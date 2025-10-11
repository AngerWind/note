package com.tiger;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;

@HttpExchange("/hello")
public interface HelloClient {

    @GetExchange
    String hello() ;
}
