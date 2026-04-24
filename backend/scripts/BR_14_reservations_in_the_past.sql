/*
(BR-14) Une réservation ne peut pas être créée dans le passé
(ne doit être vérifié qu'au moment de la création).
*/

create or replace function get_current_time()
    returns timestamp as
$$
declare
    simulated timestamp;
begin
    select simulated_time into simulated
    from system_time;

    if simulated is not null then
            return simulated;
    else
            return current_timestamp;
    end if;
end;
$$ language plpgsql security definer;


create or replace function check_reservation_is_in_the_future()
    returns trigger as
$$
begin
    if new.datetime < get_current_time()
    then
        raise exception 'Les réservations ne peuvent pas être dans le passé';
    end if;

    return new;
end;
$$ language plpgsql security definer;

create trigger trigger_prevent_reservation_in_the_past
    before insert
    on reservations
    for each row
execute function check_reservation_is_in_the_future();