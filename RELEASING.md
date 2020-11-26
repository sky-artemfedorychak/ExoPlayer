# How to release snapshots #

Snapshots releases are generated for every submit PR to any `sky/*` branch to this repository and deployed automatically to [https://artifactory.tools.ottcds.com/artifactory/core-video-sdk-android-maven/](https://artifactory.tools.ottcds.com/artifactory/core-video-sdk-android-maven/). Artifacts have the same group and artifactId as original ExoPlayer artifacts, but with version **_$version-cvsdk-$commit_**, where **_$version_** is the current ExoPlayer branch and _**$commit**_ its a commit in sky forementioned branch (xe: **_2.11.7-cvsdk-2a8ed20_**)

## Releasing against CI

Upload a PR to a `sky/*` branch. Sky continuous integration will build and test your PR. Once the PR is merged into the reference `sky/*` branch, it will be deployed automatically to [https://artifactory.tools.ottcds.com/artifactory/core-video-sdk-android-maven/](https://artifactory.tools.ottcds.com/artifactory/core-video-sdk-android-maven/).

## Manual releases

We should not release locally, they should always happen on CI. These notes are here for the rare circumstances when
a local release has to be done (i.e. catastrophic CI failure).

Before proceed with the local release, you must prepare your environment by following these steps,

- Ensure you have installed [rbenv](https://github.com/rbenv/rbenv#homebrew-on-macos), <abbr title="too long, didn't read">tl;dr:</abbr>
    - `brew install rbenv`
    - `rbenv init`
- Enter your Android SDK clone directory and run `rbenv install` to install the version mentioned in [`.ruby-version`](.ruby-version)
    - Run `which ruby` and `which gem` to ensure that they point to the versions in `~/.rbenv/shims` and not the system ones
- Install Bundler: `gem install bundler`
- Run `bundle install` to install the Gems (on CI, this is run with the [`--deployment`](https://bundler.io/man/bundle-install.1.html#DEPLOYMENT-MODE) flag)


Once your environment is ready,

- Create a local commit with your changes
- Run the following command

```
bundle exec fastlane android stage
```

All the whole project will be compiled, tested, static analysed and, finally, deployed to [https://artifactory.tools.ottcds.com/artifactory/core-video-sdk-android-maven/](https://artifactory.tools.ottcds.com/artifactory/core-video-sdk-android-maven/).


## Other releasing information

If you need to generate an snapshot, just prefix a commit message with `[SNAPSHOT]` to create a snapshot release from CI.

You MUST NOT do it, but if you need to skip the CI checks, just prefix a commit message with `[SKIPCI]` to skip CI checks.
