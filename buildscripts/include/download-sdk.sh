#!/bin/bash -e

. ./include/depinfo.sh

. ./include/path.sh

if ! javac -version &>/dev/null; then
	echo "Error: missing Java Development Kit. Install it manually."
	exit 255
fi

mkdir -p sdk && cd sdk

# Android SDK
if [ ! -d "android-sdk" ]; then
	echo "Android SDK not found. Downloading commandline tools."
	wget "https://dl.google.com/android/repository/commandlinetools-linux-${v_sdk}.zip"
	mkdir "android-sdk"
	unzip -q -d "android-sdk" "commandlinetools-linux-${v_sdk}.zip"
	rm "commandlinetools-linux-${v_sdk}.zip"
fi
sdkmanager () {
	local exe="./android-sdk/cmdline-tools/latest/bin/sdkmanager"
	[ -x "$exe" ] || exe="./android-sdk/cmdline-tools/bin/sdkmanager"
	"$exe" --sdk_root="${ANDROID_HOME}" "$@"
}
echo y | sdkmanager \
	"platforms;android-${v_sdk_platform}" "build-tools;${v_sdk_build_tools}" \
	"extras;android;m2repository"

# Android NDK (either standalone or installed by SDK)
if [ -d "android-ndk-${v_ndk}" ]; then
	echo "Android NDK directory found."
elif [ -d "android-sdk/ndk/${v_ndk_n}" ]; then
	echo "Creating NDK symlink to SDK."
	ln -s "android-sdk/ndk/${v_ndk_n}" "android-ndk-${v_ndk}"
else
	echo "Downloading NDK."
	wget "http://dl.google.com/android/repository/android-ndk-${v_ndk}-linux.zip"
	unzip -q "android-ndk-${v_ndk}-linux.zip"
	rm "android-ndk-${v_ndk}-linux.zip"
fi
if ! grep -qF "${v_ndk_n}" "android-ndk-${v_ndk}/source.properties"; then
	echo "Error: NDK exists but is not the correct version (expecting ${v_ndk_n})"
	exit 255
fi

# gas-preprocessor
mkdir -p bin
wget "https://github.com/FFmpeg/gas-preprocessor/raw/master/gas-preprocessor.pl" \
	-O bin/gas-preprocessor.pl
chmod +x bin/gas-preprocessor.pl

cd ..
