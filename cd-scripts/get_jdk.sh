#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir="${script_dir}/.."
temp_dir="${project_dir}/.build"
jdk_project_dir=${temp_dir}/jdk-$1.jdk
JDK_VERSION=$1

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  HOSTTYPE='linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  HOSTTYPE='osx'
else
  echo "OS not supported '$OSTYPE'"; exit 99;
fi

# Download JDK
if [ ! -d "$jdk_project_dir" ]; then
  mkdir -p ${temp_dir}
  cd ${temp_dir}

  if command -v wget &> /dev/null
  then
    wget -q https://download.java.net/java/GA/jdk11/9/GPL/openjdk-${JDK_VERSION}_${HOSTTYPE}-x64_bin.tar.gz
  elif command -v curl &> /dev/null
  then
    echo "https://download.java.net/java/GA/jdk11/9/GPL/openjdk-${JDK_VERSION}_${HOSTTYPE}-x64_bin.tar.gz"
    curl -O https://download.java.net/java/GA/jdk11/9/GPL/openjdk-${JDK_VERSION}_${HOSTTYPE}-x64_bin.tar.gz
  else
    echo "Not command found to download JDK"; exit 99;
  fi
  tar -xvf openjdk-${JDK_VERSION}_${HOSTTYPE}-x64_bin.tar.gz

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    mv jdk-${JDK_VERSION} jdk-${JDK_VERSION}.jdk
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    mv jdk-${JDK_VERSION}.jdk jdk-11.0.2.jdk-osx
    mv jdk-${JDK_VERSION}.jdk-osx/Contents/Home jdk-${JDK_VERSION}.jdk
  fi
fi
