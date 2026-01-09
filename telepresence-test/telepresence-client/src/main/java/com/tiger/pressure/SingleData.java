package com.tiger.pressure;

public class SingleData<T> implements DataSizeAware {

    private final T data;

    public SingleData(T data) {
        this.data = data;
    }

    public T get() {
        return data;
    }

    @Override
    public int size() {
        return 1;
    }
}
