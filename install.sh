#!/bin/bash
php_array=("5.6" "7.0" "7.1" "7.2")
#check if xcode command line tools are installed
if xcode-select --install 2>&1 | grep installed; then
    echo "---------------------------------------------------------------------"
	echo "1. Install Brew"

	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew doctor

	echo "---------------------------------------------------------------------"
	echo "2. Unload pre-installed apache come with macOS"
	sudo apachectl stop 2>/dev/null

  echo "---------------------------------------------------------------------"
	echo "3. Install Dnsmasq to auto resolve to localhost"
	brew install dnsmasq
	echo 'address=/.test/127.0.0.1' > /usr/local/etc/dnsmasq.conf
	sudo brew services start dnsmasq
  #sudo ln -sfv /usr/local/opt/dnsmasq/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons/

	sudo mkdir -v /etc/resolver
	sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
	sudo brew services restart dnsmasq
  #sudo launchctl reload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist


  echo "---------------------------------------------------------------------"
	echo "4. Install MariaDB"
	brew install mariadb
	brew services start mariadb


	/usr/local/bin/mysql_secure_installation


	echo "---------------------------------------------------------------------"
	echo "5. Install apache and process config files"
	brew install httpd

	cp /usr/local/etc/httpd/httpd.conf /usr/local/etc/httpd/httpd.conf.bak
	sed -i '' "s|Listen 8080|Listen 80|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|#LoadModule rewrite_module lib/httpd/modules/mod_rewrite.so|LoadModule rewrite_module lib/httpd/modules/mod_rewrite.so|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|#LoadModule vhost_alias_module lib/httpd/modules/mod_vhost_alias.so|LoadModule vhost_alias_module lib/httpd/modules/mod_vhost_alias.so|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|#LoadModule proxy_module lib/httpd/modules/mod_proxy.so|LoadModule proxy_module lib/httpd/modules/mod_proxy.so|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|#LoadModule proxy_fcgi_module lib/httpd/modules/mod_proxy_fcgi.so|LoadModule proxy_fcgi_module lib/httpd/modules/mod_proxy_fcgi.so|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|#Include /usr/local/etc/httpd/extra/httpd-vhosts.conf|Include /usr/local/etc/httpd/extra/httpd-vhosts.conf|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|#Include /usr/local/etc/httpd/extra/httpd-vhosts.conf|Include /usr/local/etc/httpd/extra/httpd-vhosts.conf|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|User _www|User $USER|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|Group _www|Group staff|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|#ServerName www.example.com:8080|ServerName localhost|g" /usr/local/etc/httpd/httpd.conf
	sed -i '' "s|index.html|index.php index.html|g" /usr/local/etc/httpd/httpd.conf

	mv /usr/local/etc/httpd/extra/httpd-vhosts.conf /usr/local/etc/httpd/extra/httpd-vhosts.conf.bak
	cp -rf httpd-vhosts.conf /usr/local/etc/httpd/extra/httpd-vhosts.conf

	echo "---------------------------------------------------------------------"
	echo "6. Copy some scripts and include PATH"
	chmod +x fpm i o sphp v x
	cp fpm i o sphp v x /usr/local/bin/
	export PATH=/usr/local/sbin:$PATH

	echo "---------------------------------------------------------------------"
	echo "7. Install PHPs, xDebug, Tidy and process config files"

	mkdir -p ~/Library/LaunchAgents
  brew tap kabel/php-ext
  #brew install libyaml
	for i in ${php_array[@]}
		do
      NODOT=${i/./}
			brew install php@"$i"
      cp /usr/local/etc/php/"$i"/php.ini /usr/local/etc/php/"$i"/php.ini.bak
      cp -rf conf/* /usr/local/etc/php/"$i"/conf.d/
sphp "$i"
			if [ "$i" == "7.2" ]; then
				ln -sfv /usr/local/opt/php@"$i"/homebrew.mxcl.php.plist ~/Library/LaunchAgents/homebrew.mxcl.php@"$i".plist
        brew install kabel/php-ext/php-tidy
        pecl install xdebug
        sed -i '' "s/9000/90$NODOT/g" /usr/local/etc/php/"$i"/php-fpm.d/www.conf
			else
				ln -sfv /usr/local/opt/php@"$i"/homebrew.mxcl.php@"$i".plist ~/Library/LaunchAgents/
        brew install kabel/php-ext/php@"$i"-tidy
        if [[ "$i" == "5.6" ]]; then
          pecl install xdebug-2.5.5
          sed -i '' "s/9000/90$NODOT/g" /usr/local/etc/php/"$i"/php-fpm.conf
        else
          pecl install xdebug
          sed -i '' "s/9000/90$NODOT/g" /usr/local/etc/php/"$i"/php-fpm.d/www.conf
        fi
			fi

      sed -i '' 's/zend_extension=/;zend_extension=/g' /usr/local/etc/php/"$i"/php.ini
  		sed -i '' 's/extension=/;extension=/g' /usr/local/etc/php/"$i"/php.ini
  		sed -i '' 's/max_execution_time = 30/max_execution_time = 30000/g' /usr/local/etc/php/"$i"/php.ini
  		sed -i '' 's/max_execution_time = 30/max_execution_time = 30000/g' /usr/local/etc/php/"$i"/php.ini
  		sed -i '' 's/max_input_time = 60/max_input_time = 60000/g' /usr/local/etc/php/"$i"/php.ini
  		sed -i '' 's/memory_limit = 128M/memory_limit = 512M/g' /usr/local/etc/php/"$i"/php.ini
  		sed -i '' 's/post_max_size = 8M/post_max_size = 128M/g' /usr/local/etc/php/"$i"/php.ini
  		sed -i '' 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /usr/local/etc/php/"$i"/php.ini

			launchctl load ~/Library/LaunchAgents/homebrew.mxcl.php@"$i".plist
	done

	echo "---------------------------------------------------------------------"
	echo "8. Add some aliases to .bash_profile"
	cat >> ~/.bash_profile << EOF
		alias a.s='sudo apachectl start'
		alias a.o='sudo apachectl stop'
		alias a.r='sudo apachectl -k restart'

		alias m.s='brew services start mariadb'
		alias m.o='brew services stop mariadb'
		alias m.r='brew services restart mariadb'

		alias a.conf='atom /usr/local/etc/httpd/httpd.conf'
		alias v.conf='atom /usr/local/etc/httpd/extra/httpd-vhosts.conf'
EOF
	source ~/.bash_profile

	echo "---------------------------------------------------------------------"
	echo "Retart all services"
	a.r
	fpm
	m.r

	echo "Finished."
else
   echo "This script will now exit and Xcode command line tools is now being installed. Please re-run this when xcode installed."
   xcode-select --install

fi
