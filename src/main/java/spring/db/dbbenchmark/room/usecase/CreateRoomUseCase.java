package spring.db.dbbenchmark.room.usecase;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import spring.db.dbbenchmark.room.dto.request.CreateRoomRequest;
import spring.db.dbbenchmark.room.dto.response.CreateRoomResponse;
import spring.db.dbbenchmark.room.entity.Checklist;
import spring.db.dbbenchmark.room.entity.Room;
import spring.db.dbbenchmark.room.mapper.RoomMapper;
import spring.db.dbbenchmark.room.repository.ChecklistRepository;
import spring.db.dbbenchmark.room.repository.RoomRepository;

@Service
@RequiredArgsConstructor
public class CreateRoomUseCase {

    private final RoomRepository roomRepository;
    private final ChecklistRepository checklistRepository;
    private final RoomMapper roomMapper;

    @Transactional
    public CreateRoomResponse execute(CreateRoomRequest request) {
        Room room = roomRepository.save(roomMapper.toRoom(request));
        Checklist checklist = checklistRepository.save(roomMapper.toChecklist(request.checklist(), room));
        return new CreateRoomResponse(room.getRoomNo(), checklist.getChecklistNo());
    }
}
