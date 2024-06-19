# 4 VM's created below

$vms = @{
 
    Name = 'TestingServer01, TestingServer02, TestingServer03, TestingServer04'
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