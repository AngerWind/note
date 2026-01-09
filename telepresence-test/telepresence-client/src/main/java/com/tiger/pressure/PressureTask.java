package com.tiger.pressure;

import java.util.concurrent.ExecutorService;

public interface PressureTask<T extends DataSizeAware> {

    /** 构造一条 / 一批数据（不计入压测时间） */
    T buildData(int index);

    /**
     * 发送数据
     * @return SendResult
     */
    SendResult send(T data) throws Exception;

    default void warmup(ExecutorService executorService) throws Exception {}

    default void init()  throws Exception {};

    default void shutdown() throws Exception {};
}

