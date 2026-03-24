import { sleep } from "k6";
import { post } from "../../shared/http-client.js";
import { buildCreateRoomRequest } from "../../shared/payloads.js";

export const options = {
  scenarios: {
    writeHeavy: {
      executor: "constant-vus",
      vus: 30,
      duration: "15m",
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.02"],
    http_req_duration: ["p(50)<300", "p(90)<800", "p(95)<1200", "p(99)<2000"],
  },
};

export default function () {
  const seed = __ITER + (__VU * 997);
  const payload = buildCreateRoomRequest(seed);
  post("/rdb/insert", payload);
  sleep(0.1);
}
