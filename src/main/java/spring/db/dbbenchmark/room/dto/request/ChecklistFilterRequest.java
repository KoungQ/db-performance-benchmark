package spring.db.dbbenchmark.room.dto.request;

import spring.db.dbbenchmark.room.entity.enums.*;

public record ChecklistFilterRequest(
        SortType sortType,
        // Room
        RoomType roomType,
        ResidencePeriod residencePeriod,
        Integer capacity,
        // 생활 패턴
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
        // 추가 규칙
        String hairDryer,
        AlarmType alarm,
        EarphoneType earphone,
        KeyskinType keyskin,
        HeatType heat,
        ColdType cold,
        StudyType study,
        TrashCanType trashCan
) {
    public enum SortType {
        LATEST,   // ORDER BY c.updated_at DESC
        REMAINING // ORDER BY (capacity - current_mate_count) DESC
    }
}
