set search_path to public;

/* -------------------------------------------------------------------------
   FONCTION GÉNÉRIQUE : Empêcher la mise à jour d'une colonne spécifique
   ------------------------------------------------------------------------- */

create or replace function prevent_column_update()
returns trigger as $$
declare
    -- On récupère le nom de la colonne passé en paramètre du trigger
nom_colonne text := TG_ARGV[0];
    ancienne_valeur text;
    nouvelle_valeur text;
begin
    -- On extrait les valeurs dynamiquement en format texte
    ancienne_valeur := row_to_json(OLD)->>nom_colonne;
    nouvelle_valeur := row_to_json(NEW)->>nom_colonne;

    -- On compare
    if ancienne_valeur is distinct from nouvelle_valeur then
        raise exception 'La modification de la colonne "%" est interdite.', nom_colonne;
end if;

return NEW;
end;
$$ language plpgsql;

/* -------------------------------------------------------------------------
   LES TRIGGER QUI FONT APPEL A FONCTION GÉNÉRIQUE prevent_column_update()
   ------------------------------------------------------------------------- */

/* On ne peut pas modifier le rôle d'un utilisateur. */

drop trigger if exists trg_prevent_role_update on users;
create trigger trg_prevent_role_update
    before update of role on users
    for each row
    execute function prevent_column_update('role');


/*On ne peut pas modifier le restaurant d'une table. */

drop  trigger if exists trg_prevent_restaurant_of_table_update on tables;
create trigger trg_prevent_restaurant_of_table_update
    before update of restaurant on tables
    for each row
    execute function prevent_column_update('restaurant');

/*On ne peut pas modifier le restaurant d'un service.*/

drop  trigger if exists trg_prevent_restaurant_of_service_update on services;
create trigger trg_prevent_restaurant_of_service_update
    before update of restaurant on services
    for each row
    execute function prevent_column_update('restaurant');

/*On ne peut pas modifier le restaurant ou le client d'une réservation.*/

drop  trigger if exists trg_prevent_restaurant_of_reservation_update on reservations;
create trigger trg_prevent_restaurant_of_reservation_update
    before update of restaurant on reservations
    for each row
execute function prevent_column_update('restaurant');

drop  trigger if exists trg_prevent_client_of_reservation_update on reservations;
create trigger trg_prevent_client_of_reservation_update
    before update of client on reservations
    for each row
execute function prevent_column_update('client');



/*On pne peut pas modifier la clé primaire d'une table*/

drop trigger if exists trg_prevent_user_id_update on users;
create trigger trg_prevent_user_id_update
    before update of id on users
    for each row
execute function prevent_column_update('id');

drop trigger if exists trg_prevent_restaurant_id_update on restaurants;
create trigger trg_prevent_restaurant_id_update
    before update of id on restaurants
    for each row
execute function prevent_column_update('id');

drop trigger if exists trg_prevent_table_id_update on tables;
create trigger trg_prevent_table_id_update
    before update of id on tables
    for each row
execute function prevent_column_update('id');

drop trigger if exists trg_prevent_service_id_update on services;
create trigger trg_prevent_service_id_update
    before update of id on services
    for each row
execute function prevent_column_update('id');

drop trigger if exists trg_prevent_reservation_id_update on reservations;
create trigger trg_prevent_reservation_id_update
    before update of id on reservations
    for each row
execute function prevent_column_update('id');

drop trigger if exists trg_prevent_restaurant_managers_restaurant_update on restaurant_managers;
create trigger trg_prevent_restaurant_managers_restaurant_update
    before update of restaurant on restaurant_managers
    for each row
execute function prevent_column_update('restaurant');

drop trigger if exists trg_prevent_restaurant_managers_manager_update on restaurant_managers;
create trigger trg_prevent_restaurant_managers_manager_update
    before update of manager on restaurant_managers
    for each row
execute function prevent_column_update('manager');

drop trigger if exists trg_prevent_reservation_tables_reservation_update on reservation_tables;
create trigger trg_prevent_reservation_tables_reservation_update
    before update of reservation on reservation_tables
    for each row
execute function prevent_column_update('reservation');

drop trigger if exists trg_prevent_reservation_tables_table_update on reservation_tables;
create trigger trg_prevent_reservation_tables_table_update
    before update of "table" on reservation_tables
    for each row
execute function prevent_column_update('table');


