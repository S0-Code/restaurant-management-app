set search_path to public, auth;

/**************************************************************
 Fonction qui permet de vérifier si un email est disponible
 **************************************************************/
create or replace function check_email_available(p_email text) returns boolean as
$$
begin
    return not exists(select 1 from users where lower(users.email) = lower(p_email));
end;
$$ language plpgsql security definer;

grant execute on function check_email_available to anon;

/**************************************************************
 Fonction qui permet de vérifier si un nom complet est disponible
 **************************************************************/
create or replace function check_fullname_available(p_full_name text) returns boolean as
$$
begin
    return not exists(select 1 from users where lower(users.full_name) = lower(p_full_name));
end;
$$ language plpgsql security definer;

grant execute on function check_fullname_available to anon;

/**************************************************************
 Fonction signup (Inscription)
 **************************************************************/
create or replace function signup(p_email text, p_password text, p_full_name text, p_phone text default null) returns void
as
$$
begin
    -- 1. On vérifie d'abord si l'email est libre
    if not check_email_available(p_email) then
        raise exception 'L''email ''%'' est déjà utilisé', p_email;
    end if;

    -- 2. On insère le nouvel utilisateur
    insert into users (email, password, full_name, phone)
    values (p_email, p_password, p_full_name, p_phone);
end;
$$ language plpgsql security definer;

grant execute on function signup to anon;

-- On dit à PostgREST de recharger le schéma
NOTIFY pgrst, 'reload schema';