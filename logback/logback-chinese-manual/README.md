# logback-chinese-manual
logback 中文手册
> 翻译自 [The logback manual](https://logback.qos.ch/manual/index.html)  

[在线地址](https://logbackcn.gitbook.io/logback/)  

## 简介

Logback 继承自 log4j。

Logback 的架构非常的通用，适用不同的使用场景。Logback 被分成三个不同的模块：logback-core，logback-classic，logback-access。

logback-core 是其它两个模块的基础。logback-classic 模块可以看作是 log4j 的一个优化版本，它天然的支持 SLF4J，所以你可以随意的从其它日志框架（例如：log4j 或者 java.util.logging）切回到 logack。

logback-access 可以与 Servlet 容器进行整合，例如：Tomcat、Jetty。它提供了 http 访问日志的功能。

## The logback manual

手册包括了最新版本的 logback，总共有 150 多页，以及许多具体的例子，主要包含以下基本的和高级的特性：

- logback 的整体架构
- 讨论 logback 最好的实践以及反模式
- logback 的 xml 配置方式
- appender
- encoder
- layout
- filter
- 上下文诊断
- Joran - logback 的配置系统

logback 手册尽可能详细的描述了 logback API，包括它的特性以及设计原理。logback 手册适用于那些使用 java 但是是 logback 新手的人，也适合那些对 logback 有一定经验的人。在手册的帮助下，新手可以快速上手。

* [第一章：logback 介绍](logback/logback-chinese-manual/01_第一章_logback介绍.md)
* [第二章：架构](logback/logback-chinese-manual/02第二章_架构.md)
* [第三章：logback 的配置](logback/logback-chinese-manual/03第三章_logback的配置)
* [第四章：Appenders](logback/logback-chinese-manual/04第四章_Appenders) 
* [第五章：Encoder](logback/logback-chinese-manual/05第五章_Encoder)   
* [第六章：Layouts](logback/logback-chinese-manual/06第六章_Layouts)
* [第七章：Filters](logback/logback-chinese-manual/07第七章_Filters)
* [第八章：MDC](logback/logback-chinese-manual/08第八章_MDC)
* [第九章：日志隔离](logback/logback-chinese-manual/09第九章_日志隔离)
* [第十章：JMX 配置器](logback/logback-chinese-manual/10第十章_JMX配置器)
* [第十一章：Joran](logback/logback-chinese-manual/11第十一章_Joran)
* [第十二章：Groovy 配置](logback/logback-chinese-manual/12第十二章_Groovy配置)
* [第十三章：从 log4j 迁移](logback/logback-chinese-manual/13第十三章_从log4j迁移)
* [第十四章：Receivers](logback/logback-chinese-manual/14第十四章_Receivers)
* [第十五章：使用 SSL](logback/logback-chinese-manual/15第十五章_使用SSL)
