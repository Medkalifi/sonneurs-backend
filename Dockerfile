# syntax=docker/dockerfile:1

FROM eclipse-temurin:17-jdk-alpine

# Ajout des bibliothèques nécessaires à la socket Cloud SQL
RUN apk add --no-cache libstdc++ curl

VOLUME /tmp

# ARG et COPY doivent être séparés pour éviter les erreurs de résolution du wildcard
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]