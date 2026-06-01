set search_path to public;

/* -------------------------------------------------------------------------
   (BR-13) Un client ne peut pas avoir deux réservations en attente,
   confirmées ou terminées pour une même date et un même service.
   ------------------------------------------------------------------------- */

create or replace function check_br13_client_duplicate()
    returns trigger as $$
declare
v_new_service_id int;
begin
    -- On applique la règle uniquement si la réservation est active
    if new.status::text in ('pending', 'confirmed', 'completed') then

        -- 1. Trouver le service correspondant à la nouvelle réservation
select id into v_new_service_id
from services
where restaurant = new.restaurant
  and day_of_week = extract(isodow from new.datetime)
  and new.datetime::time >= start_time
          and new.datetime::time <= end_time;

if v_new_service_id is not null then

            -- 2. Vérifier s'il existe une autre réservation pour ce même service
            if exists (
                select 1
                from reservations r
                join services s on r.restaurant = s.restaurant
                    and s.day_of_week = extract(isodow from r.datetime)
                    and r.datetime::time >= s.start_time
                    and r.datetime::time <= s.end_time
                where r.client = new.client
                  and r.datetime::date = new.datetime::date
                  and r.status::text in ('pending', 'confirmed', 'completed')
                  and (new.id is null or r.id != new.id)
                  and s.id = v_new_service_id
            ) then
                raise exception 'BR-13 : Un client ne peut pas avoir deux réservations pour le même service à la même date.';
end if;

end if;
end if;

return new;
end;
$$ language plpgsql;

/* -------------------------------------------------------------------------
   TRIGGER
   ------------------------------------------------------------------------- */
drop trigger if exists trg_br13_client_duplicate on reservations;
create trigger trg_br13_client_duplicate
    before insert or update on reservations
                         for each row
                         execute function check_br13_client_duplicate();