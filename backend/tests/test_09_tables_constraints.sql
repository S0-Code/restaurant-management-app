set search_path to public, auth;

/*La capacité doit être strictement positive.*/
begin;
do $test$
    begin
        raise notice 'TEST: capacité > 0 correct (insert)';

        insert into tables (restaurant, capacity, table_number)
        values (1, 4, 55);

    end;
$test$;
rollback;


begin;
do $test$
    begin
        raise notice 'TEST: capacité > 0 incorrect (insert)';

        perform should_fail($$
            insert into tables (restaurant, capacity, table_number)
            values (1, 0, 55)
        $$, 'check_violation');

    end;
$test$;
rollback;


begin;
do $test$
    declare
        table_id int;
    begin
        raise notice 'TEST: capacité > 0 correct (update)';

        insert into tables (restaurant, capacity, table_number)
        values (1, 4, 55)
        returning id into table_id;

        update tables
        set capacity = 6
        where id = table_id;

    end;
$test$;
rollback;


begin;
do $test$
    declare
        table_id int;
    begin
        raise notice 'TEST: capacité > 0 incorrect (update)';

        insert into tables (restaurant, capacity, table_number)
        values (1, 4, 55)
        returning id into table_id;

        perform should_fail($$
            update tables
            set capacity = 0
            where id = $$ || table_id
            , 'check_violation');

    end;
$test$;
rollback;


/*Le numéro de table doit être strictement positif.*/
begin;
do $test$
    begin
        raise notice 'TEST: numéro de table > 0 correct (insert)';

        insert into tables (restaurant, table_number, capacity)
        values (1, 10, 4);

    end;
$test$;
rollback;

/*Le numéro de table doit être strictement positif.*/
begin;
do $test$
    begin
        raise notice 'TEST: numéro de table > 0 incorrect (insert)';

        perform should_fail($$
            insert into tables (restaurant, table_number, capacity)
            values (1, 0, 4)
        $$, 'check_violation');

    end;
$test$;
rollback;

/*Le numéro de table doit être strictement positif.*/
begin;
do $test$
    declare
        table_id int;
    begin
        raise notice 'TEST: numéro de table > 0 correct (update)';

        insert into tables (restaurant, table_number, capacity)
        values (1, 10, 4)
        returning id into table_id;

        update tables
        set table_number = 20
        where id = table_id;

    end;
$test$;
rollback;

/*Le numéro de table doit être strictement positif.*/
begin;
do $test$
    declare
        table_id int;
    begin
        raise notice 'TEST: numéro de table > 0 incorrect (update)';

        insert into tables (restaurant, table_number, capacity)
        values (1, 10, 4)
        returning id into table_id;

        perform should_fail($$
            update tables
            set table_number = 0
            where id = $$ || table_id
            , 'check_violation');

    end;
$test$;
rollback;



/*Le numéro de table doit être unique au sein d'un même restaurant.*/
begin;
do $test$
    begin
        raise notice 'TEST: unicité numéro table par restaurant correct (insert)';

        insert into tables (restaurant, table_number, capacity)
        values (1, 10, 4);

        insert into tables (restaurant, table_number, capacity)
        values (1, 4, 4);

    end;
$test$;
rollback;

/*Le numéro de table doit être unique au sein d'un même restaurant.*/
begin;
do $test$
    begin
        raise notice 'TEST: unicité numéro table par restaurant incorrect (insert)';

        perform should_fail($$
            insert into tables (restaurant, table_number, capacity)
            values (1, 10, 4);

            insert into tables (restaurant, table_number, capacity)
            values (1, 10, 5);
        $$, 'unique_violation');

    end;
$test$;
rollback;

/*Le numéro de table doit être unique au sein d'un même restaurant.*/
begin;
do $test$
    declare
        t1 int;
        t2 int;
    begin
        raise notice 'TEST: unicité numéro table par restaurant correct (update)';

        insert into tables (restaurant, table_number, capacity)
        values (1, 10, 4)
        returning id into t1;

        insert into tables (restaurant, table_number, capacity)
        values (1, 4, 4)
        returning id into t2;

        update tables
        set table_number = 7
        where id = t2;

    end;
$test$;
rollback;

/*Le numéro de table doit être unique au sein d'un même restaurant.*/
begin;
do $test$
    declare
        t1 int;
        t2 int;
    begin
        raise notice 'TEST: unicité numéro table par restaurant incorrect (update)';

        insert into tables (restaurant, table_number, capacity)
        values (1, 10, 4)
        returning id into t1;

        insert into tables (restaurant, table_number, capacity)
        values (1, 4, 4)
        returning id into t2;

        perform should_fail($$
            update tables
            set table_number = 10
            where id = $$ || t2
            , 'unique_violation');

    end;
$test$;
rollback;