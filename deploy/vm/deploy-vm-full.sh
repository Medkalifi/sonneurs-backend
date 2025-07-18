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
if ! gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --project="$PROJECT_ID" &> /dev/null; then
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
else
  echo ">>> VM $VM_NAME déjà existante, on ne la recrée pas."
fi

echo ">>> [2] Attente que la VM soit prête..."
sleep 20

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

echo ">>> [5] Configuration systemd, Java, Nginx + téléchargement du JAR"
gcloud compute ssh "$USER_NAME@$VM_NAME" --zone="$ZONE" --command '
  echo ">>> [VM] Installation de Java + Nginx"  
  sudo apt update -y &&
  sudo apt install -y openjdk-17-jdk nginx &&

  echo ">>> Configuration Nginx"
  echo "server {
    listen 80;
    server_name _;

    location / {
      proxy_pass http://localhost:8080;
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
    }
  }" | sudo tee /etc/nginx/sites-available/sonneurs > /dev/null &&
  sudo ln -sf /etc/nginx/sites-available/sonneurs /etc/nginx/sites-enabled/sonneurs &&
  sudo nginx -t &&
  sudo systemctl restart nginx &&

  echo ">>> Configuration systemd"
  
          echo "GCP_PROJECT=$GCP_PROJECT" 
          echo "REGION=$REGION" 
          echo "GCS_BUCKET=$GCS_BUCKET" 
          echo "DOCKER_IMAGE=$DOCKER_IMAGE" 
          echo "DB_NAME=$DB_NAME" 
          echo "DB_USERNAME=$DB_USERNAME"
          echo "INSTANCE_CONNECTION_NAME=$INSTANCE_CONNECTION_NAME" 
          echo "VM_NAME=$VM_NAME" 
          echo "VM_USER=$VM_USER" 
          echo "VM_APP_PATH=$VM_APP_PATH" 
  
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