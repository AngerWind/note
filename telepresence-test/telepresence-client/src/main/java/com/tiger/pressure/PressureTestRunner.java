package com.tiger.pressure;

import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

public class PressureTestRunner<T extends DataSizeAware> {

    private final int threads;
    private final int totalTasks;
    private final PressureTask<T> task;

    private final BlockingQueue<T> queue = new LinkedBlockingQueue<>();

    // ===== 统计 =====
    private final AtomicLong success = new AtomicLong();
    private final AtomicLong failure = new AtomicLong();

    private final AtomicLong latencySumMs = new AtomicLong();
    private final AtomicLong maxLatency = new AtomicLong();
    private final AtomicLong minLatency = new AtomicLong(Long.MAX_VALUE);

    private final List<Long> latencies =
        Collections.synchronizedList(new ArrayList<>());


    private int dataBuildThreads;

    public PressureTestRunner(int threads, int totalTasks, int dataBuildThreads, PressureTask<T> task) {
        this.threads = threads;
        this.totalTasks = totalTasks;
        this.task = task;
        this.dataBuildThreads = dataBuildThreads;
    }

    /* ================== 主入口 ================== */
    public void run() throws Exception {

        ExecutorService pool = Executors.newFixedThreadPool(threads);


        System.out.println("开始构造数据");
        /* 1️⃣ 构造数据（不计时） */
        AtomicInteger buildCounter = new AtomicInteger(0);

        ExecutorService buildPool = Executors.newFixedThreadPool(dataBuildThreads);

        for (int i = 0; i < dataBuildThreads; i++) {
            buildPool.submit(() -> {
                while (true) {
                    int idx = buildCounter.getAndIncrement();

                    System.out.println("开始构造第 " + idx + " 批数据");

                    if (idx >= totalTasks){
                        break;
                    }

                    try {
                        T data = task.buildData(idx);
                        queue.put(data); // 阻塞直到队列有空间

                    } catch (Exception e) {
                        System.out.println(e.getMessage());
                    }
                }
            });
        }

        buildPool.shutdown();
        boolean termination = buildPool.awaitTermination(1, TimeUnit.HOURS);
        if (!termination) {
            throw new RuntimeException("数据构造超时");
        }

        System.out.println("构造数据成功");

        task.init();

        /* 2️⃣ warmup（不计时） */
        task.warmup(pool);

        /* 3️⃣ 压测开始 */
        System.out.println("开始发送数据");
        CountDownLatch latch = new CountDownLatch(threads);
        long startTime = System.nanoTime();

        for (int i = 0; i < threads; i++) {
            pool.submit(() -> worker(latch));
        }

        latch.await();
        long endTime = System.nanoTime();

        task.shutdown();

        pool.shutdown();

        /* 4️⃣ 输出结果 */
        statsCollector.printFinal((endTime - startTime) / 1_000_000_000.0, threads);
    }

    private final StatsCollector statsCollector = new StatsCollector(5000);

    /* ================== worker ================== */
    private void worker(CountDownLatch latch) {
        try {
            while (true) {
                T data = queue.poll();
                if (data == null) return;

                long start = System.nanoTime();
                SendResult result;
                try {
                    result = task.send(data);
                } catch (Exception e) {
                    // 全部失败
                    result = new SendResult(0, data.size());
                }
                long costMs = (System.nanoTime() - start) / 1_000_000;

                // 延迟统计（一次 send 记一次）
                latencySumMs.addAndGet(costMs);
                latencies.add(costMs);
                maxLatency.accumulateAndGet(costMs, Math::max);
                minLatency.accumulateAndGet(costMs, Math::min);

                // 成功 / 失败按条数
                success.addAndGet(result.getSuccessCount());
                failure.addAndGet(result.getFailureCount());
            }
        } finally {
            latch.countDown();
        }
    }


    /* ================== 统计输出 ================== */
    private void printResult(double seconds) {

        List<Long> snapshot;
        synchronized (latencies) {
            snapshot = new ArrayList<>(latencies);
        }
        snapshot.sort(Long::compareTo);

        long count = snapshot.size();
        long avg = count == 0 ? 0 : latencySumMs.get() / count;
        long p95 = snapshot.get((int) (count * 0.95));
        long p99 = snapshot.get((int) (count * 0.99));

        System.out.println("\n========== Pressure Test Result ==========");
        System.out.println("Threads            : " + threads);
        System.out.println("Total tasks        : " + totalTasks);
        System.out.println("Success data count : " + success.get());
        System.out.println("Failure data count : " + failure.get());
        System.out.println("Total time (s)     : " + String.format("%.2f", seconds));
        System.out.println("Throughput (QPS)   : " +
            String.format("%.2f", success.get() / seconds));
        System.out.println("Avg latency (ms)   : " + avg);
        System.out.println("Min latency (ms)   : " + minLatency.get());
        System.out.println("Max latency (ms)   : " + maxLatency.get());
        System.out.println("P95 latency (ms)   : " + p95);
        System.out.println("P99 latency (ms)   : " + p99);
        System.out.println("==========================================");
    }
}
