#!/usr/bin/env bash

export FASTLANE_HIDE_TIMESTAMP=true
eval "$(rbenv init -)"
set -e
rbenv install -s
gem install bundler
bundle config set deployment 'true'
bundle install

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir="${script_dir}/.."

# Configure JDK
JDK_VERSION=11.0.2
$script_dir/get_jdk.sh $JDK_VERSION
export JAVA_HOME=$project_dir/.build/jdk-${JDK_VERSION}.jdk
export PATH=$JAVA_HOME/bin:$PATH:/usr/local/bin
echo "JAVA_HOME => $JAVA_HOME"
echo "PATH => $PATH"


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

function isDevelop() {
  echo "Is this a snapshottable branch?"
  snapshot_release_branch_pattern="origin/sky/develop$"
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

bundle install  --deployment

if isDevelop || isSnapshotCommit; then
  echo "Yes"
  echo ">>>> DEPLOYING SNAPSHOT <<<<"
  $script_dir/build_ffmpeg.sh
  bundle exec fastlane android stage
else
  echo "No"
  bundle exec fastlane android test
fi

copyJunitReports

exit ${exitCode}
