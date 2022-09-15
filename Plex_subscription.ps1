############ Configuration ##########
############  Version 1.0  ##########
$PMS_IP='192.168.1.100:32400'
$TOKEN=''
$MSG='Abonnement expire : Rendez-vous sur http://BITOKU.com '
$user_a_kick = "Polzy"
$secondes = "600"
$csv_autorisation = "F:\Plex\Plex_management\Plex_autorisation.csv"
$image_gif = "touz.gif"
$Web_Hook_Discord = 
#####################################
#Module pour les notifications
import-Module PSDiscord
import-Module BurntToast
$searchIMP = ""
$a_kick = ""
$CSV = Import-Csv $csv_autorisation -Delimiter ";" 
Write-host "Utilisateur a kick :" $user_a_kick " Avec le message "$MSG -ForegroundColor Blue
#Récup les informations des streams sur Plex
$url = "http://" + $PMS_IP + "/status/sessions?X-Plex-Client-Identifier=$CLIENT_IDENT&X-Plex-Token=$TOKEN"
$sessionURL=invoke-webrequest $url
$xml = [xml]$sessionURL
$user = $xml.MediaContainer.Video.User.title
$session = $xml.MediaContainer.video.session.id
$object2 = ""
$list = @()
#Si il y a plus d'un utilisateur on fait cette boucle (a cause d'un bug 1 utilisateur)
if ($session.count -gt "1"){
for ($i = 0; $i -lt $session.count; $i++) {
    $object2 = New-Object PSObject
    $object2 | Add-Member Noteproperty -Name User -Value $user[$i] 
    $object2 | Add-Member Noteproperty -Name session -Value $session[$i]
    $list += $object2
}
}
#Si il y a un utilisateur on fait cette boucle (a cause d'un bug 1 utilisateur)
else{
    $object2 = New-Object PSObject
    $object2 | Add-Member Noteproperty -Name User -Value $user
    $object2 | Add-Member Noteproperty -Name session -Value $session
    $list += $object2
}
Write-host "Utilisateur en stream :" $list.user -ForegroundColor Blue
#On cherche l'user a kick
$date = get-date 

Foreach($Ligne in $CSV){
    if($list.user -like $Ligne.User)
    {
        $date_retard2 = [Datetime]::ParseExact($Ligne.'date de fin', 'dd/MM/yyyy', $null)  
    if ($date -gt $date_retard2){
       $a_kick = $Ligne.User
        write-host "Abonnement de" $Ligne.User "terminé." $date_retard2  -ForegroundColor Blue
    }
}
}



$searchIMP = $list  | ? { $_.user -like $a_kick }
#Si il est trouvé, on kick ce FDP
if($searchIMP){
    write-host "Utilisateur a kick trouvé !" $searchIMP.user -ForegroundColor Blue
$u = $searchIMP.user
$s = $searchIMP.session
invoke-webrequest "http://$PMS_IP/status/sessions/terminate?sessionId=$s&reason=$MSG&X-Plex-Client-Identifier=$u&X-Plex-Token=$TOKEN"
write-host "Kick $a_kick OK." -ForegroundColor Blue
}
