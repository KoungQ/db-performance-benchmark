-- room-checklist-update: wide-row UPDATE checklist WHERE room_no = random(1,10000)
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
  local rn = sysbench.rand.special(1, 10000)
  con:query(string.format([[
    UPDATE checklist
    SET updated_at = CURRENT_TIMESTAMP,
        bedtime = CASE WHEN bedtime = '22:00' THEN '23:00' ELSE '22:00' END,
        wake_up = CASE WHEN wake_up = '06:00' THEN '07:00' ELSE '06:00' END,
        cleaning = CASE WHEN cleaning = 'REGULAR' THEN 'IRREGULAR' ELSE 'REGULAR' END,
        phone_call = CASE WHEN phone_call = 'ALLOWED' THEN 'NOT_ALLOWED' ELSE 'ALLOWED' END,
        sleep_light = CASE WHEN sleep_light = 'DARK' THEN 'BRIGHT' ELSE 'DARK' END,
        smoking = CASE
            WHEN smoking = 'NON_SMOKER' THEN 'CIGARETTE'
            WHEN smoking = 'CIGARETTE' THEN 'E_CIGARETTE'
            ELSE 'NON_SMOKER'
        END,
        other_notes = CONCAT('benchmark-update-', %d, '-', UNIX_TIMESTAMP(CURRENT_TIMESTAMP))
    WHERE room_no = %d
  ]], rn, rn))
end
