$Logfile = "C:\Users\hegargm1\Documents\newusers.log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

$UserList = Import-Csv ".\userslist.csv"
$ad=[ADSI]"LDAP://cn=Users,dc=groupI,dc=sqrawler,dc=com"

$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() 
$root = [ADSI] "LDAP://$($dom.Name)"
$searcher = New-Object System.DirectoryServices.DirectorySearcher $root
$searcher.filter = "(&(objectCategory=person)(objectClass=user))"
$users = $searcher.FindAll()

# to hold usernames gathered from above statements
$usersArray

#Initialize and populate the array with usernames gathered from above statements
foreach($user in $users) {
    $usersArray += $user.Properties.samaccountname
}

foreach ($dataRecord in $UserList)  
{
  $cn=$dataRecord.firstName + ” ” + $dataRecord.surname
  $sAMAccountName=$dataRecord.username
  $givenName=$dataRecord.firstName
  $sn=$dataRecord.surname
  $sAMAccountName=$sAMAccountName.ToLower()
  $displayName=$sn + “, ” + $givenName
  $userPrincipalName=$sAMAccountName + “@groupI.sqrawler.com”
  $password=$dataRecord.password
  write-host $sAMAccountName

  $objUser=$ad.Create(“user”,”CN=”+$cn)
  $objUser.Put(“sAMAccountName”,$sAMAccountName)
  $objUser.Put(“userPrincipalName”,$userPrincipalName)
  $objUser.Put(“displayName”,$displayName)
  $objUser.Put(“givenName”,$givenName)
  $objUser.Put(“sn”,$sn)

  if($usersArray -notcontains $sAMAccountName) {
    $objUser.SetInfo()

    $objUser.SetPassword($password)
    $objUser.psbase.InvokeSet(“AccountDisabled”,$false)
    $objUser.SetInfo()
    LogWrite $cn+$sAMAccountName
  }
  else {
    write-host "Couldnt add user "$sAMAccountName
  }
}