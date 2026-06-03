set search_path to public, auth;

-- READ : Obtenir les horaires
drop function if exists get_public_restaurant_services(int);
create or replace function get_public_restaurant_services(p_restaurant_id int)
    returns setof services as $$
begin
    -- On vérifie juste que l'utilisateur est connecté (client ou manager)
    perform auth.check_logged();

return query
select * from services s
where s.restaurant = p_restaurant_id
order by s.day_of_week asc, s.start_time asc;
end;
$$ language plpgsql security definer;

-- On autorise les clients et les managers à exécuter cette fonction
grant execute on function get_public_restaurant_services(int) to client, manager;

notify pgrst, 'reload schema';