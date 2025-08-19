

from .task import send_email,send_msg

# 直接调用相关任务的delay方法, 里面的方法就是给任务传参
# 方法会直接返回这个celery的任务的uid
result = send_email.delay("zhangsan")
print(result.id)

result = send_msg.delay("lisi")
print(result.id)






