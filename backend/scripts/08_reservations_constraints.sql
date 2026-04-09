set search_path to public, auth;


/*  Le statut d'une réservation doit être soit
    pending (en attente de confirmation),
    confirmed (confirmée), cancelled (annulée) ou
    completed (terminée suite à la venue effective du client).
*/
ALTER TABLE reservations
    ALTER COLUMN status TYPE status_type
        USING status::status_type;


/*
Le nombre de convives d'une réservation doit être strictement positif.
*/

ALTER TABLE reservations ADD CONSTRAINT min_guests_number check
    (  number_of_guests > 0 );

/*
Le texte des demandes spéciales d'une réservation (special_requests), s'il est défini,
doit avoir une longueur minimale de 10 caractères.
*/
ALTER TABLE reservations ADD CONSTRAINT description_min_length check
    (
        special_requests is null OR
        length(trim(special_requests)) >= 10
    )