install_mysql_master(){
	echo "downloading mysql-5.6.19..."
	wget -P ${tools_home} ${http_url}/{cmake-2.8.8.tar.gz,mysql-5.6.19.tar.gz}
	
	echo -e "\033[31mInstalling cmake...\033[0m"
	yum install -y lsof gcc gcc-c++ >/dev/null 2>&1
	cd $tools_home
	if [ -f cmake-2.8.8.tar.gz ];then
	    tar xf $tools_home/cmake-2.8.8.tar.gz 
	    cd cmake-2.8.8
	    ./configure >/dev/null 2>&1
            gmake >/dev/null 2>&1 && gmake install >/dev/null 2>&1
 	    [ $? -eq 0 ] && action "cmake install successful" /bin/true
 	    cd $tools_home
    else
	    action "cmake not found" /bin/false
		exit 7
    fi
        echo -e "\033[31mInstalling support modules...\033[0m"
		yum install ncurses-devel -y >/dev/null 2>&1
		[ $? -eq 0 ] && action "Install support modules successful" /bin/true || action "Install support modules failed" /bin/false
		echo -e "\033[31mInstalling MySQL...\033[0m"
		groupadd mysql 2>/dev/null
		useradd mysql -s /sbin/nologin -M -g mysql 2>/dev/null
		
		if [ -f $tools_home/mysql-5.6.19.tar.gz ];then
			tar xf $tools_home/mysql-5.6.19.tar.gz 
			cd mysql-5.6.19
			/usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=${serv_dir}/mysql \
			-DMYSQL_DATADIR=${serv_dir}/mysql/data \
			-DSYSCONFDIR=/etc \
			-DMYSQL_USER=mysql \
			-DDEFAULT_CHARSET=utf8\
			-DDEFAULT_COLLATION=utf8_general_ci \
			-DEXTRA_CHARSETS=all \
			-DENABLED_LOCAL_INFILE=1 \
			-DWITH_READLINE=1 >/dev/null 2>&1
			make >/dev/null 2>&1 && make install >/dev/null 2>&1
			[ $? -eq 0 ] && action "MySQL Master install successful!" /bin/true || action "MySQL Master install failed!" /bin/false,exit7
		else
			action "mysql not found" /bin/false
		fi

#设置mysql数据存放的目录
mkdir -p ${serv_dir}/mysql/data
chown -R mysql.mysql ${serv_dir}/mysql
chmod -R 1777 /tmp
${serv_dir}/mysql/scripts/mysql_install_db --user=mysql --basedir=${serv_dir}/mysql --datadir=${serv_dir}/mysql/data >/dev/null 2>&1
/bin/cp $tools_home/mysql-5.6.19/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld

#设置mysql的配置文件
rm -rf /etc/my.cnf
touch /etc/my.cnf
cat >>/etc/my.cnf <<EOF
[client]
port = 3306
socket = ${serv_dir}/mysql/data/mysql.sock


[mysqld]
port = ${mysql_port}
socket = ${serv_dir}/mysql/data/mysql.sock
datadir = ${serv_dir}/mysql/data
log-error = ${serv_dir}/mysql/data/err.log
slow-query-log-file = ${serv_dir}/mysql/data/mysql-slow.log
innodb_data_home_dir = ${serv_dir}/mysql/data/
innodb_log_group_home_dir = ${serv_dir}/mysql/data/
character-set-server=utf8mb4
server-id = 1

binlog-format = ROW
#expire_logs_days = 3
expire_logs_days = 7
log-bin = ${serv_dir}/mysql/data/mysql-bin

sql-mode="NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
skip-external-locking
skip-name-resolve
sync_binlog = 1
event_scheduler = ON
max_allowed_packet = 128M
table_open_cache = 2048
wait_timeout = 28800
interactive_timeout = 28800
net_buffer_length = 1M
read_buffer_size = 8M
read_rnd_buffer_size = 8M
max_connections = 2000
max_connect_errors = 1000000
max_heap_table_size = 128M
join_buffer_size = 2M
thread_cache_size = 1024
symbolic-links = 0
query_cache_type = 0
myisam_sort_buffer_size = 8M
innodb_log_files_in_group = 3
thread_concurrency = 12
innodb_file_io_threads = 6
innodb_write_io_threads = 6
innodb_read_io_threads = 6
innodb_buffer_pool_size = 8G
innodb_log_file_size = 256M
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 0
innodb_support_xa = 1
innodb_flush_method = O_DIRECT
innodb_additional_mem_pool_size = 16M
innodb_sort_buffer_size = 16M
innodb_open_files = 3000
key_buffer_size = 2G
sort_buffer_size = 8M
slow-query-log = 0
slave_skip_errors = all

[mysqldump]
quick
max_allowed_packet = 128M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 8M
write_buffer = 8M

[mysqlhotcopy]
interactive-timeout
default-character-set = utf8mb4
EOF
}
