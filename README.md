# Database Performance Benchmark

## Background: 왜 이 벤치마크를 시작했는가?

### 1. Pain Point
DorumDorum은 기숙사 룸메이트를 매칭해주는 서비스입니다. 이 서비스에서 유저가 가장 먼저 마주하는 핵심 기능은 **20개 이상의 생활 습관 필터링을 통한 룸메이트 검색** 및 실시간 채팅입니다.
유저는 본인과 맞는 사람을 찾기 위해 '흡연 여부', '수면 시간', '청소 주기' 등 수많은 조건을 선택합니다.

### 2. Technical Challenge
* **동적 쿼리의 복잡성:** 유저마다 선택하는 필터 조합이 수만 가지에 달하며, 이는 DB 입장에서 고정된 인덱스 전략을 세우기 어렵게 만듭니다.
* **데이터 정합성 vs 성능:** 매칭 신청이나 프로필 수정이 빈번하게 일어나는 상황(Write)에서도 검색 결과(Read)는 빠르고 정확해야 합니다.
* **MVCC 오버헤드:** 20개가 넘는 컬럼을 가진 '넓은 테이블(Wide Table)' 구조에서 수정(Update)이 발생할 때, DB 엔진의 아키텍처(Undo Log vs Tuple Versioning)에 따라 성능 저하 폭이 크게 다를 것이라 판단했습니다.

### 3. Objective
단순히 유행하는 기술 스택을 추종하는 것이 아니라, **실제 서비스의 데이터 구조와 쿼리 패턴을 기반으로 가설을 설정하고, 이를 수치화된 벤치마크 데이터로 검증**하여 최적의 인프라를 선정하는 것을 목적으로 합니다.

---

## Track 1. RDB 비교: MySQL 8.4 vs PostgreSQL 16

### 1. 가설 설정 (Hypothesis)

| 가설 | 내용 | 근거                                                   |
|:--- |:--- |:-----------------------------------------------------|
| **H1 (조회)** | **5개 이상 다중 필터** 조건에서 PostgreSQL의 **Bitmap Index Scan**이 MySQL의 **Index Merge**보다 우세할 것이다. | 여러 단일 인덱스를 메모리에서 결합하여 비트맵으로 연산하는 능력의 차이              |
| **H2 (수정)** | **잦은 Update** 발생 시, MySQL(Undo Log)이 PostgreSQL(Tuple Copy)보다 **Table Bloat** 현상이 적고 성능이 안정적일 것이다. | **MVCC 구현 방식**에 따른 구버전 데이터 관리 및 디스크 I/O 효율성          |
| **H3 (생성)** | **데이터 삽입(Insert)** 시, Clustered Index 구조인 MySQL이 물리적 정렬 이득으로 인해 처리량이 높을 것이다. | 데이터가 PK 순서대로 물리적으로 정렬되는지(Clustered) vs Heap에 쌓이는지 차이 |

---

### 2. MVCC(Multi-Version Concurrency Control) 아키텍처 비교
본 벤치마크는 두 DB가 동시성을 제어하는 근본적인 메커니즘 차이를 추적합니다.

#### **MySQL (InnoDB): Undo Log 방식**
* **메커니즘:** 데이터를 수정할 때 원본 페이지의 데이터를 **직접 수정**하고, 이전 값은 **Undo Log** 영역에 기록합니다.
* **영향:** 20개의 필드 중 1개만 수정해도 변경된 값만 로그에 남기므로 스토리지 오버헤드가 적습니다. 하지만 긴 트랜잭션이 유지될 경우 Undo Log가 비대해져 전체 성능을 저하시킬 수 있습니다.

#### **PostgreSQL: Tuple Versioning 방식**
* **메커니즘:** 데이터를 수정할 때 기존 행을 건드리지 않고, **새로운 행(Tuple)을 통째로 생성**합니다. 기존 행은 Dead Tuple이 됩니다.
* **영향:** 20개 필드 중 하나만 수정해도 행 전체가 새로 복사되므로 **Table Bloat(테이블 부풀림)** 현상이 발생합니다. 이를 정리하는 `VACUUM` 프로세스가 성능의 핵심 변수가 됩니다.

---

### 3. 워크로드 시나리오 (20개 항목 체크리스트 기준)

#### **A. 동적 필터 조회 (Read)**
* **상황:** 유저가 흡연, 수면시간 등 20개 조건 중 5~10개를 선택해 룸메이트를 검색함.
* **쿼리:** `SELECT * FROM checklist WHERE smoking='NON_SMOKER' AND cleaning='DAILY' ... LIMIT 1000`
* **검증:** 복합 인덱스가 없는 상황에서 각 DB가 여러 단일 인덱스를 얼마나 효율적으로 병합(Merge)하는지 측정.

#### **B. 생성 (Create)**
* **상황:** 새로운 유저가 자신의 생활 습관 20개 항목을 입력하고 저장함.
* **검증:** 다수의 인덱스(10개 이상)가 걸린 상태에서 새로운 데이터를 삽입할 때 발생하는 인덱스 쓰기 지연(Latency) 비교.

#### **C. 수정 (Update)**
* **상황:** 유저가 자신의 체크리스트 중 '기타 특이사항(Text)'이나 '기상 시간'을 수정함.
* **검증:** 수정 발생 시 실제 디스크 사용량 변화와, 수정 작업이 동시에 진행될 때 조회 쿼리의 응답 속도 변화(MVCC 격리 수준 검증).

---

## Track 2. RDB vs NoSQL (MongoDB)
*(채팅 메시지 저장소 워크로드 테스트 시 업데이트 예정)*

- **워크로드:** 채팅 메시지 Write-heavy/Read-heavy 시나리오
- **비교 포인트:** 수평 확장성(Sharding), 스키마 유연성, 고빈도 삽입 성능
- **상태:** [Pending]

---

## 실험 환경 및 도구
- **Target:** MySQL 8.4 / PostgreSQL 16 (Docker 컨테이너)
- **API:** Spring Boot 3.2 (QueryDSL을 활용한 20개 항목 동적 필터링 구현)
- **Load Tool:** **k6** (동시성 부하 테스트), **sysbench** (MySQL), **pgbench** (PostgreSQL)
- **Monitoring:** Prometheus + Grafana (CPU, Memory, Disk I/O, DB Lock 현황 시각화)

### 엔진 벤치마크 공통 조건 (MySQL vs PostgreSQL)

두 DB를 **동일 조건**으로 비교하기 위해 아래 설정을 맞춰 둠.

| 항목 | MySQL | PostgreSQL |
|------|-------|------------|
| **버퍼/캐시** | innodb_buffer_pool_size=128M | shared_buffers=128MB |
| **정렬/해시 메모리** | sort_buffer_size=2M | work_mem=2MB |
| **max_connections** | 300 | 300 |
| **동시 클라이언트** | 10 (CLIENTS) | 10 (CLIENTS) |
| **컨테이너 메모리** | 1GB | 1GB |
| **기본 시나리오 duration** | 300초 | 300초 |

*macOS에서 pgbench "No space left on device" 시*: Docker Desktop → Settings → Resources → Memory **4GB 이상**으로 설정.

---

## 현재 엔진 시나리오

- **Read**: 다중 필터로 후보를 좁힌 뒤 남은 인원수 기준으로 정렬
- **Insert**: `room` + `checklist` 생성
- **Update**: `checklist` 여러 필드를 동시에 수정하는 wide-row update

---

## 실행 방법

### 1. 전체 초기화 후 기동

```bash
docker compose -f docker-compose.bench.yml down -v
python3 scripts/generate-seed-data.py
docker compose -f docker-compose.bench.yml up -d
sleep 120
```

접속 포인트:

- Grafana: `http://127.0.0.1:3001`
- Prometheus: `http://127.0.0.1:9091`
- Pushgateway: `http://127.0.0.1:19092`

### 2. 엔진 벤치마크

기본값:

- `TIME_SECONDS=300` (각 시나리오 5분)
- `WINDOW_SECONDS=5` (Grafana 시계열 갱신 단위)
- `SCENARIOS="room-checklist-read room-checklist-insert room-checklist-update"`

순차 비교:

```bash
WINDOW_SECONDS=5 bash scripts/run-engine-bench.sh all
```

동시 관측:

```bash
TIME_SECONDS=1200 WINDOW_SECONDS=5 bash scripts/run-engine-bench.sh parallel
```

MySQL만:

```bash
WINDOW_SECONDS=5 bash scripts/run-engine-bench.sh mysql
```

PostgreSQL만:

```bash
WINDOW_SECONDS=5 bash scripts/run-engine-bench.sh postgres
```

튜닝 예시:

```bash
CLIENTS=20 TIME_SECONDS=600 WINDOW_SECONDS=5 bash scripts/run-engine-bench.sh all
CLIENTS=20 JOBS=8 TIME_SECONDS=600 WINDOW_SECONDS=5 bash scripts/run-engine-bench.sh postgres
SCENARIOS=room-checklist-update WINDOW_SECONDS=5 bash scripts/run-engine-bench.sh parallel
```

### 3. API 부하 테스트

MySQL:

```bash
bash scripts/run-api-bench.sh mysql read-heavy 3
bash scripts/run-api-bench.sh mysql write-heavy 3
bash scripts/run-api-bench.sh mysql update-heavy 3
```

PostgreSQL:

```bash
bash scripts/run-api-bench.sh postgres read-heavy 3
bash scripts/run-api-bench.sh postgres write-heavy 3
bash scripts/run-api-bench.sh postgres update-heavy 3
```

---

## 결과 확인

엔진 결과 요약:

```bash
bash scripts/summarize-engine-results.sh
```

결과 위치:

- `benchmarks/engine/mysql-vs-postgres/results/mysql/*.txt`
- `benchmarks/engine/mysql-vs-postgres/results/postgres/*.txt`
- `benchmarks/engine/mysql-vs-postgres/results/k6/mysql/*.json`
- `benchmarks/engine/mysql-vs-postgres/results/k6/postgres/*.json`

Grafana 대시보드:

- `MySQL vs PostgreSQL Engine Benchmark`
- `Run ID` 드롭다운으로 이번 실행만 선택 가능

---

## 관측 메모

- `parallel`은 같은 시간대 Grafana 관측용이다. 최종 절대 비교 수치는 `all` 기준으로 해석하는 편이 낫다.
- `run-engine-bench.sh`는 실행 전에 DB 포트 연결과 `room` / `checklist` seed row count를 검증한다.
- 각 시나리오 종료 후 해당 시나리오 메트릭은 Pushgateway에서 삭제되어, 이전 색상이 다음 시나리오 구간까지 이어지지 않는다.
