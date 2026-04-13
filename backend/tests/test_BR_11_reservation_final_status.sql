set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : RÉSERVATIONS (BR-11)
   ========================================================================= */

/* BR-11 : Une réservation terminée ou annulée ne peut pas être modifiée. */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */

begin;
do $test$
    begin
        raise notice 'TEST: Modification d''une réservation "pending" ou "confirmed" (autorisé)';

        -- 1. On crée une réservation cobaye en 'pending' (Respect de la BR-09)
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (999, 3, 1, current_timestamp + interval '2 days', 2, 'pending');

        -- 2. On modifie le nombre d'invités (ça doit passer)
        update reservations set number_of_guests = 4 where id = 999;
    end
$test$;
rollback;

/* -------------------------------------------------------------------------
   TESTS NÉGATIFS (Doivent échouer)
   ------------------------------------------------------------------------- */

/* Négatif 1 : Statut Completed */
begin;
do $test$
    begin
        raise notice 'TEST: Modification d''une réservation "completed" (doit échouer)';

        -- 1. On crée le cobaye proprement en 'pending' (Respect de la BR-09)
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (888, 3, 1, current_timestamp - interval '2 days', 2, 'pending');

        -- 2. On suit le cycle de vie pour arriver à 'completed'
        update reservations set status = 'confirmed' where id = 888;
        update reservations set status = 'completed' where id = 888;

        -- 3. On tente de modifier le nombre d'invités sur l'ID 888 (bloqué par BR-11)
        perform should_fail($$
            update reservations set number_of_guests = 4 where id = 888;
        $$, 'restrict_violation');
    end
$test$;
rollback;

/* Négatif 2 : Statut Cancelled */
begin;
do $test$
    begin
        raise notice 'TEST: Modification d''une réservation "cancelled" (doit échouer)';

        -- 1. On crée le cobaye proprement en 'pending' (Respect de la BR-09)
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (777, 3, 1, current_timestamp + interval '2 days', 2, 'pending');

        -- 2. On l'annule en suivant le cycle de vie
        update reservations set status = 'cancelled' where id = 777;

        -- 3. On tente de modifier la date sur l'ID 777 (bloqué par BR-11)
        perform should_fail($$
            update reservations set datetime = current_timestamp + interval '5 days' where id = 777;
        $$, 'restrict_violation');
    end
$test$;
rollback;