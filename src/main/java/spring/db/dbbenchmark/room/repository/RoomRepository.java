package spring.db.dbbenchmark.room.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import spring.db.dbbenchmark.room.entity.Room;

import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Long> {

    Optional<Room> findByRoomNo(Long roomNo);

}
