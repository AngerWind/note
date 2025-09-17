官方社区版文档

https://docs.min.io/community/minio-object-store/operations/deployments/baremetal-deploy-minio-on-ubuntu-linux.html



## 测试网站

MinIO官网提供了一个搭建好的MinIO Server, 账号和密码为minioadmin, 可以直接开玩

web ui: https://play.min.io:9443

api端口: https://play.min.io






## MinIO 单机单磁盘直接启动(测试使用)

minio的安装可以分为三个部分:

1. minio:   minio的服务端
2. minio client: minio的客户端, 该客户端提供了一系列的命令来控制minio
3. sdk:   通过代码来上传和下载文件



minio server的安装基本可以划分为一下几步:

1. 下载minio
2. 设置root username和password到环境变量**(默认root账户的账户名和密码都是minioadmin)**
3. 启动minio

![image-20240507144045931](img/minio/image-20240507144045931.png)



### windows

https://min.io/download?license=agpl&platform=windows

**MinIO Server**

powershell执行如下命令: 

~~~powershell
# 下载minio到c盘
PS> Invoke-WebRequest -Uri "https://dl.min.io/server/minio/release/windows-amd64/minio.exe" -OutFile "C:\minio.exe"

# 设置用户名和密码到环境变量
PS> setx MINIO_ROOT_USER admin
PS> setx MINIO_ROOT_PASSWORD password

# server表示启动server端, f:\data为数据目录, :9001表示控制台端口, 绑定到0.0.0.0
PS> C:\minio.exe server F:\Data --console-address ":9001"
~~~

**MinIO Client**

~~~powershell
PS> Invoke-WebRequest -Uri "https://dl.minio.io/client/mc/release/windows-amd64/mc.exe" -OutFile "C:\mc.exe"
# 添加minio server到minio client中, 这样以后可以直接通过myminio来调用这个server
# 可以配置多个server
C:\mc.exe alias set myminio/ http://MINIO-SERVER MYUSER MYPASSWORD
~~~



### Linux

https://min.io/download?license=agpl&platform=linux



**MinIO Server**

~~~shell
wget https://dl.min.io/server/minio/release/linux-amd64/minio

# 赋予执行权限
chmod +x minio

# /mnt/data表示数据目录
# MINIO_ROOT_USER和MINIO_ROOT_PASSWORD是环境变量, 用于设置minio的root的用户名和密码
MINIO_ROOT_USER=admin MINIO_ROOT_PASSWORD=password ./minio server /mnt/data --console-address ":9001"
~~~

**MinIO Client**

~~~shell
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
# 添加minio server到minio client中, 这样以后可以直接通过myminio来调用这个server
# 可以配置多个server
mc alias set myminio/ http://MINIO-SERVER MYUSER MYPASSWORD
~~~



### docker

https://min.io/download?license=agpl&platform=docker

**MinIO Server**

~~~shell
podman run -p 9000:9000 -p 9001:9001 minio/minio server /data --console-address ":9001"
~~~

**MinIO Client**

~~~shell
podman run --name my-mc --hostname my-mc -it --entrypoint /bin/bash --rm minio/mc
[root@my-mc /]# mc alias set myminio/ https://my-minio-service MY-USER MY-PASSWORD
[root@my-mc /]# mc ls myminio/mybucket
~~~



### kubernetes

https://min.io/download?license=agpl&platform=kubernetes

**MinIO Server**

~~~shell
kubectl apply -k github.com/minio/operator
~~~

**MinIO Client**

~~~shell
kubectl run my-mc -i --tty --image minio/mc:latest --command -- bash
[root@my-mc /]# mc alias set myminio/ https://minio.default.svc.cluster.local MY-USER MY-PASSWORD
[root@my-mc /]# mc ls myminio/mybucket
~~~



## MinIO Server安装

> 查看文档的时候, 一定要注意, 查看的是社区版的文档, 不要使用企业版的文档, 否则要license才能启动

https://docs.min.io/community/minio-object-store/operations/deployments/baremetal-deploy-minio-on-ubuntu-linux.html

1. 访问`https://dl.min.io/server/minio/release`, 选择合适的版本进行下载

   首选选择合适的cpu架构, 因为我们linux是amd64架构的, 所以选择linux-amd64

   访问`https://dl.min.io/server/minio/release/linux-amd64/`, 有如下的文件

   ~~~shell
   File Name	File Size	Date
   Parent directory/	-	-
   archive/	-	2025-09-07 18:02
   minio	106 MiB	2025-09-07 17:54
   minio-20250907161309.0.0-1.x86_64.rpm	39 MiB	2025-09-07 17:59
   minio-20250907161309.0.0-1.x86_64.rpm.sha256sum	103 B	2025-09-07 17:59
   minio.RELEASE.2025-09-07T16-13-09Z	106 MiB	2025-09-07 17:54
   minio.RELEASE.2025-09-07T16-13-09Z.asc	833 B	2025-09-07 17:54
   minio.RELEASE.2025-09-07T16-13-09Z.minisig	326 B	2025-09-07 17:54
   minio.RELEASE.2025-09-07T16-13-09Z.sha256sum	100 B	2025-09-07 17:54
   minio.RELEASE.2025-09-07T16-13-09Z.shasum	76 B	2025-09-07 17:54
   minio.apk	35 B	2025-09-07 17:59
   minio.asc	833 B	2025-09-07 17:54
   minio.deb	34 B	2025-09-07 17:59
   minio.minisig	326 B	2025-09-07 17:54
   minio.rpm	37 B	2025-09-07 17:59
   minio.sha256sum	100 B	2025-09-07 17:54
   minio_20250907161309.0.0_amd64.deb	38 MiB	2025-09-07 17:59
   minio_20250907161309.0.0_amd64.deb.sha256sum	100 B	2025-09-07 17:59
   minio_20250907161309.0.0_x86_64.apk	39 MiB	2025-09-07 17:59
   minio_20250907161309.0.0_x86_64.apk.sha256sum	101 B	2025-09-07 17:59
   ~~~

2. 因为我们是Ubuntu, 所以下载`minio_20250907161309.0.0_amd64.deb`, 如果是centos, 可以下载`minio-20250907161309.0.0-1.x86_64.rpm`

   千万不要下载`minio.deb`和`minio.rmp`, 他们只是一个重定向包, 实际上还是要下载上面两个文件的

3. 下载上面的文件, 保存到`/opt/module/software`目录下, 并重命名为`minio.deb`

4. 安装上面的deb包

   ~~~shell
   sudo dpkg -i minio.deb
   
   Selecting previously unselected package minio.
   (Reading database ... 185440 files and directories currently installed.)
   Preparing to unpack minio.deb ...
   Unpacking minio (20250907161309.0.0) ...
   Setting up minio (20250907161309.0.0) ...
   ~~~

5. 安装完毕后, 可以通过如下命令来查看minio的版本

   ~~~shell
   minio --version
   
   minio version RELEASE.2025-09-07T16-13-09Z (commit-id=07c3a429bfed433e49018cb0f78a52145d4bedeb)
   Runtime: go1.24.6 linux/amd64
   License: GNU AGPLv3 - https://www.gnu.org/licenses/agpl-3.0.html
   Copyright: 2015-2025 MinIO, Inc.
   ~~~

   > 注意一定不要安装企业版本的

6. 安装的过程中, minio会自动创建systemd的连接文件, `/lib/systemd/system/minio.service`, 内容如下

   ~~~ini
   [Unit]
   Description=MinIO
   Documentation=https://docs.min.io
   Wants=network-online.target
   After=network-online.target
   AssertFileIsExecutable=/usr/local/bin/minio
   
   [Service]
   Type=notify
   
   WorkingDirectory=/usr/local
   
   User=minio-user
   Group=minio-user
   ProtectProc=invisible
   
   EnvironmentFile=-/etc/default/minio
   ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
   
   # Let systemd restart this service always
   Restart=always
   
   # Specifies the maximum file descriptor number that can be opened by this process
   LimitNOFILE=1048576
   
   # Turn-off memory accounting by systemd, which is buggy.
   MemoryAccounting=no
   
   # Specifies the maximum number of threads this process can create
   TasksMax=infinity
   
   # Disable timeout logic and wait until process is stopped
   TimeoutSec=infinity
   
   # Disable killing of MinIO by the kernel's OOM killer
   OOMScoreAdjust=-1000
   
   SendSIGKILL=no
   
   [Install]
   WantedBy=multi-user.target
   
   # Built for ${project.name}-${project.version} (${project.name})
   ~~~

7. 安装完成后, 我们还需要为minio创建对应的用户和组

   ~~~shell
   # 新建一个group, -r表示系统组
   sudo groupadd -r minio-user 
   
   # 新建一个minio-user的用户, -M表示不需要家目录, -r表示系统用户, -g指定初始的group
   sudo useradd -M -r -g minio-user minio-user 
   ~~~

8. 接下来, 我们可以将单独的磁盘, 挂载到特定的路径下,  比如我们将两个磁盘分别挂载到`/data/minio1`和`/data/minio2`下

   > 两个路径一定要是不同的磁盘, 因为minio会将这些磁盘作为备份, 如果两个路径是同一个磁盘, 那么完全没有备份容灾的作用, 反而因为备份导致磁盘占用增加 

   > 如果没有两个不同的备份, 你也可以直接mkdir两个目录, 来模拟测试一下

9. 挂载磁盘之后, 我们需要将这些磁盘路径的所有者和所属组分别修改为`minio-user`用户和`minio-user`组

   ~~~shell
   # {}是bash中的花括号展开语法, 表示1和2
   chown -R minio-user:minio-user /data/minio{1...2}
   ~~~

10. 根据上面的`minio.service`文件中的`EnvironmentFile=-/etc/default/minio`配置, minio在启动的时候, 会自动的读取`/etc/default/minio`, 所以我们还需要创建这个环境变量文件

    ~~~shell
    # MINIO_VOLUMES指定minio存储的文件保存的目录
    # MINIO_ROOT_PASSWORD指定超级管理员密码, 一定要超过8位长度, 否则无法启动
    # MINIO_OPTS用于指定其他的启动参数
    sudo tee /etc/default/minio <<'EOF'
    MINIO_VOLUMES="/data/minio{1...2}"
    MINIO_ROOT_USER="minioadmin"
    MINIO_ROOT_PASSWORD="00000000"
    MINIO_OPTS="--console-address :9001"
    EOF
    ~~~

    在minio中, 分别有三种不同的磁盘挂载方式

    1. 单节点单磁盘:

       这种方式集群只有一个节点, 这个节点中只有一个磁盘用于保存minio的数据

       **这种模式主要用在测试环境下**

       你需要在`/etc/default/minio`中指定这一个磁盘的挂载目录, 比如

       ~~~shell
       MINIO_VOLUMES="/mnt/drive1/minio"
       ~~~

    2. 单节点多磁盘

       https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-multi-drive.html

       这种方式集群只有一个节点, 但是有多个磁盘挂载到系统中, 用于保存minio的数据

       **这种模式主要用在可以容忍minio停机和数据丢失的场景**

       你需要在`/etc/default/minio`中指定这些磁盘的挂载目录, 比如

       ```shell
       MINIO_VOLUMES="https://minio1.example.net:9000/mnt/drive{1...4}/minio"
       ```

       > 这种模式安装, MINIO_VOLUMES指定的每个目录必须挂载的是新磁盘, 而不能和主系统一个磁盘, 否则无法启动

    3. 多节点多磁盘

       https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-multi-node-multi-drive.html

       https://www.bilibili.com/video/BV1Gx4y1Y7Rg/?spm_id_from=333.337.search-card.all.click&vd_source=f79519d2285c777c4e2b2513f5ef101a

       这种方式集群有多个minio节点, 每个节点都有至少一个磁盘用于保存minio的数据

       这种模式用于生产模式下, 需要分布式高可靠性

       你需要在`/etc/default/minio`中指定这些磁盘的挂载目录, 比如

       ```shell
       MINIO_VOLUMES="http://minio{1...4}.example.net:9000/mnt/disk{1...4}/minio"
       ```

       

11. 之后我们就可以通过如下的命令来启动minio

    ~~~shell
    systemctl start minio
    systemctl status minio
    systemctl stop minio
    systemctl restart minio
    systemctl enable minio
    systemctl disable minio
    ~~~

12. 启动之后, 可以通过如下的命令, 来查看他的启动日志

    ~~~shell
    journalctl -u minio
    ~~~

13. 启动之后, 你可以通过浏览器范围`http://localhost:9001`来访问minio的界面

    ![image-20250916005533470](img/minio/image-20250916005533470.png)

    > 如果访问失败, 记得F5刷新一下, 有可能是缓存的问题

    当然你也可以使用命令行来操作minio, 详情请查看MinIO Client的使用

    

14. 如果要卸载minio, 可以使用如下的命令

    ~~~shell
    # 卸载minio
    sudo dpkg -P minio
    # 移除systemd文件
    sudo rm /lib/systemd/system/minio.service
    # 重新加载
    sudo systemctl daemon-reload
    
    # 卸载不会删除掉/data/minio1, /data/minio2中的数据
    ~~~

    

## MinIO Client的使用

### 安装mc命令

https://docs.min.io/community/minio-object-store/reference/minio-mc.html#mc-install

要使用MinIO Client, 首先需要再系统中安装`mc`命令

1. windows下的安装过程如下

   - 下载windows版本的mc命令, 地址https://dl.min.io/client/mc/release/windows-amd64/mc.exe

   - 然后通过cmd来使用mc命令

     ~~~shell
     \path\to\mc.exe --help
     ~~~

2. linux下的安装过程

   - amd64架构(一般都是amd64架构的)

     ~~~shell
     curl https://dl.min.io/client/mc/release/linux-amd64/mc \
       --create-dirs \
       -o $HOME/minio-binaries/mc
     
     chmod +x $HOME/minio-binaries/mc
     export PATH=$PATH:$HOME/minio-binaries/
     
     mc --help
     ~~~

   - arm架构

     ~~~shell
     curl https://dl.min.io/client/mc/release/linux-arm64/mc \
       --create-dirs \
       -o ~/minio-binaries/mc
     
     chmod +x $HOME/minio-binaries/mc
     export PATH=$PATH:$HOME/minio-binaries/
     
     mc --help
     ~~~



### mc命令的使用

https://docs.min.io/community/minio-object-store/reference/minio-mc/mc-alias.html

#### mc alias

mc alias这个命令可以用来给一个minio集群起一个别名, 用于保持这个集群的url, 秘钥等等, 方便后续对这个集群进行操作

~~~shell
# 将127.0.0.1:9000地址的minio节点, 起别名为local
mc alias set local http://127.0.0.1:9000 admin admin_password
~~~







## 对象管理

MinIO使用Bucket来存储Object, Bucket类似文件系统的顶级目录

MinIO中没有二级目录的概念, 所有的Object都是直接放在Bucket中的

但是可以设置Object的名字为`aa/b.png`,  那么在使用minio console和minio client的时候., 会将`aa`作为一个二级目录来展示, 但是其内部还是使用`aa/b.png`来运行的



对于如下目录:

~~~txt
/articles/
   /john.doe/
      2020-01-02-MinIO-Object-Storage.md
      2020-01-02-MinIO-Object-Storage-comments.json
   /jane.doe/
      2020-01-03-MinIO-Advanced-Deployment.png
      2020-01-02-MinIO-Advanced-Deployment-comments.json
      2020-01-04-MinIO-Interview.md
~~~

管理员需要创建articles存储桶. 然后客户端使用**对象的完整路径**(`jane.doe/2020-01-04-MinIO-Interview.md`)来将对象写入这些存储桶



## Object Versioning 对象版本控制

https://min.io/docs/minio/linux/administration/object-management/object-versioning.html#id2

可以指定对bucket开启版本控制, 默认不开启

开启后, MinIO会保留同一Object的多个版本, 并给每个版本一个唯一的versionId

每个对象version ID 由一个 128 位固定大小的 UUIDv4 组成。

对于禁用或暂停版本控制时创建的对象，versionId为`null`。可以通过指定 `null` 作为version ID 来访问或删除这些对象。

对于最新版本, 会标记为latest

对于删除操作, 会创建一个0字节的`DeleteMarker`, 并将其标记为latest来只是该object的最新版本是删除, 同时该DeleeMarker也有versionId

每个对象最多保存10000个版本, 超过会报错, 删除一个或多个版本以创建对象的新版本。

可以删除对象的历史版本, 这个删除操作是永久性的, 不会进行版本管理

MinIO不会对文件夹进行版本管理, 换而言之, 目录的删除, 重命名, 创建都不会有版本控制

MinIO 使用全量复制的版本控制, 而不是增量或者差异。对于变化较多的Object, 会占用大量空间

可以通过`prefix`从版本控制中排除某些object

比如有文件`v1-aa.png`, `v1/a11.png`, `v1-ab.png`, 那么设置`prefix`为`v1`, 会将该bucket中的所有文件都排除出去

如果设置prefix为`v1/`, 那么只会将`v1/a11.png`排除出去

可以开启`exclude-folders`功能来将`/`结尾的对象排除在版本控制外(不知道这个功能有什么用)



开启, 暂停, 回复, 关闭版本控制可以通过三种方式来实现:

1. SDK(代码)
2. minio控制台界面
3. minio client

具体操作查看https://min.io/docs/minio/linux/administration/object-management/object-versioning.html#exclude-folders-from-versioning



开启版本控制后, 会改变下面命令的功能:



| `PUT`    | 创建对象的新完整版本作为“最新”并分配唯一的版本 ID            | 创建覆盖命名空间匹配的对象。   |
| :------- | :----------------------------------------------------------- | :----------------------------- |
| `GET`    | 默认获取对象的最新版本<br>支持通过版本ID检索任意对象版本。   | 检索对象                       |
| `LIST`   | 检索指定存储桶或前缀的对象的最新版本<br>支持检索所有对象及其关联的版本 ID。 | 检索指定存储桶或前缀的所有对象 |
| `DELETE` | 为对象创建一个 0 字节的“删除标记”作为“latest”（软删除）<br>支持通过版本ID删除任意对象版本（硬删除）。您无法撤消硬删除操作。 | 删除对象                       |



## Object Locking 对象锁定 和 Object Retention 对象保留

https://min.io/docs/minio/linux/administration/object-management/object-retention.html

可以指定bucket 开启对象锁定

被锁定的Object的历史版本只能读取, 不能删除, 直到锁过期

可以删除最新版本, 但是这也只是生成一个`DeleteMarker`, 并将其标记为`lasted`, 相当于没有删除

该功能常用于设置对象的最少保存时间





**开启Bucket对象锁定和对象保留**

该功能必须先开启bucket的版本控制功能, 并且**只能在创建bucket的时候设置是否开启Object Locking**, 一旦创建完成后就无法修改

<img src="img/minio/image-20240508221406112.png" alt="image-20240508221406112" style="zoom:33%;" />

开启Object Locking功能后, 还需要配置Bucket的 Object Retention(对象保留)规则, 才能够对Object进行Lock, 否则和没有开启一样

<img src="img/minio/image-20240508221515432.png" alt="image-20240508221515432" style="zoom:33%;" />



<img src="img/minio/image-20240508221913004.png" alt="image-20240508221913004" style="zoom:33%;" />

Retention 规则有三个选项:

1. Retention Mode: 

   - GOVERNANCE: 

     防止非特权用户进行任何会修改对象或其锁定设置的操作。

     对存储桶或对象拥有 `s3:BypassGovernanceRetention` 权限的用户可以修改对象或其锁定设置。

     在配置的保留规则持续时间过后，MinIO 会自动解除锁定。

   - COMPLIANCE:

     防止任何会改变或修改对象或其锁定设置的操作

     任何 MinIO 用户都无法修改该对象或其设置，包括 MinIO root 用户。

     在配置的保留规则持续时间过后，MinIO 会自动解除锁定。

2. Retention Unit和Retention Validity指定保留的时间



**除了在Bucket上开启默认的Retention规则,  还可以给每个对象设置单独的Retention规则**





**开启对象的合法保留**

在被锁定的对象上, 还可以设置是否开启Legal Hold Retention

对于开启了该功能的对象, 即使锁到期了, 也不能对他删除. 除非关闭了该功能之后, 才可以对其进行删除.

![image-20240508223444289](img/minio/image-20240508223444289.png)



## Object Lifecycle Management 对象生命周期管理

Minio对Object的生命周期管理,  即Object保存了一定的时间之后, 将其删除, 或者转移到其他存储层中

一个bucket可以有多个生命周期规则

<img src="img/minio/image-20240508225311874.png" alt="image-20240508225311874" style="zoom:33%;" />

<img src="img/minio/image-20240508225326489.png" alt="image-20240508225326489" style="zoom:33%;" />

Type Of Lifecycle:  指定删除还是转移

After: 表示保留几天之后就出发生命周期

To Tier: 转移到哪里去

Filters: 可以指定prefix, tags来设置要应用生命周期的对象





对于开启了版本控制的bucket的生命周期, 还有一个Object Version选项用来控制转移/删除的是当前版本还是历史版本:

<img src="img/minio/image-20240508225953956.png" alt="image-20240508225953956" style="zoom:33%;" />

如果是移除非当前版本, 那么还有两个高级选项可以设置:

1. Expire Delete Marker: 如果一个Object的所有版本都被过期删除了, 如果最新版本是delete marker, 那么是否把delete marker也删除,  这样这个Object就完全删除了
2. Expire All Version: 不知道什么意思, 想不通

<img src="img/minio/image-20240508230901762.png" alt="image-20240508230901762" style="zoom:33%;" />



## Server-Side Encryption of Objects 服务端加密

MinIO中的bucket可以开启加密存储, 即数据到达minio后进行加密, 然后写入到磁盘, 在get的时候先解密然后返回

支持三种加密方式:

1. SSE-KMS

   使用存储在外部的key manager service(kms) 的external key(ek) 来对写入存储桶的所有对象进行加密

   客户端可以显示的指定秘钥来覆盖存储桶默认的ek

   加密一旦开启, 就无法禁用

2. SSE-S3

   与SSE-KMS类似, 也是使用存储在kms中的ek来对对象进行加密
   
   客户端可以显示的指定秘钥来覆盖存储桶默认的ek
   
   加密一旦开启, 就无法禁用
   
   **不同的是, SSE-KMS的方式可以给每个bucket指定一个不同的ek, 而SSE-S3只能对所有开启加密的bucket使用同一个ek**
   
3. SSE-C

   客户端在put对象的时候, 指定对象的ek来进行加密, 即使该bucket没有开启加密

   使用这种方式, 秘钥完全保存在客户端, 下次get的时候必须提供秘钥, 否则无法解密

三种加密方式的详细配置可以查看https://min.io/docs/minio/linux/administration/server-side-encryption/server-side-encryption-sse-kms.html





## Bucket Replication 存储桶复制

https://min.io/docs/minio/linux/administration/bucket-replication.html





## 数据压缩

https://min.io/docs/minio/linux/administration/object-management/data-compression.html



## Java整合MinIO

1. 添加依赖, **minio没有starter**

   ~~~xml
   <dependency>
       <groupId>io.minio</groupId>
       <artifactId>minio</artifactId>
       <version>8.4.3</version>
   </dependency>
   ~~~

   ~~~gradle
   implementation 'io.minio:minio:8.4.3'
   ~~~

2. 创建客户端

   ~~~java
   // 线程安全的, 可以在多线程下使用
       private MinioClient minioClient;
   
       @BeforeEach
       public void init() {
           minioClient = MinioClient.builder()
               .endpoint("http://localhost:9000")
               .credentials("minioadmin", "minioadmin")
               .build();
       }
   ~~~

   

3. 具体的api使用查看

   https://github.com/minio/minio-java/tree/master/examples





## 事件通知

MinIO可以向外部发送关于Bucket和Object的事件通知

他支持RabbitMQ, MQTT, NATS, NSQ, Elasticsearch, Kafka, Mysql, PostgrsSQL, Redis, Webhook

具体如何配置查看:

https://min.io/docs/minio/linux/administration/monitoring.html



## Server日志推送到HTTP Webhook





## 文件分片上传逻辑

分片上传有根据`文件系统是否能够暴露给前端`两种实现逻辑:

1. 文件上传给后端, 然后后端上传给MinIO
2. 前端向后端请求分片地址, 然后前端直接上传给MinIO



第一种的实现逻辑:

1. 调用后端接口, 开启一个分配上传任务, 参数有`文件名, 文件总大小, 分片大小, 分片个数, 文件md5, 文件类型, 如果可以的话还应该包含每个分片的md5`

   - 后端根据文件的md5判断数据库中是否有相同md5的文件, 如果有那么直接完成并返回(可能别人已经上传过了, 百度云就是这个逻辑)
   - 如果没有那么去指定的bucket, 创建一个文件夹, 用来保存分片文件, (文件夹的名称可以是md5, 也可以是任务id)
   - 在数据库创建任务的相关记录
   - 返回任务id

2. 前端发送指定的分片给后端

   - 后端根据任务id判断这个分片任务有没有开启, 如果没有开启, 那么要先开启分片任务
   - 如果开启了, 那么就把文件上传的minio的指定文件夹下, **object name可以直接使用分片号**
   - 返回

   根据业务考虑如下逻辑:
   
   1. 上传分片的时候, 去minio中查是否已经有分片文件了, 如果没有才上传, 还是直接覆盖?
   
3. 前端上传完成后调用合并接口

   - 根据任务id判断有没有开启任务
   - 查看minio中的分片个数是否是总的个数, 即有没有所有分片上传
   - 合并文件
   - 判断合并后的文件和开始的md5是否一样

代码参考: https://www.bilibili.com/video/BV1vC4y1X7UR/?spm_id_from=333.999.0.0&vd_source=f79519d2285c777c4e2b2513f5ef101a

https://github.com/dufGIT/minio-file/







第二种上传方式:

1. 也是调用后端接口, 来开启一个上传任务

2. 前端申请分片文件的url

   - 后端可以使用分片号作为分片文件的object name, 然后向minio申请url

3. 前端并将分片文件上传到指定的url中

4. 前端调用后端接口来合并文件, 然后后端校验合并后的md5是否与原先的相同

代码参考: https://gitee.com/Gary2016/minio-upload

   

