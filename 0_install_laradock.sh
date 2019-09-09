#!/bin/bash

#字体颜色
function font_color(){
    type=$1; #输入的参数
    black="\033[30m"
    red="\033[31m"
    green="\033[32m"
    yellow="\033[33m"
    blue="\033[34m"
    purple="\033[35m"
    sky_blue="\033[36m"
    white="\033[37m"
    end="\033[0m"
    if [ $type = 'red' ]
    then
            echo $red
    elif [ $type = 'end' ]
    then
            echo $end
    else
            echo $green
    fi
}

date +'开始运行时间为:%Y年%m月%d日 %H:%M:%S' #输出来看下

yum -y install wget
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup   #首先备份/etc/yum.repos.d/CentOS-Base.repo
cd /etc/yum.repos.d && wget http://mirrors.163.com/.help/CentOS7-Base-163.repo  #载163的yum源配置文件，放入/etc/yum.repos.d/(操作前做好相应备份)
yum -y install epel-release #扩展源
yum makecache #生成缓存
yum -y update  #先更新所有

date +'更新完时间为:%Y年%m月%d日 %H:%M:%S' #输出来看下

software_array=("vim" "lrzsz" "git")
#先安装这几样软件
for software in ${software_array[@]};
    do
        current_name=${software};
        exe_result=`which ${current_name} | grep -cE "."`;#执行看看什么结果
        #echo ${exe_result};
        #exist_vim=`rpm -qa | grep ${current_name} | wc -l`
        if [ ${exe_result} -lt 1 ]
                then {
                        echo -e "`font_color red`您未安装软件:${current_name}`font_color end`"
                        yum install -y ${current_name} #安装
                }
                else {
                        echo -e "`font_color green`您已经安装软件:${current_name}`font_color end`"
                }
        fi
    done;   
#安装指定版本的docker
yum remove -y docker  docker-common docker-selinux docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce-18.09.7-3.el7  #当前 2019/7/16 19:08 最新是这个版本了
systemctl start docker
systemctl enable docker
docker version
date +'安装完docker:%Y年%m月%d日 %H:%M:%S' #输出来看下
#安装指定版本的docker-composer
    cp ./software/docker-compose /usr/local/bin/docker-compose  #已下载好上传，现在复制过去就行了
    exe_docker_compose=`which docker-compose | grep -cE "."`;#执行看看什么结果
    if [ ${exe_docker_compose} -lt 1 ];then
    {
        curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        if [ $? -eq 0 ]; then
            echo -e "`font_color green`成功安装docker-compose并修改权限：$?`font_color end`"
        else
            echo -e "`font_color red`安装docker-compose修改权限失败`font_color end`"
        fi
    }
    else {
         echo -e "`font_color green`您已经安装软件:docker_compose`font_color end`"
         }
    fi
    chmod +x /usr/local/bin/docker-compose
date +'安装完docker_copose:%Y年%m月%d日 %H:%M:%S' #输出来看下

#开始安装laradock
web_workspace='/data/wwwroot';#安装在 /data/wwwroot里面吧
if [ ! -d ${web_workspace} ]; then
  mkdir -p ${web_workspace}
fi
chown 1000.1000 ${web_workspace} #设置主人为laradock
echo -e "`font_color green`成功创建${web_workspace}并修改权限：$?`font_color end`"
cd ${web_workspace} && git clone https://github.com/laradock/laradock.git
date +'下载完laradock:%Y年%m月%d日 %H:%M:%S' #输出来看下
cp ${web_workspace}/laradock/env-example ${web_workspace}/laradock/.env
chown 1000.1000 ${web_workspace}/laradock -R #设置主人为laradock
#WORKSPACE_INSTALL_WORKSPACE_SSH=false WORKSPACE_INSTALL_SSH2=false MYSQL_VERSION=latest MYSQL_ROOT_PASSWORD=root  #修改配置文件：mysql(要改成5.7) workspace(要开启ssh)
sed -i 's/\(WORKSPACE_INSTALL_WORKSPACE_SSH=\).*/\1true/g' ${web_workspace}/laradock/.env
sed -i 's/\(WORKSPACE_INSTALL_MYSQL_CLIENT=\).*/\1true/g' ${web_workspace}/laradock/.env
sed -i 's/\(MYSQL_VERSION=\).*/\15.7/g' ${web_workspace}/laradock/.env
sed -i 's/\(MYSQL_PASSWORD=\).*/\1sdr54dfas234fjaskdopm324/g' ${web_workspace}/laradock/.env
sed -i 's/\(MYSQL_ROOT_PASSWORD=\).*/\1!@#$4321QWERrewq/g' ${web_workspace}/laradock/.env
sed -i 's/\(WORKSPACE_TIMEZONE=\).*/\1PRC/g' ${web_workspace}/laradock/.env
date +'开始安装laradock:%Y年%m月%d日 %H:%M:%S' #输出来看下
cd ${web_workspace}/laradock/ && docker-compose up -d nginx mysql php-fpm workspace
date +'安装好laradock:%Y年%m月%d日 %H:%M:%S' #输出来看下



