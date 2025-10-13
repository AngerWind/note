package com.tiger;


import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@Slf4j
@RestController
@RequestMapping("/remoteHello")
public class HelloRemoteController {


    @Autowired
    private HelloClient helloClient;

    @GetMapping
    public String hello() {

        String appEnv = System.getProperty("APP_ENV");
        if (appEnv == null || appEnv.isEmpty()) {
            appEnv = "default";
        }
        return String.format("client env: %s, server env: %s", helloClient.hello(), appEnv);
    }
}
