#!/usr/bin/env bash
# Usage: run-engine-bench.sh [mysql|postgres|all|parallel]
#   mysql    - MySQL만 실행
#   postgres - PostgreSQL만 실행
#   all      - 둘 다 순차 실행 (MySQL → PostgreSQL)
#   parallel - 둘 다 동시 실행 (같은 시간대 비교용)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RESULT_DIR="${ROOT_DIR}/benchmarks/engine/mysql-vs-postgres/results"
MYSQL_SCRIPT="${ROOT_DIR}/benchmarks/engine/mysql-vs-postgres/scripts/run-sysbench-mysql.sh"
POSTGRES_SCRIPT="${ROOT_DIR}/benchmarks/engine/mysql-vs-postgres/scripts/run-pgbench-postgres.sh"

TARGET="${1:-all}"
RUN_ID="${RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3307}"
MYSQL_USER="${MYSQL_USER:-benchmark}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-benchmark}"
MYSQL_DB="${MYSQL_DB:-db_benchmark}"
POSTGRES_HOST="${POSTGRES_HOST:-127.0.0.1}"
POSTGRES_PORT="${POSTGRES_PORT:-5433}"
POSTGRES_USER="${POSTGRES_USER:-benchmark}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-benchmark}"
POSTGRES_DB="${POSTGRES_DB:-db_benchmark}"

usage() {
  cat <<'EOF'
Usage: bash scripts/run-engine-bench.sh [mysql|postgres|all|parallel]

  mysql    Run only MySQL sysbench scenarios
  postgres Run only PostgreSQL pgbench scenarios
  all      Run MySQL first, then PostgreSQL
  parallel Run both at the same time for Grafana observation

Defaults:
  TIME_SECONDS=300
  WINDOW_SECONDS=5
  SCENARIOS="room-checklist-read room-checklist-insert room-checklist-update"
EOF
}

check_port() {
  local host="$1"
  local port="$2"
  local name="$3"
  if ! nc -z "${host}" "${port}" >/dev/null 2>&1; then
    echo "Error: ${name} is not reachable at ${host}:${port}"
    exit 1
  fi
}

check_mysql_seed() {
  local room_count
  local checklist_count

  room_count="$(MYSQL_PWD="${MYSQL_PASSWORD}" mysql \
    --host="${MYSQL_HOST}" \
    --port="${MYSQL_PORT}" \
    --user="${MYSQL_USER}" \
    --database="${MYSQL_DB}" \
    --batch --skip-column-names \
    -e "SELECT COUNT(*) FROM room;" 2>/dev/null || true)"
  checklist_count="$(MYSQL_PWD="${MYSQL_PASSWORD}" mysql \
    --host="${MYSQL_HOST}" \
    --port="${MYSQL_PORT}" \
    --user="${MYSQL_USER}" \
    --database="${MYSQL_DB}" \
    --batch --skip-column-names \
    -e "SELECT COUNT(*) FROM checklist;" 2>/dev/null || true)"

  if [[ -z "${room_count}" || -z "${checklist_count}" ]]; then
    echo "Error: failed to query MySQL benchmark seed counts"
    exit 1
  fi

  if (( room_count < 10000 || checklist_count < 10000 )); then
    echo "Error: MySQL seed data is incomplete (room=${room_count}, checklist=${checklist_count})"
    exit 1
  fi
}

check_postgres_seed() {
  local room_count
  local checklist_count

  room_count="$(PGPASSWORD="${POSTGRES_PASSWORD}" psql \
    "postgresql://${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}" \
    -tAqc "SELECT COUNT(*) FROM room;" 2>/dev/null || true)"
  checklist_count="$(PGPASSWORD="${POSTGRES_PASSWORD}" psql \
    "postgresql://${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}" \
    -tAqc "SELECT COUNT(*) FROM checklist;" 2>/dev/null || true)"

  if [[ -z "${room_count}" || -z "${checklist_count}" ]]; then
    echo "Error: failed to query PostgreSQL benchmark seed counts"
    exit 1
  fi

  if (( room_count < 10000 || checklist_count < 10000 )); then
    echo "Error: PostgreSQL seed data is incomplete (room=${room_count}, checklist=${checklist_count})"
    exit 1
  fi
}

sync_postgres_sequences() {
  PGPASSWORD="${POSTGRES_PASSWORD}" psql \
    "postgresql://${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}" \
    -v ON_ERROR_STOP=1 \
    -tAqc "
      SELECT setval(pg_get_serial_sequence('room', 'room_no'), COALESCE((SELECT MAX(room_no) FROM room), 1), true);
      SELECT setval(pg_get_serial_sequence('checklist', 'checklist_no'), COALESCE((SELECT MAX(checklist_no) FROM checklist), 1), true);
    " >/dev/null
}

validate_target() {
  case "${TARGET}" in
    mysql|postgres|all|parallel)
      ;;
    *)
      echo "Error: unsupported target '${TARGET}'"
      echo ""
      usage
      exit 1
      ;;
  esac
}

run_parallel() {
  local mysql_exit=0
  local pg_exit=0

  echo "[Parallel] MySQL + PostgreSQL 동시 실행"
  echo "Use this mode for same-window observation in Grafana, not headline comparison."
  echo ""

  RUN_ID="${RUN_ID}" bash "${MYSQL_SCRIPT}" "${RESULT_DIR}/mysql" &
  MYSQL_PID=$!
  RUN_ID="${RUN_ID}" bash "${POSTGRES_SCRIPT}" "${RESULT_DIR}/postgres" &
  PG_PID=$!

  set +e
  wait "${MYSQL_PID}"
  mysql_exit=$?
  wait "${PG_PID}"
  pg_exit=$?
  set -e

  if [[ ${mysql_exit} -ne 0 || ${pg_exit} -ne 0 ]]; then
    echo "Engine benchmark failed in parallel mode (mysql=${mysql_exit}, postgres=${pg_exit})"
    [[ ${mysql_exit} -ne 0 ]] && exit "${mysql_exit}"
    exit "${pg_exit}"
  fi
}

echo "=== MySQL vs PostgreSQL Engine Benchmark (sysbench / pgbench) ==="
echo "Target: ${TARGET}"
echo "Run ID: ${RUN_ID}"
echo ""

validate_target

if [[ "${TARGET}" == "mysql" || "${TARGET}" == "all" || "${TARGET}" == "parallel" ]]; then
  command -v sysbench >/dev/null 2>&1 || { echo "Error: sysbench not found. brew install sysbench"; exit 1; }
  command -v mysql >/dev/null 2>&1 || { echo "Error: mysql client not found. brew install mysql-client"; exit 1; }
fi
if [[ "${TARGET}" == "postgres" || "${TARGET}" == "all" || "${TARGET}" == "parallel" ]]; then
  command -v pgbench >/dev/null 2>&1 || { echo "Error: pgbench not found. brew install postgresql@16"; exit 1; }
  command -v psql >/dev/null 2>&1 || { echo "Error: psql not found. brew install postgresql@16"; exit 1; }
fi
command -v nc >/dev/null 2>&1 || { echo "Error: nc not found."; exit 1; }

echo "Checking benchmark prerequisites..."
if [[ "${TARGET}" == "mysql" || "${TARGET}" == "all" || "${TARGET}" == "parallel" ]]; then
  check_port "${MYSQL_HOST}" "${MYSQL_PORT}" "MySQL"
  check_mysql_seed
  echo "  MySQL ready at ${MYSQL_HOST}:${MYSQL_PORT} with seeded room/checklist tables"
fi
if [[ "${TARGET}" == "postgres" || "${TARGET}" == "all" || "${TARGET}" == "parallel" ]]; then
  check_port "${POSTGRES_HOST}" "${POSTGRES_PORT}" "PostgreSQL"
  check_postgres_seed
  sync_postgres_sequences
  echo "  PostgreSQL ready at ${POSTGRES_HOST}:${POSTGRES_PORT} with seeded room/checklist tables"
fi
echo ""

case "${TARGET}" in
  parallel)
    run_parallel
    ;;
  mysql)
    echo "[MySQL] Running sysbench room-checklist scenarios..."
    RUN_ID="${RUN_ID}" bash "${MYSQL_SCRIPT}" "${RESULT_DIR}/mysql"
    ;;
  postgres)
    echo "[PostgreSQL] Running pgbench room-checklist scenarios..."
    RUN_ID="${RUN_ID}" bash "${POSTGRES_SCRIPT}" "${RESULT_DIR}/postgres"
    ;;
  all)
    echo "[MySQL] Running sysbench room-checklist scenarios..."
    RUN_ID="${RUN_ID}" bash "${MYSQL_SCRIPT}" "${RESULT_DIR}/mysql"
    echo ""
    echo "[PostgreSQL] Running pgbench room-checklist scenarios..."
    RUN_ID="${RUN_ID}" bash "${POSTGRES_SCRIPT}" "${RESULT_DIR}/postgres"
    ;;
esac

echo ""
echo "Engine benchmark complete. Results in ${RESULT_DIR}"
