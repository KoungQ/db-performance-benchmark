package spring.db.dbbenchmark.room.usecase;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import spring.db.dbbenchmark.room.dto.request.ChecklistFilterRequest;
import spring.db.dbbenchmark.room.dto.response.RoomWithChecklistResponse;
import spring.db.dbbenchmark.room.service.ChecklistService;

@Service
@RequiredArgsConstructor
public class FindRoomsUseCase {

    private final ChecklistService checklistService;

    public Page<RoomWithChecklistResponse> execute(ChecklistFilterRequest filterRequest, Pageable pageable) {
        return checklistService.findChecklistsByFilter(filterRequest, pageable);
    }
}
