package com.tiger.pressure;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

public class OprationLogBuilder {
    private static final List<String> uuidList = Collections.synchronizedList(new ArrayList<>());
    // private static final Random random = new Random();
    private static final SplittableRandom random = new SplittableRandom();
    private static final ObjectMapper objectMapper = new ObjectMapper();

    static {
        // 初始化100个UUID
        for (int i = 0; i < 100; i++) {
            uuidList.add(UUID.randomUUID().toString());
        }
    }

    public static <T> T getRandom(List<T> list) {
        if (list == null || list.isEmpty()) {
            return null;
        }
        int index = ThreadLocalRandom.current().nextInt(list.size());
        return list.get(index);
    }

    public static OprationLog createOprationLog() {
        OprationLog log = new OprationLog();

        // 设置字段值
        log.setLogAccount(generateRandomString(64)); // 最大64位字符
        log.setLogAccountId(UUID.randomUUID().toString()); // uuid字符串

        log.setOperateAccount(generateRandomString(64)); // 最大64位字符
        log.setOperateAccountId(getRandom(uuidList)); // uuid字符串

        log.setOperatePlatform(generateRandomString(64)); // 最大64位字符
        log.setServiceName(generateRandomString(64)); // 最大64位字符
        log.setServiceNameAlias(generateRandomString(64)); // 最大64位字符
        log.setOperateType(generateRandomString(64)); // 最大64位字符
        log.setOperateObject(generateRandomString(64)); // 最大64位字符

        // 设置操作时间，格式：2025-12-19 00:25:41
        LocalDateTime localDateTime = LocalDateTimeGenerator.next();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        log.setOperateTime(localDateTime.format(formatter));

        log.setLogIp(generateRandomIp()); // IP地址

        // operateResult为"成功"或"失败"
        log.setOperateResult(random.nextBoolean() ? "成功" : "失败");

        // errorReason为随机json对象转换的字符串
        log.setErrorReason(generateRandomJson());

        // logLevel为1到10的字符串
        log.setLogLevel(String.valueOf(random.nextInt(10) + 1));

        // operateDesc为随机json对象转换的字符串
        log.setOperateDesc(generateRandomJson());

        log.setModuleName(generateRandomString(64)); // 64位字符串
        log.setTraceId(UUID.randomUUID().toString()); // uuid字符串
        log.setParentId(UUID.randomUUID().toString()); // uuid字符串
        log.setParentName(generateRandomString(64)); // 最大64位字符

        // param为随机json对象转换的字符串
        log.setParam(generateRandomJson());

        log.setRequestId(UUID.randomUUID().toString()); // uuid字符串
        log.setProductType(generateRandomString(64)); // 最大64位字符

        // 注意：类中没有channel字段，已从要求中移除

        // result为随机json对象转换的字符串
        log.setResult(generateRandomJson());

        log.setRegionId(generateRandomString(64)); // 最大64位字符

        return log;
    }

    /**
     * 生成指定长度的随机字符串
     */
    private static String generateRandomString(int maxLength) {
        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder();

        // 随机长度，不超过maxLength
        int length = random.nextInt(maxLength) + 1;

        for (int i = 0; i < length; i++) {
            int index = random.nextInt(characters.length());
            sb.append(characters.charAt(index));
        }

        return sb.toString();
    }

    /**
     * 生成随机IP地址
     */
    private static String generateRandomIp() {
        return random.nextInt(256) + "." +
                random.nextInt(256) + "." +
                random.nextInt(256) + "." +
                random.nextInt(256);
    }

    /**
     * 生成随机JSON对象字符串
     */
    private static String generateRandomJson() {
        Map<String, Object> jsonMap = new HashMap<>();

        // 添加一些随机字段
        jsonMap.put("id", UUID.randomUUID().toString());
        jsonMap.put("timestamp", System.currentTimeMillis());
        jsonMap.put("status", random.nextBoolean() ? "active" : "inactive");
        jsonMap.put("value", random.nextInt(1000));
        jsonMap.put("description", generateRandomString(32));

        try {
            return objectMapper.writeValueAsString(jsonMap);
        } catch (JsonProcessingException e) {
            // 如果序列化失败，返回一个简单的JSON字符串
            return "{\"error\": \"Failed to generate JSON\", \"timestamp\": " + System.currentTimeMillis() + "}";
        }
    }

    public static void main(String[] args) {
        // 创建OprationLog对象
        OprationLog log = createOprationLog();

        // 打印对象信息
        System.out.println(log);
    }
}