#!/usr/bin/env bash

set -ex

echo Wine-Crossover-MacOS

export GITHUB_WORKSPACE=$(pwd)

if [ -z "$CROSS_OVER_VERSION" ]; then
    export CROSS_OVER_VERSION=20.0.4
fi

# avoid weird linker errors with Xcode 10 and later
export MACOSX_DEPLOYMENT_TARGET=10.14
# crossover source code to be downloaded
export CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz
export CROSS_OVER_LOCAL_FILE=crossover-${matrix.CROSS_OVER_VERSION}
# directories / files inside the downloaded tar file directory structure
export LLVM_MAKEDIR=$GITHUB_WORKSPACE/sources/clang/llvm
export CLANG_MAKEDIR=$GITHUB_WORKSPACE/sources/clang/clang
export WINE_CONFIGURE=$GITHUB_WORKSPACE/sources/wine/configure
export DXVK_BUILDSCRIPT=$GITHUB_WORKSPACE/sources/dxvk/package-release.sh
# build directories
export BUILDROOT=$GITHUB_WORKSPACE/build
export LLVM_BUILDDIR=$GITHUB_WORKSPACE/build/llvm
export CLANG_BUILDDIR=$GITHUB_WORKSPACE/build/clang
# target directories for installation (must be relative to $GITHUB_WORKSPACE)
export TOOLS_INSTALLROOT=install/build-tools
export WINE_INSTALLROOT=install/wine
export DXVK_INSTALLROOT=install/dxvk
export PACKAGE_UPLOAD=install/packages
# artifact names
export BUILDTOOLS=build-tools
export WINE_SOURCES=cwine.src-cx${CROSS_OVER_VERSION}-patched
export DXVK_SOURCES=dxvk.src-cx${CROSS_OVER_VERSION}-patched
export WINE_INSTALLATION=wine-cx${CROSS_OVER_VERSION}
export DXVK_INSTALLATION=dxvk-cx${CROSS_OVER_VERSION}


echo Install Dependencies
# build tools
brew install  cmake            \
              ninja            \
              mingw-w64        \

# build dependencies for wine / crossover
brew install  freetype         \
              bison            \
              krb5             \
              faudio           \
              sdl2             \
              gphoto2          \
              gst-plugins-base \
              mpg123           \
              little-cms2      \
              libpng           \
              molten-vk

# dependencies for dxvk
brew install  coreutils \
            meson     \
            glslang

echo Add bison and krb5 to PATH
export PATH="$(brew --prefix bison)/bin":${PATH}
export PATH="$(brew --prefix krb5)/bin":${PATH}

echo Add llvm/clang to PATH for later
export PATH="$GITHUB_WORKSPACE/${TOOLS_INSTALLROOT}/bin":${PATH}


############ Download and Prepare Source Code ##############

echo Get Source
curl -o ${CROSS_OVER_LOCAL_FILE}.tar.gz ${CROSS_OVER_SOURCE_URL}

echo Upload Original Crossover Sources
mkdir -p ${PACKAGE_UPLOAD}
cp ${CROSS_OVER_LOCAL_FILE}.tar.gz ${PACKAGE_UPLOAD}/

echo Extract Source
tar xf ${CROSS_OVER_LOCAL_FILE}.tar.gz

echo Add distversion.h
cp distversion.h sources/wine/include/distversion.h

echo Patch DXVK
patch sources/dxvk/src/util/rc/util_rc_ptr.h < dxvk_util_rc_ptr.patch

echo Tar Patched Crossover Sources
tar -czvf ${WINE_SOURCES}.tar.gz ./sources/wine

echo Upload Patched Crossover Sources
mkdir -p ${PACKAGE_UPLOAD}
cp ${WINE_SOURCES}.tar.gz ${PACKAGE_UPLOAD}/

echo Tar Patched DXVK Sources
 tar -czvf ${DXVK_SOURCES}.tar.gz ./sources/dxvk

echo Upload Patched DXVK Sources
mkdir -p ${PACKAGE_UPLOAD}
cp ${DXVK_SOURCES}.tar.gz ${PACKAGE_UPLOAD}/


############ Build LLVM / Clang ##############

echo Configure LLVM
mkdir -p ${LLVM_BUILDDIR}
pushd ${LLVM_BUILDDIR}
cmake -G Ninja \
    -DLLVM_TARGETS_TO_BUILD=X86 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$GITHUB_WORKSPACE/${TOOLS_INSTALLROOT}" \
    ${LLVM_MAKEDIR}
popd

echo Build LLVM
pushd ${LLVM_BUILDDIR}
Ninja
popd

echo Install LLVM
pushd ${LLVM_BUILDDIR}
Ninja install
popd

echo Configure Clang
mkdir -p ${CLANG_BUILDDIR}
pushd ${CLANG_BUILDDIR}
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$GITHUB_WORKSPACE/${TOOLS_INSTALLROOT}" \
    ${CLANG_MAKEDIR}
popd

echo Build Clang
pushd ${CLANG_BUILDDIR}
Ninja
popd

echo Install Clang
pushd ${CLANG_BUILDDIR}
Ninja install
popd

echo Tar Build Tools
tar -czf ${BUILDTOOLS}.tar.gz ${TOOLS_INSTALLROOT}

echo Upload Build Tools
mkdir -p ${PACKAGE_UPLOAD}
cp ${BUILDTOOLS}.tar.gz ${PACKAGE_UPLOAD}/


############ Build DXVK ##############

echo Build DXVK
PATH="$(brew --prefix coreutils)/libexec/gnubin:${PATH}" ${DXVK_BUILDSCRIPT} master $GITHUB_WORKSPACE/${DXVK_INSTALLROOT} --no-package

echo Tar DXVK
tar -czf ${DXVK_INSTALLATION}.tar.gz ${DXVK_INSTALLROOT}

echo Upload DXVK
mkdir -p ${PACKAGE_UPLOAD}
cp ${DXVK_INSTALLATION}.tar.gz ${PACKAGE_UPLOAD}/


############ Build 64bit Version ##############

echo Configure wine64
export CC=clang
export CXX=clang++
# Xcode12 by default enables '-Werror,-Wimplicit-function-declaration' (49917738)
# this causes wine(64) builds to fail so needs to be disabled.
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
export CFLAGS="-Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-format"

export SDL2_CFLAGS="-I$(brew --prefix sdl2)/include"
export SDL2_LIBS="-L$(brew --prefix sdl2)/lib"

export PNG_CFLAGS="-I$(brew --prefix libpng)/include"
export PNG_LIBS="-L$(brew --prefix libpng)/lib"

export LDFLAGS="-L $(brew --prefix molten-vk)/lib"

mkdir -p ${BUILDROOT}/wine64
pushd ${BUILDROOT}/wine64
${WINE_CONFIGURE} \
        --enable-win64 \
        --disable-tests \
        --without-alsa \
        --without-capi \
        --without-dbus \
        --without-inotify \
        --without-oss \
        --without-pulse \
        --without-udev \
        --without-v4l2 \
        --without-gsm \
        --with-png \
        --with-sdl \
        --with-vulkan \
        --without-x
popd

echo Build wine64
pushd ${BUILDROOT}/wine64
make -j$(sysctl -n hw.ncpu 2>/dev/null)
popd

echo Install wine64
pushd ${BUILDROOT}/wine64
make install-lib DESTDIR="$GITHUB_WORKSPACE/${WINE_INSTALLROOT}"
popd


############ Build 32bit Version (WoW64) ##############

echo Configure wine32on64
export CC=clang
export CXX=clang++
# Xcode12 by default enables '-Werror,-Wimplicit-function-declaration' (49917738)
# this causes wine(64) builds to fail so needs to be disabled.
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
export CFLAGS="-Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-format"

export SDL2_CFLAGS="-I$(brew --prefix sdl2)/include"
export SDL2_LIBS="-L$(brew --prefix sdl2)/lib"

export PNG_CFLAGS="-I$(brew --prefix libpng)/include"
export PNG_LIBS="-L$(brew --prefix libpng)/lib"

mkdir -p ${BUILDROOT}/wine32on64
pushd ${BUILDROOT}/wine32on64
${WINE_CONFIGURE} \
        --enable-win32on64 \
        --with-wine64=${BUILDROOT}/wine64 \
        --disable-tests \
        --without-alsa \
        --without-capi \
        --without-dbus \
        --without-inotify \
        --without-oss \
        --without-pulse \
        --without-udev \
        --without-v4l2 \
        --disable-winedbg \
        --without-cms \
        --without-gstreamer \
        --without-gsm \
        --with-png \
        --with-sdl \
        --without-vkd3d \
        --without-vulkan \
        --disable-vulkan_1 \
        --disable-winevulkan \
        --without-x
popd

echo Build wine32on64
pushd ${BUILDROOT}/wine32on64
make -j$(sysctl -n hw.ncpu 2>/dev/null)
popd

echo Install wine32on64
pushd ${BUILDROOT}/wine32on64
make install-lib DESTDIR="$GITHUB_WORKSPACE/${WINE_INSTALLROOT}"
popd


############ Bundle and Upload Deliverable ##############

echo Tar Wine
tar -czvf ${WINE_INSTALLATION}.tar.gz ${WINE_INSTALLROOT}

echo Upload Wine
mkdir -p ${PACKAGE_UPLOAD}
cp ${WINE_INSTALLATION}.tar.gz ${PACKAGE_UPLOAD}/
