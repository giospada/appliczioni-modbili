---
marp: true
theme: gaia
class: 
style: |
    .three { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 1rem; }
    .two { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem; }
    .small { font-size: 80%; }
---


# Sport Mate

**Relazione progetto LAM**

![bg right h:300](img/logo.png)

**Giovanni Spadaccini**

giovanni.spadaccini3@studio.unibo.it


---

# Introduzione

Sport Mate è un'applicazione progettata per organizzare e partecipare ad eventi sportivi nella propria zona. 

L'obiettivo principale è quello di facilitare la connessione tra appassionati di sport, permettendo loro di creare, trovare e partecipare a varie attività sportive.

---

## Scelta delle tecnologie


<div class="three">
<div>

**Dart**

- Semplice e produttivo
- Sintassi chiara e coerente
- Null safety

</div>
<div class="">

 **Flutter**

<div class="small">

- Supporto eccellente per lo sviluppo multi-piattaforma, componeti definiti in maniera dichiarativa
- principali librerie utilizzate: provider, flutter_secure_storage, flutter_map, flutter_local_notifications

</div>
</div>
<div>

 **Backend**

- Scritto in Python con FastAPI
- Database PostgreSQL

</div>
</div>

---



## Features dell'applicazione

<div class="two small">
<div>

- **Login**: Autenticazione utenti
- **Signup**: Creazione profilo utente
- **Search**: Motore di ricerca per eventi o partner sportivi con filtri
  - **Mappa**: Visualizzazione eventi sulla mappa
  - **Lista**: Visualizzazione dettagliata degli eventi
</div>
<div>

- **Creazione Attività**: Creazione nuovi eventi sportivi
- **Storico**: Raccolta eventi passati con possibilità di aggiungere feedback
- **Ricordo**: Lasciare messaggi e punteggi degli eventi
- **Visualizzazione di un'Attività e Partecipazione**: Dettagli evento e iscrizione

</div>
</div>

---


## Struttura del codice sorgente

![bg left 65%](img/tree_dir_short.png)

<div class="small">

- **config**: Configurazioni globali
- **data**: Strutture dati delle attività e dei feedback
- **provider**: Dati che influenzano la UI
- **pages**: Widget delle varie pagine
- **utils**: Funzioni utilitarie

Dati caricati da un backend e salvati in locale per accesso offline.
</div>

---

<!-- _class: lead -->

## Activity Data

 **Activity**: Contiene dati relativi agli eventi sportivi (nome, descrizione, posizione, data, ora, partecipanti, ecc.)
![bg  left 60%](img/activity.png) 

---

<!-- _class: lead--->

## FeedbackData

![bg left 60%](img/feedback.png)
 **Feedback**: Contiene dati relativi ai feedback (punteggio, messaggio, attività associata)

---

### Provider

![bg left h:95%](img/data_provider.png)

<!-- _class: lead -->
<div class="small">

Un provider gestisce e fornisce dati e stato all'applicazione, migliorando la separazione tra logica di business e interfaccia utente.

- **Activity Data**: Metodi e dati per caricare, modificare ed eliminare attività
- **Auth**: Metodi e dati per gestire autenticazione e accesso utente

</div>

---
<!-- _class: lead--->

# Pagine

Andiamo a definire le pagine che compongono l'applicazione


---

### Home

Carica il file home, che controlla se è stato salvato un authetication token valido.

- Carica la pagina **Search** se il token è valido
- Carica la pagina di **Registrazione e Login** se il token non è valido

![bg right 98%](img/home.png)

---

### Registrazione e Accesso

Prima pagina visualizzata per accesso e registrazione.
Questa utilizza il provider Auth per registrare il token.

![bg left w:90%](img/login.png) ![bg w:90%](img/registrazione.png)

---

### Search

Pagina complessa che permette di cercare eventi sportivi con filtri e due modalità di visualizzazione (mappa e lista).

![bg vertical right h:90%](img/search_page.png) ![bg right h:81%](img/search_state.png)

---

### Modalità di Visualizzazione

- **Mappa**: Visualizzazione eventi tramite marker
- **Lista**: Visualizzazione dettagliata degli eventi

![bg right w:98%](img/search_map_page.png)
![bg rigt w:98%](img/filter.png)
![bg right w:98%](img/Search.png)

---

### Cambia raggio 

Questa activity serve per cambiare il raggio di ricerca della search.

![bg right w:98%](img/flutter_05.png)
![bg right w:98%](img/select_radius.png)

---

### Aggiungi attività
<div class="small">

Compilazione di diverse pagine per creare un'attività sportiva:

- **Posizione**: Selezione posizione evento
- **Data**: Selezione data e ora evento
- **Dettagli**: Descrizione evento, disciplina sportiva, partecipanti, prezzo

</div>

![bg left w:98%](img/new_pos.png)
![bg left w:98%](img/new_date.png)
![bg left w:98%](img/new_desc.png)

---

### Partecipa ad un'attività

Cliccare sul bottone "partecipa" per aggiungersi alla lista dei partecipanti e impostare un promemoria per l'evento, tramite il bottone di notifica.

![bg right fit](img/descrizione.png) ![bg right fit](img/joined.png)

---

### Storia

Visualizzare eventi passati e aggiungere feedback.

![bg left w:97%](img/history.png) ![bg left w:97%](img/add_feedback.png)

---

### Impostazioni

Modifica delle informazioni utente e delle notifiche evento. Disconnessione dall'account e eliminazione dati locali.

![bg right h:90%](img/settings.png)
