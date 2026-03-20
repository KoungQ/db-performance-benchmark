import http from "k6/http";
import { check } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://127.0.0.1:8090";

const defaultParams = {
  headers: {
    "Content-Type": "application/json",
  },
};

function mergeParams(params) {
  return {
    ...defaultParams,
    ...params,
    headers: {
      ...defaultParams.headers,
      ...(params?.headers || {}),
    },
  };
}

function assertOk(response, method, path) {
  check(response, {
    [`${method} ${path} status is 2xx`]: (res) => res.status >= 200 && res.status < 300,
  });
  return response;
}

export function get(path, params = {}) {
  const response = http.get(`${BASE_URL}${path}`, mergeParams(params));
  return assertOk(response, "GET", path);
}

export function post(path, body, params = {}) {
  const response = http.post(`${BASE_URL}${path}`, JSON.stringify(body), mergeParams(params));
  return assertOk(response, "POST", path);
}

export function patch(path, body, params = {}) {
  const response = http.patch(`${BASE_URL}${path}`, JSON.stringify(body), mergeParams(params));
  return assertOk(response, "PATCH", path);
}
