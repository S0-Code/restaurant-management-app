set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : SERVICES (BR-08 Alignement des créneaux horaires)
   ========================================================================= */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */
begin;
do $test$
    declare
        restaurant_id bigint;
        service_id bigint;
    begin
        raise notice 'TEST: Insertion et modification avec des heures parfaitement alignées';

        -- Création d'un restaurant spécifique pour ce test (créneaux de 30 min)
        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR08 Alignement OK', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        -- Insertion valide (12:00 à 14:30)
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 1, '12:00:00', '14:30:00')
        returning id into service_id;

        -- Modification avec des valeurs toujours alignées (19:30 à 22:00)
        update services
        set start_time = '19:30:00', end_time = '22:00:00'
        where id = service_id;

    end;
$test$;
rollback;


/* -------------------------------------------------------------------------
   TESTS NÉGATIFS (Doivent échouer)
   ------------------------------------------------------------------------- */

/* Négatif 1 : Minutes de début non alignées (Insert) */
begin;
do $test$
    declare
        restaurant_id bigint;
    begin
        raise notice 'TEST: Heure de début non alignée (12:15 pour un créneau de 30) (doit échouer)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR08 Start KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        perform should_fail(
                'insert into services (restaurant, day_of_week, start_time, end_time)
                 values (' || restaurant_id || ', 1, ''12:15:00'', ''14:30:00'')',
                'raise_exception'
                );
    end;
$test$;
rollback;


/* Négatif 2 : Minutes de fin non alignées (Insert) */
begin;
do $test$
    declare
        restaurant_id bigint;
    begin
        raise notice 'TEST: Heure de fin non alignée (14:40 pour un créneau de 30) (doit échouer)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR08 End KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        perform should_fail(
                'insert into services (restaurant, day_of_week, start_time, end_time)
                 values (' || restaurant_id || ', 2, ''12:00:00'', ''14:40:00'')',
                'raise_exception'
                );
    end;
$test$;
rollback;



/* Négatif 3 : Présence de secondes (Insert) */
begin;
do $test$
    declare
        restaurant_id bigint;
    begin
        raise notice 'TEST: Heure contenant des secondes (12:00:30) (doit échouer)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR08 Sec KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        perform should_fail(
                'insert into services (restaurant, day_of_week, start_time, end_time)
                 values (' || restaurant_id || ', 3, ''12:00:30'', ''14:30:00'')',
                'raise_exception'
                );
    end;
$test$;
rollback;



/* Négatif 4 : Modification rendant l'heure non alignée (Update) */
begin;
do $test$
    declare
        restaurant_id bigint;
        service_id bigint;
    begin
        raise notice 'TEST: Modification vers une heure non alignée (doit échouer)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR08 Update KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        -- Insertion initiale valide
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 4, '12:00:00', '14:30:00')
        returning id into service_id;

        -- Tentative de mise à jour invalide
        perform should_fail(
                'update services
                 set start_time = ''12:10:00''
                 where id = ' || service_id,
                'raise_exception'
                );
    end;
$test$;
rollback;