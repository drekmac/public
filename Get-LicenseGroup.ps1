#This is for checking membership of license groups, so outside of the organization this is probably worthless
Add-Type -AssemblyName PresentationFramework
function Show-OpenFileDialog {
    <#
            .SYNOPSIS
            Shows up an open file dialog.
            .EXAMPLE
            Show-OpenFileDialog
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [System.String]
        $Title = 'Windows PowerShell',
         
        [Parameter(Mandatory = $false, Position = 1)]
        [Object]
        $InitialDirectory = "$Home\Downloads",
         
        [Parameter(Mandatory = $false, Position = 2)]
        [System.String]
        $Filter = 'CSV-files|*.csv|Everything|*.*'
    )
     
    Add-Type -AssemblyName PresentationFramework
     
    $dialog = New-Object -TypeName Microsoft.Win32.OpenFileDialog
    $dialog.Title = $Title
    $dialog.InitialDirectory = $InitialDirectory
    $dialog.Filter = $Filter
    if ($dialog.ShowDialog()) {
        $dialog.FileName
    }
    else {
        Throw 'Nothing selected.'   
    }
}
function Get-Lic {
    param (
        [string]$mail,
        [string]$dawg
    )
    if ($mail) {
        $res.text = "$mail `n"        
        $user = get-aduser -filter { mail -eq $mail } -properties memberof
        $res.text += "$($user.samaccountname) `n"
    }
    elseif ($dawg) {
        $res.text = "$dawg `n"
        $user = get-aduser $dawg -properties memberof, mail
        $res.text += "$($user.mail) `n"
    }
    $res.text += "----------`n"
    if ($user) {
        $results = $user.memberof | Where-Object { $_ -like 'CN=M365*' }
        if ($results) {
            $results | Sort-Object | ForEach-Object {
                $name = (Get-ADObject $_).Name
                $res.text += "$name `n"
            }
        }
        else {
            $res.text += "No license groups found."
        }
    }
    else {
        $res.text += "User not found."
    }   
}
function Get-RSAT {
    Start-Process powershell -verb runAs -ArgumentList 'Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0;Restart-Service wuauserv;Get-WindowsCapability -Name "Rsat.activedirectory*" -Online | Add-WindowsCapability -Online'
}

$output = ".\365groups.csv"
#GUI
[xml]$Form = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Get-LicenseGroup" Height="500" Width="660" Background="#FF262626">
        <StackPanel>
            <Label Name="Title" Content="Get-LicenseGroup" Margin="10,0,0,0" HorizontalAlignment="Left" VerticalAlignment="Center" Height="50" Foreground="DarkGray" FontSize="21" />
            <Button Name="OpenFile" Content="Open CSV" HorizontalAlignment="Center" Height="26" Width="150" Margin="5" VerticalAlignment="Center" Background="DarkGray"/>
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="160" />
                    <ColumnDefinition Width="160" />
                    <ColumnDefinition Width="160" />
                    <ColumnDefinition Width="160" />
                </Grid.ColumnDefinitions>
                <Grid.RowDefinitions>
                    <RowDefinition Height="30" />
                    <RowDefinition Height="30" />
                    <RowDefinition Height="30" />
                </Grid.RowDefinitions>
                <Label Name="DawgLabel" Content="User NetworkID(siu8*)" HorizontalAlignment="Center" Height="26" VerticalAlignment="Center" Foreground="DarkGray"/>
                <TextBox Name="DawgEntry" Grid.Column="1" HorizontalAlignment="Center" Width="150" Margin="5" VerticalAlignment="Center" Background="DarkGray" />
                <Button Name="DawgButton" Grid.Column="2" Content="Get-LicenseGroups" HorizontalAlignment="Center" Height="26" Width="150" Margin="5" VerticalAlignment="Center" Background="DarkGray" />
                <Button Name="InstallRSAT" Grid.Column="3" Content="Install RSAT Module" HorizontalAlignment="Center" Height="26" Width="150" Margin="5" VerticalAlignment="Center" Background="DarkGray" />
                <Label Name="OrLabel" Content="-OR-" Grid.Row="1" Grid.Column="1" HorizontalAlignment="Center" Height="26" VerticalAlignment="Center" Foreground="DarkGray"/>
                <Label Name="EmailLabel" Content="User Email" Grid.Row="2" HorizontalAlignment="Center" Height="26" VerticalAlignment="Center" Foreground="DarkGray"/>
                <TextBox Name="EmailEntry" Grid.Row="2" Grid.Column="1" HorizontalAlignment="Center" Width="150" Margin="5" VerticalAlignment="Center" Background="DarkGray" />
                <Button Name="Button" Grid.Row="2" Grid.Column="2" Content="Get-LicenseGroups" HorizontalAlignment="Center" Height="26" Width="150" Margin="5" VerticalAlignment="Center" Background="DarkGray" />
            </Grid>
            <Label Name="Res" Content="Results" Margin="10" HorizontalAlignment="Left" Height="24" VerticalAlignment="Top" Width="69" Foreground="DarkGray" FontWeight="Bold"/>                                
            <TextBox Name="Results" Margin="10" VerticalScrollBarVisibility="Auto" HorizontalAlignment="Center" Height="200" TextWrapping="Wrap" VerticalAlignment="Top" Width="500" Background="LightGray" />            
        </StackPanel>
</Window>
"@
$NR = (New-Object System.Xml.XMLNodeReader $Form)
$Win = [Windows.Markup.XamlReader]::Load( $NR )

$OpenButton = $Win.FindName("OpenFile")
$dawgbutton = $Win.FindName("DawgButton")
$dawgentry = $win.FindName("DawgEntry")
$RSAT = $win.FindName("InstallRSAT")
$button = $Win.FindName("Button")
$emailentry = $win.FindName("EmailEntry")
$res = $win.FindName("Results")

if (Get-Module -ListAvailable -Name activedirectory) {
    Import-Module activedirectory
}
$OpenButton.Add_Click({
        $file = Show-OpenFileDialog
        $csv = Import-Csv $file

        $total = @()
        foreach ($line in $csv) {
            $365groups = @()
            $user = ""
            $results = ""
            $stringgroups = ""
            $user = get-aduser $line.NetworkID -properties memberof, mail
            if ($user) {
                $results = $user.memberof | Where-Object { $_ -like 'CN=M365*' }
                $results | Sort-Object | ForEach-Object {
                    $name = (Get-ADObject $_).Name
                    $365groups += $name
                }
                $stringgroups = $365groups -join ","
            }
            else {
                $stringgroups = "User Not Found"
            }
            
            $total += New-Object PSObject -Property @{
                NetworkID = $line.NetworkID
                Groups    = $stringgroups
            }
        }
        $total | Export-Csv $output -Force -NoTypeInformation
        Invoke-Item $output
    })
$dawgbutton.Add_Click({
        if (Get-Module -ListAvailable -Name activedirectory) {
            $dawg = $dawgentry.text
            if ($dawg -eq '') {
                [System.Windows.MessageBox]::Show("Please enter a dawgtag for the user", "Missing Value")
            }
            else {
                Get-Lic -dawg $dawg
            }
        }
        else {        
            $res.text = "Please install RSAT to use this app"
        }
    
    })

$RSAT.Add_Click({
        Get-RSAT
    })

$button.Add_Click({
        if (Get-Module -ListAvailable -Name activedirectory) {
            $email = $emailentry.text
            if ($email -eq '') {
                [System.Windows.MessageBox]::Show("Please enter an email for the user", "Missing Value")
            }
            else {
                Get-Lic -mail $email 
            }
        }
        else {        
            $res.text = "Please install RSAT to use this app"
        }
    
    })

[void]$Win.Showdialog()