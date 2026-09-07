Notis 26 maj 2026: Vi lärare har fått frågan om man kan “fabricera” (hitta på) loggmaterial där loggar inte är detaljerade nog (för forensik), svaret är: Om du vet vad du gör och håller dig till loggens tekniska format - ja, det är ok, men läs gärna denna artikel kring nginx-loggning först - kanske kan du få ut det du vill ur loggar genom att utöka loggningen?

Du ska genomföra en simulerad säkerhetsincident i din egen Wazuh-labbmiljö, utreda den som en SOC-analytiker, och dokumentera arbetet enligt en branschmall som följer SANS Incident Handler’s Handbook samt cybersäkerhetslagens (NIS2) krav på myndighetsrapportering.

Scenario
Du är säkerhetsanalytiker på en fiktiv organisation som du själv namnger. Organisationen omfattas av cybersäkerhetslagen (du väljer själv inom vilken av de 18 sektorerna - t.ex. digital infrastruktur, hälso- och sjukvård, transport, offentlig förvaltning).

I din labbmiljö kör du Wazuh som SIEM och övervakar de containrar vi använt under kursen (Debian-burk med SSH, sårbar webapp som Juice Shop eller DVWA, eventuellt ytterligare källor du lagt till).

Din uppgift är att:

Välj angreppspunkter mot Juice Shop som tillsammans bildar en realistisk angreppskedja
Genomför attacken mot din egen labbmiljö (det är din “incident”)
Utred incidenten som om du var SOC-analytiker på den fiktiva organisationen
Dokumentera utredningen enligt rapportmallen
Du är alltså både angripare och försvarare - men ditt fokus i rapporten är på försvararperspektivet. Angreppet är förutsättningen, dokumentationen är artefakten.

Vad du ska attackera
Standard: attackera Juice Shop i din labbmiljö.

Juice Shop är fylld av sårbarheter och täcker hela OWASP Top 10. Vi har under kursen sett hur attacker mot den genererar events i Wazuh, så du har en bra grund att utgå från. Du väljer själv vilken eller vilka sårbarheter du utnyttjar - en SQL injection som lyckas extrahera användardatabasen, en XSS som leder vidare till session hijacking, en kombinerad angreppskedja med flera steg, eller något annat som intresserar dig.

På handledning hjälper vi dig att hitta ett scenario som är lagom svårt och som ger tydliga spår i Wazuh.

Överkurs: installera en annan sårbar webbapplikation

Om du vill utmana dig själv kan du installera en annan sårbar webbapp som Docker-container - DVWA, WebGoat, bWAPP, Mutillidae eller liknande - och attackera den istället. Detta kräver att du själv:

Får containern att köra i din labbmiljö
Konfigurerar Wazuh-agent eller loggöverföring så events syns i SIEM:en
Verifierar att attack-events faktiskt triggar alerts
Det är inget krav, men det är en bra övning för dig som vill ut i rollen som säkerhetsingenjör snarare än ren analytiker. Boka handledning så hjälper vi dig komma igång - vi har inte testat alla webbappar själva men kan hjälpa dig felsöka.

Oavsett vilken applikation du angriper är dokumentationen i rapporten det viktiga - inte själva attackens komplexitet.

Vad du ska lämna in
Tre artefakter, alla i samma dokument enligt rapportmallen:

Del A: Intern incidentrapport (SANS-struktur) - 5-8 sidor + bilagor
Den huvudsakliga utredningsdokumentationen. Följ SANS sex faser. Skärmdumpar från din Wazuh-dashboard, queries du använt, hashade loggutdrag.

Del B: Externa rapporter enligt cybersäkerhetslagen - cirka 3-4 sidor totalt

Upplysning (24h) - 1/2 sida
Incidentanmälan (72h) - 1-2 sidor
Slutrapport (en månad) - 2-3 sidor
Del C: Playbook för framtida liknande incidenter - 2-3 sidor
Strukturerad så att en kollega som inte var med under utredningen kan följa den vid nästa liknande incident.

Bilagor - så omfattande som behövs
Loggutdrag med hashar, fullständiga queries, övriga skärmdumpar, källhänvisningar.

Totalt omfång: cirka 12-15 sidor inklusive bilagor. Det är inte en akademisk uppsats - det är en utredningsdokumentation. Skriv koncist och konkret.

Använd rapportmallen som finns publicerad på bloggen som utgångspunkt - den har strukturen, du fyller i innehållet.

Format
Du lämnar in en PDF. Mallen är skriven i Markdown men du kan skriva i Word, Google Docs, LibreOffice eller direkt i Markdown - bara slutprodukten är PDF.

Vill du skriva direkt i Markdown finns två bra webbaserade editorer som inte kräver installation:

StackEdit - https://stackedit.io - har live-preview, kan exportera direkt till PDF, och kan synka mot Google Drive eller GitHub om du vill ha din rapport säkerhetskopierad
Dillinger - https://dillinger.io - enklare gränssnitt, snabb att komma igång med, exporterar till HTML/PDF/Markdown
Båda är gratis och fungerar i webbläsaren utan konto. För en längre rapport som denna rekommenderas StackEdit eftersom den hanterar större dokument bättre och har bättre PDF-export.

Skärmdumpar ska vara tydliga och ha dina egna annoteringar (pilar, markeringar, korta kommentarer) där det är relevant. En skärmdump utan kommentar är bara ett bevis på att du loggat in i Wazuh - en annoterad skärmdump är ett analysverktyg.
