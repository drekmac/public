#Gets a list of computer accounts that are older than the entered number of days. You can also use -searchbase and enter the distinguished name of an OU you'd like to search.
#Example
#Get-StaleComputerAccounts.ps1 -DaysToExpire 365 -File 'c:\temp\staleAccounts.csv' -Searchbase 'OU=Workstations,DC=Contoso,DC=com'
Param
(
    [Parameter(Mandatory = $true,
        HelpMessage = "How many days prior to today that a computer is considered stale enough to be disabled by its PasswordLastSet" )]
    [Int]$DaysToExpire,
    [Parameter(Mandatory = $false,
        HelpMessage = "OU to search, default is everything in current computer domain")]
    [string]$Searchbase,
    [Parameter(Mandatory = $false,
        HelpMessage = "Pipe results to CSV file at this location (optional)")]
    [string]$File
)
if (!($searchbase)) {
    $searchbase = (get-addomain).DistinguishedName
}
Import-Module ActiveDirectory
$select = @(
    @{Name = "LastLogonTimeStamp"; Expression = { ([datetime]::FromFileTime($_.LastLogonTimeStamp)) } }
    'Name'
    'Enabled'
    'PasswordLastSet'
    'Modified'
    'Created'
    'OperatingSystem'
    'Description'
    'Location'
    'IPv4Address'
    'DistinguishedName'
    'SID'
    'LastLogonDate'
)
$Time = (Get-Date).Adddays( - ($DaysToExpire))
$filter = { (LastLogonTimeStamp -lt $Time -and PasswordLastSet -lt $Time) -or (LastLogonTimeStamp -notlike '*' -and PasswordLastSet -lt $time) }

$stale = Get-ADComputer -Filter $filter -SearchBase $searchbase -Properties PasswordLastSet | Sort-Object -Property PasswordLastSet
$all = @()
foreach ($object in $stale) {
    $fulldata = Get-ADComputer -Identity $object.SID -Properties LastLogonTImeStamp, Name, Enabled, Passwordlastset, modified, created, operatingsystem, description, location, ipv4address, distinguishedname, sid, lastlogondate | select-object $select
    $all += $fulldata
}
if ($file) {
    $all | Export-Csv $file -NoTypeInformation
}
$all
