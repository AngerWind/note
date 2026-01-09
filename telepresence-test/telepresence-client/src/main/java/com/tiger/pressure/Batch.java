package com.tiger.pressure;

import java.util.List;

public class Batch<T> implements DataSizeAware {

    private final List<T> data;

    public Batch(List<T> data) {
        this.data = data;
    }

    public List<T> getData() {
        return data;
    }

    @Override
    public int size() {
        return data.size();
    }
}
