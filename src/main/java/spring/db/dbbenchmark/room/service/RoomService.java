package spring.db.dbbenchmark.room.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import spring.db.dbbenchmark.room.entity.Room;
import spring.db.dbbenchmark.room.repository.RoomRepository;

@Service
@RequiredArgsConstructor
public class RoomService {

    private final RoomRepository roomRepository;

    public Room findByRoomNo(Long roomNo) {
        return roomRepository.findById(roomNo)
                .orElseThrow(() -> new RuntimeException("방이 존재하지 않습니다."));
    }

}
