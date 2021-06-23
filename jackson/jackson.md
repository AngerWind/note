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

