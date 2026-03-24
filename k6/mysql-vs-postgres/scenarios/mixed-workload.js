import { sleep } from "k6";
import { post, patch } from "../../shared/http-client.js";
import {
  buildReadFilter,
  buildCreateRoomRequest,
  buildUpdateRoomRequest,
} from "../../shared/payloads.js";

const MAX_SEED_ROOM_NO = Number(__ENV.MAX_SEED_ROOM_NO || 10000);

/*
 * Mixed Workload — 실제 서비스 트래픽 비율 시뮬레이션
 *
 *   Read   80%  (검색이 압도적으로 많은 서비스 특성)
 *   Update 15%  (체크리스트 수정)
 *   Insert  5%  (신규 방 생성)
 *
 * 모든 요청이 동시에 섞여 들어오므로
 * lock contention, buffer pool 경쟁, 인덱스 갱신이 읽기에 미치는 영향을 관찰할 수 있다.
 */
export const options = {
  scenarios: {
    read: {
      executor: "constant-arrival-rate",
      rate: 32,                // 전체 40 rps 중 80%
      timeUnit: "1s",
      duration: "15m",
      preAllocatedVUs: 16,
      maxVUs: 80,
      exec: "readOp",
    },
    update: {
      executor: "constant-arrival-rate",
      rate: 6,                 // 전체 40 rps 중 15%
      timeUnit: "1s",
      duration: "15m",
      preAllocatedVUs: 6,
      maxVUs: 30,
      exec: "updateOp",
    },
    insert: {
      executor: "constant-arrival-rate",
      rate: 2,                 // 전체 40 rps 중 5%
      timeUnit: "1s",
      duration: "15m",
      preAllocatedVUs: 2,
      maxVUs: 10,
      exec: "insertOp",
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.01"],
    "http_req_duration":           ["p(50)<300", "p(90)<500", "p(95)<700", "p(99)<1200"],
    "http_req_duration{scenario:read}":   ["p(95)<700"],
    "http_req_duration{scenario:update}": ["p(95)<900"],
    "http_req_duration{scenario:insert}": ["p(95)<1200"],
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
