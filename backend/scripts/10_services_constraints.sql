set search_path to public, auth;


/* Le jour de la semaine doit être compris entre 1 (lundi) et 7 (dimanche). */
alter table services
    add constraint service_day_range
        check (day_of_week between 1 and 7);

/* L'heure de fin doit être postérieure à l'heure de début d'au moins une heure.
   Note : l'heure de fin d'un service représente l'heure au-delà de laquelle le restaurant
   n'accepte plus de clients.*/
alter table services
      add constraint check_end_time_is_after_start_time
      check (end_time::time >= start_time::time + interval '1 hour');