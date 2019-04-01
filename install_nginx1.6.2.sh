install_nginx(){
	echo "downloading nginx..."
	wget -P ${tools_home} ${http_url}/nginx-1.6.2.tar.gz
	
    echo -e "\033[31mInstalling Nginx support modules...\033[0m"
	yum install lsof gcc gcc-c++ pcre-devel openssl openssl-devel -y >/dev/null 2>&1
	[ $? -eq 0 ] && action "Install Nginx support modules successful" /bin/true || action "Install Nginx support modules failed" /bin/false
    if [ $? -eq 0 ];then
	    echo -e "\033[31mInstalling Nginx...\033[0m" 
	    cd $tools_home
        if [ -f $tools_home/nginx-1.6.2.tar.gz ];then
			cd $tools_home
			tar xf nginx-1.6.2.tar.gz 
            groupadd www 2>/dev/null
            useradd www -s /sbin/nologin -M -g www 2>/dev/null
            cd $tools_home/nginx-1.6.2
			./configure --user=www --group=www --prefix=${serv_dir}/nginx --with-http_stub_status_module --with-http_ssl_module >/dev/null 2>&1
			make > /dev/null 2>&1 && make install >/dev/null 2>&1
	        [ $? -eq 0 ] && action "Nginx install successful" /bin/true || action "Nginx install failed" /bin/false
        else
            action "Nginx-1.6.2.tar.gz not found" /bin/false
        fi
    fi

#设置nginx的配置文件
echo -e "\033[31mSetting Nginx Configure File...\033[0m"
cat >${serv_dir}/nginx/conf/nginx.conf<<EOF
user  www www;

worker_processes auto;

error_log  ${serv_dir}/nginx/logs/nginx_error.log  crit;

pid        ${serv_dir}/nginx/logs/nginx.pid;

#Specifies the value for maximum file descriptors that can be opened by this process.
worker_rlimit_nofile 51200;

events
        {
                use epoll;
                worker_connections 51200;
                multi_accept on;
        }

http
        {
                include       mime.types;
                default_type  usr/local/octet-stream;

                server_names_hash_bucket_size 128;
                client_header_buffer_size 32k;
                large_client_header_buffers 4 32k;
                client_max_body_size 50m;

                sendfile on;
                tcp_nopush     on;

                keepalive_timeout 60;

                tcp_nodelay on;

                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
                fastcgi_buffer_size 64k;
                fastcgi_buffers 4 64k;
                fastcgi_busy_buffers_size 128k;
                fastcgi_temp_file_write_size 256k;

				gzip on;
				gzip_min_length  1k;
				gzip_buffers     512 1024k;
				gzip_http_version 1.1;
				gzip_comp_level 4;
				gzip_types       text/plain application/json text/javascript application/javascript application/x-javascript text/css application/xml application/x-httpd-php application/octet-stream;
				gzip_vary on;
				gzip_proxied        expired no-cache no-store private auth;
				gzip_disable        "MSIE [1-6]\.";

                #limit_conn_zone $binary_remote_addr zone=perip:10m;
                ##If enable limit_conn_zone,add "limit_conn perip 10;" to server section.

                server_tokens off;
                #log format
                log_format  access  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
             '\$status \$body_bytes_sent "\$http_referer" '
             '"\$http_user_agent" \$http_x_forwarded_for';
include web/*.conf;
}
EOF

mkdir ${serv_dir}/nginx/conf/web 2>/dev/null
touch ${serv_dir}/nginx/conf/web/80.conf
cat >${serv_dir}/nginx/conf/web/80.conf<<EOF
server {
        listen 80;
        server_name _;
        root html;
        index index.php index.html index.htm;

        location ~ .*\.(php|php5)?$ 
           {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            include fastcgi.conf;
           }
#       access_log  ${serv_dir}/wwwlogs/access_80.log  access;
}
EOF
sleep 3
action "Nginx configure successful" /bin/true
}
