set search_path to public;

/* -------------------------------------------------------------------------
   (BR-10) Un restaurant doit avoir au moins un manager.
   ------------------------------------------------------------------------- */

create or replace function check_restaurant_minimum_manager()
    returns trigger
    set search_path from current as $$
declare
    v_restaurant_id int;
    v_count int;
begin
    -- On identifie l'ID du restaurant selon la table impactée
    if TG_TABLE_NAME = 'restaurants' then
        v_restaurant_id := new.id;
    else
        v_restaurant_id := old.restaurant;
    end if;

    select count(*) into v_count
    from restaurant_managers
    where restaurant = v_restaurant_id;

-- 2. Si le compteur est à 0, on lève l'exception
if v_count = 0 then
        raise exception 'Un restaurant doit avoir au moins un manager.';
end if;

    return null;
end;
$$ language plpgsql security definer;

/* -------------------------------------------------------------------------
   TRIGGERS DIFFÉRÉS
   ------------------------------------------------------------------------- */

drop trigger if exists trg_br10_check_restaurant_insert on restaurants;
create constraint trigger trg_br10_check_restaurant_insert
    after insert on restaurants
    deferrable initially deferred
    for each row
execute procedure check_restaurant_minimum_manager();

drop trigger if exists trg_br10_check_manager_delete on restaurant_managers;
create constraint trigger trg_br10_check_manager_delete
    after delete or update on restaurant_managers
    deferrable initially deferred
    for each row
execute procedure check_restaurant_minimum_manager();