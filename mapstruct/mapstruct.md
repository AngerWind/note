## 导入依赖

~~~xml
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <org.mapstruct.version>1.6.3</org.mapstruct.version>
        <lombok.version>1.18.38</lombok.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct</artifactId>
            <version>${org.mapstruct.version}</version>
        </dependency>

        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.11.4</version>
        </dependency>
        
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <!-- 在compiler插件中, 添加处理注解的processor -->
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>17</source> <!-- depending on your project -->
                    <target>17</target> <!-- depending on your project -->
                    <annotationProcessorPaths>
                        <!-- mapstruct的注解处理 -->
                        <path>
                            <groupId>org.mapstruct</groupId>
                            <artifactId>mapstruct-processor</artifactId>
                            <version>${org.mapstruct.version}</version>
                        </path>
                    </annotationProcessorPaths>
                </configuration>
            </plugin>
        </plugins>
    </build>
~~~

在执行mvn clean install 的时候, MapStruct插件会自动生成代码, 生成的代码位于`/target/generated-sources/annotations/` 目录下。


## 与lombok集成

~~~xml
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <org.mapstruct.version>1.6.3</org.mapstruct.version>
        <lombok.version>1.18.38</lombok.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct</artifactId>
            <version>${org.mapstruct.version}</version>
        </dependency>

        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.11.4</version>
        </dependency>

        <!-- mapstruct与lombok集成 -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>${lombok.version}</version>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok-mapstruct-binding</artifactId>
            <version>0.2.0</version>
        </dependency>

    </dependencies>

    <build>
        <plugins>
            <plugin>
                <!-- 在compiler插件中, 添加处理注解的processor -->
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>17</source> 
                    <target>17</target>
                    <annotationProcessorPaths>
                        <!-- mapstruct的注解处理 -->
                        <path>
                            <groupId>org.mapstruct</groupId>
                            <artifactId>mapstruct-processor</artifactId>
                            <version>${org.mapstruct.version}</version>
                        </path>

                        <!-- mapstruct对lombok的支持, 如果不加这一段代码, 会导致mapstruct找不到属性 -->
                        <!-- 如果你的项目没有使用到lombok, 那么可以不需要添加下面这段 -->
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                            <version>${lombok.version}</version>
                        </path>
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok-mapstruct-binding</artifactId>
                            <version>0.2.0</version>
                        </path>
                    </annotationProcessorPaths>
                </configuration>
            </plugin>
        </plugins>
    </build>
~~~



## IDEA插件

mapstruct官方提供了一个插件, 能够在编写mapstruct的时候, 自动提示

https://plugins.jetbrains.com/plugin/10036-mapstruct-support



## 默认映射

默认映射规则如下:

1. 字段名和类型相同, 则会进行映射
2. 8种基本类型和他们对应的包装类型之间
3. 8种基本类型(和他们的包装类型) 和 String 之间
4. 日期类型和 String 之间
5. 等等

~~~java
    @Data
    public static class SimpleSource {
        private String name;
        private String description;

    }

    @Data
    public static class SimpleDestination {
        private String name;
        private String description;
    }


    // 你可以通过一个interface来创建Mapper, 也可以通过抽象类来创建一个Mapper
    @Mapper
    public static interface SimpleSourceDestinationMapper {

        // 通过Mappers.getMapper()方法获取SimpleSourceDestinationMapper的实例。
        public static final SimpleSourceDestinationMapper INSTANCE = Mappers.getMapper(SimpleSourceDestinationMapper.class);

        SimpleDestination sourceToDestination(SimpleSource source);

        SimpleSource destinationToSource(SimpleDestination destination);
    }

	@Test
    public void givenSourceToDestination_whenMaps_thenCorrect() {
        // 创建源对象并赋值
        SimpleSource simpleSource = new SimpleSource();
        simpleSource.setName("SourceName");
        simpleSource.setDescription("SourceDescription");

        // 拷贝
        SimpleDestination destination = SimpleSourceDestinationMapper.INSTANCE.sourceToDestination(simpleSource);

        // 比较值是否一样
        assertEquals(simpleSource.getName(), destination.getName());
        assertEquals(simpleSource.getDescription(), destination.getDescription());
    }

    @Test
    public void givenDestinationToSource_whenMaps_thenCorrect() {
        SimpleDestination destination = new SimpleDestination();
        destination.setName("DestinationName");
        destination.setDescription("DestinationDescription");

        SimpleSource source = SimpleSourceDestinationMapper.INSTANCE.destinationToSource(destination);

        assertEquals(destination.getName(), source.getName());
        assertEquals(destination.getDescription(), source.getDescription());
    }
~~~



## 不同字段的映射

~~~java
	@Data
    public static class EmployeeDTO {
        private int employeeId;
        private String employeeName;
    }


    @Data
    public static class Employee {
        private int id;
        private String name;
    }


    @Mapper
    public interface EmployeeMapper {

        public static final EmployeeMapper INSTANCE = Mappers.getMapper(EmployeeMapper.class);

        @Mapping(target = "employeeId", source = "id")
        @Mapping(target = "employeeName", source = "name")
        EmployeeDTO employeeToEmployeeDTO(Employee entity);

        @Mapping(target = "id", source = "employeeId")
        @Mapping(target = "name", source = "employeeName")
        Employee employeeDTOtoEmployee(EmployeeDTO dto);
    }
~~~





## 嵌套对象的映射

~~~java
	@Data
    public static class EmployeeDTO {
        private int employeeId;
        private String employeeName;
        private DivisionDTO division;
    }


    @Data
    public static class Employee {
        private int id;
        private String name;
        private Division division;
    }
    @AllArgsConstructor
    @Data
    @NoArgsConstructor
    public static class Division {
        private int id;
        private String name;
    }

    @AllArgsConstructor
    @Data
    @NoArgsConstructor
    public static class DivisionDTO {
        private int id;
        private String name;
    }
@Mapper
    public interface EmployeeMapper {

        public static final EmployeeMapper INSTANCE = Mappers.getMapper(EmployeeMapper.class);

        // 默认情况下, 内部的division和divisionDto是没有办法转换的, 因为mapstruct不知道怎么转换
        // 但是我们在这个方法中定义了divisionToDivisionDTO和divisionDTOtoDivision
        // 所以mapstruct能够识别到这两个方法, 然后会指定调用这两个方法来转换division
        @Mapping(target = "employeeId", source = "id")
        @Mapping(target = "employeeName", source = "name")
        EmployeeDTO employeeToEmployeeDTO(Employee entity);

        @Mapping(target = "id", source = "employeeId")
        @Mapping(target = "name", source = "employeeName")
        Employee employeeDTOtoEmployee(EmployeeDTO dto);

        DivisionDTO divisionToDivisionDTO(Division entity);
        Division divisionDTOtoDivision(DivisionDTO dto);
    }
~~~

如果Division和DivisionDTO的转换是在别的mapper的话, 那么你还可以这样来使用

~~~java
	@Mapper
    public interface DivisionMapper {
        public static final DivisionMapper INSTANCE = Mappers.getMapper(DivisionMapper.class);
        
        DivisionDTO divisionToDivisionDTO(Division entity);
        Division divisionDTOtoDivision(DivisionDTO dto);
    }

    // 通过use属性, 那么EmployeeMapper在转换的时候, 就知道DivisionMapper怎么转换了
	@Mapper(use = {DivisionMapper.class})
    public interface EmployeeMapper {

        public static final EmployeeMapper INSTANCE = Mappers.getMapper(EmployeeMapper.class);

        @Mapping(target = "employeeId", source = "id")
        @Mapping(target = "employeeName", source = "name")
        EmployeeDTO employeeToEmployeeDTO(Employee entity);

        @Mapping(target = "id", source = "employeeId")
        @Mapping(target = "name", source = "employeeName")
        Employee employeeDTOtoEmployee(EmployeeDTO dto);
    }
~~~

## 集合类型的转换

### List

~~~java
	@Data
    public static class EmployeeDTO {
        private double salary;
    }


    @Data
    public static class Employee {
        private double salary;
    }

    @Mapper
    public interface EmployeeMapper {

        public static final EmployeeMapper INSTANCE = Mappers.getMapper(EmployeeMapper.class);

        EmployeeDTO employeeToEmployeeDTO(Employee entity);

        // mapstruct会自动的调用上面的方法, 通过for循环来进行转换, 不需要我们手写
        List<EmployeeDTO> employeeListToEmployeeDTOList(Collection<Employee> entity);

    }
~~~

如果Source无法直接映射为Target, 我们也可以使用default方法来映射

~~~java
public class Employee {
    private String firstName;
    private String lastName;
}
public class EmployeeFullNameDTO {
    private String fullName;
}
@Mapper
public interface EmployeeFullNameMapper {

    // 这个方法会自动使用下面的方法来处理映射
    List<EmployeeFullNameDTO> map(List<Employee> employees);

    // 手动自定义Employee到EmployeeDTO的映射
    default EmployeeFullNameDTO map(Employee employee) {
        EmployeeFullNameDTO employeeInfoDTO = new EmployeeFullNameDTO();
        employeeInfoDTO.setFullName(employee.getFirstName() + " " + employee.getLastName());

        return employeeInfoDTO;
    }
}
~~~



### Set和Map

映射Set和Map的方式, 与List类似

~~~java
public class Employee {
    private String firstName;
    private String lastName;
}
public class EmployeeDTO {
    private String firstName;
    private String lastName;
}

@Mapper
public interface EmployeeMapper {

    Map<String, EmployeeDTO> map(Map<String, Employee> idEmployeeMap);
    Set<EmployeeDTO> map(Set<Employee> employees);
}
~~~



### 集合的映射策略





## 与枚举的映射

### 枚举和枚举的映射

~~~java
public enum TrafficSignal {
    Off, Stop, Go
}
public enum RoadSign {
    Off, Halt, Move
}
@Mapper
public interface TrafficSignalMapper {
    TrafficSignalMapper INSTANCE = Mappers.getMapper(TrafficSignalMapper.class);

    @ValueMapping(target = "Off", source = "Off")
    @ValueMapping(target = "Go", source = "Move")
    @ValueMapping(target = "Stop", source = "Halt")
    TrafficSignal toTrafficSignal(RoadSign source);
}
@Test
void whenRoadSignIsMapped_thenGetTrafficSignal() {
    RoadSign source = RoadSign.Move;
    TrafficSignal target = TrafficSignalMapper.INSTANCE.toTrafficSignal(source);
    assertEquals(TrafficSignal.Go, target);
}
~~~

#### 处理未知的枚举类型

~~~java
public enum SimpleTrafficSignal { Off, On }
public enum TrafficSignal { Off, Stop, Go }

@Mapper
public interface TrafficSignalMapper {
    TrafficSignalMapper INSTANCE = Mappers.getMapper(TrafficSignalMapper.class);

    // 必须指定所有枚举的映射关系, 否则会报错
    @ValueMapping(target = "Off", source = "Off")
	@ValueMapping(target = "On", source = "Go")
	@ValueMapping(target = "Off", source = "Stop")
	SimpleTrafficSignal toSimpleTrafficSignal(TrafficSignal source); 
    
    /**
    	在source上, 你可以
    	    指定具体的枚举值
    	    使用MappingConstants.NULL表示source为null的情况
		    使用MappingConstants.ANY_REMAINING表示剩余的枚举值
		    使用MappingConstants.ANY_UNMAPPED表示其他未指定的情况
		    ANY_REMAINING和ANY_UNMAPPED的区别在于:
		        ANY_REMAINING只表示剩余的枚举值, 特别是在String->Enum的时候, 要使用ANY_UNMAPPED
		        ANY_UNMAPPED表示其他所有情况, 类似else
		    
		在target上, 你可以
		    指定具体的枚举值
		    使用MappingConstants.NULL表示target返回null
		    使用MappingConstants.THROW_EXCEPTION表示抛出一个异常
    */
    
    // 我们也可以使用ANY_REMAINING, 来让剩余的值, 映射到target的Off上
    @ValueMapping(target = "On", source = "Go")
	@ValueMapping(target = "Off", source = MappingConstants.ANY_REMAINING)
	SimpleTrafficSignal toSimpleTrafficSignalWithRemaining(TrafficSignal source);
    
    // 使用ANY_UNMAPPED也是一样的
    @ValueMapping(target = "On", source = "Go")
	@ValueMapping(target = "Off", source = MappingConstants.ANY_UNMAPPED)
	SimpleTrafficSignal toSimpleTrafficSignalWithUnmapped(TrafficSignal source);

    // 还可以将Null映射为Off, 将ANY_UNMAPPED映射为null
    @ValueMapping(target = "Off", source = MappingConstants.NULL)
	@ValueMapping(target = "On", source = "Go")
	@ValueMapping(target = MappingConstants.NULL, source = MappingConstants.ANY_UNMAPPED)
	SimpleTrafficSignal toSimpleTrafficSignalWithNullHandling(TrafficSignal source);

   
    @ValueMapping(target = "On", source = "Go")
	@ValueMapping(target = MappingConstants.THROW_EXCEPTION, source = MappingConstants.ANY_UNMAPPED) // source为any_unmapped, 引发异常
	@ValueMapping(target = MappingConstants.THROW_EXCEPTION, source = MappingConstants.NULL) // 如果source为null, 引发异常
	SimpleTrafficSignal toSimpleTrafficSignalWithExceptionHandling(TrafficSignal source);
}
~~~







### 字符串和枚举的映射

~~~java
public enum TrafficSignal {
    Off, Stop, Go
}
@Mapper
public interface TrafficSignalMapper {
    TrafficSignalMapper INSTANCE = Mappers.getMapper(TrafficSignalMapper.class);

    // 默认情况下, String转enum是通过valueOf来进行的
	TrafficSignal stringToTrafficSignal(String source);
    
    // 默认情况下, enum转string, 是通过enum的name()方法来进行的
    String trafficSignalToString(TrafficSignal source);
}
~~~

你也可以自定义字符串和枚举之间的转换关系

~~~java
	// 将字符串Off, Move, Halt转换为枚举Off, Go, Stop
    @ValueMapping(target = "Off", source = "Off")
	@ValueMapping(target = "Go", source = "Move")
	@ValueMapping(target = "Stop", source = "Halt")
	TrafficSignal stringToTrafficSignal(String source);

    @ValueMapping(target = "Off", source = "Off")
	@ValueMapping(target = "Move", source = "Go")
	@ValueMapping(target = "Halt", source = "Stop")
	String trafficSignalToString(TrafficSignal source);
~~~



#### 处理未知的情况

~~~java
public enum TrafficSignal {
    Off, Stop, Go
}

@Mapper
public interface TrafficSignalMapper {
    TrafficSignalMapper INSTANCE = Mappers.getMapper(TrafficSignalMapper.class);
    
        /**
    	在source上, 你可以
    	    指定具体的枚举值
    	    使用MappingConstants.NULL表示source为null的情况
		    使用MappingConstants.ANY_REMAINING表示剩余的枚举值
		    使用MappingConstants.ANY_UNMAPPED表示其他未指定的情况
		    ANY_REMAINING和ANY_UNMAPPED的区别在于:
		        ANY_REMAINING只表示剩余的枚举值, 特别是在String->Enum的时候, 要使用ANY_UNMAPPED
		        ANY_UNMAPPED表示其他所有情况, 类似else
		    
		在target上, 你可以
		    指定具体的枚举值
		    使用MappingConstants.NULL表示target返回null
		    使用MappingConstants.THROW_EXCEPTION表示抛出一个异常
    */
    
    @ValueMapping(target = "Off", source = "Off")
    @ValueMapping(target = MappingConstants.THROW_EXCEPTION, source = MappingConstants.NULL) // 如果字符串为null, 抛出异常
    @ValueMapping(target = "Go", source = MappingConstants.ANY_UNMAPPED) // 将其他的字符串转换为枚举Go
	TrafficSignal stringToTrafficSignal(String source);
    
    @ValueMapping(target = "Go", source = MappingConstants.NULL) // 如果枚举为null, 指定默认的字符串
    @ValueMapping(target = "hA", source = MappingConstants.ANY_REMAINNING) // 其余的枚举, 转换为hA
    String trafficSignalToString(TrafficSignal source);
}
~~~









### 枚举和数字的映射

枚举和数字之间的映射没有什么好的办法, 还是要手写

~~~java
public enum TrafficSignal {
    Off, Stop, Go
}

@Mapper
public interface TrafficSignalMapper {
    TrafficSignalMapper INSTANCE = Mappers.getMapper(TrafficSignalMapper.class);
     
	default TrafficSignal intToTrafficSignal(Integer source) {
        // 通过swatch或者其他的方式进行映射
    }
    default Integer intToTrafficSignal(TrafficSignal source) {
        // 通过swatch或者其他的方式进行映射
    }
}
~~~





### 按照特定格式映射

~~~java
public enum TrafficSignalSuffixed { Off_Value, Stop_Value, Go_Value }
public enum TrafficSignalPrefixed { Value_Off, Value_Stop, Value_Go }
public enum TrafficSignal { Off, Stop, Go }
public enum TrafficSignalLowercase { off, stop, go }
public enum TrafficSignalUppercase { OFF, STOP, GO }



@Mapper
public interface TrafficSignalMapper {
    TrafficSignalMapper INSTANCE = Mappers.getMapper(TrafficSignalMapper.class);

    // 添加后缀, 然后去target中查找
    @EnumMapping(nameTransformationStrategy = MappingConstants.SUFFIX_TRANSFORMATION, configuration = "_Value")
	TrafficSignalSuffixed applySuffix(TrafficSignal source);
	}

    // 添加前缀, 然后去target中查找
	@EnumMapping(nameTransformationStrategy = MappingConstants.PREFIX_TRANSFORMATION, configuration = "Value_")
	TrafficSignalPrefixed applyPrefix(TrafficSignal source);
    
    // 删除后缀, 然后去target中查找
	@EnumMapping(nameTransformationStrategy = MappingConstants.STRIP_SUFFIX_TRANSFORMATION, configuration = "_Value")
	TrafficSignal stripSuffix(TrafficSignalSuffixed source);

    // 删除前缀, 然后去target中查找
	@EnumMapping(nameTransformationStrategy = MappingConstants.STRIP_PREFIX_TRANSFORMATION, configuration = "Value_")
	TrafficSignal stripPrefix(TrafficSignalPrefixed source);
    
    // 将枚举转换为小写, 然后去target中查找
	@EnumMapping(nameTransformationStrategy = MappingConstants.CASE_TRANSFORMATION, configuration = "lower")
	TrafficSignalLowercase applyLowercase(TrafficSignal source);

    // 将枚举转换为大写, 然后去target中查找
	@EnumMapping(nameTransformationStrategy = MappingConstants.CASE_TRANSFORMATION, configuration = "upper")
	TrafficSignalUppercase applyUppercase(TrafficSignal source);

    // 将枚举转换为单词首字母大写, 然后去target中查找
    // 这种情况会将OFF_VALUE转换为Off_Value, 将GO_VALUE转换为Go_Value
	@EnumMapping(nameTransformationStrategy = MappingConstants.CASE_TRANSFORMATION, configuration = "captial")
	TrafficSignal lowercaseToCapital(TrafficSignalLowercase source);
}
~~~





## 与Spring集成

~~~java
@ComponentScan
@Configuration
public class _14_与spring集成 {

    @Data
    public static class Person {
        private String id;
        private String name;
    }

    @Data
    public static class PersonDTO {
        private String personId;
        private String personName;
    }


    // 指定了这个属性的话, 那么会自动注入一个PersonMapper的实现类到spring容器中, 然后我们就可以使用@Autowired来注入这个实例了
    // 他的原理就是在生成的类上面, 添加了一个@Component注解, 这样spring在扫描的时候就可以扫描到了
    @Mapper(componentModel = "spring")
    public interface PersonMapper {

        @Mapping(target = "personId", source = "id")
        @Mapping(target = "personName", source = "name")
        PersonDTO personToPersonDTO(Person person);


        @InheritInverseConfiguration(name = "personToPersonDTO")
        Person personDTOToPerson(PersonDTO personDTO);
    }

    @Test
    public void test() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(
                _14_与spring集成.class);
        PersonMapper personMapper = context.getBean(PersonMapper.class);

        assertNotNull(personMapper);

        Person person = new Person();
        person.setId("1");
        person.setName("tiger");

        PersonDTO personDTO = personMapper.personToPersonDTO(person);
        assertEquals("1", personDTO.getPersonId());
        assertEquals("tiger", personDTO.getPersonName());
    }
    
}
~~~







## @Mapping注解的属性

### target和source

这两个属性用于指定源字段和目标字段的对应关系

~~~java
	@Data
    public static class EmployeeDTO {
        private int employeeId;
        private String employeeName;
    }


    @Data
    public static class Employee {
        private int id;
        private String name;
    }


    @Mapper
    public interface EmployeeMapper {

        public static final EmployeeMapper INSTANCE = Mappers.getMapper(EmployeeMapper.class);

        @Mapping(target = "employeeId", source = "id")
        @Mapping(target = "employeeName", source = "name")
        EmployeeDTO employeeToEmployeeDTO(Employee entity);
    }
~~~



### ignore

是否忽略目标字段, 不要复制

~~~java
	@Data
    public static class Person {
        private String id;
        private String name;
    }

    @Data
    public static class PersonDTO {
        private String id;
        private String name;
    }

    @Mapper
    public interface PersonMapper {
        PersonMapper INSTANCE = Mappers.getMapper(PersonMapper.class);

        @Mapping(target = "name", ignore = true) // 忽略单个属性
        PersonDTO personToPersonDTO(Person person);
    }
~~~





### dateFormat

这个属性主要用在Date和String相互转换的时候, 用来指定字符串的格式

~~~java
	@Data
    public static class EmployeeDTO {
        private Date startDt;
    }
    @Data
    public static class Employee {
        private String employeeStartDt;
    }
    @Mapper
    public interface EmployeeMapper {

        public static final EmployeeMapper INSTANCE = Mappers.getMapper(EmployeeMapper.class);

        // 字符串转换为Date
        @Mapping(target="startDt", source = "employeeStartDt",
                dateFormat = "dd-MM-yyyy HH:mm:ss")
        EmployeeDTO employeeToEmployeeDTO(Employee entity);

        // Data转换为字符串
        @Mapping(target="employeeStartDt", source="startDt",
                dateFormat="dd-MM-yyyy HH:mm:ss")
        Employee employeeDTOtoEmployee(EmployeeDTO dto);
    }
~~~

他的原理类似如下代码

~~~java
Date date = new Date();
SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String formattedDate = sdf.format(date);
~~~



### numberFormat

这个属性主要用于Number和String进行转换的时候, 指定String的格式

~~~java
 	@Data
    public static class EmployeeDTO {
        private double salary;
    }
    @Data
    public static class Employee {
        private String salaryStr;
    }
    @Mapper
    public interface EmployeeMapper {

        public static final EmployeeMapper INSTANCE = Mappers.getMapper(EmployeeMapper.class);
        
        // 字符串转换为Date
        @Mapping(target = "salary", source = "salaryStr", numberFormat = "#.00")
        EmployeeDTO employeeToEmployeeDTO(Employee entity);

        // Data转换为字符串
        @Mapping(target = "salaryStr", source = "salary", numberFormat = "#.00")
        Employee employeeDTOtoEmployee(EmployeeDTO dto);
    }
~~~

他的原理是通过DecimalFormat来实现的

~~~java
double salary = 1234.567;
DecimalFormat df = new DecimalFormat("#.00");
String formattedSalary = df.format(salary);
~~~



### constant

这个属性的作用是给目标字段指定为一个常量

这个属性不能和`source, defaultValue, defaultExpression, expression`一起使用

~~~java
@Data
public class User {
    private String name;
    private int age;
}
@Data
public class UserDTO {
    private String name;
    private int age;
}
@Mapper
public interface UserMapper {

    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);

    // 将name和age指定为常量
    @Mapping(target = "name", constant = "zhangsan")
    @Mapping(target = "age", constant = "99")
    UserDTO toDTO(User user);
}
~~~



### expression

我们可以通过expression来计算目标字段的值

他不能与`source, defaultValue, defaultExpressio, qualifiedBy, qualifiedByName, constant`一起使用

~~~java
@Data
public class User {
    private String name;
}
@Data
public class UserDTO {
    private Integer nameLength;
}
@Mapper
public interface UserMapper {

    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);

    // 通过表达式来计算target的值
    
    // 你也可以通过全类名来调用其他的方法
    // @Mapping(target = "nameLength", expression="java(com.apache.StringUtils.length(user.name))")
    
    // 或者直接调用当前mapper中的方法
    // @Mapping(target = "nameLength", expression="java(length(user.getName()))")
    
    // 或者直接在expression中进行计算
    @Mapping(target = "nameLength", expression="java(user.getName() == null ? 0 : user.getName().length())")
    UserDTO toDTO(User user);
    
    default length(String name) {
        return name == null ? 0 : name.length();
    }
}
~~~



### defaultExpression

当源字段为null的时候, 会通过defaultExpression来计算目标表达式的值

他不能和`expression, defaultValue, constant`一起使用

~~~java
    @Data
    public static class Person {
        private String id;
    }

    @Data
    public static class PersonDTO {
        private String id;
    }

    @Mapper
    public interface PersonMapper {
        PersonMapper INSTANCE = Mappers.getMapper(PersonMapper.class);

        // 如果person中的id为null, 那么会自动调用defaultExpression, 来生成一个默认值
        @Mapping(target = "id", source = "id",
                defaultExpression = "java(java.util.UUID.randomUUID().toString())")
        PersonDTO personToPersonDTO(Person person);
    }
~~~

### defaultValue

当源字段为null的时候, 会将defaultValue作为默认值

他不能和`constant, expression, defaultExpression`一起使用

~~~java
    @Data
    public static class Person {
        private String id;
    }

    @Data
    public static class PersonDTO {
        private String id;
    }

    @Mapper
    public interface PersonMapper {
        PersonMapper INSTANCE = Mappers.getMapper(PersonMapper.class);

        @Mapping(target = "id", source = "id", defaultValue = "zhangsan")
        PersonDTO personToPersonDTO(Person person);
    }
~~~







### qualifiedByName

可以使用`qualifiedByName`来指定使用哪个方法来将原字段转换为目标字段

~~~java
@Data
public class User {
    private String name;
    private String birthDate; // 格式: "1990-01-01"
}
@Data
public class UserDTO {
    private String name;
    private int birthYear;
}
@Mapper
public interface UserMapperWithName {
    UserMapperWithName INSTANCE = Mappers.getMapper(UserMapperWithName.class);

    @Mapping(source = "birthDate", target = "birthYear", qualifiedByName = "extractYear")
    UserDTO toDTO(User user);

    // 定义工具方法, 必须添加@Named注解, mapstruct才会考虑使用
    @Named("extractYear")
    static int extractYear(String date) {
        return Integer.parseInt(date.split("-")[0]);
    }
}
~~~

你也可以将工具方法, 放在mapper的外面

~~~java
public class DateUtil {
    // 这里是不是static方法都无所谓
    @Named("extractYear")
    public static int extractYear(String date) {
        return Integer.parseInt(date.split("-")[0]);
    }
}

@Mapper(use = {DateUtil.class}) // 导入DateUtil的转换方法
public interface UserMapperWithName {
    UserMapperWithName INSTANCE = Mappers.getMapper(UserMapperWithName.class);

    // 可以在这里直接指定使用DateUtil中的extractYear方法进行转换
    @Mapping(source = "birthDate", target = "birthYear", qualifiedByName = "extractYear")
    UserDTO toDTO(User user);
}
~~~

### qualifiedBy

和上面类似, 也是可以指定自定义的转换方法

~~~java
@Data
public class User {
    private String name;
    private String birthDate; // 格式: "1990-01-01"
}
@Data
public class UserDTO {
    private String name;
    private int birthYear;
}
// 定义一个注解
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.CLASS)
@Qualifier
public @interface YearExtractor {}


@Mapper
public interface UserMapperWithName {
    UserMapperWithName INSTANCE = Mappers.getMapper(UserMapperWithName.class);

    // 通过注解找到对应的方法, 然后进行转化
    // 虽然麻烦了一点, 但是他是类型安全的, 有利于重构
    @Mapping(source = "birthDate", target = "birthYear", qualifiedBy = YearExtractor.class)
    UserDTO toDTO(User user);

    @YearExtractor // 标注注解, 就相当于通过注解标记了方法
    static int extractYearCustom(String date) {
        return Integer.parseInt(date.split("-")[0]);
    }
}
~~~

同样你可以把转换方法放到mapper外面

~~~java
public class DateUtil {
    // 是不是static方法无所谓
    @YearExtractor // 标注注解, 就相当于通过注解标记了方法
    public static int extractYearCustom(String date) {
        return Integer.parseInt(date.split("-")[0]);
    }
}
@Mapper(use = {DateUtil.class}) // 导入DateUtil的转换方法
public interface UserMapperWithName {
    UserMapperWithName INSTANCE = Mappers.getMapper(UserMapperWithName.class);

    // 通过注解找到对应的方法, 然后进行转化
    // 虽然麻烦了一点, 但是他是类型安全的, 有利于重构
    @Mapping(source = "birthDate", target = "birthYear", qualifiedBy = YearExtractor.class)
    UserDTO toDTO(User user);
}
~~~



### conditionExpression

只有conditionExpression返回true的时候, 才将源字段复制到目标字段上

~~~java
public class User {
    public String name;
    public Integer age;
    public String email;
}
public class UserDTO {
    public String name;
    public Integer age;
    public String email;
}
@Qualifier
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.CLASS)
public @interface PositiveCheck {}

public class ConditionUtils {

    // 必须添加@Condition注解和@Named注解, 才能在conditionQualifiedByName中使用
    @Condition
    @Named("hasValidEmail")
    public boolean hasValidEmail(String email) {
        return email != null && email.contains("@");
    }
    
    @Condition
	@PositiveCheck
	public boolean isPositive(Integer value) {
    	return value != null && value > 0;
	}
}

@Mapper(uses = ConditionUtils.class) // 导入ConditionUtils中的方法
public interface UserMapper {

    // 通过PositiveCheck查找到isPositive方法, 然后使用
    @Mapping(target = "age", conditionQualifiedBy = PositiveCheck.class)
    @Mapping(target = "email", conditionQualifiedByName = "hasValidEmail")
    @Mapping(target = "name", conditionExpression = "java(source.getName() != null && !source.getName().isEmpty())")
    UserDTO toDTO(User source);
}
~~~



### dependsOn

他的作用是字段在拷贝的时候, 应该先处理dependsOn中设置的字段

~~~java
@Mapping(target = "fullName", expression = "java(person.getFirstName() + \" \" + person.getLastName())", dependsOn = {"firstName", "lastName"})
@Mapping(target = "firstName", source = "first")
@Mapping(target = "lastName", source = "last")
PersonDto toDto(Person person); // 在处理fullName字段的时候, 应该先处理firstName和lastName字段
~~~



### nullValueCheckStrategy

控制在源字段到目标字段进行转换之前, 是否进行null的检测

~~~java
if (source.getName() != null) {
    target.setDisplayName(source.getName());
}
~~~



他的可选值有两个

- NullValueCheckStrategy.ALWAYS: 总是检查 null
- NullValueCheckStrategy.ON_IMPLICIT_CONVERSION: 仅在需要类型转换或表达式时检查 null, 默认值

他们两个的区别在于: 

- 如果设置为always, 那么对于对于String -> String这样的复制, 因为进行了null检查, 所以目标字段不会被赋值
- 如果设置为ON_IMPLICIT_CONVERSION,  那么只有类型转换, 或者使用表达式的时候, 才会检查null, 所以目标字段会被赋值

### nullValuePropertyMappingStrategy

如果源字段为null的时候, 或者目标字段没有对应的源字段时, 应该怎么处理目标字段

1. NullValuePropertyMappingStrategy.SET_TO_NULL : (默认), 设置为null
2. NullValuePropertyMappingStrategy.SET_TO_DEFAULT:  直接设置为默认值, 集合的话是空集合, 字符串的话是空字符串, 数组的话是空数组, boolean的话是false
3. NullValuePropertyMappingStrategy.IGNORE : 忽略, 不进行复制



## @Mapper注解的属性

### uses

他的作用有如下

1. 导入其他的mapper, 然后就可以指定转换嵌套对象了

   ~~~java
   	@Data
       public static class EmployeeDTO {
           private DivisionDTO division;
       }
       @Data
       public static class Employee {
           private Division division;
       }
       @AllArgsConstructor @Data @NoArgsConstructor
       public static class Division {
           private int id;
           private String name;
       }
       @AllArgsConstructor @Data @NoArgsConstructor
       public static class DivisionDTO {
           private int id;
           private String name;
       }	
   
   	@Mapper
       public interface DivisionMapper {
           public static final DivisionMapper INSTANCE = Mappers.getMapper(DivisionMapper.class);
           
           DivisionDTO divisionToDivisionDTO(Division entity);
           Division divisionDTOtoDivision(DivisionDTO dto);
       }
   
       // 通过use属性, 那么EmployeeMapper在转换的时候, 就知道DivisionMapper怎么转换了
   	@Mapper(use = {DivisionMapper.class})
       public interface EmployeeMapper {
   
           public static final EmployeeMapper INSTANCE = Mappers.getMapper(EmployeeMapper.class);
   
           EmployeeDTO employeeToEmployeeDTO(Employee entity);
           
           Employee employeeDTOtoEmployee(EmployeeDTO dto);
       }
   ~~~

2. 导入其他的工具类, 然后就可以在@Mapping的qualifiedBy或者conditionQualifiedByName中使用了

   ~~~java
   public class DateUtil {
       // 这里是不是static方法都无所谓
       @Named("extractYear")
       public static int extractYear(String date) {
           return Integer.parseInt(date.split("-")[0]);
       }
   }
   
   @Mapper(use = {DateUtil.class}) // 导入DateUtil的转换方法
   public interface UserMapperWithName {
       UserMapperWithName INSTANCE = Mappers.getMapper(UserMapperWithName.class);
   
       // 可以在这里直接指定使用DateUtil中的extractYear方法进行转换
       @Mapping(source = "birthDate", target = "birthYear", qualifiedByName = "extractYear")
       UserDTO toDTO(User user);
   }
   ~~~

   

### imports

他的作用是在生成的类中, imports指定的类, 然后我们就可以直接在@Mapping的expression和defaultExpression中直接使用了, 而不需要使用全类名

~~~java
package com.example.util;

public class DateUtil {
    public static String formatDate(java.time.LocalDate date) {
        return date.toString(); // 真实逻辑不重要
    }
}


@Mapper(imports = DateUtil.class)
public interface MyMapper {

    // 可以直接使用DateUtil, 而不需要使用全类名
    @Mapping(target = "formattedDate", expression = "java(DateUtil.formatDate(source.getDate()))")
    Target map(Source source);
}
~~~



### unmappedSourcePolicy

如果source中有的字段, target没有, 应该怎么处理

- ReportingPolicy.IGNORE:  忽略, 默认
- ReportingPolicy.WARN: 在编译的时候警告
- ReportingPolicy.ERROR: 编译失败



### unmappedTargetPolicy

如果target中有的字段, source没有, 应该怎么处理

- ReportingPolicy.IGNORE:  忽略
- ReportingPolicy.WARN: 在编译的时候警告, 默认
- ReportingPolicy.ERROR: 编译失败



### typeConversionPolicy

如果在自动类型转换的时候, 损失精度(Long -> Integet), 应该怎么处理

- ReportingPolicy.IGNORE:  忽略, 默认
- ReportingPolicy.WARN: 在编译的时候警告, 默认
- ReportingPolicy.ERROR: 编译失败



### componentModel

指定与ioc容器集成的时候, 应该使用怎么样的实现方式

1. `MappingConstants.ComponentModel.DEFAULT`:  不与ioc容器集成, 默认, 用户可以使用`Mappers.getMapper(Class)`来获取Mapper

2. `MappingConstants.ComponentModel.CDI`: 通过cdi的方式来集成, 一般是使用JakartaEE, Quakuas, Micronaut框架的时候使用

3. `MappingConstants.ComponentModel.SPRING`:  在生成的类上面添加@Component注解, 之后你就可以通过@Autowaired注解来注入了, 一般是和spring, springboot集成

4. `MappingConstants.ComponentModel.JSR303`: 生成的类上面添加@Named和@Singleton注解, 然后你就可以使用@Inject来注入了, 一般是支持JSR303的框架

   具体使用的是`javax.inject`还是`jakarta.inject`包中的注解, 取决于哪个在类路径上可用

   如果两个都可用, 那么优先使用`javax.inject`包

5. `MappingConstants.ComponentModel.JAKARTA`: 和上面一样, 但是只使用`jakartainject`包



### implementationName

指定实现类的名字, 默认是`<CLASS_NAME>Impl`

### implementationPackage

指定实现类的包名, 默认是抽象类或者接口的包名



### collectionMappingStrategy

https://mapstruct.org/documentation/stable/reference/html/#collection-mapping-strategies

在将字段从Collection转换为Collection的时候, 应该怎么转换

1. `CollectionMappingStrategy.ACCESSOR_ONLY`: 

   1. 如果有target字段有setter的话, 调用对应的setter方法, 类似`orderDto.setOrderLines(order.getOrderLines())`

   2. 如果没有setter的话, 但是有getter, 那么就调用getter来设置 (他会假设getter返回的是一个已经初始化的集合), 类似`orderDto.getOrderLines().addAll(order.getOrderLines())`

2. `CollectionMappingStrategy.SETTER_PREFERRED`

   1. 如果target字段有setter, 就调用setter, 类似`orderDto.setOrderLines(order.getOrderLines())`
   
   2. 如果没有setter, 但是有adder, 就调用adder, 类似`order.addOrderLine(orderLine())`
   
   3. 如果adder也没有, 但是有getter的话, 那么就使用getter, 类似`orderDto.getOrderLines().addAll(order.getOrderLines())`
   
3. `CollectionMappingStrategy.ADDER_PREFERRED`

   与上面相同, 但是优先使用add

4. `CollectionMappingStrategy.TARGET_IMMUTABLE`

   target上的集合是不可变的, 所以不会调用setter和getter, adder来设置集合, 而是创建一个新的元素,和新的集合, 然后将新的集合设置到新的元素上
   
   如果没有setter会报错



### nullValueMappingStrategy

控制转换的时候, 如果source为null怎么办

~~~java
@Mapper(nullValueMappingStrategy = NullValueMappingStrategy.RETURN_NULL)
public interface MyMapper {
    String mapList(String source); 
}
~~~



1. NullValueMappingStrategy.RETURN_NULL:  直接返回null
2. NullValueMappingStrategy.RETURN_DEFAULT: 
   - 如果返回值是集合, 返回一个空的集合
   - 如果返回值是map, 返回一个空的map
   - 如果返回值是bean, 创建一个全新的bean, 然后调用expression和constant来计算属性并传入null



### nullValueIterableMappingStrategy

当进行Collection -> Collection转换的时候, 如果source为null, 应该怎么办

~~~java
@Mapper(nullValueIterableMappingStrategy = NullValueMappingStrategy.RETURN_DEFAULT)
public interface MyMapper {
    List<String> mapList(List<String> source);  
}
~~~

默认值：`RETURN_NULL`

可选值：

- `RETURN_NULL` → 映射方法接收到 `null` 集合，返回 `null`
- `RETURN_DEFAULT` → 返回空集合（如 `new ArrayList<>()`）

### nullValueMapMappingStrategy

在map -> map转换的时候, 如果传入的map为null应该怎么办

~~~java
public interface MyMapper {
    Map<String> mapList(Map<String> source);  
}
~~~

- 默认值：`RETURN_NULL`

  可选值：

  - `RETURN_NULL` → 映射方法接收到 `null` 集合，返回 `null`
  - `RETURN_DEFAULT` → 返回空map



### nullValuePropertyMappingStrategy

当 bean 属性是 `null` 时该怎么处理

- 默认值：`SET_TO_NULL`
- 可选值：
  - `SET_TO_NULL`: 把目标属性设为 `null`
  - `IGNORE`: 不修改目标属性
  - `SET_TO_DEFAULT`: 设为默认值（如数字 0，布尔 false）



###  nullValueCheckStrategy

是否为 `null` 值添加检查, 如果为null就不进行属性的复制

可选值：

- `ALWAYS`：无论是否转换都添加 null 判断
- `ON_IMPLICIT_CONVERSION` 只在类型不同需要类型转换的时候, 或者通过expression进行表达式计算的时候, 才进行检查







### injectionStrategy

在于ioc容器集成的时候, 使用什么样的方式注入Mapper

~~~xml
InjectionStrategy.FIELD        // 默认：字段注入（@Autowired Mapper mapper;）
InjectionStrategy.CONSTRUCTOR // 构造函数注入（推荐）
InjectionStrategy.METHOD      // setter 方法注入（@Autowired setMapper()）
~~~





### disableSubMappingMethodsGeneration

控制是否**禁止自动生成嵌套对象的映射方法**。默认为false

~~~java
class Person {
    private Address address;
}

class Address {
    private String street;
}
class PersonDTO {
    private AddressDTO address;
}

class AddressDTO {
    private String street;
}
@Mapper
public interface MyMapper {
    // 默认MapStruct 会自动生成 Address → AddressDTO 的子映射方法。
    PersonDTO toDto(Person person);
}
~~~



### unexpectedValueMappingException

用于枚举到枚举映射的时候, 碰到了未知的值应该抛出什么异常, 默认是IllegalArgumentException

~~~java
public enum SourceEnum {
    A, B, C
}

public enum TargetEnum {
    A, B
}
@Mapper
public interface MyMapper {
    @ValueMapping(source = "A", target = "A")
    @ValueMapping(source = "B", target = "B")
    TargetEnum map(SourceEnum source);
}
~~~

生成的伪代码如下

~~~java
switch(source) {
    case A: return TargetEnum.A;
    case B: return TargetEnum.B;
    default: throw new MyEnumMappingException("Unexpected enum constant: " + source);
}
~~~

你也可以指定为其他的异常

~~~java
@Mapper(unexpectedValueMappingException = MyEnumMappingException.class)
public interface MyMapper {
    TargetEnum map(SourceEnum source);
}
switch(source) {
    case A: return TargetEnum.A;
    case B: return TargetEnum.B;
        // MyEnumMappingException必须接受一个String作为参数
        // 如果MyEnumMappingException是checked exception, 那么你还要在map方法上声明这个异常
    default: throw new MyEnumMappingException("Unexpected enum constant: " + source);
}
~~~



### subclassExhaustiveStrategy

用于控制在使用 `@SubclassMapping` 时，**是否必须为所有子类都提供明确的映射定义**。

~~~java
public sealed interface Animal permits Dog, Cat {}

public final class Dog implements Animal {
    public String bark;
}

public final class Cat implements Animal {
    public String meow;
}


@Mapper(subclassExhaustiveStrategy = SubclassExhaustiveStrategy.RUNTIME_EXCEPTION)
public interface AnimalMapper {
    // 如果source是Dog, 那么就转换为DogDto
    // 如果是其他未知的子类,比如Cat, 那么就根据subclassExhaustiveStrategy的策略来
    // 1. COMPILE_ERROR: 编译期报错
    // 2. RUNTIME_EXCEPTION: 在运行期如果真的碰到了Cat的子类, 那么报错
    @SubclassMapping(source = Dog.class, target = DogDto.class)
    AnimalDto map(Animal source);
}
~~~



### mappingControl

不知道有什么用



### mappingConfig

@Mapper方法中有非常多的属性, 如果你又有很多个@Mapper, 那么你就要重复写非常多次, 所以我们可以将@Mapper的配置抽取出一套, 多个Mapper进行共用

~~~java
// 能够在@Mapper中设置的属性, 也可以在@MapperConfig中设置
@MapperConfig(uses = {xxx.class}, imports = {xxx.class})
public interface CommonMapperConfig{}

// 复用@MapperConfig中的配置
// @Mapper和@MapperConfig中指定的uses会合并
// 在@Mapper中设置的其他属性, 会优先于@MapperConfig中的属性
@Mapper(config = CommonMapperConfig.class, uses = {xxx.class}, )
public interface Mapper1{
    
}
~~~



### mappingInheritanceStrategy

不着调有什么用





## @BeforeMapping和@AfterMapping注解

这两个注解主要是能够在转换前和转化后, 做一些自定义的操作

~~~java
@Data
    public static class Car {
        private int id;
        private String name;
    }


    public static class BioDieselCar extends Car {
    }

    public static class ElectricCar extends Car {
    }

    @Data
    public static class CarDTO {
        private int id;
        private String name;
        private FuelType fuelType;
    }

    public enum FuelType {
        ELECTRIC, BIO_DIESEL
    }


    @Mapper
    public static abstract class CarsMapper {

        // 这个方法会在将Car转换为CarDTO之前被调用
        // @MappingTarget 表示这个参数用来表示从谁转换到谁
        @BeforeMapping
        protected void enrichDTOWithFuelType(Car car, @MappingTarget CarDTO carDto) {
            // 转换前的自定义操作
            if (car instanceof ElectricCar) {
                carDto.setFuelType(FuelType.ELECTRIC);
            }
            if (car instanceof BioDieselCar) {
                carDto.setFuelType(FuelType.BIO_DIESEL);
            }
        }

        // 这个方法会在Car转换为CarDTO之后被调用
        // 可以在这里做一些自定义的处理
        @AfterMapping
        protected void convertNameToUpperCase(Car car, @MappingTarget CarDTO carDto) {
            carDto.setName(carDto.getName().toUpperCase());
        }

        public abstract CarDTO toCarDto(Car car);
    }
~~~









## 其他几个注解

### @BeanMapping

他主要是用在Bean -> Bean的映射上

~~~java
// 忽略所有的属性, 然后需要通过@Mapping来指定需要转换的属性
@BeanMapping(ignoreByDefault = true) 
@Mapping(target = "id", source = "id")
PersonDTO personToPersonDTO(Person person);
~~~



他有如下几个属性

1. Class<?> resultType()
2. Class<? extends Annotation>[] qualifiedBy()
3. String[] qualifiedByName()
4. NullValueMappingStrategy nullValueMappingStrategy()
5. NullValuePropertyMappingStrategy nullValuePropertyMappingStrategy()
6. NullValueCheckStrategy nullValueCheckStrategy()
7. SubclassExhaustiveStrategy subclassExhaustiveStrategy()
8. boolean ignoreByDefault()
9. String[] ignoreUnmappedSourceProperties()
10. ReportingPolicy unmappedSourcePolicy()
11. ReportingPolicy unmappedTargetPolicy()
12. Builder builder()
13. Class<? extends Annotation> mappingControl()

上面大部分的属性都可以在@Mapper这个注解中找到,  但是@Mapper这个属性是用在接口上的, 而@BeanMapping是用在方法级别的



### @ValueMapping

他通常用在Enum <--> Enum 和 String <--> Enum 的映射上

~~~java
public enum TrafficSignal {
    Off, Stop, Go
}
public enum RoadSign {
    Off, Halt, Move
}
@Mapper
public interface TrafficSignalMapper {
    TrafficSignalMapper INSTANCE = Mappers.getMapper(TrafficSignalMapper.class);

    /**
    	在source上, 你可以
    	    指定具体的枚举值
    	    使用MappingConstants.NULL表示source为null的情况
		    使用MappingConstants.ANY_REMAINING表示剩余的枚举值
		    使用MappingConstants.ANY_UNMAPPED表示其他未指定的情况
		    
		在target上, 你可以
		    指定具体的枚举值
		    使用MappingConstants.NULL表示target返回null
		    使用MappingConstants.THROW_EXCEPTION表示抛出一个异常
    */
    @ValueMapping(target = "Off", source = "Off")
    @ValueMapping(target = "Go", source = "Move")
    @ValueMapping(target = "Stop", source = "Halt")
    TrafficSignal toTrafficSignal(RoadSign source);
}
~~~



### @EnumMapping

主要用在枚举到枚举之间的转换,  用于指定特定的转换规则

~~~java
public enum TrafficSignalSuffixed { Off_Value, Stop_Value, Go_Value }
public enum TrafficSignal { Off, Stop, Go }


@Mapper
public interface TrafficSignalMapper {
    TrafficSignalMapper INSTANCE = Mappers.getMapper(TrafficSignalMapper.class);

    // 添加后缀, 然后去target中查找
    @EnumMapping(nameTransformationStrategy = MappingConstants.SUFFIX_TRANSFORMATION, configuration = "_Value")
	TrafficSignalSuffixed applySuffix(TrafficSignal source);
	}
}
~~~







### @MapMapping

通常用于Map到Map的映射上

~~~java
@MapMapping(keyTargetType = String.class, valueTargetType = Target.class)
Map<String, Target> map(Map<Integer, Source> sourceMap);
~~~

他有如下几个属性:

1. String keyDateFormat() default "";

   如果两个key是Date和String之间的转换, 那么指定String 的 format

2. String valueDateFormat() default "";

   如果两个Value是Date和String之间的转换, 那么指定String 的 format

3. String valueNumberFormat() default "";

   如果两个Value是Number和String之间的转换, 那么指定String的format

4. Class<? extends Annotation>[] keyQualifiedBy() default { };

   指定key 的转换函数

5. String[] keyQualifiedByName() default { };

   指定key的转换函数

6. Class<? extends Annotation>[] valueQualifiedBy() default { };

   指定value的转换函数

7. String[] valueQualifiedByName() default { };

   指定value的转换函数

8. Class<?> keyTargetType() default void.class;

   指定target的key类型

9. Class<?> valueTargetType() default void.class;

   指定target的value类型

10. NullValueMappingStrategy nullValueMappingStrategy() default NullValueMappingStrategy.RETURN_NULL;

    如果source为null, 怎么办

    1. NullValueMappingStrategy.RETURN_NULL:  直接返回null
    2. NullValueMappingStrategy.RETURN_DEFAULT: 返回一个空map

11. Class<? extends Annotation> keyMappingControl() default MappingControl.class;

    设置key的mappingControl

12. Class<? extends Annotation> valueMappingControl() default MappingControl.class;

    设置value的mappingControl



### @IterableMapping

主要用于Collection和Collection之间的映射

~~~java
@IterableMapping(elementTargetType = Target.class)
List<Target> map(List<Source> sources);
~~~

他主要的属性有如下:

1. String dateFormat() default "";

   如果Element是Date和String的转换, 指定String的format

2. String numberFormat() default "";

   如果Element是String和Number的转换, 指定String的format

3. Class<? extends Annotation>[] qualifiedBy() default { };

   指定Element的转换函数

4. String[] qualifiedByName() default { };

   指定Element的转换函数

5. Class<?> elementTargetType() default void.class;

   指定target的Element的类型

6. NullValueMappingStrategy nullValueMappingStrategy() default NullValueMappingStrategy.RETURN_NULL;

   如果source为null, 怎么办

   1. NullValueMappingStrategy.RETURN_NULL:  直接返回null
   2. NullValueMappingStrategy.RETURN_DEFAULT: 返回一个空的集合

7. Class<? extends Annotation> elementMappingControl() default MappingControl.class;

   指定mappingControl





### @SubclassMapping

主要用于子类之间的映射

~~~java
public abstract class Animal {
    private String name;
}

public class Dog extends Animal {
    private String breed;
}

public class Cat extends Animal {
    private boolean indoor;
}

public abstract class AnimalDTO {
    private String name;
}

public class DogDTO extends AnimalDTO {
    private String breed;
}

public class CatDTO extends AnimalDTO {
    private boolean indoor;
}

@Mapper
public interface AnimalMapper {

    // 必须指定所有子类的映射关系
    // 如果传入的是Dog, 那么返回DogDTO, 如果传入的是Cat, 那么返回CatDTO
    @SubclassMapping(source = Dog.class, target = DogDTO.class)
    @SubclassMapping(source = Cat.class, target = CatDTO.class)
    AnimalDTO map(Animal animal);

    DogDTO mapDog(Dog dog);

    CatDTO mapCat(Cat cat);
}
~~~

相关联的属性是@Mapper的subclassExhaustiveStrategy







## 自定义转换逻辑的几种方法

1. 通过@Mapping的expression和@Mapper的imports属性结合来调用其他类的方法进行转换

2. 通过@Mapping的expression调用当前Mapper的其他default方法进行计算

3. 通过@Mapping的expression通过表达式直接计算

4. 通过qualifiedByName和qualifiedBy属性来指定转换的方法

5. 通过@BeforeMapping和@AfterMapping在转换前后做一些自定义处理

6. 通过@Mapper(use = {XXXMapper.class}) 来自定义一些通用的转换规则

7. 通过装饰器来实现

8. 通过default方法自己手写映射的逻辑

   ~~~java
   @Mapper
   public interface CarMapper {
   
       default PersonDto personToPersonDto(Person person) {
           //hand-written mapping logic
       }
   }
   ~~~

   





## 重用映射关系



### 继承与反向继承映射关系

~~~java
@Mapper
public interface CarMapper {

    @Mapping(target = "numberOfSeats", source = "seatCount")
    Car carDtoToCar(CarDto car);

    // 因为source和target的类型相同, 所有可以继承上面的映射关系
    @InheritConfiguration( name = "carDtoToCar" )
    @Mapping(target = "numberOfSeats", ignore = true) // 还可以通过@Mapping和@BeanMapping来覆盖继承的映射关系
    void carDtoIntoCar(CarDto carDto, @MappingTarget Car car);
    
    // 你还可以反向继承映射关系
    @InheritInverseConfiguration( name = "carDtoToCar" )
    @Mapping(target = "numberOfSeats", ignore = true) // // 还可以通过@Mapping和@BeanMapping来覆盖继承的映射关系
    Car carDtoToCar(CarDto carDto);
}
~~~



### @MapperConfig

@MapperConfig的属性和@Mapper的属性是一样的,  所以你可以通过@MapperConfig来定义一套公共的配置, 然后让@Mapper注解复用这个配置

~~~java
// 能够在@Mapper中设置的属性, 也可以在@MapperConfig中设置
@MapperConfig(uses = {xxx.class}, imports = {xxx.class})
public interface CommonMapperConfig{}

// 复用@MapperConfig中的配置
// @Mapper和@MapperConfig中指定的uses会合并
// 在@Mapper中设置的其他属性, 会优先于@MapperConfig中的属性
@Mapper(config = CommonMapperConfig.class, uses = {xxx.class}, )
public interface Mapper1{
    
}
~~~



## 装饰器

装饰器主要用于自定义映射逻辑

~~~java
@Mapper
@DecoratedWith(PersonMapperDecorator.class) // 通过PersonMapperDecorator来对PersonMapper进行装饰
public interface PersonMapper {

    PersonMapper INSTANCE = Mappers.getMapper( PersonMapper.class );

    // 调用这个方法, 会调用PersonMapperDecorator的personToPersonDto方法
    PersonDto personToPersonDto(Person person);

    AddressDto addressToAddressDto(Address address);
}

// 装饰器必须是对应Mapper的子类, 你可以将其设置为抽象类
public abstract class PersonMapperDecorator implements PersonMapper {

    private final PersonMapper delegate;

    public PersonMapperDecorator(PersonMapper delegate) {
        this.delegate = delegate;
    }

    // 继承personToPersonDto方法, 表示要对他进行装饰
    @Override
    public PersonDto personToPersonDto(Person person) {
        // 调用原生mapper方法进行转换
        PersonDto dto = delegate.personToPersonDto( person );
        // 做自定义的逻辑
        dto.setFullName( person.getFirstName() + " " + person.getLastName() );
        return dto;
    }
}

@Test
public void test() {
    PersonMapper.INSTANCE.personToPersonDto(new Person())
}
~~~



### 装饰器与Spring

如果你的mapstruct与spring进行了集成, 那么在使用装饰器的时候, 应该这样使用

~~~java
@Mapper(componentModel = "spring")
@DecoratedWith(PersonMapperDecorator.class) // 通过PersonMapperDecorator来对PersonMapper进行装饰
public interface PersonMapper {

    PersonMapper INSTANCE = Mappers.getMapper( PersonMapper.class );

    // 调用这个方法, 会调用PersonMapperDecorator的personToPersonDto方法
    PersonDto personToPersonDto(Person person);

    AddressDto addressToAddressDto(Address address);
}
public abstract class PersonMapperDecorator implements PersonMapper {

     @Autowired
     @Qualifier("delegate")
     private PersonMapper delegate;

     @Override
     public PersonDto personToPersonDto(Person person) {
         PersonDto dto = delegate.personToPersonDto( person );
         dto.setName( person.getFirstName() + " " + person.getLastName() );

         return dto;
     }
 }

// 在其他的Service中
@Autowired
private PersonMapper personMapper;
~~~







## 其他

### 组合映射

~~~java
@Retention(RetentionPolicy.CLASS)
@Mapping(target = "id", ignore = true)
@Mapping(target = "creationDate", expression = "java(new java.util.Date())")
@Mapping(target = "name", source = "groupName")
public @interface ToEntity { }

@Mapper
public interface StorageMapper {

    StorageMapper INSTANCE = Mappers.getMapper( StorageMapper.class );

    @ToEntity // 复用ToEntity中的@Mapping注解
    @Mapping( target = "weightLimit", source = "maxWeight")
    ShelveEntity map(ShelveDto source);

    @ToEntity
    @Mapping( target = "label", source = "designation")
    BoxEntity map(BoxDto source);
}
~~~

### 多个Source进行转换

~~~java
class DeliveryAddress {
    private String forename;
    private String surname;
    private String street;
    private String postalcode;
    private String county;
}
class Address {
    private String street;
    private String postalcode;
    private String county;
}
class Customer {
    private String firstName;
    private String lastName;
}

@Mapper
interface DeliveryAddressMapper {

    // 需要Customer和Address才能转换出一个DeliveryAddress
    // 只有Customer和Address都为null的时候, 才返回null
    // 如果其中一个不为null, 那么就会实例化DeliveryAddress并进行复制
    @Mapping(source = "customer.firstName", target = "forename")
    @Mapping(source = "customer.lastName", target = "surname")
    @Mapping(source = "address.street", target = "street")
    @Mapping(source = "address.postalcode", target = "postalcode")
    @Mapping(source = "address.county", target = "county")
    DeliveryAddress from(Customer customer, Address address);
}
~~~



### 将嵌套的bean属性映射到target上

~~~java
 @Mapper
 public interface CustomerMapper {

     @Mapping( target = "name", source = "record.name" )
     @Mapping( target = ".", source = "record" ) // 将customerDto.record中所有的属性复制到Customer上
     @Mapping( target = ".", source = "account" ) // 同上
     // 如果customerDto.record和customerDto.account有同名的属性, 那么要通过@Mapping明确指定使用哪个属性
     Customer customerDtoToCustomer(CustomerDto customerDto);
 }
~~~

### 更新属性

~~~java
class Address {
    private String street;
    private String postalcode;
    private String county;
}
class AddressDTO {
    private String street;
    private String postalcode;
    private String county;
}
@Mapper
interface AddressMapper {

    // 将address上的属性更新到addressDto中
    // 返回值可以是void, 或者target, 都可以
    AddressDTO from(@MappingTarget AddressDTO addressDto, Address address);
}
~~~



### 使用Builder来创建target

默认情况下, mapstruct会查找target中是否有Builder, 并使用Builder方法来创建并赋值target

mapstruct假设target有

1. 一个无参的public static的方法, 并且他返回一个Builder, 例如， `Person` 有一个返回 `PersonBuilder` 公共静态方法。
2. Builder有一个无参数的公共方法（build 方法），它返回正在构建的类型。在我们的示例中， `PersonBuilder` 有一个返回 `Person` 方法。

你也可以通过@Builder这个注解来告诉mapstruct, build方法的方法名, 创建builder的方法的方法名

**你直接使用lombok来创建Builder方法就好了, mapstruct支持lombok生成的Builder方法**



### 使用构造函数创建target

如果没有Builder, 那么mapstruct会尝试使用构造函数来创建target

他会

1. 首先查找带有@Default注解的构造函数, 然后使用他
2. 否则, 如果只有一个public的构造函数, 那么就直接使用他
3. 否则, 如果有一个无参的构造函数, 那么使用他
4. 如果查找到多个符合条件的构造函数, 会报错

~~~java
public class Truck {

    public Truck() { }

    // 指定使用这个构造函数
    @Default
    public Truck(String make, String color) { }
}
~~~



### 将map映射为bean

~~~java
public class Customer {
    private Long id;
    private String name;
}

@Mapper
public interface CustomerMapper {

    // 从map中获取customerName, 然后设置到Customer的name属性中
    @Mapping(target = "name", source = "customerName")
    Customer toCustomer(Map<String, String> map);

}
~~~



### 为实现类添加注解

~~~java
@Mapper
@AnnotateWith(
  value = Converter.class,
  elements = @AnnotateWith.Element( name = "generateBulkLoader", booleans = true )
)
public interface MyConverter {
    @AnnotateWith( Converter.class )
    DomainObject map( DtoObject dto );
}
~~~

生成的代码类似

~~~java
@Converter( generateBulkLoader = true )
public class MyConverterImpl implements MyConverter {
    @Converter
    public DomainObject map( DtoObject dto ) {
        // default mapping behaviour
    }
}
~~~

