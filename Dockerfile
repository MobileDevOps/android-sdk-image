FROM ubuntu:18.04

LABEL maintainer="messeb"
    
ENV ANDROID_SDK_TOOLS_VERSION 4333796
ENV ANDROID_SDK_TOOLS_CHECKSUM 92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9

ENV ANDROID_HOME "/opt/android-sdk-linux"
ENV ANDROID_SDK_ROOT $ANDROID_HOME
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools

# Add base environment
RUN apt-get -qq update \
    && apt-get -qqy --no-install-recommends install \
    apt-utils \
    openjdk-8-jdk \
    openjdk-11-jre-headless- \
    software-properties-common \
    build-essential \
    lib32stdc++6 \
    libpulse0 \
    libglu1-mesa \
    openssh-server \
    unzip \
    curl \
    lldb \
    git > /dev/null \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   
# Download and unzip Android SDK Tools
RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_TOOLS_VERSION.zip > /tools.zip \
    && echo "$ANDROID_SDK_TOOLS_CHECKSUM ./tools.zip" | sha256sum -c \
    && unzip -qq /tools.zip -d $ANDROID_HOME \
    && rm -v /tools.zip

# Accept licenses
RUN mkdir -p $ANDROID_HOME/licenses/ \
    && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license \
    && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license \
    && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

# Add non-root user 
RUN groupadd -r mobiledevops \
    && useradd --no-log-init -r -g mobiledevops mobiledevops \
    && mkdir -p /home/mobiledevops/.android \
    && mkdir -p /home/mobiledevops/app \
    && touch /home/mobiledevops/.android/repositories.cfg \
    && chown --recursive mobiledevops:mobiledevops /home/mobiledevops \
    && chown --recursive mobiledevops:mobiledevops /home/mobiledevops/app \
    && chown --recursive mobiledevops:mobiledevops $ANDROID_HOME

# Set non-root user as default      
ENV HOME /home/mobiledevops
USER mobiledevops
WORKDIR $HOME/app

# Install Android packages
ADD packages.txt $HOME
RUN $ANDROID_HOME/tools/bin/sdkmanager --update \
    && while read -r pkg; do PKGS="${PKGS}${pkg} "; done < $HOME/packages.txt \
    && $ANDROID_HOME/tools/bin/sdkmanager $PKGS > /dev/null \
    && rm $HOME/packages.txt
