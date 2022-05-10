-- welab_skyeye.dag_api definition

CREATE TABLE `dag_api` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `api_code` varchar(50) NOT NULL COMMENT '唯一编码',
  `name` varchar(100) NOT NULL COMMENT '名称',
  `action` varchar(100) NOT NULL COMMENT '执行动作',
  `parameters` longtext COMMENT '参数JSON形式动态参数${xx}表示',
  `type` varchar(50) DEFAULT NULL COMMENT '类型:1:HTTP,2:dubbo,3:mq,4:本地shell,0:其它',
  `user_id` bigint(20) DEFAULT NULL COMMENT '所属用户',
  `release_state` tinyint(4) NOT NULL COMMENT '状态：0 未上线，1 上线',
  `desc` longtext COMMENT '描述',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `flag` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否可用  1 可用,0 不可用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_global_uniq_str` (`api_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API定义表';


-- welab_skyeye.dag_api_auth definition

CREATE TABLE `dag_api_auth` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `auth_code` varchar(50) NOT NULL COMMENT '唯一编码',
  `secretkey` varchar(50) NOT NULL COMMENT '金乌安全授权码',
  `name` varchar(100) NOT NULL COMMENT '名称',
  `desc` longtext COMMENT '描述',
  `begin_date` datetime DEFAULT NULL COMMENT '开始时间',
  `end_date` datetime DEFAULT NULL COMMENT '结束时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `flag` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否可用  1 可用,0 不可用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_global_uniq_str` (`auth_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API权限表';


-- welab_skyeye.dag_api_auth_ref definition

CREATE TABLE `dag_api_auth_ref` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `api_code` varchar(50) NOT NULL COMMENT '唯一编码',
  `auth_code` varchar(50) NOT NULL COMMENT '唯一字符串',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- welab_skyeye.dag_api_invoke definition

CREATE TABLE `dag_api_invoke` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `api_code` varchar(50) NOT NULL COMMENT 'dag_api外键',
  `invoke_in` longtext COMMENT '入参JSON形式',
  `invoke_out` longtext COMMENT '出参JSON形式',
  `parameters` longtext COMMENT '参数JSON形式动态参数${xx}表示',
  `invoke_user_id` bigint(20) DEFAULT NULL COMMENT '所属用户',
  `desc` longtext COMMENT '描述',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `flag` tinyint(2) NOT NULL DEFAULT '1' COMMENT '是否可用  1 可用,0 不可用',
  PRIMARY KEY (`id`),
  KEY `dag_api_code` (`api_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API调用执行表';


-- welab_skyeye.dag_api_task definition

CREATE TABLE `dag_api_task` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `task_code` varchar(50) NOT NULL COMMENT '唯一字符串',
  `name` varchar(100) NOT NULL COMMENT '项目名称',
  `action` varchar(100) NOT NULL COMMENT '执行动作',
  `method` varchar(20) DEFAULT NULL COMMENT '执行方法 GET,POST,PUT,DELETE,',
  `parameters` longtext COMMENT '参数JSON形式动态参数${xx}表示',
  `type` varchar(20) DEFAULT NULL COMMENT '类型:1:service,2:control,0:其它',
  `desc` varchar(200) DEFAULT NULL COMMENT '项目描述',
  `user_id` bigint(20) DEFAULT NULL COMMENT '所属用户',
  `flag` tinyint(2) NOT NULL DEFAULT '1' COMMENT '是否可用  1 是,0 否',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `AK_task_code_unique` (`task_code`),
  KEY `user_id_index` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API 调用模板';


-- welab_skyeye.dag_api_task_ref definition

CREATE TABLE `dag_api_task_ref` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `api_code` varchar(50) NOT NULL COMMENT '唯一编码',
  `task_code` varchar(50) NOT NULL COMMENT '唯一字符串',
  `order_no` int(11) NOT NULL DEFAULT '0' COMMENT '排序号',
  `is_sync` tinyint(2) NOT NULL DEFAULT '1' COMMENT '是否同步  1 是,0 否',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- welab_skyeye.dag_calendar definition

CREATE TABLE `dag_calendar` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '名称',
  `global_uniq_str` varchar(150) COLLATE utf8mb4_bin NOT NULL COMMENT '唯一字符串',
  `desc` longtext COLLATE utf8mb4_bin COMMENT '描述',
  `calendar_year` year(4) DEFAULT NULL COMMENT '日历年份',
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `release_state` tinyint(4) NOT NULL COMMENT '状态：0 未上线，1 上线',
  `worker_group_id` int(11) DEFAULT '-1' COMMENT '任务指定运行的worker分组',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `flag` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否可用  1 可用,0 不可用',
  `relation_calendar` varchar(150) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关联日历',
  `calendar_strategy` tinyint(4) DEFAULT NULL COMMENT '生成策略：0、节假日，1、按工作日，2、按非工作日，',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_global_uniq_str` (`global_uniq_str`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=382 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='日历主表';


-- welab_skyeye.dag_calendar_detail definition

CREATE TABLE `dag_calendar_detail` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '名称',
  `calendar_global_uniq_str` varchar(150) COLLATE utf8mb4_bin NOT NULL COMMENT '日历表关联键',
  `desc` longtext COLLATE utf8mb4_bin COMMENT '描述',
  `calendar_date` date NOT NULL COMMENT '日历日期',
  `is_workday` tinyint(4) NOT NULL COMMENT '是否工作日',
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `release_state` tinyint(4) NOT NULL COMMENT '状态：0 未上线，1 上线',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_global_uniq_str` (`calendar_global_uniq_str`)
) ENGINE=InnoDB AUTO_INCREMENT=23170 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='日历明细表';


-- welab_skyeye.dag_calendar_duty definition

CREATE TABLE `dag_calendar_duty` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '名称',
  `desc` longtext COLLATE utf8mb4_bin COMMENT '描述',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `release_state` tinyint(4) NOT NULL DEFAULT '1' COMMENT '上下线状态,0 未上线，1 上线',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `flag` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否可用  1 可用,0 不可用',
  `calendar_strategy` tinyint(4) NOT NULL COMMENT '0 按天轮值，1 按周轮值',
  `send_notify` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否发送值班提醒，0，否；1，是',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='值班表主表';


-- welab_skyeye.dag_calendar_guardian definition

CREATE TABLE `dag_calendar_guardian` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `guard_id` bigint(20) NOT NULL COMMENT '负责人ID',
  `guard_type` tinyint(4) NOT NULL COMMENT '0=用户，1=角色',
  `calendar_date` date NOT NULL COMMENT '日期',
  `duty_calendar_id` bigint(20) NOT NULL COMMENT '值班表id',
  `guard_name` varchar(100) NOT NULL COMMENT '负责人名称',
  PRIMARY KEY (`id`),
  KEY `idx_guard` (`guard_type`,`guard_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12227 DEFAULT CHARSET=utf8mb4 COMMENT='值班表-负责人映射表';


-- welab_skyeye.dag_command definition

CREATE TABLE `dag_command` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `command_type` tinyint(4) DEFAULT NULL COMMENT '命令类型：0 启动工作流,1 从当前节点开始执行,2 恢复被容错的工作流,3 恢复暂停流程,4 从失败节点开始执行,5 补数,6 调度,7 重跑,8 暂停,9 停止,10 恢复等待线程',
  `process_definition_id` int(11) DEFAULT NULL COMMENT '流程定义id',
  `command_param` mediumtext COLLATE utf8mb4_bin COMMENT '命令的参数（json格式）',
  `task_depend_type` tinyint(4) DEFAULT NULL COMMENT '节点依赖类型：0 当前节点,1 向前执行,2 向后执行',
  `failure_strategy` tinyint(4) DEFAULT '0' COMMENT '失败策略：0结束，1继续',
  `warning_type` tinyint(4) DEFAULT '0' COMMENT '告警类型：0 不发,1 流程成功发,2 流程失败发,3 成功失败都发',
  `warning_group_id` int(11) DEFAULT NULL COMMENT '告警组',
  `schedule_time` datetime DEFAULT NULL COMMENT '预期运行时间',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `executor_id` bigint(20) DEFAULT NULL COMMENT '执行用户id',
  `dependence` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '依赖字段',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `process_instance_priority` int(11) DEFAULT NULL COMMENT '流程实例优先级：0 Highest,1 High,2 Medium,3 Low,4 Lowest',
  `worker_group_id` int(11) DEFAULT '-1' COMMENT '任务指定运行的worker分组',
  `worker_group` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'worker group id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2341 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='escheduler执行命令行表';


-- welab_skyeye.dag_custom_param definition

CREATE TABLE `dag_custom_param` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '名称',
  `param_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '参数类型 ：  0 普通参数 ，1，全局参数',
  `value` varchar(1000) NOT NULL COMMENT '值',
  `data_type` int(11) NOT NULL DEFAULT '0' COMMENT '0 字符串 , 1 数值类型 , 2 布尔类, 3 时间类型, 4枚举类型, 5 浮点类型',
  `description` varchar(1000) DEFAULT NULL COMMENT '描述',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `release_state` tinyint(4) NOT NULL DEFAULT '1' COMMENT '参数状态：0 未上线 ， 1已上线',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;


-- welab_skyeye.dag_error_command definition

CREATE TABLE `dag_error_command` (
  `id` int(11) NOT NULL COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `command_type` tinyint(4) DEFAULT NULL COMMENT '命令类型：0 启动工作流,1 从当前节点开始执行,2 恢复被容错的工作流,3 恢复暂停流程,4 从失败节点开始执行,5 补数,6 调度,7 重跑,8 暂停,9 停止,10 恢复等待线程',
  `executor_id` int(11) DEFAULT NULL COMMENT '命令执行者',
  `process_definition_id` int(11) DEFAULT NULL COMMENT '流程定义id',
  `command_param` mediumtext COLLATE utf8mb4_bin COMMENT '命令的参数（json格式）',
  `task_depend_type` tinyint(4) DEFAULT NULL COMMENT '节点依赖类型',
  `failure_strategy` tinyint(4) DEFAULT '0' COMMENT '失败策略：0结束，1继续',
  `warning_type` tinyint(4) DEFAULT '0' COMMENT '告警类型',
  `warning_group_id` int(11) DEFAULT NULL COMMENT '告警组',
  `schedule_time` datetime DEFAULT NULL COMMENT '预期运行时间',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `dependence` mediumtext COLLATE utf8mb4_bin COMMENT '依赖字段',
  `process_instance_priority` int(11) DEFAULT NULL COMMENT '流程实例优先级：0 Highest,1 High,2 Medium,3 Low,4 Lowest',
  `worker_group_id` int(11) DEFAULT '-1' COMMENT '任务指定运行的worker分组',
  `message` mediumtext COLLATE utf8mb4_bin COMMENT '执行信息',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;


-- welab_skyeye.dag_error_table definition

CREATE TABLE `dag_error_table` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `error_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '业务id',
  `error_table` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL,
  `error_field` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL,
  `error_desc` mediumtext COLLATE utf8mb4_bin COMMENT '错误描述',
  `error_code` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '错误码',
  `job_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28699 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_etl_log definition

CREATE TABLE `dag_etl_log` (
  `ID_BATCH` int(11) DEFAULT NULL,
  `CHANNEL_ID` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `TRANSNAME` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `STATUS` varchar(15) COLLATE utf8mb4_bin DEFAULT NULL,
  `LINES_READ` bigint(20) DEFAULT NULL,
  `LINES_WRITTEN` bigint(20) DEFAULT NULL,
  `LINES_UPDATED` bigint(20) DEFAULT NULL,
  `LINES_INPUT` bigint(20) DEFAULT NULL,
  `LINES_OUTPUT` bigint(20) DEFAULT NULL,
  `LINES_REJECTED` bigint(20) DEFAULT NULL,
  `ERRORS` bigint(20) DEFAULT NULL,
  `STARTDATE` datetime DEFAULT NULL,
  `ENDDATE` datetime DEFAULT NULL,
  `LOGDATE` datetime DEFAULT NULL,
  `DEPDATE` datetime DEFAULT NULL,
  `REPLAYDATE` datetime DEFAULT NULL,
  `LOG_FIELD` longtext COLLATE utf8mb4_bin
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_fee_config definition

CREATE TABLE `dag_fee_config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `resources_id` bigint(20) NOT NULL COMMENT '资源id',
  `fee` decimal(20,4) DEFAULT '0.0000' COMMENT '成本(以分为单位)',
  `start_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '开始计费时间',
  `end_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '结束时间',
  `charge_type` tinyint(2) DEFAULT NULL COMMENT '计费类型    0：次数  1：时间',
  `status` tinyint(1) DEFAULT '1' COMMENT '是否开启  0：关闭   1：开启',
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '描述',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_resources_id` (`resources_id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COMMENT='成本配置表';


-- welab_skyeye.dag_fee_config_detail definition

CREATE TABLE `dag_fee_config_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `fee_config_id` bigint(20) DEFAULT NULL COMMENT '成本配置id',
  `interface_status` varchar(10) DEFAULT NULL COMMENT '接口状态码',
  `status_code_path` varchar(100) DEFAULT NULL COMMENT '报文状态码路径',
  `status_code_value` varchar(50) DEFAULT NULL COMMENT '报文状态码值',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_fee_config_id` (`fee_config_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='成本配置收费标识表';


-- welab_skyeye.dag_instance_task_relation definition

CREATE TABLE `dag_instance_task_relation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'self-increasing id',
  `process_instance_id` int(11) NOT NULL COMMENT '流程实例id',
  `process_task_relation_id` int(11) NOT NULL COMMENT '流程与任务关联id',
  `process_definition_code` bigint(20) NOT NULL COMMENT '流程定义code',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`process_instance_id`,`process_task_relation_id`,`process_definition_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='流程实例与流程定义关联关系';


-- welab_skyeye.dag_master_server definition

CREATE TABLE `dag_master_server` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `host` varchar(45) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'ip',
  `port` int(11) DEFAULT NULL COMMENT '进程号',
  `zk_directory` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'zk注册目录',
  `res_info` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '集群资源信息：json格式{"cpu":xxx,"memroy":xxx}',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `last_heartbeat_time` datetime DEFAULT NULL COMMENT '最后心跳时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8742 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_process_definition definition

CREATE TABLE `dag_process_definition` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流程定义名称',
  `code` bigint(20) DEFAULT NULL COMMENT '唯一编码(由雪花算法生成)',
  `version` int(11) DEFAULT NULL COMMENT '流程定义版本',
  `release_state` tinyint(4) DEFAULT NULL COMMENT '流程定义的发布状态：0 未上线  1已上线',
  `project_id` int(11) DEFAULT NULL COMMENT '项目id',
  `user_id` int(11) DEFAULT NULL COMMENT '流程定义所属用户id',
  `process_definition_json` longtext COLLATE utf8mb4_bin COMMENT '流程定义json串',
  `process_definition_json_template` longtext COLLATE utf8mb4_bin,
  `desc` mediumtext COLLATE utf8mb4_bin COMMENT '流程定义描述',
  `global_params` mediumtext COLLATE utf8mb4_bin COMMENT '全局参数',
  `flag` tinyint(4) DEFAULT NULL COMMENT '流程是否可用\r\n：0 不可用\r\n，1 可用',
  `locations` mediumtext COLLATE utf8mb4_bin COMMENT '节点坐标信息',
  `connects` mediumtext COLLATE utf8mb4_bin COMMENT '节点连线信息',
  `receivers` mediumtext COLLATE utf8mb4_bin COMMENT '收件人',
  `receivers_cc` mediumtext COLLATE utf8mb4_bin COMMENT '抄送人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `timeout` int(11) DEFAULT '0' COMMENT '超时时间',
  `tenant_id` int(11) NOT NULL DEFAULT '-1' COMMENT '租户id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `fork_from_id` int(11) NOT NULL DEFAULT '0' COMMENT 'fork来源',
  `snapshot_from_id` int(11) NOT NULL COMMENT '快照来源(非快照，值为当前数据主键id)',
  `text_md5` varchar(32) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT 'md5(process_definition_json+connects)',
  `is_snapshot` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否快照: 1=是 0=不是',
  `parent_code` bigint(20) DEFAULT '0' COMMENT '父code,没有父资源id的填0',
  `ancestor_code` bigint(20) DEFAULT '0' COMMENT '祖先code',
  `project_code` bigint(20) DEFAULT NULL COMMENT 'project code',
  `extras` longtext COLLATE utf8mb4_bin COMMENT '额外信息',
  `run_model` tinyint(4) DEFAULT NULL COMMENT '运行模式',
  `is_major` tinyint(1) DEFAULT '1' COMMENT '是否主定义流程: 1=是 0=不是',
  `complement_status` tinyint(4) DEFAULT '0' COMMENT '补数状态',
  `self_optimization_id` bigint(20) DEFAULT NULL COMMENT '关联的自优化ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_snapshot` (`snapshot_from_id`,`text_md5`,`is_snapshot`) USING BTREE COMMENT '快照唯一索引',
  KEY `process_definition_index` (`project_id`,`id`) USING BTREE,
  KEY `index_dag_process_definition_code` (`code`),
  KEY `project_code` (`project_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4472 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='escheduler流程定义表';


-- welab_skyeye.dag_process_definition_20210928_1527_tenma_bak definition

CREATE TABLE `dag_process_definition_20210928_1527_tenma_bak` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `project_id` int(11) NOT NULL COMMENT '项目id',
  `user_id` bigint(20) DEFAULT NULL COMMENT '流程定义所属用户id',
  `name` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '流程定义名称',
  `code` bigint(20) DEFAULT NULL COMMENT '唯一编码(由雪花算法生成)',
  `desc` mediumtext COLLATE utf8mb4_bin COMMENT '流程定义描述',
  `version` int(11) NOT NULL COMMENT '流程定义版本',
  `release_state` tinyint(4) NOT NULL COMMENT '流程定义的发布状态：0 未上线  1已上线',
  `process_definition_json` longtext COLLATE utf8mb4_bin COMMENT '流程定义json串',
  `process_definition_json_template` longtext COLLATE utf8mb4_bin,
  `global_params` mediumtext COLLATE utf8mb4_bin COMMENT '全局参数',
  `locations` mediumtext COLLATE utf8mb4_bin COMMENT '节点坐标信息',
  `connects` mediumtext COLLATE utf8mb4_bin COMMENT '节点连线信息',
  `receivers` mediumtext COLLATE utf8mb4_bin COMMENT '收件人',
  `receivers_cc` mediumtext COLLATE utf8mb4_bin COMMENT '抄送人',
  `timeout` int(11) DEFAULT '0' COMMENT '超时时间',
  `tenant_id` int(11) NOT NULL DEFAULT '-1' COMMENT '租户id',
  `fork_from_id` int(11) NOT NULL DEFAULT '0' COMMENT 'fork来源',
  `snapshot_from_id` int(11) NOT NULL COMMENT '快照来源(非快照，值为当前数据主键id)',
  `text_md5` varchar(32) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT 'md5(process_definition_json+connects)',
  `is_snapshot` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否快照: 1=是 0=不是',
  `flag` tinyint(4) NOT NULL COMMENT '流程是否可用\r\n：0 不可用\r\n，1 可用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `parent_code` bigint(20) DEFAULT '0' COMMENT '父code,没有父资源id的填0',
  `ancestor_code` bigint(20) DEFAULT '0' COMMENT '祖先code',
  `project_code` bigint(20) DEFAULT NULL COMMENT 'project code',
  `run_model` tinyint(4) DEFAULT NULL COMMENT '运行模式',
  `is_major` tinyint(1) DEFAULT '1' COMMENT '是否主定义流程: 1=是 0=不是',
  `complement_status` tinyint(4) DEFAULT '0' COMMENT '补数状态',
  `extras` longtext COLLATE utf8mb4_bin COMMENT '额外信息',
  `self_optimization_id` bigint(20) DEFAULT NULL COMMENT '如果是自优化创建的流程，则该字段不为空',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_snapshot` (`snapshot_from_id`,`text_md5`,`is_snapshot`) USING BTREE COMMENT '快照唯一索引',
  KEY `process_definition_index` (`project_id`,`id`) USING BTREE,
  KEY `index_definition_project_id` (`project_id`),
  KEY `index_dag_process_definition_code` (`code`),
  KEY `project_code` (`project_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1000003955 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_process_definition_bak definition

CREATE TABLE `dag_process_definition_bak` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流程定义名称',
  `code` bigint(20) DEFAULT NULL COMMENT '唯一编码(由雪花算法生成)',
  `version` int(11) DEFAULT NULL COMMENT '流程定义版本',
  `release_state` tinyint(4) DEFAULT NULL COMMENT '流程定义的发布状态：0 未上线  1已上线',
  `project_id` int(11) DEFAULT NULL COMMENT '项目id',
  `user_id` int(11) DEFAULT NULL COMMENT '流程定义所属用户id',
  `process_definition_json` longtext COLLATE utf8mb4_bin COMMENT '流程定义json串',
  `process_definition_json_template` longtext COLLATE utf8mb4_bin,
  `desc` mediumtext COLLATE utf8mb4_bin COMMENT '流程定义描述',
  `global_params` mediumtext COLLATE utf8mb4_bin COMMENT '全局参数',
  `flag` tinyint(4) DEFAULT NULL COMMENT '流程是否可用\r\n：0 不可用\r\n，1 可用',
  `locations` mediumtext COLLATE utf8mb4_bin COMMENT '节点坐标信息',
  `connects` mediumtext COLLATE utf8mb4_bin COMMENT '节点连线信息',
  `receivers` mediumtext COLLATE utf8mb4_bin COMMENT '收件人',
  `receivers_cc` mediumtext COLLATE utf8mb4_bin COMMENT '抄送人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `timeout` int(11) DEFAULT '0' COMMENT '超时时间',
  `tenant_id` int(11) NOT NULL DEFAULT '-1' COMMENT '租户id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `fork_from_id` int(11) NOT NULL DEFAULT '0' COMMENT 'fork来源',
  `snapshot_from_id` int(11) NOT NULL COMMENT '快照来源(非快照，值为当前数据主键id)',
  `text_md5` varchar(32) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT 'md5(process_definition_json+connects)',
  `is_snapshot` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否快照: 1=是 0=不是',
  `parent_code` bigint(20) DEFAULT '0' COMMENT '父code,没有父资源id的填0',
  `ancestor_code` bigint(20) DEFAULT '0' COMMENT '祖先code',
  `project_code` bigint(20) DEFAULT NULL COMMENT 'project code',
  `extras` longtext COLLATE utf8mb4_bin COMMENT '额外信息',
  `run_model` tinyint(4) DEFAULT NULL COMMENT '运行模式',
  `is_major` tinyint(1) DEFAULT '1' COMMENT '是否主定义流程: 1=是 0=不是',
  `complement_status` tinyint(4) DEFAULT '0' COMMENT '补数状态',
  `self_optimization_id` bigint(20) DEFAULT NULL COMMENT '关联的自优化ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_snapshot` (`snapshot_from_id`,`text_md5`,`is_snapshot`) USING BTREE COMMENT '快照唯一索引',
  KEY `process_definition_index` (`project_id`,`id`) USING BTREE,
  KEY `index_dag_process_definition_code` (`code`),
  KEY `project_code` (`project_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4166 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='escheduler流程定义表';


-- welab_skyeye.dag_process_instance definition

CREATE TABLE `dag_process_instance` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流程实例名称',
  `process_definition_id` int(11) DEFAULT NULL COMMENT '流程定义id',
  `state` tinyint(4) DEFAULT NULL COMMENT '流程实例状态：0 提交成功,1 正在运行,2 准备暂停,3 暂停,4 准备停止,5 停止,6 失败,7 成功,8 需要容错,9 kill,10 等待线程,11 等待依赖完成',
  `recovery` tinyint(4) DEFAULT NULL COMMENT '流程实例容错标识：0 正常,1 需要被容错重启',
  `start_time` datetime(3) DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime(3) DEFAULT NULL COMMENT '结束时间',
  `run_times` int(11) DEFAULT NULL COMMENT '流程实例运行次数',
  `host` varchar(45) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流程实例所在的机器',
  `command_type` tinyint(4) DEFAULT NULL COMMENT '命令类型：0 启动工作流,1 从当前节点开始执行,2 恢复被容错的工作流,3 恢复暂停流程,4 从失败节点开始执行,5 补数,6 调度,7 重跑,8 暂停,9 停止,10 恢复等待线程',
  `command_param` mediumtext COLLATE utf8mb4_bin COMMENT '命令的参数（json格式）',
  `task_depend_type` tinyint(4) DEFAULT NULL COMMENT '节点依赖类型：0 当前节点,1 向前执行,2 向后执行',
  `max_try_times` tinyint(4) DEFAULT '0' COMMENT '最大重试次数',
  `failure_strategy` tinyint(4) DEFAULT '0' COMMENT '失败策略 0 失败后结束，1 失败后继续',
  `warning_type` tinyint(4) DEFAULT '0' COMMENT '告警类型：0 不发,1 流程成功发,2 流程失败发,3 成功失败都发',
  `warning_group_id` int(11) DEFAULT NULL COMMENT '告警组id',
  `schedule_time` datetime DEFAULT NULL COMMENT '预期运行时间',
  `command_start_time` datetime DEFAULT NULL COMMENT '开始命令时间',
  `global_params` mediumtext COLLATE utf8mb4_bin COMMENT '全局参数（固化流程定义的参数）',
  `process_instance_json` longtext COLLATE utf8mb4_bin COMMENT '流程实例json(copy的流程定义的json)',
  `flag` tinyint(4) DEFAULT '1' COMMENT '是否可用，1 可用，0不可用',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_sub_process` int(11) DEFAULT '0' COMMENT '是否是子工作流 1 是，0 不是',
  `executor_id` int(11) NOT NULL COMMENT '命令执行者',
  `command_trace_id` varchar(100) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '命令追踪标识',
  `locations` mediumtext COLLATE utf8mb4_bin COMMENT '节点坐标信息',
  `connects` mediumtext COLLATE utf8mb4_bin COMMENT '节点连线信息',
  `history_cmd` mediumtext COLLATE utf8mb4_bin COMMENT '历史命令，记录所有对流程实例的操作',
  `dependence_schedule_times` mediumtext COLLATE utf8mb4_bin COMMENT '依赖节点的预估时间',
  `process_instance_priority` int(11) DEFAULT NULL COMMENT '流程实例优先级：0 Highest,1 High,2 Medium,3 Low,4 Lowest',
  `worker_group_id` int(11) DEFAULT '-1' COMMENT '任务指定运行的worker分组',
  `timeout` int(11) DEFAULT '0' COMMENT '超时时间',
  `save_point_path` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保存点路径',
  `var_pool` longtext COLLATE utf8mb4_bin COMMENT 'var_pool',
  `worker_group` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'worker group id',
  `run_model` tinyint(4) DEFAULT NULL COMMENT '运行模式',
  `task_model` tinyint(4) DEFAULT '0' COMMENT '任务模式0:监听，1:响应',
  `project_id` int(11) DEFAULT NULL COMMENT '项目id',
  `result` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '运行结果',
  PRIMARY KEY (`id`),
  KEY `process_instance_index` (`process_definition_id`,`id`) USING BTREE,
  KEY `start_time_index` (`start_time`) USING BTREE,
  KEY `process_instance_index1` (`process_definition_id`),
  KEY `index_instance_definition_id` (`process_definition_id`),
  KEY `state_index` (`state`),
  KEY `project_id_index` (`project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1000088791 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_process_instance_test definition

CREATE TABLE `dag_process_instance_test` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流程实例名称',
  `process_definition_id` int(11) DEFAULT NULL COMMENT '流程定义id',
  `state` tinyint(4) DEFAULT NULL COMMENT '流程实例状态：0 提交成功,1 正在运行,2 准备暂停,3 暂停,4 准备停止,5 停止,6 失败,7 成功,8 需要容错,9 kill,10 等待线程,11 等待依赖完成',
  `recovery` tinyint(4) DEFAULT NULL COMMENT '流程实例容错标识：0 正常,1 需要被容错重启',
  `start_time` datetime(3) DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime(3) DEFAULT NULL COMMENT '结束时间',
  `run_times` int(11) DEFAULT NULL COMMENT '流程实例运行次数',
  `host` varchar(45) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流程实例所在的机器',
  `command_type` tinyint(4) DEFAULT NULL COMMENT '命令类型：0 启动工作流,1 从当前节点开始执行,2 恢复被容错的工作流,3 恢复暂停流程,4 从失败节点开始执行,5 补数,6 调度,7 重跑,8 暂停,9 停止,10 恢复等待线程',
  `command_param` mediumtext COLLATE utf8mb4_bin COMMENT '命令的参数（json格式）',
  `task_depend_type` tinyint(4) DEFAULT NULL COMMENT '节点依赖类型：0 当前节点,1 向前执行,2 向后执行',
  `max_try_times` tinyint(4) DEFAULT '0' COMMENT '最大重试次数',
  `failure_strategy` tinyint(4) DEFAULT '0' COMMENT '失败策略 0 失败后结束，1 失败后继续',
  `warning_type` tinyint(4) DEFAULT '0' COMMENT '告警类型：0 不发,1 流程成功发,2 流程失败发,3 成功失败都发',
  `warning_group_id` int(11) DEFAULT NULL COMMENT '告警组id',
  `schedule_time` datetime DEFAULT NULL COMMENT '预期运行时间',
  `command_start_time` datetime DEFAULT NULL COMMENT '开始命令时间',
  `global_params` mediumtext COLLATE utf8mb4_bin COMMENT '全局参数（固化流程定义的参数）',
  `process_instance_json` longtext COLLATE utf8mb4_bin COMMENT '流程实例json(copy的流程定义的json)',
  `flag` tinyint(4) DEFAULT '1' COMMENT '是否可用，1 可用，0不可用',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_sub_process` int(11) DEFAULT '0' COMMENT '是否是子工作流 1 是，0 不是',
  `executor_id` int(11) NOT NULL COMMENT '命令执行者',
  `command_trace_id` varchar(100) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '命令追踪标识',
  `locations` mediumtext COLLATE utf8mb4_bin COMMENT '节点坐标信息',
  `connects` mediumtext COLLATE utf8mb4_bin COMMENT '节点连线信息',
  `history_cmd` mediumtext COLLATE utf8mb4_bin COMMENT '历史命令，记录所有对流程实例的操作',
  `dependence_schedule_times` mediumtext COLLATE utf8mb4_bin COMMENT '依赖节点的预估时间',
  `process_instance_priority` int(11) DEFAULT NULL COMMENT '流程实例优先级：0 Highest,1 High,2 Medium,3 Low,4 Lowest',
  `worker_group_id` int(11) DEFAULT '-1' COMMENT '任务指定运行的worker分组',
  `timeout` int(11) DEFAULT '0' COMMENT '超时时间',
  `save_point_path` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保存点路径',
  `var_pool` longtext COLLATE utf8mb4_bin COMMENT 'var_pool',
  `worker_group` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'worker group id',
  `run_model` tinyint(4) DEFAULT NULL COMMENT '运行模式',
  `task_model` tinyint(4) DEFAULT '0' COMMENT '任务模式0:监听，1:响应',
  `project_id` int(11) DEFAULT NULL COMMENT '项目id',
  `result` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '运行结果',
  PRIMARY KEY (`id`),
  KEY `process_instance_index` (`process_definition_id`,`id`) USING BTREE,
  KEY `start_time_index` (`start_time`) USING BTREE,
  KEY `process_instance_index1` (`process_definition_id`),
  KEY `index_instance_definition_id` (`process_definition_id`),
  KEY `state_index` (`state`),
  KEY `project_id_index` (`project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1000086731 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_process_task_relation definition

CREATE TABLE `dag_process_task_relation` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'self-increasing id',
  `name` varchar(200) DEFAULT NULL COMMENT 'relation name',
  `code` bigint(20) DEFAULT NULL COMMENT 'encoding',
  `project_code` bigint(20) DEFAULT NULL COMMENT 'project code',
  `process_definition_code` bigint(20) NOT NULL COMMENT 'process code',
  `source_task_code` bigint(20) DEFAULT NULL COMMENT '当前任务定义code',
  `target_task_code` bigint(20) DEFAULT NULL COMMENT '后置任务定义code',
  `condition_type` tinyint(2) DEFAULT NULL COMMENT 'condition type : 0 none, 1 judge 2 delay',
  `condition_params` text COMMENT 'condition params(json)',
  `create_time` datetime NOT NULL COMMENT 'create time',
  `update_time` datetime DEFAULT NULL COMMENT 'update time',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12623 DEFAULT CHARSET=utf8;


-- welab_skyeye.dag_project definition

CREATE TABLE `dag_project` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '应用id',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '项目名称',
  `code` bigint(20) DEFAULT NULL COMMENT '唯一编码(由雪花算法生成)',
  `desc` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '项目描述',
  `user_id` int(11) DEFAULT NULL COMMENT '所属用户',
  `type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '0.离线项目，1实时项目',
  `flag` tinyint(4) DEFAULT '1' COMMENT '是否可用  1 可用,0 不可用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `self_optimization_id` bigint(20) DEFAULT NULL COMMENT '关联的自优化ID',
  PRIMARY KEY (`id`),
  KEY `user_id_index` (`user_id`) USING BTREE,
  KEY `index_dag_project_code` (`code`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=250 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='escheduler项目表';


-- welab_skyeye.dag_project_bak definition

CREATE TABLE `dag_project_bak` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '应用id',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '项目名称',
  `code` bigint(20) DEFAULT NULL COMMENT '唯一编码(由雪花算法生成)',
  `desc` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '项目描述',
  `user_id` int(11) DEFAULT NULL COMMENT '所属用户',
  `type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '0.离线项目，1实时项目',
  `flag` tinyint(4) DEFAULT '1' COMMENT '是否可用  1 可用,0 不可用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `self_optimization_id` bigint(20) DEFAULT NULL COMMENT '关联的自优化ID',
  PRIMARY KEY (`id`),
  KEY `user_id_index` (`user_id`) USING BTREE,
  KEY `index_dag_project_code` (`code`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=246 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='escheduler项目表';


-- welab_skyeye.dag_project_duty_permission definition

CREATE TABLE `dag_project_duty_permission` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `project_id` int(11) NOT NULL COMMENT '项目id',
  `permission_id` bigint(20) NOT NULL COMMENT '权限id',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_permission` (`project_id`,`permission_id`) USING BTREE COMMENT '唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='值班时赋予的项目权限';


-- welab_skyeye.dag_reference_relation definition

CREATE TABLE `dag_reference_relation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `entity_type` tinyint(4) NOT NULL COMMENT '被引用的实体类型。1=资源，2=参数，3=原因码，4=流程',
  `entity_id` bigint(20) NOT NULL COMMENT '被引用的实体ID',
  `belong_entity_type` tinyint(4) NOT NULL COMMENT '所属实体的类型',
  `belong_entity_id` bigint(20) NOT NULL COMMENT '所属实体的ID',
  `belong_entity_name` varchar(512) DEFAULT NULL COMMENT '所属实体的名称',
  `belong_entity_node_id` bigint(20) DEFAULT NULL COMMENT '所属实体的节点ID',
  `belong_entity_node_name` varchar(512) DEFAULT NULL COMMENT '所属实体的节点名称',
  `reference_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '引用时间',
  `app_id` varchar(200) DEFAULT NULL COMMENT '应用ID',
  PRIMARY KEY (`id`),
  KEY `idx_belongEntityNodeId` (`belong_entity_node_id`),
  KEY `idx_belongEntityType_belongEntityId` (`belong_entity_type`,`belong_entity_id`),
  KEY `idx_entityType_entityId` (`entity_type`,`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=67147 DEFAULT CHARSET=utf8mb4 COMMENT='引用关系表';


-- welab_skyeye.dag_relation_process_instance definition

CREATE TABLE `dag_relation_process_instance` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `parent_process_instance_id` int(11) DEFAULT NULL COMMENT '父流程实例id',
  `parent_task_instance_id` bigint(20) DEFAULT NULL,
  `process_instance_id` int(11) DEFAULT NULL COMMENT '子流程实例id',
  PRIMARY KEY (`id`),
  KEY `dag_relation_process_instance_index` (`parent_process_instance_id`,`parent_task_instance_id`,`app_id`),
  KEY `dag_relation_process_instance_index2` (`parent_process_instance_id`,`parent_task_instance_id`),
  KEY `process_instance_id` (`process_instance_id`),
  KEY `parent_task_instance_id` (`parent_task_instance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21386 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_resources definition

CREATE TABLE `dag_resources` (
  `id` bigint(20) NOT NULL,
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `alias` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '别名',
  `file_name` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件名',
  `desc` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '描述',
  `user_id` int(11) DEFAULT NULL COMMENT '用户id',
  `type` tinyint(4) DEFAULT NULL COMMENT '资源类型，0 FILE，1 UDF',
  `size` bigint(20) DEFAULT NULL COMMENT '资源大小',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_leaf` tinyint(1) DEFAULT '1' COMMENT '是否是叶子节点，即没有子节点的节点',
  `is_thirdparty` tinyint(1) DEFAULT '0' COMMENT '是否是第3方资源',
  `seq_num` int(11) DEFAULT '0' COMMENT '展示排序',
  `parent_id` bigint(20) DEFAULT '0' COMMENT '父资源id。没有父资源id的填0',
  `flag` tinyint(1) DEFAULT '1' COMMENT '记录是否有效。0无效；1有效',
  `ancestor_id` bigint(20) DEFAULT NULL COMMENT '祖先资源id',
  `path` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件路径',
  `file_format` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件格式后缀',
  `version` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '版本号',
  `snapshot_from_id` bigint(20) NOT NULL COMMENT '快照来源(非快照，值为当前数据主键id)',
  `text_md5` varchar(32) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '叶子节点md5值，md5(资源内容)',
  `is_snapshot` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否快照: 1=是 0=不是',
  `global_uniq_id` bigint(20) DEFAULT NULL COMMENT '全局唯一标识id属性',
  `use_for` int(2) DEFAULT '0' COMMENT '资源用于 0：流程 1：离线调度',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_snapshot` (`snapshot_from_id`,`text_md5`,`is_snapshot`) USING BTREE COMMENT '快照唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_savepoint definition

CREATE TABLE `dag_savepoint` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件名字',
  `path` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '存在hdfs路径',
  `instance_id` int(11) NOT NULL COMMENT 'task_instance主键',
  `gmt_create` datetime NOT NULL COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_schedules definition

CREATE TABLE `dag_schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `process_definition_id` int(11) NOT NULL COMMENT '流程定义id',
  `start_time` datetime NOT NULL COMMENT '调度开始时间',
  `end_time` datetime NOT NULL COMMENT '调度结束时间',
  `crontab` varchar(256) COLLATE utf8mb4_bin NOT NULL COMMENT 'crontab 表达式',
  `failure_strategy` tinyint(4) NOT NULL COMMENT '失败策略： 0 结束，1 继续',
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `release_state` tinyint(4) NOT NULL COMMENT '状态：0 未上线，1 上线',
  `warning_type` tinyint(4) NOT NULL COMMENT '告警类型：0 不发,1 流程成功发,2 流程失败发,3 成功失败都发',
  `warning_group_id` int(11) DEFAULT NULL COMMENT '告警组id',
  `process_instance_priority` int(11) DEFAULT NULL COMMENT '流程实例优先级：0 Highest,1 High,2 Medium,3 Low,4 Lowest',
  `worker_group_id` int(11) DEFAULT '-1' COMMENT '任务指定运行的worker分组',
  `worker_group` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务指定运行的worker分组',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `calendar_global_uniq_str` varchar(150) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '日历模板标识码',
  `extras` longtext COLLATE utf8mb4_bin COMMENT 'JSON额外信息 recycel:是否循环调度 1是,0否',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2139095285 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_task_definition definition

CREATE TABLE `dag_task_definition` (
  `id` varchar(250) NOT NULL COMMENT 'self-increasing id',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `code` bigint(20) NOT NULL COMMENT 'encoding',
  `name` varchar(200) DEFAULT NULL COMMENT 'task definition name',
  `parent_code` bigint(20) DEFAULT '0' COMMENT '父code,没有父资源id的填0',
  `ancestor_code` bigint(20) DEFAULT NULL COMMENT '祖先code,默认填自己',
  `process_definition_code` bigint(20) NOT NULL COMMENT 'process code',
  `desc` text COMMENT 'description',
  `user_id` int(11) DEFAULT NULL COMMENT 'task definition creator id',
  `type` varchar(50) NOT NULL COMMENT 'task type',
  `params` longtext COMMENT 'job custom parameters',
  `extras` longtext COMMENT '额外信息',
  `local_params` longtext COMMENT 'local parameters',
  `text_md5` varchar(50) NOT NULL COMMENT '摘要信息',
  `run_flag` tinyint(2) DEFAULT NULL COMMENT '0 not available, 1 available',
  `flag` tinyint(2) DEFAULT NULL COMMENT '0 not available, 1 available',
  `status` tinyint(4) DEFAULT NULL COMMENT 'status',
  `task_priority` tinyint(4) DEFAULT NULL COMMENT 'job priority',
  `worker_group` varchar(200) DEFAULT NULL COMMENT 'worker grouping',
  `max_retry_times` int(11) DEFAULT NULL COMMENT 'number of failed retries',
  `retry_interval` int(11) DEFAULT NULL COMMENT 'failed retry interval',
  `timeout_flag` tinyint(2) DEFAULT '0' COMMENT 'timeout flag:0 close, 1 open',
  `timeout_notify_strategy` tinyint(4) DEFAULT NULL COMMENT 'timeout notification policy: 0 warning, 1 fail',
  `timeout` int(11) DEFAULT '0' COMMENT 'timeout length,unit: minute',
  `delay_time` int(11) DEFAULT '0' COMMENT 'delay execution time,unit: minute',
  `resource_ids` varchar(255) DEFAULT NULL COMMENT 'resource id, separated by comma',
  `create_time` datetime DEFAULT NULL COMMENT 'create time',
  `update_time` datetime DEFAULT NULL COMMENT 'update time',
  UNIQUE KEY `uk_task_defin` (`id`,`app_id`,`process_definition_code`),
  KEY `Index_id` (`id`,`app_id`),
  KEY `Index_code` (`code`,`app_id`),
  KEY `Index_def_code` (`process_definition_code`,`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- welab_skyeye.dag_task_definition2 definition

CREATE TABLE `dag_task_definition2` (
  `id` varchar(20) NOT NULL COMMENT 'self-increasing id',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `code` bigint(20) NOT NULL COMMENT 'encoding',
  `name` varchar(200) DEFAULT NULL COMMENT 'task definition name',
  `parent_code` bigint(20) DEFAULT '0' COMMENT '父code,没有父资源id的填0',
  `ancestor_code` bigint(20) DEFAULT NULL COMMENT '祖先code,默认填自己',
  `process_definition_code` bigint(20) NOT NULL COMMENT 'process code',
  `desc` text COMMENT 'description',
  `user_id` int(11) DEFAULT NULL COMMENT 'task definition creator id',
  `type` varchar(50) NOT NULL COMMENT 'task type',
  `params` text COMMENT 'job custom parameters',
  `extras` text COMMENT '额外信息',
  `local_params` text COMMENT 'local parameters',
  `text_md5` varchar(50) NOT NULL COMMENT '摘要信息',
  `run_flag` tinyint(2) DEFAULT NULL COMMENT '0 not available, 1 available',
  `flag` tinyint(2) DEFAULT NULL COMMENT '0 not available, 1 available',
  `status` tinyint(4) DEFAULT NULL COMMENT 'status',
  `task_priority` tinyint(4) DEFAULT NULL COMMENT 'job priority',
  `worker_group` varchar(200) DEFAULT NULL COMMENT 'worker grouping',
  `max_retry_times` int(11) DEFAULT NULL COMMENT 'number of failed retries',
  `retry_interval` int(11) DEFAULT NULL COMMENT 'failed retry interval',
  `timeout_flag` tinyint(2) DEFAULT '0' COMMENT 'timeout flag:0 close, 1 open',
  `timeout_notify_strategy` tinyint(4) DEFAULT NULL COMMENT 'timeout notification policy: 0 warning, 1 fail',
  `timeout` int(11) DEFAULT '0' COMMENT 'timeout length,unit: minute',
  `delay_time` int(11) DEFAULT '0' COMMENT 'delay execution time,unit: minute',
  `resource_ids` varchar(255) DEFAULT NULL COMMENT 'resource id, separated by comma',
  `create_time` datetime NOT NULL COMMENT 'create time',
  `update_time` datetime DEFAULT NULL COMMENT 'update time',
  UNIQUE KEY `uk_task_defin` (`id`,`app_id`,`process_definition_code`),
  KEY `Index_id` (`id`,`app_id`),
  KEY `Index_code` (`code`,`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- welab_skyeye.dag_task_definition_20210927_1342_tenma_bak definition

CREATE TABLE `dag_task_definition_20210927_1342_tenma_bak` (
  `id` varchar(100) NOT NULL COMMENT 'self-increasing id',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `code` bigint(20) NOT NULL COMMENT 'encoding',
  `name` varchar(200) DEFAULT NULL COMMENT 'task definition name',
  `parent_code` bigint(20) DEFAULT '0' COMMENT '父code,没有父资源id的填0',
  `ancestor_code` bigint(20) DEFAULT NULL COMMENT '祖先code,默认填自己',
  `process_definition_code` bigint(20) NOT NULL COMMENT 'process code',
  `desc` text COMMENT 'description',
  `user_id` int(11) DEFAULT NULL COMMENT 'task definition creator id',
  `type` varchar(50) NOT NULL COMMENT 'task type',
  `params` longtext COMMENT 'job custom parameters',
  `extras` longtext COMMENT '额外信息',
  `local_params` longtext COMMENT 'local parameters',
  `text_md5` varchar(50) NOT NULL COMMENT '摘要信息',
  `run_flag` tinyint(2) DEFAULT '1' COMMENT '0 not available, 1 available',
  `flag` tinyint(2) DEFAULT '1' COMMENT '0 not available, 1 available',
  `status` tinyint(4) DEFAULT NULL COMMENT 'status',
  `task_priority` tinyint(4) DEFAULT NULL COMMENT 'job priority',
  `worker_group` varchar(200) DEFAULT NULL COMMENT 'worker grouping',
  `max_retry_times` int(11) DEFAULT NULL COMMENT 'number of failed retries',
  `retry_interval` int(11) DEFAULT NULL COMMENT 'failed retry interval',
  `timeout_flag` tinyint(2) DEFAULT '0' COMMENT 'timeout flag:0 close, 1 open',
  `timeout_notify_strategy` tinyint(4) DEFAULT NULL COMMENT 'timeout notification policy: 0 warning, 1 fail',
  `timeout` int(11) DEFAULT '0' COMMENT 'timeout length,unit: minute',
  `delay_time` int(11) DEFAULT '0' COMMENT 'delay execution time,unit: minute',
  `resource_ids` varchar(255) DEFAULT NULL COMMENT 'resource id, separated by comma',
  `create_time` datetime NOT NULL COMMENT 'create time',
  `update_time` datetime DEFAULT NULL COMMENT 'update time',
  UNIQUE KEY `uk_task_defin` (`id`,`app_id`,`process_definition_code`),
  KEY `Index_id` (`id`,`app_id`),
  KEY `Index_code` (`code`,`app_id`),
  KEY `Index_def_code` (`process_definition_code`,`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- welab_skyeye.dag_task_definition_20211015_1012_tenma_bak definition

CREATE TABLE `dag_task_definition_20211015_1012_tenma_bak` (
  `id` varchar(100) NOT NULL COMMENT 'self-increasing id',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `code` bigint(20) NOT NULL COMMENT 'encoding',
  `name` varchar(200) DEFAULT NULL COMMENT 'task definition name',
  `parent_code` bigint(20) DEFAULT '0' COMMENT '父code,没有父资源id的填0',
  `ancestor_code` bigint(20) DEFAULT NULL COMMENT '祖先code,默认填自己',
  `process_definition_code` bigint(20) NOT NULL COMMENT 'process code',
  `desc` text COMMENT 'description',
  `user_id` int(11) DEFAULT NULL COMMENT 'task definition creator id',
  `type` varchar(50) NOT NULL COMMENT 'task type',
  `params` longtext COMMENT 'job custom parameters',
  `extras` longtext COMMENT '额外信息',
  `local_params` longtext COMMENT 'local parameters',
  `text_md5` varchar(50) NOT NULL COMMENT '摘要信息',
  `run_flag` tinyint(2) DEFAULT '1' COMMENT '0 not available, 1 available',
  `flag` tinyint(2) DEFAULT '1' COMMENT '0 not available, 1 available',
  `status` tinyint(4) DEFAULT NULL COMMENT 'status',
  `task_priority` tinyint(4) DEFAULT NULL COMMENT 'job priority',
  `worker_group` varchar(200) DEFAULT NULL COMMENT 'worker grouping',
  `max_retry_times` int(11) DEFAULT NULL COMMENT 'number of failed retries',
  `retry_interval` int(11) DEFAULT NULL COMMENT 'failed retry interval',
  `timeout_flag` tinyint(2) DEFAULT '0' COMMENT 'timeout flag:0 close, 1 open',
  `timeout_notify_strategy` tinyint(4) DEFAULT NULL COMMENT 'timeout notification policy: 0 warning, 1 fail',
  `timeout` int(11) DEFAULT '0' COMMENT 'timeout length,unit: minute',
  `delay_time` int(11) DEFAULT '0' COMMENT 'delay execution time,unit: minute',
  `resource_ids` varchar(255) DEFAULT NULL COMMENT 'resource id, separated by comma',
  `create_time` datetime NOT NULL COMMENT 'create time',
  `update_time` datetime DEFAULT NULL COMMENT 'update time',
  UNIQUE KEY `uk_task_defin` (`id`,`app_id`,`process_definition_code`),
  KEY `Index_id` (`id`,`app_id`),
  KEY `Index_code` (`code`,`app_id`),
  KEY `Index_def_code` (`process_definition_code`,`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- welab_skyeye.dag_task_definition_bak definition

CREATE TABLE `dag_task_definition_bak` (
  `id` varchar(250) NOT NULL COMMENT 'self-increasing id',
  `app_id` varchar(100) NOT NULL COMMENT '应用id',
  `code` bigint(20) NOT NULL COMMENT 'encoding',
  `name` varchar(200) DEFAULT NULL COMMENT 'task definition name',
  `parent_code` bigint(20) DEFAULT '0' COMMENT '父code,没有父资源id的填0',
  `ancestor_code` bigint(20) DEFAULT NULL COMMENT '祖先code,默认填自己',
  `process_definition_code` bigint(20) NOT NULL COMMENT 'process code',
  `desc` text COMMENT 'description',
  `user_id` int(11) DEFAULT NULL COMMENT 'task definition creator id',
  `type` varchar(50) NOT NULL COMMENT 'task type',
  `params` longtext COMMENT 'job custom parameters',
  `extras` longtext COMMENT '额外信息',
  `local_params` longtext COMMENT 'local parameters',
  `text_md5` varchar(50) NOT NULL COMMENT '摘要信息',
  `run_flag` tinyint(2) DEFAULT NULL COMMENT '0 not available, 1 available',
  `flag` tinyint(2) DEFAULT NULL COMMENT '0 not available, 1 available',
  `status` tinyint(4) DEFAULT NULL COMMENT 'status',
  `task_priority` tinyint(4) DEFAULT NULL COMMENT 'job priority',
  `worker_group` varchar(200) DEFAULT NULL COMMENT 'worker grouping',
  `max_retry_times` int(11) DEFAULT NULL COMMENT 'number of failed retries',
  `retry_interval` int(11) DEFAULT NULL COMMENT 'failed retry interval',
  `timeout_flag` tinyint(2) DEFAULT '0' COMMENT 'timeout flag:0 close, 1 open',
  `timeout_notify_strategy` tinyint(4) DEFAULT NULL COMMENT 'timeout notification policy: 0 warning, 1 fail',
  `timeout` int(11) DEFAULT '0' COMMENT 'timeout length,unit: minute',
  `delay_time` int(11) DEFAULT '0' COMMENT 'delay execution time,unit: minute',
  `resource_ids` varchar(255) DEFAULT NULL COMMENT 'resource id, separated by comma',
  `create_time` datetime DEFAULT NULL COMMENT 'create time',
  `update_time` datetime DEFAULT NULL COMMENT 'update time',
  UNIQUE KEY `uk_task_defin` (`id`,`app_id`,`process_definition_code`),
  KEY `Index_id` (`id`,`app_id`),
  KEY `Index_code` (`code`,`app_id`),
  KEY `Index_def_code` (`process_definition_code`,`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- welab_skyeye.dag_task_definition_reference definition

CREATE TABLE `dag_task_definition_reference` (
  `id` varchar(250) NOT NULL,
  `task_definition_code` bigint(20) NOT NULL,
  `reference_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'reference code关联的id类型, 1表示关联的是process_definition_code, 0表示关联的是task_definition_code',
  `reference_code` bigint(20) NOT NULL,
  `auto_update` tinyint(1) NOT NULL COMMENT '是否自动更新, 1是, 0否',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否有效, 1是, 0否',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `order_no` int(11) NOT NULL DEFAULT '0' COMMENT '顺序字段',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- welab_skyeye.dag_task_definition_reference_bak definition

CREATE TABLE `dag_task_definition_reference_bak` (
  `id` varchar(250) NOT NULL,
  `task_definition_code` bigint(20) NOT NULL,
  `reference_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'reference code关联的id类型, 1表示关联的是process_definition_code, 0表示关联的是task_definition_code',
  `reference_code` bigint(20) NOT NULL,
  `auto_update` tinyint(1) NOT NULL COMMENT '是否自动更新, 1是, 0否',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否有效, 1是, 0否',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- welab_skyeye.dag_task_instance definition

CREATE TABLE `dag_task_instance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务名称',
  `task_type` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务类型',
  `process_definition_id` int(11) DEFAULT NULL COMMENT '流程定义id',
  `process_instance_id` int(11) DEFAULT NULL COMMENT '流程实例id',
  `task_definition_code` bigint(20) DEFAULT NULL COMMENT 'task definition code',
  `task_json` longtext COLLATE utf8mb4_bin COMMENT '任务节点json',
  `state` tinyint(4) DEFAULT NULL COMMENT '任务实例状态：0 提交成功,1 正在运行,2 准备暂停,3 暂停,4 准备停止,5 停止,6 失败,7 成功,8 需要容错,9 kill,10 等待线程,11 等待依赖完成',
  `submit_time` datetime DEFAULT NULL COMMENT '任务提交时间',
  `start_time` datetime(3) DEFAULT NULL COMMENT '任务开始时间',
  `end_time` datetime(3) DEFAULT NULL COMMENT '任务结束时间',
  `host` varchar(45) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '执行任务的机器',
  `execute_path` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务执行路径',
  `log_path` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务日志路径',
  `alert_flag` tinyint(4) DEFAULT NULL COMMENT '是否告警',
  `retry_times` int(4) DEFAULT '0' COMMENT '重试次数',
  `pid` int(4) DEFAULT NULL COMMENT '进程pid',
  `app_link` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'yarn app id',
  `flag` tinyint(4) DEFAULT '1' COMMENT '是否可用：0 不可用，1 可用',
  `retry_interval` int(4) DEFAULT NULL COMMENT '重试间隔',
  `max_retry_times` int(2) DEFAULT NULL COMMENT '最大重试次数',
  `task_instance_priority` int(11) DEFAULT NULL COMMENT '任务实例优先级：0 Highest,1 High,2 Medium,3 Low,4 Lowest',
  `worker_group_id` int(11) DEFAULT '-1' COMMENT '任务指定运行的worker分组',
  `executor_id` int(11) DEFAULT NULL,
  `first_submit_time` datetime DEFAULT NULL COMMENT 'task first submit time',
  `delay_time` int(4) DEFAULT '0' COMMENT 'task delay execution time',
  `worker_group` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'worker group id',
  `var_pool` longtext COLLATE utf8mb4_bin COMMENT 'var_pool',
  `local_params` longtext COLLATE utf8mb4_bin COMMENT 'local parameters',
  `project_id` int(11) DEFAULT NULL COMMENT '项目id',
  PRIMARY KEY (`id`),
  KEY `process_instance_id` (`process_instance_id`) USING BTREE,
  KEY `task_instance_index` (`process_definition_id`,`process_instance_id`) USING BTREE,
  KEY `task_instance_start_time_index` (`start_time`),
  KEY `state_index` (`state`),
  KEY `project_id_index` (`project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=295726 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_task_log definition

CREATE TABLE `dag_task_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT 'appId',
  `trace_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '执行时的追踪标识',
  `req_id` bigint(20) NOT NULL COMMENT '请求消息id',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `total_use_ms` int(11) DEFAULT '-1' COMMENT '总耗时（单位：毫秒）',
  `process_definition_id` int(11) NOT NULL COMMENT '流程定义id',
  `snapshot_id` int(11) NOT NULL COMMENT '快照id(前期是实例的id,后面可以重新设计这块)',
  `log_status` tinyint(2) NOT NULL COMMENT '状态(0：执行中，1：执行失败，2：成功)',
  `status_desc` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态描述（特别是失败时，需要记录下概述）',
  PRIMARY KEY (`id`),
  KEY `idx_process_definition_id_snapshot_id_index` (`process_definition_id`,`snapshot_id`),
  KEY `idx_req_id` (`req_id`),
  KEY `idx_app_id` (`app_id`),
  KEY `idx_trace_id` (`trace_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1847 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dag任务的执行记录';


-- welab_skyeye.dag_task_output_column definition

CREATE TABLE `dag_task_output_column` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `process_definition_id` int(10) unsigned NOT NULL COMMENT '流程定义ID',
  `task_id` varchar(20) COLLATE utf8mb4_bin NOT NULL COMMENT '流程任务ID',
  `task_detail` varchar(1000) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务详情',
  `user_id` int(11) unsigned DEFAULT NULL COMMENT '用户id',
  `output_column` varchar(1000) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流程任务输出列',
  `release_state` tinyint(4) DEFAULT '0' COMMENT '流程的发布状态：0 未上线  1已上线',
  `version` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流程版本号',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='流程任务组件输出列信息表';


-- welab_skyeye.dag_test definition

CREATE TABLE `dag_test` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `end_time` date DEFAULT NULL COMMENT '调度结束时间',
  `time1` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55555556 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='escheduler任务表';


-- welab_skyeye.dag_test2 definition

CREATE TABLE `dag_test2` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `end_time` date DEFAULT NULL COMMENT '调度结束时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2113929366 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='escheduler任务表';


-- welab_skyeye.dag_udfs definition

CREATE TABLE `dag_udfs` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `func_name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT 'UDF函数名',
  `class_name` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '类名',
  `type` tinyint(4) NOT NULL COMMENT 'Udf函数类型',
  `arg_types` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '参数',
  `database` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '库名',
  `desc` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '描述',
  `resource_id` int(11) NOT NULL COMMENT '资源id',
  `resource_name` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '资源名称',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_user definition

CREATE TABLE `dag_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `user_name` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户名',
  `user_password` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户密码',
  `user_type` tinyint(4) DEFAULT NULL COMMENT '用户类型：0 管理员，1 普通用户',
  `email` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(11) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '手机',
  `tenant_id` int(11) DEFAULT NULL COMMENT '管理员0,普通用户所属租户id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `queue` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '队列',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_user2 definition

CREATE TABLE `dag_user2` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `user_name` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户名',
  `user_password` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户密码',
  `user_type` tinyint(4) DEFAULT NULL COMMENT '用户类型：0 管理员，1 普通用户',
  `email` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(11) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '手机',
  `tenant_id` int(11) DEFAULT NULL COMMENT '管理员0,普通用户所属租户id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `queue` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '队列',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dag_worker_group definition

CREATE TABLE `dag_worker_group` (
  `id` bigint(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组名称',
  `ip_list` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'worker地址列表',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `old_ip_list` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '旧worker地址列表',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;


-- welab_skyeye.dag_worker_server definition

CREATE TABLE `dag_worker_server` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_id` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '应用id',
  `host` varchar(45) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'ip',
  `port` int(11) DEFAULT NULL COMMENT '进程号',
  `zk_directory` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'zk注册目录',
  `res_info` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '集群资源信息：json格式{"cpu":xxx,"memroy":xxx}',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `last_heartbeat_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8495 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dagax_mysql_app definition

CREATE TABLE `dagax_mysql_app` (
  `id` bigint(20) unsigned NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `remark` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `gmt_create` datetime NOT NULL,
  `gmt_modified` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dashboard_overview definition

CREATE TABLE `dashboard_overview` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '名称',
  `is_public` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否公开：1=是 0=不是',
  `config` text COLLATE utf8mb4_bin COMMENT 'json格式的配置数据',
  `display_type` int(4) DEFAULT '0' COMMENT '前端概览展示类型',
  `description` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '描述',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=470 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据总览表';


-- welab_skyeye.dashboard_overview_panel definition

CREATE TABLE `dashboard_overview_panel` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `overview_id` bigint(20) unsigned NOT NULL COMMENT 'overview_id',
  `panel_id` bigint(20) unsigned NOT NULL COMMENT 'panel_id',
  `sort` bigint(20) NOT NULL COMMENT '总览内面板的排序',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_overview_panel` (`overview_id`,`panel_id`) USING BTREE COMMENT '组合唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=1247 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据总览面板表';


-- welab_skyeye.dashboard_panel definition

CREATE TABLE `dashboard_panel` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `app_id` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '应用id',
  `name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '名称',
  `type` int(11) NOT NULL COMMENT '类型：1=事件分析 2=漏斗分析 3=留存分析 4=分布分析 5=属性分析 6=渠道对比',
  `data` text COLLATE utf8mb4_bin COMMENT 'json格式的查询参数数据',
  `config` text COLLATE utf8mb4_bin COMMENT 'json格式的配置数据',
  `data_source_uuid` varchar(50) COLLATE utf8mb4_bin DEFAULT '' COMMENT '数据源uuid',
  `is_msg` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否发送邮件 0=否 1=是',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已删除的 0=否 1=是',
  `msg_config` text COLLATE utf8mb4_bin COMMENT '邮件发送配置信息',
  `is_combined_msg` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否包含多个面板的数据推送 0=否 1=是',
  `combined_msg_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '多个面板数据推送时数据名称',
  `description` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '描述',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1449 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据面板表';


-- welab_skyeye.dashboard_panel_combine definition

CREATE TABLE `dashboard_panel_combine` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `panel_id` bigint(20) NOT NULL COMMENT '主面板id',
  `combined_panel_id` bigint(20) NOT NULL COMMENT '组合面板id',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_id` (`panel_id`,`combined_panel_id`) USING BTREE COMMENT '组合唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据推送组合面板表';


-- welab_skyeye.dashboard_panel_send definition

CREATE TABLE `dashboard_panel_send` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `panel_id` bigint(20) NOT NULL COMMENT '面板id',
  `receivers` text COLLATE utf8mb4_bin COMMENT '收件人',
  `send_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`id`),
  KEY `idx_panel_id` (`panel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20258 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='面板发送表';


-- welab_skyeye.dashboard_panel_visit_time definition

CREATE TABLE `dashboard_panel_visit_time` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `panel_id` bigint(20) DEFAULT '0' COMMENT '面板ID',
  `value` bigint(20) DEFAULT '0' COMMENT '访问次数',
  `gmt_create` datetime DEFAULT NULL COMMENT '创建时间',
  `gmt_modified` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_panel_id` (`panel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=439 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='面板访问次数统计表';


-- welab_skyeye.dashboard_ureport definition

CREATE TABLE `dashboard_ureport` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ureport_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '表单名称',
  `ureport_xml` mediumtext COLLATE utf8mb4_bin COMMENT '表单内容',
  `state` tinyint(1) DEFAULT NULL COMMENT '状态',
  `gmt_create` datetime DEFAULT NULL COMMENT '创建时间',
  `gmt_modified` datetime DEFAULT NULL COMMENT '修改时间',
  `overview_ids` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '所属面板的集合',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='设计表存储';


-- welab_skyeye.data_account_test definition

CREATE TABLE `data_account_test` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `org` char(12) COLLATE utf8mb4_bin NOT NULL COMMENT '机构号',
  `acct_no` varchar(50) COLLATE utf8mb4_bin NOT NULL COMMENT '账户编号',
  `app_no` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '贷款申请编号',
  `cust_no` varchar(50) COLLATE utf8mb4_bin NOT NULL COMMENT '客户编号',
  `cust_group` varchar(500) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '所属客群',
  `fst_repay_date` date DEFAULT NULL COMMENT '首次还款日',
  `end_repay_date` date DEFAULT NULL COMMENT '末次还款日',
  `loan_type` varchar(80) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '贷款类型',
  `loan_state` varchar(30) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '贷款状态',
  `loan_purpose` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '贷款目的',
  `loan_period` int(11) DEFAULT NULL COMMENT '贷款期数',
  `loan_year_rate` decimal(16,2) DEFAULT NULL COMMENT '年利率',
  `loan_rate_em` decimal(16,2) DEFAULT NULL COMMENT '月利率',
  `loan_service_fee` decimal(16,2) DEFAULT NULL COMMENT '贷款服务费',
  `need_amt` decimal(16,2) DEFAULT NULL COMMENT '每期应还款额',
  `over_due_date` date DEFAULT NULL COMMENT '逾期日期',
  `over_due_days` int(11) DEFAULT NULL COMMENT '逾期天数',
  `over_due_terms` int(11) DEFAULT NULL COMMENT '逾期期数',
  `over_due_principal` decimal(16,2) DEFAULT NULL COMMENT '逾期本金',
  `over_due_interest` decimal(16,2) DEFAULT NULL COMMENT '逾期利率',
  `over_due_penalty` decimal(16,2) DEFAULT NULL COMMENT '逾期罚息',
  `deposit` decimal(16,2) DEFAULT NULL COMMENT '保证金',
  `over_due_maintenance` decimal(16,2) DEFAULT NULL COMMENT '逾期管理费',
  `over_due_amt` decimal(16,2) DEFAULT NULL COMMENT '逾期应还金额',
  `remain_term` int(11) DEFAULT NULL COMMENT '待还期数',
  `remain_principal` decimal(16,2) DEFAULT NULL COMMENT '剩余本金',
  `loan_balance` decimal(16,2) DEFAULT NULL COMMENT '贷款余额',
  `pact_amt` decimal(16,2) DEFAULT NULL COMMENT '合同金额',
  `loan_amt` decimal(16,2) DEFAULT NULL COMMENT '贷款金额',
  `loan_date` date DEFAULT NULL COMMENT '贷款日期',
  `collect_flag` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '案件类型',
  `collect_date` date DEFAULT NULL COMMENT '催还日期',
  `first_over_due_terms` int(11) DEFAULT NULL COMMENT '首次逾期期数',
  `curr_over_due_terms` int(11) DEFAULT NULL COMMENT '当前逾期期数',
  `curr_over_due_days` int(11) DEFAULT NULL COMMENT '当前逾期天数',
  `loan_management_fee` decimal(16,2) DEFAULT NULL COMMENT '贷款管理费用',
  `plat_service_fee` decimal(16,2) DEFAULT NULL COMMENT '平台服务费用',
  `credit_manage_fee` decimal(16,2) DEFAULT NULL COMMENT '征信费用',
  `poundage` decimal(16,2) DEFAULT NULL COMMENT '手续费',
  `is_sync` int(11) NOT NULL COMMENT '数据是否已经同步',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `rmt_loan_id` varchar(64) COLLATE utf8mb4_bin NOT NULL COMMENT '贷款ID',
  `rmt_user_id` varchar(64) COLLATE utf8mb4_bin NOT NULL COMMENT '用户ID',
  `is_settled` int(11) NOT NULL COMMENT '贷款是否结清',
  `bank_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行名称',
  `bank_card_no` varchar(400) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行卡号',
  `risk_code` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '风险等级代码',
  `partner_code` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '资金方名称',
  `credit_nvestigation` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否上传征信',
  `loan_order_id` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '贷款单号(携程产品专用)',
  `batch_remark` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '批量备注',
  `did_total_term` int(11) DEFAULT NULL COMMENT '未还总期数',
  `over_due_total_fine` decimal(19,3) DEFAULT NULL COMMENT '逾期总罚息',
  `over_due_total_principal` decimal(19,3) DEFAULT NULL COMMENT '逾期总本金',
  `over_due_total_interest` decimal(19,3) DEFAULT NULL COMMENT '逾期总利息',
  `factor_status` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_data_account_acct_no` (`acct_no`),
  KEY `idx_data_account_app_no` (`app_no`),
  KEY `idx_data_account_cust_no` (`cust_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='账户信息表';


-- welab_skyeye.data_customer_test definition

CREATE TABLE `data_customer_test` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `batch_date` date DEFAULT NULL COMMENT '批量日期',
  `org` char(12) COLLATE utf8mb4_bin NOT NULL COMMENT '机构号',
  `cust_no` varchar(50) COLLATE utf8mb4_bin NOT NULL COMMENT '客户编号',
  `cust_flag` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户标签',
  `mobile` varchar(80) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '手机号码',
  `cust_name` varchar(80) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户姓名',
  `id_type` varchar(5) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型',
  `id_no` varchar(400) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件号码',
  `sex` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `marital_status` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻状况',
  `email` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `education` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '教育水平',
  `permanent_address` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '户籍地址',
  `now_address` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '居住地址',
  `ca_company` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司名称',
  `ca_addr` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司地址',
  `ca_type` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司类型',
  `ca_industry_type` varchar(96) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司所属行业',
  `ca_duty` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职务',
  `ca_enter_time` datetime DEFAULT NULL COMMENT '入职时间',
  `ca_work_year` int(11) DEFAULT NULL COMMENT '工作年限',
  `ca_total_monthly_income` decimal(19,2) DEFAULT NULL COMMENT '月薪',
  `sc_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学校名称',
  `sc_addr` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学校地址',
  `rmt_user_id` varchar(64) COLLATE utf8mb4_bin NOT NULL COMMENT '用户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `data_customer_cust_no` (`cust_no`),
  KEY `data_customer_batch_date` (`batch_date`)
) ENGINE=InnoDB AUTO_INCREMENT=33485 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='客户信息表';


-- welab_skyeye.data_customer_test2 definition

CREATE TABLE `data_customer_test2` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `batch_date` date DEFAULT NULL COMMENT '批量日期',
  `org` char(12) COLLATE utf8mb4_bin NOT NULL COMMENT '机构号',
  `cust_no` varchar(50) COLLATE utf8mb4_bin NOT NULL COMMENT '客户编号',
  `cust_flag` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户标签',
  `mobile` varchar(80) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '手机号码',
  `cust_name` varchar(80) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户姓名',
  `id_type` varchar(5) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型',
  `id_no` varchar(400) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件号码',
  `sex` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `marital_status` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻状况',
  `email` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `education` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '教育水平',
  `permanent_address` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '户籍地址',
  `now_address` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '居住地址',
  `ca_company` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司名称',
  `ca_addr` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司地址',
  `ca_type` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司类型',
  `ca_industry_type` varchar(96) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司所属行业',
  `ca_duty` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职务',
  `ca_enter_time` datetime DEFAULT NULL COMMENT '入职时间',
  `ca_work_year` int(11) DEFAULT NULL COMMENT '工作年限',
  `ca_total_monthly_income` decimal(19,2) DEFAULT NULL COMMENT '月薪',
  `sc_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学校名称',
  `sc_addr` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学校地址',
  `rmt_user_id` varchar(64) COLLATE utf8mb4_bin NOT NULL COMMENT '用户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `data_customer_cust_no` (`cust_no`),
  KEY `data_customer_batch_date` (`batch_date`)
) ENGINE=InnoDB AUTO_INCREMENT=32290 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='客户信息表';


-- welab_skyeye.data_lineage_dataset_ref definition

CREATE TABLE `data_lineage_dataset_ref` (
  `source_id` bigint(20) DEFAULT NULL,
  `target_id` bigint(20) DEFAULT NULL COMMENT '目标id',
  `job_id` bigint(20) NOT NULL COMMENT '任务id',
  `task_id` varchar(50) DEFAULT NULL COMMENT '任务明细id',
  `task_desc` longtext COMMENT '关联概要',
  `state` tinyint(1) NOT NULL COMMENT '是否启用 1启用 0禁用',
  `desc` longtext COMMENT '描述',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- welab_skyeye.data_lineage_field_ref definition

CREATE TABLE `data_lineage_field_ref` (
  `source_id` bigint(20) DEFAULT NULL COMMENT '来源id',
  `target_id` bigint(20) DEFAULT NULL COMMENT '目标id',
  `expression` longtext COMMENT '表达式 project',
  `src_table_id` int(8) DEFAULT NULL COMMENT '数据资产-表id',
  `tar_table_id` int(8) DEFAULT NULL COMMENT '数据资产-表id',
  `job_id` bigint(20) NOT NULL COMMENT '任务id',
  `state` tinyint(1) NOT NULL COMMENT '是否启用 1启用 0禁用',
  `desc` longtext COMMENT '描述',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- welab_skyeye.data_lineage_job definition

CREATE TABLE `data_lineage_job` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '名称',
  `type` tinyint(1) NOT NULL COMMENT '类型:0:开发平台，1:数据湖，2:分析平台，3:SQL，4.模型，5:其它',
  `record_rule_id` bigint(20) DEFAULT NULL COMMENT '关联id',
  `task_id` varchar(50) DEFAULT NULL COMMENT '关联id',
  `task_desc` longtext COMMENT '关联概要',
  `state` tinyint(1) NOT NULL COMMENT '是否启用 1启用 0禁用',
  `desc` longtext COMMENT '描述',
  `gmt_create` datetime NOT NULL COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL COMMENT '更新时间',
  `app_id` varchar(100) NOT NULL COMMENT '应用标识',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`type`,`task_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6241 DEFAULT CHARSET=utf8mb4 COMMENT='任务血缘';


-- welab_skyeye.data_lineage_job_ref definition

CREATE TABLE `data_lineage_job_ref` (
  `source_id` bigint(20) DEFAULT NULL COMMENT '来源id',
  `target_id` bigint(20) DEFAULT NULL COMMENT '目标id'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- welab_skyeye.data_lineage_record_rule definition

CREATE TABLE `data_lineage_record_rule` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '名称',
  `type` tinyint(1) NOT NULL COMMENT '类型:1:开发平台，2:数据湖，3:分析平台，4:SQL，5.模型，6:其它',
  `execute_desc` longtext COMMENT '执行明细',
  `execute_times` int(10) DEFAULT NULL COMMENT '执行次数',
  `text_md5` varchar(50) NOT NULL COMMENT '摘要信息',
  `result` varchar(50) DEFAULT NULL COMMENT '结果信息',
  `state` tinyint(1) NOT NULL COMMENT '是否启用 1启用 0禁用',
  `has_record` tinyint(1) NOT NULL COMMENT '是否存在血缘 1存在 0不存在',
  `desc` longtext COMMENT '描述',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=483 DEFAULT CHARSET=utf8mb4 COMMENT='任务血缘前置';


-- welab_skyeye.data_lineage_table_conf_exec definition

CREATE TABLE `data_lineage_table_conf_exec` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dataasset_table_id` int(8) NOT NULL COMMENT '数据资产-表id',
  `dataasset_table_conf_id` int(8) NOT NULL COMMENT '数据资产-表id',
  `exec_desc` longtext COMMENT '执行明细',
  `text_md5` varchar(50) NOT NULL COMMENT '摘要信息',
  `status` tinyint(2) NOT NULL DEFAULT '0' COMMENT '表状态（0，有效；1，已删除）',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `change_desc` longtext COMMENT ' 元数 据 改 动 明 细 ',
  `effect_tables` longtext COMMENT ' 影 响 的 表 ',
  `effect_jobs` longtext COMMENT ' 影 响 的 job ',
  PRIMARY KEY (`id`),
  KEY `idx_tableId` (`dataasset_table_id`,`dataasset_table_conf_id`,`text_md5`)
) ENGINE=InnoDB AUTO_INCREMENT=105146 DEFAULT CHARSET=utf8mb4 COMMENT='数 据 血 缘 表 任 务 执 行 明 细';


-- welab_skyeye.data_lineage_table_config definition

CREATE TABLE `data_lineage_table_config` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dataasset_table_id` int(8) NOT NULL COMMENT '数据资产-表id',
  `analysis_flag` tinyint(4) DEFAULT '1' COMMENT '是否影响分析 1,是，0否',
  `alert_flag` tinyint(4) DEFAULT '1' COMMENT '是否告警，1.是，0否',
  `exec_interval` int(4) DEFAULT '1' COMMENT '运行间隔 单位（分钟）',
  `status` tinyint(2) NOT NULL DEFAULT '0' COMMENT '状态（0，有效；1，已删除）',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_tableId` (`dataasset_table_id`)
) ENGINE=InnoDB AUTO_INCREMENT=105063 DEFAULT CHARSET=utf8mb4 COMMENT='血缘表任务配置';


-- welab_skyeye.data_statistic definition

CREATE TABLE `data_statistic` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `task_type` int(10) unsigned NOT NULL COMMENT '任务类型（总线、工坊）',
  `task_id` bigint(20) unsigned NOT NULL COMMENT '数据处理任务的ID',
  `task_name` varchar(200) COLLATE utf8mb4_bin NOT NULL COMMENT '数据处理任务的名称',
  `task_topic` varchar(200) COLLATE utf8mb4_bin NOT NULL COMMENT '数据处理任务订阅的topic',
  `task_open_time` varchar(50) COLLATE utf8mb4_bin NOT NULL COMMENT '任务开启时间',
  `total_count` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '总数',
  `success_count` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '成功',
  `fail_count` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '失败',
  `gmt_statistic` datetime NOT NULL COMMENT '统计时间段',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_period_statistic` (`task_type`,`task_id`,`gmt_statistic`),
  KEY `idx_task_name` (`task_name`),
  KEY `idx_task_topic` (`task_topic`),
  KEY `idx_task_open_time` (`task_open_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='总线、工坊，数据处理统计情况';


-- welab_skyeye.data_type_template definition

CREATE TABLE `data_type_template` (
  `test_int` int(11) NOT NULL,
  `test_int_unsigned` int(10) unsigned NOT NULL,
  `test_varchar` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `test_bigint` bigint(20) NOT NULL,
  `test_bigint_unsigned` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`test_int`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- welab_skyeye.dataasset_column_info definition

CREATE TABLE `dataasset_column_info` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `column_name` varchar(150) COLLATE utf8mb4_bin NOT NULL COMMENT '列名称',
  `column_type` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '列类型',
  `column_comment` varchar(1024) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '列的原生注释',
  `column_alias` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '列别名',
  `dataasset_table_id` int(8) NOT NULL COMMENT '数据资产-表id',
  `has_processed_encrypted` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否做了加密处理（1 表示是，0 表示否）默认0',
  `status` tinyint(2) NOT NULL DEFAULT '0' COMMENT '表状态（0，有效；1，已删除）',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_tableId` (`dataasset_table_id`) USING HASH
) ENGINE=InnoDB AUTO_INCREMENT=880582 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据资产-列信息';


-- welab_skyeye.dataasset_ds_info definition

CREATE TABLE `dataasset_ds_info` (
  `id` int(5) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `ds_id` bigint(10) NOT NULL COMMENT '数据源ID',
  `ds_name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '冗余数据源名称',
  `ds_db_type` int(11) NOT NULL COMMENT '冗余数据源类型',
  `ds_schema_name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '数据源库名称',
  `ds_alias` varchar(150) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '数据源库名称-别名',
  `group_id` bigint(20) DEFAULT '-1' COMMENT '冗余分组id(取的标签分组id)',
  `cur_storage_space` bigint(63) unsigned NOT NULL DEFAULT '0' COMMENT '存储空间大小（单位：B）',
  `cur_rows_count` bigint(20) NOT NULL DEFAULT '0' COMMENT '当前总记录数',
  `started` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启动统计资产任务（默认是）',
  `status` int(2) unsigned NOT NULL DEFAULT '0' COMMENT '状态，0：生效，10连接不通，99强制失效',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_ds_id` (`ds_id`) USING BTREE,
  KEY `idx_groupId` (`group_id`) USING HASH,
  KEY `idx_dbType` (`ds_db_type`) USING HASH
) ENGINE=InnoDB AUTO_INCREMENT=554 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据资产-数据源信息';


-- welab_skyeye.dataasset_overview_summary definition

CREATE TABLE `dataasset_overview_summary` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `ds_count` int(11) NOT NULL DEFAULT '0' COMMENT '实例总数',
  `table_count` bigint(20) NOT NULL DEFAULT '0' COMMENT '表总数',
  `rows_count` bigint(50) NOT NULL DEFAULT '0' COMMENT '记录总数',
  `storage_space` bigint(100) NOT NULL DEFAULT '0' COMMENT '总存储',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10937 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据总览汇总表';


-- welab_skyeye.dataasset_table_info definition

CREATE TABLE `dataasset_table_info` (
  `id` int(8) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `table_name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '表的名称',
  `table_comment` varchar(1024) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '表的业务库原生注释',
  `table_alias` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '表别名',
  `dataasset_ds_id` int(11) NOT NULL COMMENT '数据资产-数据源id',
  `cur_storage_space` bigint(63) unsigned NOT NULL DEFAULT '0' COMMENT '存储空间大小（单位：B）',
  `cur_rows_count` bigint(20) NOT NULL DEFAULT '0' COMMENT '当前总记录数',
  `status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '表状态（0，有效；1，已删除）',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `map_type` tinyint(1) DEFAULT '1' COMMENT '映射类型：1：实际，0：虚拟',
  PRIMARY KEY (`id`),
  KEY `idx_dataassetDsId` (`dataasset_ds_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=60453 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='数据资产-表信息';


-- welab_skyeye.dataasset_task_record definition

CREATE TABLE `dataasset_task_record` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `task_type` tinyint(2) NOT NULL COMMENT '任务类型（0，数据库任务；1，表任务）',
  `task_biz_id` int(11) NOT NULL COMMENT '数据资产-数据源id/表id',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '任务执行时间',
  `before_storage_space` bigint(63) unsigned NOT NULL COMMENT '执行前存储空间大小（单位：B）',
  `before_rows_count` bigint(20) NOT NULL COMMENT '执行前总记录数',
  `after_storage_space` bigint(63) unsigned NOT NULL COMMENT '执行后存储空间大小（单位：B）',
  `after_rows_count` bigint(20) NOT NULL COMMENT '执行后总记录数',
  `remark` mediumtext COLLATE utf8mb4_bin COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_bizId_taskType` (`task_biz_id`,`task_type`) USING BTREE,
  KEY `idx_create` (`gmt_create`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=389726674647336119 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据资产-任务执行日志';


-- welab_skyeye.dataasset_task_record3 definition

CREATE TABLE `dataasset_task_record3` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `task_type` tinyint(2) NOT NULL COMMENT '任务类型（0，数据库任务；1，表任务）',
  `task_biz_id` int(11) NOT NULL COMMENT '数据资产-数据源id/表id',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '任务执行时间',
  `before_storage_space` bigint(63) unsigned NOT NULL COMMENT '执行前存储空间大小（单位：B）',
  `before_rows_count` bigint(20) NOT NULL COMMENT '执行前总记录数',
  `after_storage_space` bigint(63) unsigned NOT NULL COMMENT '执行后存储空间大小（单位：B）',
  `after_rows_count` bigint(20) NOT NULL COMMENT '执行后总记录数',
  `remark` mediumtext COLLATE utf8mb4_bin COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_bizId_taskType` (`task_biz_id`,`task_type`) USING BTREE,
  KEY `idx_create` (`gmt_create`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='数据资产-任务执行日志';