#!/bin/bash -e

. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	make clean
	exit 0
else
	exit 255
fi

# Building separately from source tree is not supported, this means we are forced to always clean
$0 clean

hostcc=gcc
[[ "$ndk_triple" == "i686"* || "$ndk_triple" == "arm"* ]] && hostcc="gcc -m32"

# LUAJIT_T= to disable building the luajit executable
# TARGET_STRIP=" @:" disables stripping
make HOST_CC="$hostcc" HOST_LUA=lua5.2 CROSS=$ndk_triple- \
	STATIC_CC="$CC" DYNAMIC_CC="$CC -fPIC" \
	TARGET_LD="$CC" TARGET_AR="$AR rcus" TARGET_STRIP=" @:" \
	TARGET_SYS=Linux BUILDMODE=dynamic LUAJIT_T= -j$cores amalg

# ugly flags to disable installing things we didn't build
make DESTDIR="$prefix_dir" \
	INSTALL_DEP= FILE_T=/dev/null FILES_JITLIB=/dev/null install

# remove the ABI versionings for simplicity.
# Android won't let us load external C modules from writable locations anyway.
ln -Lf "$prefix_dir"/lib/libluajit{-*,}.so
patchelf --set-soname libluajit.so "$prefix_dir/lib/libluajit.so"
sed 's/-l${libname}/-lluajit/' "$prefix_dir/lib/pkgconfig/luajit.pc" -i
