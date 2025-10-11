package com.tiger;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Value("${url}")
    public String url;
    @Bean
    public HelloClient helloClient() {
        RestClient restClient = RestClient
                .builder()
                // 你可以在这里指定baseUrl, 也可以在@HttpExchange中指定, 也可以直接在@GetExchange中指定, 反正都是拼接字符串
                .baseUrl(url)
                .build();

        RestClientAdapter adapter = RestClientAdapter.create(restClient);
        HttpServiceProxyFactory factory = HttpServiceProxyFactory.builderFor(adapter).build();
        return factory.createClient(HelloClient.class);
    }

}
