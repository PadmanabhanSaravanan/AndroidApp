# Use a base image with JDK
FROM openjdk:11-jdk-slim

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget unzip tar git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV ANDROID_HOME /opt/android-sdk
ENV PATH $PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Download and install the Android SDK Command Line Tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && cd $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip -q commandlinetools-linux-8512546_latest.zip && \
    rm commandlinetools-linux-8512546_latest.zip && \
    mkdir -p $ANDROID_HOME/cmdline-tools/latest && \
    mv cmdline-tools/* latest/

# Accept licenses and install required Android SDK packages
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# Set the working directory
WORKDIR /app

# Copy Gradle files
COPY gradle gradle
COPY gradlew .
COPY build.gradle settings.gradle gradle.properties ./

# Grant execute permission for the Gradle wrapper
RUN chmod +x gradlew

# Copy the project files
COPY . .

# Build the project
RUN ./gradlew assembleDebug

# The resulting APK file will be located in app/build/outputs/apk/debug/
