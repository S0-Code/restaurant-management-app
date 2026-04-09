set search_path to public;


/* La description, si elle est fournie, doit avoir au min 10 caractères. */

/* Test Positif */
begin;
do $test$
    begin
        raise notice 'TEST: Description valide (>= 10)';
        insert into restaurants (id, name, address, city, phone)
        values (1, 'Test Description', 'Rue du Test', 'Bruxelles', '0470112233');

        update restaurants set description = 'Une description de plus de dix caractères' where id = 1;
    end
$test$;
rollback;

/* Test Négatif */
begin;
do $test$
    begin
        raise notice 'TEST: Description trop courte (doit échouer)';
        perform should_fail($$
            insert into restaurants (name, address, city, phone, description)
            values ('Test Description Fail', 'Rue du Test', 'Bruxelles', '0470112233', 'Court');
        $$, 'check_violation');
    end
$test$;
rollback;


/* La note doit être comprise entre 0.0 et 5.0 si elle est définie. */

/* Test Positif */
begin;
do $test$
    begin
        raise notice 'TEST: La note doit être comprise entre 0.0 et 5.0';
        insert into restaurants (id, name, address, city, phone)
        values (1, 'Test Note', 'Rue du Test', 'Bruxelles', '0470112233');

        update restaurants set rating = 0.0 where id = 1;
        update restaurants set rating = 1.5 where id = 1;
        update restaurants set rating = 2.0 where id = 1;
        update restaurants set rating = 3.5 where id = 1;
        update restaurants set rating = 4.5 where id = 1;
        update restaurants set rating = 5.0 where id = 1;

    end
$test$;
rollback;

/* Test Négatif */
begin;
do $test$
    begin
        raise notice 'TEST: La note n''est pas comprise entre 0.0 et 5.0 (doit échouer)';
        perform should_fail($$
            insert into restaurants (name, address, city, phone, rating)
            values ('Test Note Fail', 'Rue du Test', 'Bruxelles', '0470112233', 6.0);
        $$, 'check_violation');
    end
$test$;
rollback;


/* La fourchette de prix doit être comprise entre 1 et 4 si elle est définie. */

/* Test Positif */
begin;
do $test$
    begin
        raise notice 'TEST: La fourchette de prix doit être comprise entre 1 et 4';
        insert into restaurants (id, name, address, city, phone)
        values (1, 'Test Prix', 'Rue du Test', 'Bruxelles', '0470112233');

        update restaurants set price_range = 3 where id = 1;
        update restaurants set price_range = 3 where id = 2;
        update restaurants set price_range = 3 where id = 3;
        update restaurants set price_range = 3 where id = 4;

    end
$test$;
rollback;

/* Test Négatif */
begin;
do $test$
    begin
        raise notice 'TEST: La fourchette de prix n''est pas comprise entre 1 et 4 (doit échouer)';
        perform should_fail($$
            insert into restaurants (name, address, city, phone, price_range)
            values ('Test Prix Fail', 'Rue du Test', 'Bruxelles', '0470112233', 5);
        $$, 'check_violation');
    end
$test$;
rollback;


/* La durée de créneau de réservation doit être soit 10, 15, 20, 30 ou 60 minutes. */

/* Test Positif */
begin;
do $test$
    begin
        raise notice 'TEST: Slot duration valide (30)';
        insert into restaurants (id, name, address, city, phone)
        values (1, 'Test Slot', 'Rue du Test', 'Bruxelles', '0470112233');

        update restaurants set slot_duration = 10 where id = 1;
        update restaurants set slot_duration = 15 where id = 1;
        update restaurants set slot_duration = 20 where id = 1;
        update restaurants set slot_duration = 30 where id = 1;
        update restaurants set slot_duration = 60 where id = 1;

    end
$test$;
rollback;

/* Test Négatif */
begin;
do $test$
    begin
        raise notice 'TEST: Slot duration invalide (25) (doit échouer)';
        perform should_fail($$
            insert into restaurants (name, address, city, phone, slot_duration)
            values ('Test Slot Fail', 'Rue du Test', 'Bruxelles', '0470112233', 25);
        $$, 'check_violation');
    end
$test$;
rollback;

