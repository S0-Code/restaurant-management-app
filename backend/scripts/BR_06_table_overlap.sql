set search_path to public;

/* -------------------------------------------------------------------------
   (BR-06) : Une table ne peut pas faire l'objet de deux réservations terminées
   ou confirmées pour une même date et un même service.
   ------------------------------------------------------------------------- */

-- 1. Fonction spécifique pour la table 'reservation_tables'
create or replace function check_tables_availability_on_rt() returns trigger as $$
begin
    if exists (
        select 1
        from reservation_tables rt1
                 join reservations r1 on rt1.reservation = r1.id
                 join reservation_tables rt2 on rt1."table" = rt2."table"
                 join reservations r2 on rt2.reservation = r2.id
        where r1.id != r2.id
          and r1.status in ('confirmed'::status_type, 'completed'::status_type)
          and r2.status in ('confirmed'::status_type, 'completed'::status_type)
          and r1.datetime::date = r2.datetime::date
          and (r1.id = new.reservation OR r2.id = new.reservation)
          and exists (
            select 1 from services s
            where s.restaurant = r1.restaurant
              and s.day_of_week = extract(isodow from r1.datetime::date)::int
              and s.start_time <= r1.datetime::time and s.end_time > r1.datetime::time
              and s.start_time <= r2.datetime::time and s.end_time > r2.datetime::time
        )
    ) then
        raise exception 'Une table ne peut pas faire l''objet de deux réservations terminées ou confirmées pour une même date et un même service.';
    end if;

    return null;
end;
$$ language plpgsql security definer;

-- 2. Fonction spécifique pour la table 'reservations'
create or replace function check_tables_availability_on_res() returns trigger as $$
begin
    if exists (
        select 1
        from reservation_tables rt1
                 join reservations r1 on rt1.reservation = r1.id
                 join reservation_tables rt2 on rt1."table" = rt2."table"
                 join reservations r2 on rt2.reservation = r2.id
        where r1.id != r2.id
          and r1.status in ('confirmed'::status_type, 'completed'::status_type)
          and r2.status in ('confirmed'::status_type, 'completed'::status_type)
          and r1.datetime::date = r2.datetime::date
          and (r1.id = new.id OR r2.id = new.id)
          and exists (
            select 1 from services s
            where s.restaurant = r1.restaurant
              and s.day_of_week = extract(isodow from r1.datetime::date)::int
              and s.start_time <= r1.datetime::time and s.end_time > r1.datetime::time
              and s.start_time <= r2.datetime::time and s.end_time > r2.datetime::time
        )
    ) then
        raise exception 'Une table ne peut pas faire l''objet de deux réservations terminées ou confirmées pour une même date et un même service.';
    end if;
    return null;
end;
$$ language plpgsql security definer;

-- 3. Déclaration des Triggers
drop trigger if exists trg_check_table_availability_on_reservation_tables on reservation_tables;
create constraint trigger trg_check_table_availability_on_reservation_tables
    after insert on reservation_tables
    deferrable initially deferred
    for each row
execute function check_tables_availability_on_rt();

drop trigger if exists trg_check_table_availability_on_reservations on reservations;
create constraint trigger trg_check_table_availability_on_reservations
    after update of status, datetime on reservations
    deferrable initially deferred
    for each row
execute function check_tables_availability_on_res();