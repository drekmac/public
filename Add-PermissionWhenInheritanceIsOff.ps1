#This script will add the group indicated with permissions on any subfolder under the input path that has inheritance turned off
#needs ntfssecurity module installed
if(!(Get-Module NTFSSecurity)){
    Install-Module NTFSSecurity
}
$secGroup = "domain\GroupName"
$filepath = Read-Host -Prompt "Enter path: "
Import-Module NTFSSecurity
Get-ChildItem $filepath -Recurse | 
Get-NTFSInheritance | 
Where-Object AccessInheritanceEnabled -eq $false | 
Add-NTFSAccess -Account $secGroup -AccessRights Full