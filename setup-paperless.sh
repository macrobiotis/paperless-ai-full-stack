#!/bin/bash
set -e

# nc installieren
if ! command -v nc >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*
fi

cd /usr/src/paperless/src

# Permissions
chown -R paperless:paperless /usr/src/paperless
chmod -R 755 /usr/src/paperless/{consume,media,data,export}

# Warte DB/Redis
echo "Waiting for PostgreSQL..."
timeout 60 bash -c 'until nc -z localhost 5432; do sleep 2; done' || exit 1
echo "PostgreSQL ready."

echo "Waiting for Redis..."
timeout 60 bash -c 'until nc -z localhost 6379; do sleep 2; done' || exit 1
echo "Redis ready."

# Setup
python3 manage.py migrate --noinput
python3 manage.py collectstatic --noinput || true

# Superuser
python3 manage.py shell <<EOF || true
from django.contrib.auth import get_user_model
User = get_user_model()
username = '${PAPERLESS_USERNAME:-admin}'
email = '${PAPERLESS_EMAIL:-admin@example.com}'
password = '${PAPERLESS_PASSWORD:-admin}'
if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username, email, password)
EOF

# env
export PAPERLESS_CONSUMPTION_DIR='/usr/src/paperless/consume'
export PAPERLESS_MEDIA_ROOT='/usr/src/paperless/media'
export PAPERLESS_TASK_WORKER_NUM_THREADS=2
export PAPERLESS_WEBSERVER_WORKERS=2

# paperless-ngx starts granian
echo "Setup complete. Starting Paperless webserver..."
exec "$@"
