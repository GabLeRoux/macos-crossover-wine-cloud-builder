#!/usr/bin/env arch -x86_64 bash

set -ex

echo Wine-Crossover-MacOS

export GITHUB_WORKSPACE=$(pwd)

if [ -z "$CROSS_OVER_VERSION" ]; then
    export CROSS_OVER_VERSION=21.2.0
    echo "CROSS_OVER_VERSION not set building crossover-wine-${CROSS_OVER_VERSION}"
fi

# avoid weird linker errors with Xcode 10 and later
export MACOSX_DEPLOYMENT_TARGET=10.14
# crossover source code to be downloaded
export CROSS_OVER_SOURCE_URL=https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz
export CROSS_OVER_LOCAL_FILE=crossover-${CROSS_OVER_VERSION}
# directories / files inside the downloaded tar file directory structure
export WINE_CONFIGURE=$GITHUB_WORKSPACE/sources/wine/configure
export DXVK_BUILDSCRIPT=$GITHUB_WORKSPACE/sources/dxvk/package-release.sh
# build directories
export BUILDROOT=$GITHUB_WORKSPACE/build
# target directory for installation
export INSTALLROOT=$GITHUB_WORKSPACE/install
export PACKAGE_UPLOAD=$GITHUB_WORKSPACE/upload
# artifact names
export WINE_INSTALLATION=wine-cx${CROSS_OVER_VERSION}
export DXVK_INSTALLATION=dxvk-cx${CROSS_OVER_VERSION}

# Need to ensure Instel brew actually exists
if ! command -v "/usr/local/bin/brew" &> /dev/null
then
    echo "</usr/local/bin/brew> could not be found"
    echo "An Intel brew installation is required"
    exit
fi

# Manually configure $PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin"

echo Getting latest HomeBrew formulas/bottles
brew update

echo Installing Dependencies
# build dependencies
brew install   bison                \
               cmake                \
               gcenx/wine/cx-llvm   \
               mingw-w64            \
               ninja

# runtime dependencies for crossover-wine
brew install   faudio               \
               freetype             \
               gnutls               \
               gphoto2              \
               gst-plugins-base     \
               libpng               \
               little-cms2          \
               molten-vk            \
               mpg123               \
               sane-backends        \
               sdl2

echo "Add bison to PATH"
export PATH="$(brew --prefix bison)/bin":${PATH}

echo "Add cx-llvm to PATH"
export PATH="$(brew --prefix cx-llvm)/bin":${PATH}


############ Download and Prepare Source Code ##############

echo Get Source
if [[ ! -f ${CROSS_OVER_LOCAL_FILE}.tar.gz ]]; then
    curl -o ${CROSS_OVER_LOCAL_FILE}.tar.gz ${CROSS_OVER_SOURCE_URL}
fi

echo Extract Source
if [[ -d "${GITHUB_WORKSPACE}/sources" ]]; then
    rm -rf ${GITHUB_WORKSPACE}/sources
fi
tar xf ${CROSS_OVER_LOCAL_FILE}.tar.gz

echo "Patch Add missing distversion.h"
# Patch provided by Josh Dubois, CrossOver product manager, CodeWeavers.
pushd sources/wine
patch -p1 < ${GITHUB_WORKSPACE}/distversion.patch
popd


if [[ ${CROSS_OVER_VERSION} == 20.* ]]; then
    echo "Patch wcslen() in ntdll/wcstring.c to prevent crash if a nullptr is suppluied to the function (HACK)"
    pushd sources/wine
    patch -p1 < ${GITHUB_WORKSPACE}/wcstring.patch
    popd

    echo "Patch msvcrt to export the missing sincos function"
    # https://github.com/wine-mirror/wine/commit/f0131276474997b9d4e593bbf8c5616b879d3bd5
    pushd sources/wine
    patch -p1 < ${GITHUB_WORKSPACE}/msvcrt-sincos.patch
    popd
fi


############ Build DXVK ##############

if [[ ${CROSS_OVER_VERSION} == 21.* ]]; then
    if [[ ! -f "${PACKAGE_UPLOAD}/${DXVK_INSTALLATION}.tar.gz" ]]; then
        echo "Applying patches to DXVK"
        pushd sources/dxvk
        patch -p1 < ${GITHUB_WORKSPACE}/0001-build-macOS-Fix-up-for-macOS.patch
        patch -p1 < ${GITHUB_WORKSPACE}/0002-fix-d3d11-header-for-MinGW-9-1883.patch
        patch -p1 < ${GITHUB_WORKSPACE}/0003-fixes-for-mingw-gcc-12.patch
        popd

        echo "Installing dependencies for DXVK"
        brew install  meson     \
                      glslang

        echo "Build DXVK"
        ${DXVK_BUILDSCRIPT} master ${INSTALLROOT}/${DXVK_INSTALLATION} --no-package

        echo "Tar DXVK"
        pushd ${INSTALLROOT}
        tar -czf ${DXVK_INSTALLATION}.tar.gz ${DXVK_INSTALLATION}
        popd

        echo "Upload DXVK"
        mkdir -p ${PACKAGE_UPLOAD}
        cp ${INSTALLROOT}/${DXVK_INSTALLATION}.tar.gz ${PACKAGE_UPLOAD}/
    fi
fi

############ Build 64bit Version ##############

echo "Configure wine64-${CROSS_OVER_VERSION}"
export CC=clang
export CXX=clang++
# see https://github.com/Gcenx/macOS_Wine_builds/issues/17#issuecomment-750346843
export CROSSCFLAGS=$([[ ${CROSS_OVER_VERSION} -le 20.0.2 ]] && echo "-g -O2 -fcommon" || echo "-g -O2")
# Xcode12 by default enables '-Werror,-Wimplicit-function-declaration' (49917738)
# this causes wine(64) builds to fail so needs to be disabled.
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
export CFLAGS="-g -O2 -Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-format"
export LDFLAGS="-Wl,-headerpad_max_install_names"

export GPHOTO2_CFLAGS="-I$(brew --prefix libgphoto2)/include -I$(brew --prefix libgphoto2)/include/gphoto2"
export GPHOTO2_PORT_CFLAGS="-I$(brew --prefix libgphoto2)/include -I$(brew --prefix libgphoto2)/include/gphoto2"
export SDL2_CFLAGS="-I$(brew --prefix sdl2)/include -I$(brew --prefix sdl2)/include/SDL2"
export ac_cv_lib_soname_vulkan=""
export ac_cv_lib_soname_MoltenVK="$(brew --prefix molten-vk)/lib/libMoltenVK.dylib"

mkdir -p ${BUILDROOT}/wine64-${CROSS_OVER_VERSION}
pushd ${BUILDROOT}/wine64-${CROSS_OVER_VERSION}
${WINE_CONFIGURE} \
        --disable-option-checking \
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
        --with-mingw \
        --with-png \
        --with-sdl \
        --without-krb5 \
        --with-vulkan \
        --without-x
popd

echo "Build wine64-${CROSS_OVER_VERSION}"
pushd ${BUILDROOT}/wine64-${CROSS_OVER_VERSION}
make -j$(sysctl -n hw.ncpu 2>/dev/null)
popd


############ Build 32bit Version (WoW64) ##############

echo "Configure wine32on64-${CROSS_OVER_VERSION}"
export CC=clang
export CXX=clang++
# see https://github.com/Gcenx/macOS_Wine_builds/issues/17#issuecomment-750346843
export CROSSCFLAGS=$([[ ${CROSS_OVER_VERSION} -le 20.0.2 ]] && echo "-g -O2 -fcommon" || echo "-g -O2")
# Xcode12 by default enables '-Werror,-Wimplicit-function-declaration' (49917738)
# this causes wine(64) builds to fail so needs to be disabled.
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
export CFLAGS="-g -O2 -Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-format"
export LDFLAGS="-Wl,-headerpad_max_install_names"

export GPHOTO2_CFLAGS="-I$(brew --prefix libgphoto2)/include -I$(brew --prefix libgphoto2)/include/gphoto2"
export GPHOTO2_PORT_CFLAGS="-I$(brew --prefix libgphoto2)/include -I$(brew --prefix libgphoto2)/include/gphoto2"
export SDL2_CFLAGS="-I$(brew --prefix sdl2)/include -I$(brew --prefix sdl2)/include/SDL2"

mkdir -p ${BUILDROOT}/wine32on64-${CROSS_OVER_VERSION}
pushd ${BUILDROOT}/wine32on64-${CROSS_OVER_VERSION}
${WINE_CONFIGURE} \
        --disable-option-checking \
        --enable-win32on64 \
        --with-wine64=${BUILDROOT}/wine64-${CROSS_OVER_VERSION} \
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
        --without-gphoto \
        --without-sane \
        --with-mingw \
        --with-png \
        --with-sdl \
        --without-krb5 \
        --without-vkd3d \
        --without-vulkan \
        --disable-vulkan_1 \
        --disable-winevulkan \
        --without-x
popd

echo "Build wine32on64-${CROSS_OVER_VERSION}"
pushd ${BUILDROOT}/wine32on64-${CROSS_OVER_VERSION}
make -k -j$(sysctl -n hw.activecpu 2>/dev/null)
popd


############ Install wine ##############

echo "Install wine32on64-${CROSS_OVER_VERSION}"
pushd ${BUILDROOT}/wine32on64-${CROSS_OVER_VERSION}
make install-lib DESTDIR="${INSTALLROOT}/${WINE_INSTALLATION}"
popd

echo "Install wine64-${CROSS_OVER_VERSION}"
pushd ${BUILDROOT}/wine64-${CROSS_OVER_VERSION}
make install-lib DESTDIR="${INSTALLROOT}/${WINE_INSTALLATION}"
popd


############ Bundle and Upload Deliverable ##############

echo "Tar Wine"
pushd ${INSTALLROOT}
tar -czvf ${WINE_INSTALLATION}.tar.gz ${WINE_INSTALLATION}
popd

echo "Upload Wine"
mkdir -p ${PACKAGE_UPLOAD}
cp ${INSTALLROOT}/${WINE_INSTALLATION}.tar.gz ${PACKAGE_UPLOAD}/
