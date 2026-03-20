package spring.db.dbbenchmark.room.dto.response;

import spring.db.dbbenchmark.room.entity.enums.*;

public record RoomWithChecklistResponse(
        Long roomNo,
        String title,
        RoomType roomType,
        RoomStatus roomStatus,
        ResidencePeriod residencePeriod,
        Integer capacity,
        Integer currentMateCount,
        ChecklistSummaryResponse checklist
) {}
