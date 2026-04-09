set search_path to public, auth;

alter table users add constraint full_name_min_length
    check ( length(trim(full_name)) >= 3  );



alter table users add constraint check_password_format
    check (length(trim(password)) >= 8
        AND password ~ '[a-z]'
        AND password ~ '[A-Z]'
        AND password ~ '[0-9]'
        AND password ~ '[,;.:!?/$%&@#]');