# NOTES:

This set of scripts sends multiple commands in a single line. This design is deliberately conceived with the purpose of sending the same object to multiple devices simultaneously from the backend. From my point of view, this approach simplifies the development task on the backend, although the scripts are not visually appealing.
There are other systems, such as the Mikrotic API collection, that allow sending multiple lines of commands.
You can separate the commands within the same line using a semicolon (;) (for example, /create user [...]; /create group [...]; delay 3s).
Texts that we wish to send, such as names or saved scripts, should be enclosed in double quotation marks (""). Within this content, line breaks are performed using \r\n, and characters like double quotes (") and the dollar sign ($) need to be escaped.


- SYSTEM AND RESOURCES INFO:
  /system identity print;/system resource print

- SEARCH IN FILES, FOR EXAMPLE A BACKUP FILE:
  /file print where name~"backup"

- EXAMPLE OF EMAIL SENDING INFORMATION AND A BACKUP
  /tool e-mail send file=name_backup.backup to="MAIL@TEST.COM" body="Backup" subject="$[/system identity get name] $[/system clock get time] $[/system clock get date] Backup"

- SET LEASE TIME IN 10MIN:
  set lease-time=10m hotspot

- SHORT INTERVAL FOR REPAIR PERIODS
  set lease-time=30s hotspot

- LIST NETWORKS WITH LEASE TIME LESS THAN 3 MINUTES
  /ip dhcp-server print where lease-time<3m

- LIST OF NETWORKS WITH DIFFERENT LEASE WITHIN 10 MIN
  /ip dhcp-server print where lease-time!=00:10:00

- CORRECT TO 10MIN THE LEASE TIME OF NETWORKS THAT HAVE IT DIFFERENT TO THIS VALUE
  /ip dhcp-server set [find where lease-time!=00:10:00] lease-time=00:10:00

- SAME AS ABOVE BUT REDUCED SEARCH NAMES IN NETWORKS WITH NAME HOTSPOT
  /ip dhcp-server set [find where lease-time!=00:10:00 name=hotspot] lease-time=00:10:00

- CREATE A SCRIPT AND SCHEDULE IT IN ORDER TO REVIEW THE LEASE TIME SETTINGS AND CONFIGURE IT IN 10 MIN
  /system script add name=LeaseTime_Revisor owner="admin" source="####### Lease Time Ament ########\r\n####### corrects the leasetime to 10 minutes if it has a different value\r\n/ip dhcp-server set [find where lease-time!=00:10:00 name=hotspot] lease-time=00:10:00;";:delay 3s;/system scheduler add name=leasetime_revisor interval=1d on-event=LeaseTime_Revisor;

- GENERATE A BACKUP NAME BASED ON MKT AND DATE VARIABLES
  :local folderName "/backup"; :local name [/system identity get name]; :local date [/system clock get date]; :local day [ :pick $date 4 6 ]; :local month [ :pick $date 0 3 ]; :local year [ :pick $date 7 11 ]; :local backupName ("$folderName"."/".$name."_".$day."-".$month."-".$year); /system backup save name=$backupName;

- SAVE A BACKUP SCRIPT IN MIKROTIK AND CREATE A SCHEDULED TASK EVERY 30 DAYS:
  /system script add name=backup_monthly owner="admin" source="####### BACKUP TEST ########\r\n## Generam nom ###\r\n:local folderName \"/backup\";\r\n:local name [/system identity get name];\r\n:local date [/system clock get date];\r\n:local day [ :pick \$date 4 6 ]; \r\n:local month [ :pick \$date 0 3 ];\r\n:local year [ :pick \$date 7 11 ];\r\n:local backupName \"\$folderName/\$name_\$day-\$month-\$year\";\r\n### Cream backup ####\r\n/system backup save name=\$backupName;\r\n:log info \"Backup Completed\";";:delay 3s;/system scheduler add name=backup_monthly interval=30d on-event=backup_monthly;

- LIST ALL USERS (only names)
  :foreach user in=[/user print as-value] do={put ($user->"name")}

- FILTER USERS BY NAME
  :foreach user in=[/user print as-value where name~"XXXXXXX"] do={put ($user->"name")}

- LIST ALL USERS AND GROUPS
  :foreach user in=[/user print as-value] do={:local name ($user->"name"); :local group ($user->"group"); :put ("Username: " . $name . ", Group: " . $group)}

- FIND USER BY NAME
  :local usernameToFind "NAME"; :local userExists false; :foreach user in=[/user print as-value] do={:local name ($user->"name"); :if ($name = $usernameToFind) do={:put ("User '" . $usernameToFind . "' exist.");:set userExists true}}; :if ($userExists = false) do={:put ("User '" . $usernameToFind . "' does not exist.")}

- CHECK AND DEPLOY USER: GROUP, AND SERVICE
  :local userPassword "XXXXXXXXXXX"; :local userName="XXXXXXXX"; local groupName="XXXXXXXX"; :local userExists [/user find where name=$userName]; :local groupExists [/user group find where name=$groupName]; :if ($groupExists != "") do={:put ("Group already exist")} else={/user group add name=$userName policy="local, ssh, reboot, read, write, policy, test, winbox, api"; :put ("Group created")}; :if ($userExists != "") do={/user set $userExists password=$userPassword; :put ("User exist. Updated password")} else={/user add name=$userName group=$groupName password=$userPassword; :put ("User created.")};
