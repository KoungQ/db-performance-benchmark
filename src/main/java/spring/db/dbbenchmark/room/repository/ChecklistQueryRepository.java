package spring.db.dbbenchmark.room.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import spring.db.dbbenchmark.room.dto.request.ChecklistFilterRequest;
import spring.db.dbbenchmark.room.dto.response.RoomWithChecklistResponse;

public interface ChecklistQueryRepository {

    Page<RoomWithChecklistResponse> findChecklistsByFilter(ChecklistFilterRequest filter, Pageable pageable);
}
