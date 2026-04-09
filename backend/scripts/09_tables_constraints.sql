set search_path to public, auth;

/*
La capacité doit être strictement positive.
*/

ALTER TABLE tables add constraint min_capacity check
    ( capacity > 0 );

/*
Le numéro de table doit être strictement positif et unique au sein d'un même restaurant.
*/
ALTER TABLE tables add constraint min_table_number check
    ( table_number > 0 );

ALTER TABLE tables add constraint table_number_unicity UNIQUE
    ( restaurant, table_number );