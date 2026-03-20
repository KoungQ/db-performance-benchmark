package spring.db.dbbenchmark.room.dto.response;

import spring.db.dbbenchmark.room.entity.enums.*;

import java.time.LocalDateTime;

public record ChecklistSummaryResponse(
        Long checklistNo,
        String bedtime,
        String wakeUp,
        ReturnHomeType returnHome,
        String returnHomeTime,
        CleaningType cleaning,
        PhoneCallType phoneCall,
        SleepLightType sleepLight,
        SleepHabitType sleepHabit,
        SnoringType snoring,
        ShowerTimeType showerTime,
        EatingType eating,
        LightsOutType lightsOut,
        String lightsOutTime,
        HomeVisitType homeVisit,
        SmokingType smoking,
        RefrigeratorType refrigerator,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {}
