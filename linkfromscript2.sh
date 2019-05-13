#!/bin/sh
echo -n "Type your new domain name: "; read newdomainname
sed "s/ServerAlias.*/& $newdomainname/" -i /etc/apache2/sites-enabled/*.conf
certbot --apache --register-unsafely-without-email;
echo -e $"Complete!\nYou just add new alias  $newdomainname to Virtual Host config"
exit 0;
