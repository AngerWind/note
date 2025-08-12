# 使用Junit

具体代码查看`example4test/example4test-with-junit5`

### 使用Junit5进行单元测试

1. 导入依赖

   ~~~xml
    <dependencies>
           <dependency>
               <!-- 导入junit5的依赖 -->
               <groupId>org.junit.jupiter</groupId>
               <artifactId>junit-jupiter-engine</artifactId>
               <version>5.5.2</version>
               <scope>test</scope>
           </dependency>
       </dependencies>
   
       <build>
           <plugins>
               <plugin>
                   <groupId>org.apache.maven.plugins</groupId>
                   <artifactId>maven-compiler-plugin</artifactId>
                   <version>3.8.1</version>
               </plugin>
               <plugin>
                   <!-- 这个插件会绑定到maven的test声明周期, 并执行测试用例, 比如junit5 -->
                   <!-- 如果不添加这个plugin, 那么就算执行到了test生命周期, 也不会执行测试用例, 所以一定要配置这个插件 -->
                   <groupId>org.apache.maven.plugins</groupId>
                   <artifactId>maven-surefire-plugin</artifactId>
                   <version>3.2.5</version>
               </plugin>
           </plugins>
       </build>
   ~~~

2. 我们创建一个类, 用来进行业务测试

   ~~~java
   public class MathTools {
       public static double convertToDecimal(int numerator, int denominator) {
           if (denominator == 0) {
               throw new IllegalArgumentException("Denominator must not be 0");
           }
           return (double)numerator / (double)denominator;
       }
   }
   ~~~

3. 创建一个测试类, 对上面的类convertToDecimal方法进行单元测试

   ~~~java
   class MathToolsTest {
       /**
        * 测试正常情况, 使用@DisplayName注解指定测试的名称
        */
       @Test
       @DisplayName("测试正常情况")
       void testConvertToDecimalSuccess() {
           double result = MathTools.convertToDecimal(3, 4);
           // 对结果进行断言
           Assertions.assertEquals(0.75, result);
       }
   
       /**
        * 测试异常情况
        */
       @Test
       @DisplayName("测试异常情况")
       void testConvertToDecimalInvalidDenominator() {
           Assertions.assertThrows(IllegalArgumentException.class, () -> MathTools.convertToDecimal(3, 0));
       }
   }
   ~~~

   上面我们可以使用@DisplayName来对测试用例进行命名

4. 执行maven的测试命令

   ~~~shell
   mvn clean test
   ~~~

   如果你是在idea中的话, 可以点击maven侧边栏的test按钮



### Junit5中的Assertions断言

在junit5中, 我们可以使用Assertions这个类来对我们的业务进行断言

该方法的使用说明如下:

~~~java
package com.example;

import org.junit.jupiter.api.*;

import java.time.Duration;
public class _02_AssertionsTest {

    /**
     * Assertions的使用比较简单, 当前类主要列举了部分常用的方法
     */
    @Test
    public void testAssertions() {

        int a = 5;
        int c = 5;
        // 断言相等和不相等, 内部调用equals
        Assertions.assertEquals(10, a + c);
        Assertions.assertNotEquals(15, a + c);

        // 断言引用相等和不相等, 内部调用 ==
        Assertions.assertNotSame(new Object(), new Object());
        Assertions.assertSame(Integer.valueOf("1"), Integer.valueOf("1"));

        // 断言数组相等和不相等
        int[] arr1 = {1, 2, 3};
        int[] arr2 = {1, 2, 3};
        Assertions.assertArrayEquals(arr1, arr2);

        // 断言true和false
        int c1 = 10;
        int c2 = 10;
        int c3 = 11;
        Assertions.assertTrue(c1 < c3);
        Assertions.assertFalse(c1 > c2);

        // 断言null和not null
        Assertions.assertNull(null);
        Assertions.assertNotNull("Hello");

        // 断言抛出异常
        Assertions.assertThrows(ArithmeticException.class, () -> {
            int x = 10 / 0;
        });
        // 断言不抛出异常
        Assertions.assertDoesNotThrow(() -> {
            System.out.println("Hello");
        });

        // 断言如下代码不会超时
        // 注意, executable会在当前线程中执行, 如果executable执行超时了, 那么会一直卡住, 直到executable执行完毕
        Assertions.assertTimeout(Duration.ofSeconds(10), () -> {
            Thread.sleep(5 * 1000);
        });
        // 断言如下代码不会超时, executable会在新线程中执行, 如果executable执行超时了, 那么会中断executable线程
        Assertions.assertTimeoutPreemptively(Duration.ofSeconds(10), () -> {
            Thread.sleep(5 * 1000);
        });
    }
}
~~~



### Junit5测试的生命周期

~~~java
public class _03_LifecycleTest {

    @BeforeAll
    static void beforeAll() {
        // 静态方法, 在所有测试运行前执行一次
        System.out.println("Connect to the database");
    }
    
    @AfterAll
    static void afterAll() {
        // 静态方法, 在所有测试运行后执行一次
        System.out.println("Disconnect from the database");
    }

    @BeforeEach
    void beforeEach() {
        // 每个测试方法运行前执行
        System.out.println("Load the schema");
    }

    @AfterEach
    void afterEach() {
        // 每个测试方法运行后执行
        System.out.println("Drop the schema");
    }
    
    @Test
    void test1() {
        System.out.println("Test 1");
    }

    @Test
    void test2() {
        System.out.println("Test 2");
    }
}
~~~

上面代码打印如下

~~~txt
Connect to the database
Load the schema
Test 1
Drop the schema
Load the schema
Test 2
Drop the schema
Disconnect from the database
~~~



### Junit5分组测试

分组测试主要用在对不同环境下, 执行特定分类的测试用例

~~~java
// 定义当前测试类的分组为Development
@Tag("Development")
class TestOne {
    @Test
    void testOne() {
        System.out.println("Test 1");
    }
}

@Tag("Development")
class TestTwo {
    @Test
    void testTwo() {
        System.out.println("Test 2");
    }
}

@Tag("Production")
class TestThree {
    @Test
    void testThree() {
        System.out.println("Test 3");
    }
}
~~~

使用如下命令行来仔细`Development`分组的测试用例

~~~bash
# groups和excludedGroups分别指定要包含/排除的group
# 多个group使用逗号隔开
mvn clean test -Dgroups="Development" -DexcludedGroups="Production"
~~~



### Junit5 @Disable

当我们希望在运行测试类时，跳过某个测试方法，正常运行其他测试用例时，我们就可以用上 @Disabled 注解，表明该测试方法处于不可用，执行测试类的测试方法时不会被 JUnit 执行。

~~~java
@DisplayName("我的第三个测试")
@Disabled // 禁用当前这个测试
@Test
void testThirdTest() {
	System.out.println("我的第三个测试开始测试");
}
~~~





### Junit5 @Nested

当我们编写的类和代码逐渐增多，随之而来的需要测试的对应测试类也会越来越多。为了解决测试类数量爆炸的问题，JUnit 5提供了@Nested 注解，能够以静态内部成员类的形式对测试用例类进行逻辑分组。 并且每个静态内部类都可以有自己的生命周期方法， 这些方法将按从外到内层次顺序执行。 此外，嵌套的类也可以用@DisplayName 标记，这样我们就可以使用正确的测试名称。下面看下简单的用法：

```java
@DisplayName("内嵌测试类")
public class NestUnitTest {
    @BeforeEach
    void init() {
        // 会在每一个@Test方法执行之前执行
        System.out.println("测试方法执行前准备");
    }

    @Nested
    @DisplayName("第一个内嵌测试类")
    class FirstNestTest {
        @Test
        void test() {
            System.out.println("第一个内嵌测试类执行测试");
        }
    }

    @Nested
    @DisplayName("第二个内嵌测试类")
    class SecondNestTest {
        @Test
        void test() {
            System.out.println("第二个内嵌测试类执行测试");
        }
    }
}
```

运行所有测试用例后，在控制台能看到如下结果：



### Junit5与hamcrest断言库结合使用

上面我们讲了, 在Junit5中自带一个Assertions类用来对我们的代码进行断言, 但是我们会发现这个自带的Assertions类的功能过于简单, 只能对是否相等, 是否抛出异常, 是否执行超时进行断言

对于一些复杂的断言, 他就无能为力了, 所以junit也可以和其他第三方的断言库进行集成, 包括AssertJ, Hamcrest, Truth等等



下面我们演示Hamcrest和Junit5结合使用

1. 添加依赖

   ~~~xml
   <dependencies>
           <dependency>
               <!-- 导入junit5的依赖 -->
               <groupId>org.junit.jupiter</groupId>
               <artifactId>junit-jupiter-engine</artifactId>
               <version>5.5.2</version>
               <scope>test</scope>
           </dependency>
   
   
           <dependency>
               <!-- 演示hamcrest断言库 -->
               <groupId>org.hamcrest</groupId>
               <artifactId>hamcrest-library</artifactId>
               <version>2.2</version>
               <scope>test</scope>
           </dependency>
       </dependencies>
   
       <build>
           <plugins>
               <plugin>
                   <groupId>org.apache.maven.plugins</groupId>
                   <artifactId>maven-compiler-plugin</artifactId>
                   <version>3.8.1</version>
               </plugin>
               <plugin>
                   <!-- 这个插件会绑定到maven的test声明周期, 并执行测试用例, 比如junit5 -->
                   <!-- 如果不添加这个plugin, 那么就算执行到了test生命周期, 也不会执行测试用例 -->
                   <groupId>org.apache.maven.plugins</groupId>
                   <artifactId>maven-surefire-plugin</artifactId>
                   <version>3.2.5</version>
               </plugin>
           </plugins>
       </build>
   ~~~

2. 在测试用例中使用Hamcrest

   我们可以使用`org.hamcrest.MatcherAssert.assertThat`方法来进行断言, 如下

   ~~~java
   import org.junit.jupiter.api.DisplayName;
   import org.junit.jupiter.api.Test;
   
   import java.util.ArrayList;
   import java.util.List;
   
   import static org.hamcrest.MatcherAssert.assertThat;
   import static org.hamcrest.Matchers.*;
   
   public class _04_HamcrestAssertTest {
   
       @Test
       @DisplayName("String Examples")
       void stringExamples() {
           String s1 = "Hello";
           String s2 = "Hello";
   
           assertThat("Comparing Strings", s1, is(s2));
           assertThat(s1, equalTo(s2));
           assertThat(s1, sameInstance(s2));
           assertThat("ABCDE", containsString("BC"));
           assertThat("ABCDE", not(containsString("EF")));
       }
   
       @Test
       @DisplayName("List Examples")
       void listExamples() {
           // Create an empty list
           List<String> list = new ArrayList<>();
           assertThat(list, isA(List.class));
           assertThat(list, empty());
   
           // Add a couple items
           list.add("One");
           list.add("Two");
           assertThat(list, not(empty()));
           assertThat(list, hasSize(2));
           assertThat(list, contains("One", "Two"));
           assertThat(list, containsInAnyOrder("Two", "One"));
           assertThat(list, hasItem("Two"));
       }
   
       @Test
       @DisplayName("Number Examples")
       void numberExamples() {
           assertThat(5, lessThan(10));
           assertThat(5, lessThanOrEqualTo(5));
           assertThat(5.01, closeTo(5.0, 0.01));
       }
   }
   ~~~

   

Hamcrest常见的断言方法如下

- **Objects**: `equalTo`, `hasToString`, `instanceOf`, `isCompatibleType`, `notNullValue`, `nullValue`, `sameInstance`
  **对象**： `equalTo` 、 `hasToString` 、 `instanceOf` 、 `isCompatibleType` 、 `notNullValue` 、 `nullValue` 、 `sameInstance`
- **Text**: `equalToIgnoringCase`, `equalToIgnoringWhiteSpace`, `containsString`, `endsWith`, `startsWith`
  **文本**： `equalToIgnoringCase` 、 `equalToIgnoringWhiteSpace` 、 `containsString` 、 `endsWith` 、 `startsWith`
- **Numbers**: `closeTo`, `greaterThan`, `greaterThanOrEqualTo`, `lessThan`, `lessThanOrEqualTo`
  **数字**： `closeTo` 、 `greaterThan` 、 `greaterThanOrEqualTo` 、 `lessThan` 、 `lessThanOrEqualTo`
- **Logical**: `allOf`, `anyOf`, `not`
  **逻辑**： `allOf` 、 `anyOf` 、 `not`
- **Collections**: `array` (compare an array to an array of matchers), `hasEntry`, `hasKey`, `hasValue`, `hasItem`, `hasItems`, `hasItemInArray`
  **Collections** : `array` (将数组与匹配器数组进行比较), `hasEntry` , `hasKey` , `hasValue` , `hasItem` , `hasItems` , `hasItemInArray`





### 使用Mockito模拟对象

https://www.infoworld.com/article/2257253/junit-5-tutorial-part-1-unit-testing-with-junit-5-mockito-and-hamcrest.html

上面我们只讲了不依赖于外部依赖项的简单方法，但这对于大型应用程序来说是很不正常的。

例如，我们的业务可能依赖数据库或者远程调用来获取数据。那么我们如何在这样的类中测试方法呢？我们如何模拟有问题的情况，例如数据库连接错误或超时？

模拟对象的策略是分析被测试的类并创建其所有依赖项的模拟版本，从而创建我们想要测试的场景。您可以手动完成此操作（这需要大量工作），或者您可以利用 Mockito 等工具，它简化了模拟对象的创建和注入到您的类中的过程。 Mockito 提供了一个简单的 API 来创建依赖类的模拟实现、将模拟注入到您的类中以及控制模拟的行为。

比如我们有如下一个数据库操作类

~~~java
public class Repository {
    public List<String> getStuff() throws SQLException {
        // Execute Query

        // Return results
        return Arrays.asList("One", "Two", "Three");
    }
}
~~~

我们服务依赖于这个Repository来操作数据库

~~~java
public class Service {
    private Repository repository;

    public Service(Repository repository) {
        this.repository = repository;
    }

    public List<String> getStuffWithLengthLessThanFive() {
        try {
            // 返回获取到的所有长度小于5的字符串
            return repository.getStuff().stream()
                    .filter(stuff -> stuff.length() < 5)
                    .collect(Collectors.toList());
            // 如果数据库抛出了异常, 那么就返回一个空列表
        } catch (SQLException e) {
            // 如果数据库抛出了异常, 那么就返回一个空列表
            return Arrays.asList();
        }
    }
}
~~~

此时我们想要测试Repository在正常, 异常情况下, getStuffWithLengthLessThanFive的表现会如何, 但是我们总不能在数据库中插入一些数据, 然后测试一下正常的情况, 然后有关闭数据库, 然后强制getStuff抛出SQLException来测试异常情况吧

所以这个时候我们就需要借助Mockito, 来模拟Repository在正常或者异常情况下的行为, 然后看看我们的getStuffWithLengthLessThanFive表现会如何

我们首先需要导入mockito依赖

~~~xml
<dependencies>
        <dependency>
            <!-- 导入junit5的依赖 -->
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter-engine</artifactId>
            <version>5.5.2</version>
            <scope>test</scope>
        </dependency>


        <dependency>
            <!-- 演示hamcrest断言库 -->
            <groupId>org.hamcrest</groupId>
            <artifactId>hamcrest-library</artifactId>
            <version>2.2</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <!-- mockito与junit集成的包, 该包包含了所有mockito所需要的包 -->
            <groupId>org.mockito</groupId>
            <artifactId>mockito-junit-jupiter</artifactId>
            <version>2.23.4</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
            </plugin>
            <plugin>
                <!-- 这个插件会绑定到maven的test声明周期, 并执行测试用例, 比如junit5 -->
                <!-- 如果不添加这个plugin, 那么就算执行到了test生命周期, 也不会执行测试用例 -->
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
            </plugin>
        </plugins>
    </build>
~~~



下面是测试代码

~~~java
import org.junit.jupiter.*;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

// 让Junit加载Mockito扩展, 这样Mockito就加载到了Junit中了
@ExtendWith(MockitoExtension.class)
class ServiceTest {
    
    // MockitoExtension会创建Repository代理, 并注入进来
    @Mock
    Repository repository;

    // MockitoExtension会创建Service对象, 并注入进来, 同时通过setter/构造函数将Repository注入到Service中
    @InjectMocks
    Service service;

    @Test
    void testSuccess() {
        
        try {
            // 设置Repository Mock对象的行为
            // 指定在调用repository.getStuff()的时候, 需要返回特定的结果集
            Mockito.when(repository.getStuff()).thenReturn(Arrays.asList("A", "B", "CDEFGHIJK", "12345", "1234"));
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 执行我们要测试的方法
        List<String> stuff = service.getStuffWithLengthLessThanFive();

        // 验证结果
        Assertions.assertNotNull(stuff);
        Assertions.assertEquals(3, stuff.size());
    }

    @Test
    void testException() {
        
        try {
            // 指定当我们调用代理对象的getStuff()时, 需要抛出异常
            Mockito.when(repository.getStuff()).thenThrow(new SQLException("Connection Exception"));
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 执行我们的测试代码
        List<String> stuff = service.getStuffWithLengthLessThanFive();

        // 验证结果
        Assertions.assertNotNull(stuff);
        Assertions.assertEquals(0, stuff.size());
    }
}
~~~

在上面代码中

1. 我们实现使用`@ExtendWith`这个注解,  `@ExtendWith`注释用于加载 JUnit 5 扩展。

   JUnit 定义了一个扩展 API，它允许像 Mockito 这样的第三方供应商连接到正在运行的测试类的生命周期并添加附加功能。

2. `MockitoExtension`查找测试类，查找使用@Mock注释的属性, 并创建他的代理对象

3. `MockitoExtension`查找使用`@InjectMocks`进行注释的属性, 创建他的对象, 并传入上面我们创建的代理对象到构造函数中

4. `MockitoExtension`尝试 setter 注入将其他的Mock对象注入到InjectMocks对象中

我们可以调用`Mockito.when`来定义Repository代理对象的方法被调用时的行为, 这样我们就可以测试出我们的getStuffWithLengthLessThanFive在不同情况下会有什么样的表现了



如果你不想将Repository定义为字段的话, 那么也可以将Repository放在测试方法的参数上

~~~java
    // 将Mock对象放在测试参数上    
@Test
    void testSuccess(@Mock Repository repository;) {
        
        try {
            // 设置Repository Mock对象的行为
            // 指定在调用repository.getStuff()的时候, 需要返回特定的结果集
            Mockito.when(repository.getStuff()).thenReturn(Arrays.asList("A", "B", "CDEFGHIJK", "12345", "1234"));
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 执行我们要测试的方法
        List<String> stuff = service.getStuffWithLengthLessThanFive();

        // 验证结果
        Assertions.assertNotNull(stuff);
        Assertions.assertEquals(3, stuff.size());
    }
~~~

# 使用Junit5测试SpringBoot

#### 创建SpringBoot项目

首先我们需要创建一个springboot项目, 该项目使用mybatis作为rom框架

具体代码查看example4test/example4test-with-springboot

pom文件如下

~~~xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.example</groupId>
        <artifactId>example4test</artifactId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <groupId>com.example</groupId>
    <artifactId>example4springboot</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>example4springboot</name>
    <description>example4springboot</description>
    <properties>
        <java.version>17</java.version>
    </properties>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>3.3.3</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <!-- 这个依赖包中已经包含了
                   1. hamcrest: 第三方断言库
                   2. junit-jupiter
                   3. mockito-core: mockito的核心库
                   4. mockito-junit-jupiter: mockito与junit5集成包
                   5. spring-test: 用于测试spring的包
                   6. spring-boot-test: 用于测试springboot的包-->
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.28</version>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>3.0.3</version>
        </dependency>
        <dependency>
            <!-- 测试mybatis -->
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter-test</artifactId>
            <version>3.0.3</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
~~~

应用类如下:

~~~java
@SpringBootApplication
@MapperScan("com.example.example4springboot.mapper")
public class Example4springbootApplication {

    public static void main(String[] args) {
        SpringApplication.run(Example4springbootApplication.class, args);
    }
}
~~~

实体类如下:

~~~java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Widget {

    private Long id;
    private String name;
    private String description;
    private Integer version;

    public Widget(String name, String description) {
        this.name = name;
        this.description = description;
    }
    public Widget(String name, String description, Integer version) {
        this.name = name;
        this.description = description;
        this.version = version;
    }
}
~~~

Mapper类如下:

~~~sql
@Mapper
public interface WidgetMapper {

    @Select("select * from widget where id = #{id}")
    Optional<Widget> findById(Long id);

    @Select("select * form widget")
    List<Widget> findAll();

    @Insert("insert into widget(name, description, version) values ( #{name}, #{description}, #{version})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int save(Widget widget);

    @Delete("delete from widget where id = #{id} ")
    int deleteById(Long id);
}
~~~

Service类如下:

~~~java
public interface WidgetService {
    Optional<Widget> findById(Long id);
    List<Widget> findAll();
    Widget save(Widget widget);
    void deleteById(Long id);
}
@Service
public class WidgetServiceImpl implements WidgetService {

    private WidgetMapper widgetMapper;

    // 构造函数注入
    public WidgetServiceImpl(WidgetMapper widgetMapper) {
        this.widgetMapper = widgetMapper;
    }

    @Override
    public Optional<Widget> findById(Long id) {
        return widgetMapper.findById(id);
    }

    @Override
    public List<Widget> findAll() {
        return widgetMapper.findAll();
    }

    @Override
    public Widget save(Widget widget) {
        // Increment the version number
        widget.setVersion(widget.getVersion() + 1);

        // Save the widget to the repository
        widgetMapper.save(widget);

        return widget;
    }

    @Override
    public void deleteById(Long id) {
        widgetMapper.deleteById(id);
    }
}
~~~

Controller类如下:

~~~java
@RestController
public class WidgetRestController {
    private static final Logger logger = LogManager.getLogger(WidgetRestController.class);

    @Autowired
    private WidgetService widgetService;

    @GetMapping("/rest/widget/{id}")
    public ResponseEntity<?> getWidget(@PathVariable Long id) {
        return widgetService.findById(id)
                .map(widget -> {
                    try {
                        return ResponseEntity
                                .ok()
                                .eTag(Integer.toString(widget.getVersion()))
                                .location(new URI("/rest/widget/" + widget.getId()))
                                .body(widget);
                    } catch (URISyntaxException e) {
                        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
                    }
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/rest/widgets")
    public ResponseEntity<List<Widget>> getWidgets() {
        try {
            return ResponseEntity.ok()
                    .location((new URI("/rest/widgets")))
                    .body(widgetService.findAll());
        } catch (URISyntaxException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping("/rest/widget")
    public ResponseEntity<Widget> createWidget(@RequestBody Widget widget) {
        logger.info("Received widget: name: " + widget.getName() + ", description: " + widget.getDescription());
        Widget newWidget = widgetService.save(widget);

        try {
            return ResponseEntity
                    .created(new URI("/rest/widget/" + newWidget.getId()))
                    .eTag(Integer.toString(newWidget.getVersion()))
                    .body(newWidget);
        } catch (URISyntaxException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PutMapping("/rest/widget/{id}")
    public ResponseEntity<Widget> updateWidget(@RequestBody Widget widget, @PathVariable Long id, @RequestHeader(HttpHeaders.IF_MATCH) String ifMatch) {
        // Get the widget with the specified id
        Optional<Widget> existingWidget = widgetService.findById(id);
        if (!existingWidget.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        // Validate that the if-match header matches the widget's version
        if (!ifMatch.equalsIgnoreCase(Integer.toString(existingWidget.get().getVersion()))) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }

        // Update the widget
        widget.setId(id);
        widget = widgetService.save(widget);

        try {
            // Return a 200 response with the updated widget
            return ResponseEntity
                    .ok()
                    .eTag(Integer.toString(widget.getVersion()))
                    .location(new URI("/rest/widget/" + widget.getId()))
                    .body(widget);
        } catch (URISyntaxException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PutMapping("/rest/proper/widget/{id}")
    public ResponseEntity<Widget> updateWidgetProper(@RequestBody Widget widget, @PathVariable Long id, @RequestHeader("If-Match") Integer ifMatch) {
        Optional<Widget> existingWidget = widgetService.findById(id);
        if (existingWidget.isPresent()) {
            if (ifMatch.equals(existingWidget.get().getVersion())) {
                widget.setId(id);
                return ResponseEntity.ok().body(widgetService.save(widget));
            } else {
                return ResponseEntity.status(HttpStatus.CONFLICT).build();
            }
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/rest/widget/{id}")
    public ResponseEntity deleteWidget(@PathVariable Long id) {
        widgetService.deleteById(id);
        return ResponseEntity.ok().build();
    }
}
~~~





#### 将Spring与Junit结合

JUnit 5 定义了一个*扩展接口*，通过该接口，类可以在执行生命周期的各个阶段与 JUnit 测试集成。我们可以通过向测试类添加`@ExtendWith`注释并指定要加载的扩展类来启用扩展。然后，扩展可以实现各种回调接口，这些接口将在整个测试生命周期中调用：在所有测试运行之前、每个测试运行之前、每个测试运行之后以及所有测试运行之后。

Spring 定义了一个`SpringExtension`类，该类订阅 JUnit 5 生命周期通知来创建和维护“测试上下文”。**他会扫描当前包中的所有bean, 并构造一个测试用的ApplicationContext.**

Spring 使用 JUnit 5 扩展模型来维护测试的ApplicationContext，这使得使用 Spring 编写单元测试变得简单。

我们只需要使用如下代码, 即可在Junit5扩展接口中添加Spring扩展

~~~java
@ExtendWith(SpringExtension.class)
class MyTests {
  // ...
}
~~~

但是, 因为我们的应用程序是一个springboot程序, 所以我们可以使用`@SpringBootTest`, 因为`@SpringBootTest`注释已经包含 `@ExtendWith(SpringExtension.class)` 注解

~~~java
@SpringBootTest
class MyTests {
  // ...
}
~~~



#### 测试Service

我们有一个WidgetService的实现类, 他依赖于WidgetRepository从数据库查询具体的数据, 我们需要对其进行测试

为了正确地单独测试每个组件并模拟不同的场景，我们需要创建测试类的所依赖的bean, 并使用mockito来模拟他们在特定情况下的行为

~~~java
@SpringBootTest // 相当于@ExtendWith(SpringExtension.class)
public class WidgetServiceTest {
    // 自动注入我们需要测试的类
    @Autowired
    private WidgetService service;

    // 自动注入WidgetService依赖的WidgetRepository, 这个WidgetRepository是mockito创建的一个mock对象, 用来模拟各种情况下WidgetService的行为
    @MockBean
    private WidgetMapper widgetMapper;

    @Test
    @DisplayName("Test findById Success")
    void testFindById() {
        // 定义WidgetRepository的行为
        // 在调用他的findById()方法时, 如果参数是1l, 那么返回一个Optional.of(widget)
        Widget widget = new Widget(1l, "Widget Name", "Description", 1);
        doReturn(Optional.of(widget)).when(widgetMapper).findById(1l);

        // 执行调用
        Optional<Widget> returnedWidget = service.findById(1l);

        // 断言
        Assertions.assertTrue(returnedWidget.isPresent(), "Widget was not found");
        Assertions.assertSame(returnedWidget.get(), widget, "The widget returned was not the same as the mock");
    }

    @Test
    @DisplayName("Test findById Not Found")
    void testFindByIdNotFound() {
        // 定义在调用repository.findById(1l)的时候, 返回一个Optional.empty()
        doReturn(Optional.empty()).when(widgetMapper).findById(1l);

        // 执行调用
        Optional<Widget> returnedWidget = service.findById(1l);

        // 断言
        Assertions.assertFalse(returnedWidget.isPresent(), "Widget should not be found");
    }
}
~~~

`WidgetServiceTest`类使用`@SpringBootTest`注解进行注解，该注解会扫描`CLASSPATH`中的所有 Spring 配置类和 bean，并为测试类设置 Spring 应用程序上下文。

请注意， `@SpringBootTest`包含 `@ExtendWith(SpringExtension.class)` 注解，通过`@SpringBootTest`注解，将测试类与JUnit 5集成。

测试类还使用Spring的`@Autowired`注释来注入WidgetService以进行测试

同时测试类通过`@MockBean`定义了一个`WidgetRepository` , 这会告诉Spring, 使用一个模拟的`WidgetRepository` 对真实的`WidgetRepository` 进行代理, 然后将模拟的`WidgetRepository` 注入到**当前测试类中和所有依赖他的bean里面**

我们调用这个模拟的`WidgetRepository` 的任何方法, 他都会返回一个返回类型的默认值, 如果是引用类型, 那么是null, 如果是int, 那么返回0



#### @MockBean和@SpyBean

上面说到, Spring中提供了两个注释让我们能够创建模拟的bean, 用以定义他们的行为

~~~java
@SpringBootTest // 相当于@ExtendWith(SpringExtension.class)
public class WidgetServiceTest {
    // 自动注入我们需要测试的类
    @Autowired
    private WidgetService service;

    // 定义模拟bean
    @MockBean
    // @SpyBean
    private WidgetMapper widgetMapper;
}
~~~

@MockBean和@SpyBean都是告诉Spring, 创建一个模拟的bean对真实的bean进行代理, 然后将这个mock的bean注入到所有依赖他的bean里面

这样我们就可以在测试代码中定义这个mock的各种行为, 然后看看我们需要测试的代码是表现



@MockBean和@SpyBean的不同点在于

1. 使用了 `@MockBean`，会创建完全模拟的对象，它**完全替代**了被模拟的 Bean，并且所有方法的调用都被模拟。对于未指定行为的方法，返回值如果是基本类型则返回对应基本类型的默认值，如果是引用类型则返回 `null`

   

   @SpyBean它创建的是部分模拟对象，未指定方法行为时，将执行被模拟对象的**真实实现**，返回实际方法的执行结果

   常见的情况是：测试依赖外部资源（例如数据库、文件系统等）的方法，我们要在测试中模拟其中一部分方法的行为，同时保留对外部资源的实际访问，那么可以使用 `@SpyBean`

   

2. 对于@MockBean创建出来的模拟的bean, 有两种方式可以定义他的行为

   ~~~java
           // 有两种方式来定义WidgetService的行为
           // 方式1: 通过doReturn来定义
           doReturn(Lists.newArrayList(widget1, widget2)).when(service).findAll();
           doCallRealMethod().when(service).findById(3L);
           doThrow(new RuntimeException("hello")).when(service).findById(4L);
   
           // 方式2: 通过when来定义
           when(service.findById(1L)).thenReturn(Optional.of(widget1));
           when(service.findById(2L)).thenThrow(new RuntimeException("hello"));
           when(service.findById(5L)).thenCallRealMethod();
   ~~~

   而对于@SpyBean创建出来的bean, 我们只能通过第一种方式来定义他的行为, 因为通过`when(service.findById(1L))`来定义行为的时候, 我们已经调用了findById这个方法, 而他会执行真实的代码, 这可能会对测试结果产生副作用

   

#### 测试Controller

在测试完上面的WidgetService之后, 我们还需要测试Controller

我们创建一个测试类, 用来测试WidgetRestController

~~~java
import com.example.example4springboot.entity.Widget;
import com.example.example4springboot.service.WidgetService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.assertj.core.util.Lists;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Optional;

import static org.mockito.Mockito.doReturn;
import static org.mockito.ArgumentMatchers.any;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import static org.hamcrest.Matchers.*;

// @SpringBootTest // 将Spring与Junit进行集成
// @AutoConfigureMockMvc注释告诉Spring 创建一个与应用程序上下文关联的MockMvc实例，以便它可以将请求传递给处理它们的Controller
// @WebMvcTest结合了@SpringBootTest和@AutoConfigureMockMvc的功能,
// 默认情况下他会扫描所有的bean, 我们指定WidgetRestController.class, 那么他只会创建于WidgetRestController相关的bean, 可以加快测试
@WebMvcTest(WidgetRestController.class)
@AutoConfigureMybatis // mybatis配置mapper
class WidgetRestControllerTest {

    // 创建一个WidgetService mockbean, 用来模拟各种情况的WidgetService
    @MockBean
    private WidgetService service;

    // 自动注入MockMvc, 用来将请求传递给Controller
    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("GET /widgets success")
    void testGetWidgetsSuccess() throws Exception {
        // 定义WidgetService的行为
        Widget widget1 = new Widget(1L, "Widget Name", "Description", 1);
        Widget widget2 = new Widget(2L, "Widget 2 Name", "Description 2", 4);
        doReturn(Lists.newArrayList(widget1, widget2)).when(service).findAll();

        // 发送请求到Controller中, 并对返回的结果进行断言
        mockMvc.perform(get("/rest/widgets").param("xxx", "yyy").param("aa", "bb"))
                // 断言返回的http code
                .andExpect(status().isOk())
                // 断言返回的context-type
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))

                // 断言返回的http header
                .andExpect(header().string(HttpHeaders.LOCATION, "/rest/widgets"))

                // 断言返回的responsebody中的json
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].id", is(1)))
                .andExpect(jsonPath("$[0].name", is("Widget Name")))
                .andExpect(jsonPath("$[0].description", is("Description")))
                .andExpect(jsonPath("$[0].version", is(1)))
                .andExpect(jsonPath("$[1].id", is(2)))
                .andExpect(jsonPath("$[1].name", is("Widget 2 Name")))
                .andExpect(jsonPath("$[1].description", is("Description 2")))
                .andExpect(jsonPath("$[1].version", is(4)));
    }
    
	@Test
    void testGetWidgetsSuccess2() throws Exception {
        // 定义WidgetService的行为
        Widget widget1 = new Widget(1L, "Widget Name", "Description", 1);
        Widget widget2 = new Widget(2L, "Widget 2 Name", "Description 2", 4);
        doReturn(Lists.newArrayList(widget1, widget2)).when(service).findAll();

        // 发送请求到Controller中, 并对返回的结果进行断言
        MockHttpServletResponse response = mockMvc.perform(get("/rest/widgets"))
                // 断言返回的http code
                .andExpect(status().isOk())
                // 断言返回的context-type
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))

                // 断言返回的http header
                .andExpect(header().string(HttpHeaders.LOCATION, "/rest/widgets")).andReturn().getResponse();

        // 断言http状态
        Assertions.assertThat(response.getStatus()).isEqualTo(HttpStatus.OK.value());

        // 断言header
        Assertions.assertThat(response.getHeader(HttpHeaders.LOCATION)).isEqualTo("/rest/widgets");
        // 断言content-type
        Assertions.assertThat(response.getContentType()).isEqualTo(MediaType.APPLICATION_JSON.toString());
        // 断言返回的responsebody中的json
        Assertions.assertThat(response.getContentAsString()).isEqualTo(asJsonString(Lists.newArrayList(widget1, widget2)));

    }


    @Test
    @DisplayName("GET /rest/widget/1 - Not Found")
    void testGetWidgetByIdNotFound() throws Exception {
        // Setup our mocked service
        doReturn(Optional.empty()).when(service).findById(1L);

        // Execute the GET request
        mockMvc.perform(get("/rest/widget/{id}", 1L))
                // 断言code为404
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("POST /rest/widget")
    void testCreateWidget() throws Exception {
        // Setup our mocked service
        Widget widgetToPost = new Widget("New Widget", "This is my widget");
        Widget widgetToReturn = new Widget(1L, "New Widget", "This is my widget", 1);
        doReturn(widgetToReturn).when(service).save(any());

        // 执行post请求
        mockMvc.perform(put("/rest/widget/{id}", 1l)
                        .contentType(MediaType.APPLICATION_JSON)
                        // 指定request body
                        .content(asJsonString(widgetToPost)))

                // Validate the response code and content type
                .andExpect(status().isCreated())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))

                // Validate headers
                .andExpect(header().string(HttpHeaders.LOCATION, "/rest/widget/1"))
                .andExpect(header().string(HttpHeaders.ETAG, "1"))

                // Validate the returned fields
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.name", is("New Widget")))
                .andExpect(jsonPath("$.description", is("This is my widget")))
                .andExpect(jsonPath("$.version", is(1)));
    }

    static String asJsonString(final Object obj) {
        try {
            return new ObjectMapper().writeValueAsString(obj);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
~~~

有时候我们需要Mock的bean不经常使用, 那么我们就没必要将mockbean定义为属性, 我们可以将其放在测试方法的参数上

~~~java
    @Test
    @DisplayName("PUT /rest/widget/1 - Not Found")
    void testUpdateWidgetNotFound(@MockBean WidgetService service) throws Exception {
		// 执行测试
    }
~~~



**同时因为我们使用的是SpringBoot项目, 所以我们没必要`@SpringBootTest`和`@AutoConfigureMockMvc` 这两个注解来标注我们的测试类, SpringBoot提供了一个更好的注解`@WebMvcTest`专门用于测试Controller类**

这个注释结合了@SpringBootTest, @AutoConfigureMockMvc, 同时也结合了一些其他的注解

~~~java
@BootstrapWith(WebMvcTestContextBootstrapper.class)
@ExtendWith(SpringExtension.class) // 监听Junit相关事件, 创建ApplicationContext
@OverrideAutoConfiguration(enabled = false) // 关闭自动配置
@TypeExcludeFilters(WebMvcTypeExcludeFilter.class) // 只加载mvc相关的类型的bean
@AutoConfigureCache // 缓存相关
@AutoConfigureWebMvc // 将标注有@WebMvcTest的测试类注册为bean
@AutoConfigureMockMvc // 创建一个MockMvc实例用来发送请求到Controller
@ImportAutoConfiguration
public @interface WebMvcTest {
    // ...
}
~~~

我们可以这样使用@WebMvcTest这个注解

~~~java
// @SpringBootTest
// @AutoConfigureMockMvc 
@WebMvcTest(WidgetRestController.class) // 告诉Spring只创建于WidgetRestController相关的bean, 加快测试, 否则会创建所有的bean
class WidgetRestControllerTest {
    /// .... 
}
~~~



#### 优化测试的速度

上面的测试代码, 因为启动的时候, 都涉及到IOC容器的启用, 所以在执行的时候会比较慢, 如果你的bean的依赖关系比较简单, 那么可以使用原生的mockito来进行mock

~~~java
/**
   如下代码不涉及到IOC容器的启动
*/
@ExtendWith(MockitoExtension.class)
public class Test1{
    
    private MockMvc mockMvc;
    
    @InjectMocks
    private UserController userController;
    
    @Mock
    private UserService userService;
    
    @BeforeEach
    public void setUp() {
        // 创建mock mvc
        mockMvc = MockMvcBuilders.standaloneSetup(userController)
            .defaultResponseCharacterEncoding(StandardCharsets.UTF_8)
            .build();
    }
    
    @Test
    public void testSelectById() {
        // mock userService的行为, 看看controller的反应
    }
}
~~~









#### 避免 ApplicationContext 复用

**Spring会针对每一个测试类生成一个ApplicationContext**, 这样可以加快运行数据, 但是如果某些bean是有状态的, 那么多个测试方法可能会相互影响, 所有我们让每个测试方法执行完毕之后, 重新创建ApplicationContext

`@DirtiesContext` 默认的 `classMode` 参数为`ClassMode.AFTER_CLASS` 该模式会在 整个测试类运行完毕后重新加载 Spring 测试上下文。

我们可以将其放在class上, 并指定classMode为AFTER_METHOD, 这样spring会在每一个method执行之后重新创建一个ApplicationContext

也可以放在method上, 并指定classMode为AFTER_METHOD, 这样spring会在指定的method执行之后重新创建一个ApplicationContext

~~~java
@SpringBootTest
// @DirtiesContext(methodMode = DirtiesContext.MethodMode.AFTER_METHOD)
public class CacheIntegrationTest {

    @Autowired
    private CacheService cacheService;

    @Test
    @DirtiesContext(methodMode = DirtiesContext.MethodMode.AFTER_METHOD)
    public void testCacheEviction() {
        // 模拟缓存数据，缓存实际为 HashMap
        cacheService.addToCache("key1", "value1");
        cacheService.addToCache("key2", "value2");
    }

    @Test
    public void testCacheLookup() {
        // 从缓存中查找数据
        // 因为使用了 @DirtiesContext(methodMode = DirtiesContext.MethodMode.AFTER_METHOD) ApplicationContext 重置，故缓存为空
        String value1 = cacheService.getFromCache("key1");
        String value2 = cacheService.getFromCache("key2");
    }
}
~~~



#### 控制多个测试方法的执行顺序

~~~java
@SpringBootTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class CacheIntegrationTest {

    @Test
    @Order(1)
    public void testCacheEviction() { }

    @Test
    public void testCacheLookup() { }
}
~~~





#### 测试Mapper

https://mybatis.org/spring-boot-starter/mybatis-spring-boot-test-autoconfigure/zh/index.html

https://segmentfault.com/a/1190000041177598



针对mapper类的测试, 就两种方式:

1. 针对select查询,  先通过sql准备数据, 然后调用我们需要测试的mapper方法, 看查询出来的结果和我们准备的数据是否相吻合

2. **针对update和insert查询,  先调用mapper方法插入或者修改数据,  然后调用select方法查询数据**

   **如果select出来的数据和是修改后的数据, 那么就是正确的**

3. 对于delete查询, 我们先准备数据, 然后调用mapper的方法进行删除数据, 然后通过select方法查询数据, 如果delete成功, 那么应该查询不到数据



在测试了Service和Controller后, 我们还需要对Mapper类进行测试, 为了测试Mapper类, 首先我们需要导入Mybatis的测试包

~~~xml
        <dependency>
            <!-- 测试mybatis -->
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter-test</artifactId>
            <version>3.0.3</version>
            <scope>test</scope>
        </dependency>
~~~

然后创建我们的测试类

~~~java
@MybatisTest // 替换SpringTest
public class WidgetMapperWithEmbeddedDBTest {

    @Autowired
    private WidgetMapper widgetMapper;
}
~~~

我们使用@MybatisTest标注我们的测试类, 默认情况下

- 它将会配置 MyBatis（MyBatis-Spring）组件（`SqlSessionFactory` 与 `SqlSessionTemplate`）
- 配置 MyBatis mapper 接口和内存中的内嵌的数据库。
-  MyBatis 测试默认情况下基于事务，且在测试的结尾进行回滚
-  `@Component` beans 将不会被载入 `ApplicationContext` , 以加快测试

因为mybatis默认使用内嵌的内存中的数据库来对sql进行测试, 而不是我们真实的数据库, 所以我们在默认情况下, 他会去classpath下寻找是否有内嵌的数据库依赖, 比如H2/HSQLDB/Derby/SQLite

如果没有找到, 那么他将会报错, 所以如果我们要使用内嵌的数据库进行测试的话, 还需要配置一个内嵌的数据库依赖, 这里以H2举例

~~~xml
        <dependency>
            <!-- 用于测试的内存数据库 -->
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>test</scope>
        </dependency>
~~~

如果你想要使用application.yml中配置的真实数据库(**推荐**)作为测试时使用的数据库, 那么你可以使用如下方式

**不需要担心测试代码会污染数据库, 因为测试结束后, 事务会回滚**

~~~java
@MybatisTest // 替换SpringTest
// 默认情况下replace为ANY, 此时会创建一个内嵌的内存数据库作为我们的测试数据库,
// 所以我们在maven的test环境下必须导入一个内嵌数据库(比如h2)的依赖, 否则会找不到内嵌数据库支持而报错
// 如果我们想要使用真实的数据库, 那么我们可以设置replace为NONE
@AutoConfigureTestDatabase(replace = Replace.NONE)
public class WidgetMapperWithEmbeddedDBTest {

    @Autowired
    private WidgetMapper widgetMapper;
}
~~~





下面我们使用内嵌的h2来作为我们的测试数据库, 来编写我们的测试用例, 此时我们会发现, 因为数据库是一个全新的数据库, 那么这个数据库中并没有我们测试时需要的表和数据

此时我们在执行测试之前, 必须在h2数据库上执行建表和insert的语句, 那么我们可以使用@Sql这个注解来完成

1. @Sql可以通过scripts来指定classpath下要运行的脚本, 也可以通过statements指定要运行的sql

2. 可以通过executionPhase指定是在测试之前运行还是之后运行, 有如下几个选项

   - BEFORE_TEST_CLASS: 在测试类开始测试之前执行
   - AFTER_TEST_CLASS: 在测试类执行完测试方法之后执行
   - BEFORE_TEST_METHOD: 在每一个测试方法执行之前执行
   - AFTER_TEST_METHOD: 在每一个测试方法执行之后执行

3. @Sql可以标注在class上, 那么会在当前类的测试执行前/后执行一次(只执行一次), 也可以放在method上, 在对应的测试方法执行前/后执行

4. 在默认情况下, 如果在method上指定了@Sql, 又在class上指定的@Sql()并且**executionPhase 为BEFORE_TEST_METHOD或者DAFTER_TEST_METHOD(方法级别的sql)**, 那么method上的注解会覆盖class上的注解

   如果想要两者同时执行, 那么可以在对应的class或者method上标注@SqlMergeMode(MergeMode.MERGE)

5. @SqlMergeMode(MergeMode.MERGE)如果放在class上, 表示所有的方法级别的@Sql注解都会与class上的方法级别的@Sql注解合并

   @SqlMergeMode(MergeMode.MERGE)如果放在method上, 表示当前方法的@Sql注解都会与class上的方法级别的@Sql注解合并

6. 可以在class或者method上指定多个@Sql注解, 但是要放在@SqlGroup中
   
   

~~~java
@MybatisTest // 替换SpringTest
@AutoConfigureTestDatabase()
@SqlGroup(value = {@Sql(scripts = {"classpath:/schema.sql"}, executionPhase = ExecutionPhase.BEFORE_TEST_CLASS),
        @Sql(statements = {"select * from widget;"}, executionPhase = ExecutionPhase.BEFORE_TEST_CLASS)})
// 这个注解可以放在class上, 也可以放在method上
// 如果放在class上, 表示所有的方法级别的@Sql注解都会与class上的@Sql注解合并/覆盖
// 如果放在method上, 表示当前方法的@Sql注解会与当前class上的@Sql注解合并/覆盖
@SqlMergeMode(MergeMode.MERGE)
public class WidgetMapperWithEmbeddedDBTest {

    @Autowired
    private WidgetMapper widgetMapper;

    @Test
    @Sql(scripts = "classpath:/data.sql", executionPhase = ExecutionPhase.BEFORE_TEST_METHOD) // 指定在当前测试之前要执行的sql
    @SqlMergeMode(MergeMode.MERGE) // 指定当前方法上的@Sql与class上的方法级别的Sql合并, 而不是覆盖
    public void testSelectByPrimaryKey() {
        Optional<Widget> result = widgetMapper.findById(1L);
        assertThat(result.isPresent(), equalTo(true));
        assertThat(result.get(), equalTo(new Widget(1L, "Widget1", "This is the first widget", 1)));
    }
}
~~~



上面我们说到, 在执行完测试代码之后, 事务默认会回滚, 而不影响数据库, 我们可以使用@Rollback(false)或者@Commit注解来让事务提交, 而不是回滚

这两个注解可以放在class上, 针对所有测试生效, 也可以放在method上, 针对当前方法生效

~~~java
@MybatisTest
@AutoConfigureTestDatabase()

// 默认情况下, 在执行完测试方法后, 会自动回滚事务, 防止我们的测试代码污染数据库
// 可以添加@Rollback(false)来取消事务回滚, 这样测试代码会真正的影响数据库
// 这个配置可以添加在类上, 也可以添加在方法上
@Rollback(false)
// @Commit // @Commit等效于@Rollback(false)
public class WidgetMapperWithEmbeddedDBTest {

    @Autowired
    private WidgetMapper widgetMapper;

    @Test
    @Commit // 标注在方法上, 那么在执行完测试的时候会提交事务, 而不是回滚事务
    // @Rollback(false) // 作用与@Commit一样
    public void testSelectByPrimaryKey() {
        // ...
    }
}
~~~



#### mock RestTemplate

https://www.baeldung.com/spring-mock-rest-template

首先, 想要mock RestTemplate有两种办法, 

一种是使用mockito, 然后和其他的mock bean一样进行mock



另外一种是在spring环境中, 创建一个*MockRestServiceServer* , 他会使用*MockClientHttpRequestFactory*来拦截http请求, 当匹配到特点的请求后, 就返回我们预先设定的结果



使用mockito来mock的代码如下

~~~java
@Service
public class EmployeeService {
    
    @Autowired
    private RestTemplate restTemplate;

    public Employee getEmployeeWithGetForEntity(String id) {
	ResponseEntity resp = 
          restTemplate.getForEntity("http://localhost:8080/employee/" + id, Employee.class);
        
	return resp.getStatusCode() == HttpStatus.OK ? resp.getBody() : null;
    }
}

@ExtendWith(MockitoExtension.class)
public class EmployeeServiceTest {

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private EmployeeService empService = new EmployeeService();

    @Test
    public void givenMockingIsDoneByMockito_whenGetForEntityIsCalled_thenReturnMockedObject() {
        Employee emp = new Employee(“E001”, "Eric Simmons");
        // 指定预期的行为
        Mockito
          .when(restTemplate.getForEntity(
            "http://localhost:8080/employee/E001", Employee.class))
          .thenReturn(new ResponseEntity(emp, HttpStatus.OK));

        Employee employee = empService.getEmployeeWithGetForEntity(id);
        Assertions.assertEquals(emp, employee);
    }
    
    @Test
    public void givenMockingIsDoneByMockito_whenExchangeIsCalled_thenReturnMockedObject(){
        Employee emp = new Employee("E001", "Eric Simmons");
        Mockito.when(restTemplate.exchange("http://localhost:8080/employee/E001",
            HttpMethod.GET,
            null,
            Employee.class)
        ).thenReturn(new ResponseEntity(emp, HttpStatus.OK));
        Employee employee = empService.getEmployeeWithRestTemplateExchange("E001");
        assertEquals(emp, employee);
    }
}
~~~



使用Spring中的*MockRestServiceServer* 来mock的代码如下:

~~~java
@ExtendWith(SpringExtension.class)
@SpringBootTest(classes = SpringTestConfig.class)
public class EmployeeServiceMockRestServiceServerUnitTest {

    @Autowired
    private EmployeeService empService;
    @Autowired
    private RestTemplate restTemplate;

    private MockRestServiceServer mockServer;
    private ObjectMapper mapper = new ObjectMapper();

    @BeforeEach
    public void init() {
        // 创建MockRestServiceServer来拦截http请求
        mockServer = MockRestServiceServer.createServer(restTemplate);
    }
    
    @Test 
    public void givenMockingIsDoneByMockRestServiceServer_whenGetIsCalled_thenReturnsMockedObject()() {   
        Employee emp = new Employee("E001", "Eric Simmons");
        // 拦截GET http://localhost:8080/employee/E001一次
        // 返回一个emp的json字段
        mockServer.expect(ExpectedCount.once(), 
          requestTo(new URI("http://localhost:8080/employee/E001")))
          .andExpect(method(HttpMethod.GET))
          .andRespond(withStatus(HttpStatus.OK)
          .contentType(MediaType.APPLICATION_JSON)
          .body(mapper.writeValueAsString(emp))
        );                                   
                       
        Employee employee = empService.getEmployeeWithGetForEntity(id);
        mockServer.verify();
        Assertions.assertEquals(emp, employee);                                                        
    }
}
@Test
public void givenMockingIsDoneByMockRestServiceServer_whenExchangeIsCalled_thenReturnMockedObject() throws Exception {
    Employee emp = new Employee("E001", "Eric Simmons");

    mockServer.expect(ExpectedCount.once(), requestTo(new URI("http://localhost:8080/employee/E001")))
      .andExpect(method(HttpMethod.GET))
      .andRespond(withStatus(HttpStatus.OK)
        .contentType(MediaType.APPLICATION_JSON)
        .body(mapper.writeValueAsString(emp)));

    Employee employee = empService.getEmployeeWithRestTemplateExchange("E001");
    mockServer.verify();
    Assertions.assertEquals(emp, employee);
}
~~~







# Mockito



## Mock和Spy对象

当我们测试一个类的时候,  我们可能想要测试当他依赖的对象正常时/异常时,  我们测试的类会有怎么样的反应, 那么此时我们就可以创建一个mock/spy对象来模拟依赖



### 创建Spy和Mock对象

有以下几种创建mock和spy对象的方式:

1. 通过Mockito的静态方法创建

   ~~~java
   @Test
   public void test() {
       List<?> mockList = Mockito.mock(List.class); // 通过class来创建一个mock对象
       assert Mockito.mockingDetails(mockList).isMock(); // 判断是否为mock对象
   
       List<?> spyList = Mockito.spy(AbstractList.class); // 通过class来创建一个spy对象
       assert Mockito.mockingDetails(spyList).isSpy(); // 判断是否为spy对象
       assert Mockito.mockingDetails(spyList).isMock(); // 判断是否为mock对象
   
       List<?> spied = Mockito.spy(new ArrayList<>()); // 通过一个对象来创建一个spy对象
       assert Mockito.mockingDetails(spyList).isSpy(); // 判断是否为spy对象
       assert Mockito.mockingDetails(spyList).isMock(); // 判断是否为mock对象
   }
   ~~~

2. 通过注解来创建

   ~~~java
   // 在junit5中启用mockito, 这样就可以使用各种注解了
   @ExtendWith(MockitoExtension.class)
   public class _02_by_MockitoExtension {
   
       // 通过class来创建一个mock对象
       // 等效于List<?> mockList = Mockito.mock(List.class);
       @Mock
       List<?> mockList;
   
       // 通过class来创建一个spy对象
       // 等效于List<?> spyList = Mockito.spy(AbstractList.class);
       @Spy
       List<?> spyList;
   
       // 通过一个对象来创建一个spy对象
       // 等效于List<?> spied = Mockito.spy(new ArrayList<>());
       // !!!! 需要注意的是, 此时的spied不是刚刚new出来的, Mockito会对刚刚new出来的list进行代理, 所以spied是代理对象
       @Spy
       List<?> spied = new ArrayList<>();
   
       @Test
       public void test() {
           assert Mockito.mockingDetails(mockList).isMock(); // 判断是否为mock对象
   
           assert Mockito.mockingDetails(spyList).isSpy(); // 判断是否为spy对象
           assert Mockito.mockingDetails(spyList).isMock(); // 判断是否为mock对象
   
           assert Mockito.mockingDetails(spyList).isSpy(); // 判断是否为spy对象
           assert Mockito.mockingDetails(spyList).isMock(); // 判断是否为mock对象
       }
   }
   ~~~

3. 通过注解创建

   ~~~java
   public class _03_by_MockitoAnnotations {
   
       // 通过class来创建一个mock对象
       // 等效于List<?> mockList = Mockito.mock(List.class);
       @Mock
       List<?> mockList;
   
       // 通过class来创建一个spy对象
       // 等效于List<?> spyList = Mockito.spy(AbstractList.class);
       @Spy
       List<?> spyList;
   
       // 通过一个对象来创建一个spy对象
       // 等效于List<?> spied = Mockito.spy(new ArrayList<>());
       // !!!! 需要注意的是, 此时的spied不是刚刚new出来的, Mockito会对刚刚new出来的list进行代理, 所以spied是代理对象
       @Spy
       List<?> spied = new ArrayList<>();
   
       @BeforeEach
       public void init() {
           // 在junit5中启用mockito, 这样就可以使用各种注解了
           MockitoAnnotations.openMocks(this);
       }
   
       @Test
       public void test() {
           // ...
       }
   }
   ~~~

### 注意点

- spy是一种特使的mock对象,  所以在判断spy对象是不是mock对象的时候, 返回true

- **mock和spy都可以用在接口, 抽象类, final类, 正常类上面**

  如果spy碰到了抽象方法, 那么会和mock对象一样返回一个默认值



### Mock和Spy对象的区别

1. 在调用mock代理对象的时候, 默认情况下他不会执行真实的方法, 而是直接返回返回类型的默认值

   - 基础类型(0, false, 0d)
   - 引用类型: null,  包括String也是返回null
   - Optional类型:  Optional.empty()
   - Stream类型: Stream.empty()
   - 集合类型: 空集合
   
   而在调用spy对象的时候, 他会执行真实的方法, 返回真实的返回值
   
2. @spy使用的真实的对象实例，调用的都是真实的方法，所以通过这种方式进行测试，在进行sonar覆盖率统计时统计出来是有覆盖率；
@mock出来的对象可能已经发生了变化，调用的方法都不是真实的，在进行sonar覆盖率统计时统计出来的Calculator类覆盖率为0.00%。



   ### 通过class和对象创建spy对象的区别

一般情况下, 我们都是通过对象创建spy对象时,  对spy对象的调用都会转而调用这个对象的真实方法

当我们想要模拟一下抽象类, 或者接口的时候, 我们可以通过class来创建spy对象, 因为抽象类和接口无法被实例化

对于抽象方法,  spy对象会像mock对象一样, 直接返回一个返回类型的默认值

   

### 判断是否为mock和spy对象

要想判断一个对象是否为mock和spy对象, 可以使用

~~~java
@Test
public void whenNotUseMockAnnotation_thenCorrect() {
    // 创建mock和spy对象
    List mockList = Mockito.mock(ArrayList.class);
    List<String> spyList = Mockito.spy(new ArrayList<String>());
    
    // 判断是否为mock对象
    assert Mockito.mockingDetails(mockList).isMock() == true;
    // 判断是否为spy对象
    assert Mockito.mockingDetails(spyList).isSpy() == true;
    // spy对象是一种特殊的mock对象, 所以这里为true
    assert Mockito.mockingDetails(spyList).isMock() == true;
}
~~~



### 创建mock和spy对象的原理

通过bytebuddy在运行时创建代理



### Mock对象的配置

https://www.baeldung.com/mockito-mock-methods

我们在通过@Mock和mock()方法创建mock对象的时候, 可以给定一些其他的参数, 用来对mock对象进行配置



假设我们有如下一个mock对象的类

~~~java
public class MyList extends AbstractList<String> {

    @Override
    public String get(int index) {
        return null;
    }

    @Override
    public int size() {
        return 1;
    }
}
~~~

1. 简单创建一个Mock对象

   ~~~java
   MyList listMock = mock(MyList.class);
   when(listMock.add(anyString())).thenReturn(false);
   
   boolean added = listMock.add(randomAlphabetic(6));
   
   verify(listMock).add(anyString());
   assertThat(added).isFalse();
   ~~~

2. 创建一个Mock对象, 并给定一个name

   这个name有助于我们调试信息

   ~~~java
   MyList listMock = mock(MyList.class, "myMock");
   
   when(listMock.add(anyString())).thenReturn(false);
   listMock.add(randomAlphabetic(6));
   
   // verify(listMock, times(2)).add(anyString())表示验证add方法的调用次数为2次, 少于两次会抛出TooFewActualInvocations异常
   // assertThatThrownBy().isisInstanceOf()用于验证异常的类型 
   // hasMessageContaining用于验证异常的内容
   assertThatThrownBy(() -> verify(listMock, times(2)).add(anyString()))
       .isInstanceOf(TooFewActualInvocations.class)
       .hasMessageContaining("myMock.add");
   ~~~

3. 创建一个Mock对象, 并给定一个Answer

   如果我们没有对Mock对象设置预期行为, 那么会调用Answer来生成返回值

   ~~~java
   class CustomAnswer implements Answer<Boolean> {
   
       @Override
       public Boolean answer(InvocationOnMock invocation) throws Throwable {
           return false;
       }
   }
   
   MyList listMock = mock(MyList.class, new CustomAnswer());
   boolean added = listMock.add(randomAlphabetic(6)); // 没有设置add方法的预期行为, 会调用CustomAnswer的answer方法来生成对应的返回值
   assertThat(added).isFalse(); // 验证返回值为false
   ~~~

4. 创建一个Mock对象, 并给定一个MockSettings

   *MockSettings*接口的方法支持多种自定义设置，例如使用*invokingListeners*在当前模拟上注册方法调用的侦听器，使用*sererable*配置序列化，使用*spiedInstance*指定要监视的实例，配置 Mockito 以尝试使用构造函数使用*useConstructor*等实例化模拟时

   ~~~java
   MockSettings customSettings = withSettings().defaultAnswer(new CustomAnswer()); // 通过withSettings创建一个MockSettings, 并配置一个Answer
   
   MyList listMock = mock(MyList.class, customSettings); // 创建Mock对象并设置settings
   
   
   boolean added = listMock.add(randomAlphabetic(6));
   verify(listMock).add(anyString());
   assertThat(added).isFalse(); // MockSettings中的Answer发挥作用
   ~~~




## @InjectMocks

我们可以使用@InjectMocks注解来创建一个我们需要测试的对象

**InjectMocks对象是一个真实的对象, 不会像mock和spy对象一样进行代理**

同时Mockito还会尽可能的将其他mock和spy对象通过构造函数参数, setter, 或者反射的形式通过类型匹配注入到InjectMocks对象中

~~~java
@ExtendWith(MockitoExtension.class)
public class Demo1Test {

    public static class MyDictionaryAndList {
        public Map<String, String> wordMap;
        public List<String> list;

        public MyDictionaryAndList() {
            wordMap = new HashMap<String, String>();
            list = new ArrayList<String>();
        }
        public void add(final String word, final String meaning) {
            System.out.println("add");
            wordMap.put(word, meaning);
        }
        public String getMeaning(final String word) {
            System.out.println("getMeaning");
            return wordMap.get(word);
        }

        public void addListElement(final String word) {
            System.out.println("addListElement");
            list.add(word);
        }

        public String getListElement(final int index) {
            System.out.println("getElement");
            return list.get(index);
        }
    }

    List<String> arrayList = new ArrayList<String>();

    @Mock
    Map<String, String> map;

    @Spy
    List<String> list = arrayList;

    @InjectMocks
    @Spy // 这里这个@Spy可以不用加, 但是通常情况下, 我们会mock MyDictionaryAndList的其他方法, 如果不加我们就不能进行mock, 所以还是加上比较好
    MyDictionaryAndList myDictionaryAndList;

    @Test
    public void test(){
		// Mockito会将spy和mock注入到InjectMocks对象中
        System.out.println(map == myDictionaryAndList.wordMap); // true
        System.out.println(list == myDictionaryAndList.list); // true

        // spy对象不是原来的那个arrayList, Mockito会对赋值的那个arrayList进行代理, 所以这里的list是代理后的arrayList
        System.out.println(list == arrayList); // false

        // 因为map是mock对象, 不会真正的执行, 而是返回返回类型的默认值
        myDictionaryAndList.add("hello", "world");
        System.out.println(myDictionaryAndList.getMeaning("hello") == null); // true

        // spy对象会真正的执行真实方法
        myDictionaryAndList.addListElement("hello");
        System.out.println(myDictionaryAndList.getListElement(0)); // hello
    }
}
~~~





## 指定mock和spy对象的行为

~~~java
public class _02_ArgumentMatcher {

    @Mock
    OrderService orderService;

    /**
     * 使用doXXX, 可以用来指定mock和spy对象的行为
     */
    @Test
    public void test() {
        // 当调用orderService的createOrder方法, 并且参数是new Order("hello", "world")的时候, 返回true
        Mockito.doReturn(true).when(orderService).createOrder(new Order("hello", "world"));

        // doNothing一般针对返回值为void的方法, 当调用orderService.save()并且参数是new Order()的时候, 不做任何事情
        Mockito.doNothing().when(orderService).save(new Order());

        // 当调用orderService.createOrder方法的时候, 并且参数是new Order()的时候, 抛出一个RuntimeException异常
        Mockito.doThrow(RuntimeException.class).when(orderService).createOrder(new Order());
        // 当调用orderService.createOrder()并且参数是new Order("1", "1")的时候, 抛出一个IllegalArgumentException("msg")异常
        Mockito.doThrow(new IllegalArgumentException("msg")).when(orderService).createOrder(new Order("1", "1"));

        // 当调用orderService.createOrder(), 并且参数是new Order("2", "2")时, 转而调用真实的方法
        Mockito.doCallRealMethod().when(orderService).createOrder(new Order("2", "2"));

        // 当调用orderService..createOrder(new Order("3", "3"))时, 通过Answer接口来动态的设置返回值
        Mockito.doAnswer(invocation -> {
            // 获取参数
            Order argument = invocation.getArgument(1, Order.class);
            if (argument.getFields1().equals("1")) {
                return false;
            }
            // 调用真实的方法
            return invocation.callRealMethod();
        }).when(orderService).createOrder(new Order("3", "3"));
    }
    
    
    /**
     * 使用when().then(), 只能指定mock对象的行为, spy对象使用这种方式有歧义
     */
    @Test
    public void test1() {
        Mockito.when(orderService.createOrder(new Order("hello", "world"))).thenReturn(true);
        Mockito.when(orderService.createOrder(new Order())).thenThrow(RuntimeException.class);
        Mockito.when(orderService.createOrder(new Order("1", "1"))).thenThrow(new IllegalArgumentException("msg"));
        Mockito.when(orderService.createOrder(new Order("2", "2"))).thenCallRealMethod();
        Answer<?> answer = (invocation) -> {
            // 获取参数
            Order argument = invocation.getArgument(1, Order.class);
            if (argument.getFields1().equals("1")) {
                return false;
            }
            // 调用真实的方法
            return invocation.callRealMethod();
        };
        Mockito.when(orderService.createOrder(new Order("2", "2"))).thenAnswer(answer); // thenAnswer和then是一样的
        Mockito.when(orderService.createOrder(new Order("3", "3"))).then(answer);

        // when().then()不能作用于void方法, 碰上void方法使用doXXX().when()吧
        // Mockito.when(orderService.save(new Order())).thenCallRealMethod();
    }

    /**
     * when().then()可以进行链式调用, 引来指定多次调用时的行为
     */
    @Test
    public void test2() {
        Mockito.when(orderService.createOrder(new Order("hello", "world")))
                .thenReturn(true) // 第一次调用时返回true
                .thenReturn(false) // 第二次调用时返回false
                .thenThrow(RuntimeException.class); // 第三次调用时抛出异常
    }

}
~~~



## 参数匹配

上面我们在定义mock/spy的行为的时候, 我们使用的都是直接指定参数的方式, 即当传入特定参数的时候, 返回特定的值

如果我们想要一次性匹配多个参数, 或者根据情况来匹配参数的时候应该怎么办呢?

此时我们可以使用`ArgumentMatcher`这个类, 他提供了很多方法来匹配参数

~~~java
public class _02_ArgumentMatcher {

    @Mock
    OrderService orderService;

    /**
     * 使用doXXX, 可以用来指定mock和spy对象的行为
     */
    @Test
    public void test() {
        // 直接指定参数
        Mockito.doReturn(true).when(orderService).deleteOrder(new Order("hello", "world"), true);

        // any用来匹配任何对象实例
        // anyString(), anyInt(), anyByte(), anyChar(), anyDouble(), anyFloat(), anyBoolean(), anyShort(), anyLong()
        // anyCollection(), anyIterable(), anyList(), anyMap(), anySet()
        // any(Order.class) 匹配任意Order类型的对象
        // any() 匹配任意值
        Mockito.doReturn(true).when(orderService).deleteOrder(ArgumentMatchers.any(Order.class), ArgumentMatchers.anyBoolean());

        // isA(): 匹配当前类及其子类
        // eq(): 匹配相等的值
        // same(): 匹配相同的地址
        // refEq(): 使用反射来比较所有的属性是否相同, 可以排除指定的属性
        Mockito.doReturn(true).when(orderService).deleteOrder(ArgumentMatchers.isA(Order.class), ArgumentMatchers.eq(false));

        // startsWith(String prefix), endsWith(String suffix), contains(String substring), matchers(String regex), matchers(Pattern pattern): 匹配特定的字符串


        // isNull和isNull(Class T), isNotNull()和isNotNull(Class T), notNull()和notNull(Class T): 匹配null和非null值, isNotNull和notNull两个意思一样, 带类型的主要用于防止方法重载
        // nullable(Class t): 用于匹配特定类型的值, 或者null


        // xxxThat(): 自定义是否匹配
        Mockito.doReturn(true).when(orderService).deleteOrder(ArgumentMatchers.argThat(new ArgumentMatcher<Order>() {
            @Override
            public boolean matches(Order argument) {
                return false;
            }
        }), ArgumentMatchers.booleanThat(new ArgumentMatcher<Boolean>() {
            @Override
            public boolean matches(Boolean argument) {
                return false;
            }
        }));


        // or(): 或
        // and(): 与
        // not(): 非
        // cmpEq(): 通过类型自身的compareTo方法来比较
        // geq: 大于等于
        // gt: 大于
        // leq: 小于等于
        // le小于
        // aryEq: 比较数值是否相等
        Mockito.doReturn(true).when(orderService).deleteOrder(AdditionalMatchers.or(new Order("1", "1"), new Order("2", "2")), ArgumentMatchers.eq(false));
        Mockito.doReturn(true).when(orderService).deleteOrder(AdditionalMatchers.not(new Order()), ArgumentMatchers.eq(false));
    }
    
}
~~~



## 校验

当我们执行了需要测试的方法之后, 我们还需要对调用的方法进行校验, 校验主要由一下几种:

1. 校验返回值或者异常
2. 校验依赖方法的调用



### 校验返回值

在校验返回值的时候, 我们可以使用Junit5自带的断言, 也可以使用其他第三方库进行断言, 比如hamcrest

~~~java
@ExtendWith(MockitoExtension.class)
public class _03_VerifyResult {

    @Mock
    OrderService orderService;

    @Test
    public void test() {
        // 定义行为
        Mockito.doReturn(new Order("1", "1")).when(orderService).getOrder("1");
        Mockito.doThrow(RuntimeException.class).when(orderService).getOrder("2");

        Order order = orderService.getOrder("1");

        // 使用junit断言
        Assertions.assertEquals("hello", order.getFields1());

        // 使用hamcrest断言
        MatcherAssert.assertThat(order.getFields1(), Matchers.equalTo("1"));

        // 断言抛出异常
        Assertions.assertThrows(RuntimeException.class, () -> {
            orderService.getOrder("2");
        });
    }

}
~~~



### 校验依赖对象的方法调用



https://www.baeldung.com/mockito-verify

假设我们有如下的一个mock类

~~~java
public class MyList extends AbstractList<String> {

    @Override
    public String get(final int index) {
        return null;
    }
    
    @Override
    public int size() {
        return 1;
    }
}
~~~



验证调用次数

~~~java
List<String> mockedList = mock(MyList.class);
mockedList.size();

verify(mockedList).size(); // size方法被调用1次
verify(mockList, times(1)).size();
verify(mockList, atLeastOnce()).size(); // 至少调用一次siez()
verify(mockList, atMost(2)).size(); // 至多2次调用siez()
verify(mockList, atLeast(1)).size(); // 至少1次调用size()

verify(mockList, never()).clear(); // 从未调用过clear方法
verify(mockedList, times(0)).size(); // 从未调用过size方法

// 校验没有调用mockedList的任何方法
verifyNoInteractions(mockedList);
verifyZeroInteractions(mockedList);

verify(mockedList, only()).size();  // 只调用过size方法
~~~



验证调用顺序

~~~java
// 我们可以跳过任何方法进行验证，但是要验证的方法必须以相同的顺序调用。
// 验证单个 或者 多个mock bean之间方法的调用顺序
InOrder inOrder = inOrder(mockList, mockMap);
inOrder.verify(mockList).add("Pankaj");
inOrder.verify(mockList, calls(1)).size();
inOrder.verify(mockList).isEmpty();
inOrder.verify(mockMap).isEmpty();

verifyNoMoreInteractions(mockList); // 验证此时没有尚未验证的调用了, 常常用在测试方法的最后面, 如果还有没有验证的调用, 那么测试方法不会通过
~~~



验证调用的参数

~~~java
@ExtendWith(MockitoExtension.class)
public class _04_VerifyCall {

    @InjectMocks
    OrderService orderService;

    @Mock
    OrderDao orderDao;

    @Test
    public void test() {

        // 定义行为
        Mockito.doReturn(new Order("1", "1")).when(orderDao).getOrder("1");
        Mockito.doThrow(RuntimeException.class).when(orderDao).getOrder("2");

        Order order = orderService.getOrder("1");

        Assertions.assertThrows(RuntimeException.class, () -> {
            orderService.getOrder("2");
        });


        /**
         * 直接指定方法的调用参数来进行验证
         */
        // 验证orderDao.getOrder("2")是否被调用了一次
        Mockito.verify(orderDao, Mockito.times(1)).getOrder("2");
        // 验证orderDao.getOrder("1")是否被调用了一次
        Mockito.verify(orderDao, Mockito.times(1)).getOrder("1");


        /**
         * 还可以使用ArgumentMatchers来指定调用的参数
         */
        // 校验getOrder()至少被调用了2次, 并且参数为"1"或者"2"
        Mockito.verify(orderDao, Mockito.atLeast(2)).getOrder(AdditionalMatchers.or(ArgumentMatchers.eq("1"), ArgumentMatchers.eq("2")));
        // 校验getOrder()被至多调用了2次, 并且参数为任何字符串
        Mockito.verify(orderDao, Mockito.atMost(2)).getOrder(ArgumentMatchers.anyString());


        /**
         * 或者可以使用ArgumentCaptor来捕获参数, 然后对调用的参数进行校验
         */
        ArgumentCaptor<String> argumentCaptor = ArgumentCaptor.forClass(String.class);
        // 验证getOrder被调用了2次, 并将调用的参数保存到argumentCaptor中
        // 想要捕获多个参数, 需要创建多个ArgumentCaptor
        // 如果getOrder被调用了多次, 那么会将所有参数都保存到ArgumentCaptor
        Mockito.verify(orderDao, Mockito.times(2)).getOrder(argumentCaptor.capture());

        // 获取每次调用时的参数,返回一个List, 然后获取第1, 2次调用时的参数, 进行校验
        Assertions.assertEquals("1", argumentCaptor.getAllValues().get(0));
        Assertions.assertEquals("2", argumentCaptor.getAllValues().get(1));

        // 获取最后一次的调用
        Assertions.assertEquals("2", argumentCaptor.getValue());
    }

}
~~~







## mock  静态方法

https://www.baeldung.com/mockito-mock-static-methods

~~~java
@ExtendWith(MockitoExtension.class)
public class _01_MockStaticMethod {

    public static class StaticUtils {

        private StaticUtils() {}

        public static List<Integer> range(int start, int end) {
            return IntStream.range(start, end)
                    .boxed()
                    .collect(Collectors.toList());
        }

        public static String name() {
            return "Baeldung";
        }
    }

    @Test
    public void givenStaticMethodWithNoArgs_whenMocked_thenReturnsMockSuccessfully() {
        assertThat(StaticUtils.name()).isEqualTo("Baeldung");

        // utilities是threadlocal的, 并且必须在测试方法结尾被关闭
        // 之后在try-catch中, 静态方法才是被代理的
        // 在try-catch之外, 静态方法是正常调用的
        try (MockedStatic<StaticUtils> utilities = Mockito.mockStatic(StaticUtils.class)) {
            // 指定调用name的时候, 返回Eugen
            utilities.when(StaticUtils::name).thenReturn("Eugen");
            // 校验
            assertThat(StaticUtils.name()).isEqualTo("Eugen");
        }

        assertThat(StaticUtils.name()).isEqualTo("Baeldung");

    }

    /**
     * mock 有参数的静态方法
     */
    @Test
    void givenStaticMethodWithArgs_whenMocked_thenReturnsMockSuccessfully() {
        assertThat(StaticUtils.range(2, 6)).containsExactly(2, 3, 4, 5);

        // 只有在try-catch内, mock才是有效的
        try (MockedStatic<StaticUtils> utilities = Mockito.mockStatic(StaticUtils.class)) {
            // 使用lambda来定义, 当调用range(2, 6)时, 返回[10, 11, 12]
            utilities.when(() -> StaticUtils.range(2, 6))
                    .thenReturn(Arrays.asList(10, 11, 12));

            // 实际调用并验证
            assertThat(StaticUtils.range(2, 6)).containsExactly(10, 11, 12);
        }

        assertThat(StaticUtils.range(2, 6)).containsExactly(2, 3, 4, 5);
    }
}
~~~









## mock 构造函数

我们可以对一个class的构造函数进行mock, 这样通过构造函数来创建一个对象的时候, 不会真正的调用构造函数来创建对象, 而是直接返回一个mock后的对象,  我们可以定义这个mock后的对象的各种行为



mock构造函数的场景通常是用在:   我们需要测试的函数, 他内部会new其他对象, 我们想要对new出来的对象进行mock, 然后看看我们测试的函数会怎么样的反应



下面我们来看一个简单的mock构造函数的案例

~~~java
    public static class Fruit {
        public String getName() { }
        public String getColour() { return "Red"; }
    }

    @Test
    public void test() {
        try (MockedConstruction<Fruit> mocked = Mockito.mockConstruction(Fruit.class)) {
            // 在这个范围内, Fruit的构造函数已经被mock了, 只要调用了Fruit的构造函数来创建对象,
            // 就会直接返回一个mock的Fruit对象, 而不会调用真实的构造函数

            Fruit fruit = new Fruit(); // 这会返回一个mock的Fruit对象

            // 可以对mock的Fruit对象进行一些操作
            Mockito.when(fruit.getName()).thenReturn("Banana");
            Mockito.when(fruit.getColour()).thenReturn("Yellow");

            // 验证mock的Fruit对象的方法是否被调用
            Mockito.verify(fruit).getName();
            Mockito.verify(fruit).getColour();

            // 可以使用mocked.constructed()来获取所有mock的Fruit对象
            List<Fruit> constructedFruits = mocked.constructed();
            assertThat(constructedFruits.size()).isEqualTo(1);
        }
    }
~~~





上面说了, mock构造函数的一般场景是:  我们需要测试的函数, 他内部会new其他对象, 我们想要对new出来的对象进行mock, 然后看看我们测试的函数会怎么样的反应?  下面我们来看看这种情况

~~~java
    public static class CoffeeMachine {

        private Grinder grinder;
        private WaterTank tank;

        public CoffeeMachine() {
            this.grinder = new Grinder();
            this.tank = new WaterTank();
        }

        public String makeCoffee() {
            String type = this.tank.isEspresso() ? "Espresso" : "Americano";
            return String.format("Finished making a delicious %s made with %s beans", type, this.grinder.getBeans());
        }
    }

    public static class Grinder {

        @Getter
        @Setter
        private String beans;

        public Grinder() {
            this.beans = "Guatemalan";
        }
    }

    public static class WaterTank {

        @Getter
        @Setter
        private int mils;

        public WaterTank() {
            this.mils = 25;
        }

        public boolean isEspresso() {
            return getMils() < 50;
        }
    }

    @Test
    public void test() {
        try (MockedConstruction<Grinder> mockedGrinder = Mockito.mockConstruction(Grinder.class);
             MockedConstruction<WaterTank> mockedWaterTank = Mockito.mockConstruction(WaterTank.class)) {
            // 在这个范围内, Grinder和WaterTank的构造函数已经被mock了, 只要调用了Grinder和WaterTank的构造函数来创建对象,
            // 就会直接返回一个mock的Grinder和WaterTank对象, 而不会调用真实的构造函数

            // 创建一个CoffeeMachine, 内部会调用WaterTank和Grinder的构造函数, 所以会创建他们的mock对象
            CoffeeMachine machine = new CoffeeMachine();

            WaterTank tank = mockedWaterTank.constructed().get(0); // 获取mock创建的的WaterTank对象
            Grinder grinder = mockedGrinder.constructed().get(0); // 获取mock创建的Grinder对象

            when(tank.isEspresso()).thenReturn(false); // 定义mock的WaterTank的行为
            when(grinder.getBeans()).thenReturn("Peruvian"); // 定义mock的Grinder的行为

            // 验证CoffeeMachine的行为
            Assertions.assertEquals("Finished making a delicious Americano made with Peruvian beans", machine.makeCoffee());
        }
    }
~~~



上面我们mock的构造函数都是不带参数的, 那么当构造函数具有参数时, 我们应该怎么办呢, Mockito提供了一种机制可以让我们访问到传递够来的构造函数参数,  从而定制mock bean的行为

~~~java
// 向WaterTank添加一个新的构造函数
public WaterTank(int mils) {
    this.mils = mils;
}

// 向CoffeeMachine添加一个新的构造函数
public CoffeeMachine(int mils) {
    this.grinder = new Grinder();
    this.tank = new WaterTank(mils);
}

@Test
void givenMockedContructorWithArgument_whenCoffeeMade_thenMockDependencyReturned() {
    try (MockedConstruction<WaterTank> mockTank = mockConstruction(WaterTank.class, 
      (mock, context) -> {
          // 这里我们可以获取到传入到构造函数中的参数
          int mils = (int) context.arguments().get(0);
          // 根据传递进来的参数, 来对行为进行定制
          when(mock.getMils()).thenReturn(mils);
      }); 
      MockedConstruction<Grinder> mockGrinder = mockConstruction(Grinder.class)) {
        // 创建CoffeeMachine, 内部会创建WaterTank
          CoffeeMachine machine = new CoffeeMachine(100);

        // 获取mock创建出来的WaterTank
          Grinder grinder = mockGrinder.constructed().get(0);
        // 定制行为
          when(grinder.getBeans()).thenReturn("Kenyan");
        
        // 校验
          assertEquals("Finished making a delicious Americano made with Kenyan beans", machine.makeCoffee());
        }
    }
~~~



通常情况下, 我们mock构造函数创建出来的mock对象,  他就是一个mock对象, 在调用他的方法的时候, 他不会调用真实的方法, 而是直接返回一个默认值,  如果我们想要他是一个spy对象呢? 即像一个正常的对象一样, 调用真实的方法, 我们可以像下面这样配置他

~~~java
@Test
void givenMockedContructorWithNewDefaultAnswer_whenFruitCreated_thenRealMethodInvoked() {
    // CALLS_REAL_METHODS表示在执行mock对象的方法的时候, 调用真实的方法, 而不是返回默认值
    try (MockedConstruction<Fruit> mock = mockConstruction(Fruit.class, withSettings().defaultAnswer(Answers.CALLS_REAL_METHODS))) {

        Fruit fruit = new Fruit();

        assertEquals("Apple", fruit.getName());
        assertEquals("Red", fruit.getColour());
    }
}

~~~



## mock Final类和Final方法

mock final类和final没有什么特别之处, 只需要像普通的方法一样对待就行了

唯一需要注意的就是低版本的mockito可能不支持mock final类和final方法



## mock 私有字段

假设我们有如下这样一个类

~~~java
public class MockService {
    private final Person person = new Person("John Doe");
    
    public String getName() {
        return person.getName();
    }
}
public class Person {
    private final String name;
    
    public Person(String name) {
        this.name = name;
    }
    
    public String getName() {
        return name;
    }
}
~~~

他有一个private final 属性, 我们想要mock他, 但是他说private final的, 同时也没有setter, 那么我们想要mock他, 就必须使用反射

~~~java
public class MockServiceUnitTest {
    private Person mockedPerson;

    @BeforeEach
    public void setUp(){
        mockedPerson = mock(Person.class);
    }
    
    @Test
void givenNameChangedWithReflection_whenGetName_thenReturnName() throws Exception {
    Class<?> mockServiceClass = Class.forName("com.baeldung.mockprivate.MockService");
    MockService mockService = (MockService) mockServiceClass.getDeclaredConstructor().newInstance();
    Field field = mockServiceClass.getDeclaredField("person");
    field.setAccessible(true);
    field.set(mockService, mockedPerson);

    when(mockedPerson.getName()).thenReturn("Jane Doe");

    Assertions.assertEquals("Jane Doe", mockService.getName());
}
}
~~~

如果你使用的Junit5, 那么可以使用ReflectionUtils来进行反射

~~~java
@Test
void givenNameChangedWithReflectionUtils_whenGetName_thenReturnName() throws Exception {
    MockService mockService = new MockService();
    Field field = ReflectionUtils
      .findFields(MockService.class, f -> f.getName().equals("person"),
        ReflectionUtils.HierarchyTraversalMode.TOP_DOWN)
      .get(0);

    field.setAccessible(true);
    field.set(mockService, mockedPerson);

    when(mockedPerson.getName()).thenReturn("Jane Doe");

    Assertions.assertEquals("Jane Doe", mockService.getName());
}
~~~

如果你与spring-test进行了集成, 那么你可以使用另一个工具类

~~~java
@Test
void givenNameChangedWithReflectionTestUtils_whenGetName_thenReturnName() throws Exception {
    MockService mockService = new MockService();

    ReflectionTestUtils.setField(mockService, "person", mockedPerson);

    when(mockedPerson.getName()).thenReturn("Jane Doe");
    Assertions.assertEquals("Jane Doe", mockService.getName());
}
~~~



## mock 私有方法

https://www.baeldung.com/powermock-private-method

单纯的使用mockito是没有办法mock私有方法的,  想要mock私有方法需要使用PowerMock

他的底层是mockito, 并且对mockito进行了增强, 使其能够mock私有方法



需要注意的是

1. PowerMock最高支持junit4, 不支持junit5
2. 他支持的mockito最高为3.12.4,  如果你使用了spring, 注意要降低mockito的版本, 因为spring使用的mockito太新了
3. PowerMock的依赖和mockito-inline这个包不能共存



1. 导入依赖

   ~~~xml
   <dependency>
       <groupId>org.powermock</groupId>
       <artifactId>powermock-module-junit4</artifactId>
       <version>1.7.3</version>
       <scope>test</scope>
   </dependency>
   <dependency>
       <groupId>org.powermock</groupId>
       <artifactId>powermock-api-mockito2</artifactId>
       <version>2.0.9</version>
       <scope>test</scope>
   </dependency>
   ~~~

2. powermock的使用

   ~~~java
       public static class LuckyNumberGenerator {
   
           public int getLuckyNumber(String name) {
               saveIntoDatabase(name);
               if (name == null) {
                   return getDefaultLuckyNumber();
               }
               return getComputedLuckyNumber(name.length());
           }
   
           private int getDefaultLuckyNumber() {
               return 0;
           }
   
           private int getComputedLuckyNumber(int length) {
               return 0;
           }
   
           private void saveIntoDatabase(String name) { }
   
       }
   
   
       /**
        * 这个代码跑不起来, 有可能powermock的版本有问题
        */
       @Test
       public void test() throws Exception {
           LuckyNumberGenerator luckyNumberGenerator = new LuckyNumberGenerator();
           LuckyNumberGenerator spy = PowerMockito.spy(luckyNumberGenerator);
   
           // 当调用saveIntoDatabase时, 不做任何操作
           PowerMockito.doNothing().when(spy, "saveIntoDatabase", Mockito.anyString());
           // 当调用getDefaultLuckyNumber时, 返回100
           PowerMockito.when(spy, "getDefaultLuckyNumber").thenReturn(100);
           // 当调用getComputedLuckyNumber时, 返回100
           PowerMockito.when(spy, "getComputedLuckyNumber", Mockito.anyInt()).thenReturn(100);
   
           // 调用真实的方法
           int luckyNumber = luckyNumberGenerator.getLuckyNumber("Tiger");
   
           // 校验
           Assertions.assertEquals(100, luckyNumber);
       }
   ~~~

   





## 其他

### UnnecessaryStubbingException

https://www.baeldung.com/mockito-unnecessary-stubbing-exception

简单来说, 如果我们定义了一个mock bean的多个预期的行为, 但是只我们测试的时候, 又没有调用到对应的方法, 那么就会出现这个异常

~~~java
@Test
public void givenUnusedStub_whenInvokingGetThenThrowUnnecessaryStubbingException() {
    
    // 定义了add的行为, 但是又没有调用它, 会抛出异常
    when(mockList.add("one")).thenReturn(true); 
    when(mockList.get(anyInt())).thenReturn("hello");
    assertEquals("List should contain hello", "hello", mockList.get(1));
}
~~~



### 延迟验证

https://www.baeldung.com/mockito-lazy-verification

**Mockito 的默认行为是在第一次验证失败时立即停止**，这种方法也称为*快速失败*。

但是有时我们可能需要获取所有的错误信息, 那么我们可以使用延迟验证

~~~java
@ExtendWith(MockitoExtension.class)
public class LazyVerificationTest {
 
    // 开启延迟验证
    @Rule
    public VerificationCollector verificationCollector = MockitoJUnit.collector();

    @Test
	public void testLazyVerification() throws Exception {
    	List mockList = mock(ArrayList.class);
    
    	verify(mockList).add("one"); // 失败
    	verify(mockList).clear(); // 失败
	}
}
~~~

如果没有开启延迟验证的话,  那么我们在第一次验证失败的时候就会停止

但是开启了延迟验证的话, 所有的失败情况都会进行报告

**通常来说还是挺有用的, 特别是对于大型项目, 不用一直改bug然后重复执行**





# TestContainers



### GenericContainer abstraction

Testcontainers 提供了一个名为 GenericContainer 的编程抽象，用于表示 Docker 容器。您可以使用 GenericContainer 启动 Docker 容器，获取任何容器信息，例如主机名（映射端口可访问的主机）、映射端口，以及停止容器。

For example, you can use **GenericContainer** from **Testcontainers for Java** as follows:
例如，您可以按如下方式使用 **Testcontainers for Java** 中的 **GenericContainer** ：

```java
GenericContainer container = new GenericContainer("postgres:15")
        .withExposedPorts(5432)
        .waitingFor(new LogMessageWaitStrategy()
            .withRegEx(".*database system is ready to accept connections.*\\s")
            .withTimes(2)
            .withStartupTimeout(Duration.of(60, ChronoUnit.SECONDS)));
container.start();
var username = "test";
var password = "test";
var jdbcUrl = "jdbc:postgresql://" + container.getHost() + ":" + container.getMappedPort(5432) + "/test";
//perform db operations
container.stop();
```



## Testcontainers modules 

Testcontainers为各类的基础设施软件都提供了对应的模块, 这些模块都是在GenericContainer之上的封装, 使得你能够方便的使用这些基础设施, 比如对于pg数据库, 提供了如下的module

~~~xml
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <version>1.20.0</version>
    <scope>test</scope>
</dependency>
~~~

导入之后,  你就可以使用如下代码来创建对应的pg Container了

~~~java
PostgreSQLContainer postgres = new PostgreSQLContainer("postgres:15");
postgres.start();
var username = postgres.getUsername();
var password = postgres.getPassword();
var jdbcUrl = postgres.getJdbcUrl();
//perform db operations
postgres.stop();
~~~

你可以在https://testcontainers.com/modules/ 中查看所有的Testcontainers模块





## Testcontainers的依赖

https://java.testcontainers.org/

Testcontainers for Java支持Junit4, Junit5, Spock框架, 常常用于在测试的时候, 通过数据库依赖, 或者Selenium Web浏览器以进行ui测试

要想和java进行集成

- gradle

  ~~~groovy
  testImplementation "org.testcontainers:testcontainers:1.21.3"
  ~~~

- maven

  ~~~xml
  <dependency>
      <groupId>org.testcontainers</groupId>
      <artifactId>testcontainers</artifactId>
      <version>1.21.3</version>
      <scope>test</scope>
  </dependency>
  ~~~

当然你也可以在https://central.sonatype.com/search?q=testcontainers&smo=true查看testcontainrs的最新版本



同时你也可通过testcontainers提供的bom来管理所有的testcontainers相关的依赖的版本

- maven

  ~~~xml
  <dependencyManagement>
      <dependencies>
          <dependency>
              <groupId>org.testcontainers</groupId>
              <artifactId>testcontainers-bom</artifactId>
              <version>1.21.3</version>
              <type>pom</type>
              <scope>import</scope>
          </dependency>
      </dependencies>
  </dependencyManagement>
  
  <!-- 这里无需再指定版本了 -->
  <dependency>
      <groupId>org.testcontainers</groupId>
      <artifactId>mysql</artifactId>
      <scope>test</scope>
  </dependency>
  ~~~

- Gradle

  ~~~groovy
  implementation platform('org.testcontainers:testcontainers-bom:1.21.3') //import bom
  testImplementation('org.testcontainers:mysql') // 相关依赖不需要指定版本
  ~~~




## 在Java项目中测试数据库

1. 首先我们添加如下的依赖

   ~~~xml
   <dependencies>
       <dependency>
           <groupId>org.postgresql</groupId>
           <artifactId>postgresql</artifactId>
           <version>42.7.3</version>
       </dependency>
       <dependency>
           <groupId>ch.qos.logback</groupId>
           <artifactId>logback-classic</artifactId>
           <version>1.5.6</version>
       </dependency>
       <dependency>
           <groupId>org.junit.jupiter</groupId>
           <artifactId>junit-jupiter</artifactId>
           <version>5.10.2</version>
           <scope>test</scope>
       </dependency>
   </dependencies>
   
   <build>
       <plugins>
           <plugin>
               <!-- 启动测试的插件 -->
               <groupId>org.apache.maven.plugins</groupId>
               <artifactId>maven-surefire-plugin</artifactId>
               <version>3.2.5</version>
           </plugin>
       </plugins>
   </build>
   ~~~

2. 定义一个Customer作为实体类

   ~~~java
   package com.testcontainers.demo;
   
   public record Customer(Long id, String name) {}
   ~~~

3. 创建 **DBConnectionProvider.java** 类来保存 JDBC 连接参数，并创建一个获取数据库 **Connection** 的方法

   ~~~java
   package com.testcontainers.demo;
   
   import java.sql.Connection;
   import java.sql.DriverManager;
   
   class DBConnectionProvider {
   
     private final String url;
     private final String username;
     private final String password;
   
     public DBConnectionProvider(String url, String username, String password) {
       this.url = url;
       this.username = username;
       this.password = password;
     }
   
     // 通过数据库的参数, 返回一个Connection
     Connection getConnection() {
       try {
         return DriverManager.getConnection(url, username, password);
       } catch (Exception e) {
         throw new RuntimeException(e);
       }
     }
   }
   ~~~

4. 创建 **CustomerService.java** 

   ~~~java
   package com.testcontainers.demo;
   
   import java.sql.Connection;
   import java.sql.PreparedStatement;
   import java.sql.ResultSet;
   import java.sql.SQLException;
   import java.util.ArrayList;
   import java.util.List;
   
   public class CustomerService {
   
     private final DBConnectionProvider connectionProvider;
   
     public CustomerService(DBConnectionProvider connectionProvider) {
       this.connectionProvider = connectionProvider;
       createCustomersTableIfNotExists();
     }
   
       // 插入一个Customer
     public void createCustomer(Customer customer) {
       try (Connection conn = this.connectionProvider.getConnection()) {
         PreparedStatement pstmt = conn.prepareStatement(
           "insert into customers(id,name) values(?,?)"
         );
         pstmt.setLong(1, customer.id());
         pstmt.setString(2, customer.name());
         pstmt.execute();
       } catch (SQLException e) {
         throw new RuntimeException(e);
       }
     }
   
       // 查询所有的Customer
     public List<Customer> getAllCustomers() {
       List<Customer> customers = new ArrayList<>();
   
       try (Connection conn = this.connectionProvider.getConnection()) {
         PreparedStatement pstmt = conn.prepareStatement(
           "select id,name from customers"
         );
         ResultSet rs = pstmt.executeQuery();
         while (rs.next()) {
           long id = rs.getLong("id");
           String name = rs.getString("name");
           customers.add(new Customer(id, name));
         }
       } catch (SQLException e) {
         throw new RuntimeException(e);
       }
       return customers;
     }
   
       // 如果customers表不存在, 那么就创建这个表
     private void createCustomersTableIfNotExists() {
       try (Connection conn = this.connectionProvider.getConnection()) {
         PreparedStatement pstmt = conn.prepareStatement(
           """
           create table if not exists customers (
               id bigint not null,
               name varchar not null,
               primary key (id)
           )
           """
         );
         pstmt.execute();
       } catch (SQLException e) {
         throw new RuntimeException(e);
       }
     }
   }
   ~~~

5. 我们添加Testcontainers依赖

   ~~~xml
   <dependency>
       <groupId>org.testcontainers</groupId>
       <artifactId>postgresql</artifactId>
       <version>1.19.8</version>
       <scope>test</scope>
   </dependency>
   ~~~

6. 在 **src/test/java** 下创建 **CustomerServiceTest.java**, 并编写测试代码

   ~~~java
   package com.testcontainers.demo;
   
   import static org.junit.jupiter.api.Assertions.assertEquals;
   
   import java.util.List;
   import org.junit.jupiter.api.AfterAll;
   import org.junit.jupiter.api.BeforeAll;
   import org.junit.jupiter.api.BeforeEach;
   import org.junit.jupiter.api.Test;
   import org.testcontainers.containers.PostgreSQLContainer;
   
   class CustomerServiceTest {
   
       // 通过如下代码, 会通过docker创建一个pg的容器
     static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>(
       "postgres:16-alpine"
     );
   
     CustomerService customerService;
   
     @BeforeAll
     static void beforeAll() {
         // 在所有测试用例执行之前启动pg容器
       postgres.start();
     }
   
     @AfterAll
     static void afterAll() {
         // 在所有测试用例执行之后, 停止并删除pg容器
       postgres.stop();
     }
   
     @BeforeEach
     void setUp() {
       DBConnectionProvider connectionProvider = new DBConnectionProvider(
         postgres.getJdbcUrl(),
         postgres.getUsername(),
         postgres.getPassword()
       );
       customerService = new CustomerService(connectionProvider);
     }
   
     @Test
     void shouldGetCustomers() {
         // 插入两个customer到数据库中
       customerService.createCustomer(new Customer(1L, "George"));
       customerService.createCustomer(new Customer(2L, "John"));
   
         // 断言是否正确的插入了数据
       List<Customer> customers = customerService.getAllCustomers();
       assertEquals(2, customers.size());
     }
   }
   ~~~

   



## 在Springboot项目中测试数据库

这是一个web项目, 使用spring web作为web框架, spring data jpa作为作为orm框架, pg作为数据库, testcontainer作为容器启动器



你可以从如下地址中获取到代码

 https://github.com/testcontainers/tc-guide-testing-spring-boot-rest-api.git



1. 添加maven依赖

   ~~~xml
   <properties>
       <java.version>17</java.version>
       <testcontainers.version>1.19.8</testcontainers.version>
   </properties>
   <dependencies>
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-data-jpa</artifactId>
       </dependency>
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-web</artifactId>
       </dependency>
       <dependency>
           <groupId>org.postgresql</groupId>
           <artifactId>postgresql</artifactId>
           <scope>runtime</scope>
       </dependency>
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-test</artifactId>
           <scope>test</scope>
       </dependency>
       <dependency>
           <groupId>org.testcontainers</groupId>
           <artifactId>junit-jupiter</artifactId>
           <scope>test</scope>
       </dependency>
       <dependency>
           <groupId>org.testcontainers</groupId>
           <artifactId>postgresql</artifactId>
           <scope>test</scope>
       </dependency>
   </dependencies>
   ~~~

2. 创建jpa相关的entity

   ~~~java
   package com.testcontainers.demo;
   
   import jakarta.persistence.Column;
   import jakarta.persistence.Entity;
   import jakarta.persistence.GeneratedValue;
   import jakarta.persistence.GenerationType;
   import jakarta.persistence.Id;
   import jakarta.persistence.Table;
   
   @Entity
   @Table(name = "customers")
   class Customer {
   
     @Id
     @GeneratedValue(strategy = GenerationType.IDENTITY)
     private Long id;
   
     @Column(nullable = false)
     private String name;
   
     @Column(nullable = false, unique = true)
     private String email;
   
     public Customer() {}
   
     public Customer(Long id, String name, String email) {
       this.id = id;
       this.name = name;
       this.email = email;
     }
   
     // getter, setter
   }
   ~~~

3. 创建jpa相关的repository

   ~~~java
   package com.testcontainers.demo;
   
   import org.springframework.data.jpa.repository.JpaRepository;
   
   interface CustomerRepository extends JpaRepository<Customer, Long> {}
   ~~~

4. 创建一个 `src/main/resources/schema.sql `文件

   ~~~java
   create table if not exists customers (
       id bigserial not null,
       name varchar not null,
       email varchar not null,
       primary key (id),
       UNIQUE (email)
   );
   ~~~

5. 在`src/main/resources/application.properties`中添加如下的属性, 这样springboot会在启动的时候去执行上面的schema.sql

   ~~~properties
   spring.sql.init.mode=always
   ~~~

6. 创建一个controller

   ~~~java
   package com.testcontainers.demo;
   
   import java.util.List;
   import org.springframework.web.bind.annotation.GetMapping;
   import org.springframework.web.bind.annotation.RestController;
   
   @RestController
   class CustomerController {
   
     private final CustomerRepository repo;
   
     CustomerController(CustomerRepository repo) {
       this.repo = repo;
     }
   
     @GetMapping("/api/customers")
     List<Customer> getAll() {
       return repo.findAll();
     }
   }
   ~~~

7. 为controller添加测试

   首先我们需要导入rest-assured包, 他是一个用来调用controller接口的模块

   ~~~xml
   <dependency>
       <groupId>io.rest-assured</groupId>
       <artifactId>rest-assured</artifactId>
       <scope>test</scope>
   </dependency>
   ~~~

   如果你使用的是gradle, 那么添加如下的依赖

   ~~~groovy
   testImplementation 'io.rest-assured:rest-assured'
   ~~~

8. 接下来我们来编写测试类

   ~~~java
   package com.testcontainers.demo;
   
   import static io.restassured.RestAssured.given;
   import static org.hamcrest.Matchers.hasSize;
   
   import io.restassured.RestAssured;
   import io.restassured.http.ContentType;
   import java.util.List;
   import org.junit.jupiter.api.AfterAll;
   import org.junit.jupiter.api.BeforeAll;
   import org.junit.jupiter.api.BeforeEach;
   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.boot.test.web.server.LocalServerPort;
   import org.springframework.test.context.DynamicPropertyRegistry;
   import org.springframework.test.context.DynamicPropertySource;
   import org.testcontainers.containers.PostgreSQLContainer;
   
   // 随机端口启动web
   @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
   class CustomerControllerTest {
   
       // 注入当前的随机端口
     @LocalServerPort
     private Integer port;
   
     static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>(
       "postgres:16-alpine"
     );
   
     @BeforeAll
     static void beforeAll() {
         // 在所有的测试启动之前, 启动容器
       postgres.start();
     }
   
     @AfterAll
     static void afterAll() {
         // 在所有的测试执行之后, 销毁容器
       postgres.stop();
     }
   
     @DynamicPropertySource
     static void configureProperties(DynamicPropertyRegistry registry) {
         // 将容器的信息, 动态的注册到springboot的配置中, 这样数据源就可以使用这个配置来创建连接了
         // 这和在application.yaml中添加配置是一样的作用的
       registry.add("spring.datasource.url", postgres::getJdbcUrl);
       registry.add("spring.datasource.username", postgres::getUsername);
       registry.add("spring.datasource.password", postgres::getPassword);
     }
   
     @Autowired
     CustomerRepository customerRepository;
   
     @BeforeEach
     void setUp() {
         // 设置RestAssured调用路径的baseURI
         // 在每个测试用例开始之前, 都删除掉数据
       RestAssured.baseURI = "http://localhost:" + port;
       customerRepository.deleteAll();
     }
   
     @Test
     void shouldGetAllCustomers() {
       List<Customer> customers = List.of(
         new Customer(null, "John", "john@mail.com"),
         new Customer(null, "Dennis", "dennis@mail.com")
       );
       customerRepository.saveAll(customers);
       
         // 调用controller的接口, 测试接口是否正确
       given()
         .contentType(ContentType.JSON)
         .when()
         .get("/api/customers")
         .then()
         .statusCode(200)
         .body(".", hasSize(2));
     }
   }
   ~~~

9. 执行测试

   ~~~shell
   # If you are using Maven
   ./mvnw test
   
   # If you are using Gradle
   ./gradlew test
   ~~~

   



## 在springboot项目中测试kafka listener

在这个项目中, 我们使用到了spring for kafka, spring data jpa, mysql, testcontainer, 并且使用awaitility作为断言库

这个项目是用来测试kafka listener能否接受到kafka client发送的消息, 并将消息写入到数据库中



1. 导入依赖

   ~~~groovy
   dependencies {
       implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
       implementation 'org.springframework.kafka:spring-kafka'
       runtimeOnly 'com.mysql:mysql-connector-j'
   
       testImplementation 'org.springframework.boot:spring-boot-starter-test'
       testImplementation 'org.testcontainers:junit-jupiter'
       testImplementation 'org.springframework.kafka:spring-kafka-test'
       testImplementation 'org.testcontainers:junit-jupiter'
       testImplementation 'org.testcontainers:kafka'
       testImplementation 'org.testcontainers:mysql'
       testImplementation 'org.awaitility:awaitility'
   }
   ~~~

2. 创建jpa的entity

   ~~~java
   package com.testcontainers.demo;
   
   import jakarta.persistence.Column;
   import jakarta.persistence.Entity;
   import jakarta.persistence.GeneratedValue;
   import jakarta.persistence.GenerationType;
   import jakarta.persistence.Id;
   import jakarta.persistence.Table;
   import java.math.BigDecimal;
   
   @Entity
   @Table(name = "products")
   class Product {
   
     @Id
     @GeneratedValue(strategy = GenerationType.IDENTITY)
     private Long id;
   
     @Column(nullable = false, unique = true)
     private String code;
   
     @Column(nullable = false)
     private String name;
   
     @Column(nullable = false)
     private BigDecimal price;
   
     public Product() {}
   
     public Product(Long id, String code, String name, BigDecimal price) {
       this.id = id;
       this.code = code;
       this.name = name;
       this.price = price;
     }
   
   	// getter, setter
   }
   ~~~

3. 创建jpa的entity

   ~~~java
   package com.testcontainers.demo;
   
   import java.math.BigDecimal;
   import java.util.Optional;
   import org.springframework.data.jpa.repository.JpaRepository;
   import org.springframework.data.jpa.repository.Modifying;
   import org.springframework.data.jpa.repository.Query;
   import org.springframework.data.repository.query.Param;
   
   interface ProductRepository extends JpaRepository<Product, Long> {
     Optional<Product> findByCode(String code);
   
     @Modifying
     @Query("update Product p set p.price = :price where p.code = :productCode")
     void updateProductPrice(
       @Param("productCode") String productCode,
       @Param("price") BigDecimal price
     );
   }
   ~~~

4. 在 **src/main/resources** 目录下创建一个包含以下内容的 **schema.sql** 文件

   ~~~sql
   create table products if not exists (
         id int NOT NULL AUTO_INCREMENT,
         code varchar(255) not null,
         name varchar(255) not null,
         price numeric(5,2) not null,
         PRIMARY KEY (id),
         UNIQUE (code)
   );
   ~~~

5. 我们还需要通过在 **src/main/resources/application.properties** 文件中添加以下属性来启用schema初始化

   ~~~properties
   spring.sql.init.mode=always
   ~~~

6. 创建kafka的事件对象

   ~~~java
   package com.testcontainers.demo;
   
   import java.math.BigDecimal;
   
   record ProductPriceChangedEvent(String productCode, BigDecimal price) {}
   ~~~

7. 创建一个kafka listener, 用来监听kafka的消息, 并将消息写入到数据库中

   ~~~java
   package com.testcontainers.demo;
   
   import org.slf4j.Logger;
   import org.slf4j.LoggerFactory;
   import org.springframework.kafka.annotation.KafkaListener;
   import org.springframework.stereotype.Component;
   import org.springframework.transaction.annotation.Transactional;
   
   @Component
   @Transactional
   class ProductPriceChangedEventHandler {
   
     private static final Logger log = LoggerFactory.getLogger(
       ProductPriceChangedEventHandler.class
     );
   
     private final ProductRepository productRepository;
   
     ProductPriceChangedEventHandler(ProductRepository productRepository) {
       this.productRepository = productRepository;
     }
   
     @KafkaListener(topics = "product-price-changes", groupId = "demo")
     public void handle(ProductPriceChangedEvent event) {
       log.info(
         "Received a ProductPriceChangedEvent with productCode:{}: ",
         event.productCode()
       );
         // 根据数据库中指定商品的价格
       productRepository.updateProductPrice(event.productCode(), event.price());
     }
   }
   ~~~

8. 我们还需要在`src/main/resources/application.properties`中添加如下的属性

   ~~~properties
   # 生产者的配置参数
   spring.kafka.bootstrap-servers=localhost:9092
   spring.kafka.producer.key-serializer=org.apache.kafka.common.serialization.StringSerializer
   spring.kafka.producer.value-serializer=org.springframework.kafka.support.serializer.JsonSerializer
   
   # 消费者的参数
   spring.kafka.consumer.group-id=demo
   spring.kafka.consumer.auto-offset-reset=latest
   spring.kafka.consumer.key-deserializer=org.apache.kafka.common.serialization.StringDeserializer
   spring.kafka.consumer.value-deserializer=org.springframework.kafka.support.serializer.JsonDeserializer
   spring.kafka.consumer.properties.spring.json.trusted.packages=com.testcontainers.demo
   ~~~

9. 为kafka listener编写测试

   ~~~java
   package com.testcontainers.demo;
   
   import static java.util.concurrent.TimeUnit.SECONDS;
   import static org.assertj.core.api.Assertions.assertThat;
   import static org.awaitility.Awaitility.await;
   
   import java.math.BigDecimal;
   import java.time.Duration;
   import java.util.Optional;
   import org.junit.jupiter.api.BeforeEach;
   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.kafka.core.KafkaTemplate;
   import org.springframework.test.context.DynamicPropertyRegistry;
   import org.springframework.test.context.DynamicPropertySource;
   import org.springframework.test.context.TestPropertySource;
   import org.testcontainers.containers.KafkaContainer;
   import org.testcontainers.junit.jupiter.Container;
   import org.testcontainers.junit.jupiter.Testcontainers;
   import org.testcontainers.utility.DockerImageName;
   
   @SpringBootTest
   @TestPropertySource(
     properties = {
         // 将消费的offset指定为earlist, 这样即使先发送了消息, listener才启动, 也可以消费到这个消息
       "spring.kafka.consumer.auto-offset-reset=earliest",
         // 指定数据库的url, 让他使用testcontainer提供的容器的url
       "spring.datasource.url=jdbc:tc:mysql:8.0.32:///db",
     }
   )
   @Testcontainers
   class ProductPriceChangedEventHandlerTest {
   
     @Container
     static final KafkaContainer kafka = new KafkaContainer(
       DockerImageName.parse("confluentinc/cp-kafka:7.6.1")
     );
   
     @DynamicPropertySource
     static void overrideProperties(DynamicPropertyRegistry registry) {
         // 动态的注入kafka bootstrap-server的地址
         // 这和在application.yaml中添加这个配置是一样的
       registry.add("spring.kafka.bootstrap-servers", kafka::getBootstrapServers);
     }
   
     @Autowired
     private KafkaTemplate<String, Object> kafkaTemplate;
   
     @Autowired
     private ProductRepository productRepository;
   
     @BeforeEach
     void setUp() {
         // 在每次启动测试之前, 都插入一个商品信息
       Product product = new Product(null, "P100", "Product One", BigDecimal.TEN);
       productRepository.save(product);
     }
   
     @Test
     void shouldHandleProductPriceChangedEvent() {
         // 创建爱你一个kafka消息
       ProductPriceChangedEvent event = new ProductPriceChangedEvent(
         "P100",
         new BigDecimal("14.50")
       );
   
         // 发送kafka消息
       kafkaTemplate.send("product-price-changes", event.productCode(), event);
   
         // 断言, 等待三秒, 最多等待10秒, 测试数据库中关于P100的商品的信息
       await()
         .pollInterval(Duration.ofSeconds(3))
         .atMost(10, SECONDS)
         .untilAsserted(() -> {
           Optional<Product> optionalProduct = productRepository.findByCode(
             "P100"
           );
           assertThat(optionalProduct).isPresent();
           assertThat(optionalProduct.get().getCode()).isEqualTo("P100");
           assertThat(optionalProduct.get().getPrice())
             .isEqualTo(new BigDecimal("14.50"));
         });
     }
   }
   ~~~

10. 执行测试

    ~~~shell
    # If you are using Maven
    ./mvnw test
    
    # If you are using Gradle
    ./gradlew test
    ~~~

    执行完毕之后, 容器会自动停止并删除





## 在springboot项目中测试第三方http接口

在本次项目中, 我们正在构建一个管理视频和相册的引用, 并将第三方的rest api的 https://jsonplaceholder.typicode.com/地址来保存照片

我们将使用 [WireMock](https://wiremock.org/) （一个用于构建模拟 API 的工具）来模拟外部服务交互并测试我们的 API 端点。



1. 首先创建一个相册,  和照片的pojo

   ~~~java
   package com.testcontainers.demo;
   
   import java.util.List;
   
   public record Album(Long albumId, List<Photo> photos) {}
   
   record Photo(Long id, String title, String url, String thumbnailUrl) {}
   ~~~

2. 创建 PhotoServiceClient ，它在内部使用 RestTemplate ，来获取给定 albumId 的照片

   ~~~java
   package com.testcontainers.demo;
   
   import java.util.List;
   import org.springframework.beans.factory.annotation.Value;
   import org.springframework.boot.web.client.RestTemplateBuilder;
   import org.springframework.core.ParameterizedTypeReference;
   import org.springframework.http.HttpMethod;
   import org.springframework.http.ResponseEntity;
   import org.springframework.stereotype.Service;
   import org.springframework.web.client.RestTemplate;
   
   @Service
   class PhotoServiceClient {
   
     private final String baseUrl;
     private final RestTemplate restTemplate;
   
     PhotoServiceClient(
       @Value("${photos.api.base-url}") String baseUrl,
       RestTemplateBuilder builder
     ) {
       this.baseUrl = baseUrl;
       this.restTemplate = builder.build();
     }
   
     List<Photo> getPhotos(Long albumId) {
         // 调用rest api来获取指定相册的所有图片
       String url = baseUrl + "/albums/{albumId}/photos";
       ResponseEntity<List<Photo>> response = restTemplate.exchange(
         url,
         HttpMethod.GET,
         null,
         new ParameterizedTypeReference<>() {},
         albumId
       );
       return response.getBody();
     }
   }
   ~~~

3. 因为上面使用到了 `photos.api.base-url`这个属性作为http的base uri, 所以我们还需要在src/main/resources/application.properties 文件中添加以下属性

   ~~~properties
   photos.api.base-url=https://jsonplaceholder.typicode.com
   ~~~

4. 让我们实现一个controller, 他调用PhotoServiceClient来返回指定相册的所有图片

   ~~~java
   package com.testcontainers.demo;
   
   import java.util.List;
   import org.slf4j.Logger;
   import org.slf4j.LoggerFactory;
   import org.springframework.http.ResponseEntity;
   import org.springframework.web.bind.annotation.GetMapping;
   import org.springframework.web.bind.annotation.PathVariable;
   import org.springframework.web.bind.annotation.RequestMapping;
   import org.springframework.web.bind.annotation.RestController;
   import org.springframework.web.client.RestClientResponseException;
   
   @RestController
   @RequestMapping("/api")
   class AlbumController {
   
     private static final Logger logger = LoggerFactory.getLogger(
       AlbumController.class
     );
   
     private final PhotoServiceClient photoServiceClient;
   
     AlbumController(PhotoServiceClient photoServiceClient) {
       this.photoServiceClient = photoServiceClient;
     }
   
     @GetMapping("/albums/{albumId}")
     public ResponseEntity<Album> getAlbumById(@PathVariable Long albumId) {
       try {
           // 通过photoServiceClient调用第三方的接口, 获取指定相册的所有图片
         List<Photo> photos = photoServiceClient.getPhotos(albumId);
         return ResponseEntity.ok(new Album(albumId, photos));
       } catch (RestClientResponseException e) {
         logger.error("Failed to get photos", e);
         return new ResponseEntity<>(e.getStatusCode());
       }
     }
   }
   ~~~

5. 此时我们要实现这个第三方的http接口, 并让他暴露出`/albums/{albumId}/photos`这个接口, 并且返回类似如下内容的响应

   ~~~json
   {
      "albumId": 1,
      "photos": [
          {
              "id": 51,
              "title": "non sunt voluptatem placeat consequuntur rem incidunt",
              "url": "https://via.placeholder.com/600/8e973b",
              "thumbnailUrl": "https://via.placeholder.com/150/8e973b"
          },
          {
              "id": 52,
              "title": "eveniet pariatur quia nobis reiciendis laboriosam ea",
              "url": "https://via.placeholder.com/600/121fa4",
              "thumbnailUrl": "https://via.placeholder.com/150/121fa4"
          },
          ...
          ...
      ]
   }
   ~~~

6. 我们可以直接通过mockito来模拟`photoServiceClient.getPhotos(albumId);`这个方法, 但是这样的话, 就没有办法来测试序列化, 反序列化的问题了, 也没有办法来测试网络延迟的问题了, 所以我们可以通过WireMock中的WireMockExtension类来启动一个服务器, 并让他在接受到特定的url的时候, 返回特定的json内容, 这样我们就快速的实现了一个第三方的http服务器

   ~~~java
   package com.testcontainers.demo;
   
   import static com.github.tomakehurst.wiremock.client.WireMock.aResponse;
   import static com.github.tomakehurst.wiremock.client.WireMock.urlMatching;
   import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.wireMockConfig;
   import static io.restassured.RestAssured.given;
   import static org.hamcrest.CoreMatchers.is;
   import static org.hamcrest.Matchers.hasSize;
   import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;
   
   import com.github.tomakehurst.wiremock.client.WireMock;
   import com.github.tomakehurst.wiremock.junit5.WireMockExtension;
   import io.restassured.RestAssured;
   import io.restassured.http.ContentType;
   import org.junit.jupiter.api.BeforeEach;
   import org.junit.jupiter.api.Test;
   import org.junit.jupiter.api.extension.RegisterExtension;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.boot.test.web.server.LocalServerPort;
   import org.springframework.http.MediaType;
   import org.springframework.test.context.DynamicPropertyRegistry;
   import org.springframework.test.context.DynamicPropertySource;
   
   // 随机的web端口
   @SpringBootTest(webEnvironment = RANDOM_PORT)
   class AlbumControllerTest {
   
       // 获取这个随机的端口
     @LocalServerPort
     private Integer port;
   
       // 创建一个WireMockExtension来启动一个WireMockExtension服务器
     @RegisterExtension
     static WireMockExtension wireMock = WireMockExtension
       .newInstance()
       .options(wireMockConfig().dynamicPort()) // 启动在随机的端口
       .build();
   
     @DynamicPropertySource
     static void configureProperties(DynamicPropertyRegistry registry) {
       // 将wireMock的地址, 设置到属性中
       // 这和在application.yaml中添加photos.api.base-url是一样的
       registry.add("photos.api.base-url", wireMock::baseUrl);
     }
   
     @BeforeEach
     void setUp() {
         // 指定RestAssured调用的端口为web端口
       RestAssured.port = port;
     }
   
     @Test
     void shouldGetAlbumById() {
       Long albumId = 1L;
      // 指定wireMock在接受到特定的请求之后, 返回特定的json
       wireMock.stubFor(
         WireMock
           .get(urlMatching("/albums/" + albumId + "/photos"))
           .willReturn(
             aResponse()
               .withHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
               .withBody(
                 """
                 [
                      {
                          "id": 1,
                          "title": "accusamus beatae ad facilis cum similique qui sunt",
                          "url": "https://via.placeholder.com/600/92c952",
                          "thumbnailUrl": "https://via.placeholder.com/150/92c952"
                      },
                      {
                          "id": 2,
                          "title": "reprehenderit est deserunt velit ipsam",
                          "url": "https://via.placeholder.com/600/771796",
                          "thumbnailUrl": "https://via.placeholder.com/150/771796"
                      }
                  ]
                 """
               )
           )
       );
   
         // 通过RestAssured来调用controller的接口, 进行测试
       given()
         .contentType(ContentType.JSON)
         .when()
         .get("/api/albums/{albumId}", albumId)
         .then()
         .statusCode(200)
         .body("albumId", is(albumId.intValue()))
         .body("photos", hasSize(2));
     }
   
     @Test
     void shouldReturnServerErrorWhenPhotoServiceCallFailed() {
       Long albumId = 2L;
         // 指定wireMock在接受到特定的url的时候, 报错
       wireMock.stubFor(
         WireMock
           .get(urlMatching("/albums/" + albumId + "/photos"))
           .willReturn(aResponse().withStatus(500))
       );
   
         // 测试
       given()
         .contentType(ContentType.JSON)
         .when()
         .get("/api/albums/{albumId}", albumId)
         .then()
         .statusCode(500);
     }
   }
   ~~~

7. 在上面的代码中, 我们是通过java代码, 来指定WireMock在接受到指定的url访问的时候返回特定的json文件, 当然我们也可以将这些url和返回的json放在一个json文件中来指定

   首选我们要创建一个`src/test/resources/wiremock/mappings/get-album-photos.json`文件

   ~~~json
   {
     "mappings": [
       {
         "request": {
           "method": "GET",
           "urlPattern": "/albums/([0-9]+)/photos"
         },
         "response": {
           "status": 200,
           "headers": {
             "Content-Type": "application/json"
           },
           "jsonBody": [
             {
               "id": 1,
               "title": "accusamus beatae ad facilis cum similique qui sunt",
               "url": "https://via.placeholder.com/600/92c952",
               "thumbnailUrl": "https://via.placeholder.com/150/92c952"
             },
             {
               ...
             }
           ]
         }
       }
     ]
   }
   ~~~

   然后通过如下代码, 让wiremock读取指定目录下的文件, 来匹配url和要返回的json

   ~~~java
   @RegisterExtension
   static WireMockExtension wireMock = WireMockExtension.newInstance()
        .options(
            wireMockConfig()
               .dynamicPort()
       // 读取src/test/resources/wiremock下的json文件
               .usingFilesUnderClasspath("wiremock")
       )
       .build();
   ~~~

   然后就可以这样编写测试用例了

   ~~~java
     @Test
     void shouldGetAlbumById() {
       Long albumId = 1L;
   
       given()
         .contentType(ContentType.JSON)
         .when()
         .get("/api/albums/{albumId}", albumId)
         .then()
         .statusCode(200)
         .body("albumId", is(albumId.intValue()))
         .body("photos", hasSize(2));
     }
   ~~~

8. 在上面的代码中, 我们实际上是通过WireMockExtension启动了一个服务器, 来模拟第三方接口, 我们也可以通过Testcontainer来将WireMockExtension跑在docker容器中

   ~~~java
   @SpringBootTest(webEnvironment = RANDOM_PORT) // web启动在随机的端口
   @Testcontainers
   class AlbumControllerTestcontainersTests {
   
       @LocalServerPort
       private Integer port;
   
       // 通过WireMockContainer, 会启动一个docker容器, 内置了一个WireMockExtension启动的服务器
       @Container
       static WireMockContainer wiremockServer = new WireMockContainer("wiremock/wiremock:3.6.0")
               .withMapping("photos-by-album",
                           // 读取src/test/resources/com/testcontainrs/demoAlbumControllerTestcontainersTests下的mocks-config.json作为配置文件
                           AlbumControllerTestcontainersTests.class,
                           "mocks-config.json");
   
       @DynamicPropertySource
       static void configureProperties(DynamicPropertyRegistry registry) {
           // 获取wiremock的baseurl, 注册到属性中
           registry.add("photos.api.base-url", wiremockServer::getBaseUrl);
       }
   
       @BeforeEach
       void setUp() {
           // 设置web端口的port, RestAssured是用于调用controller接口的
           RestAssured.port = port;
       }
   
       @Test
       void shouldGetAlbumById() {
           Long albumId = 1L;
   
           given().contentType(ContentType.JSON)
                   .when()
                   .get("/api/albums/{albumId}", albumId)
                   .then()
                   .statusCode(200)
                   .body("albumId", is(albumId.intValue()))
                   .body("photos", hasSize(1));
       }
   }
   ~~~

   我们创建需要读取的wiremock

   ~~~json
   {
     "mappings": [
       {
         "request": {
           "method": "GET",
           "urlPattern": "/albums/([0-9]+)/photos"
         },
         "response": {
           "status": 200,
           "headers": {
             "Content-Type": "application/json"
           },
           "jsonBody": [
             {
               "id": 1,
               "title": "accusamus beatae ad facilis cum similique qui sunt",
               "url": "https://via.placeholder.com/600/92c952",
               "thumbnailUrl": "https://via.placeholder.com/150/92c952"
             }
           ]
         }
       }
     ]
   }
   ~~~

9. 之后我们可以通过如下的命令, 来执行测试

   ~~~shell
   # If you are using Maven
   ./mvnw test
   
   # If you are using Gradle
   ./gradlew test
   ~~~

   