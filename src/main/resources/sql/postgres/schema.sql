CREATE TABLE IF NOT EXISTS room (
    room_no BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    room_type VARCHAR(32) NOT NULL,
    room_status VARCHAR(32) NOT NULL,
    residence_period VARCHAR(32) NOT NULL,
    capacity INTEGER NOT NULL,
    current_mate_count INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS checklist (
    checklist_no BIGSERIAL PRIMARY KEY,
    room_no BIGINT NOT NULL,
    bedtime VARCHAR(32) NOT NULL,
    wake_up VARCHAR(32) NOT NULL,
    return_home VARCHAR(32) NOT NULL,
    return_home_time VARCHAR(32) NOT NULL,
    cleaning VARCHAR(32) NOT NULL,
    phone_call VARCHAR(32) NOT NULL,
    sleep_light VARCHAR(32) NOT NULL,
    sleep_habit VARCHAR(32) NOT NULL,
    snoring VARCHAR(32) NOT NULL,
    shower_time VARCHAR(32) NOT NULL,
    eating VARCHAR(32) NOT NULL,
    lights_out VARCHAR(32) NOT NULL,
    lights_out_time VARCHAR(32) NOT NULL,
    home_visit VARCHAR(32) NOT NULL,
    smoking VARCHAR(32) NOT NULL,
    refrigerator VARCHAR(32) NOT NULL,
    hair_dryer VARCHAR(255) DEFAULT NULL,
    alarm VARCHAR(32) DEFAULT NULL,
    earphone VARCHAR(32) DEFAULT NULL,
    keyskin VARCHAR(32) DEFAULT NULL,
    heat VARCHAR(32) DEFAULT NULL,
    cold VARCHAR(32) DEFAULT NULL,
    study VARCHAR(32) DEFAULT NULL,
    trash_can VARCHAR(32) DEFAULT NULL,
    other_notes TEXT DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_checklist_room FOREIGN KEY (room_no) REFERENCES room (room_no) ON DELETE CASCADE,
    CONSTRAINT uq_checklist_room_no UNIQUE (room_no)
);

-- Checklist: 필수 항목만 단일 인덱스 (선택 항목은 null 가능해 필터 사용 빈도 낮음)
CREATE INDEX IF NOT EXISTS idx_checklist_bedtime ON checklist (bedtime);
CREATE INDEX IF NOT EXISTS idx_checklist_wake_up ON checklist (wake_up);
CREATE INDEX IF NOT EXISTS idx_checklist_return_home ON checklist (return_home);
CREATE INDEX IF NOT EXISTS idx_checklist_return_home_time ON checklist (return_home_time);
CREATE INDEX IF NOT EXISTS idx_checklist_cleaning ON checklist (cleaning);
CREATE INDEX IF NOT EXISTS idx_checklist_phone_call ON checklist (phone_call);
CREATE INDEX IF NOT EXISTS idx_checklist_sleep_light ON checklist (sleep_light);
CREATE INDEX IF NOT EXISTS idx_checklist_sleep_habit ON checklist (sleep_habit);
CREATE INDEX IF NOT EXISTS idx_checklist_snoring ON checklist (snoring);
CREATE INDEX IF NOT EXISTS idx_checklist_shower_time ON checklist (shower_time);
CREATE INDEX IF NOT EXISTS idx_checklist_eating ON checklist (eating);
CREATE INDEX IF NOT EXISTS idx_checklist_lights_out ON checklist (lights_out);
CREATE INDEX IF NOT EXISTS idx_checklist_lights_out_time ON checklist (lights_out_time);
CREATE INDEX IF NOT EXISTS idx_checklist_home_visit ON checklist (home_visit);
CREATE INDEX IF NOT EXISTS idx_checklist_smoking ON checklist (smoking);
CREATE INDEX IF NOT EXISTS idx_checklist_refrigerator ON checklist (refrigerator);
-- room-checklist-read: ORDER BY c.updated_at DESC
CREATE INDEX IF NOT EXISTS idx_checklist_updated_at ON checklist (updated_at DESC);

-- Room: REMAINING 정렬용 (capacity - current_mate_count DESC, room_no DESC)
CREATE INDEX IF NOT EXISTS idx_room_remaining ON room (capacity DESC, current_mate_count ASC, room_no DESC);

-- Room: room_status, room_type 필터용 (capacity는 idx_room_remaining 선행 컬럼으로 커버)
CREATE INDEX IF NOT EXISTS idx_room_status_type ON room (room_status, room_type);

CREATE TABLE IF NOT EXISTS bench_chat_message (
    id BIGSERIAL PRIMARY KEY,
    room_key VARCHAR(64) NOT NULL,
    sender_id VARCHAR(64) NOT NULL,
    message_body VARCHAR(2000) NOT NULL,
    message_order BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_chat_room_order ON bench_chat_message (room_key, message_order);
CREATE INDEX IF NOT EXISTS idx_chat_created_at ON bench_chat_message (created_at);
