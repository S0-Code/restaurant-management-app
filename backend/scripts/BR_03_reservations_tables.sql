set search_path to public;

/*
(BR-03) Les tables associées à une réservation doivent
appartenir au restaurant de la réservation.

Tables concernées :

-reservations_tables :
    -insert : oui
    -update : non car clé primaire composée
    -delete : non
*/


create or replace function check_reservation_table_belongs_to_reservation_restaurant()
    returns trigger as
$$
begin
    if exists(select 1
              from reservation_tables rt
                       join reservations r on rt.reservation = r.id
                       join tables t on rt."table" = t.id
              where t.restaurant <> r.restaurant)
    then
        raise exception 'Les tables d''une réservation doivent appartenir au restaurant de la réservation';
    end if;

    return null;
end;
$$ language plpgsql security definer;


create trigger trigger_reservation_tables_belongs_to_restaurant_reservation
    after insert
    on reservation_tables
    for each row
execute function check_reservation_table_belongs_to_reservation_restaurant();




