#This script lists all Azure VM and all the information regarding the OMS agent extension for the VMs

#Get all Azure Subscriptions
#Connect-AzAccount -UseDeviceAuthentication
$subs = Get-AzSubscription

$AllLinuxVms = @()

#Checking VMs in All subscriptions and its extensions
$time1 = Get-Date

$token = Get-AzAccessToken
foreach ($sub in $subs) {
    $sub.Name
    Set-AzContext -Subscription $sub.Id | Out-Null
    $LinuxVM = Get-AzVM -Status | Where-Object {$_.StorageProfile.OsDisk.OsType.ToString() -eq "Linux"}
    
    foreach ($VM in $LinuxVM) {
    $LAExtension = Get-AzVMExtension -VMName $VM.Name -ResourceGroupName $vm.ResourceGroupName -Status  |  where Publisher -eq "Microsoft.EnterpriseCloud.Monitoring"
  
    if ($null -eq $LAExtension) {$LAExtensionInstalled = $false;$Version = "na";$AutoUpgradeMinorVersion = "na"}
    else {$LAExtensionInstalled = $true; $AutoUpgradeMinorVersion = $LAExtension.AutoUpgradeMinorVersion
    
        $uri = "https://management.azure.com/subscriptions/$($sub.id)/resourceGroups/$($vm.ResourceGroupName)/providers/Microsoft.Compute/virtualMachines/$($VM.Name)/instanceView?api-version=2017-03-30"
    $auth = "$($Token.Type) "+ " " + "$($Token.token)"
    $query = Invoke-RestMethod -Method Get -Headers @{
            Authorization   = $auth
            'Content-Type'  = "application/json"
        } -Uri $uri -ErrorAction SilentlyContinue

    $Version = ($query.extensions | where name -EQ OmsAgentForLinux).typeHandlerVersion
    }

    $LinuxVMobj = New-Object PSObject -Property @{
        Name = $VM.Name
        ResourceGroupName = $vm.ResourceGroupName
        Subscription = $sub.Name
        PowerState = $vm.PowerState
        OMSAgentversion = $Version
        LAExtensionInstalled = $LAExtensionInstalled
        AutoUpgradeMinorVersion = $AutoUpgradeMinorVersion
        }
    $AllLinuxVms += $LinuxVMobj
    }
    
}
$time2 = Get-Date
Write-Host "Time elapsed: $(($time2 - $time1).minutes) minutes" -ForegroundColor Green

$AllLinuxVms | Export-Csv -NoTypeInformation .\AllLinuxVms.csv -Force