FROM maven:3.8-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests -B

FROM eclipse-temurin:11-jre
WORKDIR /app
COPY --from=build /app/target/example-app-1.0.0.jar app.jar

ENV APP_NAME=example-app
ENV APP_ENV=development
ENV APP_PORT=8080

EXPOSE ${APP_PORT}

ENTRYPOINT ["java", "-jar", "app.jar"]
