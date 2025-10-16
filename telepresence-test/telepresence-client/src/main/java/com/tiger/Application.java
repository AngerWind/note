package com.tiger;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {

        String encodedUrl = URLEncoder.encode("/dashboard/index.html#/out/view/default/aidc_overview", StandardCharsets.UTF_8);
        URI uri = UriComponentsBuilder.fromHttpUrl("http://localhost:8080")
                .queryParam("url", encodedUrl)
                .build(true)
                .toUri();
        System.out.println("After build: " + uri);

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
