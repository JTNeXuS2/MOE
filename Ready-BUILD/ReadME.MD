
# Pre-configured BUILD CLASTER
Download
[pixeldrain](https://pixeldrain.com/u/XMVnrDvw) | [StaticMirror](https://junger.zzux.com/webhook/MOE_DLC/moe_cluster-ready.zip)
## ======= START =======
need open ports UDP+TCP: 3307 for SQL server,6379 for Redis server, servers need range 6000-8999

1. Unpack in to C:\moe_cluster
2. To create all the necessary directories, use the script "z start once - mklink- sync dir.cmd" ![Screen](https://junger.zzux.com/webhook/MOE_DLC/Screenshot_1.png)  
    2b. To Download SteamCMD and server files start "z manual Update-Download-Validate.cmd" ![Screen](https://junger.zzux.com/webhook/MOE_DLC/Screenshot_2.png)
3. replace all texts via notepad++ in C:\moe_cluster use filters ```*.txt *.json *.bat *.cmd *.conf *.ini``` ![Screen](https://junger.zzux.com/webhook/MOE_DLC/Screenshot_3.png)

	replace it (Find -> Replace)  
	    ```junger.zzux.com``` -> ```your DNSnames or external IP```  
	    ```192.168.0.101``` -> ```your Local IP```  
	    ```RCON_PASSWORD``` -> ```your RCON_PASSWORD```  
	addition: if issues rcon  
	            0.0.0.0 -> To ExternalIP or Local IP (cant DNSnames)

4. check the settings in C:\moe_cluster\scripts\demon.cfg
5. run MatrixServerTool and check the settings
6. run "!START-minimal_TEST_CLUSTER.cmd" for start core and one server or "!START_CLUSTER.cmd" for full start claster
	check the operation of the cluster and servers ![Screen](https://junger.zzux.com/webhook/MOE_DLC/Screenshot_4.png)  
	if everything works fine run "Auto_Update_Backup_Claster.bat" to automatically run the cluster servsers  
	![Screen](https://junger.zzux.com/webhook/MOE_DLC/Screenshot_5a.png)  
	![Screen](https://junger.zzux.com/webhook/MOE_DLC/Screenshot_6.png)  
dayly restart at 12:00 setup in C:\moe_cluster\scripts\ShedulerRestart.cmd

when adding/removing servers, you will need to add or remove the corresponding block in CMDs(moe_cluster\scripts)
![Screen](https://junger.zzux.com/webhook/MOE_DLC/Screenshot_7.png)  
## ======= Additional INFOs =======
don't forget to change the database access via C:\moe_cluster\mysql\HeidiSQL (SQL Server need started C:\moe_cluster\mysql\!Start.cmd)
![Screen](https://junger.zzux.com/webhook/MOE_DLC/Screenshot_8a.png)  
to connect to the database with ROOTaccess use ip "127.0.0.1" port "3307" user "SuperAdmin" pass "Legend!@#mko"
	just specify from which addresses what rights can be obtained or delete unnecessary ones, don't worry, you can always restore the database from a backup
#### additional sql scripts

##### create a database
	-- Don't touch this
	CREATE DATABASE moe_pub;
	CREATE DATABASE moe_role;
	CREATE DATABASE moe_opt;

##### assign give access rights to user moe_cluster with pass DB_PASSWORD from any hosts
	-- CHANGE THE DB_PASSWORD
	CREATE USER 'moe_cluster'@'_%' IDENTIFIED BY 'DB_PASSWORD';
	GRANT ALL PRIVILEGES ON moe_opt.* TO 'moe_cluster'@'_%';
	GRANT ALL PRIVILEGES ON moe_role.* TO 'moe_cluster'@'_%';
	ALL PRIVILEGES ON moe_pub.* TO 'moe_cluster'@'_%';
  
  
  
  
  
#### find me on discord [![Discord](https://discordapp.com/api/guilds/626106205122592769/widget.png?style=shield)](https://discord.gg/qYmBmDR)
#### Donate for me
#### [yoomoney](https://yoomoney.ru/to/4100116619431314)
https://fkwallet.io  ID: F7202415841873335
#### [boosty](https://boosty.to/_illidan_)

