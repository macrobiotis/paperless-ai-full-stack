# paperless-ai-full-stack

## Install

```bash
git clone git@github.com:macrobiotis/paperless-ai-full-stack.git
cd paperless-ai-full-stack
```

***

## Creates

### Docker-Containers

| Service            | Port  | URL             |
|--------------------|-------|--------------------------|
| ollama             | 11434 | <http://localhost:11434>  |
| redis              | 6379  |   |
| paperless-db       | 5432  |                           |
| paperless-webserver| 8000  | <http://localhost:8000>   |
| paperless-ai       | 3000  | <http://localhost:3000>   |

***

## Files

| File                |                                 |
|----------------------|---------------------------------|
| `.env`              | Edit this file for token-update |
| `.paperless-ai.env` | Edit this optional             |

***

## Folders

| Path                  |                   |
|-------------------------|-------------------------------|
| `./volumes/consume`    | Add your files here          |
| `./volumes/export`     |                               |
| `./volumes/media`      |                               |

***

## Run

### 1. Start paperless-webserver

```bash
make up
```

### 2. Get API-Token from [http://localhost:8000](http://localhost:8000) → Profile → API Tokens → Create new API Token → Copy the token

### 3. Add to `.env` as `PAPERLESS_API_TOKEN`

### 4. Start paperless-ai

```bash
make up-ai
```

### 5. Login to paperless-ai at <http://localhost:3000>

***

## Logs

- make logs
- make logs-paperless <- paperless-webserver logs.
- make logs-ai <- paperless-ai logs.
- make logs-redis <- redis logs.
- make logs-ollama <- ollama logs.

## Source

- <https://github.com/macrobiotis/paperless-ai>
- <https://github.com/paperless-ngx/paperless-ngx>

Thanks.

***

## Example

### paperless-ai German Language Prompt

```m̀arkdown
Du bist präziser Assistent. **STRICT: Nur Kontext-Fakten, KEINE Ergänzungen/Halluzinationen!**

**AUFGABE:** Saubere Analyse. Ignoriere irrelevante Chunks.

**KONTEXT:** {context}  # text | page | chunkid | rolle/person

**STRICT REGELN:**

- **STOP bei Wiederholung:** Wenn ein inhaltlich gleicher Satz 3x im Kontext vorkommt, übernimm ihn höchstens 1x in der ABSCHRIFT und IGNORIERE alle weiteren Wiederholungen. Keine „Fortsetzung“ mehr anhängen.
- Schreibe NIEMALS Sätze mehrfach in der ABSCHRIFT, nur weil sie im Kontext mehrfach vorkommen.
- **BESCHLÜSSE:** KANN NUR DAS GERICHT/DIE BEHÖRDE ERLASSEN! Partei/Anwalt-Text = Antrag/Schriftsatz (NIE Beschluss).
- **TITEL:** Bestimme einen kurzen Titel aus dem Kontext mit Rolle des Autors (Gericht, Kindesmutter, Kindesvater, Verfahrensbeistand, Umgangspfleger). Nur alphabetische Zeichen, keine `#`, keine Sonderzeichen.

**STRICT Markdown-Format (~≤1200 Wörter):**

**Titel:** {TITEL}  # Aus Kontext, mit Rolle des Autors (kürzen!)
**Datum:** {DATUM}
**Aktenzeichen:** {AKTENZEICHEN}
**Tags:** {TAGS}
**Klassifizierung:** {Antrag/Beschluss/Bericht – aus Text}

***
ABSCHRIFT
```
