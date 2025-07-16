#!/bin/bash

set -e

# Paramètres passés en arguments
DB_PASSWORD="$1"

# Lecture des variables d'env (présumées exportées ou passées en arguments/env)
APP_JAR="app.jar"
JAR_GCS_PATH="gs://$GCS_BUCKET/jars/$APP_JAR"
JAR_PATH="$VM_APP_PATH/$APP_JAR"
LOG_FILE="$VM_APP_PATH/app.log"

echo ">>> [VM] Téléchargement du JAR depuis $JAR_GCS_PATH"
gsutil cp "$JAR_GCS_PATH" "$JAR_PATH"

echo ">>> [VM] Arrêt des instances Java existantes"
pkill -f "$APP_JAR" || true

echo ">>> [VM] Lancement de l’application"
nohup java -jar "$JAR_PATH" \
  --spring.datasource.password="$DB_PASSWORD" > "$LOG_FILE" 2>&1 &

echo ">>> [VM] Application déployée avec succès."