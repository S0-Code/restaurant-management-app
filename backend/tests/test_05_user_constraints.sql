set search_path to public, auth;

begin;
do
$test$
    begin
        raise notice 'TEST: longueur full name correct (insert)';
        INSERT INTO users (email, password, full_name, role, phone)
        VALUES ('test@test.com', 'Password1,', 'test', 'client', '0484632159');
    end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST: longueur full name Incorrect (insert)';
        perform should_fail($$
    INSERT INTO users (email, password, full_name, role, phone)
    VALUES ('test@test.com', 'Password1,', 'te', 'client', '0484632159');
$$, 'check_violation');
    end;
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'TEST: longueur full name correct (update)';

        INSERT INTO users (email, password, full_name, role, phone)
        VALUES ('test_update_full_name_ok@test.com', 'Password1,', 'validname', 'client', '0484632159');

        UPDATE users
        SET full_name = 'newname'
        WHERE email = 'test_update_full_name_ok@test.com';

    end;
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'TEST: longueur full name incorrect (update)';


        INSERT INTO users (email, password, full_name, role, phone)
        VALUES ('test_update_full_name_nok@test.com', 'Password1,', 'validname', 'client', '0484632159');

        perform should_fail($$
        UPDATE users
        SET full_name = 'te'
        WHERE email = 'test_update_full_name_nok@test.com';
    $$, 'check_violation');
    end;
$test$;
rollback;



begin;
do
$test$
    begin
        raise notice 'TEST: Format password correct (insert)';

        INSERT INTO users (email, password, full_name, role, phone)
        VALUES ('test_insert_password_ok@test.com', 'Password1,', 'validname', 'client', '0484632159');

    end;
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'TEST: Format password incorrect (insert)';


        perform should_fail(
                $$
                INSERT INTO users (email, password, full_name, role, phone)
        VALUES ('test_insert_password_nok@test.com', 'Password1', 'validname', 'client', '0484632159');
        $$, 'check_violation');

    end;
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'TEST: Format password correct (update)';

        INSERT INTO users (email, password, full_name, role, phone)
        VALUES ('test_update_password_ok@test.com', 'Password1,', 'validname', 'client', '0484632159');


        UPDATE users
        SET password = 'Password2,'
        WHERE  email = 'test_update_password_ok@test.com';


    end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST: Format password incorrect (update)';

        INSERT INTO users (email, password, full_name, role, phone)
        VALUES ('test_update_password_nok@test.com', 'Password1,', 'validname', 'client', '0484632159');

        perform should_fail(
                $$
                UPDATE users
        SET password = 'Password1'
        WHERE  email = 'test_update_password_nok@test.com';
        $$, 'check_violation');

    end;
$test$;
rollback;
