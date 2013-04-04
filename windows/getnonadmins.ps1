$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() 
$root = [ADSI] "LDAP://$($dom.Name)"
$searcher = New-Object System.DirectoryServices.DirectorySearcher $root
$searcher.filter = "(&(objectCategory=person)(objectClass=user))"
$users = $searcher.FindAll()
foreach($user in $users) {
  if($user.Properties.admincount -ne 1)  {
    write-host $user.Properties.cn
  }
}