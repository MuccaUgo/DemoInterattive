# Demo Interattive

Il catalogo delle demo da fare in store: cosa mostrare, a chi, con quale frase
si apre, **i passaggi da dire al cliente** e i vantaggi con cui si chiude.
E il registro di quelle che vengono fatte davvero, per sapere quali vivono in
reparto e quali restano solo scritte.

Sito a sé, database a sé. Sta accanto a **Store Tasks**, non dentro.

## Le quattro sezioni

- **Elenco** — le demo raggruppate per argomento, con ricerca (nome, frase di
  apertura, cliente, passi, vantaggi) e filtri. Ogni scheda si apre sui passaggi
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

## Come si entra

1. **Password del team** — la stessa di Store Tasks, verificata da Supabase Auth.
2. **Registrazione** — la prima volta scegli il tuo nome e un **codice di 6
   cifre**. Da un altro telefono ti ritrovi con nome e codice.

Il codice non viene mai salvato: si salva solo la sua impronta (SHA-256 con un
sale casuale, calcolata sul telefono). Serve a riconoscersi tra colleghi, non a
proteggere segreti: la porta di casa resta la password del team.

## Setup

### 1. Database
Già fatto sul progetto **StoreTool**: le tabelle e le tredici demo di partenza
ci sono. Il file `schema.sql` resta qui come sorgente: serve per rifare il
database da zero o per un secondo ambiente. Si può rieseguire senza danni —
se il catalogo non è vuoto, non tocca niente.

Tabelle: `demo_people` (chi si è registrato), `demos` (le schede),
`demo_runs` (le demo fatte, in sola aggiunta), `demo_favorites` (le preferite).

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
