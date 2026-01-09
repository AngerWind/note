package com.tiger.pressure;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.util.EntityUtils;


import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;


public class OpenobservePressureTestRunner extends PressureTestRunner<SingleDataBatch<String>> {

    public static final int THREADS = 8;
    static int BATCH_SIZE = 5000;
    static int TOTAL_LOGS = 1_000_000;
    static int totalBatches = TOTAL_LOGS / BATCH_SIZE;

    public OpenobservePressureTestRunner() {
        super(THREADS, totalBatches, THREADS * 4, new OpenobservePressureTask());
    }


    public static class OpenobservePressureTask implements PressureTask<SingleDataBatch<String>> {

        //        static final String OPENOBSERVE_URL = "http://10.144.183.164:35080";
        static final String ORG = "380gyDDwcQkD3EzI0x6TWdMQYwi";
        static String STREAM = "stream128";

//        static final String USERNAME = "root@example.com";
//        static final String PASSWORD = "Complexpass#123";

        static String OPENOBSERVE_URL = "https://api.openobserve.ai";
        static String USERNAME = "ys.shenqitai@h3c.com";
        static String PASSWORD = "VHjOpjqGc0nxftHL";

        static final int CONNECT_TIMEOUT_MS = 3000;
        static final int SOCKET_TIMEOUT_MS = 10_000;

        static final String INGEST_URL =
                OPENOBSERVE_URL + "/api/" + ORG + "/" + STREAM + "/_json";

        CloseableHttpClient httpClient;

        static final String basicAuth = "Basic eXMuc2hlbnFpdGFpQGgzYy5jb206VkhqT3BqcUdjMG54ZnRITA==";

        @Override
        public SingleDataBatch<String> buildData(int index) {
            String data = buildJson1(index, BATCH_SIZE);
            return new SingleDataBatch<>(data, BATCH_SIZE);
        }

        @Override
        public SendResult send(SingleDataBatch<String> data) throws Exception {
            HttpPost post = new HttpPost(INGEST_URL);
            post.setHeader("Content-Type", "application/json");
            post.setHeader("Authorization", basicAuth);
            post.setEntity(new StringEntity(data.get(), StandardCharsets.UTF_8));


            try (CloseableHttpResponse response = httpClient.execute(post)) {

                int status = response.getStatusLine().getStatusCode();
                EntityUtils.consumeQuietly(response.getEntity());

                if (status == 200) {
                    return new SendResult(BATCH_SIZE, 0);
                } else {
                    return new SendResult(0, BATCH_SIZE);
                }


            } catch (Exception e) {
                return new SendResult(0, BATCH_SIZE);
            }
        }

        @Override
        public void warmup(ExecutorService executorService) throws Exception {
            // 初始化http连接池
            ArrayList<Future<?>> futures = new ArrayList<>(THREADS);
            for (int i = 0; i < THREADS; i++) {
                Future<?> future = executorService.submit(() -> {
                    try {
                        HttpPost post = new HttpPost(INGEST_URL);
                        post.setHeader("Content-Type", "application/json");
                        post.setHeader("Authorization", basicAuth);
                        post.setEntity(new StringEntity("[{}]", StandardCharsets.UTF_8));
                        CloseableHttpResponse resp = httpClient.execute(post);
                        EntityUtils.consumeQuietly(resp.getEntity());
                        resp.close();
                    } catch (Exception e) {
                    }
                });
                futures.add(future);
            }

            for (Future<?> future : futures) {
                try {
                    future.get();
                } catch (Exception e) {
                }
            }

        }


        @Override
        public void shutdown() throws Exception {
            httpClient.close();
        }

        @Override
        public void init() throws Exception {
            PoolingHttpClientConnectionManager cm =
                    new PoolingHttpClientConnectionManager();

            cm.setMaxTotal(THREADS * 2);
            cm.setDefaultMaxPerRoute(THREADS);

            RequestConfig config = RequestConfig.custom()
                    .setConnectTimeout(CONNECT_TIMEOUT_MS)
                    .setSocketTimeout(SOCKET_TIMEOUT_MS)
                    .build();

            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(
                    null,
                    new TrustManager[]{
                            new X509TrustManager() {
                                public void checkClientTrusted(X509Certificate[] xcs, String s) {}
                                public void checkServerTrusted(X509Certificate[] xcs, String s) {}
                                public X509Certificate[] getAcceptedIssuers() {
                                    return new X509Certificate[0];
                                }
                            }
                    },
                    new SecureRandom()
            );

            httpClient = HttpClients.custom()
                    .setConnectionManager(cm)
                    .setDefaultRequestConfig(config)
                    .setSSLContext(sslContext)
                    .build();
        }


        static String buildJson(int batchId, int batchSize) {
            long ts = System.currentTimeMillis();
            StringBuilder sb = new StringBuilder(1024);
            sb.append("[");

            for (int i = 0; i < batchSize; i++) {
                sb.append("{")
                        .append("\"timestamp\":").append(ts).append(",")
                        .append("\"level\":\"INFO\",")
                        .append("\"service\":\"pressure-test\",")
                        .append("\"thread\":\"").append(Thread.currentThread().getName()).append("\",")
                        .append("\"batchId\":").append(batchId).append(",")
                        .append("\"index\":").append(i).append(",")
                        .append("\"message\":\"openobserve load test\"")
                        .append("}");
                if (i < batchSize - 1) {
                    sb.append(",");
                }
            }

            sb.append("]");
            return sb.toString();
        }

        public static final ObjectMapper mapper = new ObjectMapper()
                .registerModule(new JavaTimeModule());

        static String buildJson1(int batchId, int batchSize) {
            List<Object[]> batchData = generateBatchData(batchSize);
            List<Map<String, Object>> rows = new ArrayList<>();

            for (Object[] row : batchData) {
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("log_account", row[0]);
                // map.put("log_account_id", row[1]);
                map.put("operate_account", row[2]);
                map.put("operate_account_id", row[3]);
                map.put("operate_platform", row[4]);
                // map.put("service_name", row[5]);
                map.put("service_name_alias", row[6]);
                map.put("operate_type", row[7]);
                map.put("operate_object", row[8]);

                map.put("operate_time", ((LocalDateTime) row[9]).format(TIMESTAMP_FORMATTER));

                map.put("log_ip", row[10]);
                map.put("operate_result", row[11]);
                // map.put("error_reason", row[12]);
                // map.put("log_level", row[13]);
                map.put("operate_desc", row[14]);
                map.put("module_name", row[15]);
                map.put("trace_id", row[16]);
                map.put("parent_id", row[17]);
                map.put("parent_name", row[18]);
                map.put("param", row[19]);
                map.put("request_id", row[20]);
                map.put("product_type", row[21]);
                map.put("result", row[22]);
                map.put("region_id", row[23]);

//                 map.put("_timestamp", String.valueOf(TimeGenerator.nextMicro()));


                long spendTimeMs = SpendTimeGenerator.next();
                map.put("spend_time", spendTimeMs);

                String log_level = LogLevelStringGenerator.next();
                map.put("log_level_without_partition", log_level);
                map.put("log_level_with_kv_partition", log_level);
                map.put("log_level_with_kv_partition_and_bloom", log_level);

                String serviceName = ServiceNameGenerator.next();
                map.put("service_name_without_partition", serviceName);
                map.put("service_name_with_kv_partition", serviceName);
                map.put("service_name_with_kv_partition_and_bloom", serviceName);

                String uuid = UUID.randomUUID().toString();
                map.put("log_account_id_without_partition", uuid);
                map.put("log_account_id_with_hash_partition_and_bloom", uuid);
                map.put("log_account_id_with_hash_partition_and_secondary", uuid);

                String errorReason = ErrorReasonGenerator.next();
                map.put("error_reason_without_partition", errorReason);
                map.put("error_reason_with_prefix_partition", errorReason);
                map.put("error_reason_with_prefix_partition_and_full_text_search", errorReason);
                map.put("error_reason_with_full_text_search", errorReason);
                rows.add(map);
            }
            String jsonBody = null;
            try {
                jsonBody = mapper.writeValueAsString(rows);
            } catch (Exception e) {
                e.printStackTrace();
                System.exit(1);
            }
            return jsonBody;
        }


    }


    public static void main(String[] args) throws Exception {
        for (int i = 0; i < 1; i++) {
            OpenobservePressureTestRunner runner = new OpenobservePressureTestRunner();
            runner.run();

            Thread.sleep(1500);
        }

        // OpenobservePressureTestRunner runner = new OpenobservePressureTestRunner();
        // runner.run();
    }


    public static List<Object[]> generateBatchData(int size) {
        List<Object[]> batch = new ArrayList<>(size);
        for (int i = 0; i < size; i++) {
            batch.add(generateRow());
        }
        return batch;
    }

    private static Object[] generateRow() {

        OprationLog log = OprationLogBuilder.createOprationLog();

        return new Object[]{
                log.getLogAccount(),
                log.getLogAccountId(), // uuid
                log.getOperateAccount(),
                log.getOperateAccountId(),
                log.getOperatePlatform(),
                log.getServiceName(), // todo, 使用20个随机值
                log.getServiceNameAlias(),
                log.getOperateType(),
                log.getOperateObject(),
                LocalDateTime.parse(log.getOperateTime(), TIMESTAMP_FORMATTER),
                log.getLogIp(),
                log.getOperateResult(),
                log.getErrorReason(), // todo 全文索引
                log.getLogLevel(), // todo 使用5个随机值
                log.getOperateDesc(),
                log.getModuleName(),
                log.getTraceId(),
                log.getParentId(),
                log.getParentName(),
                log.getParam(),
                log.getRequestId(),
                log.getProductType(),
                log.getResult(),
                log.getRegionId()
        };
    }

    public static final DateTimeFormatter TIMESTAMP_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");


}