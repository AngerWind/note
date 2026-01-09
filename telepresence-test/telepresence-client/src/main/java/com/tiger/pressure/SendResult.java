package com.tiger.pressure;

public class SendResult implements DataSizeAware {

    private final int successCount;
    private final int failureCount;

    public SendResult(int successCount, int failureCount) {
        this.successCount = successCount;
        this.failureCount = failureCount;
    }

    public int getSuccessCount() {
        return successCount;
    }

    public int getFailureCount() {
        return failureCount;
    }

    /**
     * 总共处理的数据条数 = 成功 + 失败
     */
    @Override
    public int size() {
        return successCount + failureCount;
    }

    /**
     * 是否完全成功
     */
    public boolean isAllSuccess() {
        return failureCount == 0;
    }
}
