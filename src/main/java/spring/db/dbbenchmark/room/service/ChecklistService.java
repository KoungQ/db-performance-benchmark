package spring.db.dbbenchmark.room.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import spring.db.dbbenchmark.room.dto.request.ChecklistFilterRequest;
import spring.db.dbbenchmark.room.dto.response.RoomWithChecklistResponse;
import spring.db.dbbenchmark.room.entity.Checklist;
import spring.db.dbbenchmark.room.repository.ChecklistQueryRepository;
import spring.db.dbbenchmark.room.repository.ChecklistRepository;

@Service
@RequiredArgsConstructor
public class ChecklistService {

    private final ChecklistRepository checklistRepository;
    private final ChecklistQueryRepository checklistQueryRepository;

    public Checklist findByRoomNo(Long roomNo) {
        return checklistRepository.findByRoom_RoomNo(roomNo)
                .orElseThrow(() -> new RuntimeException("체크리스트가 존재하지 않습니다."));
    }

    public Page<RoomWithChecklistResponse> findChecklistsByFilter(ChecklistFilterRequest filter, Pageable pageable) {
        return checklistQueryRepository.findChecklistsByFilter(filter, pageable);
    }
}
