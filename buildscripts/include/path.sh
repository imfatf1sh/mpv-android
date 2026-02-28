#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

. "$DIR/include/depinfo.sh"

[ -z "$cores" ] && cores=$(grep -c ^processor /proc/cpuinfo)

# configure pkg-config paths if inside buildscripts
if [ -n "$ndk_triple" ]; then
	export PKG_CONFIG_SYSROOT_DIR="$prefix_dir"
	export PKG_CONFIG_LIBDIR="$PKG_CONFIG_SYSROOT_DIR/lib/pkgconfig"
	unset PKG_CONFIG_PATH
fi

toolchain=$(echo "$DIR/sdk/android-ndk-${v_ndk}/toolchains/llvm/prebuilt/"*)
[ -d "$toolchain" ] && \
	export PATH="$toolchain/bin:$DIR/sdk/android-ndk-${v_ndk}:$DIR/sdk/bin:$PATH"
export ANDROID_HOME="$DIR/sdk/android-sdk"
unset ANDROID_SDK_ROOT ANDROID_NDK_ROOT
