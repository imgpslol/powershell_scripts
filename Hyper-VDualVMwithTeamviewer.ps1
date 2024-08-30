# Define VM parameters
$VMNames = @("TestingVM-01", "TestingVM-02")
$VMMemoryStartup = 8GB # Define startup memory for the VM
$VHDPath = "C:\Hyper-V\Virtual Hard Disks" # Path where the VHDX files will be stored
$ISOPath = "C:\Path\To\Windows11.iso" # Path to your Windows ISO
$SwitchName = "Default Switch" # Name of your virtual switch in Hyper-V

# Create a VM function to be re-used if needed
function Create-VM {
    param (
        [string]$VMName
    )
    
    # Create a new VM
    New-VM -Name $VMName -MemoryStartupBytes $VMMemoryStartup -Generation 2 -NewVHDPath "$VHDPath\$VMName.vhdx" -NewVHDSizeBytes 120GB -SwitchName $SwitchName
    
    # Set up boot order to boot from the ISO
    Set-VMFirmware -VMName $VMName -FirstBootDevice $null
    Add-VMDvdDrive -VMName $VMName -Path $ISOPath
    Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMDvdDrive -VMName $VMName)

    # Start the VM to begin Windows installation
    Start-VM -Name $VMName
}

# Function to install software inside the VM using PowerShell Direct
function Install-Software {
    param (
        [string]$VMName
    )

    # Wait for VM to be accessible
    Write-Host "Waiting for $VMName to be accessible..."
    Start-Sleep -Seconds 60 # Wait to ensure the VM is ready, adjust as needed based on your environment

    # Install latest version of Chrome
    Invoke-Command -VMName $VMName -ScriptBlock {
        $chromeInstaller = "$env:TEMP\chrome_installer.exe"
        Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $chromeInstaller
        Start-Process -FilePath $chromeInstaller -ArgumentList "/silent /install" -Wait
        Remove-Item $chromeInstaller
    }

    # Install latest version of TeamViewer
    Invoke-Command -VMName $VMName -ScriptBlock {
        $teamViewerInstaller = "$env:TEMP\TeamViewer_Setup.exe"
        Invoke-WebRequest -Uri "https://download.teamviewer.com/download/TeamViewer_Setup.exe" -OutFile $teamViewerInstaller
        Start-Process -FilePath $teamViewerInstaller -ArgumentList "/S" -Wait
        Remove-Item $teamViewerInstaller
    }

    # Install the latest Windows updates
    Invoke-Command -VMName $VMName -ScriptBlock {
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
    }
}

# Main script execution
foreach ($VMName in $VMNames) {
    # Create VM
    Create-VM -VMName $VMName

    # Install Chrome, TeamViewer, and updates inside the VM
    Install-Software -VMName $VMName
}

Write-Host "VM creation and software installation process is complete!"
