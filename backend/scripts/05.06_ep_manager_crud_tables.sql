set search_path to public, auth;

-- 1. READ : Fonction Table
drop function if exists get_restaurant_tables(int);
create or replace function get_restaurant_tables(p_restaurant_id int)
    returns setof tables as $$
begin
    perform auth.check_logged();

    -- Sécurité : On vérifie que le manager connecté gère bien ce restaurant
    if not exists (select 1 from restaurant_managers rm where rm.restaurant = p_restaurant_id and rm.manager = auth.id()) then
        raise exception 'Accès refusé.';
    end if;

    return query
        select * from tables t
        where t.restaurant = p_restaurant_id
        order by t.capacity asc, t.table_number asc;
end;
$$ language plpgsql security definer;


-- 2. CREATE
drop function if exists create_restaurant_table(int, int, int);
create or replace function create_restaurant_table(p_restaurant_id int, p_table_number int, p_capacity int)
    returns void as $$
begin
    perform auth.check_logged();

    if not exists (select 1 from restaurant_managers rm where rm.restaurant = p_restaurant_id and rm.manager = auth.id()) then
        raise exception 'Accès refusé.';
    end if;

    insert into tables (restaurant, table_number, capacity)
    values (p_restaurant_id, p_table_number, p_capacity);
end;
$$ language plpgsql security definer;


-- 3. UPDATE
drop function if exists update_restaurant_table(int, int, int);
create or replace function update_restaurant_table(p_table_id int, p_table_number int, p_capacity int)
    returns void as $$
declare
    v_restaurant_id int;
begin
    perform auth.check_logged();

    select restaurant into v_restaurant_id from tables where id = p_table_id;

    if not exists (select 1 from restaurant_managers rm where rm.restaurant = v_restaurant_id and rm.manager = auth.id()) then
        raise exception 'Accès refusé.';
    end if;

    update tables
    set table_number = p_table_number, capacity = p_capacity
    where id = p_table_id;
end;
$$ language plpgsql security definer;


-- Autorisations
grant execute on function get_restaurant_tables(int) to manager;
grant execute on function create_restaurant_table(int, int, int) to manager;
grant execute on function update_restaurant_table(int, int, int) to manager;

notify pgrst, 'reload schema';