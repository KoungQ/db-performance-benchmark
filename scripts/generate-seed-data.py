#!/usr/bin/env python3
"""
Generate 10k rooms + checklists for MySQL and PostgreSQL benchmark seed data.
Output: src/main/resources/sql/mysql/data.sql, src/main/resources/sql/postgres/data.sql
"""
import random
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
MYSQL_DATA = ROOT / "src" / "main" / "resources" / "sql" / "mysql" / "data.sql"
POSTGRES_DATA = ROOT / "src" / "main" / "resources" / "sql" / "postgres" / "data.sql"
NUM_ROOMS = 10_000

ROOM_TYPES = ("TYPE_1", "TYPE_2", "TYPE_MEDICAL")
ROOM_STATUSES = ("CONFIRM_PENDING", "IN_PROGRESS", "COMPLETED")
RESIDENCE_PERIODS = ("SEMESTER", "HALF_YEAR", "SEASONAL")

BEDTIMES = ("22:00", "23:00")
WAKE_UPS = ("06:00", "07:00")
RETURN_HOMES = ("FLEXIBLE", "FIXED")
RETURN_HOME_TIMES = ("22:00", "24:00")
CLEANINGS = ("REGULAR", "IRREGULAR")
PHONE_CALLS = ("ALLOWED", "NOT_ALLOWED")
SLEEP_LIGHTS = ("BRIGHT", "DARK")
SLEEP_HABITS = ("SEVERE", "MODERATE", "MILD")
SNORINGS = ("SEVERE", "MODERATE", "MILD_OR_NONE")
SHOWER_TIMES = ("MORNING", "EVENING")
EATINGS = ("ALLOWED", "NOT_ALLOWED", "ALLOWED_WITH_VENTILATION")
LIGHTS_OUTS = ("AFTER_TIME", "WHEN_ONE_SLEEPS")
LIGHTS_OUT_TIMES = ("22:00", "23:00")
HOME_VISITS = ("WEEKLY", "BIWEEKLY", "MONTHLY_OR_MORE", "RARELY")
SMOKINGS = ("CIGARETTE", "E_CIGARETTE", "NON_SMOKER")
REFRIGERATORS = ("RENT_PURCHASE_OWN", "DECIDE_AFTER_DISCUSSION", "NOT_NEEDED")


def pick(lst):
    return random.choice(lst)


def generate_room(i: int) -> tuple:
    capacity = random.choice((2, 4, 6))
    current_mate_count = random.randint(0, capacity)
    return (
        i,
        f"room-{i}",
        pick(ROOM_TYPES),
        pick(ROOM_STATUSES),
        pick(RESIDENCE_PERIODS),
        capacity,
        current_mate_count,
    )


def generate_checklist(i: int, room_no: int) -> tuple:
    return (
        i,
        room_no,
        pick(BEDTIMES),
        pick(WAKE_UPS),
        pick(RETURN_HOMES),
        pick(RETURN_HOME_TIMES),
        pick(CLEANINGS),
        pick(PHONE_CALLS),
        pick(SLEEP_LIGHTS),
        pick(SLEEP_HABITS),
        pick(SNORINGS),
        pick(SHOWER_TIMES),
        pick(EATINGS),
        pick(LIGHTS_OUTS),
        pick(LIGHTS_OUT_TIMES),
        pick(HOME_VISITS),
        pick(SMOKINGS),
        pick(REFRIGERATORS),
    )


def escape_sql(s: str) -> str:
    return s.replace("'", "''")


def write_mysql():
    MYSQL_DATA.parent.mkdir(parents=True, exist_ok=True)
    rooms = []
    checklists = []
    for i in range(1, NUM_ROOMS + 1):
        r = generate_room(i)
        rooms.append(f"({r[0]}, '{escape_sql(r[1])}', '{r[2]}', '{r[3]}', '{r[4]}', {r[5]}, {r[6]})")
        c = generate_checklist(i, i)
        checklists.append(
            f"({c[0]}, {c[1]}, '{c[2]}', '{c[3]}', '{c[4]}', '{c[5]}', '{c[6]}', '{c[7]}', "
            f"'{c[8]}', '{c[9]}', '{c[10]}', '{c[11]}', '{c[12]}', '{c[13]}', '{c[14]}', '{c[15]}', "
            f"'{c[16]}', '{c[17]}')"
        )

    with open(MYSQL_DATA, "w") as f:
        f.write("-- MySQL room+checklist seed (10k rows)\n")
        f.write("INSERT INTO room (room_no, title, room_type, room_status, residence_period, capacity, current_mate_count)\nVALUES\n")
        f.write(",\n".join(rooms))
        f.write(";\n\n")
        f.write("INSERT INTO checklist (checklist_no, room_no, bedtime, wake_up, return_home, return_home_time, cleaning, phone_call, sleep_light, sleep_habit, snoring, shower_time, eating, lights_out, lights_out_time, home_visit, smoking, refrigerator)\nVALUES\n")
        f.write(",\n".join(checklists))
        f.write(";\n")


def write_postgres():
    POSTGRES_DATA.parent.mkdir(parents=True, exist_ok=True)
    rooms = []
    checklists = []
    for i in range(1, NUM_ROOMS + 1):
        r = generate_room(i)
        rooms.append(f"({r[0]}, '{escape_sql(r[1])}', '{r[2]}', '{r[3]}', '{r[4]}', {r[5]}, {r[6]})")
        c = generate_checklist(i, i)
        checklists.append(
            f"({c[0]}, {c[1]}, '{c[2]}', '{c[3]}', '{c[4]}', '{c[5]}', '{c[6]}', '{c[7]}', "
            f"'{c[8]}', '{c[9]}', '{c[10]}', '{c[11]}', '{c[12]}', '{c[13]}', '{c[14]}', '{c[15]}', "
            f"'{c[16]}', '{c[17]}')"
        )

    with open(POSTGRES_DATA, "w") as f:
        f.write("-- PostgreSQL room+checklist seed (10k rows)\n")
        f.write("INSERT INTO room (room_no, title, room_type, room_status, residence_period, capacity, current_mate_count)\nVALUES\n")
        f.write(",\n".join(rooms))
        f.write("\nON CONFLICT (room_no) DO NOTHING;\n\n")
        f.write("INSERT INTO checklist (checklist_no, room_no, bedtime, wake_up, return_home, return_home_time, cleaning, phone_call, sleep_light, sleep_habit, snoring, shower_time, eating, lights_out, lights_out_time, home_visit, smoking, refrigerator)\nVALUES\n")
        f.write(",\n".join(checklists))
        f.write("\nON CONFLICT (checklist_no) DO NOTHING;\n")
        f.write("\nSELECT setval(pg_get_serial_sequence('room', 'room_no'), COALESCE((SELECT MAX(room_no) FROM room), 1), true);\n")
        f.write("SELECT setval(pg_get_serial_sequence('checklist', 'checklist_no'), COALESCE((SELECT MAX(checklist_no) FROM checklist), 1), true);\n")


def main():
    random.seed(42)
    print(f"Generating {NUM_ROOMS} rooms + checklists...")
    write_mysql()
    write_postgres()
    print(f"Done. Output:")
    print(f"  MySQL:    {MYSQL_DATA}")
    print(f"  Postgres: {POSTGRES_DATA}")


if __name__ == "__main__":
    main()
