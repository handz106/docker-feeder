#!/bin/bash
set -e

#cek apakah data postgresql atau web app telah tersedia (pernah diinstall)
if [ ! -d "/var/lib/postgresql" ] || [ ! -d "/var/www/html" ]
  then
    echo "Web and database not found."
    echo "Copying database data..."
    unzip -o -qq /feeder/postgresql.zip -d /var/lib
    echo "Change directory db owner..."
    chown postgres:postgres -R /var/lib/postgresql

    echo "Copying web file..."
    unzip -o -qq /feeder/html.zip -d /var/www/html
    echo "Change directory db owner..."
    chown www-data:www-data -R /var/www/html
  else
    if [ "$(ls -A /var/lib/postgresql)" ] && [ "$(ls -A /var/www/html)" ]
        then
            echo "Database and web app already exist..."
        else
            echo "Copying database data..."
            unzip -o -qq /feeder/postgresql.zip -d /var/lib
            echo "Change directory db owner..."
            chown postgres:postgres -R /var/lib/postgresql

            echo "Copying web file..."
            unzip -o -qq /feeder/html.zip -d /var/www/html
            echo "Change directory db owner..."
            chown www-data:www-data -R /var/www/html
    fi
fi

#start services
/etc/init.d/postgresql start

##Check installed version and compare then update
echo "Checking installed version"
installed_version=$(sed -nr "/^\[config\]/ { :l /^last[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /var/www/html/install.ini)
version_number=${installed_version//./}

#Update to 3.3
cd /feeder
if [ "$version_number" -lt 33 ]
  then
    echo "Updating to v3.3"
    /feeder/UPDATE_PATCH.3.3
    echo "Done update v3.3"
fi

##Update to 3.4
if [ "$version_number" -lt 34 ]
  then
    echo "Updating to v3.4"
    /feeder/UPDATE_PATCH.3.4
    echo "Done update v3.4"
fi

#Update to 4.0
if [ "$version_number" -lt 40 ]
  then
    echo "Updating to v4.0"
    /feeder/UPDATE_PATCH.4.0
    echo "Done update v4.0"
fi

#Update to 4.1
if [ "$version_number" -lt 41 ]
  then
    echo "Updating to v4.1"
    /feeder/UPDATE_PATCH.4.1
    echo "Done update v4.1"
fi

#change directory owner
echo "Change directory owner..."
#chown postgres:postgres -R /var/lib/postgresql
#chown www-data:www-data -R /var/www/html
chown www-data:www-data -R /home/prefill

echo "Ready to accept to connection..."
supervisord