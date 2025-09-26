# syntax=docker/dockerfile:1

# Build stage: use Gradle with JDK 17 to compile and package the app
FROM gradle:8.10.2-jdk17 AS build
WORKDIR /app
COPY . /app
# Remove host-specific Gradle JDK pin (if present) to avoid invalid path inside container
RUN if [ -f gradle.properties ]; then sed -i '/^org\\.gradle\\.java\\.home/d' gradle.properties; fi \
    && gradle -Dorg.gradle.java.home=/opt/java/openjdk clean bootJar --no-daemon

# Run stage: slim JRE image to run the fat JAR
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built jar from the build stage (fat jar under build/libs)
COPY --from=build /app/build/libs/*.jar /app/app.jar

# Basic JVM options (tune as needed)
ENV JAVA_OPTS="-Xms256m -Xmx512m"

EXPOSE 8080

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]


