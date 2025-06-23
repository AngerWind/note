package com.tiger.embeder;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.LoggerContext;
import lombok.Getter;
import org.slf4j.LoggerFactory;


@Getter
public abstract class MavenInvokerBaseGoal<T> implements MavenInvokerGoal<T> {
    protected final String goal;
    protected T result;

    public MavenInvokerBaseGoal(String goal) {
        this.goal = goal;
    }

}