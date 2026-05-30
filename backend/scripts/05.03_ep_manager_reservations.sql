set search_path to public, auth;

drop function if exists get_manager_restaurant_reservations(int);

create or replace function get_manager_restaurant_reservations(p_restaurant_id int)
    returns table (
                      id int,
                      restaurant_id int,
                      client_name varchar(256),
                      client_email varchar(256),
                      client_phone varchar(50),
                      restaurant_name varchar(256),
                      datetime timestamp,
                      number_of_guests int,
                      status text,
                      special_requests text,
                      assigned_tables json
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
            r.restaurant as restaurant_id,
            u.full_name::varchar(256) as client_name,
            u.email::varchar(256) as client_email,
            u.phone::varchar(50) as client_phone,
            rest.name::varchar(256) as restaurant_name,
            r.datetime,
            r.number_of_guests,
            r.status::text,
            r.special_requests,
            (
                select coalesce(json_agg(json_build_object('table_number', t.table_number, 'capacity', t.capacity)), '[]'::json)
                from reservation_tables rt
                         join tables t on rt."table" = t.id
                where rt.reservation = r.id
            ) as assigned_tables
        from reservations r
                 join users u on r.client = u.id
                 join restaurants rest on r.restaurant = rest.id
        where r.restaurant = p_restaurant_id
        order by r.datetime desc, r.id desc;
end;
$$ language plpgsql security definer;

grant execute on function get_manager_restaurant_reservations(int) to manager;
notify pgrst, 'reload schema';