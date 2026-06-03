set search_path to public, auth;

-- 1. READ : Lire les services
drop function if exists get_restaurant_services(int);
create or replace function get_restaurant_services(p_restaurant_id int)
    returns setof services as $$
begin
    perform auth.check_logged();

    -- On retourne les services triés par jour de la semaine, puis par heure de début
return query
select * from services s
where s.restaurant = p_restaurant_id
order by s.day_of_week asc, s.start_time asc;
end;
$$ language plpgsql security definer;


-- 2. CREATE : Ajouter un service
drop function if exists create_restaurant_service(int, int, time, time);
create or replace function create_restaurant_service(p_restaurant_id int, p_day_of_week int, p_start_time time, p_end_time time)
    returns void as $$
begin
    perform auth.check_logged();

    if not exists (select 1 from restaurant_managers rm where rm.restaurant = p_restaurant_id and rm.manager = auth.id()) then
        raise exception 'Accès refusé.';
end if;

insert into services (restaurant, day_of_week, start_time, end_time)
values (p_restaurant_id, p_day_of_week, p_start_time, p_end_time);
end;
$$ language plpgsql security definer;


-- 3. UPDATE : Modifier un service
drop function if exists update_restaurant_service(int, int, time, time);
create or replace function update_restaurant_service(p_service_id int, p_day_of_week int, p_start_time time, p_end_time time)
    returns void as $$
declare
    v_restaurant_id int;
    v_old_day int;
    v_old_start time;
    v_old_end time;
begin
    perform auth.check_logged();

    -- On récupère les ANCIENNES valeurs du service
    select restaurant, day_of_week, start_time, end_time
    into v_restaurant_id, v_old_day, v_old_start, v_old_end
    from services where id = p_service_id;

    if not exists (select 1 from restaurant_managers rm where rm.restaurant = v_restaurant_id and rm.manager = auth.id()) then
        raise exception 'Accès refusé.';
    end if;

    -- REGLE MÉTIER : Vérifier si des réservations deviennent orphelines
    if exists (
        select 1 from reservations r
        where r.restaurant = v_restaurant_id
          and extract(isodow from r.datetime) = v_old_day
          and r.datetime::time >= v_old_start
          and r.datetime::time < v_old_end
          and r.status in ('pending', 'confirmed')
          -- Elles deviennent orphelines si on change de jour OU si elles sortent des nouvelles heures
          and (
            p_day_of_week != v_old_day
                or r.datetime::time < p_start_time
                or r.datetime::time >= p_end_time
            )
    ) then
        raise exception 'Modification impossible : des réservations confirmées ou en attente seraient en dehors des horaires.';
    end if;

    update services
    set day_of_week = p_day_of_week, start_time = p_start_time, end_time = p_end_time
    where id = p_service_id;
end;
$$ language plpgsql security definer;


-- 4. DELETE : Supprimer un service
drop function if exists delete_restaurant_service(int);
create or replace function delete_restaurant_service(p_service_id int)
    returns void as $$
declare
    v_restaurant_id int;
    v_day_of_week int;
    v_start_time time;
    v_end_time time;
begin
    perform auth.check_logged();

    -- On récupère les infos du service avant de le supprimer
    select restaurant, day_of_week, start_time, end_time
    into v_restaurant_id, v_day_of_week, v_start_time, v_end_time
    from services where id = p_service_id;

    if not exists (select 1 from restaurant_managers rm where rm.restaurant = v_restaurant_id and rm.manager = auth.id()) then
        raise exception 'Accès refusé.';
    end if;

    -- REGLE MÉTIER : Y a-t-il des réservations non annulées pendant ce service ?
    if exists (
        select 1 from reservations r
        where r.restaurant = v_restaurant_id
          and extract(isodow from r.datetime) = v_day_of_week
          and r.datetime::time >= v_start_time
          and r.datetime::time < v_end_time
          and r.status != 'cancelled'
    ) then
        raise exception 'Impossible de supprimer : des réservations non annulées utilisent ce service';
    end if;

    delete from services where id = p_service_id;
end;
$$ language plpgsql security definer;

-- Autorisations
grant execute on function get_restaurant_services(int) to manager;
grant execute on function create_restaurant_service(int, int, time, time) to manager;
grant execute on function update_restaurant_service(int, int, time, time) to manager;
grant execute on function delete_restaurant_service(int) to manager;

notify pgrst, 'reload schema';