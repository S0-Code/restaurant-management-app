set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : MANAGERS (BR-10 Minimum un manager par restaurant)
   ========================================================================= */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */
begin;
do $test$
    declare
manager1_id bigint;
        manager2_id bigint;
        restaurant_id bigint;
begin
        raise notice 'TEST: Suppression d un manager quand il en reste un autre (autorisé)';

        -- Création de deux managers
insert into users (email, full_name, password, role)
values ('m1_br10@test.com', 'Manager 1', 'Pass123.', 'manager')
    returning id into manager1_id;

insert into users (email, full_name, password, role)
values ('m2_br10@test.com', 'Manager 2', 'Pass123.', 'manager')
    returning id into manager2_id;

-- Création d'un restaurant
insert into restaurants (name, address, city, phone, slot_duration)
values ('Resto BR10 OK', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
    returning id into restaurant_id;

-- Ajout des deux managers au restaurant
insert into restaurant_managers (restaurant, manager) values (restaurant_id, manager1_id);
insert into restaurant_managers (restaurant, manager) values (restaurant_id, manager2_id);

-- Suppression d'un seul manager (doit réussir car il en reste un)
delete from restaurant_managers where restaurant = restaurant_id and manager = manager1_id;

set constraints all immediate;
end;
$test$;
rollback;


/* -------------------------------------------------------------------------
   TESTS NÉGATIFS (Doivent échouer)
   ------------------------------------------------------------------------- */

/* Négatif 1 : Création d'un restaurant sans manager */
begin;
do $test$
begin
        raise notice 'TEST: Création d un restaurant sans manager (doit échouer)';

        perform should_fail(
                'insert into restaurants (name, address, city, phone, slot_duration)
                 values (''Resto BR10 Vide'', ''Rue du Test'', ''Bruxelles'', ''+32 485 65 69 12'', 30)',
                'raise_exception'
                );
end;
$test$;
rollback;


/* Négatif 2 : Suppression du dernier manager */
begin;
do $test$
    declare
manager_id bigint;
        restaurant_id bigint;
begin
        raise notice 'TEST: Suppression du dernier manager (doit échouer)';

insert into users (email, full_name, password, role)
values ('m_solo_br10@test.com', 'Manager Solo', 'Pass123.', 'manager')
    returning id into manager_id;

insert into restaurants (name, address, city, phone, slot_duration)
values ('Resto BR10 Delete KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
    returning id into restaurant_id;

insert into restaurant_managers (restaurant, manager) values (restaurant_id, manager_id);

-- Tentative de suppression du seul manager
perform should_fail(
                'delete from restaurant_managers where restaurant = ' || restaurant_id || ' and manager = ' || manager_id,
                'raise_exception'
                );
end;
$test$;
rollback;


/* Négatif 3 : Modification (Update) du dernier manager vers un autre restaurant */
begin;
do $test$
    declare
manager_id bigint;
        restaurant1_id bigint;
        restaurant2_id bigint;
begin
        raise notice 'TEST: Déplacement du dernier manager vers un autre restaurant (doit échouer)';

insert into users (email, full_name, password, role)
values ('m_move_br10@test.com', 'Manager Move', 'Pass123.', 'manager')
    returning id into manager_id;

insert into restaurants (name, address, city, phone, slot_duration)
values ('Resto BR10 Move 1', 'Rue 1', 'Bruxelles', '+32 485 65 69 12', 30)
    returning id into restaurant1_id;

insert into restaurants (name, address, city, phone, slot_duration)
values ('Resto BR10 Move 2', 'Rue 2', 'Bruxelles', '+32 485 65 69 12', 30)
    returning id into restaurant2_id;

-- On assigne le manager au Resto 1
insert into restaurant_managers (restaurant, manager) values (restaurant1_id, manager_id);

-- Tentative de déplacer ce manager vers le Resto 2
perform should_fail(
                'update restaurant_managers set restaurant = ' || restaurant2_id || ' where restaurant = ' || restaurant1_id || ' and manager = ' || manager_id,
                'raise_exception'
                );
end;
$test$;
rollback;