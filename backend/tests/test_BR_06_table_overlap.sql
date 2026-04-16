set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : RÉSERVATIONS (BR-06 Chevauchement de tables)
   ========================================================================= */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */
begin;
do $test$
    begin
        raise notice 'TEST: Deux réservations confirmées sur des tables DIFFÉRENTES (autorisé)';

        -- 1. Création de deux réservations le même jour, dans le même créneau horaire (ex: Service du soir)
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (101, 3, 1, '2026-06-05 20:00:00', 2, 'pending'),
               (102, 4, 1, '2026-06-05 20:30:00', 2, 'pending');

        -- 2. On les confirme toutes les deux
        update reservations set status = 'confirmed' where id = 101;
        update reservations set status = 'confirmed' where id = 102;

        -- 3. Affectation à des tables différentes (ex: table 1 et table 2)
        -- (Si les tables 1 et 2 n'existent pas dans ton jeu de test, modifie ces numéros)
        insert into reservation_tables (reservation, "table") values (101, 1);
        insert into reservation_tables (reservation, "table") values (102, 2);
    end
$test$;
rollback;


/* -------------------------------------------------------------------------
   TESTS NÉGATIFS (Doivent échouer)
   ------------------------------------------------------------------------- */
begin;
do $test$
    begin
        raise notice 'TEST: Double réservation de la MÊME table pour le MÊME service (doit échouer)';

        -- 1. Création de deux réservations concurrentes
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (201, 3, 1, '2026-06-05 20:00:00', 2, 'pending'),
               (202, 4, 1, '2026-06-05 20:30:00', 2, 'pending');

        -- 2. On confirme la première et on lui donne la table 1
        update reservations set status = 'confirmed' where id = 201;
        insert into reservation_tables (reservation, "table") values (201, 1);

        -- 3. On confirme la deuxième
        update reservations set status = 'confirmed' where id = 202;

        -- 4. Tentative de lui donner AUSSI la table 1 (La BR-06 doit bloquer l'action !)
        perform should_fail($$
            insert into reservation_tables (reservation, "table") values (202, 1);
        $$, 'restrict_violation');
    end
$test$;
rollback;