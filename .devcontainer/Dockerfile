FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEVCONTAINER="true"

# setup android sdk
RUN apt clean && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install adb clang cmake git ninja-build pkg-config libglu1-mesa libgtk-3-dev xz-utils unzip zip \
    && apt-get clean -y

USER vscode

RUN export HOME="/home/vscode"
ARG HOME="/home/vscode"
ENV FLUTTER_HOME="${HOME}/.local/flutter"
ENV ANDROID_HOME=/home/vscode/.local
ENV ANDROID_SDK_ROOT=/home/vscode/.local
ENV CMDLINE_HOME="${HOME}/.local/cmdline-tools"
ENV CMDLINE="${HOME}/.local/cmdline-tools/cmdline-tools/bin"

# setup flutter sdk
ENV PATH=${PATH}:${FLUTTER_HOME}/flutter/bin:${CMDLINE}


# setup command line tools
RUN ls -la ~ && whoami && sudo mkdir -pv ${CMDLINE_HOME} && cd ${CMDLINE_HOME} \
    && sudo wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip \
    && sudo unzip commandlinetools-linux-8512546_latest.zip \
    && sudo rm commandlinetools-linux-8512546_latest.zip

RUN ls -la ${HOME}/ && ls -la ${CMDLINE_HOME} && echo ${CMDLINE_HOME} && sudo chown -Rv vscode:vscode ${HOME}/.local
RUN sudo chmod +r+w+x -Rv ${HOME}/.local

# Install cmdlinetools and sdk
RUN sudo apt-get install openjdk-21-jdk --no-install-recommends -y
RUN yes | sdkmanager --install "build-tools;36.0.0" "platforms;android-36" "platform-tools" "cmdline-tools;latest"

# setup flutter
RUN mkdir -pv ${FLUTTER_HOME} \
    && cd ${FLUTTER_HOME} \
    && git clone -b master https://github.com/flutter/flutter \
    && flutter precache

RUN flutter config --android-sdk "/home/vscode/.local"
RUN yes | flutter doctor --android-licenses

# Cleanup
RUN sudo apt-get clean -y && sudo rm -rf /var/lib/apt/lists/*

# # FROM docker.io/library/ubuntu:24.04
# # FROM mcr.microsoft.com/devcontainers/base:ubuntu
# FROM Ubuntu:24.04

# ENV DEVCONTAINER="true"

# USER vscode

# RUN sudo apt-get update -y && sudo apt-get upgrade -y
# RUN sudo apt-get install -y curl git clang ninja-build pkg-config unzip xz-utils zip libglu1-mesa wget libgtk-3-dev adb

# RUN export HOME="/home/vscode"
# ARG HOME="/home/vscode"
# ENV FLUTTER_HOME="${HOME}/.local/flutter"
# ENV ANDROID_HOME=/home/vscode/.local
# ENV ANDROID_SDK_ROOT=/home/vscode/.local
# ENV CMDLINE_HOME="${HOME}/.local/cmdline-tools"
# ENV CMDLINE="${HOME}/.local/cmdline-tools/cmdline-tools/bin"

# # setup flutter sdk
# ENV PATH=${PATH}:${FLUTTER_HOME}/flutter/bin:${CMDLINE}

# # Prevent tar ownership extraction errors during flutter precache
# # ENV TAR_OPTIONS="--no-same-owner --no-same-permissions"

# # setup command line tools
# # RUN mkdir -pv ${CMDLINE_HOME} && cd ${CMDLINE_HOME} \
# #     && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip \
# #     && unzip commandlinetools-linux-8512546_latest.zip \
# #     && rm commandlinetools-linux-8512546_latest.zip

# # RUN apt-get install openjdk-21-jdk --no-install-recommends -y
# # RUN yes | sdkmanager --install "build-tools;36.0.0" "platforms;android-36" "platform-tools" "cmdline-tools;latest"

# # setup flutter
# RUN mkdir -pv ${FLUTTER_HOME} \
#     && cd ${FLUTTER_HOME} \
#     && git clone -b stable https://github.com/flutter/flutter \
#     && flutter precache

# RUN flutter config --android-sdk "/home/vscode/.local"
# # RUN yes | flutter doctor --android-licenses