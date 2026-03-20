package spring.db.dbbenchmark.room.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import spring.db.dbbenchmark.room.dto.request.CreateRoomRequest;
import spring.db.dbbenchmark.room.dto.response.CreateRoomResponse;
import spring.db.dbbenchmark.room.usecase.CreateRoomUseCase;

@RestController
@RequiredArgsConstructor
public class CreateRoomController {

    private final CreateRoomUseCase createRoomUseCase;

    @PostMapping("/rdb/insert")
    public ResponseEntity<CreateRoomResponse> create(@Valid @RequestBody CreateRoomRequest request) {
        return ResponseEntity.ok(createRoomUseCase.execute(request));
    }
}
