

https://www.bilibili.com/video/BV1bS4y1471A/?p=20&vd_source=f79519d2285c777c4e2b2513f5ef101a

# jenkins架构图

![image-20231121143745041](img/jenkins/image-20231121143745041.png)

在上面的图示中, 一共需要三台服务器

1. 代码托管服务器上需要安装gitlab
2. Jenkins服务器上需要安装Jenkins, Maven, Git
3. 代码测试服务器上, 因为我们只需要测试java, 所以只需要安装jdk

#  Jenkins架构安装

## 在代码管理服务器上安装gitlab

一下是通过docker安装gitlab的过程

https://blog.csdn.net/BThinker/article/details/124097795

~~~shell
# 启动容器
docker run \
 -itd  \
 -p 9980:80 \
 -p 9922:22 \
 -v /home/gitlab/etc:/etc/gitlab  \
 -v /home/gitlab/log:/var/log/gitlab \
 -v /home/gitlab/opt:/var/opt/gitlab \
 --restart always \
 --privileged=true \
 --name gitlab \
 gitlab/gitlab-ce
 
# 进入docker内部
docker exec -it gitlab /bin/bash


vi /etc/gitlab/gitlab.rb
# 添加如下东西, ip换成自己宿主机的ip或者域名
external_url 'http://192.168.124.194'
gitlab_rails['gitlab_ssh_host'] = '192.168.124.194'
gitlab_rails['gitlab_shell_ssh_port'] = 9922

vi /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml
# 修改如下内容
gitlab:
    host: 192.168.124.194 # 这里修改为自己ip
    port: 9980 # 这里改为9980
    https: false

# 重启gitlab
gitlab-ctl restart

# 在容器内查看root密码
cat /etc/gitlab/initial_root_password

# 退出容器
exit 
~~~



## 在Jenkins服务器上安装JDK, Maven, Jenkins, Git

~~~shell
# 安装jdk11
yum search openjdk
# 必须要jdk, jre不行!!!!!!
yum install java-11-openjdk

# 安装jdk和jenkins
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  yum install fontconfig jenkins
  
# 查找jenkins配置文件目录
find / -name "hudson.model.UpdateCenter.xml" -type f
# 更改配置文件, 否则jenkins连接外网, 会特别的慢
vim /var/lib/jenkins/hudson.model.UpdateCenter.xml
https://updates.jenkins.io/update-center.json
更改为https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json


# 启动jenkins
systemctl start jenkins
systemctl status jenkins

# 安装maven
wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz
tar -xzvf apache-maven-3.9.5-bin.tar.gz
mv apache-maven-3.9.5 /usr/local/maven

# 写入环境变量, 这里的\表示不要转义其中的变量
cat << \EOF >> /etc/profile
MAVEN_HOME=/usr/local/maven
export PATH=${MAVEN_HOME}/bin:${PATH}
EOF
source /etc/profile

# 添加maven镜像
vim /usr/local/maven/conf/settings
<mirror>
　　<id>nexus-tencentyun</id>
　　<mirrorOf>*</mirrorOf>
　　<name>Nexus tencentyun</name>
　　<url>http://mirrors.cloud.tencent.com/nexus/repository/maven-public/</url>
</mirror>

# 安装git
sudo yum install -y git
~~~

1. 访问jenkins, 输入密码

   <img src="img/jenkins/image-20231121173431479.png" alt="image-20231121173431479" style="zoom: 33%;" />

2. 安装插件

   <img src="img/jenkins/image-20231121173453909.png" alt="image-20231121173453909" style="zoom:33%;" />

3. 创建管理员用户

   <img src="img/jenkins/image-20231121173525960.png" alt="image-20231121173525960" style="zoom:33%;" />



# 配置jenkins拉取gitlab代码并自动构建和测试

### Jenkins配置maven

1. 安装jenkins的maven插件

   ![image-20231121193157359](img/jenkins/image-20231121193157359.png)

   

   <img src="img/jenkins/image-20231121180030022.png" alt="image-20231121180030022" style="zoom: 25%;" />

2. 在jenkins中配置maven的位置

   ![image-20231121193131067](img/jenkins/image-20231121193131067.png)

   ![image-20231121193102364](img/jenkins/image-20231121193102364.png)

### Jenkins配置测试服务器
1. 安装jenkins的Publish Over SSH插件, 该插件用来将打包好的jar包通过ssh发送到测试服务器上

   <img src="img/jenkins/image-20231121191731515.png" alt="image-20231121191731515" style="zoom:50%;" />

2. 配置一台测试服务器

   ![image-20231121193313679](img/jenkins/image-20231121193313679.png)

   ![image-20231121193354298](img/jenkins/image-20231121193354298.png)

   ![image-20231121193524593](img/jenkins/image-20231121193524593.png)





### 创建item, 用于自动构建, 测试

<img src="img/jenkins/image-20231121193654200.png" alt="image-20231121193654200" style="zoom:33%;" />

<img src="img/jenkins/image-20231121193736707.png" alt="image-20231121193736707" style="zoom:33%;" />

<img src="img/jenkins/image-20231121194225103.png" alt="image-20231121194225103" style="zoom: 33%;" />



<img src="img/jenkins/image-20231121194351288.png" alt="image-20231121194351288" style="zoom:33%;" />

<img src="img/jenkins/image-20231122121125722.png" alt="image-20231122121125722" style="zoom:33%;" />

![image-20231121202153595](img/jenkins/image-20231121202153595.png)

构建的时候, jenkins会通过git将源代码下载到`/var/lib/jenkins/workspace/item_name/`下, 然后通过maven进行构建

并且如果没有在m

aven的settings.xml中指定maven仓库, 默认使用`/var/lib/jenkins/.m2`作为maven仓库

### 配置item构建后发送jar包到测试服务器上, 并执行

1. 构建后发送到测试服务器上, 并自动执行jar包

   <img src="img/jenkins/image-20231122130119949.png" alt="image-20231122130119949" style="zoom:33%;" />

   <img src="img/jenkins/image-20231122130151113.png" alt="image-20231122130151113" style="zoom:33%;" />

   需要注意的是

   1. source files是以`/var/lib/jenkins/workspace/items_name`作为根路径的, 所以sourcefile要填`**/target/test1*.jar`
   2. remote directory是以**连接服务器的用户的家目录**为根目录的, 所以文件会发送到`/root/jenkins/test1`下, 因为配置的ssh是root用户
   3. 在发送文件的时候, 会连带文件所在的目录一起发送到remote directory中, 因为jar包在`target`下, 所以发送到测试服务器的位置为`/root/jenkins/test1/target/`,  我们不希望发送target这个目录, 所以需要在remove prefix中填入`target`, 这样文件就会在`/root/jenkins/test1/`下面
   4. exec command:`nohup java -jar ~/jenkins/test1/test1*.jar > my.log 2>&1 &`必须要退出, 并且状态码必须是0, 如果只是执行java -jar 的话, 命令行不会退出, 这样exec command就会超时报错

2. 清理上次发送过来的jar包和杀死上次执行的进程

   在`/usr/bin`创建`clean.sh`, 用来清理文件和程序, 内容如下

   ~~~shell
   #!/bin/bash
   
   #删除历史数据
   rm -rf ~/jenkins/*
   appname=$1
   #获取正在运行的jar包pid
   pid=`jps | grep $appname | awk '{printf $1}'`
   #如果pid为空，提示一下，否则，执行kill命令
   if [ -z $pid ];
   #使用-z 做空值判断
           then
                   echo "$appname not started"
           else
                   kill -9 $pid
                   echo "$appname stoping...."
   fi
   check=`ps -ef | grep -w $pid | grep java`
   if [ -z $check ];
           then
                   echo "$appname pid:$pid is stop"
           else
                   echo "$appname stop failed"
   fi
   ~~~

   在jenkins中配置如下:

   <img src="img/jenkins/image-20231122131202901.png" alt="image-20231122131202901" style="zoom:33%;" />

# 自动化构建的几种构建触发器的说明

<img src="img/jenkins/image-20231122131819645.png" alt="image-20231122131819645" style="zoom:33%;" />

触发器指定了在什么时候, 自动的触发item任务的执行, 并自动构建我们的任务

- Build whenever a SNAPSHOT dependency is built

  jenkins分析项目中的pom文件, 当项目中的依赖重新构建时, 自动重新构建当前项目

  

- 触发远程构建 (例如,使用脚本)

  设置一个`TOKEN`, 比如12345, 当调用`jenkins域名:端口/job/item_name?token=${TOKEN}`时, 会触发jenkins调用项目

  **使用这种方式, 可以配合GitLab或者GitHub的Webhooks来使用, 当我们提交代码的时候, 自动调用我们的接口, 来触发项目构建**

  !!! 使用这种方式接口触发自动化构建的时候, 除了要携带token, 还必须触发已经登录的状态, 否则会调用失败并跳转到登录界面

  如果希望可以直接调用而不用带已登录的token, 需要安装插件`Build Authorization Token Root`, 然后调用`buildByToken/build?job=${item_name}&token=${TOKEN}`

- Build after other projects are built

  指定一个item, 当该item构建的时候, 自动构建当前项目

  

- Build periodically

  使用cron表达式定时构建本job

  

- GitHub hook trigger for GITScm polling

  Github-WebHook出发时构建本job

  

- Poll SCM

  使用cron表达式定时检查代码是否变更，变更后构建本job



### 构建结果发送邮箱

https://www.bilibili.com/video/BV1bS4y1471A?p=20&vd_source=f79519d2285c777c4e2b2513f5ef101a



### jenkins 多节点并发构建

多节点并发构建并不需要多节点上安装jenkins, 只需要有对应的构建工具即可, jenkins通过ssh连接上后, 会执行对应的命令, 进行自动化构建

1. 添加节点

   ![image-20231201150552017](img/jenkins/image-20231201150552017.png)

   ![image-20231201150701787](img/jenkins/image-20231201150701787.png)

   ![image-20231201150727287](img/jenkins/image-20231201150727287.png)

   配置完成后可以查看日志, 看主机连接到这个节点的过程

   ![image-20231201151634633](img/jenkins/image-20231201151634633.png)

   添加节点有如下需要注意的地方

   **number of executor:  当前机器能够并发构建的个数**

   远程工作目录: 

   标签: 类似于k8s中的标签, 用于确定任务需要分配到哪个机器上进行构建

   用法: 用于确定如何分配任务到当前机器上

   1. use this node as much as possible: 尽可能使用当前节点进行构建
   2. only build jobs with label expression matching this node: 只有当任务的标签选择器匹配到了当前机器才在当前机器上进行构建

   启动方式: 即主机如何控制当前机器

   1. launch agent by connectiong it to the controller
   2. lanch agent via execution  of command on the controller
   3. launch agents via ssh: 通过ssh控制

2. 设置任务并发构建

   ![image-20231201152101046](img/jenkins/image-20231201152101046.png)





# pipeline

在使用jenkins执行构建的时候, 如果我们创建的是freestyle project这种类型的item的话, 所有的日志都会打印在同一个任务中

![image-20260207173941968](img/jenkins/image-20260207173941968.png)

![image-20260207173527706](img/jenkins/image-20260207173527706.png)

为了能够将每个步骤的日志都打印在他当前步骤的任务中, 我们可以创建一个pipeline类型的item

![image-20260207174103709](img/jenkins/image-20260207174103709.png)

然后选择流水线, 在其中输入pipeline相关的代码, 这里的pipeline代码实际上就是groovy的dsl代码

![image-20260207174207453](img/jenkins/image-20260207174207453.png)

pipeline代码如下

~~~groovy
//所有的脚本命合都放在pipeline中
pipeline{
	//指定任务在哪个jenkins节点中执行, any表示随便哪个节点
	agent any
	// 声明全局变量，方便后面使用
    environment {
        key = 'value'
    }
    // stages定义每一个单独要执行的步骤
	stages {
	   stage('拉取git仓库代码'){
            // 定义具体的步骤, 可以有多个命令
			steps {
            	echo '拉取git仓库代码 - SUCCESS'
            }
		}
        stage('通过maven构建项目'){
             steps {
                 echo '通过maven构建项目 - SUCCESS'
             }
         }
        stage('通过SonarQube做代码质量检测'){
             steps {
                 echo '通过SonarQube做代码质量检测 - SUCCESS'
             }
         }
        stage('通过Docker制作自定义镜像'){
             steps {
                 echo '通过Docker制作自定义镜像 - SUCCESS'
             }
         }
        stage('将自定义镜像推动到Harbor'){
             steps {
                 echo '将自定义镜像推动到Harbor - SUCCESS'
             }
         }
        stage('通过Publish Over SSH 通知目标服务器'){
             steps {
                 echo '通过Publish Over SSH 通知目标服务器 - SUCCESS'
             }
         }
    }
}
~~~

将上面的代码粘贴到下面的位置中并进行构建

![image-20260207175253256](img/jenkins/image-20260207175253256.png)

![image-20260207175319657](img/jenkins/image-20260207175319657.png)

通过上面的图片, 你可以看到每个步骤的名字, 他们执行了多久的时间, 就不需要和free style一样, 所有的日志都堆在一起了



## pipiline语法

实际上你根本不需要去记忆pipeline语法, Jenkins提供了pipeline代码生成器, 你只需要在界面上进行配置, 就可以生成对应的代码

![image-20260207175606967](img/jenkins/image-20260207175606967.png)

![image-20260207175627283](img/jenkins/image-20260207175627283.png)

比如我现在要从gitlab上面checkout代码, 那么我只需要在片段生成器中选择`checkout: Check out from version controller`这个步骤, 然后填写gitlab的地址

![image-20260207175842776](img/jenkins/image-20260207175842776.png)

![image-20260207175910875](img/jenkins/image-20260207175910875.png)

配置完毕之后, 点击生成pipeline语法, 即可出现对应的代码

![image-20260207180002546](img/jenkins/image-20260207180002546.png)

然后你只要把对应的代码, 放到pipeline代码中的`steps`代码片段中接口



## jenkinsfile

上面的案例中, pipeline的步骤实际上还是保存在jenkins的界面中, 我们要进行修改的时候, 实际上还是要在jenkins的界面上进行修改, 这样有点不太方便

jenkins提供了一种方式, 你可以将pipeline的步骤保存在本地的`Jenkinsfile`文件中, 然后和你的代码一起上传到gitlab上面, 然后你可以在jenkins上面指定Jenkinsfile在gitlab上面的位置

在构建的时候, jenkins会先去gitlab上面下载对应的Jenkinsfile, 然后再执行Jenkinsfile上面指定的步骤

1. 首先在你本地的项目上创建一个`Jenkinsfile`文件, 保存到项目的根目录下, 类似`Dockerfile`

2. 将这个文件和项目代码一起推送到gitlab上面

   ![image-20260207183641035](img/jenkins/image-20260207183641035.png)

3. 在jenkins上面配置这个文件的位置

   ![image-20260207183428019](img/jenkins/image-20260207183428019.png)

   ![image-20260207183515057](img/jenkins/image-20260207183515057.png)

4. 然后在jenkins上面, 进行构建, 会多出来一个步骤, 这个步骤就是从gitlab上面拉取jenkinsfile的

   ![image-20260207183931271](img/jenkins/image-20260207183931271.png)