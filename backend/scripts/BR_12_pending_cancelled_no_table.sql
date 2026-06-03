set search_path to public;

/* -------------------------------------------------------------------------
   (BR-12) Une réservation en attente ou annulée ne peut être associée
   à aucune table.
   ------------------------------------------------------------------------- */

/* Analyse
Tables concernées :
- reservation_tables :
    - insert : oui (empêcher l'association si la réservation est pending/cancelled)
    - update : oui (empêcher de modifier l'association vers une réservation pending/cancelled)
    - delete : non (supprimer une association va dans le sens de la règle)

- reservations :
    - insert : non (si on insère à l'état pending/cancelled, il n'y a pas encore de table associée)
    - update : oui
        MAIS on ne bloque pas le changement de statut vers pending/cancelled.
        On supprime automatiquement les tables associées, car une réservation pending/cancelled
        ne peut simplement pas garder ses tables.
    - delete : non
*/


/* -------------------------------------------------------------------------
   1. Empêcher d'associer une table à une réservation pending/cancelled
   ------------------------------------------------------------------------- */

create or replace function check_reservation_tables_status()
    returns trigger as $$
declare
    v_status text;
begin
    select status::text
    into v_status
    from reservations
    where id = new.reservation;

    if v_status in ('pending', 'cancelled') then
        raise exception 'BR-12 : Une réservation en attente ou annulée ne peut pas être associée à une table.';
    end if;

    return null;
end;
$$ language plpgsql;


/* -------------------------------------------------------------------------
   2. Si une réservation passe en pending/cancelled, supprimer ses tables
   ------------------------------------------------------------------------- */

create or replace function remove_tables_when_pending_or_cancelled()
    returns trigger as $$
begin
    if new.status::text in ('pending', 'cancelled') then
        delete from reservation_tables
        where reservation = new.id;
    end if;

    return new;
end;
$$ language plpgsql security definer;


/* -------------------------------------------------------------------------
   TRIGGERS
   ------------------------------------------------------------------------- */

-- Trigger sur reservation_tables :
-- on garde un trigger différé, car il sert à vérifier l'état final.
drop trigger if exists trg_br12_reservation_tables_status on reservation_tables;

create constraint trigger trg_br12_reservation_tables_status
    after insert or update of reservation, "table" on reservation_tables
    deferrable initially deferred
    for each row
execute function check_reservation_tables_status();


-- Trigger sur reservations :
-- celui-ci ne doit PAS être différé, car on veut supprimer les tables
-- immédiatement avant que les autres triggers différés vérifient l'état final.
drop trigger if exists trg_br12_reservations_status_update on reservations;

create trigger trg_br12_reservations_status_update
    before update of status on reservations
    for each row
execute function remove_tables_when_pending_or_cancelled();