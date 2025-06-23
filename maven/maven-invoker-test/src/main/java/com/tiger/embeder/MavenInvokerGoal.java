package com.tiger.embeder;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.LoggerContext;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.slf4j.LoggerFactory;


public interface MavenInvokerGoal<T> {

    String getGoal();

    void collectResult();

    void runBefore();

    T getResult();
}