#Variabler för lagring av användare och datornamn
$user = $env:USERNAME
$computerName = $env:COMPUTERNAME

#Variabler för att samla systeminformation
$dateTime = Get-Date #Hämtar datum och tid
$winVersion = (Get-ComputerInfo).WindowsProductName #Hämtar systeminformation
$disk = Get-PSDrive -Name C #Hämtar information om enheten i detta fall C disken
$runningServices = Get-Service | Where-Object{$_.Status -eq "Running"} | Select-Object -ExpandProperty Name <#Get-Service hämtar alla tjänster på systemet,
Where-Object filtrerar objekt baserat på ett vilkor - i detta fall "{$_.Status -eq "Running"}" som kollar ifall
Status = "Running". Select-Object -ExpandProperty Name gör att vi bara hämtar Namnet från varje tjänst#>

#Variabler för kritiska tjänster så som “Spooler”, “DHCP”, “DNS” samt variabel för varningsmeddelande om någon av tjänsterna är stoppade
#Vi skriver Spooler", "Dhcp", "Dnscache" då detta är deras korrekta namn inne i 'services.msc' --> "Property" --> "Service name"
$criticalServices = "Spooler", "Dhcp", "Dnscache"
$warnings = @()

#Nu ska vi kontrollera det tillgängliga diskutrymmet på C: Enheten, enklast för mig med erfarenhet av C# är att använda [math] för att konvertera
#ledigt (.Free) diskutrymme från byte till GB och avrunda till jämt värde med 2 decimaler
$freeDisk = [math]::Round($disk.Free / 1gb, 2)

#Loop för att kontrollera alla kritiska tjänster
foreach ($service in $criticalServices){
    $status = (Get-Service -Name $service).Status
    if ($status -ne "Running") {
        $warnings += "Tjänsten '$service' är stoppad!"
    }
}

#If sats som kollar ifall där finns varningar eller inte, finns där inga så skriv ut i rapport och sammanfattning att 'Alla kritiska tjänsterkörs'
#Om där finns tjänster skriv då istället ut 'Tjänsten '$tjänst' är stoppad!' som vi tarfrån loopen ovan
if ($warnings.Count -eq 0) {
    $serviceStatus = "Alla kritiska tjänster kör!"
}
else {
    $serviceStatus = $warnings -join "`n"
}

#Väg till var rapporten ska sparas
$reportFile = "C:\ITLab\Documentation\system-report.txt"

#Skapar en array för rapporten, härandvänder vi Multiline String, även kallad "Here-strings" som låter dig skriva komplexa 'strings' som gåröver flertal 
#linjer.
$report = @"
    **********SYSTEMINFORMATION**********

    Användare: $user
    Datornamn: $computerName
    Datum & Tid: $dateTime
    Windows version: $winVersion

            *****DISKUTRYME*****

    Ledigt utrymme: $freeDisk GB

         *****KÖRANDE TJÄNSTER*****

$($runningServices -join "`n")

          *****TJÄNSTSTATUS*****

    $serviceStatus
"@

#Sparar rapporten till .txt fil i Documentation mappen
Set-Content -Path $reportFile -Value $report #Skriver innehåll till en fil
Write-Host "Rapport har sparats till: $reportFile" #Skriver ut texttill skärmen / konsolen

#Skriv ut sammanfattning påskrämen
$summary = @"
     **********SYSTEMINFORMATION**********

    Användare: $user
    Datornamn: $computerName
    Datum & Tid: $dateTime
    Windows version: $winVersion

            *****DISKUTRYME*****

    Ledigt utrymme: $freeDisk GB

         *****KÖRANDE TJÄNSTER*****

$($runningServices -join "`n")

          *****TJÄNSTSTATUS*****

    $serviceStatus
"@

Write-Host $summary

