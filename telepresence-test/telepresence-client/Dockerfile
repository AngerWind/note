# ===== 构建阶段 =====
FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /app

# 仅复制必要的文件以利用缓存
COPY pom.xml .
COPY ./telepresence-client ./telepresence-client

# 打包 Spring Boot 应用
RUN mvn clean package spring-boot:repackage -DskipTests -f ./telepresence-client/pom.xml

# ===== 运行阶段 =====
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# 拷贝构建产物
COPY --from=builder /app/telepresence-client/target/*.jar app.jar

# 设置环境变量
ENV APP_ENV=dev

# 暴露端口
EXPOSE 8088

# 启动命令
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"]
