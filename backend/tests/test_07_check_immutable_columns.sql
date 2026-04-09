set search_path to public;

/* =========================================================================
   TESTS DES RÈGLES D'IMMUTABILITÉ (prevent_column_update)
   ========================================================================= */

/* -------------------------------------------------------------------------
   BR: On ne peut pas modifier le rôle d'un utilisateur.
   ------------------------------------------------------------------------- */

/* Test Négatif (Ce qui est interdit) */
begin;
do $test$
    begin
        raise notice 'TEST: Modification du rôle utilisateur (doit échouer)';

        perform should_fail($$
            -- On tente de changer le rôle de l'utilisateur existant (id = 3) en 'manager'
            -- Cela doit planter grâce à notre trigger
            update users set role = 'manager' where id = 3;
        $$, 'restrict_violation');
    end
$test$;
rollback;


/* -------------------------------------------------------------------------
   BR: On ne peut pas modifier le restaurant d'une table.
   ------------------------------------------------------------------------- */

/* Test Négatif (Ce qui est interdit) */
begin;
do $test$
    begin
        raise notice 'TEST: Modification du restaurant de la table (doit échouer)';

        -- 1. On prépare DEUX restaurants cobayes
        insert into restaurants (id, name, address, city, phone)
        values (999, 'Test Resto Départ', 'Rue du Test', 'Bruxelles', '0470112233');

        insert into restaurants (id, name, address, city, phone)
        values (888, 'Test Resto Arrivée', 'Avenue du Test', 'Bruxelles', '0470445566');

        -- 2. On crée la table cobaye liée au premier restaurant (999)
        insert into tables (id, table_number, capacity, restaurant)
        values (999, 10, 4, 999);

        -- 3. On tente de transférer la table vers le deuxième restaurant (888)
        perform should_fail($$
            update tables set restaurant = 888 where id = 999;
        $$, 'restrict_violation');
    end
$test$;
rollback;
