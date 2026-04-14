#Definera sökvägar
$userPath = "C:\ITLab\UserData\"
$documentationPath = "C:\ITLab\Documentation"

#Skapa 10 textfiler (user1,user2...) i = 1 om i är mindre än 10 i+1 (i=2) repetera loop
for ($i = 1; $i -le 10; $i++) {
    $fileName = "User$i.txt"
    $filePath = Join-Path -Path $userPath $fileName
    $content = @"
        Namn: User$i
        Avdelning: IT
        E-Mail: user$i@ITS25.com
"@

    Set-Content -Path $filePath -Value $content
}

#Läser igenom alla text filer i UserData map
$txtFiles = Get-ChildItem -Path $userPath -Filter "*.txt"

#Loopar för att räkna och samla filnamn samt skapar en tom array för att lagra filnamn
$count = 0
$sumList = @()

foreach ($file in $txtFiles) {
    $sumList += $file.Name
    $count++
}

#Skapar fil för sammanfattning och fyller med array'n vi gjorde tidigare som nu har filnamn
$sumFilePath = Join-Path -Path $documentationPath "user-summary.txt"
Set-Content -Path $sumFilePath -Value $sumList

#Skriv ut antal filer på skärmen
Write-Host "Antal filer: $count"
