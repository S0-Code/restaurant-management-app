set search_path to public;

/* -------------------------------------------------------------------------
   FONCTION : Empêcher la modification d'une réservation terminée/annulée
   ------------------------------------------------------------------------- */

create or replace function prevent_modification_final_status()
returns trigger as $$
begin
    -- Si la réservation était déjà 'completed' ou 'cancelled', on bloque tout
    if old.status in ('completed', 'cancelled') then
        raise exception 'Une réservation avec le statut "%" ne peut plus être modifiée.', old.status
        using errcode = 'raise_exception';
end if;

return new;
end;
$$ language plpgsql;

/* -------------------------------------------------------------------------
   TRIGGER
   ------------------------------------------------------------------------- */

drop trigger if exists trg_prevent_modification_final_status on reservations;
create trigger trg_prevent_modification_final_status
    before update on reservations
    for each row
    execute function prevent_modification_final_status();