-- room-checklist-insert: INSERT room + checklist
sysbench.cmdline.options = {
  time = {"Duration in seconds", 120},
  threads = {"Number of threads", 10}
}

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()
end

function thread_done()
  con:disconnect()
end

function event()
  local cr = sysbench.rand.uniform(1, 100000000)
  -- PostgreSQL과 동일: 1 트랜잭션 = 1 room+checklist insert
  con:query("BEGIN")
  con:query(string.format("INSERT INTO room (title, room_type, room_status, residence_period, capacity, current_mate_count) VALUES ('Room %d', 'TYPE_1', 'CONFIRM_PENDING', 'SEMESTER', 2, 0)", cr))
  con:query([[
    INSERT INTO checklist (room_no, bedtime, wake_up, return_home, return_home_time, cleaning, phone_call, sleep_light, sleep_habit, snoring, shower_time, eating, lights_out, lights_out_time, home_visit, smoking, refrigerator)
    VALUES (LAST_INSERT_ID(), '23:00', '07:00', 'FLEXIBLE', '22:00', 'REGULAR', 'ALLOWED', 'DARK', 'MILD', 'MILD_OR_NONE', 'EVENING', 'ALLOWED', 'AFTER_TIME', '23:00', 'WEEKLY', 'NON_SMOKER', 'RENT_PURCHASE_OWN')
  ]])
  con:query("COMMIT")
end
