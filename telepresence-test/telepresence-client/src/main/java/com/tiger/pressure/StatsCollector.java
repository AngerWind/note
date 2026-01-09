package com.tiger.pressure;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.LongAdder;

public class StatsCollector {

    // 统计总的成功 / 失败次数
    private final AtomicLong totalSuccess = new AtomicLong();
    private final AtomicLong totalFailure = new AtomicLong();

    // 统计每个任务的耗时
    private final List<Long> latencies = Collections.synchronizedList(new ArrayList<>());

    // 用于当前的这个定时周期中, 计算任务的成功 / 失败次数
    private final LongAdder secondSuccess = new LongAdder();
    private final LongAdder secondFailure = new LongAdder();

    // 计算任务的平均耗时
    private final AtomicLong latencySum = new AtomicLong();

    // 计算任务的最大 / 最小耗时
    private final AtomicLong maxLatency = new AtomicLong();
    private final AtomicLong minLatency = new AtomicLong(Long.MAX_VALUE);


    // 定时输出统计信息
    private final ScheduledExecutorService reporter = Executors.newSingleThreadScheduledExecutor();


    private final int printIntervalMs ;

    public StatsCollector(int printIntervalMs) {
        this.printIntervalMs = printIntervalMs;

        // 启动实时 QPS 输出，每秒一次
        reporter.scheduleAtFixedRate(this::reportCurrentSecond, 1, printIntervalMs, TimeUnit.MILLISECONDS);
    }

    /** worker 调用，记录一次 send 的耗时和 SendResult */
    public void record(long costMs, SendResult result) {
        totalSuccess.addAndGet(result.getSuccessCount());
        totalFailure.addAndGet(result.getFailureCount());

        secondSuccess.add(result.getSuccessCount());
        secondFailure.add(result.getFailureCount());

        latencies.add(costMs);
        latencySum.addAndGet(costMs);
        maxLatency.accumulateAndGet(costMs, Math::max);
        minLatency.accumulateAndGet(costMs, Math::min);
    }

    /** 每秒输出一次 QPS / 平均延迟 */
    private void reportCurrentSecond() {
        long suc = secondSuccess.sumThenReset();
        long fail = secondFailure.sumThenReset();
        long total = suc + fail;

        long count;
        long avgLatency;
        synchronized (latencies) {
            count = latencies.size();
            avgLatency = count == 0 ? 0 : latencySum.get() / count;
        }

        System.out.printf("[实时] QPS: %d, 总共: %d, 成功: %d, 失败: %d, avg latency(ms): %d\n",
                suc * 1000 / printIntervalMs, total, suc, fail, avgLatency);
    }

    /** 输出最终统计结果 */
    public void printFinal(double totalSeconds, int threads) {
        reporter.shutdownNow(); // 停止实时输出

        List<Long> snapshot;
        synchronized (latencies) {
            snapshot = new ArrayList<>(latencies);
        }
        snapshot.sort(Long::compareTo);

        long count = snapshot.size();
        long avgLatency = count == 0 ? 0 : latencySum.get() / count;
        long p95 = snapshot.isEmpty() ? 0 : snapshot.get((int) (count * 0.95));
        long p99 = snapshot.isEmpty() ? 0 : snapshot.get((int) (count * 0.99));

        System.out.println("\n========== Pressure Test Result ==========");
        System.out.println("Threads              : " + threads);
        System.out.println("Total time (s)       : " + String.format("%.2f", totalSeconds));
        System.out.println("Total                : " + (totalSuccess.get() + totalFailure.get()));
        System.out.println("Total success        : " + totalSuccess.get());
        System.out.println("Total failure        : " + totalFailure.get());
        System.out.println("Throughput (QPS)     : " +
                String.format("%.2f", totalSuccess.get() / totalSeconds));
        System.out.println("Avg latency (ms)     : " + avgLatency);
        System.out.println("Min latency (ms)     : " + minLatency.get());
        System.out.println("Max latency (ms)     : " + maxLatency.get());
        System.out.println("P95 latency (ms)     : " + p95);
        System.out.println("P99 latency (ms)     : " + p99);
        System.out.println("==========================================");
    }
}