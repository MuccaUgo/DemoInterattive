-- ============================================================
-- Demo Interattive — schema del catalogo
-- Incolla nello SQL Editor del progetto Supabase ed esegui.
-- Si può rieseguire senza danni: crea solo quello che manca.
-- Non tocca le tabelle di Store Tasks.
-- ============================================================

-- Chi usa l'app. Ci si registra la prima volta scegliendo un nome e un
-- codice di 6 cifre. Il codice non viene mai salvato: si salva solo la
-- sua impronta (SHA-256 con un sale casuale), che non si può ricalcolare
-- a ritroso. Serve a riconoscersi da un altro telefono, non a proteggere
-- segreti: la porta di casa resta la password del team.
create table if not exists public.demo_people (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  salt text not null,
  code_hash text not null,
  created_at timestamptz not null default now()
);

-- Una demo = una scheda del catalogo: cosa mostrare, a chi, e come.
-- I passi stanno in jsonb perché si scrivono e si leggono sempre insieme.
create table if not exists public.demos (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'iPhone',   -- iPhone · iPad · Mac · Watch · Audio · Servizi · Altro
  hook text,                                 -- la frase con cui si apre
  who text,                                  -- a quale cliente sta bene
  duration text not null default 'breve',    -- lampo · breve · completa
  level text not null default 'facile',      -- facile · media · avanzata
  steps jsonb not null default '[]'::jsonb,  -- i passaggi da dire al cliente, in ordine
  needs text,                                -- cosa serve prima di iniziare
  benefits jsonb not null default '[]'::jsonb, -- i vantaggi con cui si chiude
  owner text,                                -- chi tiene aggiornata la scheda
  status text not null default 'bozza',      -- bozza · pronta · ritirata
  created_by text,                           -- chi l'ha scritta
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists demos_lookup on public.demos (status, category, position);
alter table public.demos add column if not exists created_by text;
alter table public.demos add column if not exists benefits jsonb not null default '[]'::jsonb;

-- Ogni volta che una demo viene fatta davvero in reparto.
-- In sola aggiunta: è il registro che dice quali demo vivono
-- sul pavimento del negozio e quali restano solo scritte.
create table if not exists public.demo_runs (
  id bigint generated always as identity primary key,
  demo_id uuid not null references public.demos(id) on delete cascade,
  actor_name text not null,
  outcome text not null default 'ok',        -- wow · ok · fiacca
  note text,
  created_at timestamptz not null default now()
);
create index if not exists demo_runs_lookup on public.demo_runs (demo_id, created_at);

-- Le preferite: ognuno ha le sue, legate al nome scelto nel profilo.
-- Sono le demo che uno vuole avere sottomano, non una classifica.
create table if not exists public.demo_favorites (
  id bigint generated always as identity primary key,
  demo_id uuid not null references public.demos(id) on delete cascade,
  person_name text not null,
  created_at timestamptz not null default now(),
  unique (demo_id, person_name)
);
create index if not exists demo_favorites_lookup on public.demo_favorites (person_name);

-- ------------------------------------------------------------
-- Accesso: si legge e si scrive solo dopo il login
-- ------------------------------------------------------------
alter table public.demo_people    enable row level security;
alter table public.demos          enable row level security;
alter table public.demo_runs      enable row level security;
alter table public.demo_favorites enable row level security;

drop policy if exists "people all"  on public.demo_people;
drop policy if exists "demos all"   on public.demos;
drop policy if exists "runs read"   on public.demo_runs;
drop policy if exists "runs insert" on public.demo_runs;
drop policy if exists "favs all"    on public.demo_favorites;

create policy "people all"  on public.demo_people
  for all to authenticated using (true) with check (true);
create policy "demos all"   on public.demos
  for all to authenticated using (true) with check (true);
create policy "runs read"   on public.demo_runs
  for select to authenticated using (true);
create policy "runs insert" on public.demo_runs
  for insert to authenticated with check (true);
create policy "favs all"    on public.demo_favorites
  for all to authenticated using (true) with check (true);
-- volutamente nessuna policy di update o delete: una demo fatta resta

-- ------------------------------------------------------------
-- Aggiornamenti in tempo reale sugli altri telefoni
-- ------------------------------------------------------------
do $$
begin
  alter publication supabase_realtime add table public.demo_people;
exception when duplicate_object then null;
end $$;
do $$
begin
  alter publication supabase_realtime add table public.demos;
exception when duplicate_object then null;
end $$;
do $$
begin
  alter publication supabase_realtime add table public.demo_runs;
exception when duplicate_object then null;
end $$;
do $$
begin
  alter publication supabase_realtime add table public.demo_favorites;
exception when duplicate_object then null;
end $$;


-- ------------------------------------------------------------
-- Il catalogo di partenza: le demo raccolte dal team, riscritte
-- come si dicono al cliente. Ogni scheda chiude sui vantaggi.
-- Si corregge tutto dall'app: qui serve solo a non partire vuoti.
-- ------------------------------------------------------------
do $$
begin
  if exists (select 1 from public.demos) then return; end if;

  insert into public.demos
    (name, category, hook, who, duration, level, steps, benefits, needs, status, position)
  values

  ('Intelligenza visiva e annunci', 'Apple Intelligence',
   'Se dovessi rivendere quella giacca online, sapresti come descriverla?',
   'Chi vende sui marketplace, genitori con i vestiti dei figli da rivendere',
   'lampo', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di prendere il suo iPhone e tenere premuto il tasto Controllo fotocamera',
     'Fagli inquadrare un oggetto che ha con sé — una giacca, una borsa — e scattare',
     'Digli di toccare Chiedi e di farsi scrivere la descrizione per l''annuncio'
   ]),
   to_jsonb(array[
     'Pubblichi l''annuncio in un minuto invece che in un quarto d''ora',
     'La descrizione è completa e vende meglio, anche quando non sai da dove iniziare'
   ]),
   'iPhone del cliente con Apple Intelligence attiva e connessione',
   'pronta', 1),

  ('Fotocamera con inversione colori', 'Accessibilità',
   'Ti faccio vedere come si trova quello che a occhio nudo non si vede?',
   'Chi ha animali, chi fatica a distinguere i dettagli, chi lavora con oggetti scuri',
   'breve', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di aprire Impostazioni e andare in Accessibilità',
     'Guidalo in Schermo e dimensione testo e fagli attivare Inversione classica',
     'Digli di aprire la fotocamera e inquadrare un tessuto scuro o il pelo di un animale'
   ]),
   to_jsonb(array[
     'Trovi forasacchi, schegge e macchie che sul colore normale spariscono',
     'Lo schermo diventa più leggibile quando gli occhi sono stanchi'
   ]),
   'Un iPhone qualsiasi. A fine demo ricordati di rimettere l''inversione su No',
   'pronta', 2),

  ('Sostituzione testo', 'Tastiera e testo',
   'Quante volte al mese scrivi per intero il tuo codice fiscale?',
   'Chi ripete sempre gli stessi dati: IBAN, codice fiscale, indirizzo, email',
   'lampo', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di aprire Impostazioni, poi Generali e Tastiera',
     'Fagli toccare Sostituzione testo e poi il +',
     'Digli di scrivere una frase che usa spesso e la sua abbreviazione, poi di provarla in Note'
   ]),
   to_jsonb(array[
     'Il codice fiscale o l''IBAN escono con tre lettere, senza sbagliare una cifra',
     'Vale in tutte le app e su tutti i dispositivi con lo stesso ID Apple'
   ]),
   'Un iPhone qualsiasi: la funzione c''è da sempre',
   'pronta', 3),

  ('La continuità del copia e incolla', 'Continuity',
   'Ti capita di mandarti dei link da solo, per ritrovarli sul computer?',
   'Chi ha già l''iPhone e sta guardando un Mac',
   'breve', 'media',
   to_jsonb(array[
     'Chiedi al cliente di copiare un link o due righe di testo dal suo iPhone',
     'Portalo davanti al Mac in esposizione e apri Note',
     'Digli di incollare: quello che ha copiato sul telefono è già lì'
   ]),
   to_jsonb(array[
     'Niente più messaggi mandati a te stesso per spostare due righe',
     'Funziona anche con foto e file: si copia di là, si incolla di qua'
   ]),
   'Mac e iPhone con lo stesso ID Apple, Bluetooth e Wi-Fi accesi',
   'pronta', 4),

  ('Intelligenza visiva in cucina', 'Apple Intelligence',
   'Hai ricette scritte a mano che non hai mai digitalizzato?',
   'Chi cucina, chi ha ospiti con esigenze alimentari diverse',
   'breve', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di attivare Intelligenza visiva tenendo premuto il tasto Controllo fotocamera',
     'Fagli inquadrare una ricetta scritta a mano, un menù o un''etichetta',
     'Digli di toccare Chiedi e domandare una variante: senza glutine, vegetariana, per sei persone'
   ]),
   to_jsonb(array[
     'La ricetta della nonna diventa una versione per chi ha intolleranze, in pochi secondi',
     'Funziona anche al ristorante o al supermercato, su qualsiasi etichetta'
   ]),
   'iPhone con Apple Intelligence attiva. Tieni una ricetta stampata sotto il banco',
   'pronta', 5),

  ('Intelligenza visiva e sneakers', 'Apple Intelligence',
   'Ti è mai capitato di vedere delle scarpe per strada e non sapere che modello fossero?',
   'Ragazzi, chi segue le mode, chi compra online',
   'lampo', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di attivare Intelligenza visiva dal tasto Controllo fotocamera',
     'Fagli inquadrare le sue scarpe — o le tue',
     'Digli di toccare Cerca e guardare modello e prezzi che compaiono'
   ]),
   to_jsonb(array[
     'Scopri modello e prezzo di quello che vedi, senza chiedere a nessuno',
     'Confronti dove conviene comprarlo prima di decidere'
   ]),
   'iPhone con Apple Intelligence attiva e connessione',
   'pronta', 6),

  ('Trovare i contatti dal tastierino', 'Telefono e contatti',
   'Come cerchi un contatto quando hai fretta e una mano sola?',
   'Chi ha la rubrica piena, chi chiama in auto o mentre cammina',
   'lampo', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di aprire Telefono e andare su Tastierino',
     'Digli di comporre le lettere di un nome usando i tasti con le lettere corrispondenti',
     'Fagli toccare il contatto che compare per chiamare'
   ]),
   to_jsonb(array[
     'Trovi la persona senza scorrere la rubrica e senza uscire dal tastierino',
     'Ci arrivi con una mano sola, mentre stai facendo altro'
   ]),
   'Un iPhone con qualche contatto in rubrica',
   'pronta', 7),

  ('Promemoria condivisi', 'Organizzazione',
   'Chi fa la spesa a casa tua? E come sapete cosa manca?',
   'Famiglie, coppie, coinquilini',
   'breve', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di aprire Promemoria e creare un nuovo elenco',
     'Fagli dare un nome all''elenco — Spesa va benissimo — e aggiungere due voci',
     'Digli di toccare il pulsante di condivisione e mandarlo a una persona di casa'
   ]),
   to_jsonb(array[
     'Chi passa al supermercato vede la lista aggiornata mentre gli altri la scrivono',
     'Le voci spuntate spariscono per tutti: niente doppioni'
   ]),
   'iPhone del cliente con iCloud attivo',
   'pronta', 8),

  ('Intelligenza visiva e alimenti', 'Apple Intelligence',
   'Quando compri online, ti chiedi mai se esiste un''alternativa più sana?',
   'Chi fa la spesa online, chi sta attento a cosa mangia',
   'lampo', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di fare uno screenshot di un prodotto, anche dal sito che ha già aperto',
     'Sullo screenshot, fagli toccare Chiedi',
     'Digli di domandare quali sono le alternative più salutari'
   ]),
   to_jsonb(array[
     'Ricevi una risposta sul prodotto che hai davanti, non una ricerca generica',
     'Vale su qualsiasi schermata: prodotti, menù, etichette'
   ]),
   'iPhone con Apple Intelligence attiva e connessione',
   'pronta', 9),

  ('Intelligenza visiva e libri', 'Apple Intelligence',
   'Quando finisci un libro che ti è piaciuto, come scegli il prossimo?',
   'Chi legge, chi cerca un regalo',
   'lampo', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di attivare Intelligenza visiva dal tasto Controllo fotocamera',
     'Fagli scattare una foto alla copertina di un libro',
     'Digli di chiedere altri titoli con lo stesso stile'
   ]),
   to_jsonb(array[
     'Trovi la prossima lettura in pochi secondi, partendo da una che ti è piaciuta',
     'Lo stesso gesto vale per film, dischi e videogiochi'
   ]),
   'iPhone con Apple Intelligence attiva. Tieni un libro sul banco',
   'pronta', 10),

  ('Cartelle personalizzate', 'Mac',
   'Quando apri il Finder, trovi subito quello che cerchi?',
   'Studenti, chi lavora con tanti file, chi condivide il Mac in famiglia',
   'breve', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di aprire una cartella sul Mac in esposizione',
     'Guidalo su Personalizza cartella',
     'Fagli scegliere colore e icona, poi chiudere: la cartella si riconosce al volo'
   ]),
   to_jsonb(array[
     'Riconosci la cartella giusta senza leggere il nome',
     'La scrivania resta ordinata anche quando i file diventano tanti'
   ]),
   'Un Mac in esposizione con qualche cartella sulla scrivania',
   'pronta', 11),

  ('Strumenti di scrittura e l''inglese', 'Apple Intelligence',
   'Ti capita di scrivere mail in inglese e non essere sicuro di come suonano?',
   'Studenti, chi lavora con l''estero',
   'breve', 'media',
   to_jsonb(array[
     'Chiedi al cliente di scrivere due righe in inglese in Note o in una mail',
     'Fagli selezionare il testo e aprire Strumenti di scrittura',
     'Digli di scegliere Correggi e di toccare una correzione per leggere il perché'
   ]),
   to_jsonb(array[
     'Mandi la mail senza il dubbio di aver scritto una frase sbagliata',
     'Impari la regola mentre correggi, non solo la parola giusta'
   ]),
   'iPhone o iPad con Apple Intelligence attiva',
   'pronta', 12),

  ('Intelligenza visiva e acquisti', 'Apple Intelligence',
   'Hai mai visto una poltrona in una foto senza sapere dove comprarla?',
   'Chi arreda casa, chi salva foto di ispirazione, chi compra online',
   'lampo', 'facile',
   to_jsonb(array[
     'Chiedi al cliente di aprire una foto con un oggetto che gli piace e fare uno screenshot',
     'Fagli evidenziare l''oggetto con il dito',
     'Digli di scorrere verso l''alto per vedere dove si compra e quanto costa'
   ]),
   to_jsonb(array[
     'Trovi l''oggetto esatto che hai visto, con il prezzo, senza descriverlo a parole',
     'Confronti più negozi in una schermata sola'
   ]),
   'iPhone con Apple Intelligence attiva e connessione',
   'pronta', 13);
end $$;
