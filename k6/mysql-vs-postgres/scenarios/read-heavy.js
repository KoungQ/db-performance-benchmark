import { sleep } from "k6";
import { post } from "../../shared/http-client.js";
import { buildReadFilter } from "../../shared/payloads.js";

export const options = {
  scenarios: {
    readHeavy: {
      executor: "constant-arrival-rate",
      rate: 40,
      timeUnit: "1s",
      duration: "15m",
      preAllocatedVUs: 20,
      maxVUs: 120,
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<700"],
  },
};

export default function () {
  const seed = __ITER + (__VU * 997);
  const filter = buildReadFilter(seed, seed % 2 === 0 ? "LATEST" : "REMAINING");
  const page = seed % 20;

  post(`/rdb/select?page=${page}&size=50`, filter);
  sleep(0.2);
}
