package spring.db.dbbenchmark.room.mapper;

import org.springframework.stereotype.Component;
import spring.db.dbbenchmark.room.dto.response.ChecklistSummaryResponse;
import spring.db.dbbenchmark.room.dto.response.RoomWithChecklistResponse;
import spring.db.dbbenchmark.room.entity.Checklist;
import spring.db.dbbenchmark.room.entity.Room;

@Component
public class ChecklistMapper {

    public RoomWithChecklistResponse toRoomWithChecklist(Checklist c) {
        Room r = c.getRoom();
        return new RoomWithChecklistResponse(
                r.getRoomNo(),
                r.getTitle(),
                r.getRoomType(),
                r.getRoomStatus(),
                r.getResidencePeriod(),
                r.getCapacity(),
                r.getCurrentMateCount(),
                toChecklistSummary(c)
        );
    }

    public ChecklistSummaryResponse toChecklistSummary(Checklist c) {
        return new ChecklistSummaryResponse(
                c.getChecklistNo(),
                c.getBedtime(),
                c.getWakeUp(),
                c.getReturnHome(),
                c.getReturnHomeTime(),
                c.getCleaning(),
                c.getPhoneCall(),
                c.getSleepLight(),
                c.getSleepHabit(),
                c.getSnoring(),
                c.getShowerTime(),
                c.getEating(),
                c.getLightsOut(),
                c.getLightsOutTime(),
                c.getHomeVisit(),
                c.getSmoking(),
                c.getRefrigerator(),
                c.getCreatedAt(),
                c.getUpdatedAt()
        );
    }
}
