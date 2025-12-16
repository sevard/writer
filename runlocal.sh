#!/usr/bin/env bash

runner="${1:?Error: please specify a runner (e.g., local, docker)}"

echo "Running with: $runner"

case "$runner" in
  local)
    echo "Starting Django development server..."
    export DEBUG=True
    export SECRET_KEY="test-secret-key-change-this"
    export ALLOWED_HOSTS="localhost,127.0.0.1"
    # python3 manage.py migrate
    python3 manage.py runserver
    ;;
  docker)
    echo "Building and running Docker container..."

    # sudo usermod -aG docker $USER
    # newgrp docker
    # Log out and back in, or restart terminal

    docker build -t writer:local .
    docker run \
      -e DEBUG=False \
      -e SECRET_KEY="test-secret-key-12345" \
      -e ALLOWED_HOSTS="localhost,127.0.0.1" \
      -p 8080:8080 \
      writer:local
    ;;
  *)
    echo "Error: Unknown runner '$runner'"
    echo "Available runners: local, docker"
    exit 1
    ;;
esac