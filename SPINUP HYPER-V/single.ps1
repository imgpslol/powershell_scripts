# Command below Installs the needed cmdlets for hyper-v
# Get-Command  -Module Hyper-V 
# Update the respective fields below for the needed specs on the VM

$vms = @{
 
    Name = 'TestingServer01'
    Generation = '2'
    MemoryStartupBytes = 6GB
    NewVHDPath = 'c:\temp\replacewithnameofvhd.vhdx'
    NewVHDSizeBytes = 50GB
    SwitchName = 'Default Switch'
 
}
 
New-VM @vms
  
Add-VMDvdDrive `
-VMName $vms.Name `
-Path C:\Software\replacewithyouriso.iso
 
Set-VMFirmware -VMName $vms.Name `
-FirstBootDevice ((Get-VMFirmware -VMName $vms.Name).BootOrder | 
Where-Object Device -like *DvD*).Device