$wmi = Get-WmiObject Win32_service

foreach ($s in $wmi){
	if($s.name -eq "DNS"){
		Write-Host "Found DNS"
		break
	}else{
		Write-Host "Nope"
	}
}