set search_path to public;

/* -------------------------------------------------------------------------
   FONCTION : Récupérer l'heure actuelle (Réelle ou Simulée)
   ------------------------------------------------------------------------- */
create or replace function get_current_time()
    returns timestamp as $$
declare
    res timestamp;
begin

    select simulated_time into res
    from system_time
    limit 1;

    if res is null then
        res := current_timestamp;
    end if;

    return res;
end;
$$ language plpgsql;