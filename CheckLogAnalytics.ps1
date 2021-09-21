# This scripts query all Analytics workspaces in all subscriptions and gets the version of the Log analytics agent for every client machine, among other properties 
#LogAnalytics query

$query= @"
Heartbeat
| summarize arg_max(TimeGenerated, *) by SourceComputerId
| where OSType == "Linux"
| project  Computer,ComputerIP,Version,OSName,OSMajorVersion,TimeGenerated
"@


# Get all Azure Subscriptions
#Connect-AzAccount -UseDeviceAuthentication
$subs = Get-AzSubscription


$GlobalResults = @()


foreach ($sub in $subs)
{


        # Set Azure Subscription context    
        Set-AzContext -Subscription $sub.Id | Out-Null

        $Workspaces = Get-AzOperationalInsightsWorkspace
        Write-Host "Subscription: $($sub.name)" -ForegroundColor Cyan
        Write-Host "`tFound $($Workspaces.Count) Workspaces:" -ForegroundColor Green
        foreach ($Workspace in $Workspaces) {Write-Host "`t`t $($workspace.name)"}
        
 
        foreach ($workspace in $Workspaces) {
                
        $Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId.Guid -Query $query
        
        if (($Results.Results | measure).Count -ne 0)
            {

            Write-Host "`t`t`tFound $(($Results.Results | measure).Count) Linux VMs in workspace $($Workspace.Name).." -Foreground Green

            $FullData = @()
            $Data = $Results.Results
            $Data = $Data | ConvertTo-Json | ConvertFrom-Json | ForEach-Object {
                $_ |Add-Member -MemberType NoteProperty -Name Subscription -Value $sub.Name;
                $_ |Add-Member -MemberType NoteProperty -Name LAWorkspace -Value $workspace.Name
                $FullData += $_}
            $GlobalResults += $FullData
            $FullData | ft -AutoSize
                        }     
        else {Write-Host "`t`t`tNo Linux VMs found in workspace $($Workspace.Name).."}
        }
}

$GlobalResults | Export-Csv .\AllLogAnalyticsAgents.csv -NoTypeInformation


