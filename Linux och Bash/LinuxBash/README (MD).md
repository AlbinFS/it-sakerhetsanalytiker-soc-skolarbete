**README - Dokumentation (DEL5)**
*Alla skripts ligger i mappen "Scripts" och all skärmdumpar i "Skärmdumpar"*

Översikt över system
1. **backup.sh** är en säkerhetskoperings skript som gör en backup av vald map (hårdkodad). Skripten komprimerar backupen med datumen som filnamn och raderar backups som är äldre än 7 dagar. Skripten loggar även varje backup till en loggfil. Detta skripts bör köras med sudo ./backup.sh eftersom den skriver till filer som ligger inne till kataloger och filer som ligger under /root
2. **system_report.sh** genererar en systemrapport med loggar, användarinformation, diskstatus m.m Mer specifikt så visas i rapporten de 10 senaste misslyckade inloggningsförsöken, den listar de senaste 5 skapade användarna, visar vilka användare som använt sudo de senaste 24 timmarna, vissar aktuellt diskutrymme och markerar ifall det är över 80% fullt och sparar rapporten till en fil med datum i filnamnet.
3. **user_manager.sh** är ett menybaserat verktyg för att skapa, ta bort och listaanvändare. Skripten inehåller även felhantering med användarvänliga meddelanden.
4. **monitor_disk.sh** övervakar diskanvänding och markerar med färgkod varningar och kritiska nivåer.
5. **system_report_colorcode** är samma som system_report.sh men den färgkodar diskanvändningen samt skriver ut diskanvändningen till terminalen

**Installationsinstruktioner**
Gör skriptsen körbara med chmod +x skript_namn.sh
Kör skript ./skript_namn.sh
Om du vill köra skripten så de schmalägger med cron kör du ./skript_namn.sh --setup-cron

**Exempel på skripts**
1. Exempel på output från backup.sh är 

    [Sat Oct 18 03:22:41 PM UTC 2025] [INFO] Backup created: /backup/developers_20251018_152241.tar.gz (Size: 4.0K)
    [Sat Oct 18 03:22:41 PM UTC 2025] [INFO] Cleared 0 old backups (> 7 days)

2. Exempel på output från system_report.sh är

    [INFO] Report saved to /home/albin/Linux-inlamning/reports/system_report_20251018_152542.log

3. Exempel output från user_manager.sh är

    //****** USER MANAGER ******//
    1) Create new user
    2) Remove user
    3) List all users
    4) Add user to group
    5) Exit
    Choose one option 1-5:

4. Exempel på output från monitor_disk.sh ör

    //***** DISK MONITORING *****//
    /run : 1% [OK]
    /sys/firmware/efi/efivars : 1% [OK]
    / : 20% [OK]
    /dev/shm : 0% [OK]
    /run/lock : 0% [OK]
    /boot : 6% [OK]
    /boot/efi : 1% [OK]
    /run/user/1000 : 1% [OK]

5. Exempel på output från system_report_colorcode.sh är

    Filesystem                         Size  Used Avail Use% Mounted on
    tmpfs                              795M  956K  794M   1% /run [OK]
    efivarfs                           128M   35K  128M   1% /sys/firmware/efi/efivars [OK]
    /dev/mapper/ubuntu--vg-ubuntu--lv   30G  5.5G   23G  20% / [OK]
    tmpfs                              3.9G     0  3.9G   0% /dev/shm [OK]
    tmpfs                              5.0M     0  5.0M   0% /run/lock [OK]
    /dev/sda2                          2.0G  101M  1.7G   6% /boot [OK]
    /dev/sda1                          1.1G  6.2M  1.1G   1% /boot/efi [OK]
    tmpfs                              795M   12K  795M   1% /run/user/1000 [OK]
    
    [INFO] Report saved to /home/albin/Linux-inlamning/reports/system_report_20251018_152901.log

6. Exempel på cron körning med system_report.sh är

    [Sat Oct 18 03:30:19 PM UTC 2025] [OK] Cron job successfully scheduled daily at 00:00
    [INFO] Report saved to /home/albin/Linux-inlamning/reports/system_report_20251018_153019.log

**Del 1: Systeminstallation och konfigurering**

- **Ubuntu Server installerad på Hyper V**
	- Konfiguration av Hyper-V Switch
			Då jag från början ville använda min laptop som värd för min ubuntu VM men ville jobba på min stationära dator provade jag först med en external switch vilket inte fungerade bra alls då uppkopplingen var instabil jag gick då över till en intern switch. Började med att tilldela en IP-adress till adaptern på laptopen och sedan en till min Ubuntu VM
			`New-NetIPAddress -InterfaceAlias "vEthernet (InternSSH)" -IPAddress 192.168.100.1 -PrefixLength 24` och  `192.168.100.10/24`
			
	- **Konfiguration av Ubuntu server**
	Jag ändrade SSH konfigurationen med `sudo nano /etc/ssh/sshd_config/` och där ändrade jag porten från 22 til 22226 efter det startade jag om tjänsten med `sudo systemctl restart ssh` därefter behövde jag tillåta porten i UFW med `sudo ufw allow 22226/tcp` och sedan verifiera att SSH lysnar på port 22226 med `sudo ss -tuln | grep 22226`

- **Portproxy på laptopen**
	- Aktiverade portproxy för att vidarebefodra från laptopens WiFi-adress 192.168.1.168 till Ubuntu VM 192.168.100.10 med `netsh interface portproxy add v4tov4 listenport=22226 listenaddress=0.0.0.0 connectport=22226 connectaddress=192.168.100.10`i Powershell.

- Brandväggsregler
	- Jag började med att aktivera UFW med `sudo ufw enable`sedan tillåter jag port 22226 med `sudo ufw allow 22226/tcp` (jag använder /tcp eftersom SSH använder bara TCP så det är onödigt att öppna både UDP och TCP) efter det kontrollerar vi med `sudo ufw status`. Sedan öppnar jag porten i Windows brandvägg med  `New-NetFirewallRule -DisplayName "Allow SSH 22226" -Direction Inbound -LocalPort 22226 -Protocol TCP -Action Allow`

- Första inloggningen med lösenord och sedan med SSH nycklar
	- När nätverk, portproxy och brandväggar var på plats provade jag för första gången att logga in från min stationära dator med `ssh -p 22226 albin@192.168.1.168` när jag sedan var inne var det tid att generera ssh nycklar med `ssh-keygen -t ed25519 -f $HOME\.ssh\albin_secure_key -C "albin@vm"` när nycklarna var genererade använde jag `ssh-copy-id -i ~/.ssh/albin_secure_key.pub "-p 22226 albin@192.168.1.168"` för att kopiera min publika nyckel till ~/.ssh/authorized_keys på min Ubuntu server. Genom att använda ssh-copy-id så sätts rättigheter automatiskt och jag behöver inte använda chmod. 
	- Nu när nycklarna är på plats testade jag att logga in utan lösenord med `ssh -p 22226 -i $HOME\.ssh\albin_secure_key albin@192.168.1.168` när jag kom in och allting funkade tog jag bort lösenords inloggning i konfigurationen genom att sätta `PasswordAuthentication no` och `PermitRootLogin prohibit-password` då kan man inte längre logga in med lösenord och PermitRootLogin prohibit-password gör att root bara kan logga in med nyckel.

- Stabilitetstest
	- När allting var klart körde jag ett stabilitets test för att kolla att jag inte har samma problem som jag hade när jag använde en External Switch (packageloss på runt 70%) med `ping 192.168.1.168 -n 600` från min stationära mot laptopen och från min server mot min stationära med `ping -c 600 192.168.1.168` detta fungerade utan några problem och därav var konfigurationen slutförd.

**Del 2: Användar- och grupphantering**

- Skapa grupper
	sudo groupadd developers
	sudo groupadd admins
	sudo groupadd users
	
- Skapa användare och tilldela grupp
	sudo useradd -m -s /bin/bash -g developers calle
	sudo useradd -m -s /bin/bash -g developers albert
	sudo useradd -m -s /bin/bash -g admins simon
	sudo useradd -m -s /bin/bash -g users lukas
	sudo useradd -m -s /bin/bash -g users maxi

	
- Sätta lösenord
	sudo passwd calle
	sudo passwd albert
	sudo passwd simon
	sudo passwd lukas
	sudo passwd maxi

- Ge admins sudo rättigheter
	För att ge admins gruppen sudo rättigheter körde jag `sudo visudo` och där inne ändrade jag 

> %admins ALL=(ALL) ALL

 till 

> %admins ALL=(ALL:ALL) ALL

 och då har admins gruppen sudo rättigehter

- Nu skapar jag en delad mapp för varje grupp med korrekt rättigheter, jag börjar med `sudo mkdir /srv/developers` sedan en för admins och en för users, efter det sätter jag ägare och grupp med `sudo chown root:developers /srv/developers` och repeterar för admins och users. Till sist sätter jag rättigheter med `sudo chmod 2770 /srv/developers` och igen repeterar med admins och users.
	
**Del 3: Bash-skript för automatisering - reflektion**

- Alla skripts är väl kommenterade

- Testade alla min skripts med ShellCheck där jag juseterade lite, mest noterbart var i min system_report.sh där jag fick `#SC2129` vilket var pågrund av att flertal echo med `>>`och skrev därför om min echo struktur inne i `{}>>`
- Jag hade även lite svårighet med olika behörigheter där ett problem uppstod när jag ville använda $HOME som sedan ändrades till /root då vissa skripts krävde att man körde dem med suo för att spara backlups till /root
- Jag gjorde även lite annorlunda när jag konfigurerade min ssh anslutning. Jag köra Hyper-V på min laptop och ville sedan koppla upp mig till min Ubuntu server med ssh från min stationära dator. Jag provade med en external switch vilket verkade fungera tills jag märkte sabilitets problem, jag hadepackageloss på kring 60-70% och tappade uppkoppling flertal gånger vilket gjorde det omöjligt att arbeta via SSH. Jag valde då att gå vägen igenom en internal switch, då var jag tvungen att ta bort den externa annars fick jag ingen giltig 192.168-adress, där efter satte jag statiska IP-adresser på min laptop `192.168.100.1` och `192.168.100.10` på min server. Sedan uppstod nästa problem, jag hade skapat en ssh nyckel med ett unikt namn `albin_secure_key` och inte ett standard namn `id_rsa` eller `id_ed25519` så för att kunna koppla upp mig var jag tvungen att ange nyckelvägen varje gång med `-i $HOME\.ssh\albin_secure_key` detta fixade jag sedan genom att skapa en host-alias i `~/.ssh/config` så nu kan jag koppla upp mig med `ssh ubuntusrv`.
- I skriptet `backup.sh` hade jag lite problem med att förstå varför `tar` gav varningen *"Removing leading '/*och hur jag på bästa sätt skulle hantera det. Verkade vara ett harmlöst error men jag fixade det med `if (cd  "$(dirname "$source_dir")" && tar  -czf  "$backup_file"  "$(basename "$source_dir")"); then` vilket är dokumenterat i kommentarerna i `backup.sh`. Hädanefter kommer relativa sökvägar användas i tar för att undvika varningar.
- I **system_report.sh** var det lite klurig att samla flera olika loggkällor (journalctl, last, sudo-loggar och diskstatus) på ett strukturerat sätt, krävdes även lite research kring hur man använde dem. Det var även lite klurig att bygga långa pipes, gjorde det svårt att felsöka. Behövde också i denna skript kika lite extra på hur `$1 $2` osv fungerade i awk då jag använde `$1` för användarnamn (första kolumnen) och `$11` var ofta IP-adressen i SSH loggarna.
-I **monitor_disk.sh** krävdes lite extra att på awk att korrekt jämföra procenttal och skriva ut färgkodade varningar. Felaktiga jämförelser t.ex strängjämförelser istället för numeriska. Lärdom är att använda `-gt/-lt` för numeriska jämförelser.

- **Säkerhetskonfigurationer**
Här har jag som sagt stängt av lösenords inloggningar, genererat en SSH nyckel och bytat default porten från `22` til `22226`.

- **Cron job**
Jag valde att göra det möjligt för användaren att köra skriptsen med argumentet `--setup-cron` för att kunna schemalägga skriptsen som behöver det. **backup.sh** valde jag att göra en backup dagligen vid 00:00 då backupsäldreän 7 dagarkommer tas bort så även om filerna är lite större kommer de att gradvis tas bort och ersättas med nya uppdaterade backups. **system_report.sh** och **system_report_colorcoded.sh** valde jag att köras dagligen, då log filerna de genererar inte ärså stora och tar inte så mycket plats. Att de körs dagligen ger även möjlighet för bättre säkerhet då man efter varje dag kan kolla efter inloggningsförsök, vilka som använt sudo osv. När det kommer till `monitor_disk.sh` är den schemalagd att köra varje tredje timme fram tills den sista körningen 20:00 sedan börjar den igen 06:00 då användaren antagligen inte kommer vara på jobb under natten. Detta för det möjligt för användaren att hålla koll på sitt lagrings utrymme relativt ofta i `disk_status.log`.

**Del 4: Fjärranslutning och säkerhet**
- Här hänvisar jag till **Del 1: Systeminstallation och konfiguration** samt .png filerna som jag bifogar i uppgiften.
> Written with [StackEdit](https://stackedit.io/).

