from celery.result import AsyncResult
from .celery import app

async_result=AsyncResult(id="e7d5560e-04d1-4674-bab2-bcd9ce8cb764", app=app)

if async_result.successful():
    result = async_result.get()
    print(result)
elif async_result.failed():
    print('执行失败')
elif async_result.status == 'PENDING':
    print('任务等待中被执行')
elif async_result.status == 'RETRY':
    print('任务异常后正在重试')
elif async_result.status == 'STARTED':
    print('任务已经开始被执行')