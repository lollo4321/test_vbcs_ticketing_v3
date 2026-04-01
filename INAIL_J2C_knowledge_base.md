# INAIL J2C – Knowledge Base: Linee Guida SaaS e PaaS
> Documento di riferimento per lo sviluppo nel progetto di trasformazione J2C.
> Da usare come contesto in Claude Code durante le attività di sviluppo.

---

## 1. ACRONIMI E GLOSSARIO

| Acronimo | Significato |
|----------|-------------|
| OCI | Oracle Cloud Infrastructure |
| OIC | Oracle Integration Cloud |
| ODI | Oracle Data Integrator |
| VBCS | Visual Builder Cloud Service |
| VBS | Visual Builder Studio (versioning del codice) |
| ATP | Autonomous Transaction Processing (database) |
| OAC | Oracle Analytics Cloud |
| BICC | Business Intelligence Cloud Connector |
| BIP | BI Publisher |
| ORDS | Oracle REST Data Services |
| SSO | Single Sign-On |
| IdP | Identity Provider |
| SP | Service Provider |
| CIE | Carta d'Identità Elettronica |
| SDI | Sistema di Interscambio |
| NSO | Nodo Smistamento Ordini |
| RAI | Rilevazione Attività Intramuraria |
| CIVA | Certificazione Impianti e Verifica Apparecchi |
| ISI | Intervento a supporto delle Imprese |
| GIMAP | Gestione Integrata Magazzino Ausili Protesi |
| ITP | Indice Tempestività dei Pagamenti |
| SC-PCC | Sistema di Comunicazione con la Piattaforma dei Crediti Commerciali |
| CCR | Cartella Clinica Riabilitativa |
| ANAC | Autorità Nazionale Anticorruzione |
| AgID | Agenzia per l'Italia Digitale |
| MEF/RGS | Ministero dell'Economia e delle Finanze / Ragioneria Generale dello Stato |
| Landing Zone | Configurazione di base del tenant Cloud (sicurezza, connettività, networking, compartment, monitoring/logging) |

---

## 2. ARCHITETTURA GENERALE

### 2.1 Stack tecnologico

Il progetto J2C si basa su tre layer:

- **SaaS** – Oracle Fusion Cloud ERP/EPM (applicativo standard)
- **PaaS** – OCI con OIC, VBCS, ODI, ATP, OAC, SFTP, Object Storage
- **IaaS** – OCI (necessaria per OIC e VBCS)

### 2.2 Tenant OCI

- Unico tenant: **`inailintegrazionesaas`**
- 4 compartment: **Sviluppo**, **Collaudo**, **Certificazione**, **Produzione**

### 2.3 Componenti PaaS e loro ruolo

| Componente | Ruolo |
|------------|-------|
| **OIC** | Integrazione real-time/near-real-time tra sistemi via REST/SOAP/eventi; orchestrazione batch end-to-end; Human Workflow (Process) |
| **VBCS** | UI custom per estensioni del SaaS; applicazioni orientate all'interfaccia utente |
| **ODI** | ETL su grandi volumi di dati; trasformazione dati grezzi; Data Warehouse |
| **ATP** | Layer di persistenza e staging per integrazioni ed estensioni |
| **OAC** | Analytics e reporting |
| **Object Storage** | Area di scambio file massivi (batch) con sistemi esterni |
| **SFTP Server** | Scambio file con sistemi che usano protocollo SFTP |
| **API Gateway** | Pubblicazione API su rete privata/pubblica con autenticazione, validazione, rate limiting |

### 2.4 Principi architetturali chiave

- **2 API Gateway**: uno su rete privata per OIC, uno su rete privata per i servizi OIC con ATP
- **OIC** è istanziato su **rete pubblica** (impossibile su privata); configurare whitelist CIDR per accessi
- **ATP** è istanziato su **rete privata**
- Ogni comunicazione con **Connectivity Agent OIC** parte sempre dall'Agent
- Certificati INAIL (TLS v1.2) installati nel Connectivity Agent
- **ODI** installato su VM OCI in rete privata
- **VBCS non si accede mai direttamente**: accesso tramite SaaS con profili (coni di visibilità)
- **ORDS** esposto su internet mediato da FrontDoor (Azure); filtri header e CIDR a livello load balancer

---

## 3. AMBIENTI E URL

### 3.1 SaaS – Oracle Fusion ERP

| Ambiente | URL | System Name | OCID |
|----------|-----|-------------|------|
| Sviluppo (Test) | https://iacags-test.fa.ocs.oraclecloud.com/fscmUI/faces/FuseOverview | IACAGS-TEST | ocid1.fusionenvironment...cgk3tq |
| Collaudo (Dev1) | https://iacags-dev1.fa.ocs.oraclecloud.com/fscmUI/faces/FuseOverview | IACAGS-DEV1 | ocid1.fusionenvironment...5xl2yq |
| Certificazione (Dev2) | https://iacags-dev2.fa.ocs.oraclecloud.com/fscmUI/faces/FuseOverview | IACAGS-DEV2 | ocid1.fusionenvironment...efmgba |
| Produzione | https://iacags.fa.ocs.oraclecloud.com/fscmUI/faces/FuseOverview | IACAGS | ocid1.fusionenvironment...7opuca |

Tutti gli ambienti: versione **24C**, famiglia `inailintegrazionesaas-fa`.

### 3.2 PaaS – OIC (Oracle Integration Cloud)

| Ambiente | Instance | URL Designer |
|----------|----------|-------------|
| Sviluppo | SVOCINJ2C0IC01 | https://design.integration.eu-milan-1.ocp.oraclecloud.com/?integrationInstance=svocinj2c0ic01-fr1summxjhgi-li |
| Collaudo | COOCINJ2C0IC01 | https://design.integration.eu-milan-1.ocp.oraclecloud.com/?integrationInstance=coocinj2c0ic01-fr1summxjhgi-li |
| Certificazione | CEOCINJ2C0IC01 | https://design.integration.eu-milan-1.ocp.oraclecloud.com/?integrationInstance=ceocinj2c0ic01-fr1summxjhgi-li |
| Produzione | PROCINJ2C0IC01 | https://design.integration.eu-milan-1.ocp.oraclecloud.com/?integrationInstance=procinj2c0ic01-fr1summxjhgi-li |

URL base (radice): `https://<prefix>ocinj2c0ic01-fr1summxjhgi-li.integration.eu-milan-1.ocp.oraclecloud.com/`

### 3.3 PaaS – VBCS (Visual Builder Cloud Service)

| Ambiente | URL Builder |
|----------|------------|
| Sviluppo | https://svocinj2c0vb01-vb-fr1summxjhgi.builder.eu-milan-1.ocp.oraclecloud.com/ic/builder/ |
| Collaudo | https://coocinj2c0vb01-vb-fr1summxjhgi.builder.eu-milan-1.ocp.oraclecloud.com/ic/builder/ |
| Certificazione | https://ceocinj2c0vb01-vb-fr1summxjhgi.builder.eu-milan-1.ocp.oraclecloud.com/ic/builder/ |
| Produzione | https://procinj2c0vb01-vb-fr1summxjhgi.builder.eu-milan-1.ocp.oraclecloud.com/ic/builder/ |

### 3.4 PaaS – ATP (Autonomous Database)

| Ambiente | DB Name | URL ORDS SQL Developer |
|----------|---------|----------------------|
| Sviluppo | SVOCINJ2C0DB01 | https://a6pg36kb.adb.eu-milan-1.oraclecloudapps.com/ords/sql-developer |
| Collaudo | COOCINJ2C0DB01 | – |
| Certificazione | CEOCINJ2C0DB01 | – |
| Produzione | PROCINJ2C0DB01 | – |

**Pattern URL ORDS**: `https://a6pg36kb.adb.eu-milan-1.oraclecloud.com/ords/<schema_alias>/<object_alias>/`

**Voci da aggiungere al file hosts Windows** (`C:\Windows\System32\drivers\etc\hosts`):
```
172.29.241.72  a6pg36kb.adb.eu-milan-1.oraclecloud.com         # ATP SVIL
172.29.241.72  a6pg36kb.adb.eu-milan-1.oraclecloudapps.com     # ATP SVIL
172.29.240.77  l90xhz7u.adb.eu-milan-1.oraclecloud.com         # ATP COLL
172.29.239.73  vzymsuok.adb.eu-milan-1.oraclecloud.com         # ATP CERT
172.29.245.43  lftwdub1.adb.eu-milan-1.oraclecloud.com lftwdub1.adb.eu-milan-1.oraclecloudapps.com  # GEN AI SVIL
```

**Schema ATP Sviluppo** (utenze tecniche):
| Schema | Scopo | User | Password |
|--------|-------|------|----------|
| INT_ADMIN | DBA condiviso: viste, procedure, pkg, funzioni | INT_ADMIN | Admin_svil_2024 |
| ETL_SOURCE | ODI – scarico dati esterni | ETL_SOURCE | ETL_svil_20_24 |
| STAGING_PAAS | Stage per estensioni applicative e tabelle post-ETL | STAGING_PAAS | PAAS_svil_2024 |
| STAGING_SAAS | Stage per dati provenienti dal SaaS | STAGING_SAAS | SAAS_svil_2024 |
| DW_OAC | Lettura dati per OAC (disaccoppiato dal transazionale) | DW_OAC | OAC_svil_2024 |
| STAGING_MIGR | Migrazione dati da R12 | STAGING_MIGR | Migrazione_svil_2025 |
| ODI REPO Sviluppo | – | ODISVIL_ODI_REPO | JQ6DwTPW4i99 |

### 3.5 PaaS – OAC (Oracle Analytics Cloud)

| Ambiente | VCN | IP OAC | URL |
|----------|-----|--------|-----|
| Sviluppo | VCN-development | 172.29.245.253 | https://svocinj2c0ac01-ax45x6tuynyp-li.analytics.ocp.oraclecloud.com/ui/ |
| Collaudo | VCN-Collaudo | 172.29.246.250 | https://coocinj2c0ac01-ax45x6tuynyp-li.analytics.ocp.oraclecloud.com/ui/ |
| Certificazione | VCN-Certificazione | 172.29.247.249 | https://ceocinj2c0ac01-ax45x6tuynyp-li.analytics.ocp.oraclecloud.com/ui/ |
| Produzione | VCN-Produzione | 172.29.248.248 | https://procinj2c0ac01-ax45x6tuynyp-li.analytics.ocp.oraclecloud.com/ui/ |

### 3.6 EBS R12 (On-Premise)

| Ambiente | Host | Porta | Servizio |
|----------|------|-------|---------|
| Sviluppo | svfilebsdb01.inail.it | 1525 | EBSSVIL |
| Collaudo | 10.1.80.56 | 1521 | EBSCF.inailservizi.inail.pri |
| Certificazione | ebscert-clsl.inailservizi.inail.pri | 1521 | EBSCERT.INAILSERVIZI.INAIL.PRI |
| Produzione | ebsdbpf-clsl.inailservizi.inail.pri | 1521 | EBSPF.inailservizi.inail.pri |

**Connectivity Agent** (connessione verso EBS R12):
- Installato sull'Application Server di Sviluppo in: `/home/applmgr/agent_OIC_dev`
- Connessione VM: `172.29.241.130`, user: `opc`, private key: `luca`
- Dopo login: `sudo su - oracle`
- Verifica agent: `ps -ef | grep java`
- Avvio agent: `cd /u01/app/oracle/agent_oic && nohup java -jar connectivityagent.jar &`

---

## 4. LINEE GUIDA DI SVILUPPO

### 4.1 Quando usare SaaS vs PaaS

#### Usa SaaS (Visual Builder Studio integrato nel SaaS) quando:
- Si usano **solo dati SaaS**
- Si vuole semplificare una pagina standard SaaS per CRUD semplici
- Si devono salvare **piccole quantità di dati** (le UI nuove salvano in Document table 2242344.1)
- Si usano RestAPI SaaS o ATP ORDS
- È possibile usare strumenti standard: Page Composer, Application Composer, User Interface Text, Page Template Composer

#### NON usare SaaS quando:
- Ci sono **logiche di calcolo complesse**
- Servono dati da **sistemi esterni** al SaaS
- Il modello dati è **articolato**
- Sono necessarie **integrazioni** con altri sistemi

#### Usa PaaS (VBCS + ATP + OIC) quando:
- Si devono creare **procedure, package PL/SQL** per logiche complesse
- Si usa l'**Autonomous Database**
- Si devono estendere le funzionalità SaaS con logiche di business/normative complesse
- Si devono costruire **integrazioni** con altri sistemi
- Si vuole la **sola visualizzazione** di dati SaaS (read-only è accettabile in PaaS)

---

### 4.2 Lookup SaaS vs Tabelle PaaS

#### Usa Lookup SaaS quando:
- Serve una **semplice decodifica** tra 2 insiemi di valori
- Si vuole la visibilità standard nel SaaS e nei BI Report
- Si vuole la tracciabilità standard
- Si ha necessità di gestire flag abilitato/data validità out-of-the-box

**REST API per Lookup SaaS:**
```
GET /fscmRestApi/resources/11.13.18.05/standardLookups
GET /fscmRestApi/resources/11.13.18.05/standardLookups/{LookupType}/child/lookupCodes
```

#### Usa Tabelle PaaS quando:
- La tabella ha **interazioni con sistemi esterni** (la PaaS non è il master per il SaaS)
- Servono **logiche complesse** o un elevato numero di decodifiche
- Serve una UI dedicata (es. pagina VBCS) per gestire l'informazione

---

### 4.3 PL/SQL vs ETL ODI

#### Usa PL/SQL quando:
- Si creano oggetti di DB per **singole estensioni**
- Si sviluppano **funzioni/procedure centralizzate** su cui montare servizi/moduli ORDS

#### Usa ETL ODI quando:
- Occorre trasformare un **volume elevato di dati**
- Si devono elaborare **file con grandi volumi** di dati

> **Nota**: per l'elaborazione di file è preferibile usare OIC o ODI rispetto a PL/SQL puro.

---

### 4.4 Look & Feel – VB (SaaS) e VBCS (PaaS)

#### Regola generale
Usare il template **"Redwood Starter Application"** sia in VB che in VBCS.

#### VB (SaaS)
- Modello: **Redwood Starter Application**
- Evitare CSS custom salvo necessità di template completamente custom (color palette, font, margini)
- In caso di aggiornamento del tema Redwood, l'app deployata NON si aggiorna automaticamente: creare una nuova versione
- Il copia-testo in un campo non è nativo: aggiungere un bottone con funzione "copia"

#### VBCS (PaaS)
- Modello: **Redwood Starter Application**
- Definire le **proprietà delle connessioni a livello di sistema** (centralizzate e condivise)
- Usare **Action Chain di tipo JavaScript** per poter usare il debug nativo
- Evitare CSS custom (stessa regola di VB)
- VBCS permette applicazioni più complesse e si integra meglio con servizi Oracle Cloud e REST/SOAP esterni

#### APEX – Da NON usare
- Orientato a manipolazione dati su DB, non allineato con i nuovi rilasci Oracle
- Look & feel diverso da VB/VBCS/SaaS standard

#### Link utili Redwood:
- https://docs.oracle.com/en/cloud/saas/applications-common/23c/farca/ (Extending Oracle Cloud Applications with Visual Builder Studio, Release 23.10)

---

### 4.5 RestAPI SaaS vs BI Report vs BICC

#### Usa RestAPI quando:
- **Esistono RestAPI**: usarle sempre (disaccoppiano BE da FE)
- Volumi **molto bassi** di dati
- Modalità **real-time**

**Riferimento API Financials**: https://docs.oracle.com/en/cloud/saas/financials/23d/farfa/index.html

#### Usa BIP (BI Publisher) quando:
- Non esistono RestAPI per il dato cercato
- Volumi **medi** di dati, simili a report BI standard
- Modalità **batch**
- Formati supportati: Word, Excel, PDF, RTF, HTML
- **ATTENZIONE**: Oracle non garantisce stabilità dello schema dati tra versioni; limite **2 milioni di record**; query pesanti rischiano timeout

#### Usa BICC quando:
- Si devono estrarre **grandi moli di dati**
- Prima estrazione **Full**, successive **incrementali**
- Modalità **batch**, formato **CSV**
- Supporta solo estrazione da Business Object Fusion (BI ADF VO)

**Link BICC**: https://iacags-test.fa.ocs.oraclecloud.com/biacm/faces/setup

---

## 5. AUTONOMOUS DATABASE – BEST PRACTICE

### 5.1 Schema e segregazione

Ogni layer usa uno schema dedicato:

| Schema | Destinazione |
|--------|-------------|
| `ETL_SOURCE` | ODI – dati da sistemi esterni che subiscono trasformazioni |
| `STAGING_PAAS` | Estensioni applicative + tabelle Stage post-ETL |
| `STAGING_SAAS` | Dati dal SaaS verso PaaS (anagrafiche, FBDI, lookup, …) |
| `INT_ADMIN` | DBA condiviso: integrazioni, tabelle infrastrutturali, viste, procedure, pkg, funzioni condivise |
| `DW_OAC` | Dati per OAC (disaccoppiati dal transazionale) |

### 5.2 Naming Convention oggetti DB

**Formato**: `Modulo_Applicazione_Funzione_Gerarchia`

**Modulo (4-5 char)**:
| Codice | Significato |
|--------|-------------|
| INFND | Oggetti common o dal SaaS schema FND |
| ININT | Integrazioni |
| INAP | Payables |
| INPO | Procurement |
| INAR | Ciclo attivo |
| INGL | Contabilità / General Ledger |
| INCE | Cash Management |

**Applicazione (5 char)**: INCENTIVI, STOCK, SCPCC, ...

**Funzione (3 char)**: INS, UPD, DEL (se presente)

**Gerarchia (3 char)**:

| Codice | Significato |
|--------|-------------|
| H / HEADER / T / TESTATA | Testata |
| L / LINEE | Linee |
| DET | Dettaglio |
| V | Viste |
| STG | Tabelle di staging |
| IN | Input |
| OUT | Output |
| IND | Indici |
| S / SEQ | Sequenze |

**Suffissi per tipo oggetto**:

| Tipo | Suffisso |
|------|---------|
| TABLE (Temporary) | `_TMP` |
| VIEW | `_V` |
| INDEX (Primary Key) | `_PK` |
| INDEX (Unique Key) | `_UK` |
| INDEX (Foreign Key) | `_FK` |
| INDEX (Other) | `_IND` |
| PACKAGE | `_PKG` |
| SEQUENCE | `_SEQ` oppure `_S` |
| TRIGGER | `_TRG` |
| TYPE (Object) | `_OT` |
| TYPE (Collection) | `_CT` |
| MATERIALIZED VIEW | `_MV` |
| MATERIALIZED VIEW LOG | `_MVL` |
| DATABASE LINK | `_DBL` |

### 5.3 Regole di design per tabelle

- Inserire sempre le **WHO COLUMNS** (created_by, creation_date, last_updated_by, last_update_date)
- Inserire una **colonna ID** per il collegamento gerarchico
- Salvare sempre **codici** (mai descrizioni) nelle tabelle
- **Indici e PK**: univoci per colonne ID; per colonne chiave di processo/applicazione
- **Sequenze**: per le colonne ID
- Creare **singoli PKG** per applicazione di riferimento
- Funzioni/procedure **centralizzate e riutilizzabili** per n applicazioni

### 5.4 ORDS – Moduli e servizi

Le pagine VBCS chiamano solo:
- **POST** → procedure PL/SQL (tramite moduli ORDS)
- **GET** → SELECT

I servizi esposti dall'ATP si chiamano **"Module"** in ORDS.

> Per grandi volumi di dati: usare **viste** piuttosto che servizi ORDS.

**Documentazione API PL/SQL ORDS**:
https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/23.4/orddg/ORDS-reference.html#GUID-E4476C14-01B1-4EA4-94D3-73B92C8C9AB3

**Script template per definire un Module ORDS**:
```sql
-- Definizione Module
BEGIN
  ORDS.DEFINE_MODULE(
    p_module_name    => 'test',
    p_base_path      => '/test/',
    p_items_per_page => 25,
    p_status         => 'PUBLISHED',
    p_comments       => NULL
  );
END;

-- Definizione Template
BEGIN
  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'test',
    p_pattern     => 'procedure',
    p_priority    => 0,
    p_etag_type   => 'HASH',
    p_etag_query  => NULL,
    p_comments    => NULL
  );
END;

-- Definizione Handler (POST → PL/SQL)
BEGIN
  ORDS.DEFINE_HANDLER(
    p_module_name  => 'test',
    p_pattern      => 'procedure',
    p_method       => 'POST',
    p_source_type  => ords.source_type_plsql,
    p_mimes_allowed => 'application/json',
    p_comments     => NULL,
    p_source       =>
'DECLARE
  output varchar2(100);
BEGIN
  INT_ADMIN.PROCEDURE_NAME(
    param1 => :p1,
    param2 => output
  );
  :p2 := output;
END;'
  );
END;

COMMIT;
```

---

## 6. CONNETTIVITÀ E SICUREZZA

### 6.1 Connettività tra componenti PaaS (flussi interni Oracle)

| ID | Sorgente | Target | Mediatore | Protocollo | Sicurezza |
|----|----------|--------|-----------|------------|-----------|
| 1 | OIC | ERP (SaaS) | – | HTTPS | Username/Password Token; OAuth Authorization Code |
| 2 | OIC | ATP | Private Endpoint / Agent | JDBC | JDBC over SSL (wallet); Username/Password DB |
| 3 | OIC | ODI (Load Balancer) | Private Endpoint / Agent | HTTP | Username/Password ODI |
| 4 | OIC | SFTP (Network LB) | Private Endpoint / Agent | FTP | FTP Public Key; FTP Server Access Policy; FTP Multi Level Auth |
| 5 | OIC | Object Storage | – | HTTPS | OCI Signature Version 1 (API Key utente tecnico) |
| 6 | ODI | ATP | – | JDBC | JDBC over SSL (wallet); Username/Password DB |
| 7 | ODI | SFTP | – | FTP | FTP Public Key Authentication |
| 8 | ODI | Object Storage | – | HTTPS | OCI Signature Version 1 |

### 6.2 Connettività verso sistemi esterni

| ID | Sorgente | Target | Mediatore | Protocollo | Sicurezza |
|----|----------|--------|-----------|------------|-----------|
| 9 | OIC | External System | API Gateway | HTTPS | Policy dell'erogatore |
| 10 | OIC | Remote Server | – | FTP | Policy dell'erogatore |
| 11 | ODI | Remote Server | – | FTP | Policy dell'erogatore |
| 12 | OIC | External DB | Connectivity Agent | JDBC | Policy del DB esterno |
| 13 | ODI | External DB | ODI Agent | JDBC | Policy del DB esterno |
| 14 | External System | OIC | Connectivity Agent | HTTPS | HTTP Basic Auth; OAuth (JWT assertion, Auth code, ROPC, Client credentials) |

### 6.3 Connettività per estensioni VBCS

| ID | Sorgente | Target | Mediatore | Protocollo | Sicurezza | Note |
|----|----------|--------|-----------|------------|-----------|------|
| 15 | VBCS | OIC | – | HTTPS | HTTP Basic; OAuth (JWT assertion, Auth code, ROPC, Client credentials); Oracle Account (propagazione identità) | Client-side e server-side |
| 16 | VBCS | ATP | ORDS (Load Balancer) | HTTPS | OAuth – dominio database | Usare Load Balancer **pubblico** (ORDS su rete privata) |
| 17 | VBCS | ERP (SaaS) | – | HTTPS | Basic Auth; Oracle Cloud Account (propagazione identità) | Client-side e server-side |

### 6.4 Interfacce esposte dai componenti PaaS

| ID | Componente | Protocollo | Sicurezza | Rete |
|----|-----------|------------|-----------|------|
| 18 | OIC | HTTPS (REST/SOAP) | HTTP Basic; OAuth (JWT, Auth code, ROPC, Client credentials) | Pubblica |
| 19 | OIC | HTTPS (Event da ERP) | Username/Password Token; OAuth Auth Code | – |
| 20 | OIC | JDBC (Trigger da ATP) | JDBC over SSL (wallet); Username/Password | – |
| 21 | Object Storage | HTTPS | OCI Signature Version 1 | Pubblica |
| 22 | SFTP | FTP | FTP Public Key Authentication | Privata |
| 23 | VBCS | HTTPS | OCI Auth (IAM domain) | Pubblica |

### 6.5 OIC Adapter – riepilogo sicurezza

| Adapter | Protocollo | Sicurezza supportata |
|---------|------------|---------------------|
| REST | HTTPS | Basic, OAuth CC, OAuth ROPC, OAuth Auth Code, API Key, OCI Signature V1, OAuth JWT Assertion |
| SOAP | HTTPS | Basic, OAuth CC, OAuth Auth Code, SAML |
| Database | JDBC | Username/Password Token; Oracle Wallet |
| FTP | FTP | Public Key; Server Access Policy; Multi Level Auth |

> OIC fornisce **104 adapter** (tecnologici e applicativi).
> Documentazione completa: https://docs.oracle.com/en/cloud/paas/application-integration/find-adapters.html

### 6.6 Canali di comunicazione per integrazioni

**Modalità di autenticazione usate nel progetto**:
- JWT Bearer
- OAuth 1.0
- Basic Auth
- OAuth 2.0

**Pattern tipici**:
- REST API tra Oracle Fusion (SaaS) ↔ Oracle Fusion (PaaS): per esposizione servizi di dati contabili, anagrafici
- REST API verso sistemi intranet: per dati degli Esiti Disposizioni, anagrafica Conti, dati da PDND (Registro Imprese via API Gateway)
- REST API verso sistemi internet: RGS (SC-PCC), SDI (Fatturazione Elettronica)
- Flat file import: dati amministrativo-contabili da procedure istituzionali

---

## 7. MODELLO DATI – AUTONOMOUS DATABASE

### 7.1 Schema logico (Contabilità)

Il flusso dati segue questo percorso:

```
Applicazioni Esterne
       ↓ ETL (ODI / OIC batch)
   ETL_SOURCE  ──────────────→  STAGING_PAAS / STAGING_SAAS
                                       ↓ (trasformazioni N:1 e 1:1)
                              INT_ADMIN (procedure/pkg condivisi)
                                       ↓
                              Oracle ERP (Fusion)
                                       ↓
                              DW_OAC (per OAC analytics)
```

**Pattern di aggregazione**:
- **N:1 Aggregazione**: più record sorgente → un record destinazione (es. PAGAMENTI, INCASSI)
- **1:1 Analitico**: un record sorgente → un record destinazione con dettaglio (es. TFRICH_PAGAMENTO_DL)

### 7.2 Tabelle di riferimento per la contabilità

| Tabella | Schema | Tipo | Descrizione |
|---------|--------|------|-------------|
| TFRICH_PAGAMENTO | STAGING_PAAS | N:1 | Richieste pagamento aggregate |
| TFRICH_PAGAMENTO_DL | STAGING_PAAS | 1:1 | Richieste pagamento analitiche |
| TFLOG_CONTABILE | STAGING_PAAS | N:1 | Log contabile aggregato |
| TFLOG_CONTABILE_DL | STAGING_PAAS | 1:1 | Log contabile analitico |
| LOG_CONT | – | – | Log di contabilità |
| LOG_SIP, LOG_INF, LOG_ECC | – | – | Log applicativi |

---

## 8. TEST NON FUNZIONALI

### 8.1 Componente SaaS (Oracle gestisce)
- **Vulnerability Assessment / Penetration Test**: NON permessi su nessun ambiente SaaS
- **Test Prestazionali**: NON permessi su nessun ambiente SaaS
- **Accessibilità**: NON necessari (gestiti da Oracle)
- **Qualità del Codice**: NON necessari (gestiti da Oracle)

### 8.2 Componente PaaS (INAIL responsabile)
- **Penetration Test**: RICHIESTO sulle applicazioni con URL testabile
- **SAST (Static Application Security Testing)**: NECESSARIO
- **Test Prestazionali**: NECESSARI
- **Qualità (analisi statica del codice)**: NECESSARIA

---

## 9. MODELLO OPERATIVO – DEPLOY IN PRODUZIONE

### 9.1 Sequenza di deploy (ERP)

1. **Configurazione ambienti** (Coll, Cert, Prod) – Go-live -3 mesi
   - SaaS: Setup moduli, calendari, chiave contabile, categorie, sequenze, sandbox
   - PaaS: Definizione compartment, VCN, subnet; provisioning ATP, ODI, SFTP, OIC, VBCS, VBS con IP privati

2. **Migrazione dati** – Fine Pilota 2 / Go-live -3 mesi
   - Anagrafiche e transazioni SaaS
   - Anagrafiche e transazioni PaaS

3. **Federazione IAM** (Inizio UAT)
   - Federazione domini IAM tenant `inailoci` e `inailintegrazionisaas` con Oracle Fusion SaaS
   - Gestione accesso digitale (SPID) in SSO

4. **Rilascio DevOps**
   - SaaS: export Report BIP e setup FSM tramite API REST via pipeline DevOps
   - PaaS: pipeline per artefatti OIC, ODI, ATP, pagine VBCS generate tramite VBS

### 9.2 DevOps per ODI

```
1. Modifica interfacce ODI in Sviluppo
2. Creazione Scenario
3. Porting in Certificazione dello Scenario
4. Test
5. Porting in Produzione dello Scenario
```

### 9.3 VBS (Visual Builder Studio)

- Si può usare VBS con GIT integrato per sviluppare applicazioni VBCS
- Deploy tramite **job/pipeline VBS** sull'ambiente VBCS target

---

## 10. PUNTI DI ATTENZIONE – CHECKLIST SVILUPPATORE

- [ ] **Naming convention**: rispettare la convenzione `Modulo_Applicazione_Funzione_Gerarchia` per tutti gli oggetti DB
- [ ] **WHO COLUMNS**: presenti in tutte le tabelle ATP
- [ ] **Colonna ID**: sempre presente per collegamento gerarchico
- [ ] **Codici, non descrizioni**: nelle tabelle salvare sempre i codici
- [ ] **Connessioni centralizzate**: definire le proprietà di connessione a livello di sistema (non inline)
- [ ] **Layout Redwood**: usare "Redwood Starter Application" per tutte le UI (VB e VBCS)
- [ ] **Action Chain JavaScript**: preferire JS con debug nativo in VBCS
- [ ] **VBCS → ATP**: usare sempre un Load Balancer pubblico (ORDS è su rete privata)
- [ ] **VBCS → ERP/OIC**: la comunicazione può essere sia client-side che server-side
- [ ] **Grandi volumi**: preferire ODI per ETL, BICC per estrazione SaaS, viste per GET massivi da ATP
- [ ] **CSS custom**: solo se strettamente necessario; prepararsi a manutenzione continua
- [ ] **Test PaaS**: pianificare SAST, test prestazionali e analisi statica del codice
- [ ] **OIC Connectivity Agent**: sempre avviato su Application Server di Sviluppo prima di testare integrazioni con EBS R12
- [ ] **Repository e riuso**: censire sempre i servizi OIC/VBCS creati per evitare duplicati

---

## 11. CSI (Customer Support Identifier)

| Ambito | CSI |
|--------|-----|
| OCI | 24242227 |
| SaaS | 24834363 |

---

*Documento generato da Claude Code sulla base delle Linee Guida INAIL J2C SaaS e PaaS.*
