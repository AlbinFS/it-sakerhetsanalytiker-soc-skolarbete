# Detection & Response

Kurs: Detection & Response (ITS25), hösten 2026
Rapport: [Inlämning Detection and Response Albin Sulejmani ITS25.pdf].

## Om uppgiften

Kursen var upplagd som ett SOC-team i grupp (Grupp 2). Varje vecka fick vi en ny incident eller en ny förmåga. Gruppen utredde tillsammans, men varje deltagare skrev en egen rapport som betygsattes.

Kursen trappades upp i tre steg: **analysera → automatisera → bedöma**.

Målet var att se samma attack från två håll och lägga ihop bilden (XDR):

| Verktyg | Roll | Vad det visar |
|---|---|---|
| **Security Onion** (Suricata, Zeek, pcap) | NDR, nätverksvyn | Vad som hände i nätet: C2-trafik, DNS, HTTP, payloads |
| **Wazuh** | EDR, endpointvyn | Vad som hände på servern: loggar, regelträffar, active response |
| **Shuffle** | SOAR | Automationen som binder ihop dem: larm → beslut → berikning → case → notis → respons |

Attackerna kördes i en isolerad labbmiljö. Antingen spelades en pcap från läraren upp i Security Onion, eller så attackerade gruppen sin egen sårbara webbapp (OWASP Juice Shop).

## Veckouppgifter

| Vecka | Incident / förmåga | Vad vi byggde och lärde oss |
|---|---|---|
| **v38** | Kom igång: Security Onions API + Shuffle | Hämtade larm ur SO via API:t från Shuffle, filtrerade (severity, acknowledged, escalated), plockade ut IP-adresser ur JSON och berikade dem med externa tjänster. |
| **v39** | **STRRAT** (Remote Access Trojan som ringer hem till sin C2) | Första SOAR-flödet: larm → severity-grind (bara *high*) → berikning (IPinfo) → eskalering till case via SO:s API (skapa case, bifoga event, kvittera) → notis via e-post och Discord. Undvek "case-floden" med flodkollaps, severity-grind och kvittering (idempotens). |
| **v40** | **Lumma Stealer** (info-stealer, C2 över `.su`/`.cyou`) | AI som andra åsikt för gråzonslarm (medium/low). Egen systemprompt med svaret `UPGRADE / AGREE / IGNORE`. Grundregel: AI:n får bara höja, aldrig sänka eller stänga. Skydd mot prompt-injection, dubbletthantering av case, resonemang kring juridik och datasuveränitet (CLOUD Act, GDPR). |
| **v41** | **SQL-injektion mot Juice Shop**: samma attack i två vyer | Wazuh kopplades in. Korskorrelerade Wazuh-larm med SO/Zeek i samma case. Hittade *severity-paradoxen*: lyckad SQLi (regel 31106, nivå 6) fick lägre nivå än misslyckade försök (31103, nivå 7). Korrelation på beteende (mål + attackkategori + tidsfönster) i stället för käll-IP. |
| **v42** | **Path traversal mot Juice Shop** (poison null byte, `%2500`) | Samma flöde mot en ny attacktyp. Flödet klassar attacken utifrån URL-mönster, så att SQLi och traversal från samma IP blir separata case. Den verkliga filläckan gav inget larm i Wazuh och hittades bara via svarsstorlekar i Zeek. |
| **v43** | **Respons**: active response | Shuffle anropar Wazuhs API och kör `!contain-web` på nginx-agenten, så att Juice Shop svarar 503 och attacken stoppas (cirka 75 s från lyckad injektion till stängning). Tjänsten återställs med `!restore-web`. Beslutet ligger i Shuffle i stället för i en Wazuh-regel på grund av severity-paradoxen. Avvägning: att stänga hela tjänsten blir en DoS mot de egna kunderna. |
| **v44** | **Bedömning & strategi** | Verktygsbedömning mot en konkret organisation (en liten e-handel): EDR vs NDR vs XDR, proaktiv vs reaktiv övervakning, AI i SOAR och slutsatser. |

## Rapportens struktur

Rapporten följer kursens mall i fyra delar:

1. **Loggbok**: en kort not per veckoincident med verktyg, offer/IP och IOC:er, och en motivering av vad som är signal och vad som är brus.
2. **Djupdykning**: en fullständig incidentrapport om SQL-injektionen mot Juice Shop (v41 och v43), med:
   - sammanfattning och drabbade system/konton
   - IOC-tabell
   - tidslinje i UTC (recon → kolumnräkning → schemadump → kontodump → inloggning som admin på knappt 6 minuter)
   - analys i båda vyerna
   - kritisk granskning av datan
   - prioriterad åtgärdsplan (IP-blockering, lösenordsbyte, prepared statements/WAF, bättre detektionsregler, anmälan till IMY)
3. **Automation (Shuffle)**: den röda tråden genom flödet vecka för vecka (vilket problem varje steg löste och vilket nytt problem det skapade), designval, race conditions och en granskning av svagheter i det egna flödet.
4. **Bedömning & strategi**: rekommenderad säkerhetsarkitektur för en liten e-handel (WAF + Wazuh + Security Onion), proaktiv övervakning, och värdet av AI-triage vägt mot juridiska risker.

## Viktigaste lärdomar

- **Ingen enskild sensor ser hela attacken.**
  - Wazuh larmade på rätt händelser men med fel prioritet.
  - Security Onion hade bevisen (Zeek/pcap) men larmade på bruset.
  - Inloggningen som admin syntes bara i pcap.
- **Severity och statuskod går inte att lita på blint.** HTTP 200 bevisar inte att en attack lyckades, och regelnivån kan vara bakvänd. Svarsstorleken i Zeek var det starkaste beviset.
- **Automation flyttar problemet ett steg.** Varje lösning i flödet skapade en ny utmaning, och därför måste även den egna automationen granskas kritiskt.
- **AI i SOAR kräver tydliga gränser.** AI:n får bara höja larm, larmdata behandlas som opålitlig indata, och det kräver juridiska överväganden när data skickas till en extern tjänst.

## Verktyg och tekniker

Security Onion (Suricata, Zeek, pcap-uppspelning, case-API) · Wazuh (regler, active response, REST API) · Shuffle (webhooks, HTTP-noder, Python, datastore) · IPinfo · AbuseIPDB · Claude-API för AI-triage · Discord/SMTP-notiser · OWASP Juice Shop · MITRE ATT&CK (T1190)

> Notera: angriparens käll-IP är maskerad i rapporten (90.227.x.x) eftersom den tillhör en gruppmedlem.
