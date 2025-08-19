from celery.result import AsyncResult
from celery_task import app

async_result=AsyncResult(id="477c9d77-c62b-4fe5-9035-9087f7ad018a", app=app)

if async_result.successful():
    result = async_result.get()
    print(result)
    # result.forget() # 将结果删除从redis中删除
    # async_result.revoke(terminate=True) # 终止任务, 不管这个任务是否执行
    # async_result.revoke(terminate=False) # 如果任务还没有开始执行, 那么终止任务
elif async_result.failed():
    print('执行失败')
elif async_result.status == 'PENDING':
    print('任务等待中被执行')
elif async_result.status == 'RETRY':
    print('任务异常后正在重试')
elif async_result.status == 'STARTED':
    print('任务已经开始被执行')