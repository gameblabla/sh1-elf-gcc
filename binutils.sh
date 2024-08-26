#!/bin/bash

###################################################################
#Script Name	:   build-binutils                                                                                            
#Description	:   build binutils for the SuperH2 toolchain   
#Date           :   samedi, 4 avril 2020                                                                          
#Args           :   Welcome to the next level!                                                                                        
#Author       	:   Jacques Belosoukinski (kentosama)                                                   
#Email         	:   kentosama@genku.net                                          
###################################################################

VERSION="2.43"
ARCHIVE="binutils-${VERSION}.tar.bz2"
URL="https://ftp.gnu.org/gnu/binutils/${ARCHIVE}"
SHA512SUM="ad00688eef3e70862850dfd865bd4b2baf95b34338d3d1b3ae1bdf840b9eac0f528a1c96767458ee9d06559dadafccb13aab5caae77bedf84443a551caef1289"
DIR="binutils-${VERSION}"

# Check if user is root
if [ ${EUID} == 0 ]; then
    echo "Please don't run this script as root"
    exit 1
fi


# Create build folder
mkdir -p ${BUILD_DIR}/${DIR}

cd ${DOWNLOAD_DIR}

# Download binutils if is needed
if ! [ -f "${ARCHIVE}" ]; then
    wget ${URL}
fi

# Extract binutils archive if is needed
if ! [ -d "${SRC_DIR}/${DIR}" ]; then
    if [ $(sha512sum ${ARCHIVE} | awk '{print $1}') != ${SHA512SUM} ]; then
        echo "SHA512SUM verification of ${ARCHIVE} failed!"
        exit
    else
        tar jxvf ${ARCHIVE} -C ${SRC_DIR}
    fi
fi

cd ${BUILD_DIR}/${DIR}

# Enable gold for 64bit
if [ ${ARCH} != "i386" ] && [ ${ARCH} != "i686" ]; then
    GOLD="--enable-gold"
fi

# Configure before build
${SRC_DIR}/${DIR}/configure     --prefix=${INSTALL_DIR} \
                                --build=${BUILD_MACH} \
                                --host=${HOST_MACH} \
                                --target=${TARGET} \
                                --disable-werror \
                                --disable-nls \
                                --enable-libssp \
                                --enable-lto \
                                --program-prefix=${PROGRAM_PREFIX} \
                                --disable-nls \
                                --with-multilib-list=m1 \
                                ${GOD}


# build and install binutils
make -j${NUM_PROC} 2<&1 | tee build.log

# Install binutils
if [ $? -eq 0 ]; then
    make install -j${NUM_PROC}
fi
