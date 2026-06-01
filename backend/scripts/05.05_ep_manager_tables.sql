set search_path to public, auth;

-- 1. Fonction pour récupérer la disponibilité des tables pour une réservation donnée
drop function if exists get_restaurant_tables_availability(int, int);
create or replace function get_restaurant_tables_availability(p_restaurant_id int, p_reservation_id int)
    returns table (
                      id int,
                      table_number int,
                      capacity int,
                      is_available boolean
                  ) as $$
declare
    v_res_datetime timestamp;
begin
    perform auth.check_logged();

    -- Sécurité : le manager gère-t-il ce restaurant ?
    if not exists (
        select 1 from restaurant_managers rm
        where rm.restaurant = p_restaurant_id and rm.manager = auth.id()
    ) then
        raise exception 'Accès refusé.';
    end if;

    -- Récupération de l'heure de la réservation
    select reservations.datetime into v_res_datetime from reservations where reservations.id = p_reservation_id;

    return query
        select
            t.id,
            t.table_number,
            t.capacity,
            -- La table est disponible si AUCUNE autre réservation active n'utilise cette table
            not exists (
                select 1
                from reservation_tables rt
                         join reservations r2 on rt.reservation = r2.id
                where rt."table" = t.id
                  and r2.id != p_reservation_id
                  and r2.status::text in ('pending', 'confirmed', 'completed')
                  and r2.datetime::date = v_res_datetime::date
                  and abs(extract(epoch from (r2.datetime - v_res_datetime))) <= 7200
            ) as is_available
        from tables t
        where t.restaurant = p_restaurant_id
        order by t.table_number;
end;
$$ language plpgsql security definer;
grant execute on function get_restaurant_tables_availability(int, int) to manager;


-- 2. Fonction pour assigner les tables et confirmer
drop function if exists manager_assign_tables_and_confirm(int, int[]);
create or replace function manager_assign_tables_and_confirm(p_reservation_id int, p_table_ids int[])
    returns void as $$
declare
    v_restaurant_id int;
begin
    perform auth.check_logged();

    -- Récupération du restaurant
    select reservations.restaurant into v_restaurant_id from reservations where reservations.id = p_reservation_id;

    -- Sécurité
    if not exists (
        select 1 from restaurant_managers rm
        where rm.restaurant = v_restaurant_id and rm.manager = auth.id()
    ) then
        raise exception 'Accès refusé.';
    end if;

    -- Supprimer les anciennes assignations
    delete from reservation_tables where reservation_tables.reservation = p_reservation_id;

    -- Insérer les nouvelles tables
    insert into reservation_tables (reservation, "table")
    select p_reservation_id, unnest(p_table_ids);

    -- Mettre à jour le statut en 'confirmed'
    update reservations set status = 'confirmed'::status_type where reservations.id = p_reservation_id;
end;
$$ language plpgsql security definer;

-- =========================================================================
-- AUTORISATIONS
-- =========================================================================
grant execute on function manager_assign_tables_and_confirm(int, int[]) to manager;
grant select on all tables in schema public to manager;
grant update on table reservations to manager;
grant insert, delete on table reservation_tables to manager;

notify pgrst, 'reload schema';
