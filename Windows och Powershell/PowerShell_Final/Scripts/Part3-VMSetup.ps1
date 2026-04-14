#Variabler

$VMName = "TestLab-VM"
$VMGen = 2
$VMMemory = 2GB
$HDDSize = 25gb
$HDDPath = "C:\Users\albin\Desktop\TestVM\VM\$VMName\$VMName.vhdx"
$SwitchName = "Default Switch"
$logPath = "C:\Users\albin\Desktop\TestVM\VM\VMLogs\vm-creation.log"
$isoPath = "C:\Users\albin\Desktop\TestVM\ubuntu-24.04.3-desktop-amd64.iso"

#Kolla så logg mappen finns
$Log = Split-Path $logPath -Parent
mkdir $Log -Force

#Funktion för att skriva data till log fil
function Write-Log {
    param($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $logPath -Append
}

try {
    #Loggar proccessen för att skapa VM
    Write-Log "Börjar proccessen för att skapa VM för $VMName"

    #Skapa mapp för VM
    New-Item -ItemType Directory -Path (Split-Path $HDDPath) -Force

    #Skapar hårddisk för VM
    Write-Log "Skapar hårddisk i $HDDPath"
    New-VHD -Path $HDDPath -SizeBytes $HDDSize -Dynamic

    #Skapa VM
    Write-Log "Skapar VM ($VMName) i generation $VMGen med $VMMemory minne"
    New-VM -Name $VMName -Generation $VMGen -MemoryStartupBytes $VMMemory -VHDPath $HDDPath -SwitchName $SwitchName

    Write-Log "VM $VMName skapad!"

    #Lägger till DVD drive med .iso fil
    Add-VMDvdDrive -VMName $VMName -Path $isoPath
    Write-Log "VM $VMName har fått .iso mountad!"

    #Hämtar DVD drive objektet och sätter det som första boot device
    $dvd = Get-VMDvdDrive -VMName $VMName | Select-Object -First 1
    
    #Sätter UEFI boot med Secure Boot aktiverat (krävs för Ubuntu installation)
    Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd -EnableSecureBoot On -SecureBootTemplate "MicrosoftUEFICertificateAuthority"
    Write-Log "VM $VMName har fått UEFI boot med Secure Boot aktiverat!"
}
catch {
    Write-Log "Fel uppstod: $_"
}