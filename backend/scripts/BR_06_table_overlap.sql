set search_path to public;

/* -------------------------------------------------------------------------
   (BR-06) : Une table ne peut pas faire l'objet de deux réservations terminées ou confirmées pour une même date et un même service.
   ------------------------------------------------------------------------- */
create or replace function check_table_availability()
    returns trigger as $$
declare
    res_restaurant int;
    res_date date;
    res_time time;
    res_service_id int;
begin
    -- 1. Récupérer les infos (date et heure séparées) de la réservation concernée
    select restaurant, datetime::date, datetime::time
    into res_restaurant, res_date, res_time
    from reservations
    where id = new.reservation;

    -- 2. Identifier à quel service (ID) correspond l'heure de cette réservation
    select id into res_service_id
    from services
    where restaurant = res_restaurant
      and day_of_week = extract(isodow from res_date)::int
      and res_time >= start_time
      and res_time <= end_time
    limit 1;

    -- 3. Vérifier s'il y a un chevauchement (Même table, même date, même service, statut confirmé/terminé)
    if exists (
        select 1
        from reservation_tables rt
                 join reservations r on rt.reservation = r.id
        where rt."table" = new."table"  -- Utilisation des guillemets car "table" est un mot réservé SQL
          and r.datetime::date = res_date
          and r.status in ('confirmed', 'completed')
          and r.id != new.reservation
          and exists (
            -- On s'assure que l'autre réservation tombe bien dans le MÊME service
            select 1 from services s
            where s.id = res_service_id
              and extract(isodow from r.datetime::date)::int = s.day_of_week
              and r.datetime::time >= s.start_time
              and r.datetime::time <= s.end_time
        )
    ) then
        raise exception 'La table % est déjà occupée pour ce service le %.', new."table", res_date
            using errcode = 'restrict_violation';
    end if;

    return new;
end;
$$ language plpgsql;

/* -------------------------------------------------------------------------
   TRIGGER
   ------------------------------------------------------------------------- */
drop trigger if exists trg_check_table_availability on reservation_tables;
create trigger trg_check_table_availability
    before insert or update on reservation_tables
    for each row
execute function check_table_availability();