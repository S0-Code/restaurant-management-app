set search_path to public;

/* -------------------------------------------------------------------------
   (BR-09) Cycle de vie d'une réservation
   ------------------------------------------------------------------------- */

/*
Transitions autorisées :

- INSERT :
    Toute nouvelle réservation doit commencer en pending.

- UPDATE :
    pending   -> confirmed
    pending   -> cancelled

    confirmed -> completed
    confirmed -> pending, uniquement si la réservation est dans le futur

Les autres transitions sont interdites.

Remarque :
- BR-11 peut aussi empêcher certains changements depuis completed/cancelled.
- Ici, on garde quand même une sécurité explicite pour éviter de dépendre
  uniquement de BR-11.
*/


/* -------------------------------------------------------------------------
   1. Forcer le statut initial à pending
   ------------------------------------------------------------------------- */

create or replace function enforce_initial_reservation_status()
    returns trigger as $$
begin
    if new.status is distinct from 'pending'::status_type then
        raise exception 'BR-09 : Une nouvelle réservation doit obligatoirement avoir le statut pending.';
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
   2. Contrôler les transitions du cycle de vie
   ------------------------------------------------------------------------- */

create or replace function check_reservation_lifecycle()
    returns trigger as $$
begin
    -- Si le statut n'a pas été modifié, on laisse passer
    if old.status = new.status then
        return new;
    end if;

    -- Une réservation annulée ou terminée ne peut plus changer de statut
    if old.status in ('cancelled'::status_type, 'completed'::status_type) then
        raise exception 'BR-09 : Une réservation annulée ou terminée ne peut plus changer de statut.';
    end if;

    -- pending -> confirmed
    if old.status = 'pending'::status_type
        and new.status = 'confirmed'::status_type then
        return new;
    end if;

    -- pending -> cancelled
    if old.status = 'pending'::status_type
        and new.status = 'cancelled'::status_type then
        return new;
    end if;

    -- confirmed -> completed
    if old.status = 'confirmed'::status_type
        and new.status = 'completed'::status_type then
        return new;
    end if;

    -- confirmed -> cancelled
    if old.status = 'confirmed'::status_type
        and new.status = 'cancelled'::status_type then
        return new;
    end if;

    -- confirmed -> pending uniquement si la réservation est dans le futur
    if old.status = 'confirmed'::status_type
        and new.status = 'pending'::status_type then

        if old.datetime > get_current_time() then
            return new;
        end if;

        raise exception 'BR-09 : Impossible de repasser une réservation confirmée en pending si elle n''est pas dans le futur.';
    end if;

    raise exception 'BR-09 : Transition invalide de % vers %.', old.status, new.status;
end;
$$ language plpgsql;


drop trigger if exists trg_check_reservation_lifecycle on reservations;

create trigger trg_check_reservation_lifecycle
    before update of status on reservations
    for each row
execute function check_reservation_lifecycle();