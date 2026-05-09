set search_path to public;

/* -------------------------------------------------------------------------
   (BR-06) : Une table ne peut pas faire l'objet de deux réservations terminées
   ou confirmées pour une même date et un même service.
      Tables concernées :
   reservation_tables :
    insert : oui
    update : non
    delete : non
   reservations:
    insert : non car à la création d'une résa, pas encore de tables assignées
    update : oui si on passe d'un statut pending à confirmed par ex.
            ou si on change le date d'une resa pour un jour/heure où
            une table de la résa est dejà prise par une autre résa
    delete : non
   ------------------------------------------------------------------------- */

select rt.reservation
    from reservation_tables rt
        join reservations r on rt.reservation = r.id
        /*On vérifie le statut*/
    where r.status in ('confirmed'::status_type, 'completed'::status_type) AND
          exists(
              SELECT 1
              FROM reservations res
                    join reservation_tables rt2 on rt2.reservation = res.id
              where res.datetime::date = r.datetime::date AND
                and res.status in ('confirmed'::status_type, 'completed'::status_type) AND
                    exists(
                        select 1
                        from services
                        where
                              /*Même restaurant*/
                              services.restaurant = res.restaurant and
                              services.restaurant = r.restaurant and
                              /*Même date*/
                              services.day_of_week = extract(isodow from res.datetime::date)::int and
                              services.day_of_week = extract(isodow from r.datetime::date)::int and
                              /*Même service*/
                              services.start_time <= res.datetime::time and
                              services.end_time > res.datetime::time and
                              services.start_time <= r.datetime::time and
                              services.end_time > r.datetime::time and
                              /*Même table*/
                              rt2."table" = rt.table and
                              /*réservartion  différente*/
                              r.id <> res.id
                    )


          );

create or replace function check_tables_availability()
    returns trigger as
$$
begin
    if exists(select rt.reservation
              from reservation_tables rt
                       join reservations r on rt.reservation = r.id
              /*On vérifie le statut*/
              where r.status in ('confirmed'::status_type, 'completed'::status_type) AND
                  exists(
                      SELECT 1
                      FROM reservations res
                               join reservation_tables rt2 on rt2.reservation = res.id
                      where res.datetime::date = r.datetime::date AND
                            res.status in ('confirmed'::status_type, 'completed'::status_type) AND
                          exists(
                              select 1
                              from services
                              where
                                  /*Même restaurant*/
                                  services.restaurant = res.restaurant and
                                  services.restaurant = r.restaurant and
                                  /*Même date*/
                                  services.day_of_week = extract(isodow from res.datetime::date)::int and
                                  services.day_of_week = extract(isodow from r.datetime::date)::int and
                                  /*Même service*/
                                  services.start_time <= res.datetime::time and
                                  services.end_time > res.datetime::time and
                                  services.start_time <= r.datetime::time and
                                  services.end_time > r.datetime::time and
                                  /*Même table*/
                                  rt2."table" = rt.table and
                                  /*réservartion  différente*/
                                  r.id <> res.id
                          )


                  ))
    then
        raise exception 'Une table ne peut pas faire l''objet de deux réservations terminées
   ou confirmées pour une même date et un même service.';
    end if;

    return null;
end;
$$ language plpgsql security definer;



/* -------------------------------------------------------------------------
   TRIGGER
   ------------------------------------------------------------------------- */
drop trigger if exists trg_check_table_availability_on_reservation_tables on reservation_tables;
create trigger trg_check_table_availability_on_reservation_tables
    after insert on reservation_tables
    for each row
execute function check_tables_availability();
drop trigger if exists trg_check_table_availability_on_reservations on reservations;
create trigger trg_check_table_availability_on_reservations
    after update of status, datetime on reservations
    for each row
execute function check_tables_availability();
