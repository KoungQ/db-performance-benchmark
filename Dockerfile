FROM gradle:8.10.2-jdk17 AS builder

WORKDIR /app

COPY gradlew ./
COPY gradle gradle
COPY build.gradle settings.gradle* ./
COPY src src

RUN chmod +x ./gradlew && ./gradlew bootJar --no-daemon

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8090

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS:-} -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:-bench-mysql} -jar /app/app.jar"]
