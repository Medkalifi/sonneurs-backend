#!/bin/bash

set -euo pipefail

ENV_FILE="deploy/env.dev"
NAMESPACE="dev"
DEPLOYMENT_NAME="springboot-app"
SERVICE_NAME="springboot-service"
SECRET_NAME="springboot-secret"
SA_SECRET_NAME="springboot-service-account-key"
KEY_FILE="/tmp/gcp-key.json"

echo "📄 Lecture des variables d'environnement depuis $ENV_FILE..."
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Fichier $ENV_FILE introuvable."
  exit 1
fi

# Charge les variables du fichier
set -a
source "$ENV_FILE"
set +a

# S'assurer que DB_PASSWORD est présent
if [[ -z "${DB_PASSWORD:-}" ]]; then
  echo "❌ La variable DB_PASSWORD doit être fournie dans l'environnement."
  exit 1
fi

# Clé de service obligatoire pour créer le secret
if [[ ! -f "$KEY_FILE" ]]; then
  echo "❌ Fichier de clé de service GCP introuvable à $KEY_FILE"
  exit 1
fi

echo "🧹 Suppression des ressources Kubernetes existantes (si elles existent)..."
kubectl delete deployment $DEPLOYMENT_NAME -n $NAMESPACE --ignore-not-found
kubectl delete svc $SERVICE_NAME -n $NAMESPACE --ignore-not-found
kubectl delete secret $SECRET_NAME -n $NAMESPACE --ignore-not-found
kubectl delete secret $SA_SECRET_NAME -n $NAMESPACE --ignore-not-found

echo "🔐 Création des secrets Kubernetes..."
kubectl create secret generic $SECRET_NAME \
  --from-literal=DB_NAME="$DB_NAME" \
  --from-literal=DB_USERNAME="$DB_USERNAME" \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --from-literal=INSTANCE_CONNECTION_NAME="$INSTANCE_CONNECTION_NAME" \
  -n $NAMESPACE

kubectl create secret generic $SA_SECRET_NAME \
  --from-file=credentials.json="$KEY_FILE" \
  -n $NAMESPACE

echo "🚀 Déploiement des manifests Kubernetes..."
kubectl apply -f deploy/k8s/deployment.yml -n $NAMESPACE
kubectl apply -f deploy/k8s/service.yml -n $NAMESPACE

echo "✅ Déploiement terminé avec succès."
