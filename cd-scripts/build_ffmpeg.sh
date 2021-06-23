#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir="${script_dir}/.."
ndk_project_dir="${project_dir}/.build"
ANDROID_NDK_VERSION='r21d'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  NDK_OS='linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  NDK_OS='darwin'
else
  echo "OS not supported '$OSTYPE'"; exit 99;
fi

export ANDROID_NDK_HOME=${ndk_project_dir}/android-ndk-${ANDROID_NDK_VERSION}
export PATH=${ANDROID_NDK_HOME}:${PATH}:/usr/local/bin

# Download NDK
if [ ! -d "$ANDROID_NDK_HOME" ]; then
  mkdir -p ${ndk_project_dir}
  cd ${ndk_project_dir}

  if command -v wget &> /dev/null
  then
    wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-${NDK_OS}-${HOSTTYPE}.zip
  elif command -v curl &> /dev/null
  then
    curl -O https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-${NDK_OS}-${HOSTTYPE}.zip
  else
    echo "Not command found to download NDK"; exit 99;
  fi
  unzip -q android-ndk-${ANDROID_NDK_VERSION}-${NDK_OS}-${HOSTTYPE}.zip
fi


# Compile FFmpeg
FFMPEG_EXT_PATH="${project_dir}/extensions/ffmpeg/src/main"
HOST_PLATFORM=${NDK_OS}-${HOSTTYPE}
ENABLED_DECODERS=(ac3 eac3)
FFMPEG_BRANCH="release/4.2"

cd "${FFMPEG_EXT_PATH}/jni"
if [ ! -d "ffmpeg" ]; then
  git clone git://source.ffmpeg.org/ffmpeg && \
    cd ffmpeg && \
    git checkout -f ${FFMPEG_BRANCH}
else
  cd ffmpeg && \
    git reset --hard HEAD && \
    git checkout -f ${FFMPEG_BRANCH}
fi

cd "${FFMPEG_EXT_PATH}/jni"
./build_ffmpeg.sh \
  "${FFMPEG_EXT_PATH}" "${ANDROID_NDK_HOME}" "${HOST_PLATFORM}" "${ENABLED_DECODERS[@]}"

if [ -f "${FFMPEG_EXT_PATH}/jni/Android.mk" ]; then
  cd "${FFMPEG_EXT_PATH}/jni" && \
    ${ANDROID_NDK_HOME}/ndk-build APP_ABI="armeabi-v7a arm64-v8a x86 x86_64" -j4
fi

# There is an issue with some Git versions behaving incorrectly when
# there are other git repositories inside one git repository.
# To avoid issues, just clear up all cloned data, as we only need
# binaries from here on.
cd "${project_dir}"
rm -Rf "${FFMPEG_EXT_PATH}/jni/ffmpeg"

exit ${exitCode}
