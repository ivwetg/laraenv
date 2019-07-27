#!/bin/bash
#输入：
#1、用户 (用来判断代码位置)
#2、项目编号
#3、域名

USER=$1
PROJECT=$2
DOMIAN_NAME=$3
USER_ROOT="/var/www/${USER}"
if [ ! -d $USER_ROOT ]; then
    echo "用户不存在，请先创建用户"  #不存在报错
    exit 1
fi
if [ "${PROJECT}" = "" ]; then
    echo "项目名未输入"  #不存在报错
    exit 1
fi
if [ "${DOMIAN_NAME}" = "" ]; then
    echo "域名未输入"  #不存在报错
    exit 1
fi

cp -p /var/www/laradock/nginx/sites/laravel.conf.example /var/www/laradock/nginx/sites/${PROJECT}.conf #复制站点示例文件

sed -i "s#laravel.test#${DOMIAN_NAME}#g" /var/www/laradock/nginx/sites/${PROJECT}.conf
sed -i "s#/var/www/laravel/public#/var/www/${USER}/code/${PROJECT}/public#g" /var/www/laradock/nginx/sites/${PROJECT}.conf

#以下是源文件内容
#server {
#listen 80;
#listen [::]:80;

# For https
# listen 443 ssl;
# listen [::]:443 ssl ipv6only=on;
# ssl_certificate /etc/nginx/ssl/default.crt;
# ssl_certificate_key /etc/nginx/ssl/default.key;

#server_name laravel.test;
#root /var/www/laravel/public;
#index index.php index.html index.htm;

#location / {
     #try_files $uri $uri/ /index.php$is_args$args;

#}

#location ~ \.php$ {
    #try_files $uri /index.php =404;
    #fastcgi_pass php-upstream;
    #fastcgi_index index.php;
    #fastcgi_buffers 16 16k;
    #fastcgi_buffer_size 32k;
    #fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    #fixes timeouts
    #fastcgi_read_timeout 600;
    #include fastcgi_params;
#}

#location ~ /\.ht {
    #deny all;
#}

#location /.well-known/acme-challenge/ {
    #root /var/www/letsencrypt/;
    #log_not_found off;
#}

#error_log /var/log/nginx/laravel_error.log;
#access_log /var/log/nginx/laravel_access.log;

#}
