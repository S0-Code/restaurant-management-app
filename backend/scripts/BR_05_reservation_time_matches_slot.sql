set search_path to public;

/*
(BR-05) Au moment de sa création ou de sa modification,
l'heure d'une réservation doit correspondre à un créneau de
réservation (slot) pour le restaurant. Un créneau de réservation
doit toujours correspondre à une heure exacte (sans minutes)
augmentéed'un multiple de la durée du créneau de réservation.

Tables concernées :
-reservations :
    -insert : oui
    -update : oui si on change datetime
    -delete : non
-restaurants :
    -insert : non car pas de résa pour ce resto
    -update : oui si on change slot_duration
    -delete : non car delete en cascade
*/

select r.id, r.restaurant, r.datetime
from reservations r
where exists(
    select 1
    from restaurants rest
    where rest.id = r.restaurant AND
          (
          extract(minute from r.datetime::time)::int  % rest.slot_duration <> 0
              OR
            extract(second from r.datetime)::int <> 0
        )
);

create or replace function check_reservation_time_matches_slot_duration()
    returns trigger as
$$
begin
    if exists(select r.id, r.restaurant, r.datetime
              from reservations r
              where exists(
                  select 1
                  from restaurants rest
                  where rest.id = r.restaurant AND
                      (
                          extract(minute from r.datetime::time)::int  % rest.slot_duration <> 0
                              OR
                          extract(second from r.datetime)::int <> 0
                          )
              ))
    then
        raise exception 'L''heure d''une réservation doit correspondre à un créneau de réservation pour le restaurant';
    end if;

    return null;
end;
$$ language plpgsql security definer;

create trigger trigger_reservation_time_matches_slot_duration_on_reservations
    after insert or update of datetime
    on reservations
    for each row
execute function check_reservation_time_matches_slot_duration();

create trigger trigger_reservation_time_matches_slot_duration_on_restaurants
    after update of slot_duration
    on restaurants
    for each row
execute function check_reservation_time_matches_slot_duration();