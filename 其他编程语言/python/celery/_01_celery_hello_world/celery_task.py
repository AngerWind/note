from celery import Celery
import time

# 配置 Redis 作为 broker 和 backend
app = Celery(
    "test",
    # broker指定celery创建队列使用的redis
    broker="redis://127.0.0.1:6379/2",
    # backend执行celery将结果写到的地址
    backend="redis://127.0.0.1:6379/1"
)

@app.task
def send_email(name: str) -> str:
    print(f"向 {name} 发送邮件...")
    time.sleep(5)
    print(f"向 {name} 发送邮件完成")
    return "ok"

@app.task
def send_msg(name: str) -> str:
    print(f"向 {name} 发送短信...")
    time.sleep(5)
    print(f"向 {name} 发送短信完成")
    return "ok"
