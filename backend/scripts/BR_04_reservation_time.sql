set search_path to public;

/*
(BR-04) L'heure d'une réservation confirmée,
terminée ou en attente doit être comprise entre
l'heure de début et l'heure de fin d'un service pour
le même jour de la semaine.

Tables concernées :
- services :
    -insert : non car pas encore de resa pour ce service au moment de la création du service
    -update : non car clé primaire
    -delete : non
- reservations :
    -insert : oui, ex : insert heure où pas de service
    -update : oui si on change l'heure
    -delete : non
*/
select r.id, r.datetime, r.status, extract(isodow from r.datetime) as day
from reservations r
where r.status in ('pending'::status_type, 'completed'::status_type, 'confirmed'::status_type)
  and not exists (
    select 1
    from services s
    where s.restaurant = r.restaurant
      and s.day_of_week = extract(isodow from r.datetime)
      and r.datetime::time between s.start_time and s.end_time
);

create or replace function check_reservation_time_within_service()
    returns trigger as
$$
begin
    if exists(select r.id, r.datetime, r.status, extract(isodow from r.datetime) as day
              from reservations r
              where r.status in ('pending'::status_type, 'completed'::status_type, 'confirmed'::status_type)
                and not exists (
                  select 1
                  from services s
                  where s.restaurant = r.restaurant
                    and s.day_of_week = extract(isodow from r.datetime)
                    and r.datetime::time >= s.start_time
                    and r.datetime::time < s.end_time
              ))
    then
        raise exception 'Les réservations ''pending'' ''confirmed'' et ''completed'' doivent avoir lieu durant un service existant dans ce restaurant pour le jour de la réservation';
    end if;

    return null;
end;
$$ language plpgsql security definer;

create trigger trigger_reservation_time_within_service
    after insert or update of datetime, status
    on reservations
    for each row
execute function check_reservation_time_within_service();
