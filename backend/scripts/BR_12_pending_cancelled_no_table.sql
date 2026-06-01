set search_path to public;

/* -------------------------------------------------------------------------
   (BR-12) Une réservation en attente ou annulée ne peut être associée
   à aucune table.
   ------------------------------------------------------------------------- */

/* Analyse
Tables concernées :
- reservation_tables :
    - insert : oui (empêcher l'association si elle est pending/cancelled)
    - update : oui (empêcher de modifier l'association vers pending/cancelled)
    - delete : non (supprimer une association va dans le sens de la règle)
- reservations :
    - insert : non (si on insère à l'état pending/cancelled, il n'y a pas encore de table associée)
    - update : oui (si on change le statut vers pending/cancelled alors qu'une table est déjà associée, on doit bloquer)
    - delete : non
*/

-- 1. Fonction pour contrôler l'insertion/modification sur reservation_tables
create or replace function check_reservation_tables_status()
    returns trigger as $$
declare
    v_status text;
begin
    -- On récupère le statut actuel de la réservation parente
    select status::text into v_status from reservations where id = new.reservation;

    -- Si le statut interdit les tables, on bloque
    if v_status in ('pending', 'cancelled') then
        raise exception 'BR-12 : Une réservation en attente ou annulée ne peut pas être associée à une table.';
    end if;

    return null;
end;
$$ language plpgsql;

-- 2. Nettoyage automatique des tables
create or replace function auto_release_tables_on_status_change()
    returns trigger as $$
begin
    if new.status::text in ('pending', 'cancelled') and old.status::text not in ('pending', 'cancelled') then
        delete from reservation_tables where reservation = new.id;
    end if;
    return new;
end;
$$ language plpgsql;

-- 3. Contrôle de sécurité final
create or replace function check_reservations_status_update()
    returns trigger as $$
declare
    v_table_count int;
begin
    -- Si on tente de passer vers un statut qui interdit les tables
    if new.status::text in ('pending', 'cancelled') then
        -- On vérifie s'il existe déjà des tables associées
        select count(*) into v_table_count from reservation_tables where reservation = new.id;

        -- S'il y a des tables, on bloque le changement de statut
        if v_table_count > 0 then
            raise exception 'BR-12 : Impossible de passer la réservation en % car elle est associée à des tables.', new.status;
        end if;
    end if;

    return null;
end;
$$ language plpgsql;


/* -------------------------------------------------------------------------
   TRIGGERS
   ------------------------------------------------------------------------- */
-- Le nettoyage avant que les problèmes n'arrivent
drop trigger if exists trg_auto_release_tables on reservations;
create trigger trg_auto_release_tables
    before update of status on reservations
    for each row
execute procedure auto_release_tables_on_status_change();

-- Trigger sur reservation_tables
drop trigger if exists trg_br12_reservation_tables_status on reservation_tables;
create constraint trigger trg_br12_reservation_tables_status
    after insert or update on reservation_tables
    deferrable initially deferred
    for each row
execute procedure check_reservation_tables_status();

-- Trigger sur reservations (uniquement sur le UPDATE de la colonne status)
drop trigger if exists trg_br12_reservations_status_update on reservations;
create constraint trigger trg_br12_reservations_status_update
    after update of status on reservations
    deferrable initially deferred
    for each row
execute procedure check_reservations_status_update();