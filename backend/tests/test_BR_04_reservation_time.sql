set search_path to public;

/*(BR-04) L'heure d'une réservation confirmée,
terminée ou en attente doit être comprise entre
l'heure de début et l'heure de fin d'un service pour
le même jour de la semaine.*/

-- 1) INSERT correct : réservation pendant un service existant
begin;
do
$test$
declare
        client_id bigint;
        restaurant_id bigint;
begin
        raise notice 'TEST: Heure de réservation comprise dans un service correct (insert)';

insert into users (email, full_name, password, role)
values ('client_br04_insert_ok@test.com', 'Client BR-04 OK', 'Password123.', 'client')
    returning id into client_id;

insert into restaurants (name, address, city, phone)
values ('Restaurant BR-04 Insert OK', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 12')
    returning id into restaurant_id;

insert into services (restaurant, day_of_week, start_time, end_time)
values (restaurant_id, 7, '18:00:00', '23:00:00');

insert into reservations (client, restaurant, number_of_guests, datetime)
values (client_id, restaurant_id, 2, '2026-11-15 19:00:00.000000');
end;
$test$;
rollback;


-- 2) INSERT incorrect : réservation hors service existant
begin;
do $test$
    declare
client_id bigint;
        restaurant_id bigint;
begin
        raise notice 'TEST: Heure de réservation hors service incorrect (insert)';

insert into users (email, full_name, password, role)
values ('client_br04_insert_ko@test.com', 'Client BR-04 KO', 'Password123.', 'client')
    returning id into client_id;

insert into restaurants (name, address, city, phone)
values ('Restaurant BR-04 Insert KO', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 13')
    returning id into restaurant_id;

insert into services (restaurant, day_of_week, start_time, end_time)
values (restaurant_id, 7, '18:00:00', '23:00:00');

perform should_fail($$
            insert into reservations (client, restaurant, number_of_guests, datetime)
            values ($$ || client_id || $$, $$ || restaurant_id || $$, 2, '2026-11-15 15:00:00.000000')
        $$, 'P0001');
end;
$test$;
rollback;


-- 3) UPDATE correct : modification vers une heure comprise dans un service
begin;
do $test$
    declare
client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
begin
        raise notice 'TEST: Heure de réservation comprise dans un service correct (update)';

insert into users (email, full_name, password, role)
values ('client_br04_update_ok@test.com', 'Client BR-04 Update OK', 'Password123.', 'client')
    returning id into client_id;

insert into restaurants (name, address, city, phone)
values ('Restaurant BR-04 Update OK', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 14')
    returning id into restaurant_id;

insert into services (restaurant, day_of_week, start_time, end_time)
values (restaurant_id, 7, '18:00:00', '23:00:00');

insert into reservations (client, restaurant, number_of_guests, datetime)
values (client_id, restaurant_id, 2, '2026-11-15 19:00:00.000000')
    returning id into reservation_id;

update reservations
set datetime = '2026-11-15 20:00:00.000000'
where id = reservation_id;
end;
$test$;
rollback;


-- 4) UPDATE incorrect : modification vers une heure hors service
begin;
do $test$
    declare
client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
begin
        raise notice 'TEST: Heure de réservation hors service incorrect (update)';

insert into users (email, full_name, password, role)
values ('client_br04_update_ko@test.com', 'Client BR-04 Update KO', 'Password123.', 'client')
    returning id into client_id;

insert into restaurants (name, address, city, phone)
values ('Restaurant BR-04 Update KO', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 15')
    returning id into restaurant_id;

insert into services (restaurant, day_of_week, start_time, end_time)
values (restaurant_id, 7, '18:00:00', '23:00:00');

insert into reservations (client, restaurant, number_of_guests, datetime)
values (client_id, restaurant_id, 2, '2026-11-15 19:00:00.000000')
    returning id into reservation_id;

perform should_fail($$
            update reservations
            set datetime = '2026-11-15 15:00:00.000000'
            where id = $$ || reservation_id ||
        $$$$, 'raise_exception');
end;
$test$;
rollback;