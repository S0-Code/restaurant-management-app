set search_path to public, auth;

/* Le nom complet doit avoir une longueur d'au moins 3 caractères.*/

    alter table users add constraint full_name_min_length
    check ( length(trim(full_name)) >= 3  );


/* Le mot de passe doit avoir au minimum une longueur de 8 caractères,
   doit contenir au moins un chiffre, une lettre majuscule,
   une lettre minuscule et un caractère spécial parmi les suivants : ,;.:!?/$%&@#. */

alter table users add constraint check_password_format
    check (length(trim(password)) >= 8
        AND password ~ '[a-z]'
        AND password ~ '[A-Z]'
        AND password ~ '[0-9]'
        AND password ~ '[,;.:!?/$%&@#]');

/* Le mot de passe doit être stocké de manière sécurisée (hachage + sel). */
    /*  function auth.encrypt_pass() est déjà dans Security


/*On ne peut pas modifier le rôle d'un utilisateur.*/
        Va être fait dans check_immutable_columns.sql
     */
