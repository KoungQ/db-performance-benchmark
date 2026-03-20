-- room-checklist-read: JOIN room+checklist with 8 filters, ORDER BY remaining slots DESC
SELECT r.room_no,
       r.title,
       r.room_type,
       r.room_status,
       r.residence_period,
       r.capacity,
       r.current_mate_count,
       c.checklist_no,
       c.bedtime,
       c.wake_up,
       c.return_home,
       c.return_home_time,
       c.cleaning,
       c.phone_call,
       c.sleep_light,
       c.sleep_habit,
       c.snoring,
       c.shower_time,
       c.eating,
       c.lights_out,
       c.lights_out_time,
       c.home_visit,
       c.smoking,
       c.refrigerator,
       c.created_at,
       c.updated_at
FROM room r
JOIN checklist c ON c.room_no = r.room_no
WHERE r.room_status = 'CONFIRM_PENDING'
  AND r.capacity = 2
  AND c.return_home = 'FLEXIBLE'
  AND c.cleaning = 'REGULAR'
  AND c.phone_call = 'ALLOWED'
  AND c.sleep_light = 'DARK'
  AND c.smoking = 'NON_SMOKER'
  AND c.refrigerator = 'RENT_PURCHASE_OWN'
ORDER BY (r.capacity - r.current_mate_count) DESC, r.room_no DESC, c.checklist_no DESC
LIMIT 50;
