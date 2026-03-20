package spring.db.dbbenchmark.room.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import spring.db.dbbenchmark.room.entity.enums.*;

public record CreateRoomRequest(
        @NotBlank String title,
        @NotNull RoomType roomType,
        @NotNull RoomStatus roomStatus,
        @NotNull ResidencePeriod residencePeriod,
        @NotNull Integer capacity,
        @Valid CreateChecklistRequest checklist
) {
    public record CreateChecklistRequest(
            @NotBlank String bedtime,
            @NotBlank String wakeUp,
            @NotNull ReturnHomeType returnHome,
            @NotBlank String returnHomeTime,
            @NotNull CleaningType cleaning,
            @NotNull PhoneCallType phoneCall,
            @NotNull SleepLightType sleepLight,
            @NotNull SleepHabitType sleepHabit,
            @NotNull SnoringType snoring,
            @NotNull ShowerTimeType showerTime,
            @NotNull EatingType eating,
            @NotNull LightsOutType lightsOut,
            @NotBlank String lightsOutTime,
            @NotNull HomeVisitType homeVisit,
            @NotNull SmokingType smoking,
            @NotNull RefrigeratorType refrigerator,
            String hairDryer,
            AlarmType alarm,
            EarphoneType earphone,
            KeyskinType keyskin,
            HeatType heat,
            ColdType cold,
            StudyType study,
            TrashCanType trashCan,
            String otherNotes
    ) {}
}
