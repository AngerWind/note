https://www.bilibili.com/video/BV1jg4y13718?spm_id_from=333.788.videopod.episodes&vd_source=f79519d2285c777c4e2b2513f5ef101a&p=5

https://www.cnblogs.com/pyedu/p/12461819.html





~~~shell
# celery表示启动celery
# -A celery_task 指定celery的task的定义的文件是根目录下的celery_task.py
# 如果你的celery_task.py 是在 aa包中的, 那么使用 aa.celery_task 来指定, 格式就是python中的import语法

# worker 表示启动worker进程
# -l info 打印info 日志, 这会打印扫描到的任务
celery -A celery_task worker -l info


celery  -A celery_task beat
~~~





如果你使用redis来作为消息队列的话, 那么celery会使用redis中的list模拟消息队列, 并使用`lpush/rpop`来模拟消息的入队和出队



假如你有如下的一个task, 那么在调用`send_email.delay(xxx)`的时候, 会将这个任务发送到`celery`这个key的list中

~~~python
def send_email(name):
    pass
~~~

当然你也可以指定任务要监听的消息消息队列

~~~python
@app.task(queue="email_queue")
def send_email(name):
    pass
~~~

那么你在调用`send_email.delay(xxx)`的时候,  消息会被发送到key为`celery:email_queue`这个redis list中







todo 当然celery中也支持多队列任务路由, 

todo 结果是保存在redis的哪个key中





## 问题

### ModuleNotFound

在启动生产者的时候, 如果你的生产者是在模块a中, 那么你执行如下命令的时候, 会报错, 因为python会将`./a/`当做项目的根目录, 导致没有办法import

```shell
python ./a/producer.py
```

所以你应该使用如下命令来执行producer

```shell
python -m a.producer
```



### [WinError 6] 句柄无效

当你将任务发送到worker的时候, 会出现如下的报错信息

~~~shell
Pool process <billiard.pool.Worker object at 0x000001B328636B50> error: PermissionError(13, '拒绝访问。', None, 5, None)
OSError: [WinError 6] 句柄无效。
PermissionError: [WinError 5] 拒绝访问。
~~~

这是因为celery worker默认使用了prefork来作为线程池, 而windows不执行fork, 所以你需要使用其他类型的线程池来替代

 你可以使用gevent来替代他

~~~shell
pip install gevent
celery -A celery_app worker -l info -P gevent
~~~

