############ Configuration ##########
############  Version 1.0  ##########
Remove-Variable * -ErrorAction SilentlyContinue
$PMS_IP='192.168.1.100:32400'
$TOKEN=''
$MSG='Abonnement expire : Rendez-vous sur http://SITE.com '
$csv_autorisation = "F:\Plex\Plex_management\Plex_autorisation.csv"
$Web_Hook_Discord = ""
#####################################
#Module pour les notifications
import-Module PSDiscord
#import-Module BurntToast
#####################################
$CSV = Import-Csv $csv_autorisation -Delimiter ";" 
function get_user_to_csv {
$Get_users = invoke-webrequest "https://plex.tv/api/users/?X-Plex-Token=$TOKEN"
$xml_users = [xml]$Get_users
$list_user = @()
    for ($i = 0; $i -lt $xml_users.MediaContainer.user.count; $i++) {
        $search_user = $CSV | ? { $_.user -like $xml_users.MediaContainer.user.username[$i] }
        if($search_user){
            $date_fin = $search_user.'date de fin'
        }  
        else{ $date_fin = "01/01/2020"}
        $object_user = New-Object PSObject
        $object_user | Add-Member Noteproperty -Name ID -Value $xml_users.MediaContainer.user.id[$i] 
        $object_user | Add-Member Noteproperty -Name title -Value $xml_users.MediaContainer.user.title[$i]
        $object_user | Add-Member Noteproperty -Name User -Value $xml_users.MediaContainer.user.username[$i]
        $object_user | Add-Member Noteproperty -Name email -Value $xml_users.MediaContainer.user.email[$i]
        $object_user | Add-Member Noteproperty -Name 'date de fin' -Value $date_fin
        $list_user += $object_user
    }
$list_user | export-csv $csv_autorisation -Delimiter ";" -Encoding UTF8 -NoTypeInformation
}
get_user_to_csv

Write-host "Utilisateur a kick :" $user_a_kick " Avec le message "$MSG -ForegroundColor Blue
#Récup les informations des streams sur Plex
$url = "http://" + $PMS_IP + "/status/sessions?X-Plex-Client-Identifier=$CLIENT_IDENT&X-Plex-Token=$TOKEN"
$sessionURL=invoke-webrequest $url
$xml = [xml]$sessionURL
$user = $xml.MediaContainer.Video.User.title
$session = $xml.MediaContainer.video.session.id
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
    $messageDiscord = "Kick de " + $a_kick + "avec le message : " + $MSG + " Date de fin : " + $date_retard2 
            Send-DiscordMessage -WebHookUrl $Web_Hook_Discord -Text $messageDiscord
            $Ligne.User
    }
