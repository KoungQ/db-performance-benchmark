package spring.db.dbbenchmark.room.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import spring.db.dbbenchmark.room.entity.Checklist;

import java.util.Optional;

public interface ChecklistRepository extends JpaRepository<Checklist, Long> {
    Optional<Checklist> findByRoom_RoomNo(Long roomNo);
}
