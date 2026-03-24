import { sleep } from "k6";
import { post, patch } from "../../shared/http-client.js";
import {
  buildReadFilter,
  buildCreateRoomRequest,
  buildUpdateRoomRequest,
} from "../../shared/payloads.js";

const MAX_SEED_ROOM_NO = Number(__ENV.MAX_SEED_ROOM_NO || 10000);
const SOAK_DURATION = __ENV.SOAK_DURATION || "60m";

/*
 * Soak Test — 장시간 부하로 DB 안정성 검증
 *
 * 목적:
 *   - PostgreSQL: dead tuple 축적 → autovacuum 발동 → 성능 변동 관찰
 *   - MySQL: undo log 비대화 → purge 지연 → 성능 변동 관찰
 *   - 두 DB 모두: connection pool 안정성, 메모리 누수 여부
 *
 * 구조:
 *   5분 ramp-up → 일정 부하 유지(기본 60분) → 5분 ramp-down
 *   Mixed 비율: Read 80% / Update 15% / Insert 5%
 *
 * 실행:
 *   SOAK_DURATION=60m bash scripts/run-api-bench.sh mysql soak-test 1
 */
export const options = {
  scenarios: {
    read: {
      executor: "ramping-arrival-rate",
      startRate: 0,
      stages: [
        { target: 32, duration: "5m" },   // ramp-up
        { target: 32, duration: SOAK_DURATION }, // sustained
        { target: 0, duration: "5m" },    // ramp-down
      ],
      preAllocatedVUs: 20,
      maxVUs: 100,
      exec: "readOp",
    },
    update: {
      executor: "ramping-arrival-rate",
      startRate: 0,
      stages: [
        { target: 6, duration: "5m" },
        { target: 6, duration: SOAK_DURATION },
        { target: 0, duration: "5m" },
      ],
      preAllocatedVUs: 6,
      maxVUs: 30,
      exec: "updateOp",
    },
    insert: {
      executor: "ramping-arrival-rate",
      startRate: 0,
      stages: [
        { target: 2, duration: "5m" },
        { target: 2, duration: SOAK_DURATION },
        { target: 0, duration: "5m" },
      ],
      preAllocatedVUs: 2,
      maxVUs: 10,
      exec: "insertOp",
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.01"],
    "http_req_duration":           ["p(50)<300", "p(90)<500", "p(95)<700", "p(99)<1500"],
    "http_req_duration{scenario:read}":   ["p(95)<700", "p(99)<1200"],
    "http_req_duration{scenario:update}": ["p(95)<900", "p(99)<1500"],
    "http_req_duration{scenario:insert}": ["p(95)<1200", "p(99)<2000"],
  },
};

export function readOp() {
  const seed = __ITER + (__VU * 997);
  const filter = buildReadFilter(seed, seed % 2 === 0 ? "LATEST" : "REMAINING");
  const page = seed % 20;

  post(`/rdb/select?page=${page}&size=50`, filter);
  sleep(0.1);
}

export function updateOp() {
  const seed = __ITER + (__VU * 991);
  const roomNo = 1 + (seed % MAX_SEED_ROOM_NO);
  const payload = buildUpdateRoomRequest(seed);

  patch(`/rdb/update?roomNo=${roomNo}`, payload);
  sleep(0.1);
}

export function insertOp() {
  const seed = __ITER + (__VU * 983);
  const payload = buildCreateRoomRequest(seed);

  post("/rdb/insert", payload);
  sleep(0.1);
}
