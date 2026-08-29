# Demo Interattive

Il catalogo delle demo da fare in store: cosa mostrare, a chi, con quale frase
si apre, **i passaggi da dire al cliente** e i vantaggi con cui si chiude.
E il registro di quelle che vengono fatte davvero, per sapere quali vivono in
reparto e quali restano solo scritte.

Sito a sé, database a sé. Sta accanto a **Store Tasks**, non dentro.

## Le quattro sezioni

- **Elenco** — le demo raggruppate per tag, con ricerca (nome, frase di
  apertura, cliente, passi, vantaggi, tag) e filtri. Ogni scheda si apre sui passaggi
  numerati, scritti come si dicono davvero: *“Chiedi al cliente di tenere premuto
  il tasto Controllo fotocamera”*. In fondo, **cosa ci guadagna il cliente**.
- **Preferite** — la stella accanto al nome. Personali, legate al profilo: le
  demo che vuoi avere sottomano, non una classifica.
- **Crea la demo** — modulo a tutta pagina: cos'è, come si attacca, i passaggi
  (pochi e chiari, si aggiungono uno alla volta), i vantaggi, il contorno. Lo
  stesso modulo serve per le modifiche.
- **Profilo** — il tuo nome e il tuo codice, quante demo hai fatto, quelle che
  fai più spesso, le tue ultime, e come sta il catalogo del team.

Su ogni scheda c'è **“L'ho fatta”**: com'è andata (wow · ok · fiacca) e una riga
di commento. È in sola aggiunta: una demo fatta non si cancella.

In alto, accanto al tuo nome, il tasto **↻**: ricarica l'app e riprende dal
database le proposte e le segnalazioni arrivate nel frattempo. Se stai
scrivendo una demo non ricarica niente, aggiorna solo i dati.

## I tag

Una demo parla di più cose insieme: *Apple Intelligence* **e** *iPhone*,
*Accessibilità* **e** *Mac*. Per questo i tag sono più d'uno e si scelgono
toccandoli, nel modulo di creazione:

> iPhone · iPad · Mac · Apple Watch · AirPods · Apple Intelligence ·
> Accessibilità · Fotocamera e Foto · Tastiera e testo · Continuity ·
> Telefono e contatti · Organizzazione · Salute e movimento · Altro

Restano nell'ordine in cui li tocchi, e **il primo** è quello sotto cui la demo
finisce nell'elenco — il modulo lo dice mentre scegli. I filtri in cima
all'elenco e la ricerca li guardano tutti, non solo il primo.

Sulla scheda compaiono gli altri tag, quelli che il titolo del gruppo non dice
già.

## Come si entra

Si apre il sito e si sceglie il proprio nome, poi il **codice di 6 cifre**.
La prima volta ci si registra: nome e codice, e da un altro telefono ci si
ritrova con quelli.

Non c'è più la password del team: `senza-password.sql` è stato eseguito e le
regole valgono anche per chi non ha fatto login. Vuol dire che **chiunque
conosca l'indirizzo del sito** legge e modifica catalogo, nomi e registro. Il
codice personale dice chi sei, non protegge i dati. Le tabelle di Store Tasks
restano dietro il loro login.

### Amministratori

Chi scrive una demo manda una **proposta**: la vede solo lui, marcata *Da
approvare*, finché un amministratore non la pubblica. Da lì in poi la demo
pubblicata la modifica solo un amministratore.

Il giro di una proposta si chiude sempre, in un modo o nell'altro:

- **Approva e pubblica** — la demo entra nel catalogo di tutti, con scritto chi
  l'ha proposta e chi l'ha pubblicata.
- **Rifiuta** — serve un motivo, non si rifiuta in silenzio. Chi l'ha scritta
  trova la demo marcata *Rifiutata* con la nota dell'amministratore sulla
  scheda: la corregge, la salva, e torna in coda da sé (la vecchia nota sparisce).
- **Rimetti in attesa** — vale anche su una demo già pubblicata, quando ha
  smesso di funzionare: torna *Da approvare* con scritto cosa va sistemato.

L'amministratore trova quello che lo aspetta in cima all'**Elenco**: un avviso
con i numeri e i filtri *Da approvare* e *Segnalate*.

### Segnalazioni

Una demo pubblicata la modifica solo un amministratore, ma chi lavora in reparto
è il primo ad accorgersi se un passo non torna più. Sulle demo pubblicate c'è
**“Proponi una correzione”**: due righe, firmate, che restano sulla scheda
finché un amministratore non le segna *Sistemata* o *Scarta*.

Un amministratore, dal **Profilo → Chi usa l'app**, aggiunge persone, azzera
codici, e passa il ruolo ad altri (*Gestisci → Rendi amministratore*). L'ultimo
amministratore non si può togliere: il catalogo non resta senza nessuno che
approvi.

Il primo amministratore si crea con `admin.sql`. È già stato eseguito sul progetto
**StoreTool**: **Admin** esiste, con il codice concordato. Chi aggiungi trova già il suo
nome all'ingresso e sceglie il codice da sé al primo accesso; chi lo dimentica,
*Gestisci → Azzera il codice*.

**Il limite, detto chiaro**: questi controlli vivono nell'app, non nel database.
Senza la password del team le regole di Supabase lasciano scrivere chiunque,
quindi chi sa usare gli strumenti per sviluppatori può aggirarli. Servono a
tenere in ordine il lavoro del team, non a difendere i dati da un estraneo.

### Rimettere la password del team

Due passi, l'inverso di prima: `RICHIEDI_PASSWORD = true` in cima allo
`<script>` di `index.html`, e i `drop policy` che stanno in fondo a
`senza-password.sql`.

Il codice non viene mai salvato: si salva solo la sua impronta (SHA-256 con un
sale casuale, calcolata sul telefono). Serve a riconoscersi tra colleghi, non a
proteggere segreti: la porta di casa resta la password del team.

## Setup

### 1. Database
Già fatto sul progetto **StoreTool**: le tabelle e le tredici demo di partenza
ci sono, `demo_suggestions` e le colonne del verdetto comprese. Per i ruoli serve anche `admin.sql`, che aggiunge la colonna e crea il
primo amministratore. Il file `schema.sql` resta qui come sorgente: serve per rifare il
database da zero o per un secondo ambiente. Si può rieseguire senza danni —
se il catalogo non è vuoto, non tocca niente.

I tag stanno in `demos.tags`. Finché quella colonna non c'è, l'app li tiene
tutti in `demos.category`, uniti da `·`: funziona uguale prima e dopo. Per
aggiungere la colonna e rimettere a posto le demo già scritte, esegui
`tags.sql` — una volta sola, si può rieseguire senza danni.

Tabelle: `demo_people` (chi si è registrato), `demos` (le schede),
`demo_runs` (le demo fatte, in sola aggiunta), `demo_favorites` (le preferite),
`demo_suggestions` (le correzioni proposte).

### 2. Pubblicazione su GitHub Pages
Repository → **Settings → Pages** → Source: `main`, cartella `/ (root)`.
Dopo circa un minuto il sito è online.

### 3. Su iPhone
Apri l'URL in Safari → **Condividi → Aggiungi a schermata Home**.

## Configurazione

URL e chiave pubblica Supabase sono in cima allo `<script>` di `index.html`
(`SUPABASE_URL`, `SUPABASE_KEY`, `SHARED_EMAIL`). La chiave `anon/publishable`
è pensata per essere pubblica: i permessi reali li decide la Row Level Security.

## Sicurezza

- La password del team non è nel codice: la verifica Supabase Auth.
- Row Level Security su tutte le tabelle: senza login non si legge nulla.
- I codici personali sono salvati solo come impronta, mai in chiaro.
- Il registro delle demo fatte è solo-aggiunta: nessuno può riscriverlo.
