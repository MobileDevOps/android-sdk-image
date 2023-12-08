# Docker image for Android SDK
Docker image to build an Android app `*.apk`.
The image contains the latest [Android SDK tools](https://developer.android.com/studio#cmdline-tools), [Gradle 8.2](https://developer.android.com/build/releases/gradle-plugin) and the Android SDK platform packages from [packages.txt](packages.txt):


* build-tools;34.0.0
* build-tools;33.0.2
* platforms;android-34
* platforms;android-34-ext8
* platforms;android-33
* platform-tools
* extras;android;m2repository
* extras;google;google_play_services
* extras;google;m2repository
* add-ons;addon-google_apis-google-24

The [releases tags](https://github.com/mobiledevops/android-sdk-image/releases) are oriented on the base of the *Build Tools* version from [packages.txt](packages.txt).

## Usage

The image can be used on different cloud build services or own hosted pipeline solutions like Travis CI, CircleCI or GitLab CI/CD.

### CircleCI

CircleCI supports the direct specification of a Docker image and checks out the source code in it: https://circleci.com/docs/2.0/circleci-images/

Therefore you execute your CI script directly in the container.

Example:

```
# .circleci/config.yml
version: 2.1
jobs:
  build:
    docker: 
      - image: mobiledevops/android-sdk-image:34.0.0
    steps:
      - checkout
      - run:
          name: Android Build
          command: ./gradlew clean assembleRelease
```

Example Project: https://github.com/mobiledevops/android-ci-demo

### Travis CI 

To use a Docker container on Travis CI, you have to pull, run and execute it manually because Travis CI has no Docker executor: https://docs.travis-ci.com/user/docker/

And to prevent to do a new checkout of the source code in the Docker image, you can copy the code into the container via `tar` (see https://docs.docker.com/engine/reference/commandline/cp/).
To execute your CI script, use `docker exec` with the container name.

Example:

```
# .travis.yml
dist: bionic

services:
  - docker

env:
  - DOCKER_IMAGE=mobiledevops/android-sdk-image:34.0.0

before_install:
  - docker pull $DOCKER_IMAGE
  - docker run --name android_ci -t -d $DOCKER_IMAGE /bin/sh
  - tar Ccf . - . | docker exec -i android_ci tar Cxf /home/mobiledevops/app -

script:
  - docker exec android_ci ./gradlew clean assembleRelease
```
Example Project: https://github.com/mobiledevops/android-ci-demo

### GitLab CI

GitLab CI/CD supports to run jobs on provided Docker images: https://docs.gitlab.com/runner/executors/docker.html

Therefore you execute your CI script directly in the container.

Example:

```
# .gitlab-ci.yml
image: mobiledevops/android-sdk-image:34.0.0

stages:
    - build

release_build:
    stage: build
    tags:
      - shared
    script:
        - ./gradlew clean assembleRelease
```

Example Project: https://gitlab.com/mobiledevops/android-ci-demo

---

[Contributing](.github/CONTRIBUTING.md)

[Code of Conduct](.github/CODE_OF_CONDUCT.md)
