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



### Junit5与其他断言库结合使用

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
// @AutoConfigureMockMvc
// @WebMvcTest结合了@SpringBootTest和@@AutoConfigureMockMvc的功能,
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
        mockMvc.perform(get("/rest/widgets"))
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
    @DisplayName("GET /rest/widget/1")
    void testGetWidgetById() throws Exception {
        // Set up our mocked service
        Widget widget = new Widget(1L, "Widget Name", "Description", 1);
        doReturn(Optional.of(widget)).when(service).findById(1L);

        // 执行get请求, 并传入参数
        mockMvc.perform(get("/rest/widget/{id}", 1L))
                // Validate the response code and content type
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))

                // Validate headers
                .andExpect(header().string(HttpHeaders.LOCATION, "/rest/widget/1"))
                .andExpect(header().string(HttpHeaders.ETAG, "1"))

                // Validate the returned fields
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.name", is("Widget Name")))
                .andExpect(jsonPath("$.description", is("Description")))
                .andExpect(jsonPath("$.version", is(1)));
    }

    @Test
    @DisplayName("GET /rest/widget/1 - Not Found")
    void testGetWidgetByIdNotFound() throws Exception {
        // Setup our mocked service
        doReturn(Optional.empty()).when(service).findById(1L);

        // Execute the GET request
        mockMvc.perform(get("/rest/widget/{id}", 1L))
                // Validate the response code
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
        mockMvc.perform(post("/rest/widget")
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

    @Test
    @DisplayName("PUT /rest/widget/1")
    void testUpdateWidget() throws Exception {
        // Setup our mocked service
        Widget widgetToPut = new Widget("New Widget", "This is my widget");
        Widget widgetToReturnFindBy = new Widget(1L, "New Widget", "This is my widget", 2);
        Widget widgetToReturnSave = new Widget(1L, "New Widget", "This is my widget", 3);
        doReturn(Optional.of(widgetToReturnFindBy)).when(service).findById(1L);
        doReturn(widgetToReturnSave).when(service).save(any());

        // Execute the POST request
        mockMvc.perform(put("/rest/widget/{id}", 1L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .header(HttpHeaders.IF_MATCH, 2)
                        .content(asJsonString(widgetToPut)))

                // Validate the response code and content type
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))

                // Validate headers
                .andExpect(header().string(HttpHeaders.LOCATION, "/rest/widget/1"))
                .andExpect(header().string(HttpHeaders.ETAG, "3"))

                // Validate the returned fields
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.name", is("New Widget")))
                .andExpect(jsonPath("$.description", is("This is my widget")))
                .andExpect(jsonPath("$.version", is(3)));
    }

    @Test
    @DisplayName("PUT /rest/widget/1 - Conflict")
    void testUpdateWidgetConflict() throws Exception {
        // Setup our mocked service
        Widget widgetToPut = new Widget("New Widget", "This is my widget", 1);
        Widget widgetToReturn = new Widget(1L, "New Widget", "This is my widget", 2);
        doReturn(Optional.of(widgetToReturn)).when(service).findById(1L);
        doReturn(widgetToReturn).when(service).save(any());

        // Execute the POST request
        mockMvc.perform(put("/rest/widget/{id}", 1L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .header(HttpHeaders.IF_MATCH, 3)
                        .content(asJsonString(widgetToPut)))

                // Validate the response code and content type
                .andExpect(status().isConflict());
    }

    @Test
    @DisplayName("PUT /rest/widget/1 - Not Found")
    void testUpdateWidgetNotFound() throws Exception {
        // Setup our mocked service
        Widget widgetToPut = new Widget("New Widget", "This is my widget");
        doReturn(Optional.empty()).when(service).findById(1L);

        // Execute the POST request
        mockMvc.perform(put("/rest/widget/{id}", 1L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .header(HttpHeaders.IF_MATCH, 3)
                        .content(asJsonString(widgetToPut)))

                // Validate the response code and content type
                .andExpect(status().isNotFound());
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
        // Setup our mocked service
        Widget widgetToPut = new Widget("New Widget", "This is my widget");
        doReturn(Optional.empty()).when(service).findById(1L);

        // Execute the POST request
        mockMvc.perform(put("/rest/widget/{id}", 1l)
                .contentType(MediaType.APPLICATION_JSON)
                .header(HttpHeaders.IF_MATCH, 3)
                .content(asJsonString(widgetToPut)))

                // Validate the response code and content type
                .andExpect(status().isNotFound());
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



#### 避免 ApplicationContext 复用

Spring会针对每一个测试类生成一个ApplicationContext, 这样可以加快运行数据, 但是如果某些bean是有状态的, 那么多个测试方法可能会相互影响, 所有我们让每个测试方法执行完毕之后, 重新创建ApplicationContext

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





# Mockito

## 基础篇

### 入门

https://www.baeldung.com/mockito-annotations

#### 启用Mockito

在junit中启用Mockito, 有三种方式:

~~~java
// 方式1
@ExtendWith(MockitoExtension.class)
public class MockitoAnnotationUnitTest {
    ...
}

// 方式2
public class MockitoAnnotationUnitTest {
    @BeforeEach
	public void init() {
    	MockitoAnnotations.openMocks(this);
	}
}
// 方式3
public class MockitoAnnotationsInitWithMockitoJUnitRuleUnitTest {
    @Rule
    public MockitoRule initRule = MockitoJUnit.rule();

    ...
}
~~~



#### 创建mock对象

在Mockito中, 有三种方式来创建mock对象

~~~java
// 方式1
@Test
public void whenNotUseMockAnnotation_thenCorrect() {
    // 通过mock方法来创建一个mock对象
    List mockList = Mockito.mock(ArrayList.class);
    
    mockList.add("one");
    Mockito.verify(mockList).add("one");
    assertEquals(0, mockList.size());

    Mockito.when(mockList.size()).thenReturn(100);
    assertEquals(100, mockList.size());
}

// 方式2, 自动注入一个mock对象
@Mock
List<String> mockedList;
@Test
public void whenUseMockAnnotation_thenMockIsInjected() {
    mockedList.add("one");
    Mockito.verify(mockedList).add("one");
    assertEquals(0, mockedList.size());

    Mockito.when(mockedList.size()).thenReturn(100);
    assertEquals(100, mockedList.size());
}
~~~



#### 创建spy对象

创建spy对象

~~~java
// 方式1
@Test
public void whenNotUseSpyAnnotation_thenCorrect() {
    // 通过spy方法创建一个spy对象
    List<String> spyList = Mockito.spy(new ArrayList<String>());
    
    spyList.add("one");
    spyList.add("two");

    Mockito.verify(spyList).add("one");
    Mockito.verify(spyList).add("two");

    assertEquals(2, spyList.size());

    Mockito.doReturn(100).when(spyList).size();
    assertEquals(100, spyList.size());
}

// 方式2, 通过注解自动注入一个spy对象
@Spy
List<String> spiedList = new ArrayList<String>();
@Test
public void whenUseSpyAnnotation_thenSpyIsInjectedCorrectly() {
    // !!!注意, 此时的spiedList不是刚刚new出来的, Mockito会对刚刚new出来的list进行代理
    // 所以这里是代理对象
    
    spiedList.add("one");
    spiedList.add("two");

    Mockito.verify(spiedList).add("one");
    Mockito.verify(spiedList).add("two");

    assertEquals(2, spiedList.size());

    Mockito.doReturn(100).when(spiedList).size();
    assertEquals(100, spiedList.size());
}
~~~



#### spy和mock的区别

相同点:

1. 我们都可以api来定义spy和mock在接受到指定参数时的返回值/异常

不同点:

1. mock对象是Mockito通过反射创建一个对象, 然后进行代理

   spy对象是要我们手动创建一个对象, 然后Mockito对他进行代理

2. 在调用mock代理对象的时候, 默认情况下他不会执行真实的方法, 而是返回返回类型的默认值(0, false, null), 除非我们通过doReturn或when来定义行为

   在调用spy代理独享的时候, 默认情况下他会执行真实的方法, 除非通过doReturn来定义行为

3. mock可以通过doReturn或when来定义行为, 而spy只能通过doReturn来定义行为, 因为when有歧义

4. @spy使用的真实的对象实例，调用的都是真实的方法，所以通过这种方式进行测试，在进行sonar覆盖率统计时统计出来是有覆盖率；
   @mock出来的对象可能已经发生了变化，调用的方法都不是真实的，在进行sonar覆盖率统计时统计出来的Calculator类覆盖率为0.00%。

#### 创建参数捕获器

在某些场景中，不光要对方法的返回值和调用进行验证，同时需要验证一系列交互后所传入方法的参数。那么我们可以用参数捕获器来捕获传入方法的参数进行验证，看它是否符合我们的要求。 

有两种方式来创建参数捕获器

~~~java
// 方式1
@Test
public void whenNotUseCaptorAnnotation_thenCorrect() {
    List mockList = Mockito.mock(List.class);
    // 通过forClass来创建一个对应类型的参数捕获器
    ArgumentCaptor<String> arg = ArgumentCaptor.forClass(String.class);
}

// 方式2
@Mock
List mockedList;
@Captor 
ArgumentCaptor argCaptor;
~~~

参数捕获器的使用

~~~java
@Test  
public void argumentCaptorTest() {  
    List mock = mock(List.class);  
    List mock2 = mock(List.class);  
    mock.add("John");  
    mock2.add("Brian");  
    mock2.add("Jim");  
    
    // 创建对应参数类型的捕获器
    // 如果方法有多个参数都要捕获验证，那就需要创建多个ArgumentCaptor对象处理。
    ArgumentCaptor argument = ArgumentCaptor.forClass(String.class);  
    
    // 在verify方法的参数中调用argument.capture()方法来捕获输入的参数，之后argument变量中就保存了参数值
    verify(mock).add(argument.capture());  
    // 获取捕获的参数
    assertEquals("John", argument.getValue());  
    
    // 当某个对象进行了多次调用后，如mock2对象，这时调用argument.getValue()获取到的是最后一次调用的参数。如果要获取所有的参数值可以调用argument.getAllValues()，它将返回参数值的List。
    verify(mock2, times(2)).add(argument.capture());  
    assertEquals("Jim", argument.getValue());  
    assertArrayEquals(new Object[]{"Brian","Jim"},argument.getAllValues().toArray());  
}  
~~~





#### @InjectMocks

我们可以使用@InjectMocks注解来创建一个我们需要测试的对象

InjectMocks对象是一个真实的对象, 不会像mock和spy对象一样进行代理

同时Mockito还会尽可能的将其他mock和spy对象通过构造函数参数, setter的形式通过类型匹配注入到InjectMocks对象中

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







### BDD风格的测试方法

https://www.baeldung.com/bdd-mockito

BDD 术语由[Dan North 于 2006 年](https://dannorth.net/introducing-bdd/)首次创造。BDD 鼓励使用自然的、人类可读的语言编写测试，重点关注应用程序的行为。
它定义了一种结构清晰的测试编写方式，分为三个部分（Arrange、Act、Assert）：

- 给定一些前提条件（Arrange）

- 当一个动作发生时（Act）

- 然后验证输出（Assert）

Mockito 库提供了BDDMockito类，该类引入了 BDD 友好的 API。这个 API 允许我们采用更加 BDD 友好的方法，使用`Give()`安排测试并使用`then()`进行断言。



~~~java
// 传统api
when(phoneBookRepository.contains(momContactName))
  .thenReturn(false); // 使用when定义行为
phoneBookService.register(momContactName, momPhoneNumber); // 调用方法
verify(phoneBookRepository) // 使用verify进行验证
  .insert(momContactName, momPhoneNumber);

// BDD风格
given(phoneBookRepository.contains(momContactName))
  .willReturn(false); // 使用given定义行为
phoneBookService.register(momContactName, momPhoneNumber); // 调用方法
then(phoneBookRepository) // 使用then进行验证
  .should()
  .insert(momContactName, momPhoneNumber);
~~~



BDDMockito允许我们在定义对象的行为的时候, 返回固定的或动态的值。它还允许我们抛出异常

~~~java
given(phoneBookRepository.contains(momContactName))
  .willReturn(false); // 返回固定的值

given(phoneBookRepository.getPhoneNumberByContactName(momContactName))
  .will((InvocationOnMock invocation) -> // 返回动态计算的值
    invocation.getArgument(0).equals(momContactName) 
      ? momPhoneNumber 
      : null);

willThrow(new RuntimeException()) // 抛出异常
  .given(phoneBookRepository)
  .insert(any(String.class), eq(tooLongPhoneNumber));
~~~



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

   

### 参数匹配

https://www.baeldung.com/mockito-argument-matchers

在定义mock/spy对象的预期行为的时候

我们可以`参数匹配器`来定义方法接受到什么参数的时候, 他的预期行为是什么

~~~java
doReturn("Flower").when(flowerService).analyze("poppy"); // 匹配参数 poppy
when(flowerService.analyze(anyString())).thenReturn("Flower"); // 匹配任何字符串

// 如果mock方法有多个参数, 那么所有的参数都要使用参数匹配器
when(flowerService.isABigFlower("poppy", anyInt())).thenReturn(true); // 报错
when(flowerService.isABigFlower(eq("poppy"), anyInt())).thenReturn(true); // 正确写法
~~~

也可以用在verify中,  用来验证mock对象的调用的参数

~~~java
// 验证analyze被调用一次, 并且参数是y结尾, 或者poppy
verify(flowerService).analyze(or(eq("poppy"), endsWith("y")));
~~~



使用匹配器有两个需要注意的点:

1. 参数匹配器只能用在定义行为,  或者用在verify
2. 参数匹配器只能用来匹配参数, 不能用来匹配返回值



**自定义参数匹配器**

创建我们自己的\*匹配器使\*我们能够为给定场景选择最佳方法，并生成干净且可维护的高质量测试。

例如，我们可以有一个传递消息的*MessageController* 。它将接收*MessageDTO* ，并从中创建*Message*传递到*MessageService*中

~~~java
MessageDTO messageDTO = new MessageDTO();
messageDTO.setFrom("me");
messageDTO.setTo("you");
messageDTO.setText("Hello, you!");

messageController.createMessage(messageDTO);
// deliverMessage是messageService的方法, 不是Mockito的方法
verify(messageService, times(1)).deliverMessage(any(Message.class));
~~~

但是如果我们使用any的话, 那么Message和MessageDTO中的数据可能有所不同, 所以我们可以实现一个自定义的参数匹配器

~~~java
public class MessageMatcher implements ArgumentMatcher<Message> {

    private Message left;

    // constructors

    @Override
    public boolean matches(Message right) {
        // 我们传入的left是对Message的预期数据
        // 接受到的right是调用deliverMessage的时候真实接受到的Message
        // 然后判断我们预期接受到的Message和真实接受到的Message是否相同
        return left.getFrom().equals(right.getFrom()) &&
          left.getTo().equals(right.getTo()) &&
          left.getText().equals(right.getText()) &&
          right.getDate() != null &&
          right.getId() != null;
    }
}

MessageDTO messageDTO = new MessageDTO();
messageDTO.setFrom("me");
messageDTO.setTo("you");
messageDTO.setText("Hello, you!");

messageController.createMessage(messageDTO);

Message message = new Message();
message.setFrom("me");
message.setTo("you");
message.setText("Hello, you!");

// 使用argThat来设置自定义的参数匹配器
verify(messageService, times(1)).deliverMessage(argThat(new MessageMatcher(message)));
~~~



**参数捕获器(ArgumentCaptor)和参数匹配器(Argument Matcher)的区别**

我们知道, 参数捕获器可以用来收集mock对象被调用时的参数的值, 然后我们可以通过这个值与我们预期的值来判断

而参数匹配器也是对mock对象被调用时的参数进行匹配, 验证

那么他们有什么区别呢, 两者都可以完成验证



**通常来说, ArgumentCaptor更适合用来对调用时的参数进行验证, 看看是否和我们的预期一致**

**而ArgumentMatcher 更适合用来定义mock对象接受到特定参数的时候的行为**







## 高级篇

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



