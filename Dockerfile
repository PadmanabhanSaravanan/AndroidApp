# Use the official Gradle image as the base image
FROM gradle:7.6.0-jdk11 AS build

# Set the working directory
WORKDIR /app

# Copy Gradle wrapper and build scripts
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle /app/

# Grant execute permissions to the Gradle wrapper
RUN chmod +x gradlew

# Download Gradle dependencies
RUN ./gradlew --no-daemon dependencies

# Copy the complete source code
COPY . .

# Build the application
RUN ./gradlew build -x test --no-daemon

# Second stage to copy the APK (Multi-stage build)
FROM openjdk:11-jre-slim AS release

# Set the working directory
WORKDIR /release

# Copy the built APK from the previous stage
COPY --from=build /app/app/build/outputs/apk/ ./apk/

# Display APKs in the output directory
RUN ls -R ./apk/

# This image does nothing when run
CMD echo "APK build complete. Find APKs in the ./apk directory."
