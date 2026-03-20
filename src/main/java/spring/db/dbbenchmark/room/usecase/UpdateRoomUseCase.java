package spring.db.dbbenchmark.room.usecase;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import spring.db.dbbenchmark.room.dto.request.RoomUpdateRequest;
import spring.db.dbbenchmark.room.entity.Checklist;
import spring.db.dbbenchmark.room.entity.Room;
import spring.db.dbbenchmark.room.service.ChecklistService;
import spring.db.dbbenchmark.room.service.RoomService;

@Service
@RequiredArgsConstructor
public class UpdateRoomUseCase {

    private final RoomService roomService;
    private final ChecklistService checklistService;

    @Transactional
    public void execute(Long roomNo, RoomUpdateRequest request) {
        Room room = roomService.findByRoomNo(roomNo);
        room.update(request);

        Checklist checklist = checklistService.findByRoomNo(roomNo);
        checklist.update(request.checklist());
    }
}
