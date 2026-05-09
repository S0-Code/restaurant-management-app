set search_path to public, auth;

    /*(BR-01) Une réservation doit être associée à un utilisateur ayant le rôle de client.*/

/*
Tables concernées :
-reservations :
    -insert : oui
    -update : oui
    -delete : non
-users
    -insert : non
    -update : non car on ne peut pas modifier le rôle d'un user
    -delete : non
*/
create or replace function reservation_user_should_be_client_fct()
    returns trigger as
$$
begin
    /*On vérfifie que le client existe bien et qu'il a le bon rôle*/
    if not exists (
        select 1
        from users
        where id = new.client
          and role = 'client'
    ) then
        raise exception 'Reservation user should have client role';
    end if;

    return new;
end;
$$ language plpgsql;

create or replace trigger reservation_user_should_be_client
    before insert or update
    on reservations
    for each row
execute function reservation_user_should_be_client_fct();
