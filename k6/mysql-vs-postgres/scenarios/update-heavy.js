import { sleep } from "k6";
import { patch } from "../../shared/http-client.js";
import { buildUpdateRoomRequest } from "../../shared/payloads.js";

const MAX_SEED_ROOM_NO = Number(__ENV.MAX_SEED_ROOM_NO || 10000);

export const options = {
  scenarios: {
    updateHeavy: {
      executor: "constant-vus",
      vus: 20,
      duration: "15m",
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.02"],
    http_req_duration: ["p(50)<200", "p(90)<600", "p(95)<900", "p(99)<1500"],
  },
};

export default function () {
  const seed = __ITER + (__VU * 991);
  const roomNo = 1 + (seed % MAX_SEED_ROOM_NO);
  const payload = buildUpdateRoomRequest(seed);

  patch(`/rdb/update?roomNo=${roomNo}`, payload);
  sleep(0.2);
}
