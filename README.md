# OMIGOD-OMSAgentInfo
PowerShell Scripts created to detect machines afected by OMI vulnerability: CVE-2021-38645, CVE-2021-38649, CVE-2021-38648, and CVE-2021-38647


[Additional Guidance Regarding OMI Vulnerabilities within Azure VM Management Extensions](https://msrc-blog.microsoft.com/2021/09/16/additional-guidance-regarding-omi-vulnerabilities-within-azure-vm-management-extensions)

**CheckLogAnalytics.ps1** - This scripts query all Analytics workspaces in all subscriptions and gets the version of the Log analytics agent for every client machine, among other properties   

**CheckAzureVMsOMSAgent.ps1** - This script lists all Azure VM and all the information regarding the OMS agent extension for the VMs

**CheckAzureARCServers.ps1** - This script list Azure ARC OMS agent extension versions
