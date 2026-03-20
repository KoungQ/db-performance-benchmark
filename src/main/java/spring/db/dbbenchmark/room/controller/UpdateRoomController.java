package spring.db.dbbenchmark.room.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import spring.db.dbbenchmark.room.dto.request.RoomUpdateRequest;
import spring.db.dbbenchmark.room.usecase.UpdateRoomUseCase;

@RestController
@RequiredArgsConstructor
public class UpdateRoomController {

    private final UpdateRoomUseCase updateRoomUseCase;

    @PatchMapping("/rdb/update")
    public ResponseEntity<Void> update(
            @RequestParam Long roomNo,
            @Valid @RequestBody RoomUpdateRequest request
    ) {
        updateRoomUseCase.execute(roomNo, request);
        return ResponseEntity.noContent().build();
    }
}
