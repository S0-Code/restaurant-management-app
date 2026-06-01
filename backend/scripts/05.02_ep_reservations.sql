set search_path to public, auth;

/*Récupération des réservations*/
create or replace function get_reservations()
    returns setof client_reservation as
$$
begin
    perform auth.check_logged();

    return query
        select
            r.id,
            r.client,
            rest.name,
            rest.address,
            rest.city,
            rest.phone,
            r.datetime,
            r.number_of_guests,
            r.status,
            r.special_requests
        from reservations r
                 join restaurants rest on rest.id = r.restaurant
        where r.client = auth.id()
        order by r.datetime desc;
end;
$$ language plpgsql security definer;

grant execute on function get_reservations() to client;

notify pgrst, 'reload schema';
