[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$VMName,

    [Parameter(Mandatory=$true)]
    [SecureString]$AdminPassword,

    [string]$DomainName
)

if ($DomainName) {
    $userName = "$DomainName\admin"
} else {
    $userName = 'admin'
}
$pass = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($userName, $pass)

do {
    $result = New-PSSession -VMName $VMName -Credential $cred -ErrorAction SilentlyContinue

    if (-not $result) {
        Write-Verbose "Waiting for connection with '$VMName'..."
        Start-Sleep -Seconds 1
    }
} while (-not $result)
$result