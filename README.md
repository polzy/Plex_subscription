# Plex_subscription
Ouvrir le .ps1 et remplir la conf : 

$PMS_IP='192.168.1.100:32400'
$TOKEN=''
$MSG='Abonnement expire : Rendez-vous sur http://SITE.com '
$csv_autorisation = "F:\Plex\Plex_management\Plex_autorisation.csv"
$Web_Hook_Discord = ""

Lancer le script avec le planificateur de tache Windows. 
Faire une boucle Powershell bug avec Windows donc je ne l'ai pas ajouté, le vidage mémoire ne fonctionne pas donc le script va prendre de plus en plus de RAM.
