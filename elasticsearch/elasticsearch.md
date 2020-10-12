## elasticsearch安装注意

#### 设置kibana汉化

1. 进入`kibana安装目录\x-pack\plugins\translations\translations`，确认该目录下存在汉化包，一个Json文件 `zh-CN.json
   
2. 打开`kibana安装目录\config\kibana.yml`
   找到`i18n.locale`，如果没找到自行添加如下文本

   ~~~yml
   i18n:
     locale: "zh-CN"
   ~~~

#### 设置elasticsearch跨域

1. 因为elasticsearch-head默认的端口为9100，而elasticseache默认端口为9200。当es-head调用es时会产生跨域问题。

2. 在`elasticsearch安装目录\config\elasticsearch.yml`, 在其中添加

   ~~~yml
   http:
     cors:
       enabled: true
       allow-origin: "*"
   ~~~


#### 安装ik分词器

1. 使用浏览器访问https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.5.1/elasticsearch-analysis-ik-7.5.1.zip，将版本号该为对应的es的版本号，就可以开始下载。版本不一致会导致该es的cmd闪退。

2. 解压该文件到`es安装目录\plugins\ik`

   ![image-20200912224347024](img\image-20200912224347024.png)

   

## ES核心概念
**ES和关系型数据库对比**：

> elasticsearch是面向文档的，一切都是json，关系型数据库和es客观对比

| Relational DB | ElasticSearch                           |
| ------------- | --------------------------------------- |
| 数据库        | 索引（indices）                         |
| 表            | types（7.x中过期，8.x中弃用，了解即可） |
| 行            | documents                               |
| 字段          | fields                                  |

es集群中可以包含多个indices，每个indices中可以包含多个types，每个types下包含多个documents，每个documents中又包含多个fields

**物理设计：**

es在后台把每个索引分成多个分片，每个分片可以在集群中的不同服务器间迁移。

一个人就是一个集群！默认的集群名称就是elasticsearch

![](img\image-20200912211634786.png)

**逻辑设计：**

一个索引类型中，包含多个文档，比如docment1，docment2. 当我们索引一篇文档时，可以通过这样的顺序找到他：索引 》 类型 》 文档ID。通过这个组合我们就能找到具体的某个文档。Note：ID不必是整数，实际上它是一个字符串。

> 文档

之前说es是面向文档的，那么索引和搜索数据的最小单位就是doc， es中doc有几个重要属性：

- 自我包含：一篇文档同时包含字段和对应的值，也就是同时包含key-value。
- 可以是层次型的，一个文档中可以包含自文档，复杂的逻辑就是这么来的。
- 灵活的结构。文档不依赖预先定义的模式，在关系型数据库中，要提前定义字段才能使用，在es中，对于字段是非常灵活的，有时候我们可以忽略该字段，或者动态的添加一个新的字段。

尽管我们可以随意新增和忽略某个字段，但是，每个字段的类型非常重要，比如一个年龄字段类型，可以是字符串也可以是整形。因为es会保存字段和类型之间的映射以其他设置。这种映射具体到每个映射的每种类型，这也是为什么在es中，类型有时候也成为映射类型。

> 索引

索引是一个非常大的文档集合。索引存储了映射类型的字段和其他设置。然后他们被存储在各个分片上。

**物理设计：节点和分片如何工作**

一个集群至少一个节点，而一个节点就是一个es进程，节点可以有多个索引默认。每个索引是多个分片（primary shard，又称主分片）构成的，每个主分片又会有多个副本（replica shard，又称复制分片）。

![](img\image-20200912214951113.png)

上图是一个有3个节点的集群，可以看到每个主分片和对应的复制分片都不会再同一个节点内，这样有利于某个节点挂掉，数据也会至于丢失。这一点和kafka相似，每个topic由多个分区构成，分区又有副本。同时分区和副本不会在同一个机器上。

> 倒排索引





## ik分词器

#### ik_smart

最粗粒度划分，分词不会重复，例如`中华人民共和国人民大会堂`会分词为`中华人民共和国`和`人民大会堂`

![image-20200912233048564](img\image-20200912233048564.png)



#### ik_max_word

最细粒度划分，会尽可能多的获取词汇的组合，例如中华人民共和国，会被划分为`中华人民共和国`和`中华人民`和`中华`和`华人`和`人民共和国`和`人民`和`共和国`等等

![image-20200912233013689](img\image-20200912233013689.png)

#### ik分词器配置扩展字典

- 进入到`es安装目录\plugins\ik\config`目录下面

- 新建自己的词典（`建议复制之前的dic文件进行使用，否则容易导致文件无法识别从而扩展失败`），kuang.dic, 并且在kuang.dic中输入自己想要扩展的词汇例如`狂神说`

  ![image-20200912234138718](img\image-20200912234138718.png)

- 编辑`es安装目录\plugins\ik\config`目录下的`IKAnalyzer.cfg.xml`,在其中配置自己新建的词典。多个词典配置多个`ext_dic`选项

  ![image-20200912234526625](img\image-20200912234526625.png)

- 重启es，发送请求，ik分词器已经能够识别狂神说这个单词了。图片中两个请求结果一致。

  ![image-20200912235819169](img\image-20200912235819169.png)



#### ES Rest风格说明

| Method |                     url地址                     |         描述         |
| :----: | :---------------------------------------------: | :------------------: |
|  PUT   |     localhost:9200/索引名称/类型名称/文档id     | 创建文档，指定文档id |
|  POST  |        localhost:9200/索引名称/类型名称         | 创建文档，随机文档id |
|  POST  | localhost:9200/索引名称/类型名称/文档id/_update |       修改文档       |
| DELETE |     localhost:9200/索引名称/类型名称/文档id     |       删除文档       |
|  GET   |     localhost:9200/索引名称/文档名称/文档id     |  通过文档id查询文档  |
|  POST  |    localhost:9200/索引名称/类型名称/_search     |     查询所有数据     |

> 新建/覆盖一个文档，没有索引会自动创建

~~~
PUT /{index}/_doc/{id}
{
  ...upsert的数据
}
~~~

> 修改一个文档

~~~
POST /{index}/_doc/_update
{
  "doc":{
    需要修改的数据，未修改的数据保持原样
  }
}
~~~

> 删除索引

~~~
DELETE {index}
~~~

> 查询文档

~~~

~~~





# Elastic Stack

## ElasticSeach 与Kibaba入门

#### ElasticSearch 配置文件

> elasticsearch.yml



> jvm.option jvm的相关参数

> log42.properties 日志相关配置


## Beats与Filebea入门