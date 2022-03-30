#!/usr/bin/env bash

source ~/.bash_profile
jenv enable-plugin export
jenv versions
jenv shell 11

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir="${script_dir}/.."

function copyJunitReports() {
  dest=$(cd ${project_dir}; pwd)/build/junit-reports
  rm -rf "$dest" 2>/dev/null || true
  mkdir -p "$dest"

  for folder in $(find . -name "test-results"); do
    for f in $folder/testReleaseUnitTest/*.xml; do
      project=$(dirname $f)/../../../
      project=$(cd ${project}; pwd)
      project=$(basename $project)
      filename=$(basename $f)
      cp "$f" "$dest/$project-$filename" 2>/dev/null || true
    done;
  done;
}

function isProtectedBranch() {
  echo "Is this a protected branch?"
  protected_branch_pattern="(-sky$|-v2$)$"
  current_revision=$(git rev-parse HEAD)
  set +e
  git branch --remotes --contains ${current_revision} | grep -E ${protected_branch_pattern}
  result=$?
  set -e
  return ${result}
}

function isSkyBranch() {
  echo "Is this a snapshottable branch?"
  snapshot_release_branch_pattern="origin/sky/.*$"
  current_revision=$(git rev-parse HEAD)
  set +e
  git branch --remotes --contains ${current_revision} | grep ${snapshot_release_branch_pattern}
  result=$?
  set -e
  return ${result}
}

function isSnapshotCommit() {
  echo "Is this a snapshottable commit?"
  set +e
  git log -1 --pretty=%B | grep -E "^\[SNAPSHOT\]"
  result=$?
  set -e
  return ${result}
}

function shouldSkipCi() {
  echo "Should we skip building this commit?"
  set +e
  git log -1 --pretty=%B | grep -E "^\[SKIPCI\]"
  result=$?
  set -e
  return ${result}
}

if shouldSkipCi || isProtectedBranch; then
  echo "Yes"
  exit 0
else
  echo "No"
fi

cd $project_dir


if isSkyBranch || isSnapshotCommit; then
  echo "Yes"
  echo ">>>> DEPLOYING SNAPSHOT <<<<"
  $script_dir/build_ffmpeg.sh

  ./gradlew clean lintRelease testRelease assembleRelease
  # no-configure-on-demand flag is required due to an issue with jfrog artifactory plugin
  # but it's not a long term solution, as per https://github.com/gradle/gradle/issues/4783#issuecomment-393184042
  ./gradlew -Dorg.gradle.parallel=false --no-configure-on-demand \
            sourcesJar \
            javadocJar \
            generatePomFileForAarReleasePublication \
            artifactoryPublish \
            publishReleasePublicationToOneAppMavenRepository
else
  echo "No"
  ./gradlew clean lintRelease testRelease
fi
