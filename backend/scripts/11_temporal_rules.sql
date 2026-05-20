set search_path to public;

/* -------------------------------------------------------------------------
   FONCTION SPÉCIFIQUE : Vérification des transitions de statut
   ------------------------------------------------------------------------- */

create or replace function check_reservation_status_transition()
returns trigger as $$
begin
    -- On cible spécifiquement le passage de 'confirmed' à 'pending'
    if old.status = 'confirmed' and new.status = 'pending' then

        -- On vérifie si la réservation est dans le passé par rapport à l'instant T
        if new.datetime <= get_current_time() then
            raise exception 'Une réservation passée ou en cours ne peut pas repasser au statut "pending".';
end if;

end if;

return new;
end;
$$ language plpgsql;

/* -------------------------------------------------------------------------
   TRIGGER
   ------------------------------------------------------------------------- */

drop trigger if exists trg_reservation_status_transition on reservations;
create trigger trg_reservation_status_transition
    before update on reservations
    for each row
    execute function check_reservation_status_transition();