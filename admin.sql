-- ============================================================
-- Demo Interattive — amministratori
-- Incolla nello SQL Editor di Supabase ed esegui.
-- Si può rieseguire senza danni.
-- ============================================================

-- Chi approva le proposte e può toccare le demo già pubblicate.
alter table public.demo_people add column if not exists admin boolean not null default false;

-- Il primo amministratore, con il codice 123456 concordato.
-- Il codice non è qui: c'è la sua impronta (SHA-256 con il sale accanto),
-- la stessa che l'app calcola sul telefono. Cambiarlo si fa dall'app,
-- dal profilo, come per chiunque altro.
insert into public.demo_people (name, salt, code_hash, admin)
values ('Admin', 'd8de46710ac4ba0fe4c08ce8',
        'e634016be97d68eaf61d354a325d8bd8be74bd70df9e0e1d1e6a0172a4f021d9', true)
on conflict (name) do update
  set salt = excluded.salt, code_hash = excluded.code_hash, admin = true;

-- ------------------------------------------------------------
-- Da qui in poi il ruolo si passa dall'app: Profilo → Chi usa
-- l'app → Gestisci → Rendi amministratore.
-- ------------------------------------------------------------
