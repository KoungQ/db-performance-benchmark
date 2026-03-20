package spring.db.dbbenchmark.room.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import spring.db.dbbenchmark.room.entity.enums.ResidencePeriod;
import spring.db.dbbenchmark.room.entity.enums.RoomStatus;
import spring.db.dbbenchmark.room.entity.enums.RoomType;

public record RoomUpdateRequest(
        @NotBlank String title,
        @NotNull RoomType roomType,
        @NotNull RoomStatus roomStatus,
        @NotNull ResidencePeriod residencePeriod,
        @NotNull Integer capacity,
        @Valid @NotNull UpdateChecklistRequest checklist
) {}
