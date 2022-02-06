apt update

apt install git gcc redis s python3-setuptools graphviz python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev

sudo -u postgres psql
	CREATE DATABASE netbox;
	CREATE USER netbox WITH PASSWORD 'netbox';
	GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;
	\q

sudo git clone -b master https://github.com/digitalocean/netbox.git
mv netbox/ /opt/
cd netbox/netbox/netbox/
	cp configuration.example.py configuration.py
	vim configuration.py
	groupadd --system netbox
	adduser --system netbox
	chown --recursive netbox /opt/netbox/netbox/media/

cd /opt/netbox/
	python3 -m venv /opt/netbox/venv

cd /opt/netbox/netbox
	./generate_secret_key.py

