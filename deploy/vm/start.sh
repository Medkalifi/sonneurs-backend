#!/bin/bash

APP_JAR="app.jar"
DB_PASSWORD="$1"

echo ">>> Lancement de l’application Java..."
exec java -jar "$APP_JAR" --spring.datasource.password="$DB_PASSWORD"