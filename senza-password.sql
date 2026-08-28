-- ============================================================
-- Demo Interattive — togliere la password del team
-- Incolla nello SQL Editor di Supabase ed esegui, POI metti
-- RICHIEDI_PASSWORD = false in cima allo <script> di index.html.
--
-- ATTENZIONE, in chiaro: da qui in avanti chiunque conosca
-- l'indirizzo del sito può leggere e modificare catalogo, nomi
-- delle persone e registro delle demo fatte, senza credenziali.
-- Le tabelle di Store Tasks non vengono toccate: restano dietro
-- il login come prima.
-- ============================================================

-- Le stesse regole che valgono dopo il login, estese a chi non l'ha fatto.
drop policy if exists "people anon" on public.demo_people;
drop policy if exists "demos anon"  on public.demos;
drop policy if exists "runs anon read"   on public.demo_runs;
drop policy if exists "runs anon insert" on public.demo_runs;
drop policy if exists "favs anon"   on public.demo_favorites;

create policy "people anon" on public.demo_people
  for all to anon using (true) with check (true);
create policy "demos anon"  on public.demos
  for all to anon using (true) with check (true);
create policy "runs anon read"   on public.demo_runs
  for select to anon using (true);
create policy "runs anon insert" on public.demo_runs
  for insert to anon with check (true);
create policy "favs anon"   on public.demo_favorites
  for all to anon using (true) with check (true);
-- anche qui nessun update o delete sul registro: una demo fatta resta

-- ------------------------------------------------------------
-- Per tornare indietro: si cancellano le policy qui sopra e si
-- rimette RICHIEDI_PASSWORD = true.
-- ------------------------------------------------------------
-- drop policy if exists "people anon"      on public.demo_people;
-- drop policy if exists "demos anon"       on public.demos;
-- drop policy if exists "runs anon read"   on public.demo_runs;
-- drop policy if exists "runs anon insert" on public.demo_runs;
-- drop policy if exists "favs anon"        on public.demo_favorites;
