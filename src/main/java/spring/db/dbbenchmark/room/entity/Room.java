package spring.db.dbbenchmark.room.entity;

import jakarta.persistence.*;
import lombok.*;
import spring.db.dbbenchmark.room.dto.request.RoomUpdateRequest;
import spring.db.dbbenchmark.room.entity.enums.ResidencePeriod;
import spring.db.dbbenchmark.room.entity.enums.RoomStatus;
import spring.db.dbbenchmark.room.entity.enums.RoomType;

@Entity
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PROTECTED)
public class Room {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long roomNo;

    @Column(nullable = false)
    private String title;

    // Room Metadata
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RoomType roomType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RoomStatus roomStatus;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private ResidencePeriod residencePeriod;

    @Column(nullable = false)
    private Integer capacity;

    @Column(name = "current_mate_count", nullable = false)
    private Integer currentMateCount;

    public void update(RoomUpdateRequest request) {
        this.title = request.title();
        this.roomType = request.roomType();
        this.roomStatus = request.roomStatus();
        this.residencePeriod = request.residencePeriod();
        this.capacity = request.capacity();
    }
}
