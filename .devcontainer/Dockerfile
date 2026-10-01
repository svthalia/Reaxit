FROM docker.io/library/ubuntu:24.04

ENV DEVCONTAINER="true"
ENV DEBIAN_FRONTEND=noninteractive

# Install all system dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    clang \
    cmake \
    curl \
    openjdk-21-jdk \
    git \
    libgtk-3-dev \
    ninja-build \
    pkg-config \
    unzip \
    wget \
    zip

# Set up environment paths
ENV HOME="/home/vscode"
ENV ANDROID_HOME="${HOME}/.local/android-sdk"
ENV ANDROID_SDK_ROOT="${ANDROID_HOME}"
ENV FLUTTER_HOME="${HOME}/.local/flutter"

ENV PATH="${PATH}:${FLUTTER_HOME}/flutter/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"
ENV TAR_OPTIONS="--no-same-owner --no-same-permissions"

# Setup Android Command Line Tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && cd ${ANDROID_HOME}/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip \
    && unzip -q cmdline-tools.zip \
    && mv cmdline-tools latest \
    && rm cmdline-tools.zip

# Accept Android licenses and install SDK tools
RUN yes | sdkmanager --licenses || true \
    && sdkmanager "build-tools;36.0.0" "platforms;android-36" "platform-tools"

# Setup Flutter
RUN mkdir -p ${FLUTTER_HOME} \
    && cd ${FLUTTER_HOME} \
    && git clone -b stable https://github.com/flutter/flutter.git \
    && flutter config --android-sdk "${ANDROID_HOME}" \
    && flutter precache