set search_path to public;

/* -------------------------------------------------------------------------
   (BR-08) Au moment de leur création ou de leur modification, les heures
   de début et de fin d'un service doivent être alignées sur les créneaux
   de réservation pour le restaurant.
   ------------------------------------------------------------------------- */

/*
Tables concernées :
- services :
    - insert : oui (l'ajout d'un nouveau service doit respecter l'alignement des créneaux)
    - update : oui (la modification des horaires d'un service existant doit respecter l'alignement)
    - delete : non (supprimer un service n'enfreint pas la règle)
- restaurants :
    - insert : non
    - update : non (la règle s'applique spécifiquement sur la table services au moment de leur création/modification)
    - delete : non
*/

create or replace function check_service_time_alignment()
    returns trigger as $$
declare
    rest_slot_duration int;
    start_min int;
    end_min int;
    start_sec int;
    end_sec int;
begin
    -- 1. Récupération de la durée du créneau du restaurant
    select slot_duration into rest_slot_duration
    from restaurants
    where id = new.restaurant;

    -- 2. Extraction des minutes et des secondes
    start_min := extract(minute from new.start_time)::int;
    end_min := extract(minute from new.end_time)::int;
    start_sec := extract(second from new.start_time)::int;
    end_sec := extract(second from new.end_time)::int;

    -- 3. Vérification de l'alignement strict (0 seconde, et minutes multiples du créneau)
    if (start_sec != 0) or (end_sec != 0) or
       (start_min % rest_slot_duration != 0) or (end_min % rest_slot_duration != 0) then

        raise exception 'Les heures de service doivent être alignées sur les créneaux de % minutes du restaurant (secondes à 0).', rest_slot_duration;
    end if;

    return new;
end;
$$ language plpgsql;

/* -------------------------------------------------------------------------
   TRIGGER
   ------------------------------------------------------------------------- */
drop trigger if exists trg_check_service_time_alignment on services;
create trigger trg_check_service_time_alignment
    before insert or update of restaurant, start_time, end_time
    on services
    for each row
execute function check_service_time_alignment();