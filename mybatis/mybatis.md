#### mybatis 在xml中引入静态常亮，枚举类，静态方法

> 语法

~~~sql
${@全类名$内部类或者枚举类@属性或者方法}
~~~

> 枚举类

~~~java
package com.tiger
public enum Season{
    Spring("春"),
    Summer("夏"),
    Autumn("秋"),
    Winter("冬")
        
    public String season;
    public Season(String season){
        this.season = season
    }
}
~~~

~~~xml
<select id='testSelectA' .....>
  select * from tableA where season=${@com.tiger.Season$Spring.value}
</select>
~~~

> 静态方法和静态常亮

https://blog.csdn.net/chenliang2623/article/details/100840838

ongl中：

比如我有一个工具类com.wts.test.DateUtil，其中有一个方法isLeapYear(int year)，用于判断某年是否闰年。而在mapper的某个select中要根据是否闰年执行不同的查询。可以类似这样：

```xml
<if test="@com.wts.test.DateUtil@isLeapYear(year)==true">
  select * from tableA
</if>
```

如果要使用常量的话，假设有常量类和常量Constant.CURRENT_YEAR：

```xml
<if test=year==@com.wts.test.Consant@CURRENT_YEAR>
	select * from tableC
</if>
```



sql中：

使用静态方法：

```xml
<select id='testSelectA' .....>
  select * from tableA where year=${@com.wts.test.DateUtil@getYear()}
</select>
```

使用静态常量：

```xml
<select id='testSelectB' .....>
	select * from tableA where year=${@com.wts.test.Constant@CURRENT_YEAR}
</select>
```



#### mybatis #与$的区别

- #将传入的数据都当成一个字符串，会自动为传入的数据添加一个单引号，而$只是字符串拼接

  下面的两条语句，分别传入id = 1，将被编译成

  ~~~xml
  select id,name,age from student where id =#{id}
  select id,name,age from student where id =${id}
  ~~~

  ~~~sql
  select id,name,age from student where id ='1'
  select id,name,age from student where id = 1
  ~~~

- #可以防止sql注入，而$不行，所以应当优先使用#{}

  下面的语句

  ~~~sql
  select * from ${tableName} where name = #{name}
  select * from #{tableName} where name = #{name}
  ~~~

  当tableName为user; delete user; --时将被编译为

  ~~~sql
  select * from user; delete user; -- where name = ?
  select * from 'user; delete user; --' where name = ?
  ~~~

- 在group by 和 order by的时候必须使用${}

  如下的语句

  ~~~sql
  select * from tableA group by ${columnA} order by #{columnB}
  ~~~

  传入columnA为id， columnB为createTime时被编译为，然而我们是要对createTime字段进行排序，而不是字符串createTime，所以只能使用${}

  ~~~sql
  select * from tableA group by id order by 'createTime'
  ~~~

- 处理时机不同。

  如果是下面的sql, 传入name为zhangsan：

  ~~~xml
  select * from ${tableName} where name = #{name}
  ~~~

  #{}在预处理的时候，会把参数变成一个占位符？代替

  ~~~sql
  select * from user where name = ?
  ~~~

  而${}只是在动态解析阶段做简单的字符串替换

  ~~~sql
  select * from user where name = 'zhangsan'
  ~~~



