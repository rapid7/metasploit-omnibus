$source = "http://windows.metasploit.com/metasploitframework-latest.msi"
$destination = "$env:userprofile\Downloads\metasploitframework-latest.msi"

Write-Output "Downloading latest Metasploit Framework"
Import-Module BitsTransfer
Start-BitsTransfer -Source $source -Destination $destination

Write-Output "Updating Metasploit Framework"
$arguments =
@(
	"/I `"$env:userprofile\Downloads\metasploitframework-latest.msi`"",
	"/QB",
	"/L*V `"$ENV:TEMP\msfupdate.log`""
)

$p = Start-Process -FilePath "msiexec" -ArgumentList $arguments -Wait -PassThru
if($p.ExitCode -ne 0)
{
	Write-Output "Metasploit update failed, error code: $($p.ExitCode)"
} else {
	Write-Output "Update Complete"
}
