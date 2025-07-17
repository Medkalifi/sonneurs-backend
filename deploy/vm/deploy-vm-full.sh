#!/bin/bash
set -e

# Paramètres
PROJECT_ID="$1"
ZONE="$2"
VM_NAME="$3"
USER_NAME="$4"
GCS_BUCKET="$5"
DB_PASSWORD="$6"

APP_JAR="app.jar"
APP_PATH="/home/$USER_NAME/app"
SERVICE_NAME="sonneurs.service"
JAR_GCS_PATH="gs://$GCS_BUCKET/jars/$APP_JAR"

echo ">>> [1] Création de la VM si elle n'existe pas..."
gcloud compute instances list --filter="name=($VM_NAME)" --project="$PROJECT_ID" | grep "$VM_NAME" || \
gcloud compute instances create "$VM_NAME" \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-size=10GB \
  --tags=http-server \
  --metadata=enable-osconfig=TRUE \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --quiet

echo ">>> [2] Attente que la VM soit prête..."
sleep 30

echo ">>> [3] Préparation de la VM..."
gcloud compute ssh "$USER_NAME@$VM_NAME" --zone="$ZONE" --command "
  mkdir -p $APP_PATH && sudo chown $USER_NAME:$USER_NAME $APP_PATH
"

echo ">>> [4] Copie des fichiers"
gcloud compute scp deploy/vm/start.sh "$USER_NAME@$VM_NAME:$APP_PATH" --zone="$ZONE"

cat <<EOF > "$SERVICE_NAME"
[Unit]
Description=Sonneurs Spring Boot App
After=network.target

[Service]
User=$USER_NAME
WorkingDirectory=$APP_PATH
ExecStart=/bin/bash $APP_PATH/start.sh $DB_PASSWORD
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

gcloud compute scp "$SERVICE_NAME" "$USER_NAME@$VM_NAME:/tmp/$SERVICE_NAME" --zone="$ZONE"

echo ">>> [5] Configuration systemd + téléchargement du JAR"

echo "#######################################################
echo "GCS_BUCKET=$GCS_BUCKET"
echo "JAR_GCS_PATH=$JAR_GCS_PATH"
echo "#######################################################

gcloud compute ssh "$USER_NAME@$VM_NAME" --zone="$ZONE" --command '
  echo ">>> [VM] Installation de Java (OpenJDK 17)"  
  sudo apt update -y &&
  sudo apt install -y openjdk-17-jdk &&
  sudo mv /tmp/'"$SERVICE_NAME"' /etc/systemd/system/'"$SERVICE_NAME"' &&
  sudo chmod 644 /etc/systemd/system/'"$SERVICE_NAME"' &&
  gsutil cp '"$JAR_GCS_PATH"' '"$APP_PATH/$APP_JAR"' &&
  chmod +x '"$APP_PATH"'/start.sh &&
  sudo systemctl daemon-reload &&
  sudo systemctl enable '"$SERVICE_NAME"' &&
  sudo systemctl restart '"$SERVICE_NAME"'
'


rm "$SERVICE_NAME"
echo ">>> ✅ Déploiement terminé avec succès"
