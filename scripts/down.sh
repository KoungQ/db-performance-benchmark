#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "Stopping benchmark stack (sysbench/pgbench 실행 중이면 연결 끊김)..."
docker compose -f docker-compose.bench.yml --profile mongo down
echo "Benchmark stack stopped."
