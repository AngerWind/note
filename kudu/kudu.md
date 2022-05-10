### Kudu使用Impala指定副本数量

https://blog.csdn.net/weixin_30367543/article/details/98326443

https://kudu.apache.org/docs/kudu_impala_integration.html

副本数量只能在创建表时指定，创建后不能修改，并且副本数量必须为奇数，并且副本数量不能多于Kudu Tablet的数量



