$filterSpec = "Metasploit-framework"

$hives = @("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")
$hives |% {
  $keys = gci $_ -Recurse
  $subkeys = $keys |% {
    $displayName = [string]$_.GetValue("DisplayName")
    $uninstallString = ([string]$_.GetValue("UninstallString")).ToLower().Replace("/i", "").Replace("msiexec.exe", "")

    if ($displayName.StartsWith($filterSpec)) {
      msfdb stop
      Write-Host "Uninstalling product: $displayName"
      Write-Host "$uninstallString"
      start-process "msiexec.exe" -arg "/X $uninstallString /qn" -Wait
    }
  }
}
