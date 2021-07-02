### Jackson Serialization And Deserialization Annotations

#### @JsonDeserialize 和 @JsonSerialize

> - @JsonDeserialize反序列化时使用，标注在setter或者字段上，需要使用 using 属性指定处理参数的类，该类需要继承 JsonDeserializer 类，并重写 deserialize()。
>
> - @JsonSerialize序列化时使用，标注在getter或者字段上， 需要使用 using 属性指定处理参数的类，该类需要继承 JsonSerializer 类，并重写 serialize()。

~~~~json
{
    "name": "zhangsan",
    "address": {
        "street": "xxx",
        "city": "aaa"
    }
}
~~~~

比如上面的json，对应java类

~~~java
public class Student{
    String name;
    String address; // 因为某种原因address的类型为String
}
~~~

将上面的json数据将无法反序列化为Student.class，因为json中address是Object类型而java中是String，并且就算是成功反序列化， 再次序列化也会得到如下的结果，因为address序列化时被自动加上了引号。

~~~json
{
    "name": "zhangsan",
    "address": "{
        "street": "xxx",
        "city": "aaa"
    }"
}
~~~

解决上面的问题使用如下方法：

~~~java
@Data
public class Student {
    String name;

    @JsonSerialize(using = JsonDataSerializer.class)
    @JsonDeserialize(using = JsonDataDeserializer.class)
    String address;

    public static class JsonDataSerializer extends JsonSerializer<String> {
        @Override
        public void serialize(String value, JsonGenerator gen, SerializerProvider provider) throws IOException {
            gen.writeRawValue(value);
        }
    }

    public static class JsonDataDeserializer extends JsonDeserializer<String> {
        @Override
        public String deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
            JsonNode node = p.getCodec().readTree(p);
            return node.toString();
        }
    }

    public static void main(String[] args) throws JsonProcessingException {
        String student = "{\n" +
                "    \"name\": \"zhangsan\",\n" +
                "    \"address\": {\n" +
                "        \"street\": \"xxx\",\n" +
                "        \"city\": \"aaa\"\n" +
                "    }\n" +
                "}";
        ObjectMapper objectMapper = new ObjectMapper();
        Student student1 = objectMapper.readValue(student, Student.class);
        String s = objectMapper.writeValueAsString(student1);
        System.out.println(s);
    }
}
~~~



#### jackson 忽略null值

使用Jackson进行对象序列化时，默认会输出值为null的字段。

很多时候，序列化null字段是没有意义的。如果想忽略null字段，一起来看看Jackson提供的几种方法。

> 默认

```java
@Data
public class Animal {
    private String name;
    private int sex;
    private Integer weight;
}
```

当weight为null时默认输出

~~~json
{"name":"sam","sex":1,"weight":null}
~~~

> 全局忽略

~~~java
@Test
public void nonNullForGlobal() throws JsonProcessingException {
    // 指定序列化时的包含规则，NON_NULL表示序列化时忽略值为null的字段
    // 使用该ObjectMapper序列化时有效
    ObjectMapper mapper = new ObjectMapper();
    mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
   
}
~~~

> 类范围

~~~java
@JsonInclude(JsonInclude.Include.NON_NULL) // 序列化时忽略所有值为null的字段
public class Animal2NonNull {
    private String name;
    private int sex;
    private Integer weight;
}
~~~

> 指定字段为null时忽略

~~~java
public class Animal2NonNull {
    private String name;
    private int sex;
    @JsonInclude(JsonInclude.Include.NON_NULL) // 如果字段值为null，则不进行序列化
    private Integer weight;
}
~~~



#### 枚举序列化与反序列化



## Jackson 常用注解

#### @JsonAnySetter和@JsonAnyGetter

@JsonAnyGetter用于序列化时，将Map属性中的kv对作为json的标准属性，即map中的key将作为json的key而不再被包装在map中。

@JsonAnySetter用于反序列化时，当json串有识别不了的属性时，可以使用一个map将其全部的接收下来。

- 标注在Map类型的字段上
- 或者非静态的两个类型的参数上，第一个参数为key，第二个参数为value

> 使用场景

当我们用一个Bean去接收参数的时候，就不用怕不同的接口参数不同，而去写好几个不同的Bean了，只需要一个Bean然后里面存放共有的属性和一个Map就行了，需要的字段直接从Map中拿就好了，省了很多的事情。

~~~java
@Data
public  class ExtendableBean {
        private String name;
        @JsonAnySetter
        private Map<String, String> properties = Maps.newHashMap();
        @JsonAnyGetter
        public Map<String, String> getProperties() {
            return properties;
        }
        // @JsonAnySetter, 标注在字段上或者方法上都可以
        public void setProp(String key, String value) {
            this.properties.put(key, value);
        }
    }
~~~

序列化ExtendableBean：

~~~java
    @SneakyThrows
    @Test
    public void serialized (){
        ExtendableBean extendableBean = new ExtendableBean("zhangsan");
        extendableBean.setProp("key1", "value1");
        extendableBean.setProp("key2", "value2");
        new ObjectMapper().writerWithDefaultPrettyPrinter().writeValueAsString(extendableBean); 
    }
}
// 可以看到map中的key和value被当做整个json的key和value
//{
//  "name" : "zhangsan",
//  "key1" : "value1",
//  "key2" : "value2"
//}
~~~

反序列化：

~~~java
	@SneakyThrows
    @Test
    public void deserialized(){
        String json = "{\n" +
                "  \"name\" : \"zhangsan\",\n" +
                "  \"key1\" : \"value1\",\n" +
                "  \"key2\" : \"value2\"\n" +
                "}";
        ExtendableBean extendableBean = new ObjectMapper().readValue(json, ExtendableBean.class);
        System.out.println(extendableBean);
    }
// name=zhangsan, properties={key1=value1, key2=value2}
// 可以看到无法识别的json属性被放在的map中
~~~





#### @JsonGetter，@JsonSetter，@JsonProperty

这三个注解用来指定json和java中字段的对应关系

JsonGetter标注在getter方法上，序列化时指定getter属性对应的json的key。

JsonSetter标注在setter方法上，反序列化将指定的key应用在setter方法上。

JsonProperty标注在字段上，指定json和java的对应关系。

~~~java
public class People {

    // @JsonProperty("USERNAME")
    private String username;

    @JsonGetter("USERNAME")
    public String getUsername() {
        return username;
    }

    @JsonSetter("USERNAME")
    public void setUsername(String username) {
        this.username = username;
    }
}
~~~

**@JsonProperty还可以放在枚举类上，指示枚举类的序列化与反序列化。**

~~~java
public enum Status {
    @JsonProperty("ready")
    READY,
    @JsonProperty("notReady")
    NOT_READY,
    @JsonProperty("notReadyAtAll")
    NOT_READY_AT_ALL;
}
~~~



#### @JsonPropertyOrder

序列化时字段排序，alphabetic指定是否使用字母排序。value和alphabetic两个使用一个就好。

~~~java
@JsonPropertyOrder(value = {"time","name"}, alphabetic = true)
@Data
public class JsonTestModel {
    String name;
    Date time;
}
~~~



#### @JsonRowValue

标注在字段或者方法上，表示该属性序列化后的字符串是其本身， 而不需要加双引号

~~~java
    @SneakyThrows
    public static void main(String[] args) {
        RawBean bean = new RawBean("My bean", "{\"attr\":false}");
        String result = new ObjectMapper()
                .writerWithDefaultPrettyPrinter()
                .writeValueAsString(bean);
        System.out.println(result);
    }
    @Data
    @AllArgsConstructor
    public static class RawBean {
        public String name;
        @JsonRawValue
        public String json;  // 添加注释， json将会原样输出， 不加的时候，json会被添加上引号
    }
~~~

使用注解时：

~~~json
{
  "name" : "My bean",
  "json" : {"attr":false}
}
~~~

不使用时：

~~~json
{
  "name" : "My bean",
  "json" : "{\"attr\":false}"
}
~~~



#### @JsonValue

@JsonValue修饰一个字段或者无参有返回值的方法。指示jackson使用指定的字段或者方法序列化整个实例。多个@JsonValue将会报错。

~~~java
    @Data
    @AllArgsConstructor
    public class Student{
        @JsonValue
        private String name;
        private Integer age;

        // 使用toString()方法序列化实例
        // @JsonValue
        public String toString() {
            return "Student{" +
                    "name='" + name + '\'' +
                    ", age=" + age +
                    '}';
        }
    }

    @Test
    @SneakyThrows
    public void test(){
        Student student = new Student("zhangsan", 18);
        String s = new ObjectMapper().writerWithDefaultPrettyPrinter().writeValueAsString(student);
        System.out.println(s);  // "zhangsan"
    }
~~~

#### @JsonCreator

Jackson在反序列化的时候，会使用实体的默认无参构造函数来实例化一个对象，然后使用对象的setter方法来初始化属性值。如果没有无参构造的话会报错。

我们可以使用@JsonCreator来指定反序列化时候的构造函数，或者静态工厂方法。**Jackson会在调用@JsonCreator方法后继续调用setter方法进行属性的赋值。**

@JsonProperty可以标注在构造函数参数或者静态工厂方法上，指示要传入的json的key。

@ConstructorProperties只能放在构造方法上，效果同上。

~~~java
public static class Student{
        private String name;
        private Integer age;
    
        @JsonCreator // 调用构造方法后，依旧会调用age的setter方法。
        public Student(@JsonProperty("name")String name){
            this.name = name;
            this.age = 10;
        }

        // @JsonCreator和@ConstructorProperties搭配使用，不需要使用@JsonProperty， @ConstructorProperties只能使用在构造方法上
        // @JsonCreator
        // @ConstructorProperties({"name", "age"})
        // public Student(String name, Integer age){
        //     this.name = name;
        //     this.age = age;
        // }

        // 工厂方法
        @JsonCreator
        public static Student getInstance(@JsonProperty("name")String name, @JsonProperty("age")Integer age){
            return new Student(name, age);
        }
    }
~~~



#### @JsonRootName

指定序列化的json的根包装，使用时需要开启SerializationFeature.WRAP_ROOT_VALUE，否则无效。

对于这类json，反序列化时需要开启DeserializationFeature.UNWRAP_ROOT_VALUE。

~~~java
    @JsonRootName("student")
    @AllArgsConstructor
    @NoArgsConstructor
    @Data
    public static class Student{
        private String name;
        private Integer age;
    }

    @Test
    @SneakyThrows
    public void test(){
        Student student = new Student("zhangsan", 18);
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.enable(SerializationFeature.WRAP_ROOT_VALUE);
        String s = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(student);
        System.out.println(s);

        objectMapper.enable(DeserializationFeature.UNWRAP_ROOT_VALUE);
        Student student1 = objectMapper.readValue(s, Student.class);
        System.out.println(student1);
    }
~~~

~~~json
{
  "student" : {
    "name" : "zhangsan",
    "age" : 18
  }
}
JsonRootNameTest.Student(name=zhangsan, age=18)
~~~

对于序列化为xml时，默认情况下跟标签就是其类名。使用@JsonRootName可以指定根标签的名称， 还可以使用@JsonRootName的namespace属性。并且在使用XmlObject时不需要开启什么特性，感觉这个注解就是为xml而生的。

~~~java
    @JsonRootName(value = "student", namespace = "stu")
    @Data
    public static class Student{
        private String name;
        private Integer age;
    }

    @Test
    @SneakyThrows
    public void xml(){
        Student student = new Student("zhangsan", 18);
        XmlMapper xmlMapper = new XmlMapper();
        String s = xmlMapper.writerWithDefaultPrettyPrinter().writeValueAsString(student);
        System.out.println(s);

        Student student1 = xmlMapper.readValue(s, Student.class);
        System.out.println(student1);
    }
~~~

~~~xml
<student xmlns="stu">
  <name xmlns="">zhangsan</name>
  <age xmlns="">18</age>
</student>

JsonRootNameTest.Student(name=zhangsan, age=18)
~~~



#### @JacksonInject

指示jackson反序列化的时候被标注字段的值将由ObjectMapper注入。按照JacksonInject的使用可以分为按id注入和按类型注入。

> 按id注入

~~~java
    @Data
    public static class Student{
        private String name;
        private Integer age;
        @JacksonInject(value = "date")
        private Date date;
    }

    @Test
    @SneakyThrows
    public void test(){
        String json = "{\"name\":\"zhangsan\",\"age\":18}";
        ObjectMapper objectMapper = new ObjectMapper();
        InjectableValues.Std std = new InjectableValues.Std();
        std.addValue("date", new Date());
        objectMapper.setInjectableValues(std);
        Student student = objectMapper.readValue(json, Student.class); // name=zhangsan, age=18, date=Thu Jul 01 16:49:28 CST 2021
    }
~~~

> 按type注入

~~~java
    @Data
    public static class Student{
        private String name;
        private Integer age;
        @JacksonInject
        private Date date;
    }
    @Test
    @SneakyThrows
    public void test1(){
        String json = "{\n" +
                "  \"name\" : \"zhangsan\",\n" +
                "  \"age\" : 18\n" +
                "}";
        ObjectMapper objectMapper = new ObjectMapper();
        InjectableValues.Std std = new InjectableValues.Std();
        std.addValue(Date.class, new Date());
        objectMapper.setInjectableValues(std);
        Student student = objectMapper.readValue(json, Student.class); // name=zhangsan, age=18, date=Thu Jul 01 16:52:26 CST 2021
    }
~~~



#### @JsonAlias

反序列化时指定多个json字段对应一个java字段

~~~java
    @Data
    public static class Student{
        @JsonAlias({"Name", "namE"})
        private String name;
        private Integer age;
    }

    @Test
    @SneakyThrows
    public void test1(){
        String json = "{\"namE\" : \"zhangsan\",  \"age\" : 18}";
        ObjectMapper objectMapper = new ObjectMapper();
        Student student = objectMapper.readValue(json, Student.class); // name=zhangsan, age=18
    } 
~~~



### Jackson Property Inclusion Annotations



#### @JsonIgnoreProperties

标注在类上，用于序列化和反序列化时忽略标注类的对应属性

~~~java
@JsonIgnoreProperties({ "id" })
public class BeanWithIgnore {
    public int id;
    public String name;
}
~~~



#### @JsonIgnore

标注在字段上， 指示jackson序列化和反序列时忽略该字段

~~~java
public class BeanWithIgnore {
    @JsonIgnore
    public int id;

    public String name;
}
~~~



#### @JsonInclude

用于序列化时指示jackson忽略对应的字段。

标注在类上将引用于该类的所有字段。

标注在

#### @JsonIgnoreType







#### @JsonAutoDetect