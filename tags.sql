-- ============================================================
-- Demo Interattive — i tag diventano più d'uno
-- Incolla nello SQL Editor del progetto Supabase ed esegui.
-- Si può rieseguire senza danni.
-- ============================================================

-- Una demo parla di più cose insieme: "Apple Intelligence" e "iPhone",
-- "Accessibilità" e "Mac". Un solo argomento non bastava più.
alter table public.demos add column if not exists tags jsonb not null default '[]'::jsonb;

-- Finché questa colonna non c'era, l'app teneva i tag dentro category,
-- separati da " · ". Qui li rimettiamo al loro posto, uno per uno,
-- rispettando l'ordine: il primo è quello che fa da titolo nell'elenco.
update public.demos
   set tags = (select coalesce(jsonb_agg(trim(both from t) order by i), '[]'::jsonb)
                 from unnest(string_to_array(category, ' · ')) with ordinality as u(t, i)
                where trim(both from t) <> '')
 where tags = '[]'::jsonb
   and coalesce(category, '') <> '';

-- category resta come copia leggibile (i tag uniti da " · "): l'app la
-- scrive comunque, così tornare indietro non perde niente.
