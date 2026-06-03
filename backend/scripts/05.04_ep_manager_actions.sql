set search_path to public, auth;

drop function if exists manager_update_reservation_status(int, text);

create or replace function manager_update_reservation_status(p_reservation_id int, p_new_status text)
    returns void as $$
begin
    perform auth.check_logged();

    if not exists (
        select 1 from reservations r
                          join restaurant_managers rm on r.restaurant = rm.restaurant
        where r.id = p_reservation_id and rm.manager = auth.id()
    ) then
        raise exception 'Accès refusé.';
    end if;

    update reservations set status = p_new_status::status_type where id = p_reservation_id;
end;
$$ language plpgsql security definer;

grant execute on function manager_update_reservation_status(int, text) to manager;
notify pgrst, 'reload schema';