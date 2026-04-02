set search_path to public, auth;

alter table users add constraint full_name_min_length
    check ( length(trim(full_name)) >= 3  );

