package spring.db.dbbenchmark.room.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import spring.db.dbbenchmark.room.dto.request.UpdateChecklistRequest;
import spring.db.dbbenchmark.room.entity.enums.*;

import java.time.LocalDateTime;

@Entity
@EntityListeners(AuditingEntityListener.class)
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PROTECTED)
public class Checklist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long checklistNo;

    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.REMOVE)
    @JoinColumn(name = "room_no", nullable = false)
    private Room room;

    // 생활 패턴
    @Column(name = "bedtime", nullable = false)
    private String bedtime;

    @Column(name = "wake_up", nullable = false)
    private String wakeUp;

    @Enumerated(EnumType.STRING)
    @Column(name = "return_home", nullable = false)
    private ReturnHomeType returnHome;

    @Column(name = "return_home_time", nullable = false)
    private String returnHomeTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "cleaning", nullable = false)
    private CleaningType cleaning;

    @Enumerated(EnumType.STRING)
    @Column(name = "phone_call", nullable = false)
    private PhoneCallType phoneCall;

    @Enumerated(EnumType.STRING)
    @Column(name = "sleep_light", nullable = false)
    private SleepLightType sleepLight;

    @Enumerated(EnumType.STRING)
    @Column(name = "sleep_habit", nullable = false)
    private SleepHabitType sleepHabit;

    @Enumerated(EnumType.STRING)
    @Column(name = "snoring", nullable = false)
    private SnoringType snoring;

    @Enumerated(EnumType.STRING)
    @Column(name = "shower_time", nullable = false)
    private ShowerTimeType showerTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "eating", nullable = false)
    private EatingType eating;

    @Enumerated(EnumType.STRING)
    @Column(name = "lights_out", nullable = false)
    private LightsOutType lightsOut;

    @Column(name = "lights_out_time", nullable = false)
    private String lightsOutTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "home_visit", nullable = false)
    private HomeVisitType homeVisit;

    @Enumerated(EnumType.STRING)
    @Column(name = "smoking", nullable = false)
    private SmokingType smoking;

    @Enumerated(EnumType.STRING)
    @Column(name = "refrigerator", nullable = false)
    private RefrigeratorType refrigerator;

    // 추가 규칙
    @Column(name = "hair_dryer")
    private String hairDryer;

    @Enumerated(EnumType.STRING)
    @Column(name = "alarm")
    private AlarmType alarm;

    @Enumerated(EnumType.STRING)
    @Column(name = "earphone")
    private EarphoneType earphone;

    @Enumerated(EnumType.STRING)
    @Column(name = "keyskin")
    private KeyskinType keyskin;

    @Enumerated(EnumType.STRING)
    @Column(name = "heat")
    private HeatType heat;

    @Enumerated(EnumType.STRING)
    @Column(name = "cold")
    private ColdType cold;

    @Enumerated(EnumType.STRING)
    @Column(name = "study")
    private StudyType study;

    @Enumerated(EnumType.STRING)
    @Column(name = "trash_can")
    private TrashCanType trashCan;

    @Column(name = "other_notes", columnDefinition = "TEXT")
    private String otherNotes;

    @CreatedDate
    @Column(name = "created_at", updatable = false, nullable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public void update(UpdateChecklistRequest request) {
        this.bedtime = request.bedtime();
        this.wakeUp = request.wakeUp();
        this.returnHome = request.returnHome();
        this.returnHomeTime = request.returnHomeTime();
        this.cleaning = request.cleaning();
        this.phoneCall = request.phoneCall();
        this.sleepLight = request.sleepLight();
        this.sleepHabit = request.sleepHabit();
        this.snoring = request.snoring();
        this.showerTime = request.showerTime();
        this.eating = request.eating();
        this.lightsOut = request.lightsOut();
        this.lightsOutTime = request.lightsOutTime();
        this.homeVisit = request.homeVisit();
        this.smoking = request.smoking();
        this.refrigerator = request.refrigerator();
        this.hairDryer = request.hairDryer();
        this.alarm = request.alarm();
        this.earphone = request.earphone();
        this.keyskin = request.keyskin();
        this.heat = request.heat();
        this.cold = request.cold();
        this.study = request.study();
        this.trashCan = request.trashCan();
        this.otherNotes = request.otherNotes();
    }
}
