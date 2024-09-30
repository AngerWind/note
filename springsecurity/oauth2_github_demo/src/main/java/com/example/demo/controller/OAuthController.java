package com.example.demo.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import java.lang.reflect.InvocationTargetException;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jdk.jfr.DataAmount;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.commons.beanutils.BeanUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/5/15
 * @description
 */
@Controller
public class OAuthController {

    private String clientId= "Ov23liivMu7uKB6H4nnB";
    private String clientSecret = "0a78500b7d76f51f61dea3498c45a91170422cb7";
    // 这个链接必须是注册应用时填写的回调地址, 否则会报错, 不确定能不能添加queryString
    private String redirectUri = "http://localhost:8080/callback";

    public static final String accessTokenUrl = "https://github.com/login/oauth/access_token";
    public static final HttpMethod accessTokenMethod =  HttpMethod.POST;

    public static final String userInfoUrl = "https://api.github.com/user";
    public static final HttpMethod userInfoMethod = HttpMethod.GET;

    RestTemplate restTemplate;

    @PostConstruct
    public void init() {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        // 配置代理服务器
        Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress("127.0.0.1", 7890));
        requestFactory.setProxy(proxy);
        restTemplate = new RestTemplate(requestFactory);
    }


    @GetMapping("/callback")
    public String githubCallback(@RequestParam("code") String code, @RequestParam("redirectPage") String redirectTo)
        throws  JsonProcessingException {

        ResponseEntity<Map> response = requestForAccessToken(code);
        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            Map body = response.getBody();
            // todo accessToken需要保存到数据库
            String accessToken = (String)body.get("access_token");
            String scope = (String)body.get("scope");
            String tokenType = (String) body.get("token_type");

            // 使用access token获取用户信息
            ResponseEntity<Map<String, Object>> userResponse = requestForUserInfo(accessToken);
            if (userResponse.getStatusCode() == HttpStatus.OK && userResponse.getBody() != null) {
                Map<String, Object> userInfo = userResponse.getBody();
                userInfo.forEach((key, value) -> System.out.println(key + ":" + value));
                // 跳转回原来的页面
                return "redirect:" + redirectTo;
            } else {
                throw new RuntimeException("获取用户信息失败");
            }
        } else {
            throw new RuntimeException("获取access token失败");
        }

    }
    
    private ResponseEntity<Map> requestForAccessToken(String code) {
        // 需要在url上携带这四个参数
        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(accessTokenUrl)
            .queryParam("client_id", clientId)
            .queryParam("client_secret", clientSecret)
            .queryParam("code", code)
            .queryParam("redirect_uri", redirectUri);

        // 告诉github返回json格式的数据
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));
        HttpEntity<String> entity = new HttpEntity<>(headers);

        // 发送请求
        return restTemplate.exchange(builder.toUriString(), accessTokenMethod, entity, Map.class);
    }

    private ResponseEntity<Map<String, Object>> requestForUserInfo(String accessToken) {
        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(userInfoUrl);

        // 告诉github返回json格式的数据
        HttpHeaders headers = new HttpHeaders();
        // 将access token 放在请求头中
        headers.add("Authorization", "Bearer " + accessToken);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        // 发送请求
        return restTemplate.exchange(builder.toUriString(), userInfoMethod, entity, new ParameterizedTypeReference<Map<String, Object>>() {});
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class GitHubUser {
        private String login;
        private Long id;
        private String nodeId;
        private String avatarUrl;
        private String gravatarId;
        private String url;
        private String htmlUrl;
        private String followersUrl;
        private String followingUrl;
        private String gistsUrl;
        private String starredUrl;
        private String subscriptionsUrl;
        private String organizationsUrl;
        private String reposUrl;
        private String eventsUrl;
        private String receivedEventsUrl;
        private String type;
        private Boolean siteAdmin;
        private String name;
        private String company;
        private String blog;
        private String location;
        private String email;
        private String hireable;
        private String bio;
        private String twitterUsername;
        private Integer publicRepos;
        private Integer publicGists;
        private Integer followers;
        private Integer following;
        private String createdAt;
        private String updatedAt;
    }
}
