#### 关于wsl使用ssh连接localhost的问题

在wsl1中，windows和wsl的Ubuntu系统之间的网络是无感知的，也就是连通的。即windows可以通过localhost访问Ubuntu上面的引用，Ubuntu也可以通过localhost访问windows上面的应用。

所以在Ubuntu中使用ssh连接localhost会连接到当前的windows，而不是运行的Ubuntu。这就导致一些ssh的脚本会运行失败。

但是在wsl2中，windows可以通过localhost访问Ubuntu上面的应用，但是Ubuntu不能通过localhost访问windows上面的应用，而是需要使用ip地址。

为了ssh localhost连接到windwos上面的问题需要将wsl的版本升级为wsl2

1. 查看当前wsl版本，

   ~~~shell
   wsl -l -v
   ~~~

2. 升级wsl2参考文章https://zhuanlan.zhihu.com/p/356397851

3. 升级到wsl2后，Ubuntu的sshd服务默认没有开启

   ~~~shell
   sudo apt-get update
   # 卸载自带的sshd并重新安装，貌似是有问题
   sudo apt-get remove openssh-server
   sudo apt-get install openssh-server
   
   # 修改sshd的配置文件， 运行账号密码登录和运行root远程登录，如果不修改的话只能使用公钥私钥的方式登录
   sudo vim /etc/ssh/sshd_config
   # 将修改PasswordAuthentication no为 PasswordAuthentication yes
   # 找到并用#注释掉这行：PermitRootLogin prohibit-password
   # 新建一行 添加：PermitRootLogin yes
   
   # 修改配置文件后启动sshd服务
   sudo service ssh start
   # 或者
   sudo service ssh restart
   
   # ssh连接localhost查看是否是当前的Ubuntu
   ssh user@localhost
   ~~~

4. 设置ssh服务开机自启动

   - 在windows中`win+r`输入`shell:startup`打开自启动目录
   - 创建`wsl_sshd_startup.bat`
   - 在其中输入`wsl -u root -e /etc/init.d/ssh start`

   

