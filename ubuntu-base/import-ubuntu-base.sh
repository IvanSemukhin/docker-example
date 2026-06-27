#!/usr/bin/env bash
set -euo pipefail
####################################Settings####################################
ARCHIVE_URL="https://mirror.yandex.ru/ubuntu-cdimage/ubuntu-base/releases/26.04/release/ubuntu-base-26.04-base-amd64.tar.gz"
ARCHIVE_FILE="ubuntu-base-26.04-base-amd64.tar.gz"
EXPECTED_SHA256="046fcabb7f16f45a80ae11824664f2a07e01386c6fb1ed9dc1e225a66a6553a2"
DOCKER_IMAGE_NAME="base-26.04"
DOCKER_TAG="2026-04-20"
################################################################################
#Check docker command
if ! command -v docker &> /dev/null; then
  echo "docker command not found. Try install docker." >&2
  if ! sudo apt -y install docker.io docker-buildx docker-clean docker-doc docker-compose-v2; then
    echo "install docker ERR" >&2
    exit 1
  fi
  if ! sudo usermod -aG docker "$USER"; then
    echo "add user to docker group ERR" >&2
    exit 1
  fi
  echo "install docker OK. add user to docker group OK. System will reboot in 5 seconds. Press Ctrl+C to cancel..."
  sleep 5 && sudo shutdown -r now
  exit 0
fi
#Download
if [[ ! -f "$ARCHIVE_FILE" ]]; then
  if ! wget -q -O "$ARCHIVE_FILE" "$ARCHIVE_URL"; then
    echo "Download ERR" >&2
    exit 1
  fi
fi
#Check archive
ACTUAL_SHA256=$(sha256sum "$ARCHIVE_FILE" | awk '{print $1}')
if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
  echo "Check sum ERR" >&2
  echo "Expect: $EXPECTED_SHA256" >&2
  echo "Actual: $ACTUAL_SHA256" >&2
  rm -f "$ARCHIVE_FILE"
  exit 1
fi
# Check if Docker image already exists
if docker image inspect "${DOCKER_IMAGE_NAME}:${DOCKER_TAG}" &> /dev/null; then
  echo "Docker image ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} already exists. Skipping import." >&2
  echo "If you want to rebuild, remove it first: docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
  exit 0
fi
#Import
if ! docker import "$ARCHIVE_FILE" "${DOCKER_IMAGE_NAME}:${DOCKER_TAG}" &> /dev/null; then
  echo "Docker import ERR" >&2
  exit 1
fi
