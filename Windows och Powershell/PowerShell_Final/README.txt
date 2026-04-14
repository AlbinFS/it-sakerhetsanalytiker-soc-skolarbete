'Kort förklaring av vad varje cmdlet i ditt skript gör'

Alla förklaringar finns i skripten som kommentarer
********************************

!OBS! 
För att köra VM skripten krävs en ubuntu.iso fil där behöver du ändra $isoPath till var din .iso fil ligger


********************************
Kör script:
Kan komma att kräva administratörsrättigheter så kör Powershell som admin

Öppna PowerShell som administrator
Navigera till mappen där skripten ligger (cd (sökväg))
Kör med .\(namn) t e x .\Part1-Setup.ps1

Speciella krav:

Part3 kräver att Hyper-V är installerat och aktiverat

Tips:

Om du inte kan köra skripten på grund av att deblir blockerade av 'Execution Policy' kör följande command i Powershell som administrator: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

********************************
