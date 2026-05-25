set search_path to public, auth;

drop function if exists get_my_restaurants();

create or replace function get_my_restaurants()
    returns table (
                      id int,
                      name varchar(256),
                      city varchar(256),
                      rating double precision,
                      price_range int,
                      last_reservation_date timestamp,
                      pending_requests_count int
                  ) as $$
begin
    perform auth.check_logged();

    return query
        select
            r.id,
            r.name,
            r.city,
            r.rating,
            r.price_range,
            (
                select max(res.datetime)
                from reservations res
                where res.restaurant = r.id
            ) as last_reservation_date,
            cast(
                    (select count(res.id)
                     from reservations res
                     where res.restaurant = r.id and res.status = 'pending') as int
            ) as pending_requests_count
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