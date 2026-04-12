set search_path to public, auth;


/* Le jour de la semaine doit être compris entre 1 (lundi) et 7 (dimanche). */
alter table services
    add constraint service_day_range
        check (day_of_week between 1 and 7);