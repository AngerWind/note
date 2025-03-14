package com.example.graalvm.springboot.demo.aop;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;


@Aspect
@Component
@Slf4j
public class HelloAopProxy {

    @Pointcut("execution(* com.example.graalvm.springboot.demo.controller.HelloController.hello(..))")
    public void pointcut() {

    }

    @Around("pointcut()")
    public Object around(ProceedingJoinPoint pjp) {
        System.out.println("before");
        try {
            Object proceed = pjp.proceed();
            System.out.println("after");
            return proceed;
        } catch (Throwable t) {
            throw new RuntimeException(t);
        }

    }
}
