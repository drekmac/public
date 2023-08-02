#get current setting for whether a WSUS server is in use or not so we can put it back when we're done
$currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | Select-Object -ExpandProperty UseWUServer
#Turns off WSUS server so it can download RSAT from Microsoft
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
#Restarts the update service so the settings take hold
Restart-Service wuauserv
#Gets all Windows features that start with RSAT (you can change this if you want to match only a specific feature)
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
#Sets it back to what it was previously
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU
#Restarts the update service so the settings take hold
Restart-Service wuauserv
