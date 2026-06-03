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




/*Le nom doit avoir au minimum une longueur de 5 caractères.*/

ALTER TABLE restaurants add constraint restaurant_name_min_length check
    (  length(trim(name)) >= 5  );



/*L'adresse doit avoir au minimum une longueur de 5 caractères.*/
ALTER TABLE restaurants add constraint restaurant_address_min_length check
    (  length(trim(address)) >= 5 );

/*La ville doit avoir au minimum une longueur de 3 caractères.*/
ALTER TABLE restaurants add constraint restaurant_city_min_length check
    (  length(trim(city)) >= 3 );

/*Le numéro de téléphone doit avoir un format de numéro belge valide,
  et peut être encodé avec ou sans espaces de séparation entre les groupes de chiffres.*/
ALTER TABLE restaurants add constraint restaurant_phone_number_format check
    ( replace(phone, ' ', '') ~ '^\+32[1-9]\d{7,8}$' )