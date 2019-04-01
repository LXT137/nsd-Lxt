install_php(){
	echo "downloading php depend on package..."
	wget -P ${tools_home} ${http_url}/{libiconv-1.14.tar.gz,libmcrypt-2.5.8.tar.gz,mhash-0.9.9.9.tar.gz,mcrypt-2.6.8.tar.gz,memcache-2.2.5.tgz,php-5.6.25.tar.gz}
	
	echo -e "\033[31mInstaling support php modules...\033[0m"
	yum install zlib libxml libjpeg freetype libpng gd  curl libiconv  zlib-devel libxml2-devel libjpeg-devel freetype-devel libpng-devel gd-devel curl-devel -y >/dev/null 2>&1
	[ $? -eq 0 ] && action "support php modules install successful" /bin/true || action "support php modules install failed" /bin/false 
	echo -e "\033[31mInstalling libiconv module...\033[0m"
	cd $tools_home
	if [ -f libiconv-1.14.tar.gz ];then 
	    tar zxf libiconv-1.14.tar.gz
	    cd libiconv-1.14
	    ./configure --prefix=/usr/local/libiconv >/dev/null 2>&1
	    make >/dev/null 2>&1 && make install >/dev/null 2>&1
	    [ $? -eq 0 ] && action "libconv install successful" /bin/true || action "libconv install failed" /bin/false
	else 
	      action "libiconv not found" /bin/false 
    fi 
	
	echo -e "\033[31mInstalling libmcrypt module...\033[0m"
	cd $tools_home
	if [ -f libmcrypt-2.5.8.tar.gz ];then 
	    tar -xf libmcrypt-2.5.8.tar.gz
	    cd libmcrypt-2.5.8
	    ./configure >/dev/null 2>&1
	    make >/dev/null 2>&1 && make install >/dev/null 2>&1
	    sleep 2
	    /sbin/ldconfig
	    cd libltdl/
	    ./configure --enable-ltdl-install >/dev/null 2>&1
	    make >/dev/null 2>&1 && make install >/dev/null 2>&1
	    [ $? -eq 0 ] && action "libmcrypt install successful" /bin/true || action "libmcrypt install failed" /bin/false
	else 
	    action "libmcrypt not found" /bin/false
	fi
	
	echo -e "\033[31mInstalling mhash module...\033[0m"
	cd $tools_home
	if [ -f mhash-0.9.9.9.tar.gz ];then 
	    tar xf mhash-0.9.9.9.tar.gz
	    cd mhash-0.9.9.9
	    ./configure >/dev/null 2>&1
            make >/dev/null 2>&1 && make install >/dev/null 2>&1
	    [ $? -eq 0 ] && action "mhash install successful" /bin/true || action "mhash install failed" /bin/false
	    sleep 2
	    cd ../
	    rm -f /usr/lib64/libmcrypt.*
        rm -f /usr/lib64/libmhash*
        ln -s /usr/local/lib64/libmcrypt.la /usr/lib64/libmcrypt.la
        ln -s /usr/local/lib64/libmcrypt.so /usr/lib64/libmcrypt.so
        ln -s /usr/local/lib64/libmcrypt.so.4 /usr/lib64/libmcrypt.so.4
        ln -s /usr/local/lib64/libmcrypt.so.4.4.8 /usr/lib64/libmcrypt.so.4.4.8
        ln -s /usr/local/lib64/libmhash.a /usr/lib64/libmhash.a
        ln -s /usr/local/lib64/libmhash.la /usr/lib64/libmhash.la
        ln -s /usr/local/lib64/libmhash.so /usr/lib64/libmhash.so
        ln -s /usr/local/lib64/libmhash.so.2 /usr/lib64/libmhash.so.2
        ln -s /usr/local/lib64/libmhash.so.2.0.1 /usr/lib64/libmhash.so.2.0.1
        ln -s /usr/local/lib64/libmcrypt-config /usr/bin/libmcrypt-config 2>/dev/null
	else
	    action "mhash not found" /bin/false
	fi
	
	echo -e "\033[31mInstalling mcrypt module...\033[0m"
	cd $tools_home
	if [ -f mcrypt-2.6.8.tar.gz ];then 
	    tar xf mcrypt-2.6.8.tar.gz
	    cd mcrypt-2.6.8
	    /sbin/ldconfig 
	    ./configure LD_LIBRARY_PATH=/usr/local/lib --with-libmcrypt-prefix=/usr/local>/dev/null 2>&1
	    make >/dev/null 2>&1 && make install >/dev/null 2>&1
	    [ $? -eq 0 ] && action "mcrypt install successful" /bin/true || action "mcrypt install failed" /bin/false 
	    cd ../
            sleep 2 
	else
	    action "mcrypt not found" /bin/false 
	fi
	
	echo -e "\033[31mInstalling PHP...\033[0m"
	cd $tools_home
	if [ -f php-5.6.25.tar.gz ];then 
	    tar xf php-5.6.25.tar.gz
	    cd php-5.6.25
		echo '/usr/local/lib' >>/etc/ld.so.conf
		ldconfig 
	    yum install libxslt* -y >/dev/null 2>/dev/null 
		./configure --prefix=${serv_dir}/php --with-config-file-path=${serv_dir}/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo >/dev/null 2>&1
        ln -s ${serv_dir}/mysql/lib/libmysqlclient.so.18 /usr/lib64 >/dev/null 2>&1
	    make ZEND_EXTRA_LIBS='/usr/local/libiconv/lib/libiconv.so.2' >/dev/null 2>&1 /usr/lib64/ && make install >/dev/null 2>&1
	    [ $? -eq 0 ] && action "PHP install successful!" /bin/true || { action "PHP install failed!" /bin/false; exit 7; }
	    /bin/cp php.ini-production ${serv_dir}/php/etc/php.ini
	else 
	   action "PHP moudle not found" /bin/false
	fi

#install fileinfo
	echo -e "\033[31mInstalling Memcache...\033[0m"
	cd $tools_home/php-5.6.25/ext/fileinfo
	if [ ! -f config.m4 ];then
		mv config0.m4 config.m4
	fi
	${serv_dir}/php/bin/phpize
	./configure --with-php-config=${serv_dir}/php/bin/php-config >/dev/null 2>&1
	make >/dev/null 2>&1 && make install >/dev/null 2>&1
	cd ${serv_dir}/php/lib/php/extensions/no-debug-non-zts-20131226/ 	
	[ -e fileinfo.so ] && action "Install fileinfo successful" /bin/true || action "Install fileinfo failed" /bin/false
	
#install memcache
	echo -e "\033[31mInstalling Memcache...\033[0m"
	cd $tools_home 
	if [ -f memcache-2.2.5.tgz ];then
	      tar xf memcache-2.2.5.tgz
	      cd memcache-2.2.5
	      ${serv_dir}/php/bin/phpize
	      ./configure --with-php-config=${serv_dir}/php/bin/php-config >/dev/null 2>&1
	      make >/dev/null 2>&1 && make install >/dev/null 2>&1
	      cd ${serv_dir}/php/lib/php/extensions/no-debug-non-zts-20131226/ 
	      [ -e memcache.so ] && action "Install Memcache successful" /bin/true || action "Install Memcache failed" /bin/false
	fi	
	
#设置PHP的配置文件
echo "Modify php.ini......"
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE/g' ${serv_dir}/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' ${serv_dir}/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' ${serv_dir}/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' ${serv_dir}/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${serv_dir}/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${serv_dir}/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' ${serv_dir}/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${serv_dir}/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' ${serv_dir}/php/etc/php.ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' ${serv_dir}/php/etc/php.ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' ${serv_dir}/php/etc/php.ini
sed -i 's/error_reporting/;error_reporting/g' ${serv_dir}/php/etc/php.ini
echo 'error_reporting = E_ALL & ~E_NOTICE' >>${serv_dir}/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${serv_dir}/php/etc/php.ini
sed -i 's/display_errors = Off/display_errors = On/g' ${serv_dir}/php/etc/php.ini

echo -e "\033[31mConfiguring PHP Parameter...\033[0m"
sed -i 's#; extension_dir = "./"# extension_dir = '"${serv_dir}"'/php/lib/php/extensions/no-debug-non-zts-20131226/#g' ${serv_dir}/php/etc/php.ini
echo "extension = memcache.so" >>${serv_dir}/php/etc/php.ini
echo "extension = fileinfo.so" >>${serv_dir}/php/etc/php.ini

#设置php-fpm的配置文件
cat >${serv_dir}/php/etc/php-fpm.conf<<EOF
[global]
pid = ${serv_dir}/php/var/run/php-fpm.pid
error_log = ${serv_dir}/php/var/log/php-fpm.log
log_level = notice

[nginx]
;listen = /tmp/php-cgi.sock
listen = 127.0.0.1:9000
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = static
pm.max_children = 150
pm.start_servers = 2
pm.min_spare_servers = 3
pm.max_spare_servers = 10
request_terminate_timeout = 120
request_slowlog_timeout = 10s
slowlog = ${serv_dir}/php/var/log/slow.log
EOF
}
