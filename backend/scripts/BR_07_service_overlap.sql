set search_path to public;

/* (BR-07) Pour un même jour de la semaine,
   les services d'un restaurant ne peuvent pas se chevaucher. */

/*
Tables concernées :
- services :
    - insert : oui (l'ajout d'un nouveau service pourrait empiéter sur les horaires d'un service existant ce jour-là)
    - update : oui (la modification de l'heure de début, l'heure de fin, ou du jour d'un service existant pourrait créer un chevauchement)
    - delete : non (supprimer un service libère de la place, cela ne peut en aucun cas créer un chevauchement)

*/
create or replace function check_service_overlap()
    returns trigger as
$$
begin

    if exists (select 1
               from services s
               where restaurant = new.restaurant
                 and day_of_week = new.day_of_week
                 and s.id <> new.id
                 and new.start_time < end_time
                 and new.end_time > start_time) then
        raise exception 'Ce service se chevauche avec un autre service existant pour ce restaurant ce jour-là.';
    end if;

    return new;
end;
$$ language plpgsql;

/* -------------------------------------------------------------------------
   TRIGGER
   ------------------------------------------------------------------------- */
drop trigger if exists trg_check_service_overlap on services;
create trigger trg_check_service_overlap
    before insert or update of day_of_week, start_time, end_time
    on services
    for each row
execute function check_service_overlap();