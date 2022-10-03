#!/usr/bin/env bash
echo "Downloading few Dependecies . . ."
git clone --depth=1 https://github.com/Synchroz/msm4.9_santonikernel santoni
git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 -b gcc-master gcc
git clone --depth=1 https://github.com/mvaisakh/gcc-arm -b gcc-master gcc32

# Main
KERNEL_NAME=Core # IMPORTANT ! Declare your kernel name
KERNEL_ROOTDIR=$(pwd)/santoni # IMPORTANT ! Fill with your kernel source root directory.
DEVICE_CODENAME=santoni # IMPORTANT ! Declare your device codename
DEVICE_DEFCONFIG=santoni_treble_defconfig # IMPORTANT ! Declare your kernel source defconfig file here.
GCC_ROOTDIR=$(pwd)/gcc # IMPORTANT! Put your gcc directory here.
GCC32_ROOTDIR=$(pwd)/gcc32 # IMPORTANT! Put your gcc32 directory here.
export KBUILD_BUILD_USER=Synchroz # Change with your own name or else.
export KBUILD_BUILD_HOST=Bloodedge # Change with your own hostname.
GCC_VERSION="$("$GCC_ROOTDIR"/bin/aarch64-elf-gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
LLD_VERSION="$("$GCC_ROOTDIR"/bin/aarch64-elf-ld.lld --version | head -n 1)"
COMPILER_STRING="$GCC_VERSION with $LLD_VERSION"
IMAGE=$(pwd)/santoni/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%F-%S")
START=$(date +"%s")
PATH="${GCC_ROOTDIR}/bin/:${GCC32_ROOTDIR}/bin/:/usr/bin:${PATH}"

# Checking environtment
# Warning !! Dont Change anything there without known reason.
function check() {
echo ================================================
echo xKernelCompiler CircleCI Edition
echo version : rev1.5 - gaspoll
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo DEVICE_DEFCONFIG = ${DEVICE_DEFCONFIG}
echo GCC_VERSION = $(${GCC_ROOTDIR}/bin/aarch64-elf-gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')
echo GCC32_VERSION = $(${GCC32_ROOTDIR}//bin/arm-eabi-gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')
echo LLD_VERSION = $(${GCC_ROOTDIR}/bin/ld.lld --version | head -n 1)
echo GCC_ROOTDIR = ${GCC_ROOTDIR}
echo KERNEL_ROOTDIR = ${KERNEL_ROOTDIR}
echo ================================================
}

# Compiler
function compile() {

   # Your Telegram Group
   curl -s -X POST "https://api.telegram.org/bot2030871213:AAEnZeoBtgl-jdsIaXfoGswrkKtCNQ0hK2U/sendMessage" \
        -d chat_id="-1001567409765" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>xKernelCompiler</b>%0ABUILDER NAME : <code>${KBUILD_BUILD_USER}</code>%0ABUILDER HOST : <code>${KBUILD_BUILD_HOST}</code>%0ADEVICE DEFCONFIG : <code>${DEVICE_DEFCONFIG}</code>%0AGCC VERSION : <code>${COMPILER_STRING}</code>"

  cd ${KERNEL_ROOTDIR}
  make -j$(nproc) O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
  make -j$(nproc) ARCH=arm64 O=out \
    CROSS_COMPILE=${GCC_ROOTDIR}/bin/aarch64-elf- \
    CROSS_COMPILE_ARM32=${GCC32_ROOTDIR}/bin/arm-eabi- \
    AR=${GCC_ROOTDIR}/bin/aarch64-elf-gcc-ar \
    AS=${GCC_ROOTDIR}/bin/aarch64-elf-as \
#    NM=${GCC_ROOTDIR}/bin/aarch64-elf-gcc-nm \
#    RANLIB=${GCC_ROOTDIR}/bin/aarch64-elf-gcc-ranlib \
#    NM=${GCC_ROOTDIR}/bin/llvm-nm \
    CC=${GCC_ROOTDIR}/bin/aarch64-elf-gcc \
#    OBJCOPY=${GCC_ROOTDIR}/bin/aarch64-elf-objcopy \
#    OBJCOPY=${GCC_ROOTDIR}/bin/llvm-objcopy \
    OBJDUMP=${GCC_ROOTDIR}/bin/aarch64-elf-objdump \
    OBJSIZE=${GCC_ROOTDIR}/bin/aarch64-elf-size \
    READELF=${GCC_ROOTDIR}/bin/aarch64-elf-readelf \
    STRIP=${GCC_ROOTDIR}/bin/aarch64-elf-strip \
    LD=${GCC_ROOTDIR}/bin/aarch64-elf-ld.lld

   if ! [ -a "$IMAGE" ]; then
	finerr
	exit 1
   fi
	cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}

# Push
function push() {
    cd out/arch/arm64/boot
    curl -F document=@Image.gz-dtb "https://api.telegram.org/bot2030871213:AAEnZeoBtgl-jdsIaXfoGswrkKtCNQ0hK2U/sendDocument" \
        -F chat_id="-1001567409765" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Redmi 4X (santoni)</b> | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"

}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot2030871213:AAEnZeoBtgl-jdsIaXfoGswrkKtCNQ0hK2U/sendMessage" \
        -d chat_id="-1001567409765" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

check
compile
END=$(date +"%s")
DIFF=$(($END - $START))
push
