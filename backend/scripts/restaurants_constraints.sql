set search_path to public, auth;


/* La description, si elle est fournie, doit avoir au minimum une longueur de 10 caractères.*/
ALTER table restaurants  add constraint description_length check
(length(trim(description))>=10);

/*La note doit être comprise entre 0.0 et 5.0 si elle est définie.*/
-- ALTER table restaurants add constraint rating_min_max check
--     (rating >= 0.0 and rating <=5.0  );

ALTER  table restaurants add constraint  rating_min_max check
    (rating BETWEEN 0.0 and 5.0);

/*La fourchette de prix doit être comprise entre 1 et 4 si elle est définie.*/
ALTER table restaurants add constraint price_range_min_max check
    (price_range BETWEEN 1 and 4);

/* La durée de créneau de réservation doit être soit 10, 15, 20, 30 ou 60 minutes. */
ALTER table restaurants add constraint slot_duration_accepted check
    ( slot_duration in (10 , 15 , 20 , 30 , 60));


