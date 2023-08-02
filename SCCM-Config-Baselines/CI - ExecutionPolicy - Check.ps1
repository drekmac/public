#Script designed to run as a configuration item in a configuration baseline within SCCM/MECM/Whatever they call it these days
#Set compliance rules to = True
$ex = Get-ExecutionPolicy
#The following are the options that will return true, put in any execution policy results that your organization accepts
$test = @(
    'RemoteSigned',
    'AllSigned',
    'Restricted'
)
if($test -contains $ex){
    $true
}
else {
    $false
}