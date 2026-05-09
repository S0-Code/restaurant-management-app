set search_path to public;

/* -------------------------------------------------------------------------
   (BR-11) Une réservation terminée ou annulée ne peut plus être modifiée.
   ------------------------------------------------------------------------- */

create or replace function prevent_modification_final_status()
    returns trigger as $$
begin
    -- On caste en ::text pour éviter les soucis avec les types ENUM
    if old.status::text in ('completed', 'cancelled') then
        raise exception 'BR-11 : Une réservation avec le statut "%" ne peut plus être modifiée.', old.status;
    end if;

    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_prevent_modification_final_status on reservations;
create trigger trg_prevent_modification_final_status
    before update on reservations
    for each row
execute function prevent_modification_final_status();