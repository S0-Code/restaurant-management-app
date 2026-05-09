set search_path to public;

/* -------------------------------------------------------------------------
   TESTS BR-07 : Pour un même jour de la semaine,
   les services d'un restaurant ne peuvent pas se chevaucher.
   ------------------------------------------------------------------------- */

/* 1. Insert correct : même jour, même resto, services côte à côte */
begin;
do $test$
    declare
        restaurant_id bigint;
    begin
        raise notice 'TEST BR-07: Services côte à côte correct (insert)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR07 OK', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 10', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 1, '12:00', '14:00');

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 1, '14:00', '16:00');
    end;
$test$;
rollback;


/* 2. Insert incorrect : même jour, même resto, chevauchement */
begin;
do $test$
    declare
        restaurant_id bigint;
    begin
        raise notice 'TEST BR-07: Chevauchement incorrect (insert)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR07 BAD', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 11', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 1, '12:00', '14:00');

        perform should_fail($$
            insert into services (restaurant, day_of_week, start_time, end_time)
            values ($$ || restaurant_id || $$, 1, '13:00', '15:00')
        $$, 'raise_exception');
    end;
$test$;
rollback;


/* 3. Update correct : modification sans chevauchement */
begin;
do $test$
    declare
        restaurant_id bigint;
        service_id bigint;
    begin
        raise notice 'TEST BR-07: Modification sans chevauchement correct (update)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR07 UP OK', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 1, '12:00', '14:00');

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 1, '16:00', '18:00')
        returning id into service_id;

        update services
        set start_time = '14:00',
            end_time = '16:00'
        where id = service_id;
    end;
$test$;
rollback;


/* 4. Update incorrect : modification qui crée un chevauchement */
begin;
do $test$
    declare
        restaurant_id bigint;
        service_id bigint;
    begin
        raise notice 'TEST BR-07: Modification avec chevauchement incorrect (update)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR07 UP BAD', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 13', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 1, '12:00', '14:00');

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 1, '16:00', '18:00')
        returning id into service_id;

        perform should_fail($$
            update services
            set start_time = '13:00',
                end_time = '17:00'
            where id = $$ || service_id
            , 'raise_exception');
    end;
$test$;
rollback;