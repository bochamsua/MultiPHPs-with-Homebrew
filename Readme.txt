Install Apache-PHP-MariaDB using Homebrew

Original tutorial here: https://getgrav.org/blog/macos-sierra-apache-multiple-php-versions


1. Edit "httpd-vhosts.conf" and change to your local project's path.

2. Run install.sh script
chmod +x install.sh
./install.sh



3. For xDebug, we disable auto start to make php scripts load faster, but we will need to create Browser bookmark in order to start/stop debugging:

Start Debug:
javascript:(/** @version 0.5.2 */function() {document.cookie='XDEBUG_SESSION='+'PHPSTORM'+';path=/;';})()

Stop Debug:
javascript:(/** @version 0.5.2 */function() {document.cookie='XDEBUG_SESSION='+''+';expires=Mon, 05 Jul 2000 00:00:00 GMT;path=/;';})()

4. SSL

subl /usr/local/etc/httpd/httpd.conf

->Uncomment: 
LoadModule socache_shmcb_module lib/httpd/modules/mod_socache_shmcb.so
...
LoadModule ssl_module lib/httpd/modules/mod_ssl.so
...
Include /usr/local/etc/httpd/extra/httpd-ssl.conf

--Config SSL
subl /usr/local/etc/httpd/extra/httpd-ssl.conf

->Change: 8443 --> 443

then find:

<VirtualHost _default_:8443>

#   General setup for the virtual host
DocumentRoot "/usr/local/var/www"
ServerName www.example.com:8443

and replace the 8443 references with 443 and note the commenting:

<VirtualHost _default_:443>

#   General setup for the virtual host
#DocumentRoot "/usr/local/var/www"
#ServerName www.example.com:443

After saving this file, you should then open up your /usr/local/etc/httpd/extra/httpd-vhosts.conf to add appropriate SSL based virtual hosts.
subl -e /usr/local/etc/httpd/extra/httpd-vhosts.conf


<VirtualHost *:443>
    DocumentRoot "/Volumes/Data/PHPProjects"
    ServerName localhost
    SSLEngine on
    SSLCertificateFile "/usr/local/etc/httpd/server.crt"
    SSLCertificateKeyFile "/usr/local/etc/httpd/server.key"
</VirtualHost>


--Generating SSL
cd /usr/local/etc/httpd && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt


Then all you need to do now is double check your Apache configuration syntax:

$ sudo apachectl configtest

If all goes well, restart Apache:

$ sudo apachectl -k restart





