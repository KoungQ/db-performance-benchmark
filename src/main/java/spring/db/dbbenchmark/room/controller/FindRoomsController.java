package spring.db.dbbenchmark.room.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import spring.db.dbbenchmark.room.dto.request.ChecklistFilterRequest;
import spring.db.dbbenchmark.room.dto.response.RoomWithChecklistResponse;
import spring.db.dbbenchmark.room.usecase.FindRoomsUseCase;

@RestController
@RequiredArgsConstructor
public class FindRoomsController {

    private final FindRoomsUseCase findRoomsUseCase;

    @PostMapping("/rdb/select")
    public ResponseEntity<Page<RoomWithChecklistResponse>> load(
            @RequestBody ChecklistFilterRequest filterRequest,
            @PageableDefault(size = 20) Pageable pageable
    ) {
        return ResponseEntity.ok(findRoomsUseCase.execute(filterRequest, pageable));
    }
}
