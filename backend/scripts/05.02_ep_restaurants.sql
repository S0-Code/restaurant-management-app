set search_path to public, auth;

drop function if exists get_my_restaurants();

create or replace function get_my_restaurants()
    returns setof restaurant_detail as $$
begin
    perform auth.check_logged();

    return query
        select
            r.id,
            r.name,
            r.city,
            r.address,
            r.phone,
            r.rating,
            r.price_range,
            (
                select max(res.datetime)
                from reservations res
                where res.restaurant = r.id
            ) as last_reservation_date,
            (
                select count(res.id)
                from reservations res
                where res.restaurant = r.id
                  and res.status = 'pending'
            )::integer as pending_requests_count,
            r.description
        from restaurants r
                 join restaurant_managers rm on r.id = rm.restaurant
        where rm.manager = auth.id();
end;
$$ language plpgsql security definer;

grant execute on function get_my_restaurants() to manager;

notify pgrst, 'reload schema';



-- select name from restaurant_managers, restaurants where restaurant_managers.manager=5 and restaurant = restaurants.id;
--
-- select name from restaurant_managers, restaurants where restaurant_managers.manager=2 and restaurant = restaurants.id;

drop function if exists search_client_restaurants(integer, text);

create or replace function search_client_restaurants(
    p_limit integer,
    p_search text default null
)
    returns setof restaurant_detail as
$$
begin
    perform auth.check_logged();

    return query
        select
            r.id,
            r.name,
            r.city,
            r.address,
            r.phone,
            r.rating,
            r.price_range,
            max(res.datetime) as last_reservation_date,
            (
                select count(*)
                from reservations r2
                where r2.restaurant = r.id
                  and r2.client = auth.id()
                  and r2.status = 'pending'
            )::integer as pending_requests_count,
            r.description
        from restaurants r
                 left join reservations res
                           on res.restaurant = r.id
                               and res.client = auth.id()
        where
            trim(coalesce(p_search, '')) = ''
           or r.name ilike '%' || trim(p_search) || '%'
           or r.city ilike '%' || trim(p_search) || '%'
           or r.address ilike '%' || trim(p_search) || '%'
        group by
            r.id,
            r.name,
            r.city,
            r.address,
            r.phone,
            r.rating,
            r.price_range,
            r.description
        order by r.name
        limit p_limit;
end;
$$ language plpgsql security definer;

grant execute on function search_client_restaurants(integer, text) to client;

notify pgrst, 'reload schema';




/*Récupération des horaires d'un restaurant*/
drop function if exists get_restaurant_services(integer);

create or replace function get_restaurant_services(
    p_restaurant integer
)
    returns setof service_info as
$$
begin
    perform auth.check_logged();

    return query
        select
            s.day_of_week,
            s.start_time,
            s.end_time
        from services s
        where s.restaurant = p_restaurant
        order by s.day_of_week, s.start_time;
end;
$$ language plpgsql security definer;

grant execute on function get_restaurant_services(integer) to client;
grant execute on function get_restaurant_services(integer) to manager;

notify pgrst, 'reload schema';