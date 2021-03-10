#!/usr/bin/env bash

set -ex

SCRIPT_DIR="`dirname \"${BASH_SOURCE}\"`"

cp ${SCRIPT_DIR}/distversion.h sources/wine/include/distversion.h

# patch sources/wine/dlls/winecoreaudio.drv/authorization.m < ${SCRIPT_DIR}/winecoreaudio.patch

patch sources/wine/include/msvcrt/stdio.h < ${SCRIPT_DIR}/msvcrt_stdio.patch

patch sources/wine/dlls/comctl32/propsheet.c < ${SCRIPT_DIR}/comctl32_propsheet.patch
patch sources/wine/dlls/comctl32/taskdialog.c < ${SCRIPT_DIR}/comctl32_taskdialog.patch
patch sources/wine/dlls/comctl32/treeview.c < ${SCRIPT_DIR}/comctl32_treeview.patch
