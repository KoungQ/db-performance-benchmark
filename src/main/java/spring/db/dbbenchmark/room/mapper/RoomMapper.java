package spring.db.dbbenchmark.room.mapper;

import org.springframework.stereotype.Component;
import spring.db.dbbenchmark.room.dto.request.CreateRoomRequest;
import spring.db.dbbenchmark.room.entity.Checklist;
import spring.db.dbbenchmark.room.entity.Room;

@Component
public class RoomMapper {

    public Room toRoom(CreateRoomRequest request) {
        return Room.builder()
                .title(request.title())
                .roomType(request.roomType())
                .roomStatus(request.roomStatus())
                .residencePeriod(request.residencePeriod())
                .capacity(request.capacity())
                .currentMateCount(0)
                .build();
    }

    public Checklist toChecklist(CreateRoomRequest.CreateChecklistRequest request, Room room) {
        return Checklist.builder()
                .room(room)
                .bedtime(request.bedtime())
                .wakeUp(request.wakeUp())
                .returnHome(request.returnHome())
                .returnHomeTime(request.returnHomeTime())
                .cleaning(request.cleaning())
                .phoneCall(request.phoneCall())
                .sleepLight(request.sleepLight())
                .sleepHabit(request.sleepHabit())
                .snoring(request.snoring())
                .showerTime(request.showerTime())
                .eating(request.eating())
                .lightsOut(request.lightsOut())
                .lightsOutTime(request.lightsOutTime())
                .homeVisit(request.homeVisit())
                .smoking(request.smoking())
                .refrigerator(request.refrigerator())
                .hairDryer(request.hairDryer())
                .alarm(request.alarm())
                .earphone(request.earphone())
                .keyskin(request.keyskin())
                .heat(request.heat())
                .cold(request.cold())
                .study(request.study())
                .trashCan(request.trashCan())
                .otherNotes(request.otherNotes())
                .build();
    }
}
