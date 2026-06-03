set search_path to public, auth;

/*Récupération des réservations*/
create or replace function get_reservations()
    returns setof client_reservation as
$$
begin
    perform auth.check_logged();

    return query
        select
            r.id,
            r.client,
            r.restaurant,
            rest.name,
            rest.address,
            rest.city,
            rest.phone,
            r.datetime,
            r.number_of_guests,
            r.status,
            r.special_requests
        from reservations r
                 join restaurants rest on rest.id = r.restaurant
        where r.client = auth.id()
        order by r.datetime desc;
end;
$$ language plpgsql security definer;

grant execute on function get_reservations() to client;

notify pgrst, 'reload schema';







drop function if exists get_client_reservation_slots(integer, date, integer);
drop function if exists get_client_reservation_slots(integer, date, integer, integer);

create or replace function get_client_reservation_slots(
    p_restaurant integer,
    p_date date,
    p_number_of_guests integer,
    p_ignored_reservation integer default null
)
    returns setof reservation_slot_info as
$$
begin
    perform auth.check_logged();

    if p_ignored_reservation is not null
        and not exists (
            select 1
            from reservations r
            where r.id = p_ignored_reservation
              and r.client = auth.id()
              and r.restaurant = p_restaurant
        )
    then
        raise exception 'La réservation à ignorer est invalide.';
    end if;

    return query
        with restaurant_info as (
            select r.slot_duration
            from restaurants r
            where r.id = p_restaurant
        ),
             slots as (
                 select
                     gs.slot_datetime,
                     gs.slot_datetime::time as slot_time
                 from services s
                          join restaurant_info ri on true
                          cross join lateral generate_series(
                         (p_date + s.start_time)::timestamp,
                         (p_date + s.end_time)::timestamp - make_interval(mins => ri.slot_duration),
                         make_interval(mins => ri.slot_duration)
                                             ) as gs(slot_datetime)
                 where s.restaurant = p_restaurant
                   and s.day_of_week = extract(isodow from p_date)::int
             ),
             slots_without_duplicate_service as (
                 select sl.*
                 from slots sl
                 where sl.slot_datetime >= get_current_time()
                   and not exists (
                     select 1
                     from reservations r
                              join services s
                                   on s.restaurant = r.restaurant
                                       and s.day_of_week = extract(isodow from r.datetime)::int
                                       and r.datetime::time >= s.start_time
                                       and r.datetime::time < s.end_time
                     where r.client = auth.id()
                       and r.restaurant = p_restaurant
                       and r.datetime::date = p_date
                       and r.status in ('pending', 'confirmed', 'completed')
                       and (p_ignored_reservation is null or r.id <> p_ignored_reservation)
                       and sl.slot_time >= s.start_time
                       and sl.slot_time < s.end_time
                 )
             )
        select
            sl.slot_datetime,
            to_char(sl.slot_time, 'HH24:MI') as slot_time,
            (
                select coalesce(sum(t.capacity), 0)
                from tables t
                where t.restaurant = p_restaurant
                  and not exists (
                    select 1
                    from reservation_tables rt
                             join reservations r on r.id = rt.reservation
                             join services s
                                  on s.restaurant = r.restaurant
                                      and s.day_of_week = extract(isodow from r.datetime)::int
                                      and r.datetime::time >= s.start_time
                                      and r.datetime::time < s.end_time
                    where rt."table" = t.id
                      and r.status in ('confirmed', 'completed')
                      and r.datetime::date = p_date
                      and (p_ignored_reservation is null or r.id <> p_ignored_reservation)
                      and sl.slot_time >= s.start_time
                      and sl.slot_time < s.end_time
                )
            ) >= p_number_of_guests as has_enough_capacity
        from slots_without_duplicate_service sl
        order by sl.slot_datetime;
end;
$$ language plpgsql security definer;

grant execute on function get_client_reservation_slots(integer, date, integer, integer) to client;

notify pgrst, 'reload schema';



drop function if exists create_client_reservation(integer, timestamp, integer, text);

drop function if exists create_client_reservation(integer, timestamp, integer, text);

create or replace function create_client_reservation(
    p_restaurant integer,
    p_datetime timestamp,
    p_number_of_guests integer,
    p_special_requests text default null
)
    returns client_reservation as
$$
declare
    v_reservation_id integer;
    v_reservation client_reservation;
begin
    perform auth.check_logged();

    insert into reservations (
        client,
        restaurant,
        datetime,
        number_of_guests,
        status,
        special_requests
    )
    values (
               auth.id(),
               p_restaurant,
               p_datetime,
               p_number_of_guests,
               'pending',
               nullif(trim(p_special_requests), '')
           )
    returning id into v_reservation_id;

    select
        r.id,
        r.client,
        r.restaurant,
        rest.name,
        rest.address,
        rest.city,
        rest.phone,
        r.datetime,
        r.number_of_guests,
        r.status,
        r.special_requests
    into v_reservation
    from reservations r
             join restaurants rest on rest.id = r.restaurant
    where r.id = v_reservation_id
      and r.client = auth.id();

    return v_reservation;
end;
$$ language plpgsql security definer;

grant execute on function create_client_reservation(integer, timestamp, integer, text) to client;

notify pgrst, 'reload schema';






drop function if exists update_client_reservation(integer, timestamp, integer, text);

create or replace function update_client_reservation(
    p_reservation integer,
    p_datetime timestamp,
    p_number_of_guests integer,
    p_special_requests text default null
)
    returns client_reservation as
$$
declare
    v_old_reservation reservations%rowtype;
    v_reservation client_reservation;
begin
    perform auth.check_logged();

    select *
    into v_old_reservation
    from reservations r
    where r.id = p_reservation
      and r.client = auth.id()
        for update;

    if not found then
        raise exception 'Réservation introuvable.';
    end if;

    if v_old_reservation.status::text not in ('pending', 'confirmed') then
        raise exception 'Cette réservation ne peut plus être modifiée.';
    end if;

    if v_old_reservation.datetime <= get_current_time() then
        raise exception 'Une réservation passée ne peut plus être modifiée.';
    end if;

    update reservations
    set datetime = p_datetime,
        number_of_guests = p_number_of_guests,
        special_requests = nullif(trim(p_special_requests), ''),
        status = 'pending'
    where id = p_reservation
      and client = auth.id();

    select
        r.id,
        r.client,
        r.restaurant,
        rest.name,
        rest.address,
        rest.city,
        rest.phone,
        r.datetime,
        r.number_of_guests,
        r.status,
        r.special_requests
    into v_reservation
    from reservations r
             join restaurants rest on rest.id = r.restaurant
    where r.id = p_reservation
      and r.client = auth.id();

    return v_reservation;
end;
$$ language plpgsql security definer;

grant execute on function update_client_reservation(integer, timestamp, integer, text) to client;

notify pgrst, 'reload schema';
