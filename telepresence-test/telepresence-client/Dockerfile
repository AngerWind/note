# ==========================
# 🧱 第一阶段：构建阶段（使用 Maven 构建 jar 包）
# ==========================
FROM maven:3.9.9-eclipse-temurin-17 AS builder

# 设置工作目录
WORKDIR /app

# 先拷贝 pom.xml 并下载依赖，加快后续构建速度（利用缓存）
COPY pom.xml .
RUN mvn -B dependency:go-offline

# 拷贝源码并构建可执行 jar
COPY src ./src
RUN mvn -B clean package -DskipTests

# ==========================
# 🚀 第二阶段：运行阶段（只包含运行环境）
# ==========================
FROM eclipse-temurin:17-jdk-alpine

# 设置工作目录
WORKDIR /app

# 从构建阶段复制 jar 包到运行环境
COPY --from=builder /app/target/*.jar app.jar

# 暴露应用端口
EXPOSE 8088

# 启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
