#This script looks through an OU with the specific distinguished name and invokes something on it with the supplied credentials
#asks you for your credentials
$Cred = Get-Credential
#Sets the OU you want to run the commands on, IT WILL ALSO GET ANY IN SUB-OUS
$ou = 'OU=Test,DC=Contoso,DC=com'
#gets all computers within the specified OU
$computerlist = Get-adcomputer -Filter * -SearchBase $ou
#cycles through each computer the last command returned
foreach ($computer in $computerlist) {
    #invokes the script commands on the remote computer
    Invoke-Command -ComputerName $computer.Name -Credential $Cred -ScriptBlock {
        #Write commands you want to invoke below
    }
}