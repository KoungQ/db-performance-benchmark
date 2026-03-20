-- room-checklist-insert: INSERT room + checklist (pgbench format with \set, RETURNING)
\set cr random(1, 100000000)
WITH ins AS (
  INSERT INTO room (title, room_type, room_status, residence_period, capacity, current_mate_count)
  VALUES ('Room ' || :cr, 'TYPE_1', 'CONFIRM_PENDING', 'SEMESTER', 2, 0)
  RETURNING room_no
)
INSERT INTO checklist (room_no, bedtime, wake_up, return_home, return_home_time, cleaning, phone_call, sleep_light, sleep_habit, snoring, shower_time, eating, lights_out, lights_out_time, home_visit, smoking, refrigerator)
SELECT room_no, '23:00', '07:00', 'FLEXIBLE', '22:00', 'REGULAR', 'ALLOWED', 'DARK', 'MILD', 'MILD_OR_NONE', 'EVENING', 'ALLOWED', 'AFTER_TIME', '23:00', 'WEEKLY', 'NON_SMOKER', 'RENT_PURCHASE_OWN'
FROM ins;
