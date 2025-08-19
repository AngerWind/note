from datetime import datetime, timedelta

from .task import send_email,send_msg


# 在指定的时间点执行任务
exec_time = datetime(2025, 8, 17, 13, 5, 00)
utc_exec_time = datetime.utcfromtimestamp(exec_time.timestamp())
result = send_email.apply_async(args=["hahah"], eta=utc_exec_time)
print(result.id)


# 在当前时间多久之后, 执行任务
utc_now = datetime.utcfromtimestamp(datetime.now().timestamp())
utc_exec_time = utc_now + timedelta(seconds=60)
result = send_msg.apply_async(args=["hahah"], eta=utc_exec_time)
print(result.id)







