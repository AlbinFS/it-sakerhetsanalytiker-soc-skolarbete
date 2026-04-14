# Variabler för basmapp, mappar och logfilen
$baseFolder = "C:\Users\albin\Desktop\ITS25 Powershell skripts"
$folders = "Scripts", "Documentation", "UserData", "Backups", "VMLogs"
$logFile = "$baseFolder\setup-log.txt"

#Skapa mappar
foreach ($folder in $folders) {
    $folderPath = "C:\Users\albin\Desktop\ITS25 Powershell skripts\$folder"
    mkdir $folderPath
    Add-Content $logFile "Skapade mapp: $folderPath"
}


#Hämtar 'Access control list' (ACL) för Scripts mappen --> modifiera behörigheter
$acl = Get-Acl "C:\ITLab\Scripts"
$acl.SetAccessRuleProtection($true, $false)  # Stänger av 'inheritance' och tar bort 'ärvda' regler

# Sätter behörigheter Administratör (Modify) och Andvändare (Read & Execute)
$admins = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "Modify", "Allow")
$users = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "ReadAndExecute", "Allow")
$acl.AddAccessRule($admins)
$acl.AddAccessRule($users)

Set-Acl "C:\Users\albin\Desktop\ITS25 Powershell skripts\Scripts" $acl

#Lägg till i log
Add-Content -Path $logFile -Value "Behörighet i Script mappen genererad"

#Skapa välkomsttext-fil i varje mapp och förklara dess syfte
$messages = @{
    "Scripts" = "Denna mapp innehåller administrativa skript, används endast av administratörer."
    "Documentation" = "Denna mapp innehåller dokumentation om företaget."
    "UserData" = "Denna mapp innehåller data som användare skapat samt profiler"
    "Backups" = "I denna mapp sparas backupfiler, både system coh användarskapade backup"
    "VMLogs" = "Denna mapp sparar loggar från virtuella maskiner"
}

foreach ($folder in $folders) {
    $folderPath = "C:\ITLab\$folder"
    $welcomeFile = "$folderPath\VälkomstText.txt"
    $message = $messages[$folder]
    Set-Content -Path $welcomeFile -Value $message
    Add-Content -Path $logFile -Value "Skapade välkomstfil i $folder"
}

#Lägg till datum för slutförd mappstruktur
Add-Content -Path $logFile -Value "Mappstruktur skapad den $(Get-Date)"