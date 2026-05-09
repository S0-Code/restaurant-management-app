set search_path to public;

/* -------------------------------------------------------------------------
   (BR-10) Un restaurant doit avoir au moins un manager.
   ------------------------------------------------------------------------- */

/* Analyse
Tables concernées :
- restaurant_managers :
    - insert : non (ajouter un nouveau manager à un restaurant ne risque pas de le laisser vide)
    - update : oui (si on réassigne un manager à un autre restaurant, son ancien restaurant pourrait se retrouver avec 0 manager)
    - delete : oui (supprimer l'assignation d'un manager pourrait laisser le restaurant avec 0 manager)
- restaurants :
    - insert : non (On doit d'abord créé un restaurant et ensuite le manager)
    - update : non (modifier n'affecte pas ses managers)
    - delete : non (supprimer le restaurant entraîne la suppression en cascade de ses managers, le restaurant n'existant plus, la règle ne s'applique plus)
*/

create or replace function check_minimum_manager()
    returns trigger as $$
declare
v_count int;
begin
    -- 1. On compte combien de managers il reste pour le restaurant impacté
    -- (On utilise "old.restaurant" car on s'intéresse au restaurant que le manager quitte)
select count(*) into v_count
from restaurant_managers
where restaurant = old.restaurant;

-- 2. Si le compteur est à 0, on lève l'exception
if v_count = 0 then
        raise exception 'Un restaurant doit avoir au moins un manager.';
end if;

return null;
end;
$$ language plpgsql;

/* -------------------------------------------------------------------------
   TRIGGER
   ------------------------------------------------------------------------- */
drop trigger if exists trg_check_minimum_manager on restaurant_managers;
create trigger trg_check_minimum_manager
    after delete or update on restaurant_managers
                        for each row
                        execute function check_minimum_manager();