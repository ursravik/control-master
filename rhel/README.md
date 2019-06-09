# Redhat and Centos Patching using ansible

Ansible playbook and shell scripts used for patching and validating suse servers. 

## Playbook phases

```
• Registration and package update check 
• Pre patch info collection 
• Prereboot
• Update
• Post patch info collection
• Deviation check and notification 
```

### Registration and package update check 

Phase one: checks if server is registered and any packages found for an update. Only if server registered and package found for
update server is pushed to next stage.
Role:  patchcheck

### Pre patch info collection 

Phase Two:  Excutes pre-check.sh shell script to catpure current system config. You can add commands of your choice into this
shell script to capture system state before patching. Output of this script is collected in central ansible node. 
Role: prepatch

### Prereboot and update

Phase three: Server is rebooted if uptime found greater than 180 days before all patches are applied and rebooted.
Role: patch

### Post patch info collection

Phase four: Excutes post-check.sh shell script to catpure system config post reboot. You can add commands of your choice into this
shell script to capture system state after patching. You can also add list of services you wish to check/start post reboot. In 
this case I have added zabbix. 
Role: postpatch


### Deviation check and notification

Phase Five: Compares output of post-check.sh and per-check.sh log file and notifies the user if any deviations found. For example 
in pre-checks.sh there is command to capture number of file system mounts on the server, this number is comapred with post check 
script output. If any deviations found in the number of mounts an email is sent ot system admin. 
Role: deviation

## Prerequisite

* Populate password less login from control node to all severs.
* Try to fix all suse registration issues before patching so servers are not skipped.
* Shutdown middleware and DB using different playbook or manually before patching.
* Ensure there are no NFS mount issues ( df command should return output without delays ).
* Update system amdin email address and relay server address in playbook vars before excution.
* Ensure all the mandate services are enabled to start post reboot.
* Include subscripts and services you wish to start post reboot in postpatch role. 
* Increase the fork value in ansible.cfg to increase parallelism. 


## How to excute playbook

* Update hosts with list of server ready to patch.
* Update email and relay server in playbook patchstatus.yml and patchfinalplay.yml.
* Update hosts and excute patchstatus.yml, "ansible-playbook patchstatus.yml -K" this will check for registration and package  update.
  You can remove servers that are not registered and no packages found for update from final play.
* Update hosts and excute patchfinalplay.yml, "ansible-playbook patchfinalplay.yml -K" this will run all the roles and complete
  patching. System admin will be notified on failure and completion. 
  
## Roles explained

### patchcheck
Run yum check-update to check regitration and number of packages found for update. 
This output is captured and copied into control node in "./patching-log" for system admin verification. If server is 
registered and package found a tmp file is created on client servers "/tmp/repoinfo-servername" this file checked 
in other roles, ie if file exists update,post patch and other roles are excuted or sever is skipped. 

### prepatch
Run pre check script to capture server state and config. Pre-check.sh will save output locally in client in path /tmp/patching-data/ and on control node "./patching-log".  Run pre check only if package is found for update ie if tmp file "/tmp/repoinfo-servername" exists prepatch role will be excuted. 
Please read shell script pre-check.sh to understand how it works.

### patch
Enable root login just in case ldap access does not work post reboot
check if server uptime is greater than 180 days, if yes it does a reboot before patching
Sends mail to user before server update
Copy list of packages updated during patching in log file and copy the contents back to control node for any bau troubleshooting
Reboot server post patching
Wait for server to boot up
Notify user if server reboot or patching fails
All the above will be executed only if server is registered and packages are found to update

### postpatch
Check if connecivity via ssh is established if not send mail to syste admin
Disable ssh root login as soon as the server is up
Add list of sevices that you wish to start post reboot and script to start application post reboot
Run post check script to gather system state and config
All the above will be executed only if server is registered and packages are found to update

### Deviation
An important stage in the play, pre and post info collected is comapared and if any deviation found mail is sent back to the user from control node.
As of now number of mount points and number of routes are checked post reboot you can add more checks in prepatch and postpatch script.
Make sure you capture definite data that you dont expect to change post reboot, diff command is run to comapre. Hence you can test before including in the script.

## Authors

* **Ravikrithik** - *Initial work* - [link](https://github.com/ursravik/control-master)
