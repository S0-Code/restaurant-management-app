create or replace function get_simulated_time()
returns timestamp
language sql
security definer
as $$
select simulated_time
from system_time
         limit 1;
$$;

grant execute on function get_simulated_time() to authenticated;

notify pgrst, 'reload schema';

create or replace function set_simulated_time(p_time timestamp)
returns void
language sql
security definer
as $$
update system_time
set simulated_time = p_time;
$$;

grant execute on function set_simulated_time(timestamp) to authenticated;

notify pgrst, 'reload schema';