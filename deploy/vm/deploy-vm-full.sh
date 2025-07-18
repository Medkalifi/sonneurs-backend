#!/bin/bash
set -e

# Paramètres
PROJECT_ID="$1"
ZONE="$2"
VM_NAME="$3"
USER_NAME="$4"
GCS_BUCKET="$5"
DB_PASSWORD="$6"

# Variables d'application
APP_JAR="app.jar"
APP_PATH="/home/$USER_NAME/app"
SERVICE_NAME="sonneurs.service"
JAR_GCS_PATH="gs://$GCS_BUCKET/jars/$APP_JAR"

# Ces variables doivent être exportées dans le workflow GitHub Actions
DB_NAME="${DB_NAME:-sonneursdb}"
DB_USERNAME="${DB_USERNAME:-svc-app-son-user}"
INSTANCE_CONNECTION_NAME="${INSTANCE_CONNECTION_NAME:-sonneurs-juvi-dev:us-central1:instance-postgres}"

echo ">>> [1] Création de la VM si elle n'existe pas..."
if ! gcloud compute instances list --project="$PROJECT_ID" --filter="name=($VM_NAME)" --format="value(name)" | grep -q "$VM_NAME"; then
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
  echo ">>> [Info] VM $VM_NAME existe déjà, pas de création."
fi

echo ">>> [2] Attente que la VM soit prête..."
sleep 20

echo ">>> [3] Préparation de la VM..."
gcloud compute ssh "$USER_NAME@$VM_NAME" --zone="$ZONE" --command "
  sudo mkdir -p $APP_PATH &&
  sudo chown $USER_NAME:$USER_NAME $APP_PATH
"

echo ">>> [4] Génération de start.sh avec variables injectées"
cat <<EOF > deploy/vm/start.sh
#!/bin/bash
export DB_USERNAME="$DB_USERNAME"
export DB_PASSWORD="$DB_PASSWORD"
export DB_NAME="$DB_NAME"
export INSTANCE_CONNECTION_NAME="$INSTANCE_CONNECTION_NAME"
export PORT=8080

cd $APP_PATH
java -jar $APP_JAR
EOF

chmod +x deploy/vm/start.sh

gcloud compute scp deploy/vm/start.sh "$USER_NAME@$VM_NAME:$APP_PATH" --zone="$ZONE"

echo ">>> [5] Configuration systemd"
cat <<EOF > "$SERVICE_NAME"
[Unit]
Description=Sonneurs Spring Boot App
After=network.target

[Service]
User=$USER_NAME
WorkingDirectory=$APP_PATH
ExecStart=/bin/bash $APP_PATH/start.sh
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

gcloud compute scp "$SERVICE_NAME" "$USER_NAME@$VM_NAME:/tmp/$SERVICE_NAME" --zone="$ZONE"

echo ">>> [6] Installation Java + configuration complète sur la VM"
gcloud compute ssh "$USER_NAME@$VM_NAME" --zone="$ZONE" --command '
  echo ">>> [VM] Installation de Java et Nginx"
  sudo apt update -y &&
  sudo apt install -y openjdk-17-jdk nginx &&

  echo ">>> [VM] Configuration Nginx reverse proxy"
  sudo tee /etc/nginx/sites-available/default > /dev/null <<EONGINX
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EONGINX

  sudo nginx -t &&
  sudo systemctl restart nginx &&

  echo ">>> [VM] Déploiement app JAR"
  sudo mv /tmp/'"$SERVICE_NAME"' /etc/systemd/system/'"$SERVICE_NAME"' &&
  sudo chmod 644 /etc/systemd/system/'"$SERVICE_NAME"' &&

  gsutil cp '"$JAR_GCS_PATH"' '"$APP_PATH/$APP_JAR"' &&
  sudo systemctl daemon-reload &&
  sudo systemctl enable '"$SERVICE_NAME"' &&
  sudo systemctl restart '"$SERVICE_NAME"'
'

rm "$SERVICE_NAME"
echo ">>> ✅ Déploiement terminé avec succès"
