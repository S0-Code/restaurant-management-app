set search_path to public, auth;

begin;
do
$test$
    begin
        raise notice 'TEST: longueur full name correct';
        INSERT INTO users (email, password, full_name, role, phone)
        VALUES ('test@test.com', 'Password1,', 'test', 'client', '0484632159');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST: longueur full name Incorrect';
        perform should_fail($$
    INSERT INTO users (email, password, full_name, role, phone)
    VALUES ('test@test.com', 'Password1,', 'te', 'client', '0484632159');
$$, 'check_violation');
    end;
$test$;
rollback;

