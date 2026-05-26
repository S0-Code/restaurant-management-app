set search_path to public, auth;

drop function if exists get_manager_restaurant_reservations(int);

create or replace function get_manager_restaurant_reservations(p_restaurant_id int)
    returns table (
        id int,
        client_name varchar(256),
        restaurant_name varchar(256),
        datetime timestamp,
        number_of_guests int,
        status text,
        special_requests text
    ) as $$
begin
    perform auth.check_logged();

    if not exists (
        select 1 from restaurant_managers rm
        where rm.restaurant = p_restaurant_id and rm.manager = auth.id()
    ) then
        raise exception 'Accès refusé : vous ne gérez pas ce restaurant.';
end if;

return query
select
    r.id,
    u.full_name::varchar(256) as client_name,
    rest.name::varchar(256) as restaurant_name,
    r.datetime,
    r.number_of_guests,
    r.status::text,
    r.special_requests
from reservations r
         join users u on r.client = u.id
         join restaurants rest on r.restaurant = rest.id
where r.restaurant = p_restaurant_id
order by r.datetime desc, r.id desc;
end;
$$ language plpgsql security definer;

grant execute on function get_manager_restaurant_reservations(int) to manager;
notify pgrst, 'reload schema';