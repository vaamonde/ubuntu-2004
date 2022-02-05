apt update
apt upgrade

apt install libdbd-pg-perl libsnmp-perl libssl-dev libio-socket-ssl-perl curl build-essential

# opção do comando useradd: -m (create-home) -p (password), -s (bash)
useradd -m -p x -s /bin/bash netdisco

su - postgres
	createuser -DRSP netdisco
	createdb -O netdisco netdisco
exit

su - netdisco
	mkdir -v ~/bin
	mkdir -v ~/environments
	curl -L https://cpanmin.us/ | perl - --notest --local-lib ~/perl5 App::Netdisco
	ln -s ~/perl5/bin/{localenv,netdisco-*} ~/bin/
	cp ~/perl5/lib/perl5/auto/share/dist/App-Netdisco/environments/deployment.yml ~/environments
	chmod 600 ~/environments/deployment.yml
	~/bin/netdisco-deploy
	~/bin/netdisco-web start
	~/bin/netdisco-backend start
exit

/etc/systemd/system/netdisco-daemon.service
[Unit]
Description=Netdisco Daemon Service
AssertFileIsExecutable=/home/netdisco/bin/netdisco-daemon
After=syslog.target network-online.target
 
[Service]
Type=forking
User=netdisco
Group=netdisco
ExecStart=/home/netdisco/bin/netdisco-daemon start
ExecStop=/home/netdisco/bin/netdisco-daemon stop
Restart=on-failure
RestartSec=60
 
[Install]
WantedBy=multi-user.target

/etc/systemd/system/netdisco-web.service
[Unit]
Description=Netdisco Web Service
AssertFileIsExecutable=/home/netdisco/bin/netdisco-web
After=syslog.target network-online.target netdisco-daemon.service
 
[Service]
Type=forking
User=netdisco
Group=netdisco
ExecStart=/home/netdisco/bin/netdisco-web start
ExecStop=/home/netdisco/bin/netdisco-web stop
Restart=on-failure
RestartSec=60
 
[Install]
WantedBy=multi-user.target

systemctl enable netdisco-daemon.service
systemctl enable netdisco-web.service
systemctl start netdisco-daemon.service
systemctl start netdisco-web.service


===============================================================================================

/bin/su -c "/path/to/backup_db.sh /tmp/test" - postgres
/bin/su -s /bin/bash -c '/path/to/your/script' testuser
apt install libdbd-pg-perl libsnmp-perl libssl-dev libio-socket-ssl-perl curl postgresql build-essential
useradd -m -p x -s /bin/bash netdisco
psql postgres -c 'createuser -DRSP netdisco
CREATE DATABASE yourdbname;
CREATE USER youruser WITH ENCRYPTED PASSWORD 'yourpass';
GRANT ALL PRIVILEGES ON DATABASE yourdbname TO youruser;
su -c 'curl -L https://cpanmin.us/ | perl - --notest --local-lib ~/perl5 App::Netdisco' - netdisco
su -c 'mkdir /home/netdisco/bin
su -c 'ln -s /home/netdisco/perl5/bin/{localenv,netdisco-*} /home/netdisco/bin/' - netdisco
su -c '/home/netdisco/bin/netdisco-backend status' - netdisco
su -c 'mkdir /home/netdisco/environments' - netdisco
su -c 'cp /home/netdisco/perl5/lib/perl5/auto/share/dist/App-Netdisco/environments/deployment.yml /home/netdisco/environments' - netdisco
su -c 'chmod 600 /home/netdisco/environments/deployment.yml' - netdisco
su -c '/home/netdisco/bin/netdisco-deploy' - netdisco
su -c '/home/netdisco/bin/netdisco-web start' - netdisco
su -c '/home/netdisco/bin/netdisco-backend start' - netdisco