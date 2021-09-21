#Requires -Modules AZ.ConnectedMAchine
#This script list Azure ARC OMS agent extension versions

$subs = Get-AzSubscription

$AllLinuxARCVms = @()

$time1 = Get-Date
foreach ($sub in $subs) {
   $sub.Name
   Set-AzContext -Subscription $sub.Id | Out-Null
   $ARCServers = Get-AzConnectedMachine  | where OSName -EQ Linux

   $i = 0
   foreach ($ARCserver in $ARCServers) {
        
        $i++
        Write-Host "$($i):$($ARCServer.Name). Getiing info from connected server.."
        $Resourcegroupname  = ($ARCServer.Id -split "resourceGRoups/")[1] -split "/" | Select-Object -First 1
        $OMSAgentExt = Get-AzConnectedMachineExtension -MachineName $ARCServer.Name -ResourceGroupName $Resourcegroupname | where InstanceViewType -eq OmsAgentForLinux
        
        if ($null -eq $OMSAgentext) {$OMSExtInstalled = $false;$OMSAgentversion = "na"}
        else {$OMSExtInstalled = $true;$OMSAgentversion = $OMSAgentExt.TypeHandlerVersion}

        $ARCobj = New-Object -TypeName PSObject -Property @{
            OMSAgentExt = $OMSExtInstalled
            Name = $ARCserver.Name
            Status = $ARCServer.Status
            OMSAgentVersion = $OMSAgentversion
            Subscription = $sub.Name
            ResourceGRoupName = $Resourcegroupname
            }
        $AllLinuxARCVms += $ARCobj
        
        }
  
   }

$time2 = Get-Date
Write-Host "Time elapsed: $(($time2 - $time1).minutes) minutes" -ForegroundColor Green

$AllLinuxARCVms

$AllLinuxARCVms | Export-Csv -NoTypeInformation AllLinuxARC.csv


