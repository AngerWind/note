## mongodb基本命令

#### 数据库相关

- show dbs或者 show database 显示所有的数据库， 没有数据的数据库不会显示。
- use <db_name> 选择某个数据库，没有数据库自动创建。
- db   当前的数据库名称

#### 集合相关

- show collections 显示当前数据库中所有集合

#### 文档相关

- 插入文档

  ~~~javascript
  // test为当前数据库的集合，若没有该集合会自动创建
  // insert可以插入一个对象，也可以插入多个对象
  db.test.insert({
      "name": "zhangsna",
      "age": "16",
      "gender": "男"
  })
  
  db.test.insertOne({...})
  db.test.insertMany([{...}, {...}])
  ~~~

- 查询集合中所有文档

  ~~~js
  // find返回一个数组
  db.test.find({...}).limit(2)
  db.test.find({...}).count()
  
  db.test.findOne({...})
  ~~~

- 修改文档

  ~~~js
  // 第一个对象为查询条件，第二个对象为修改后的对象，mongo会直接使用这个对象覆盖修改前的对象
  // update默认等于updateOne
  db.test.update({...}, {...})
  db.test.updateMany({...}, {...})
  db.test.updateOne({...}, {...})
  
  
  ~~~

  

#### mongo开启密码登录

使用mongo shell 连接mongdb
```shell
# host默认为localhost
# port默认为27017
mongo --host <HOSTNAME> --port <PORT>
```
创建用户
```shell
# swith to the admin database
use admin
# 使用db.createUser()函数创建一个root用户
db.createUser(
  {
    user: "tiger",
    pwd: "123456",
    roles: [ "root" ]
  }
)
#查看用户,验证
show users
```
关闭mongo server并退出mongo shell
```shell
db.shutdownServer()
exit
```

启动mongo server并开启密码认证

以管理员身份另开一个cmd

~~~shell
# 因为mongo通过windows服务进行自启动的，通过win + r运行services.msc查看mongo启动命令
# E:\MongoDB_4.2.8\bin\mongod.exe --config E:\MongoDB_4.2.8\bin\mongod.cfg --service
# 发现mongod是根据mongod.cfg启动的，而查看mongod.cfg发现，配置文件是没有开启密码认证的
# 所以有两种办法开启密码认证

# 方法一， 通过命令行启动密码认证
mongod --remove # 删除以前的mongod服务，默认为MongoDB，也可以使用--serviceName ”MongoDB“指定服务名
mongod --config "E:\MongoDB_4.2.8\bin\mongod.cfg" --auth --install # 创建一个默认名为MongoDB的windows服务，并且开启密码认证。通过--serviceName指定服务名
net start MongoDB # 启动mongo服务


# 方法二， 修改mongod.cfg开启密码认证
# linux下添加
auth=true
# windows下添加
security:
  authorization: enabled
net stop MongoDB 
net start MongDB # 重启mongod服务
~~~

连接mongo shell

~~~shell
# 类似mysql的登陆
mongo -u username -p password

# 连接mongo shell之后进行认证
mongo
use admin # !!!需要在admin下
db.auth("userName", "password")
~~~



 