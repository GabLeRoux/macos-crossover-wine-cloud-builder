#!/usr/bin/env arch -x86_64 bash

set -e

printtag() {
    # GitHub Actions tag format
    echo "::$1::${2-}"
}

begingroup() {
    printtag "group" "$1"
}

endgroup() {
    printtag "endgroup"
}

export GITHUB_WORKSPACE=$(pwd)

if [ -z "$CROSS_OVER_VERSION" ]; then
    export CROSS_OVER_VERSION=22.0.1
    echo "CROSS_OVER_VERSION not set building crossover-wine-${CROSS_OVER_VERSION}"
fi

export CX_MAJOR="${CROSS_OVER_VERSION:0:2}"

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

# Need to ensure Intel brew actually exists
if ! command -v "/usr/local/bin/brew" &> /dev/null
then
    echo "</usr/local/bin/brew> could not be found"
    echo "An Intel brew installation is required"
    exit
fi

# Manually configure $PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin"


begingroup "Installing Dependencies"
# build dependencies
brew install \
    bison \
    gcenx/wine/cx-llvm \
    mingw-w64 \
    pkgconfig

# runtime dependencies for crossover-wine
brew install \
    freetype \
    gnutls \
    molten-vk \
    sdl2

if [[ ${CX_MAJOR} < 22 ]]; then
    brew install \
        faudio \
        libpng \
        mpg123
fi
endgroup


export CC="$(brew --prefix cx-llvm)/bin/clang"
export CXX="${CC}++"
export BISON="$(brew --prefix bison)/bin/bison"

# Xcode12 by default enables '-Werror,-Wimplicit-function-declaration' (49917738)
# this causes wine(64) builds to fail so needs to be disabled.
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
export CFLAGS="-g -O2 -Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-format"
export LDFLAGS="-Wl,-headerpad_max_install_names"

# avoid weird linker errors with Xcode 10 and later
export MACOSX_DEPLOYMENT_TARGET=10.14

# see https://github.com/Gcenx/macOS_Wine_builds/issues/17#issuecomment-750346843
export CROSSCFLAGS=$([[ ${CX_MAJOR} < 21 ]] && echo "-g -O2 -fcommon" || echo "-g -O2")

export SDL2_CFLAGS="-I$(brew --prefix sdl2)/include -I$(brew --prefix sdl2)/include/SDL2"
export ac_cv_lib_soname_MoltenVK="libMoltenVK.dylib"
export ac_cv_lib_soname_vulkan=""


begingroup "Download & extracting source"
if [[ ! -f ${CROSS_OVER_LOCAL_FILE}.tar.gz ]]; then
    curl -o ${CROSS_OVER_LOCAL_FILE}.tar.gz ${CROSS_OVER_SOURCE_URL}
fi


if [[ -d "${GITHUB_WORKSPACE}/sources" ]]; then
    rm -rf ${GITHUB_WORKSPACE}/sources
fi
tar xf ${CROSS_OVER_LOCAL_FILE}.tar.gz
endgroup


begingroup "Patch Add missing distversion.h"
# Patch provided by Josh Dubois, CrossOver product manager, CodeWeavers.
pushd sources/wine
patch -p1 < ${GITHUB_WORKSPACE}/distversion.patch
popd
endgroup


if [[ ${CROSS_OVER_VERSION} == 22.0.0 ]]; then
    pushd sources/wine
    patch -p1 < ${GITHUB_WORKSPACE}/CX22.0.0-vkd3d-1.4.patch
    popd
fi

if [[ ${CX_MAJOR} == 20 ]]; then
    begingroup "Patch wcslen() in ntdll/wcstring.c to prevent crash if a nullptr is supplied to the function (HACK)"
    pushd sources/wine
    patch -p1 < ${GITHUB_WORKSPACE}/wcstring.patch
    popd
    endgroup

    begingroup "Patch msvcrt to export the missing sincos function"
    # https://gitlab.winehq.org/wine/wine/-/commit/f0131276474997b9d4e593bbf8c5616b879d3bd5
    pushd sources/wine
    patch -p1 < ${GITHUB_WORKSPACE}/msvcrt-sincos.patch
    popd
    endgroup
fi


if [[ ${CX_MAJOR} -ge 21 ]]; then
    if [[ ! -f "${PACKAGE_UPLOAD}/${DXVK_INSTALLATION}.tar.gz" ]]; then
        begingroup "Applying patches to DXVK"
        pushd sources/dxvk
        patch -p1 < ${GITHUB_WORKSPACE}/0001-build-macOS-Fix-up-for-macOS.patch
        patch -p1 < ${GITHUB_WORKSPACE}/0002-fix-d3d11-header-for-MinGW-9-1883.patch
        patch -p1 < ${GITHUB_WORKSPACE}/0003-fixes-for-mingw-gcc-12.patch
        popd
        endgroup

        begingroup "Installing dependencies for DXVK"
        brew install \
            meson \
            glslang
        endgroup

        begingroup "Build DXVK"
        ${DXVK_BUILDSCRIPT} master ${INSTALLROOT}/${DXVK_INSTALLATION} --no-package
        endgroup

        begingroup "Tar DXVK"
        pushd ${INSTALLROOT}
        tar -czf ${DXVK_INSTALLATION}.tar.gz ${DXVK_INSTALLATION}
        popd
        endgroup

        begingroup "Upload DXVK"
        mkdir -p ${PACKAGE_UPLOAD}
        cp ${INSTALLROOT}/${DXVK_INSTALLATION}.tar.gz ${PACKAGE_UPLOAD}/
        endgroup
    fi
fi


begingroup "Configure wine64-${CROSS_OVER_VERSION}"
mkdir -p ${BUILDROOT}/wine64-${CROSS_OVER_VERSION}
pushd ${BUILDROOT}/wine64-${CROSS_OVER_VERSION}
${WINE_CONFIGURE} \
    --disable-option-checking \
    --enable-win64 \
    --disable-winedbg \
    --disable-tests \
    --without-alsa \
    --without-capi \
    --with-coreaudio \
    --with-cups \
    --without-dbus \
    --without-fontconfig \
    --with-freetype \
    --with-gettext \
    --without-gettextpo \
    --without-gphoto \
    --with-gnutls \
    --without-gssapi \
    --without-gstreamer \
    --without-inotify \
    --without-krb5 \
    --with-mingw \
    --without-netapi \
    --with-opencl \
    --with-opengl \
    --without-oss \
    --with-pcap \
    --with-pthread \
    --without-pulse \
    --without-sane \
    --with-sdl \
    --without-udev \
    --with-unwind \
    --without-usb \
    --without-v4l2 \
    --without-x
popd
endgroup


begingroup "Build wine64-${CROSS_OVER_VERSION}"
pushd ${BUILDROOT}/wine64-${CROSS_OVER_VERSION}
make -j$(sysctl -n hw.ncpu 2>/dev/null)
popd
endgroup


begingroup "Configure wine32on64-${CROSS_OVER_VERSION}"
mkdir -p ${BUILDROOT}/wine32on64-${CROSS_OVER_VERSION}
pushd ${BUILDROOT}/wine32on64-${CROSS_OVER_VERSION}
${WINE_CONFIGURE} \
    --disable-option-checking \
    --enable-win32on64 \
    --disable-winedbg \
    --with-wine64=${BUILDROOT}/wine64-${CROSS_OVER_VERSION} \
    --disable-tests \
    --without-alsa \
    --without-capi \
    --with-coreaudio \
    --with-cups \
    --without-dbus \
    --without-fontconfig \
    --with-freetype \
    --with-gettext \
    --without-gettextpo \
    --without-gphoto \
    --with-gnutls \
    --without-gssapi \
    --without-gstreamer \
    --without-inotify \
    --without-krb5 \
    --with-mingw \
    --without-netapi \
    --with-opencl \
    --with-opengl \
    --without-oss \
    --with-pcap \
    --with-pthread \
    --without-pulse \
    --without-sane \
    --with-sdl \
    --without-udev \
    --with-unwind \
    --without-usb \
    --without-v4l2 \
    --without-x \
    --without-vulkan \
    --disable-vulkan_1 \
    --disable-winevulkan
popd
endgroup


begingroup "Build wine32on64-${CROSS_OVER_VERSION}"
pushd ${BUILDROOT}/wine32on64-${CROSS_OVER_VERSION}
make -k -j$(sysctl -n hw.activecpu 2>/dev/null)
popd
endgroup


begingroup "Install wine32on64-${CROSS_OVER_VERSION}"
pushd ${BUILDROOT}/wine32on64-${CROSS_OVER_VERSION}
make install-lib DESTDIR="${INSTALLROOT}/${WINE_INSTALLATION}"
popd
endgroup


begingroup "Install wine64-${CROSS_OVER_VERSION}"
pushd ${BUILDROOT}/wine64-${CROSS_OVER_VERSION}
make install-lib DESTDIR="${INSTALLROOT}/${WINE_INSTALLATION}"
popd
endgroup


begingroup "Tar Wine"
pushd ${INSTALLROOT}
tar -czvf ${WINE_INSTALLATION}.tar.gz ${WINE_INSTALLATION}
popd
endgroup


begingroup "Upload Wine"
mkdir -p ${PACKAGE_UPLOAD}
cp ${INSTALLROOT}/${WINE_INSTALLATION}.tar.gz ${PACKAGE_UPLOAD}/
endgroup
