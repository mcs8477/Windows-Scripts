#  Purpose: Configure Remote Desktop Services (RDS) to standards
#
#  Author : mcs8477
#  Version: 1.0 
#  Release: 02/15/2017                                                         
#
#  Info on RDS provider found on: https://technet.microsoft.com/en-us/library/ee791871(WS.10).aspx
#  Remote Desktop Services Provider for Windows PowerShell
# ============================================================================================

# ======================================================================
# -- C O N S T A N T S
# ======================================================================
$ModuleNames = @("RemoteDesktopServices")
　
# -- Array of RDS Protocol Base Paths to change
$RDSpaths = @("RDS:\RDSConfiguration\connections\ICA-CGP\SessionTimeLimitSettings\",`
			"RDS:\RDSConfiguration\connections\ICA-SSL\SessionTimeLimitSettings\",`
			"RDS:\RDSConfiguration\connections\ICA-TCP\SessionTimeLimitSettings\",`
			"RDS:\RDSConfiguration\connections\RDP-Tcp\SessionTimeLimitSettings\")
　
$OverrideUser = 0
$InfiniteTime = 0
$FifteenMin = 900000
$TwoHrs = 7200000
$Disconnect = 1
　
# ======================================================================
# -- F U N C T I O N S
# ======================================================================

Function Import-PowerShellModule {
# ============================================================================================
# -- Import-PowerShellModule
# ============================================================================================
#	Parameters:
#		$ModuleName - Name of PowerShell module to import
#
#	Example Use:
#		Import-PowerShellModule ActiveDirectory
#		
# ============================================================================================
	Param (
		[Parameter(Mandatory=$true)]
		[String] $ModuleName
	) # END Param block
	
	Write-Host "Loading required module:" $ModuleName
	if (-not (Get-Module $ModuleName)) {
		try {
			Import-Module $ModuleName -Force -ErrorAction Stop
		} # End try
		catch {
			Write-Host " "
			Write-Host "=========================================================================================" -BackgroundColor Red -ForegroundColor White
			Write-Host "W A R N I N G:  Unable to load the required modules for provided PowerShell CMDLETS !!   " -BackgroundColor Red -ForegroundColor White
			Write-Host "=========================================================================================" -BackgroundColor Red -ForegroundColor White
			Write-Host " "
		} # End catch
	} # End IF module isn't loaded

　
} # END Import-PowerShellModule

# ======================================================================
# -- M A I N
# ======================================================================
cls
　
# ** Add the required PowerShell modules
foreach ($ModuleName in $ModuleNames) { 
	Import-PowerShellModule $ModuleName 
}
　
# *****************************************************************
# ** Set Connection Protocol Settings
# *****************************************************************
foreach ($RDSpath in $RDSpaths) {
	Write-Host "Current Settings" -BackgroundColor White -ForegroundColor Red
	dir $RDSpath
	
	$TimeLimitPath = $RDSpath + "TimeLimitPolicy"
	Set-Item -path $TimeLimitPath -Value $OverrideUser -ActiveSessionLimit $InfiniteTime -IdleSessionLimit $TwoHrs -DisconnectedSessionLimit $FifteenMin
　
	$ConnectionPolicyPath = $RDSpath + "BrokenConnectionPolicy"
	Set-Item -Path $ConnectionPolicyPath -Value $OverrideUser -BrokenConnectionAction $Disconnect
	
	Write-Host " "
	Write-Host "New Settings" -BackgroundColor White -ForegroundColor Green
	dir $RDSpath
	
	Write-Host "================================================================================="
	Write-Host " "
}
　
# *****************************************************************
# ** Set RDS License Server
# *****************************************************************
$ServOS = Get-WmiObject -Class Win32_OperatingSystem
# ** We have different RDS license servers for two current licenses, based on OS
if ($ServOS.Caption.StartsWith("Microsoft Windows Server 2008")) {
	Write-Host "Found Windows 2008 R2 Server"
	$RDSLicenseSvr = "RDSlicenseSrv1.domain.com"
	}
else {
	$RDSLicenseSvr = "RDSlicenseSrv2.domain.com"	
}
Write-Host "Selected RDS License Server:" $RDSLicenseSvr
　
$CurrentLicSvr = Get-ChildItem RDS:\RDSConfiguration\LicensingSettings\SpecifiedLicenseServers
if ($CurrentLicSvr.Name -ne $RDSLicenseSvr) {
	Write-Host "Adding RDS License Server..."
	New-Item -path RDS:\RDSConfiguration\LicensingSettings\SpecifiedLicenseServers –name $RDSLicenseSvr
	}
else {
	Write-Host "RDS License Server" $RDSLicenseSvr "is already Specified"
}
　
# ======================================================================
# -- E N D
# ======================================================================
Write-Host " "
write-host " @@@  Finished Script @@@"
