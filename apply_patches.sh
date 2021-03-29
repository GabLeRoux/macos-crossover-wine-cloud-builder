#!/usr/bin/env bash

set -ex

SCRIPT_DIR="`dirname \"${BASH_SOURCE}\"`"
WINE_DLLS="sources/wine/dlls"

cp ${SCRIPT_DIR}/patches/distversion.h sources/wine/include/distversion.h

patch sources/wine/include/msvcrt/stdio.h < ${SCRIPT_DIR}/patches/msvcrt_stdio.patch

patch ${WINE_DLLS}/winecoreaudio.drv/authorization.m < ${SCRIPT_DIR}/patches/winecoreaudio.patch

patch ${WINE_DLLS}/comctl32/propsheet.c < ${SCRIPT_DIR}/patches/comctl32_propsheet.patch
patch ${WINE_DLLS}/comctl32/taskdialog.c < ${SCRIPT_DIR}/patches/comctl32_taskdialog.patch
patch ${WINE_DLLS}/comctl32/treeview.c < ${SCRIPT_DIR}/patches/comctl32_treeview.patch

patch ${WINE_DLLS}/comdlg32/filedlg.c < ${SCRIPT_DIR}/patches/comdlg32_filedlg.patch
patch ${WINE_DLLS}/comdlg32/filedlgbrowser.c < ${SCRIPT_DIR}/patches/comdlg32_filedlgbrowser.patch
patch ${WINE_DLLS}/comdlg32/printdlg.c < ${SCRIPT_DIR}/patches/comdlg32_printdlg.patch

patch ${WINE_DLLS}/cryptui/main.c < ${SCRIPT_DIR}/patches/cryptui_main.patch

patch ${WINE_DLLS}/d3dx9_24/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_24_Makefile.patch
patch ${WINE_DLLS}/d3dx9_25/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_25_Makefile.patch
patch ${WINE_DLLS}/d3dx9_26/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_26_Makefile.patch
patch ${WINE_DLLS}/d3dx9_27/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_27_Makefile.patch
patch ${WINE_DLLS}/d3dx9_28/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_28_Makefile.patch
patch ${WINE_DLLS}/d3dx9_29/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_29_Makefile.patch
patch ${WINE_DLLS}/d3dx9_30/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_30_Makefile.patch
patch ${WINE_DLLS}/d3dx9_31/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_31_Makefile.patch
patch ${WINE_DLLS}/d3dx9_32/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_32_Makefile.patch
patch ${WINE_DLLS}/d3dx9_33/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_33_Makefile.patch
patch ${WINE_DLLS}/d3dx9_34/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_34_Makefile.patch
patch ${WINE_DLLS}/d3dx9_35/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_35_Makefile.patch
patch ${WINE_DLLS}/d3dx9_36/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_36_Makefile.patch
patch ${WINE_DLLS}/d3dx9_37/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_37_Makefile.patch
patch ${WINE_DLLS}/d3dx9_38/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_38_Makefile.patch
patch ${WINE_DLLS}/d3dx9_39/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_39_Makefile.patch
patch ${WINE_DLLS}/d3dx9_40/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_40_Makefile.patch
patch ${WINE_DLLS}/d3dx9_41/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_41_Makefile.patch
patch ${WINE_DLLS}/d3dx9_42/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_42_Makefile.patch
patch ${WINE_DLLS}/d3dx9_43/Makefile.in < ${SCRIPT_DIR}/patches/d3dx9_43_Makefile.patch

patch ${WINE_DLLS}/dsound/Makefile.in < ${SCRIPT_DIR}/patches/dsound_Makefile.patch

patch ${WINE_DLLS}/dplayx/dplay.c < ${SCRIPT_DIR}/patches/dplayx_dplay.patch
patch ${WINE_DLLS}/dplayx/dplayx_global.c < ${SCRIPT_DIR}/patches/dplayx_dplayx_global.patch
patch ${WINE_DLLS}/dplayx/dplobby.c < ${SCRIPT_DIR}/patches/dplayx_dplobby.patch
patch ${WINE_DLLS}/dplayx/name_server.c < ${SCRIPT_DIR}/patches/dplayx_name_server.patch

patch ${WINE_DLLS}/gdiplus/Makefile.in < ${SCRIPT_DIR}/patches/gdiplus_Makefile.patch

patch ${WINE_DLLS}/kernelbase/console.c < ${SCRIPT_DIR}/patches/kernelbase_console.patch
patch ${WINE_DLLS}/kernelbase/memory.c < ${SCRIPT_DIR}/patches/kernelbase_memory.patch
patch ${WINE_DLLS}/kernelbase/sync.c < ${SCRIPT_DIR}/patches/kernelbase_sync.patch
patch ${WINE_DLLS}/kernelbase/thread.c < ${SCRIPT_DIR}/patches/kernelbase_thread.patch
patch ${WINE_DLLS}/kernelbase/version.c < ${SCRIPT_DIR}/patches/kernelbase_version.patch
patch ${WINE_DLLS}/kernelbase/debug.c < ${SCRIPT_DIR}/patches/kernelbase_debug.patch
patch ${WINE_DLLS}/kernelbase/loader.c < ${SCRIPT_DIR}/patches/kernelbase_loader.patch
patch ${WINE_DLLS}/kernelbase/Makefile.in < ${SCRIPT_DIR}/patches/kernelbase_Makefile.patch

patch ${WINE_DLLS}/mfplat/main.c < ${SCRIPT_DIR}/patches/mfplat_main.patch

patch ${WINE_DLLS}/hal/hal.c < ${SCRIPT_DIR}/patches/hal_hal.patch

patch ${WINE_DLLS}/msvcp70/Makefile.in < ${SCRIPT_DIR}/patches/msvcp70_Makefile.patch
patch ${WINE_DLLS}/msvcp71/Makefile.in < ${SCRIPT_DIR}/patches/msvcp71_Makefile.patch
patch ${WINE_DLLS}/msvcp80/Makefile.in < ${SCRIPT_DIR}/patches/msvcp80_Makefile.patch
patch ${WINE_DLLS}/msvcp90/Makefile.in < ${SCRIPT_DIR}/patches/msvcp90_Makefile.patch
patch ${WINE_DLLS}/msvcp100/Makefile.in < ${SCRIPT_DIR}/patches/msvcp100_Makefile.patch
patch ${WINE_DLLS}/msvcp110/Makefile.in < ${SCRIPT_DIR}/patches/msvcp110_Makefile.patch
patch ${WINE_DLLS}/msvcp120/Makefile.in < ${SCRIPT_DIR}/patches/msvcp120_Makefile.patch
patch ${WINE_DLLS}/msvcp140/Makefile.in < ${SCRIPT_DIR}/patches/msvcp140_Makefile.patch

patch ${WINE_DLLS}/mshtml/ifacewrap.c < ${SCRIPT_DIR}/patches/mshtml_ifacewrap.patch

patch ${WINE_DLLS}/ntoskrnl.exe/instr.c < ${SCRIPT_DIR}/patches/ntoskrnl_instr.patch

patch ${WINE_DLLS}/ole32/clipboard.c < ${SCRIPT_DIR}/patches/ole32_clipboard.patch
patch ${WINE_DLLS}/ole32/datacache.c < ${SCRIPT_DIR}/patches/ole32_datacache.patch
patch ${WINE_DLLS}/ole32/filelockbytes.c < ${SCRIPT_DIR}/patches/ole32_filelockbytes.patch
patch ${WINE_DLLS}/ole32/ole2.c < ${SCRIPT_DIR}/patches/ole32_ole2.patch
patch ${WINE_DLLS}/ole32/ole2impl.c < ${SCRIPT_DIR}/patches/ole32_ole2impl.patch
patch ${WINE_DLLS}/ole32/oleobj.c < ${SCRIPT_DIR}/patches/ole32_oleobj.patch
patch ${WINE_DLLS}/ole32/stg_prop.c < ${SCRIPT_DIR}/patches/ole32_stg_prop.patch
patch ${WINE_DLLS}/ole32/usrmarshal.c < ${SCRIPT_DIR}/patches/ole32_usrmarshal.patch

patch ${WINE_DLLS}/winevulkan/vulkan.c < ${SCRIPT_DIR}/patches/winevulkan_vulkan.patch
patch ${WINE_DLLS}/winevulkan/vulkan_private.h < ${SCRIPT_DIR}/patches/winevulkan_vulkan_private.patch

patch sources/dxvk/src/util/rc/util_rc_ptr.h < ${SCRIPT_DIR}/patches/dxvk_util_rc_ptr.patch
