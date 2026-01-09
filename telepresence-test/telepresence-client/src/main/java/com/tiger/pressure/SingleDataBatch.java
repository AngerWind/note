package com.tiger.pressure;

public class SingleDataBatch<T> implements DataSizeAware {

    private final T data;

    private final int size;

    public SingleDataBatch(T data, int size) {
        this.data = data;
        this.size = size;
    }

    public T get() {
        return data;
    }

    @Override
    public int size() {
        return size;
    }
}