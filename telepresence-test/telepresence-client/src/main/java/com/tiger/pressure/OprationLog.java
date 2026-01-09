package com.tiger.pressure;


import lombok.Data;

@Data
public class OprationLog {
    private String logAccount;
    private String logAccountId;
    private String operateAccount;
    private String operateAccountId;
    private String operatePlatform;
    private String serviceName;
    private String serviceNameAlias;
    private String operateType;
    private String operateObject;
    private String operateTime;
    private String logIp;
    private String operateResult;
    private String errorReason;
    private String logLevel;

    private String operateDesc;
    private String moduleName;
    private String traceId;

    private String parentId;
    private String parentName;
    private String param;
    private String requestId;
    private String productType;
    private String result;
    private String regionId;
}