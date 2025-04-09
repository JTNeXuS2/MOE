
## Pre-configured BUILD CLASTER
### ======= START =======
1. Unpack in to C:\moe_cluster
2. To create all the necessary directories, use the script "z start once - mklink- sync dir.cmd"
3. replace all texts use filters via notepad++ in C:\moe_cluster
	*.txt *.json *.bat *.cmd *.conf *.ini

	replace it (Find -> Replace)
	junger.zzux.com -> your DNSnames
	192.168.0.101 -> your Local ip
	RCON_PASSWORD -> your RCON_PASSWORD

		addition if issues rcon
		0.0.0.0 -> To ExternalIP or Local IP (cant DNSnames)
4. check the settings in C:\moe_cluster\scripts\demon.cfg
5. run MatrixServerTool and check the settings
6. run "!START-minimal_TEST_CLUSTER.cmd" for start core and one server or "!START_CLUSTER.cmd" for full start claster
	check the operation of the cluster and servers
	if everything works fine run "Auto_Update_Backup_Claster.bat" to automatically run the cluster
	
dayly restart at 12:00 C:\moe_cluster\scripts\ShedulerRestart.cmd

when adding/removing servers, you will need to add or remove the corresponding block in CMDs(moe_cluster\scripts)

### ======= Additional INFOs =======
don't forget to change the database access via C:\moe_cluster\mysql\HeidiSQL (SQL Server need started C:\moe_cluster\mysql\!Start.cmd)
to connect to the database with ROOTaccess use ip "127.0.0.1" port "3307" user "SuperAdmin" pass "Legend!@#mko"

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
