# Stage 1: Build the application using Gradle
FROM gradle:7.6.0-jdk11 AS build
WORKDIR /home/gradle/project
COPY --chown=gradle:gradle . .

# Build the application
RUN gradle build --no-daemon

# Stage 2: Create a lightweight image for running the application
FROM openjdk:11-jre-slim
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /home/gradle/project/build/libs/*.jar app.jar

# Expose the port your application runs on
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
