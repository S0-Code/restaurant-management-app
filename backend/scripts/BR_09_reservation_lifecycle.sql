set search_path to public;

/* -------------------------------------------------------------------------
   FONCTION 1 : Forcer le statut initial à 'pending'
   ------------------------------------------------------------------------- */
create or replace function enforce_initial_reservation_status()
returns trigger as $$
begin
    -- On vérifie si quelqu'un essaie de créer une réservation qui n'est pas 'pending'
    if new.status is distinct from 'pending'::status_type then
        raise exception 'Une nouvelle réservation doit obligatoirement avoir le statut "pending".';
    end if;

return new;
end;
$$ language plpgsql;

drop trigger if exists trg_enforce_initial_status on reservations;
create trigger trg_enforce_initial_status
    before insert on reservations
    for each row
    execute function enforce_initial_reservation_status();


/* -------------------------------------------------------------------------
   FONCTION 2 : Contrôler les transitions du cycle de vie
   ------------------------------------------------------------------------- */
create or replace function check_reservation_lifecycle()
returns trigger as $$
begin
    -- Si le statut n'a pas été modifié (ex: on change juste le nombre d'invités), on laisse passer
    if old.status = new.status then
        return new;
end if;

    -- Vérification des transitions depuis 'pending'
    if old.status = 'pending' and new.status not in ('confirmed'::status_type, 'cancelled'::status_type) then
        raise exception 'Transition invalide : Impossible de passer directement de "pending" à "%".', new.status;
    end if;

    -- Vérification des transitions depuis 'confirmed'
    -- (La règle temporelle confirmed -> pending est déjà gérée par l'autre trigger)
    if old.status = 'confirmed' and new.status not in ('completed'::status_type, 'cancelled'::status_type, 'pending'::status_type) then
        raise exception 'Transition invalide : Impossible de passer de "confirmed" à "%".', new.status;
end if;

    -- Note : Les statuts 'completed' et 'cancelled' sont déjà bloqués par la BR-11 !

return new;
end;
$$ language plpgsql;

drop trigger if exists trg_check_reservation_lifecycle on reservations;
create trigger trg_check_reservation_lifecycle
    before update of status on reservations
    for each row
    execute function check_reservation_lifecycle();