#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ "${1:-}" == "mongo" ]]; then
  docker compose -f docker-compose.bench.yml --profile mongo up -d
  echo "Benchmark stack started with MongoDB track enabled."
else
  docker compose -f docker-compose.bench.yml up -d
  echo "RDB benchmark stack started."
fi

echo "MySQL app: http://127.0.0.1:8090"
echo "Postgres app: http://127.0.0.1:8091"
echo "Prometheus: http://127.0.0.1:9091"
echo "Pushgateway: http://127.0.0.1:19092"
echo "Grafana: http://127.0.0.1:3001"
echo "Wait for apps to finish schema/data initialization before running benchmarks."
