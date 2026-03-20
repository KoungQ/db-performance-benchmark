package spring.db.dbbenchmark.room.repository;

import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.BooleanExpression;
import com.querydsl.core.types.dsl.Expressions;
import com.querydsl.jpa.impl.JPAQuery;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;
import spring.db.dbbenchmark.room.dto.request.ChecklistFilterRequest;
import spring.db.dbbenchmark.room.dto.response.ChecklistSummaryResponse;
import spring.db.dbbenchmark.room.dto.response.RoomWithChecklistResponse;
import spring.db.dbbenchmark.room.entity.QChecklist;

import java.util.ArrayList;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class ChecklistQueryRepositoryImpl implements ChecklistQueryRepository {

    private final JPAQueryFactory queryFactory;

    private static final QChecklist c = QChecklist.checklist;

    @Override
    public Page<RoomWithChecklistResponse> findChecklistsByFilter(ChecklistFilterRequest filter, Pageable pageable) {
        BooleanExpression where = buildWhere(filter);

        JPAQuery<RoomWithChecklistResponse> query = queryFactory
                .select(Projections.constructor(
                        RoomWithChecklistResponse.class,
                        c.room.roomNo,
                        c.room.title,
                        c.room.roomType,
                        c.room.roomStatus,
                        c.room.residencePeriod,
                        c.room.capacity,
                        c.room.currentMateCount,
                        Projections.constructor(
                                ChecklistSummaryResponse.class,
                                c.checklistNo,
                                c.bedtime,
                                c.wakeUp,
                                c.returnHome,
                                c.returnHomeTime,
                                c.cleaning,
                                c.phoneCall,
                                c.sleepLight,
                                c.sleepHabit,
                                c.snoring,
                                c.showerTime,
                                c.eating,
                                c.lightsOut,
                                c.lightsOutTime,
                                c.homeVisit,
                                c.smoking,
                                c.refrigerator,
                                c.createdAt,
                                c.updatedAt
                        )
                ))
                .from(c)
                .join(c.room)
                .where(where);

        ChecklistFilterRequest.SortType sortType = filter.sortType() != null ? filter.sortType() : ChecklistFilterRequest.SortType.LATEST;
        if (sortType == ChecklistFilterRequest.SortType.REMAINING) {
            query.orderBy(c.room.capacity.subtract(c.room.currentMateCount).desc(), c.room.roomNo.desc());
        } else {
            query.orderBy(c.updatedAt.desc());
        }

        List<RoomWithChecklistResponse> content = query
                .offset(pageable.getOffset())
                .limit(pageable.getPageSize())
                .fetch();

        long total = queryFactory
                .selectFrom(c)
                .join(c.room)
                .where(where)
                .fetchCount();

        return new PageImpl<>(content, pageable, total);
    }

    private BooleanExpression buildWhere(ChecklistFilterRequest filter) {
        List<BooleanExpression> conditions = new ArrayList<>();
        addIfPresent(conditions, eqIfPresent(c.room.roomType, filter.roomType()));
        addIfPresent(conditions, eqIfPresent(c.room.residencePeriod, filter.residencePeriod()));
        addIfPresent(conditions, eqIfPresent(c.room.capacity, filter.capacity()));
        addIfPresent(conditions, eqIfPresent(c.bedtime, filter.bedtime()));
        addIfPresent(conditions, eqIfPresent(c.wakeUp, filter.wakeUp()));
        addIfPresent(conditions, eqIfPresent(c.returnHome, filter.returnHome()));
        addIfPresent(conditions, eqIfPresent(c.returnHomeTime, filter.returnHomeTime()));
        addIfPresent(conditions, eqIfPresent(c.cleaning, filter.cleaning()));
        addIfPresent(conditions, eqIfPresent(c.phoneCall, filter.phoneCall()));
        addIfPresent(conditions, eqIfPresent(c.sleepLight, filter.sleepLight()));
        addIfPresent(conditions, eqIfPresent(c.sleepHabit, filter.sleepHabit()));
        addIfPresent(conditions, eqIfPresent(c.snoring, filter.snoring()));
        addIfPresent(conditions, eqIfPresent(c.showerTime, filter.showerTime()));
        addIfPresent(conditions, eqIfPresent(c.eating, filter.eating()));
        addIfPresent(conditions, eqIfPresent(c.lightsOut, filter.lightsOut()));
        addIfPresent(conditions, eqIfPresent(c.lightsOutTime, filter.lightsOutTime()));
        addIfPresent(conditions, eqIfPresent(c.homeVisit, filter.homeVisit()));
        addIfPresent(conditions, eqIfPresent(c.smoking, filter.smoking()));
        addIfPresent(conditions, eqIfPresent(c.refrigerator, filter.refrigerator()));
        addIfPresent(conditions, eqIfPresent(c.hairDryer, filter.hairDryer()));
        addIfPresent(conditions, eqIfPresent(c.alarm, filter.alarm()));
        addIfPresent(conditions, eqIfPresent(c.earphone, filter.earphone()));
        addIfPresent(conditions, eqIfPresent(c.keyskin, filter.keyskin()));
        addIfPresent(conditions, eqIfPresent(c.heat, filter.heat()));
        addIfPresent(conditions, eqIfPresent(c.cold, filter.cold()));
        addIfPresent(conditions, eqIfPresent(c.study, filter.study()));
        addIfPresent(conditions, eqIfPresent(c.trashCan, filter.trashCan()));

        if (conditions.isEmpty()) return Expressions.TRUE;
        return conditions.stream().reduce(BooleanExpression::and).orElse(Expressions.TRUE);
    }

    private void addIfPresent(List<BooleanExpression> list, BooleanExpression expr) {
        if (expr != null) list.add(expr);
    }

    private BooleanExpression eqIfPresent(com.querydsl.core.types.dsl.StringPath path, String value) {
        return value != null && !value.isBlank() ? path.eq(value) : null;
    }

    private <T extends Comparable<?>> BooleanExpression eqIfPresent(com.querydsl.core.types.dsl.ComparableExpressionBase<T> path, T value) {
        return value != null ? path.eq(value) : null;
    }
}
