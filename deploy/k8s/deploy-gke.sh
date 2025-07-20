#!/bin/bash
set -e

#  Chargement des variables d'environnement (hors mot de passe)
if [[ -f .env.dev ]]; then
  echo " Chargement des variables depuis .env.dev"
  export $(grep -v '^#' .env.dev | xargs)
else
  echo "❌ Fichier .env.dev non trouvé"
  exit 1
fi

# 📌 Vérification du mot de passe fourni en variable d'environnement
: "${DB_PASSWORD:? La variable DB_PASSWORD doit être définie (export DB_PASSWORD=...)}"

# 📌 Récupération infos projet
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
GKE_NODE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo " Attribution du rôle Artifact Registry Reader à $GKE_NODE_SA"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$GKE_NODE_SA" \
  --role="roles/artifactregistry.reader" \
  --quiet

#  Suppression des ressources existantes
echo " Suppression ancienne configuration (si existante)..."
kubectl delete deployment springboot-app -n dev --ignore-not-found
kubectl delete service springboot-service -n dev --ignore-not-found
kubectl delete secret springboot-secret -n dev --ignore-not-found
kubectl delete secret springboot-service-account-key -n dev --ignore-not-found

#  Création des secrets Kubernetes
echo " Création du secret app (DB credentials + instance)"
kubectl create secret generic springboot-secret \
  --from-literal=DB_NAME="$DB_NAME" \
  --from-literal=DB_USERNAME="$DB_USERNAME" \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --from-literal=INSTANCE_CONNECTION_NAME="$INSTANCE_CONNECTION_NAME" \
  -n dev

echo " Clé de service pour Cloud SQL Proxy"
kubectl create secret generic springboot-service-account-key \
  --from-file=credentials.json="$GOOGLE_APPLICATION_CREDENTIALS" \
  -n dev

# 🚀 Déploiement
echo " Déploiement de l'application Spring Boot sur GKE..."
kubectl apply -f deploy/k8s/deployment.yaml -n dev
kubectl apply -f /deploy/k8s/service.yaml -n dev

echo "✅ Déploiement terminé !"
