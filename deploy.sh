#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="${PROJECT_NAME:-pygmy}"
ACTION="${1:-deploy}"

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
else
  echo "Error: docker compose (or docker-compose) is not installed."
  exit 1
fi

COMPOSE_FILE="${COMPOSE_FILE:-${SCRIPT_DIR}/docker-compose.yml}"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "Error: compose file not found at ${COMPOSE_FILE}"
  exit 1
fi

run_compose() {
  "${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" "$@"
}

print_usage() {
  cat <<EOF
Usage: ./deploy.sh [action]

Actions:
  deploy   Build images and start services in detached mode (default)
  down     Stop and remove services
  restart  Restart all services
  logs     Follow service logs
  status   Show service status

Optional environment variables:
  PROJECT_NAME   Compose project name (default: pygmy)
  COMPOSE_FILE   Path to compose file (default: ./docker-compose.yml)
EOF
}

check_docker_running() {
  if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running."
    exit 1
  fi
}

case "${ACTION}" in
  deploy)
    check_docker_running
    echo "Deploying ${PROJECT_NAME} using ${COMPOSE_FILE}..."
    run_compose pull || true
    run_compose up -d --build
    echo "Deployment complete."
    run_compose ps
    ;;
  down)
    check_docker_running
    echo "Stopping ${PROJECT_NAME}..."
    run_compose down
    ;;
  restart)
    check_docker_running
    echo "Restarting ${PROJECT_NAME}..."
    run_compose down
    run_compose up -d --build
    run_compose ps
    ;;
  logs)
    check_docker_running
    run_compose logs -f --tail=200
    ;;
  status)
    check_docker_running
    run_compose ps
    ;;
  -h|--help|help)
    print_usage
    ;;
  *)
    echo "Error: unknown action '${ACTION}'"
    print_usage
    exit 1
    ;;
esac
