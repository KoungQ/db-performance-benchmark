const roomTypes = ["TYPE_1", "TYPE_2", "TYPE_MEDICAL"];
const roomStatuses = ["CONFIRM_PENDING", "IN_PROGRESS"];
const residencePeriods = ["SEMESTER", "HALF_YEAR", "SEASONAL"];
const bedtimes = ["22:00", "23:00"];
const wakeUps = ["06:00", "07:00"];
const returnHomes = ["FLEXIBLE", "FIXED"];
const returnHomeTimes = ["22:00", "24:00"];
const cleanings = ["REGULAR", "IRREGULAR"];
const phoneCalls = ["ALLOWED", "NOT_ALLOWED"];
const sleepLights = ["BRIGHT", "DARK"];
const sleepHabits = ["SEVERE", "MODERATE", "MILD"];
const snorings = ["SEVERE", "MODERATE", "MILD_OR_NONE"];
const showerTimes = ["MORNING", "EVENING"];
const eatings = ["ALLOWED", "NOT_ALLOWED", "ALLOWED_WITH_VENTILATION"];
const lightsOuts = ["AFTER_TIME", "WHEN_ONE_SLEEPS"];
const lightsOutTimes = ["22:00", "23:00"];
const homeVisits = ["WEEKLY", "BIWEEKLY", "MONTHLY_OR_MORE", "RARELY"];
const smokings = ["CIGARETTE", "E_CIGARETTE", "NON_SMOKER"];
const refrigerators = ["RENT_PURCHASE_OWN", "DECIDE_AFTER_DISCUSSION", "NOT_NEEDED"];
const alarms = ["VIBRATION", "SOUND"];
const earphones = ["ALWAYS", "FLEXIBLE"];
const keyskins = ["ALWAYS", "FLEXIBLE"];
const temperatureSensitivity = ["VERY_SENSITIVE", "MODERATE", "LESS_SENSITIVE"];
const studies = ["OUTSIDE_DORM", "INSIDE_DORM", "FLEXIBLE"];
const trashCans = ["INDIVIDUAL", "SHARED"];

function pick(options, seed) {
  return options[seed % options.length];
}

function buildChecklist(seed) {
  return {
    bedtime: pick(bedtimes, seed),
    wakeUp: pick(wakeUps, seed + 1),
    returnHome: pick(returnHomes, seed + 2),
    returnHomeTime: pick(returnHomeTimes, seed + 3),
    cleaning: pick(cleanings, seed + 4),
    phoneCall: pick(phoneCalls, seed + 5),
    sleepLight: pick(sleepLights, seed + 6),
    sleepHabit: pick(sleepHabits, seed + 7),
    snoring: pick(snorings, seed + 8),
    showerTime: pick(showerTimes, seed + 9),
    eating: pick(eatings, seed + 10),
    lightsOut: pick(lightsOuts, seed + 11),
    lightsOutTime: pick(lightsOutTimes, seed + 12),
    homeVisit: pick(homeVisits, seed + 13),
    smoking: pick(smokings, seed + 14),
    refrigerator: pick(refrigerators, seed + 15),
    hairDryer: seed % 2 === 0 ? "NIGHT_OK" : "EARLY_ONLY",
    alarm: pick(alarms, seed + 16),
    earphone: pick(earphones, seed + 17),
    keyskin: pick(keyskins, seed + 18),
    heat: pick(temperatureSensitivity, seed + 19),
    cold: pick(temperatureSensitivity, seed + 20),
    study: pick(studies, seed + 21),
    trashCan: pick(trashCans, seed + 22),
    otherNotes: `benchmark-note-${seed}`,
  };
}

export function buildCreateRoomRequest(seed) {
  return {
    title: `benchmark-room-${seed}`,
    roomType: pick(roomTypes, seed),
    roomStatus: pick(roomStatuses, seed + 1),
    residencePeriod: pick(residencePeriods, seed + 2),
    capacity: [2, 4, 6][seed % 3],
    checklist: buildChecklist(seed),
  };
}

export function buildUpdateRoomRequest(seed) {
  return {
    title: `benchmark-room-updated-${seed}`,
    roomType: pick(roomTypes, seed + 3),
    roomStatus: pick(roomStatuses, seed + 4),
    residencePeriod: pick(residencePeriods, seed + 5),
    capacity: [2, 4, 6][(seed + 1) % 3],
    checklist: buildChecklist(seed + 1000),
  };
}

export function buildReadFilter(seed, sortType = "LATEST") {
  const filters = {
    sortType,
    roomType: pick(roomTypes, seed),
    residencePeriod: pick(residencePeriods, seed + 1),
    capacity: [2, 4, 6][seed % 3],
    bedtime: pick(bedtimes, seed + 2),
    wakeUp: pick(wakeUps, seed + 3),
    returnHome: pick(returnHomes, seed + 4),
    returnHomeTime: pick(returnHomeTimes, seed + 5),
    cleaning: pick(cleanings, seed + 6),
    phoneCall: pick(phoneCalls, seed + 7),
    sleepLight: pick(sleepLights, seed + 8),
    sleepHabit: pick(sleepHabits, seed + 9),
    snoring: pick(snorings, seed + 10),
    showerTime: pick(showerTimes, seed + 11),
    eating: pick(eatings, seed + 12),
    lightsOut: pick(lightsOuts, seed + 13),
    lightsOutTime: pick(lightsOutTimes, seed + 14),
    homeVisit: pick(homeVisits, seed + 15),
    smoking: pick(smokings, seed + 16),
    refrigerator: pick(refrigerators, seed + 17),
    hairDryer: seed % 2 === 0 ? "NIGHT_OK" : null,
    alarm: pick(alarms, seed + 18),
    earphone: pick(earphones, seed + 19),
    keyskin: pick(keyskins, seed + 20),
    heat: pick(temperatureSensitivity, seed + 21),
    cold: pick(temperatureSensitivity, seed + 22),
    study: pick(studies, seed + 23),
    trashCan: pick(trashCans, seed + 24),
  };

  const keys = Object.keys(filters).filter((key) => key !== "sortType");
  const keepCount = 5 + (seed % 6);
  const keep = new Set();

  for (let i = 0; i < keepCount; i += 1) {
    keep.add(keys[(seed + i * 3) % keys.length]);
  }

  for (const key of keys) {
    if (!keep.has(key)) {
      filters[key] = null;
    }
  }

  return filters;
}
