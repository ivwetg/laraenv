#!/bin/bash
#参考于：https://www.tecmint.com/restrict-ssh-user-to-directory-using-chrooted-jail/
#参考于：https://blog.csdn.net/weixin_40545512/article/details/82055176
#克隆：git clone ssh://git@hostname:port/.../xxx.git
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/ucb:/usr/local/bin
#账号

if [ "$1" = "" ]; then
    echo "请输入账号！"
    exit 1
fi
#密码
if [ "$2" = "" ]; then
    echo "请输入密码！"
    exit 1
fi

#第一步：生成牢笼的根目录/

USER=$1
USER_PASSWORD=$2
USER_ROOT="/var/www/${USER}"

if [ ! -d $USER_ROOT ]; then
    `mkdir -p $USER_ROOT`  #不存在则创建
else
    echo "目录已存在！"
    exit 1
fi

#第二步：生成节点

mkdir -p $USER_ROOT/dev/
cd $USER_ROOT/dev/
mknod -m 666 null c 1 3
mknod -m 666 tty c 5 0
mknod -m 666 zero c 1 5
mknod -m 666 random c 1 8
#设置所有者为root，注意！牢笼以上层、上上层，所有者都应设置为root，测试发现有一层没设置，就连接不上ssh
chown root:root /var
chown root:root /var/www
chown root:root $USER_ROOT
chmod 0755 $USER_ROOT

#第三步：创建bin目录，并将bash移过去给新用户使用

mkdir -p  $USER_ROOT/bin
cp -v /bin/{sh,bash,ls,mkdir,chmod,chown,rm}  $USER_ROOT/bin
#需要链接这些库，用`ldd /bin/bash`可以看到链接了哪些文件，但为了省时间，直接把lib和lib64都移到牢笼之中
cp -r /lib $USER_ROOT
cp -r /lib64 $USER_ROOT
#这个是php，git的环境
mkdir -p  $USER_ROOT/usr/bin
mkdir -p  $USER_ROOT/usr/share
cp -v /usr/bin/{git*,php,vi,vim,zip,unzip}  $USER_ROOT/usr/bin
cp -vr /usr/share/git*  $USER_ROOT/usr/share

#php,git的库
cp -r /usr/lib $USER_ROOT/usr

#第四步：创建用户并设置密码

useradd $USER -s /bin/bash
echo $USER:$USER_PASSWORD|chpasswd
`mkdir -p $USER_ROOT/code && chown $USER  $USER_ROOT/code` #存放代码
`mkdir -p $USER_ROOT/repertory && chown $USER  $USER_ROOT/repertory` #存放私库

#第五步：创建用户后将结果更新到牢笼，注意，每次添加用户，都要更新一次

mkdir $USER_ROOT/etc
cp -vf /etc/{passwd,group} $USER_ROOT/etc

#第六步：更新 sshd_config 文件

sed -i "\$aMatch User ${USER}"  /etc/ssh/sshd_config
sed -i "\$aChrootDirectory ${USER_ROOT}"  /etc/ssh/sshd_config
#echo "Match User ${USER}" >> /etc/ssh/sshd_config #用sed路径有问题，先不用，暂用>>代替
#echo "ChrootDirectory ${USER_ROOT}" >> /etc/ssh/sshd_config #用sed路径有问题，先不用，暂用>>代替

#第七步：重启sshd
service sshd restart
