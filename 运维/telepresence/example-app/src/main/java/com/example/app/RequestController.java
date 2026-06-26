package com.example.app;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@RestController
public class RequestController {

    private static final Logger log = LoggerFactory.getLogger(RequestController.class);

    @GetMapping("/echo")
    public ResponseEntity<Map<String, Object>> echoGet(HttpServletRequest request) {
        logRequest("GET", request, null);
        return ResponseEntity.ok(buildResponse("GET", request, null));
    }

    @PostMapping("/echo")
    public ResponseEntity<Map<String, Object>> echoPost(HttpServletRequest request, @RequestBody(required = false) String body) {
        logRequest("POST", request, body);
        return ResponseEntity.ok(buildResponse("POST", request, body));
    }

    @RequestMapping(value = "/echo", method = {RequestMethod.PUT, RequestMethod.PATCH, RequestMethod.DELETE})
    public ResponseEntity<Map<String, Object>> echoOther(HttpServletRequest request, @RequestBody(required = false) String body) {
        String method = request.getMethod();
        logRequest(method, request, body);
        return ResponseEntity.ok(buildResponse(method, request, body));
    }

    private void logRequest(String method, HttpServletRequest request, String body) {
        log.info("=== {} Request ===", method);
        log.info("Path: {}", request.getRequestURI());

        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            log.info("Param: {} = {}", name, request.getParameter(name));
        }

        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String name = headerNames.nextElement();
            log.info("Header: {} = {}", name, request.getHeader(name));
        }

        if (body != null) {
            log.info("Body: {}", body);
        }

        log.info("Env APP_NAME: {}", System.getenv("APP_NAME"));
        log.info("Env APP_ENV: {}", System.getenv("APP_ENV"));
        log.info("Env APP_PORT: {}", System.getenv("APP_PORT"));
    }

    private Map<String, Object> buildResponse(String method, HttpServletRequest request, String body) {
        Map<String, Object> response = new HashMap<>();
        response.put("method", method);
        response.put("path", request.getRequestURI());
        response.put("queryParams", getParamsMap(request));
        response.put("headers", getHeadersMap(request));
        if (body != null) {
            response.put("body", body);
        }
        response.put("env", Map.of(
            "APP_NAME", System.getenv("APP_NAME") != null ? System.getenv("APP_NAME") : "not set",
            "APP_ENV", System.getenv("APP_ENV") != null ? System.getenv("APP_ENV") : "not set",
            "APP_PORT", System.getenv("APP_PORT") != null ? System.getenv("APP_PORT") : "not set"
        ));
        return response;
    }

    private Map<String, String> getParamsMap(HttpServletRequest request) {
        Map<String, String> params = new HashMap<>();
        Enumeration<String> names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            params.put(name, request.getParameter(name));
        }
        return params;
    }

    private Map<String, String> getHeadersMap(HttpServletRequest request) {
        Map<String, String> headers = new HashMap<>();
        Enumeration<String> names = request.getHeaderNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            headers.put(name, request.getHeader(name));
        }
        return headers;
    }
}
