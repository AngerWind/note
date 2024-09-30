# 注释

```groovy
// 当行注释
/* 
多行注释
*/
/**
 文档注释
 */
```



## shebang行

~~~groovy
#!/usr/bin/env groovy
// /usr/bin/env指定shell通过env来查找groovy
// groovy表示执行当前脚本的解释器
println "Hello from the shebang line"
~~~

如果你已安装了 Groovy 发行版并且 `groovy` 命令在 `PATH` 上可用。

那么你可以直接在命令行执行如下命令来执行groovy脚本

~~~shell
./your_file.groovy
~~~



# 变量

## 定义变量

可以使用变量的类型（如 String ）或使用关键字 `def `（或 `var` ）后跟变量名称来定义变量：

```groovy
String x // 通过类型定义变量
def y // 无类型的变量
var z // 无类型的变量

String a = "hello"
def b = 10 // 自动推断类型
var c = 10 // 自动推断类型

// 一次性创建多个变量, 
def (a, b, c) = [10, 20, 'foo'] // 自动推断类型
def (int i, String j) = [10, 'foo']

// 如果左边多余变量, 那么为null
def (a, b, c) = [1, 2] // c为null

// 通过解构来赋值变量
def nums = [1, 3, 5]
def a, b, c
(a, b, c) = nums // 结构list

def (_, month, year) = "18th June 2009".split() // 结构数组
assert "In $month of $year" == 'In June of 2009'
```



对于脚本，未声明的变量被假定来自脚本绑定。



## 变量赋值

将一个对象赋值给某个变量时, **两者的类型必须相同**

但是也有一些例外

1. 变量是String, boolean, Boolean时, 可以被赋值任何类型的值

   ~~~groovy
   String s = new Date() // 隐式调用toString
   Boolean boxed = 'some string'       // 根据if的规则转换为Boolean
   boolean prim = 'some string'        // 根据if的规则转换为Boolean
   ~~~

2. 可以将字符串赋值给Class

   ~~~groovy
   Class clazz = 'java.lang.String'    // 隐式调用Class.forname
   ~~~

3. 可以将null赋值给任何**引用**类型

   ~~~groovy
   String a = null
   ~~~

4. 可以将一个Collection或者Stream分配给一个数组, 只要元素类型相同

   ~~~groovy
   int[] i = [1,2,3]               // ArrayList分配给int数组
   
   Set set = [1,2,3]
   Number[] na = set               // Set分配给Number[]
   
   def stream = Arrays.stream(1,2,3)
   int[] i = stream                // Stream分配给数组
   ~~~

5. 可以将子类型的值分配给父类型的变量

   ~~~groovy
   List list = new ArrayList()             // passes
   ~~~

6. 基础类型的拆包与装包

   ~~~groovy
   int x = Integer.valueOf(123)
   Integer bi = 1
   ~~~

7. 可以将闭包分配给**只有一个抽象方法**的类或者接口或者特质

   ~~~groovy
   Runnable r = { println 'Hello' } // 闭包分配给接口
   
   abstract class AbstractSAM {
       int calc() { 2* value() }
       abstract int value()
   }
   AbstractSAM c = { 123 } // 闭包分配给类
   assert c.calc() == 246
   ~~~

8. 低精度的数字赋值给高精度的数字类型

   ~~~groovy
   double a = 4L // 将Long赋值给double
   ~~~

   


## 自动类型推断

当使用def或者var定义一个变量的时候, 会自动根据值来推断类型

~~~groovy
def list = [] // `java.util.List`                                                       
def list = ['foo','bar']  //`java.util.List<String>`                         
def list = ["${foo}","${bar}"] //`java.util.List<GString>` 
def map = [:]                    //`java.util.LinkedHashMap`                       
def map1 = [someKey: 'someValue']   // `java.util.LinkedHashMap<String,String>`  
def map = ["${someKey}": 'someValue'] //`java.util.LinkedHashMap<GString,String>`  
def intRange = (0..10)                // `groovy.lang.IntRange`    
def charRange = ('a'..'z')            //`groovy.lang.Range<String>` 
~~~



如果变量是一个集合类型, 那么会使用最小公共父类来推断元素的泛型

~~~groovy
interface Greeter { void greet() }                  // <1>
interface Salute { void salute() }                  // <2>

class A implements Greeter, Salute {                // <3>
	void greet() { println "Hello, I'm A!" }
	void salute() { println "Bye from A!" }
}
class B implements Greeter, Salute {                // <4>
	void greet() { println "Hello, I'm B!" }
	void salute() { println "Bye from B!" }
	void exit() { println 'No way!' }               // <5>
}
def list = [new A(), new B()]     // 泛型推断为Greeter和Salute的合并类型
~~~



# 程序结构

## 包名

Groovy中的包名与Java中的包名完全一致



## Import

Groovy中的import与Java中的完全一致, 但是进行了增强



### 默认导入

在一个类或者脚本中, 会默认导入一下类

~~~groovy
import java.lang.*
import java.util.*
import java.io.*
import java.net.*
import groovy.lang.*
import groovy.util.*
import java.math.BigInteger
import java.math.BigDecimal
~~~

### 导入别名

可以在导入的时候, 对导入的类或者属性定义别名

~~~groovy
import java.util.Date
import java.sql.Date as SQLDate

Date utilDate = new Date(1000L)
SQLDate sqlDate = new SQLDate(1000L)
~~~





# 数据类型

## 字符串

### 字符串定义

~~~groovy
def a1 = 'hello world' // 单引号字符串, 底层是`java.lang.String` ，不支持插值
def a2 = ''' 
hello world
''' // 多行字符串, 底层是`java.lang.String` ，不支持插值

def a3 = "$a1" // 双引号字符串, 可以插值, 如果有插值, 那么底层类型是`groovy.lang.GString`, 否则为`java.lang.String`

def a4 = """
$a1
""" // // 多行字符串, 可以插值, 如果有插值, 那么底层类型是`groovy.lang.GString`, 否则为`java.lang.String`
~~~



### 多行字符串的格式化

如果你的代码是缩进的，比如在类里面的方法，你的字符串将会包含这些空白的缩进。 

可以使用 `String#stripIndent()` 方法来剥离（stripping out）缩进

~~~groovy
def text = '''
    This is a 
      multi-line
    string with indentation.
'''
println text.stripIndent()
/*
This is a 
  multi-line
string with indentation.
*/
~~~

也可以使用 `String#stripMargin()` 方法，该方法需要一个分隔符来识别从字符串的开头开始删除的文本。

~~~groovy
def text = '''
    |This is a 
    |multi-line
    |string with a margin.
'''
println text.stripMargin()

/**
This is a 
multi-line
string with a margin.
*/
~~~



### 字符串转义

不管是单引号字符串和双引号字符串, 都支持转义, 和java类似

~~~groovy
def a = 'an escaped single quote: \' needs a backslash' // 使用\来转移'
def b = 'an escaped escape character: \\ needs a double backslash' // 使用\来转移\
~~~



### 字符串插值

上面说到, 双引号和三双引号支持插值,  即可以使用`${}`在字符串中引用变量

在不产生歧义的情况下, 我们可以直接省略大括号

~~~groovy
def name = 'Guillaume' // a plain string
def greeting = "Hello ${name}"
def greeting1 = "Hello $name"
~~~



大括号中支持任何表达式, 包括方法调用, 计算

~~~groovy
def sum = "The sum of 2 and 3 equals ${2 + 3}"
~~~



### 闭包插值表达式

在上面的字符串插值中, 一旦我们定义完了GString, 那么他的内容就是不可变的了

~~~groovy
def name = 'Guillaume' 
def greeting = "Hello ${name}"

name = 'hello' // 不会改变greeting
~~~

如果你想要GString的内容随着插值的内容进行变化, 那么可以使用闭包插值表达式

~~~groovy
def number = 1 
def eagerGString = "value == ${number}"
def lazyGString = "value == ${ -> number }"

assert eagerGString == "value == 1" 
assert lazyGString ==  "value == 1" 

number = 2  // 不会修改eagerGString, 但是会修改lazyGString
assert eagerGString == "value == 1" 
assert lazyGString ==  "value == 2" 
~~~

产生这种差异的原理是

- 我们在使用普通插值的时候, 实际上执行的是如下的代码

  ~~~groovy
  new String(number) // 把number传进去了, 之后不管怎么修改number, 都不会影响String内部了
  ~~~

- 而使用闭包插值表达式

  ~~~java
  new String({-> number}) // 在调用toString的时候, 需要对闭包求值, 所有String的内容会随着number而变化
  ~~~

  

### String和GString的互操作

如果一个方法需要String/GString, 你都可以传入GString/String, Groovy会自动进行转换



### 斜杠字符串

除了通常的带引号的字符串之外，Groovy 还提供斜杠字符串，它使用 / 作为开始和结束分隔符。斜杠字符串对于定义正则表达式和模式特别有用，因为不需要转义反斜杠。

斜杠字符串的示例：

```groovy
def fooPattern = /.*foo.*/
assert fooPattern == '.*foo.*'
```

只有正斜杠需要用反斜杠转义：

```groovy
def escapeSlash = /The character \/ is a forward slash/
assert escapeSlash == 'The character / is a forward slash'
```

斜杠字符串是多行的：

```groovy
def multilineSlashy = /one
    two
    three/
```

Slashy 字符串的底层是GString, 所以支持插值

```groovy
def color = 'blue'
def interpolatedSlashy = /a ${color} car/
```



### 美元斜杠字符串

美元斜线字符串是用开头 \$/ 和结尾 /\$ 分隔的多行 GString。转义字符是美元符号, 它可以转义另一个美元或正斜杠

~~~groovy
def name = "Guillaume"
def date = "April, 1st"

def dollarSlashy = $/
    Hello $name,
    today we're ${date}.

    $ dollar sign
    $$ escaped dollar sign
    \ backslash
    / forward slash
    $/ escaped forward slash
    $$$/ escaped opening dollar slashy
    $/$$ escaped closing dollar slashy
/$
/**
    Guillaume
    April, 1st
    $ dollar sign
    $ escaped dollar sign
    \\ backslash
    / forward slash
    / escaped forward slash
    $/ escaped opening dollar slashy
    /$ escaped closing dollar slashy
*/
~~~



## 字符

与 Java 不同，Groovy 没有显式的字符文字。但是，您可以通过三种不同的方式明确将 Groovy 字符串设置为实际字符：

~~~groovy
char c1 = 'A' 
assert c1 instanceof Character

def c2 = 'B' as char 
assert c2 instanceof Character

def c3 = (char)'C' 
assert c3 instanceof Character
~~~

-   通过在声明保存字符的变量时明确指定 char 类型
-   通过使用 as 运算符进行类型强制转换
-   通过使用强制转换为字符操作



## 数字

整型类型与 Java 中的相同：

-   `byte`
-   `char`
-   `short`
-   `int`
-   `long`
-   `java.math.BigInteger`
-   `float`
-   `double`

-   `java.math.BigDecimal`

您可以使用以下声明创建这些类型的整数：

```groovy
// primitive types
byte  b = 1
char  c = 2
short s = 3
int   i = 4
long  l = 5
float  f = 1.234
double d = 2.345
// infinite precision
BigInteger bi =  6
BigDecimal bd =  3.456
```

也可以使用def来定义数字, 会根据数字范围来自动推断类型

~~~groovy
def a = 1
assert a instanceof Integer

// Integer.MAX_VALUE
def b = 2147483647
assert b instanceof Integer

// Integer.MAX_VALUE + 1
def c = 2147483648
assert c instanceof Long

// Long.MAX_VALUE
def d = 9223372036854775807
assert d instanceof Long

// Long.MAX_VALUE + 1
def e = 9223372036854775808
assert e instanceof BigInteger
~~~



### 数字后缀

我们可以通过给出后缀（见下表）（大写或小写）来强制数字（包括二进制、八进制和十六进制）具有特定类型。

-----------------------------------------------------------------------

  Type                    Suffix

----------------------- -----------------------------------------------

  BigInteger              `G` or `g`

  Long                    `L` or `l`

  Integer                 `I` or `i`

  BigDecimal              `G` or `g`

  Double                  `D` or `d`

  float                    `F` or `f`



**如果你需要精确计算, 那么推荐使用`G`来作为后缀, 这样就可以使用BigDecimal**



## boolean

~~~groovy
def myBooleanVariable = true
boolean untypedBooleanVar = false
booleanField = true
~~~



## List

 Groovy 列表默认情况下是的 JDK  `java.util.ArrayList`

```groovy
def numbers = [1, 2, 3]         

assert numbers instanceof List  
assert numbers.size() == 3      
```

列表中可以包含不同的类型

```groovy
def heterogeneous = [1, "a", true]  
```



可以使用`as`, 或者直接指定类型,  来创建其他类型的List

```groovy
def arrayList = [1, 2, 3] // java.util.ArrayList
def linkedList = [2, 3, 4] as LinkedList    // java.util.LinkedList
LinkedList otherLinked = [3, 4, 5] // java.util.LinkedList         
```



可以使用索引来访问元素, 使用`<<`来追加元素

可以使用`,`和`..`一次性访问多个元素

```groovy
def letters = ['a', 'b', 'c', 'd']

assert letters[0] == 'a'     
assert letters[-1] == 'd'    

letters << 'e'     // 追加元素          

assert letters[1, 3] == ['b', 'd'] // 一次访问两个元素，返回包含这两个元素的新列表     
assert letters[2..4] == ['C', 'd', 'e']  // 使用范围访问列表中从开始到结束元素位置的一系列值
```



由于列表本质上可以是异构(heterogeneous )的，因此列表还可以包含其他列表来创建多维列表：

```groovy
def multi = [[0, 1], [2, 3]]     
assert multi[1][0] == 2          
```

- 定义数字列表

- 访问最顶层列表的第二个元素和内部列表的第一个元素

  

## Array

**Groovy 使用了 List 的表示法来表示数组，但是要创建数组，您需要通过强制或类型声明来显式定义数组的类型。**

```groovy
String[] arrStr = ['Ananas', 'Banana', 'Kiwi']  
def numArr = [1, 2, 3] as int[]      
```



您还可以创建多维数组：

```groovy
def matrix3 = new Integer[3][3]         

Integer[][] matrix2                     
matrix2 = [[1, 2], [3, 4]]
```



对数组元素的访问遵循与列表相同的表示法：

```groovy
String[] names = ['Cédric', 'Guillaume', 'Jochen', 'Paul']
assert names[0] == 'Cédric'     

names[2] = 'Blackdrag'          
```



### Java风格的数组初始化

你也可以使用Java语法来创建数组

```groovy
def primes = new int[] {2, 3, 5, 7, 11}

def pets = new String[] {'cat', 'dog'}
```



## Maps

在groovy中, Map的类型默认是`java.util.LinkedHashMap`, 

默认情况下,  key为String类型, 可以不写引号

```groovy
// 定义map
def colors = [red: '#FF0000', green: '#00FF00', blue: '#0000FF'] 
// 定义空map
def emptyMap = [:]

// 访问元素, 如果没有对应的key, 那么返回null
assert colors['red'] == '#FF0000'    
assert colors.green  == '#00FF00'    
assert colors.black  == null

// 设置或者追加元素
colors['pink'] = '#FF00FF'           
colors.yellow  = '#FFFF00'           
```



您也可以使用其他类型的值作为键：

```groovy
def numbers = [1: 'one', 2: 'two']

assert numbers[1] == 'one'
```



注意, 如果你想要将一个变量作为key, 那么需要加上括号

~~~groovy
def name = 'zhangsan'
def person = [name: 'Guillaume'] // key就是字符串的name, 而不是zhangsan
person = [(name): 'Guillaume'] // key 是name对应的变量
~~~





# 运算符



### 算数运算符

Groovy支持 

1.  `+`, `-`,`*`,`/` ,`%` ,`**`, `++`, `--`
2. `+=`,`-=`,`*=`,`/=`,`%=`,`**=`



### 关系运算符

 `==`,`!=`,`<` ,`<=`,`>` ,`>=`,`===` ,`!==`                         

注意: ==和!=类似与java中的equals,  ===和!===比较的是地址



### 逻辑运算符

`&&`,`||`,`!`

注意: &&和||会短路



### 位运算符

-   `&`: 按位"与"
-   `|`: 按位"或"
-   `^`: 按位"异或"
-   `~`: 按位取反
-   `<<`: left shift
-   `>>`: right shift
-   `>>>`: 无符号右移



## 条件运算符



### 三元运算符

`value ? a : b`

注意:  对于value的判断, 将会按照`if`关键字的规则



### Elvis操作符

Elvis操作符是三元运算符的简写

~~~groovy
displayName = user.name ? user.name : 'Anonymous'   
displayName = user.name ?: 'Anonymous' 

atomicNumber ?= 2 // 等效于name = name ?: 2
~~~



## 对象运算符

### 安全导航运算符

安全导航运算符用于避免 NullPointerException 

~~~groovy
def name = person?.name // 如果person为null, 那么返回null, 否则返回person.name
~~~





### 字段访问操作符

~~~groovy
class User {
    public final String name                 
    User(String name) { this.name = name}
    String getName() { "Name: $name" }       
}
def user = new User('Bob')
assert user.name == 'Name: Bob'  
~~~

`user.name` 调用会触发对同名属性的调用，也就是说，这里是对 name 的 getter 的调用。如果您想直接使用字段而不是调用 getter，可以使用直接字段访问运算符：

```groovy
assert user.@name == 'Bob' // 直接访问字段
```



### 方法指针运算符

方法指针运算符 ( `.&` ) 可用于在变量中存储对方法的引用，以便稍后调用它：

~~~groovy
def str = 'example of method reference'            
def fun = str.&toUpperCase  // 存储str.toUpperCase                       
def upper = fun() // 调用str.toUpperCase()
~~~

方法指针的类型是 groovy.lang.Closure ，因此它可以在任何需要使用闭包的地方使用。

```groovy
def transform(List elements, Closure action) {                    
    def result = []
    elements.each {
        result << action(it)
    }
    result
}
String describe(Person p) {                                       
    "$p.name is $p.age"
}
def action = this.&describe                                       
def list = [
    new Person(name: 'Bob',   age: 42),
    new Person(name: 'Julia', age: 35)]                           
assert transform(list, action) == ['Bob is 42', 'Julia is 35']    
```

对于构造函数, 可以使用 new 作为方法名称来获取指向构造函数的方法指针：

```groovy
def foo  = BigInteger.&new
def fortyTwo = foo('42')
assert fortyTwo == 42G
```

你可以获取一个类的方法指针, **但是在调用的时候, 要传入一个对应的实例**

```groovy
def instanceMethod = String.&toUpperCase
assert instanceMethod('foo') == 'FOO'
```



### 方法引用运算符

Groovy支持Java中的方法引用运算符`::`, 尽管他与方法指针运算符功能有些重叠

~~~groovy
[1G, 2G, 3G].stream().reduce(0G, BigInteger::add)   
[1G, 2G, 3G].stream().reduce(0G, BigInteger.&add) // 两者功能一样

[1, 2, 3].stream().toArray(Integer[]::new)  // 引用构造函数
~~~



## 正则表达式运算符

### 模式运算符

模式运算符 ( \~ ) 提供了一种创建 java.util.regex.Pattern 实例的简单方法：

```groovy
def p = ~/foo/ // p是Pattern类型
```

虽然一般情况下，模式运算符会与斜线字符串一起使用，但它可以与 Groovy 中的任何类型的 String 一起使用：

```groovy
p = ~'foo'                                                        
p = ~"foo"                                                        
p = ~$/dollar/slashy $ string/$                                   
p = ~"${pattern}"                                                 
```

**建议使用斜线字符串，以避免转义。**



### Find运算符

您还可以使用查找运算符 =\~ 直接创建 java.util.regex.Matcher 实例：

```groovy
def text = "some text to match"
def m = text =~ /match/     // =~ 使用右侧的模式针对 text 变量创建Matcher
if (!m) {         // 相当于调用 if (!m.find(0))                                                
    throw new RuntimeException("Oops, text not found!")
}
```



### Match 运算符

匹配运算符 ( ==\~ ) 是查找运算符的轻微变体，

它不返回 Matcher 而是返回布尔值，判断输入字符串的严格匹配：

```groovy
def text = "some text to match"
def m = text ==~ /match/ // 判断字符串是否严格匹配正则表达式, 返回boolean
```



### Find 和 Match 运算符的比较

通常，当模式涉及单个精确匹配时，使用Match运算符，否则Find运算符可能更有用。

```groovy
assert 'two words' ==~ /\S+\s+\S+/ 
assert 'two words' ==~ /^\S+\s+\S+$/ // equivalent, but explicit \^ and \$ are discouraged since they aren't needed         
assert !(' leading space' ==~ /\S+\s+\S+/) // no match because of leading space

def m1 = 'two words' =~ /^\S+\s+\S+$/
assert m1.size() == 1 // one match                          
def m2 = 'now three words' =~ /^\S+\s+\S+$/    
assert m2.size() == 0     // zero matches                     
def m3 = 'now three words' =~ /\S+\s+\S+/
assert m3.size() == 1     // one match, greedily starting at first word                     
assert m3[0] == 'now three'
def m4 = ' leading space' =~ /\S+\s+\S+/
assert m4.size() == 1   // one match, ignores leading space                       
assert m4[0] == 'leading space'
def m5 = 'and with four words' =~ /\S+\s+\S+/
assert m5.size() == 2    // two matches                      
assert m5[0] == 'and with'
assert m5[1] == 'four words'
```



## 其他操作符



### 展开运算符

Spread-dot 运算符  `*. ` 用于对实现了`Iterable`接口的集合的所有元素进行操作, 然后将结果收集为List

~~~groovy
class Car {
    String make
    String model
}
def cars = [
       new Car(make: 'Peugeot', model: '508'),
       new Car(make: 'Renault', model: 'Clio')]       
def makes = cars*.make  // 等效于cars.collect(it.make)   

// 对null执行扩展是安全的
null*.make // 返回null
~~~

groovy的GPath语法允许:  当引用的属性不是List的属性时, 可以将*忽略, 尽管**不推荐**

~~~groovy
def makes = cars.make // 等效于cars*.make
~~~



扩展运算符可以多次调用

~~~groovy
class Make {
    String name
    List<Model> models
}

class Model {
    String name
}

def cars = [
    new Make(name: 'Peugeot',
             models: [new Model('408'), new Model('508')]),
    new Make(name: 'Renault',
             models: [new Model('Clio'), new Model('Captur')])
]

def models = cars*.models*.name // [['408', '508'], ['Clio', 'Captur']]
~~~



#### 展开方法参数

```groovy
def args = [4,5,6]
int function(int x, int y, int z) {
    x*y+z
}
function(*args) 
```

甚至可以将普通参数与扩展参数混合在一起：

```groovy
args = [4]
assert function(*args,5,6) == 26
```

#### 展开列表元素

当在列表中使用时，展开运算符的作用就好像展开元素内容并内联到列表中一样：

```groovy
def items = [4,5]                      
def list = [1,2,3,*items,6]            
assert list == [1,2,3,4,5,6]           
```



#### 扩展map中的元素

展开map运算符的工作方式与展开list运算符类似，但适用于map。它允许您将map的内容内联到另一个map中，如下例所示：

```groovy
def m1 = [c:3, d:4]                   
def map = [a:1, b:2, *:m1]            
assert map == [a:1, b:2, c:3, d:4]    
```

展开map运算符的位置是相关的，如下例所示：

```groovy
def m1 = [c:3, d:4]                   
def map = [a:1, b:2, *:m1, d: 8]   // d:8会覆盖前面的d:4     
```



### 范围运算符

范围运算符会创建一个`groovy.lang.Range`实例, 他实现了List接口

```groovy
// 使用数字创建Range
def range = 0..5                                    
assert (0..5).collect() == [0, 1, 2, 3, 4, 5]       
assert (0..<5).collect() == [0, 1, 2, 3, 4]         
assert (0<..5).collect() == [1, 2, 3, 4, 5]         
assert (0<..<5).collect() == [1, 2, 3, 4]           
```

事实上, 只要一个类实现了`Comparable`接口, 并且有`next()`和`previous()`方法, 就可以根据实例创建Range

例如，您可以通过以下方式创建一系列字符：

~~~groovy
assert ('a'..'d').collect() == ['a','b','c','d']
~~~



### 三向比较运算符

`<=>`隐式调用compareTo方法, 如果小于返回-1, 相等返回0, 大于返回1

~~~groovy
assert (1 <=> 1) == 0
assert (1 <=> 2) == -1
~~~



### 下标运算符

下标运算符是 `getAt` 或 `putAt`的简写符号

```groovy
def list = [0,1,2,3,4]
assert list[2] == 2  // getAt
list[2] = 4  // putAt                                          
```



### 安全索引运算符

~~~groovy
// 设置list
String[] array = ['a', 'b']
array?[1]      // 如果array为null, 或者没有这个下标, 那么返回null
array?[1] = 'c' // 如果array为null, 那么忽略设置


def personInfo = [name: 'Daniel.Sun', location: 'Shanghai']
personInfo?['name']      // 如果personInfo为null, 或者没有name这个key, 返回null
personInfo?['name'] = 'sunlan'// 如果personInfo为null, 那么忽略这个设置
~~~



### in和!in

 `in`  相当于调用 isCase 方法。在 List 的上下文中，它相当于调用 contains ，如以下示例所示：\

~~~groovy
def list = ['Grace','Rob','Emmy']
assert ('Emmy' in list) // 调用 list.contains('Emmy') 或 list.isCase('Emmy')                    
assert ('Alex' !in list)   // 调用 !list.contains('Emmy') 或 !list.isCase('Emmy')
~~~



### as

as 可以进行强制类型转换

当一个对象被强制转换为另一个对象时，除非目标类型与源类型相同，否则将隐式调用`asType`并返回一个新对象

~~~groovy
String input = '42'
Integer num = (Integer) input // 报错
Integer num = input as Integer   // 隐式调用input.asType(Integer.class)
~~~





### instanceof

用来判断类型

```groovy
class Greeter {
    String greeting() { 'Hello' }
}

void doSomething(def o) {
    if (o instanceof Greeter) {     
        println o.greeting()        // 可以将o作为Greeter类型使用
    }
}
```



## 运算符重载

Groovy支持运算符重载, 你可以重写一下方法, 来对运算符进行重载

| 运算符                    | 重写方法                |
| ------------------------- | ----------------------- |
| `a + b`                   | a.plus(b)               |
| `a - b`                   | a.minus(b)              |
| `a * b`                   | a.multiply(b)           |
| `a / b`                   | a.div(b)                |
| `a % b`                   | a.mod(b)                |
| `a ** b`                  | a.power(b)              |
| `a | b`                   | a.or(b)                 |
| `a & b`                   | a.and(b)                |
| `a ^ b`                   | a.xor(b)                |
| `as`                      | a.asType(b)             |
| `a()`                     | a.call()                |
| `a[b]`                    | a.getAt(b)              |
| `a[b] = c`                | a.putAt(b, c)           |
| `a in b`                  | b.isCase(a)             |
| `a << b`                  | a.leftShift(b)          |
| `a >> b`                  | a.rightShift(b)         |
| `a >>> b`                 | a.rightShiftUnsigned(b) |
| `a++` or `++a`            | a.next()                |
| `a--` or `--a`            | a.previous()            |
| `+a`                      | a.positive()            |
| `-a`                      | a.negative()            |
| `~a`                      | a.bitwiseNegate()       |
| `switch(a) { case(b) : }` | b.isCase(a)             |
| `if(a)`                   | a.asBoolean()           |
| `a as b`                  | a.asType(b)             |
| `a == b`                  | a.equals(b)             |
| `a != b`                  | ! a.equals(b)           |
| `a <=> b`                 | a.compareTo(b)          |
| `a > b`                   | a.compareTo(b) \> 0     |
| `a <= b`                  | a.compareTo(b) \<= 0    |



自定义类型转换

~~~groovy
class Polar {
    double r
    double phi
    // 定义类型转换
    def asType(Class target) {
    	if (Cartesian==target) {
        	return new Cartesian(x: r*cos(phi), y: r*sin(phi))
    	}
	}

}
class Cartesian {
   double x
   double y
}

def polar = new Polar(r:1.0, phi:PI/2)
def cartesian = polar as Cartesian // 将Polar转换为Cartesian, 会调用Polar的asType
~~~







# 控制结构

## if / else

Groovy 支持 Java 中常见的 if - else 语法

```groovy
if ( ... ) {
    ...
} else if (...) {
    ...
} else {
    ...
}
```

if可以判断多种类型

1. Boolean: true为true, false为false

2. 集合和数组:  非空为true

3. Map: 非空的map为true

4. Matcher: 如果匹配器至少有一个匹配项，则为 true

5. 字符串: 非空为true

6. 数字: 非0为true

7. 引用类型: 非null为true

8. 其他: 调用其`asBoolean()`方法来判断真假

   ~~~java
   class Color {
       String name
       boolean asBoolean(){
           name == 'green' ? true : false 
       }
   }
   if (new Color(name: 'green')){ // true }
   ~~~

   







## switch / case

groovy与java类似, 必须在每个case语句后面添加break

switch可以匹配一下情况:

- 匹配类型
- 匹配正则表达式: 如果switch的值的toString, 与正常表达式匹配, 则返回成功
- 匹配集合: 如果switch的值在集合中, 那么匹配成功
- 匹配闭包:   将switch传入闭包中, 然后调用闭包, 然后使用`if`来判断返回值为true/false, 如果为true表示匹配成功
- 如果不是以上的情况, 那么调用equals来进行比较

```groovy
def x = 1.23
def result = ""

switch (x) {
    case Integer: // 匹配类型
        result = "integer"
        break

    case Number: // 匹配类型
        result = "number"
        break
    
    case [4, 5, 6, 'inList']: // 判断是否在集合中
        result = "list"
        break

    case 12..30: // 判断是否在集合中
        result = "range"
        break
     case ~/fo*/: // 调用switch值的toString, 然后与真正表达式比较, 是否匹配
        result = "foo regex"
        break
    
     case { it < 0 }: // 将switch的值传入闭包中, 看返回的是true还是false, 闭包隐式包含一个名为it参数
        result = "negative"
        break
    case "foo": // 不是以上的情况, 调用equals进行比较
        result = "found foo"
        break
    
    case "bar": // 不是以上的情况, 调用equals进行比较
        result += "bar"
    	break
    
    default: // 默认情况
        result = "default"
}
```



Switch还可以返回值

```groovy
def partner = switch(person) {
    case 'Romeo'  -> 'Juliet'
    case 'Adam'   -> 'Eve'
    case 'Antony' -> 'Cleopatra'
    case 'Bonnie' -> 'Clyde'
}
```



## for循环

Groovy 支持标准的 Java for 循环

```groovy
def facts = []
def count = 5
for (int fact = 1, i = 1; i <= count; i++, fact *= i) {
    facts << fact
}
assert facts == [1, 2, 6, 24, 120]
```



可以在for循环中使用多重赋值

```groovy
// multi-assignment goes loopy
def baNums = []
for (def (String u, int v) = ['bar', 42]; v < 45; u++, v++) {
    baNums << "$u $v"
}
assert baNums == ['bar 42', 'bas 43', 'bat 44']
```

## for in 循环

for in可以迭代任何集合, 数组, Map

```groovy
// 迭代range
def x = 0
for ( i in 0..9 ) {
    x += i
}
assert x == 45

// 迭代list
x = 0
for ( i in [0, 1, 2, 3, 4] ) {
    x += i
}
assert x == 10

// iterate over an array
def array = (0..4).toArray()
x = 0
for ( i in array ) {
    x += i
}
assert x == 10

// iterate over a map
def map = ['abc':1, 'def':2, 'xyz':3]
x = 0
for ( e in map ) {
    x += e.value
}
assert x == 6

// iterate over values in a map
x = 0
for ( v in map.values() ) {
    x += v
}
assert x == 6

// 迭代字符串
def text = "abc"
def list = []
for (c in text) {
    list.add(c) // c是string类型
}

// 迭代字符串
for (char c in text) { 
    // c是char类型
}
```



## while 循环

Groovy 像 Java 一样支持常见的 `while {…​}` 循环：

```groovy
def y = 5
while ( y > 0 ) {
    y--
}
```



## do/while 循环

现在支持 Java 类 do/while 循环。例子：

```groovy
def y = 5
do {
    y--
} while (y > 0)
```



# 函数

函数与方法类似, 可以查看面向对象-类-方法















# 面相对象



## 类

Groovy类和java类一样, 但是有一些细微的差别

1. 类和方法默认是public的, 可以省略public
2. 没有可见性的字段会自动转换为属性, 自动添加getter/setter
3. 类和文件不需要同名, 一个源文件可以包含多个类

~~~groovy
class Person {                       

    String name  // 自动添加getter和setter                    
    Integer age  // 自动添加getter和setter      

    def increaseAge(Integer years) { 
        this.age += years
    }
}
def p = new Person() // 实例化
~~~



### 构造函数

1. 如果没有显示定义任何构造函数, 那么有一个默认的空参构造函数

2. 可以声明多个参数不同的构造函数

3. 可以使用`groovy.transform.TupleConstructor`来添加一个构造函数, 类似于Java中的Lombok

   ~~~groovy
   import groovy.transform.TupleConstructor
   @TupleConstructor
   class Person {
       String name
       int age
   }
   def person = new Person("Alice", 30)
   ~~~

   参数选项:

   `@TupleConstructor(includes = ["field1", "field2"])`：指定构造函数只包含某些字段。

   `@TupleConstructor(excludes = ["field1"])`：指定构造函数不包含某些字段。

   `@TupleConstructor(includeFields = true)`：是否包括类的字段（包括私有字段）。

   `@TupleConstructor(callSuper = true)`：是否调用父类的构造函数。

   `@TupleConstructor(force = true)`：即使类已经有构造函数，仍然生成一个额外的构造函数。

4. 可以将一个List字面量赋值给一个类型T, 如果T有一个构造函数，其参数与List字面量中元素的类型匹配

   ~~~groovy
   @groovy.transform.TupleConstructor
   class Person {
       String firstName;
       int age
   }
   Person p = new Person("Tiger", 20)
   Person p2 = ["Tiger", 20] // 查找String,int类型的构造函数
   def p1 = ["Tiger", 20] as Person
   ~~~

5. 可以将一个Map字面量赋值给一个类型T, 如果T 有一个无参数构造函数, 并且对于 `Map` 中的每个key, 都有一个与之对应的属性

   ~~~groovy
   class Person {
       String firstName
       int age
   }
   // 调用无参构造, 然后调用setter
   Person map = [firstName:'Ada', lastName:'Lovelace']
   def map1 = [firstName:'Ada', lastName:'Lovelace'] as Person
   
   Person map = [firstName:'Ada', lastName:'Lovelace', age: 24]  // 会编译报错
   ~~~

5. 如果类有一个无参构造函数, 或者第一个参数为map的构造函数, 那么就支持通过命名参数的形式创建实例

   ~~~groovy
   class PersonWOConstructor {                                  
       String name
       Integer age
   }
   
   def person4 = new PersonWOConstructor()                      
   def person5 = new PersonWOConstructor(name: 'Marie') // 调用无参构造和setter         
   def person6 = new PersonWOConstructor(age: 1) // 调用无参构造和setter          
   def person7 = new PersonWOConstructor(name: 'Marie', age: 2) // 调用无参构造和setter   
   ~~~

   ~~~groovy
   class Person {
       String firstName;
       int age
       Person(Map map) {
           this.firstName = map.firstName
           this.age = map.age
       }
   }
   Person p = new Person(first: "Tiger", age: 20)
   Person p2 = new Person(first: "hello")
   ~~~

6. 可以使用`groovy.transform.MapConstructor`来生成一个接受Map作为参数的构造函数
   
   ~~~groovy
   @groovy.transform.MapConstructor
   class Person {
       String name
       int age
   }
   
   def person = new Person(name: "Alice", age: 30)
   ~~~
   
   参数选项
   
   `@MapConstructor(includes = ["field1", "field2"])`：只生成包含指定字段的构造函数。
   
   `@MapConstructor(excludes = ["field1"])`：排除指定字段，不在构造函数中初始化。
   
   `@MapConstructor(includeFields = true)`：是否包含类的字段（包括私有字段）。
   
   `@MapConstructor(callSuper = true)`：是否调用父类的构造函数。
   
   `@MapConstructor(force = true)`：即使类中已经有构造函数，仍然生成一个额外的基于 Map 的构造函数。
   
   `@MapConstructor(noArg = true)`：同时生成一个无参构造函数。

### 方法

#### 方法定义

1. 使用`返回类型`定义方法, 那么他**只能返回指定类型的返回值**
2. 使用 `def` 关键字定义方法, 那么他**可以返回任何类型**
3. 方法参数可以省略类型, 表示可以接收任何类型
4. 方法默认是`public`的, 也可以使用Java中的修饰符来修饰方法
5. 方法可以省略return, 默认返回最后一行的值

~~~groovy
def someMethod() { 'method called' }    // 使用def定义方法, 可以返回任何类型 
String anotherMethod() { 'another method called' } // 使用返回值类型定义方法, 只能返回string
def thirdMethod(param1) { "$param1 passed" }   // 参数可以不指定类型, 可以接收任何类型
static String fourthMethod(String param1) { "$param1 passed" }  // 可以使用Java中的修饰符
~~~

#### 默认参数

函数可以定义默认参数

~~~groovy
def foo(String par1, Integer par2 = 1) {
    [name: par1, age: par2] 
}
foo('Marie').age // 1
~~~

#### 可变参数

与Java类似

~~~groovy
def foo(Object... args) { args.length }
def foo(Object[] args) { args.length }
~~~

#### 命名参数

如果函数的第一个参数是map, 那么可以使用命名参数, 命名参数可以位于任何位置。它们被合并到map中并自动作为第一个参数传递。

~~~groovy
def foo(Map args, Integer number) {
    "${args.name}: ${args.age}, and the number is ${number}" 
}
foo(name: 'Marie', age: 1, 23)  
foo(23, name: 'Marie', age: 1)  // 命名参数会自动合并为map, 然后作为第一个参数进行传递
~~~



#### 声明异常

Groovy 声明方法抛出的异常与Java类似

~~~groovy
// 声明抛出的异常
def badRead() throws FileNotFoundException {
    new File('doesNotExist.txt').text
}
~~~

但是Exception可以像RuntimeException一样, 不必声明thrwos

~~~groovy
// 声明抛出的异常
def badRead() {
    // 在Java中FileNotFoundException一定要try-catch, 或者throws
    // 但是在Groovy中, 不需要
    new File('doesNotExist.txt').text
}
~~~



### 字段和属性

#### 字段

1. 一个必须得访问修饰符 (`public`, `protected`, or `private`)
2. 可以添加`static`, `final`, `synchronized`
3. 字段类型可以省略, 但是不推荐

~~~groovy
class Data {
    private mapping    // 省略类型
    private int id                                  
    private String id = IDGenerator.next()                  
    public static final boolean DEBUG = false       
}
~~~

#### 属性

1. 属性和字段类似, 但是没有`public`, `protected`, or `private`

2. Groovy会在字节码层面将属性设置为private, 并自动生成getter/setter(`setXXX`, `getXXX`, `isXXX--booean类型`)
3. 如果属性时final的, 那么不会生成setter
4. 属性直接通过名称进行访问, 并且会隐式的调用getter/setter
5. 可以使用实例的`properties`属性列出所有属性

~~~groovy
class Person {
    String name // 自动生成getter/setter                            
    int age // 自动生成getter/setter
    final int sex = 1  // 只有getter
}

def p = new Person()
person.name = "zhangsan" // 隐式调用setName
println(person.age) // 隐式盗用getName

p.properties // 返回一个Map, 包含所有属性名和value
~~~



即使没有支持字段，只要存在遵循 Java Beans 规范的 getter 或 setter，Groovy 也会识别属性

~~~groovy
class PseudoProperties {
    // 定义了一个name属性
    void setName(String name) {}
    String getName() {}

    // 定义了一个只读的age属性
    int getAge() { 42 }

    // 定义了一个只写的groovy属性
    void setGroovy(boolean groovy) {  }
}
def p = new PseudoProperties()
p.name = 'Foo'                      
p.age        
p.groovy = true    
~~~



### 使用多重赋值进行对象解构

在运算符中, 我们描述了下标运算符,  对一个对象取下标, 实际上就是调用他的getAt() / putAt() 方法

通过这种技术，我们可以实现对象解构。

```groovy
@Immutable
class Coordinates {
    double latitude
    double longitude

    double getAt(int idx) {
        if (idx == 0) latitude
        else if (idx == 1) longitude
        else throw new Exception("Wrong coordinate index, use 0 or 1")
    }
}

def coordinates = new Coordinates(latitude: 43.23, longitude: 3.67) 
def (la, lo) = coordinates   // 结构对象, 隐式调用getAt(1)和getAt(2) 
```



## 内部类

内部类是定义在外部类内部的类, 内部类可以访问外部类的成员和方法

Groovy 还支持非静态内部类实例化的 Java 语法

~~~groovy
class Computer {
    class Cpu {
        int coreNumber

        Cpu(int coreNumber) {
            this.coreNumber = coreNumber
        }
    }
}

def cpu = new Computer().new Cpu(4)
~~~



## 抽象类

抽象类是具有抽象方法的类, 不能被实例化

~~~groovy
abstract class Abstract {
    String name
    abstract def abstractMethod()  // 抽象方法
    def concreteMethod() {
        println 'concrete'
    }
}

class Concrete extends Abstract {
    def abstractMethod() {
        println 'abstract'
    }
}
~~~











## 接口

groovy中的接口与Java中的接口一样,  只能有default方法和抽象方法, final字段

抽象方法始终是public的

~~~groovy
interface Greeter {
    void greet(String name)                       
}
class SystemGreeter implements Greeter {                    
    void greet(String name) {                               
        println "Hello $name"
    }
}
~~~



如果一个接口只有一个抽象方法, 那么可以直接使用闭包来实现它

这会创建一个实现接口的子类

~~~groovy
interface Greeter {
    void greet(String name)                       
}

Greeter g = {name -> println(name)} // 创建一个实现接口的子类, 然后调用其构造函数创建实例
def g1 = {name -> println(name)} as Greeter
~~~







## 特质

特质与类相同, 可以有属性, 字段, 普通方法, 抽象方法等等

子类可以继承多个接口和特质, 但是只能继承一个父类



**因为Groovy的底层是Java, 所以在实现特质功能的时候, 实际上是将特质中的方法和属性合并到子类中, 而不是从特质中继承, 因为Java不支持多继承**

~~~groovy
// 定义特质
trait FlyingAbility {     
     int age // 属性
     abstract String name() // 抽象方法
     String fly() { "I'm flying!" } // 普通方法 
}
// 实现特质
class Bird implements FlyingAbility {
    
}    
~~~



**特质中的方法只支持public和private, 不支持protect**

子类不会继承特质的private方法

~~~groovy
trait Greeter {
    private String greetingMessage() {                      
        'Hello from a private method!'
    }
}
class GreetingMachine implements Greeter {}   
def g = new GreetingMachine() // g不能调用greetingMessage
~~~



特质可以实现接口

~~~groovy
interface Named {                                       
    String name()
}
trait Greetable implements Named {                      
    String greeting() { "Hello, ${name()}!" }
}
~~~



特质可以继承多个特质

~~~groovy
trait WithId {                                      
    Long id
}
trait WithName {                                    
    String name
}
trait Identified1 extends WithId {}  // 继承1个特质使用implements
trait Identified implements WithId, WithName {}  // 继承多个特质使用implements
~~~



如果一个特质只有一个抽象方法, 那么可以使用闭包来创建他的实例

这会创建一个实现特质的子类

~~~groovy
trait Named {                                       
    String name()
}
Named named = {"hello"} // 创建一个实现Named的子类, 然后调用其构造函数实例化
def n1 = {"hello"} as Named // 使用as进行类型转换
~~~







### 鸭子类型与特质

#### 动态代码

Traits 可以调用任何动态代码，就像普通的 Groovy 类一样。这意味着 **您可以在方法主体中调用应该存在于实现类中的方法，而无需在接口中显式声明它们**。这意味着特质与鸭子类型完全兼容：

    trait SpeakingDuck {
        String speak() { quack() }                      
    }
    class Duck implements SpeakingDuck {
        String methodMissing(String name, args) {
            "${name.capitalize()}!"                     
        }
    }
    def d = new Duck()
    assert d.speak() == 'Quack!'                        

-   SpeakingDuck 期望定义 quack 方法

-   Duck 类 实现了 methodMissing 方法方法

-   调用 speak 方法会触发对 quack 的调用，该调用由 methodMissing 处理

#### 特质中的动态方法

特质还可以实现 MOP 方法，例如 methodMissing 或 propertyMissing ，在这种情况下，实现类将从特质继承行为，如下例所示：

    trait DynamicObject {                               
        private Map props = [:]
        def methodMissing(String name, args) {
            name.toUpperCase()
        }
        def propertyMissing(String name) {
            props.get(name)
        }
        void setProperty(String name, Object value) {
            props.put(name, value)
        }
    }
    
    class Dynamic implements DynamicObject {
        String existingProperty = 'ok'                  
        String existingMethod() { 'ok' }                
    }
    def d = new Dynamic()
    assert d.existingProperty == 'ok'                   
    assert d.foo == null                                
    d.foo = 'bar'                                       
    assert d.foo == 'bar'                               
    assert d.existingMethod() == 'ok'                   
    assert d.someMethod() == 'SOMEMETHOD'               

-   创建一个实现多个 MOP 方法的特质

-   Dynamic 类定义一个属性

-   Dynamic 类定义了一个方法

-   调用现有属性将调用 Dynamic 中的方法

-   调用不存在的属性将调用特质中的方法

-   将调用特质上定义的 setProperty

-   将调用特质上定义的 getProperty

-   调用 Dynamic 上的现有方法

-   但由于 methodMissing 特性而调用不存在的方法

### 多重继承的冲突

#### 默认冲突解决方案

一个类可以实现多个特质。如果某个特质定义的方法与另一个特质中的方法具有相同的签名，则会发生冲突：

    trait A {
        String exec() { 'A' }               
    }
    trait B {
        String exec() { 'B' }               
    }
    class C implements A,B {}               

-   Trait A 定义了一个名为 exec 的方法，返回一个 String

-   特质 B 定义了完全相同的方法

-   类 C 实现了这两个特质

在这种情况下，默认行为是 implements 子句中最后声明的特质中的方法获胜。这里， B 是在 A 之后声明的，因此 B 中的方法将被选取：

    def c = new C()
    assert c.exec() == 'B'

#### User conflict resolution

如果这种行为不是您想要的，您可以使用 Trait.super.foo 语法显式选择要调用的方法。在上面的示例中，我们可以通过编写以下内容来确保调用特质 A 中的方法：

    class C implements A,B {
        String exec() { A.super.exec() }    
    }
    def c = new C()
    assert c.exec() == 'A'                  

-   从特质 A 显式调用 exec

-   调用 A 中的版本，而不是使用默认的 B 中的版本

### 特质的运行时实现

#### 在运行时实现特质

Groovy 还支持在运行时动态实现特质。它允许您使用特质"装饰"现有对象。作为一个例子，让我们从这个特质和下面的类开始：

    trait Extra {
        String extra() { "I'm an extra method" }            
    }
    class Something {                                       
        String doSomething() { 'Something' }                
    }

-   Extra 特质定义了 extra 方法

-   Something 类未实现 Extra 特质

-   Something 只定义了一个方法 doSomething

那么如果我们这样做：

    def s = new Something()
    s.extra()

对 extra 的调用将失败，因为 Something 未实现 Extra 。可以使用以下语法在运行时执行此操作：

    def s = new Something() as Extra                        
    s.extra()                                               
    s.doSomething()                                         

-   使用 as 关键字在运行时将对象强制为特质

-   然后可以在对象上调用 extra

-   并且 doSomething 仍然可以调用

当将对象强制为特质时，操作的结果与原来的实例不是同一个实例。被强制的对象将实现原始对象实现的特质和接口，但不会是原始类的实例。

#### 一次实现多个特质

如果您需要一次实现多个特质，您可以使用 withTraits 方法而不是 as 关键字：

    trait A { void methodFromA() {} }
    trait B { void methodFromB() {} }
    
    class C {}
    
    def c = new C()
    c.methodFromA()                     
    c.methodFromB()                     
    def d = c.withTraits A, B           
    d.methodFromA()                     
    d.methodFromB()                     

-   调用 methodFromA 将失败，因为 C 未实现 A

-   调用 methodFromB 将失败，因为 C 未实现 B

-   withTrait 将把 c 包装成实现 A 和 B 的东西

-   methodFromA 现在将通过，因为 d 实现了 A

-   methodFromB 现在将通过，因为 d 也实现了 B

当将一个对象强制为多个特质时，操作的结果与原来的实例不是同一个实例。被强制的对象将实现原始对象实现的特质和接口，但不会是原始类的实例。

### 链式行为

Groovy 支持可堆叠特质的概念。这个想法是，如果当前特质无法处理消息，则将一个特质委托给另一个特质。为了说明这一点，让我们想象一个像这样的消息处理程序接口：

    interface MessageHandler {
        void on(String message, Map payload)
    }

然后，您可以通过应用小行为来编写消息处理程序。例如，让我们以特质的形式定义一个默认处理程序：

    trait DefaultHandler implements MessageHandler {
        void on(String message, Map payload) {
            println "Received $message with payload $payload"
        }
    }

然后任何类都可以通过实现该特质来继承默认处理程序的行为：

    class SimpleHandler implements DefaultHandler {}

现在，如果您想记录除了默认处理程序之外的所有消息怎么办？一种选择是这样写：

    class SimpleHandlerWithLogging implements DefaultHandler {
        void on(String message, Map payload) {                                  
            println "Seeing $message with payload $payload"                     
            DefaultHandler.super.on(message, payload)                           
        }
    }

-   显式实现 on 方法

-   执行日志记录

-   继续执行 DefaultHandler 特质中的行为

这是可行的，但这种方法有缺点：

1.  日志逻辑绑定到"具体"处理程序

2.  我们在 on 方法中显式引用了 DefaultHandler ，这意味着如果我们碰巧更改了类实现的特质，代码将会被破坏

作为替代方案，我们可以编写另一个特质，其责任仅限于日志记录：

    trait LoggingHandler implements MessageHandler {                            
        void on(String message, Map payload) {
            println "Seeing $message with payload $payload"                     
            super.on(message, payload)                                          
        }
    }

-   日志处理程序本身就是一个处理程序

-   打印收到的消息

-   然后 super 使其将调用委托给链中的下一个特质

那么我们的类可以重写为：

    class HandlerWithLogger implements DefaultHandler, LoggingHandler {}
    def loggingHandler = new HandlerWithLogger()
    loggingHandler.on('test logging', [:])

这将打印：

    Seeing test logging with payload [:]
    Received test logging with payload [:]

由于优先级规则意味着 LoggerHandler 获胜，因为它是最后声明的，因此对 on 的调用将使用 LoggingHandler 的实现。但后者调用了 super ，这意味着链中的下一个特质。在这里，下一个特质是 DefaultHandler 因此两者都会被调用：

如果我们添加第三个处理程序，该处理程序负责处理以 say 开头的消息，那么这种方法的好处就变得更加明显：

    trait SayHandler implements MessageHandler {
        void on(String message, Map payload) {
            if (message.startsWith("say")) {                                    
                println "I say ${message - 'say'}!"
            } else {
                super.on(message, payload)                                      
            }
        }
    }

-   处理程序特定的先决条件

-   如果不满足前提条件，则将消息传递给链中的下一个处理程序

然后我们的最终处理程序如下所示：

    class Handler implements DefaultHandler, SayHandler, LoggingHandler {}
    def h = new Handler()
    h.on('foo', [:])
    h.on('sayHello', [:])

这意味着

-   消息将首先通过日志处理程序

-   日志处理程序调用 super ，它将委托给下一个处理程序，即 SayHandler

-   如果消息以 say 开头，则处理程序将使用该消息

-   如果没有， say 处理程序将委托给链中的下一个处理程序

这种方法非常强大，因为它允许您编写彼此不认识的处理程序，但又可以按照您想要的顺序组合它们。例如，如果我们执行代码，它将打印：

    Seeing foo with payload [:]
    Received foo with payload [:]
    Seeing sayHello with payload [:]
    I say Hello!

但是如果我们将日志处理程序移至链中的第二个，则输出会有所不同：

    class AlternateHandler implements DefaultHandler, LoggingHandler, SayHandler {}
    h = new AlternateHandler()
    h.on('foo', [:])
    h.on('sayHello', [:])

打印:

    Seeing foo with payload [:]
    Received foo with payload [:]
    I say Hello!

原因是，现在，由于 SayHandler 在不调用 super 的情况下使用消息，因此不再调用日志记录处理程序。

#### Trait 内 super 的语义

如果一个类实现了多个特质并且发现了对 super 的调用，则：

1.  如果该类实现了另一个特质，则调用将委托给链中的下一个特质

2.  如果链中没有剩余的特质了，则 super 引用实现类的超类（this）

例如，由于以下行为，可以装饰最终类：

    trait Filtering {                                       
        StringBuilder append(String str) {                  
            def subst = str.replace('o','')                 
            super.append(subst)                             
        }
        String toString() { super.toString() }              
    }
    def sb = new StringBuilder().withTraits Filtering       
    sb.append('Groovy')
    assert sb.toString() == 'Grvy'                          

-   定义一个名为 Filtering 的特质，应该在运行时应用于 StringBuilder

-   重新定义 append 方法

-   删除字符串中的所有"o"

-   然后委托给 super

-   如果调用 toString ，则委托给 super.toString

-   StringBuilder 实例上 Filtering 特质的运行时实现

-   已附加的字符串不再包含字母 o

在这个例子中，当遇到 super.append 时，目标对象没有实现其他trait，所以调用的方法是原来的 append 方法，也就是说来自 StringBuilder 。同样的技巧也用于 toString ，以便生成的代理对象的字符串表示形式委托给 StringBuilder 实例的 toString 。

### 高级功能

#### 与 Java 8 默认方法的差异

在 Java 8 中，接口可以具有default方法。如果一个类实现了一个接口并且没有重写该default方法，则会使用接口的default方法。特质与此类似，但有一个主要区别：**如果特质和父类上有相同的方法, 那么默认使用特质上的**.

如果您想覆盖已实现的方法的行为，此功能可用于以非常精确的方式组合行为。

为了说明这个概念，让我们从这个简单的例子开始：

    import groovy.test.GroovyTestCase
    import groovy.transform.CompileStatic
    import org.codehaus.groovy.control.CompilerConfiguration
    import org.codehaus.groovy.control.customizers.ASTTransformationCustomizer
    import org.codehaus.groovy.control.customizers.ImportCustomizer
    
    class SomeTest extends GroovyTestCase {
        def config
        def shell
    
        void setup() {
            config = new CompilerConfiguration()
            shell = new GroovyShell(config)
        }
        void testSomething() {
            assert shell.evaluate('1+1') == 2
        }
        void otherTest() { /* ... */ }
    }

在此示例中，我们创建一个简单的测试用例，它使用两个属性（config 和 shell）并在多个测试方法中使用这些属性。现在假设您想要测试相同的内容，但使用另一个不同的编译器配置。一种选择是创建 SomeTest 的子类：

    class AnotherTest extends SomeTest {
        void setup() {
            config = new CompilerConfiguration()
            config.addCompilationCustomizers( ... )
            shell = new GroovyShell(config)
        }
    }

它有效，但是如果您实际上有多个测试类，并且您想要测试所有这些测试类的新配置怎么办？然后你必须为每个测试类创建一个不同的子类：

    class YetAnotherTest extends SomeTest {
        void setup() {
            config = new CompilerConfiguration()
            config.addCompilationCustomizers( ... )
            shell = new GroovyShell(config)
        }
    }

然后你看到的是，两个测试的 setup 方法是相同的。那么，我们的办法就是创造一个特质：

    trait MyTestSupport {
        void setup() {
            config = new CompilerConfiguration()
            config.addCompilationCustomizers( new ASTTransformationCustomizer(CompileStatic) )
            shell = new GroovyShell(config)
        }
    }

然后在子类中使用它：

    class AnotherTest extends SomeTest implements MyTestSupport {}
    class YetAnotherTest extends SomeTest2 implements MyTestSupport {}
    ...

它将允许我们显着减少样板代码，并降低在我们决定更改设置代码时忘记更改设置代码的风险。**即使 setup 已经在父类中实现，由于测试类在其接口列表中声明了特质，因此默认使用特质中的行为**！

当您无法访问父类源代码时，此功能特别有用。它可用于模拟方法或强制子类中方法的特定实现。它允许您重构代码，将被覆盖的逻辑保留在单个特质中，并通过实现它来继承新的行为。当然，另一种方法是在您将使用新代码的每个地方重写该方法。

值得注意的是，如果您使用运行时特质，则特质中的方法始终优先于原始对象的方法：

    class Person {
        String name                                         
    }
    trait Bob {
        String getName() { 'Bob' }                          
    }
    
    def p = new Person(name: 'Alice')
    assert p.name == 'Alice'                                
    def p2 = p as Bob                                       
    assert p2.name == 'Bob'                                 

-   Person 类定义了 name 属性，该属性产生 getName 方法

-   Bob 是一个特质，它将 getName 定义为返回 Bob

-   默认对象将返回 Alice

-   p2 在运行时将 p 强制转换为 Bob

-   getName 返回 Bob，因为 getName 来自特质

Again, don't forget that dynamic trait coercion returns a distinct object which only implements the original interfaces, as well as the traits.

### 与 mixins 的区别

Mixins 在概念上存在一些差异，因为它们在 Groovy 中可用。请注意，我们谈论的是运行时 mixin，而不是 \@Mixin 注解，@Mixin 注解已被弃用。

首先，特质中定义的方法在字节码中可见：

-   在内部，该特质表示为一个接口（没有默认或静态方法）和几个辅助类

-   这意味着实现特质的对象有效地实现了接口

-   这些方法在 Java 中是可见的

-   它们与类型检查和静态编译兼容

相反，通过 mixin 添加的方法仅在运行时可见：

    class A { String methodFromA() { 'A' } }        
    class B { String methodFromB() { 'B' } }        
    A.metaClass.mixin B                             
    def o = new A()
    assert o.methodFromA() == 'A'                   
    assert o.methodFromB() == 'B'                   
    assert o instanceof A                           
    assert !(o instanceof B)                        

-   类 A 定义 methodFromA

-   类 B 定义 methodFromB

-   将B混入A中

-   我们可以调用 methodFromA

-   我们也可以调用 methodFromB

-   该对象是 A 的实例

-   但它不是 B 的实例

最后一点实际上非常重要，它说明了 mixin 比 Trait 具有优势的地方：实例不会被修改，因此如果您将某个类混合到另一个类中，则不会生成第三个类，and methods which respond to A will continue responding to A even if mixed in.

### 静态的方法、属性和字段

以下说明需谨慎。静态成员支持正在进行中，并且仍处于试验阶段。以下信息仅适用于 {groovyVersion}。

可以在特质中定义静态方法，但它有许多限制： \* 具有静态方法的特质无法进行静态编译或类型检查。所有静态方法、属性和字段都是动态访问的（这是 JVM 的限制）。 \* 静态方法不会出现在每个特质生成的接口中。 \* 该特质被视为实现类的模板，这意味着每个实现类将获得自己的静态方法、属性和字段。因此，在特质上声明的静态成员不属于 Trait ，而是属于其实现类。 \* You should typically not mix static and instance methods of the same signature. The normal rules for applying traits apply (including multiple inheritance conflict resolution). If the method chosen is static but some implemented trait has an instance variant, a compilation error will occur. If the method chosen is the instance variant, the static variant will be ignored (the behavior is similar to static methods in Java interfaces for this case). 通常不应混合具有相同签名的静态方法和实例方法。应用特质的正常规则适用（包括多重继承冲突解决）。如果选择的方法是静态的，但某些实现的特质具有实例变体，则会发生编译错误。如果选择的方法是实例变体，则静态变体将被忽略（在这种情况下，其行为类似于 Java 接口中的静态方法）。

让我们从一个简单的例子开始：

    trait TestHelper {
        public static boolean CALLED = false        
        static void init() {                        
            CALLED = true                           
        }
    }
    class Foo implements TestHelper {}
    Foo.init()                                      
    assert Foo.TestHelper__CALLED                   

-   静态字段在特质中声明

-   特质中还声明了一个静态方法

-   静态字段在特质内更新

-   静态方法 init 可供实现类使用

-   重新映射静态场以避免钻石问题

与往常一样，不建议使用公共字段。不管怎样，如果你想要这个，你必须明白下面的代码会失败：

    Foo.CALLED = true

因为特质本身没有定义静态字段 CALLED。同样，如果您有两个不同的实现类，则每个类都会获得一个不同的静态字段：

    class Bar implements TestHelper {}              
    class Baz implements TestHelper {}              
    Bar.init()                                      
    assert Bar.TestHelper__CALLED                   
    assert !Baz.TestHelper__CALLED                  

-   类 Bar 实现该特质

-   类 Baz 也实现了该特质

-   init 仅在 Bar 上调用

-   Bar 上的静态字段 CALLED 已更新

-   但 Baz 上的静态字段 CALLED 不是，因为它是不同的

### 状态继承的陷阱

我们已经看到特质是有状态的。特质可以定义字段或属性，但是当类实现特质时，它会根据每个特质获取这些字段/属性。因此，请考虑以下示例：

    trait IntCouple {
        int x = 1
        int y = 2
        int sum() { x+y }
    }

该特质定义了两个属性， x 和 y ，以及一个 sum 方法。现在让我们创建一个实现该特质的类：

    class BaseElem implements IntCouple {
        int f() { sum() }
    }
    def base = new BaseElem()
    assert base.f() == 3

调用 f 的结果是 3 ，因为 f 委托给特质中的 sum ，它具有状态。但如果我们改写这个呢？

    class Elem implements IntCouple {
        int x = 3                                       
        int y = 4                                       
        int f() { sum() }                               
    }
    def elem = new Elem()

-   覆盖属性 x

-   覆盖属性 y

-   从特质调用 sum

如果您调用 elem.f() ，预期输出是什么？其实是：

    assert elem.f() == 3

原因是 sum 方法访问特质的字段。因此它使用特质中定义的 x 和 y 值。如果您想使用实现类中的值，则需要使用 getter 和 setter 来取消引用字段，如下所示：

    trait IntCouple {
        int x = 1
        int y = 2
        int sum() { getX()+getY() }
    }
    
    class Elem implements IntCouple {
        int x = 3
        int y = 4
        int f() { sum() }
    }
    def elem = new Elem()
    assert elem.f() == 7

### Self types

#### 特质的类型限制

有时您会想编写一个只能应用于某种类型的特质。例如，您可能希望在一个类上应用一个特质，该特质扩展了另一个超出您控制范围的类，并且仍然能够调用这些方法。为了说明这一点，让我们从这个例子开始：

    class CommunicationService {
        static void sendMessage(String from, String to, String message) {       
            println "$from sent [$message] to $to"
        }
    }
    
    class Device { String id }                                                  
    
    trait Communicating {
        void sendMessage(Device to, String message) {
            CommunicationService.sendMessage(id, to.id, message)                
        }
    }
    
    class MyDevice extends Device implements Communicating {}                   
    
    def bob = new MyDevice(id:'Bob')
    def alice = new MyDevice(id:'Alice')
    bob.sendMessage(alice,'secret')                                             

-   A `Service` class, beyond your control (in a library, ...​) defines a `sendMessage` method

-   A `Device` class, beyond your control (in a library, ...​)

-   Defines a communicating trait for devices that can call the service

-   Defines `MyDevice` as a communicating device

-   The method from the trait is called, and `id` is resolved

很明显， Communicating 特质只能应用于 Device 。然而，没有明确的契约表明这一点，因为特质不能扩展类。然而，代码编译并运行得很好，因为特质方法中的 id 将被动态解析。问题是没有什么可以阻止该特质应用于任何不是 Device 的类。任何具有 id 属性的类都可以工作，而任何不具有 id 属性的类都会导致运行时错误。

如果您想启用类型检查或在特质上应用 \@CompileStatic ，问题会更加复杂：因为特质不知道自己是 Device ，类型检查器会抱怨说它找不到 id 属性。

一种可能性是在特质中显式添加 getId 方法，但这并不能解决所有问题。如果一个方法需要 this 作为参数，并且实际上要求它是 Device 该怎么办？

    class SecurityService {
        static void check(Device d) { if (d.id==null) throw new SecurityException() }
    }

如果您希望能够在特质中调用 this ，那么您将明确需要将 this 转换为 Device 。如果到处显式转换为 this ，这很快就会变得不可读。

#### @SelfType注解

为了使这个契约明确，并使类型检查器了解其自身的类型，Groovy 提供了一个 @SelfType 注解，它将：

-   让您声明实现此特质的类必须继承或实现的类型

-   如果不满足这些类型约束，则抛出编译时错误

因此，在前面的示例中，我们可以使用 \@groovy.transform.SelfType 注解来修复该特质：

    @SelfType(Device)
    @CompileStatic
    trait Communicating {
        void sendMessage(Device to, String message) {
            SecurityService.check(this)
            CommunicationService.sendMessage(id, to.id, message)
        }
    }

现在，如果您尝试在不是 Device 的类上实现此特质，则会出现编译时错误：

    class MyDevice implements Communicating {} // forgot to extend Device

错误将是：

    class 'MyDevice' implements trait 'Communicating' but does not extend self type class 'Device'

总之，自我类型是声明对特质的约束的有效方式，而不必直接在特质中声明契约或必须在各处使用强制转换，从而保持关注点的分离尽可能紧密。

#### 与 Sealed 注解（孵化中）的差异

Both `@Sealed` and `@SelfType` restrict classes which use a trait but in orthogonal ways. Consider the following example:

    interface HasHeight { double getHeight() }
    interface HasArea { double getArea() }
    
    @SelfType([HasHeight, HasArea])                       
    @Sealed(permittedSubclasses=[UnitCylinder,UnitCube])  
    trait HasVolume {
        double getVolume() { height * area }
    }
    
    final class UnitCube implements HasVolume, HasHeight, HasArea {
        // for the purposes of this example: h=1, w=1, l=1
        double height = 1d
        double area = 1d
    }
    
    final class UnitCylinder implements HasVolume, HasHeight, HasArea {
        // for the purposes of this example: h=1, diameter=1
        // radius=diameter/2, area=PI * r^2
        double height = 1d
        double area = Math.PI * 0.5d**2
    }
    
    assert new UnitCube().volume == 1d
    assert new UnitCylinder().volume == 0.7853981633974483d

-   All usages of the `HasVolume` trait must implement or extend both `HasHeight` and `HasArea`

-   Only `UnitCube` or `UnitCylinder` can use the trait

For the degenerate case where a single class implements a trait, e.g.:

    final class Foo implements FooTrait {}

Then, either:

    @SelfType(Foo)
    trait FooTrait {}

or:

    @Sealed(permittedSubclasses='Foo') 
    trait FooTrait {}

-   Or just `@Sealed` if `Foo` and `FooTrait` are in the same source file

could express this constraint. Generally, the former of these is preferred.

### 局限性

#### 与 AST 转换的兼容性

Traits 与 AST 转换不是正式兼容。其中一些（例如 \@CompileStatic ）将应用于特质本身（而不是实现类），而其他一些将应用于实现类和特质。绝对不能保证 AST 转换会像在常规类上一样在特质上运行，因此使用它需要您自担风险！

#### 前缀和后缀操作

在特质中，不允许使用前缀和后缀操作更新特质的字段：

    trait Counting {
        int x
        void inc() {
            x++                             
        }
        void dec() {
            --x                             
        }
    }
    class Counter implements Counting {}
    def c = new Counter()
    c.inc()

-   x 在特质中定义，不允许后缀增量

-   x 在特质中定义，不允许前缀递减

解决方法是使用 += 运算符。

你可以在特质中调用不存在的方法或者属性或者字段

如果子类中有这个方法, 那么会直接调用, 如果子类没有这个方法, 那么会调用子类中的`methodMissing`方法



特质中可以有public字段或者属性, 但是为了避免菱形问题, 在编译的时候会修改他们的名字

包中的所有点（ . ）都替换为下划线（ \_ ），最终名称包含双下划线。

因此，如果字段的类型为 String ，包的名称为 my.package ，特质的名称为 Foo ，字段的名称为 bar ，在实现类中，公共字段将显示为：

~~~groovy
String my_package_Foo__bar
~~~



## Record类

Groovy中的Record类与Java中的一致

~~~groovy
// 对属性自动生成getter/setter, toString, equals, hashcode
// 生成的getter方法与字段同名, 而不是getXXX的格式
record Message(String from, String to, String body) {
    
    // 如果对自动生成的方法不满意, 可以重写他
	String toString() {
        "Point3D[coords=$x,$y,$z]"
    }
} 
~~~

Record中可以使用泛型

~~~groovy
record Coord<T extends Number>(T v1, T v2){
    double distFromOrigin() { Math.sqrt(v1()**2 + v2()**2 as double) }
}
~~~



**Record中可以设置一个特殊的构造函数, 他没有括号, 通常用来对参数的校验**

~~~groovy
public record Warning(String message) {
    public Warning {
        Objects.requireNonNull(message)
        message = message.toUpperCase()
    }
}

def w = new Warning('Help')
~~~



### Groovy对Record类的增强



#### 参数默认值

~~~groovy
record ColoredPoint(int x, int y = 0, String color = 'white') {}

@TupleConstructor(defaultsMode=DefaultsMode.OFF) // 关闭参数默认值功能, 那么会将所有参数的默认值都去除
record ColoredPoint2(int x, int y, String color) {}

@TupleConstructor(defaultsMode=DefaultsMode.ON) // 强制给没有默认值的参数添加上默认值, 这样x就有一个默认值0
record ColoredPoint3(int x, int y = 0, String color = 'white') {}
~~~

#### 命名参数

groovy对record进行了增强, 可以使用命名参数

~~~groovy
record ColoredPoint(int x, int y = 0, String color = 'white') {}
new ColoredPoint(x: 5, y: 0)
~~~



#### 自定义toString

如果默认提供的toString()方法你不喜欢, 那么可以重写toString方法

或者使用@ToString注解来自定义toString方法

~~~groovy
import groovy.transform.ToString

@ToString(ignoreNulls=true, cache=true, includeNames=true,
          leftDelimiter='[', rightDelimiter=']', nameValueSeparator='=')
record Point(Integer x, Integer y, Integer z=null) { }
~~~

-   includeNames=true, 包含包名和类名, 默认为false

-   cache=true, 缓存toString的值, 因为我们不会改变Record中的值

-   ignoreNulls=true, 忽略null值



#### record中的特殊方法

~~~groovy
record Point(int x, int y, String color) { }

def p = new Point(100, 200, 'green')
def (x, y, c) = p.toList() // 获取所有属性的值
p.toMap() // 将record转换为map
p.size() // 获取属性的个数
p[1] // 获取第2个属性
~~~



#### clone

可以使用`@RecordOptions(copyWith=true)`来指定生成一个copyWith方法, 用于clone一个Record

属性的clone是浅克隆

~~~groovy
@RecordOptions(copyWith=true)
record Fruit(String name, double price) {}
def apple = new Fruit('Apple', 11.6)

def orange = apple.copyWith(name: 'Orange')
assert orange.toString() == 'Fruit[name=Orange, price=11.6]'
~~~



#### 深度不可变

与 Java 一样，Record默认是浅层不变性(所有字段都是final)

但是Groovy中提供了@Immutable注解, 他会对所有的可变数据类型进行复制, 来实现深度不可变

```groovy
@ImmutableProperties
record Shopping(List items) {}

def items = ['bread', 'milk']
def shop = new Shopping(items) // 对items进行复制, 内部保存的items无法被修改
items << 'chocolate'
assert shop.items() == ['bread', 'milk']
```



### 将Record转换为Tuple

~~~groovy
@RecordOptions(components=true)
record Point(int x, int y, String color) { }

def p1 = new Point(100, 200, 'green')
def (int x1, int y1, String c1) = p1.components() // 转换为tuple
~~~



## 密封类/接口/特质

如果一个类/接口/特质是密封的,  那么只允许特定的类实现/继承他们

~~~groovy
sealed interface ShapeI permits Circle,Square { } // 只允许Circle,Square继承ShapeI
final class Circle implements ShapeI { }
final class Square implements ShapeI { }
~~~

同时还可以使用注解来完成这个功能

~~~groovy
@Sealed(permittedSubclasses=[Circle,Square]) interface ShapeI { }
final class Circle implements ShapeI { }
final class Square implements ShapeI { }
~~~





## 枚举

你可以将一个字符串直接分配给枚举, 无需显式的 `as` 强制转换：

~~~groovy
enum State {
    up,
    down
}
State st = 'up' // 只能分配up/down


// 在switch中也可以使用
State switchState(State st) {
    switch (st) {
        case 'up':
            return State.down // 显式常量
        case 'down':
            return 'up' // 返回值的隐式强制转换
    }
}
~~~





# 闭包

Groovy 中的闭包是一个开放的、匿名的代码块，可以接受参数、返回值和分配给变量。

闭包可以引用在其周围范围内声明的变量。

与闭包的正式定义相反，Groovy 语言中的 `Closure` 还可以包含在其周围范围之外定义的自由变量。



### 定义闭包

~~~groovy
{ [closureParameters -> ] statements }
~~~

其中 `[closureParameters->]` 是可选的以逗号分隔的参数列表，这些参数类似于方法参数列表，并且这些参数可以是类型化的或非类型化的。

下面是一些合法的闭包定义:

```groovy
{ item++ }                                          

{ -> item++ }                                       

{ println it } // 闭包有一个隐式参数it

{ it -> println it }  

{ name -> println name }                            

{ String x, int y ->                                
    println "hey ${x} the value is ${y}"
}
```



### 闭包作为对象

闭包是 `groovy.lang.Closure` 类的实例，可以像任何其他变量一样分配给变量或字段，尽管它是一个代码块：

```groovy
def listener = { e -> println "Clicked on $e.source" }      
Closure callback = { println 'Done!' }                      
Closure<Boolean> isTextFile = { // 通过泛型指定闭包的返回值类型
    File it -> it.name.endsWith('.txt')                     
}
```



### 调用闭包

可以通过`()`或者`call()`方法来调用闭包

**闭包在调用的时候总是返回一个值**

    def code = { 123 }
    code()
    code.call()
    
    def isOdd = { int i -> i%2 != 0 }                           
    isOdd(3)                              
    isOdd.call(2) 



### 闭包的参数

#### 普通参数

闭包的参数定义与方法的参数定义一样:

1. 可以指定参数的类型, 表示只能接收特定类型的参数
2. 可以省略参数类型, 表示可以接收任何类型的参数
3. 参数可以有默认值

~~~groovy
def closureWithOneArg = { str -> str.toUpperCase() }
def closureWithOneArgAndExplicitType = { String str -> str.toUpperCase() }
def closureWithTwoArgsAndOptionalTypes = { a, int b -> a+b }
def closureWithTwoArgAndDefaultValue = { int a, int b=2 -> a+b }
~~~



#### 隐式参数

当闭包没有使用参数列表的时候, 闭包具有一个隐式参数`it`

~~~groovy
def greeting = { "Hello, $it!" }
// 等效于
def greeting = { it -> "Hello, $it!" }
~~~

如果你不想要这个隐式参数`it`,  那么可以使用`->`来声明一个空的参数列表

~~~groovy
def magicNumber = { -> 42 } // 不接受任何参数, 包括it
~~~



#### 可变参数

闭包与方法一样, 可以接收可变参数

~~~groovy
def concat1 = { String... args -> args.join('') }  
def concat2 = { String[] args -> args.join('') }  

def multiConcat = { int n, String... args ->                
    args.join('')*n
}
~~~



### 委托

闭包与Java中的lambda不同的一点是, 闭包中有委托这个概念

*更改委托* 或 *更改闭包的委托策略* 的能力使得在 Groovy 中设计漂亮的领域特定语言 (DSL) 成为可能。

#### owner, delegate 和 this

要理解delegate的概念，我们首先要解释一下闭包中 `this` 的含义。闭包实际上定义了 3 个不同的东西：

-   `this` 对应于定义闭包的 *封闭类*

-   `owner` 对应于定义闭包的 *封闭对象* ，可以是类，也可以是闭包

-   `delegate` 对应于第三方对象, 当闭包的调用者未定义时，方法调用或属性将被解析到 `delegate`。

#### 闭包中的this

闭包中的this对应于定义闭包的类, 在闭包中调用`getThisObject`等效于调用`this`

```groovy
class Enclosing {
    void run() { this } // 返回Enclosing实例
}
def a = new Enclosing()
assert  a.run() == a 

class EnclosedInInnerClass {
    class Inner {
        Closure cl = { this }   // 返回的是Inner实例 
    }
    void run() {
        def inner = new Inner()
        assert inner.cl() == inner                          
    }
}
class NestedClosures {
    void run() {
        def nestedClosures = {
            def cl = { this } // 返回NestedClosures的实例
            cl()
        }
        assert nestedClosures() == this                     
    }
}
```

#### 闭包的Owner属性

闭包的`owner`返回定义闭包的**类或者闭包**

```groovy
class Enclosing {
    void run() { this   } // 返回Enclosing实例
}
def a = new Enclosing()
assert  a.run() == a 


class EnclosedInInnerClass {
    class Inner {
        Closure cl = { owner } // 返回Inner实例
    }
    void run() {
        def inner = new Inner()
        assert inner.cl() == inner                           
    }
}
class NestedClosures {
    void run() {
        def nestedClosures = {
            // 因为闭包定义在nestedClosures中, 所以返回的owner是nestedClosures
            def cl = { owner }  
            cl()
        }
        assert nestedClosures() == nestedClosures            
    }
}
```



#### 闭包的Delegate

可以使用 `delegate` 属性或调用 `getDelegate` 方法来访问闭包的委托。

默认情况下，`delegate` 设置为 `owner `

```groovy
class Enclosing {
    void run() {
        def cl = { getDelegate() } // 返回委托, 默认是owner, 即Enclosing实例
        def cl2 = { delegate }    
        assert cl() == cl2()  
        assert cl() == this  
        
        
        def enclosed = {
            { -> delegate }.call() // 因为这个闭包定义在闭包中, 所以owner是enclosed
        }
        assert enclosed() == enclosed                       
    }
}
```



可以将闭包的`delegate`设置为`任何对象`

闭包的委托可以更改为 **任何对象**。让我们通过创建两个类来说明这一点，这两个类不是彼此的子类，但都定义了一个名为 `name` 的属性：

```groovy
class Person {
    String name
}
class Thing {
    String name
}
def upperCasedName = { delegate.name.toUpperCase() }

def p = new Person(name: 'Norman')
def t = new Thing(name: 'Teapot')

upperCasedName.delegate = p
assert upperCasedName() == 'NORMAN'
upperCasedName.delegate = t
assert upperCasedName() == 'TEAPOT'
```



#### 委托策略

在闭包中, 如果调用没有定义的变量或者方法, 那么他会根据委托策略来进行查找

默认的委托策略是`Closure.OWNER_FIRST`: 先查找owner, 没有就查找delegate

```groovy
class Person {
    String name
}
def p = new Person(name:'Igor')
def cl = { name.toUpperCase() } // name在闭包中没有定义, 从delegate上查找                
cl.delegate = p                                 
assert cl() == 'IGOR'  
```

闭包实际上定义了多种您可以选择的解决策略：

-   `Closure.OWNER_FIRST` 是 **默认策略**。先查找owner, 没有就查找delegate

-   `Closure.DELEGATE_FIRST` : 先查找delegate, 没有就查找owner

-   `Closure.OWNER_ONLY` 只会解析 **owner** 的属性/方法查找, **delegate** 将被忽略。

-   `Closure.DELEGATE_ONLY` 将仅解析 **delegate** 上的属性/方法查找： **owner** 将被忽略。

-   `Closure.TO_SELF` 可供需要高级元编程技术并希望实现自定义解析策略的开发人员使用：解析不会针对 `owner` 或 `delegate` 进行，而仅针对闭包类本身进行。仅当您实现自己的 `Closure` 子类时才有意义。

让我们用以下代码来说明默认的"owner first"策略：

```groovy
class Person {
    String name
    def pretty = { "My name is $name" } // 定义一个闭包, 使用了未定义的name
    String toString() {
        pretty()
    }
}
class Thing {
    String name                                     
}

def p = new Person(name: 'Sarah')
def t = new Thing(name: 'Teapot')

assert p.toString() == 'My name is Sarah' // 先从owner上查找, owner就是p
p.pretty.delegate = t                               
assert p.toString() == 'My name is Sarah' // 先从owner上查找, owner是p
```



然而，可以改变闭包的解析策略：

    p.pretty.resolveStrategy = Closure.DELEGATE_FIRST // 将委托策略设置为delegate first
    assert p.toString() == 'My name is Teapot' // 先查找delegate

#### 委托策略与propertyMissing/methodMissing

上面我们说到, 委托策略`Closure.OWNER_FIRST` 和`Closure.DELEGATE_FIRST` 会查找owner和delegate

与其说查找, 不如说处理, 这意味着对于 \"owner first\"，如果属性/方法存在于owner中，或者它具有 `propertyMissing/methodMissing` 钩子函数，则owner将处理成员访问。

```groovy
class Person {
    String name
    int age
    def fetchAge = { age }
}
class Thing {
    String name
    def propertyMissing(String name) { -1 }
}

def p = new Person(name:'Jessica', age:42)
def t = new Thing(name:'Printer')
def cl = p.fetchAge
cl.resolveStrategy = Closure.DELEGATE_FIRST
cl.delegate = p
assert cl() == 42
cl.delegate = t
assert cl() == -1
```



### 闭包的强制类型转换

如果一个抽象类/特质/接口只有一个抽象方法, 那么可以使用闭包来创建他的子类并实例化

~~~groovy
abstract class Say{
    abstract say()
}

def s = {"hello"} // 创建一个Say的子类, 并实例化他
~~~





# 函数式编程



## 柯里化

柯里化表示部分应用,  在Groovy中只能对闭包使用柯里化, 而不能对函数进行柯里化

~~~groovy
def add = { a, b, c ->
    a + b + c
}

def lcurry = add.curry(1) // 左柯里化, 即设置左边的参数
assert add(1,2, 3) == lcurry(2, 3)

def rcurry = add.rcurry(2) // 右柯里化, 即设置右边的参数
assert add(1,2, 2) == rcurry(1, 2)

def ncurry = add.ncurry(1, 2, 2) // 从第2个参数开始, 设置第2, 3个参数为2
assert add(4, 2, 2) == ncurry(4)
~~~



## 闭包组合

闭包组合可以将多个闭包组合为一个新的闭包

闭包组合类似于链式调用

```groovy
def plus2  = { it + 2 }
def times3 = { it * 3 }

def times3plus2 = plus2 << times3 // 闭包组合
assert times3plus2(4) == plus2(times3(4))

// 反向组合, 等效于times3(plus2(3))
assert times3plus2(3) == (times3 >> plus2)(3)
```



## 方法指针

在 Groovy 中，您可以使用[方法指针操作符](core-operators.html#method-pointer-operator)从任何方法获取闭包。

所以如果你想要对一个函数进行柯里化, 但是Groovy中函数不能应用柯里化

那么你可以通过方法指针将函数转换为闭包, 然后进行柯里化

~~~groovy
// def add = { a, b, c ->
//     a + b + c
// }

def add1 (a, b, c) {
    a + b + c
}

add = this.&add1

def lcurry = add.curry(1) // 左柯里化, 即设置左边的参数
assert add(1,2, 3) == lcurry(2, 3)

def rcurry = add.rcurry(2) // 右柯里化, 即设置右边的参数
assert add(1,2, 2) == rcurry(1, 2)

def ncurry = add.ncurry(1, 2, 2) // 从第2个参数开始, 设置第2, 3个参数为2
assert add(4, 2, 2) == ncurry(4)
~~~





# 脚本

如果一个groovy文件, 有任何不在类或者函数中的代码, 那么会被认为是一个脚本

脚本实际上是一个继承了`groovy.lang.Script`的类,  类名与文件名相同



## Script类

Groovy 编译器会将脚本编译为一个继承了`groovy.lang.Script`的类，并将脚本主体复制到 `run` 方法中。

```groovy
// Main.groovy
println 'Groovy world!'


// 编译后
import org.codehaus.groovy.runtime.InvokerHelper
class Main extends Script {                    
    def run() {   
        // 脚本的主体代码
        println 'Groovy world!'                 
    }
    static void main(String[] args) {  
        // 执行run方法
        InvokerHelper.runScript(Main, args)     
    }
}
```



### 方法

可以在脚本中定义方法和语句

```groovy
println 'Hello' // 使用语句                                

int power(int n) { 2**n }  // 定义方法

println "2^6==${power(6)}" // 使用语句
```

方法会被赋值到脚本类中, 因此上面脚本编译后如下

```groovy
import org.codehaus.groovy.runtime.InvokerHelper
class Main extends Script {
    int power(int n) { 2** n} // 方法被单独抽取出来
    def run() {
        println 'Hello'   
        println "2^6==${power(6)}"  
    }
    static void main(String[] args) {
        InvokerHelper.runScript(Main, args)
    }
}
```



### 变量

脚本中可以定义变量

定义变量时, 可以添加变量类型, def, 或者什么也不加

```groovy
int x = 1 // 使用类型定义变量
def  y = 2 // 使用def定义变量

z = 3 // 直接定义变量
```

方式1,2或方式3的差异在于

+ 方式12定义的是 *局部变量* 。它将在编译器生成的 `run` 方法中声明，并且在脚本主体之外不可见。特别是，这样的变量在脚本的其他方法中将不可见

+ 使用方式3定义变量, 脚本将会从Binding对象查找该对象

  如果z在Binding对象中存在, 那么将其设置为3

  如果z不存在Binding中, 那么就新建这个变量

  **这通常用于脚本与应用程序数据共享**



### 变体

编译后的脚本会自动加上`public static void main`和`run`方法, 因此在默认情况下不能自己添加这两个方法

然而你可以在脚本中定义一个`static main`方法, 然后将所有语句放到这个main方法中, 来覆盖掉自动添加的main方法

~~~groovy
@CompileStatic
static main(args) { 
    // 将所有需要执行的代码放到这里
}

// main方法外部可以定义类和函数, 但是不能写任何可以执行的代码
int a = 1 // 这里会导致main方法变为普通方法, 而不是覆盖掉自动提供的main方法
~~~

如下格式也可以

~~~groovy
@CompileStatic
static main() { 
    // 将所有需要执行的代码放到这里
}

@CompileStatic
static main(String[] args) { 
    // 将所有需要执行的代码放到这里
}
~~~



从Groovy5开始, 可以覆盖自动提供的run方法, 只需要在脚本中定义一个无参的run方法, 然后将所有需要执行的代码放到run方法中即可

~~~groovy
def run() {
    // 所有需要执行的代码放到这里
}

// run方法外部可以定义类和函数, 但是不能写任何可以执行的代码
int a = 1 // 这里会导致run方法变为普通方法, 而不是覆盖掉自动提供的run方法
~~~



## Binding

Binding通常用于脚本与执行该脚本的应用程序进行数据共享

~~~groovy
def binding = new Binding()
def shell = new GroovyShell(binding)
binding.setVariable('x', 1)
binding.setVariable('y', 3)
shell.evaluate """
	def a = 2 // 定义一个局部变量
	b = 5 // 定义一个变量b, 然后设置到Binding中
	y = 4 // 将Binding中的y设置为4
	z = a*y*x // 定义一个变量z, 然后设置到Binding中
"""
println(binding.getVariable('z')) // 从Binding中获取变量z的值, 8
~~~



## 扩展Script类

Groovy运行自定义脚本的实现类, 只需要继承`groovy.lang.Script`类, 并设置为抽象类即可

~~~groovy
// 继承Script, 并设置为abstract
abstract class MyBaseClass extends Script {
    String name
    public void greet() { println "Hello, $name!" }
}
~~~

在执行脚本的时候, 设置脚本的实现类

~~~groovy
def config = new CompilerConfiguration()
config.scriptBaseClass = 'MyBaseClass' // 指定脚本的实现类

def shell = new GroovyShell(this.class.classLoader, config)
shell.evaluate """
    setName 'Judith'
    greet()
"""

~~~



还有一种方式是在脚本中添加`@BaseScript`注解

~~~groovy
import groovy.transform.BaseScript

@BaseScript(MyBaseClass) // 指定当前脚本的实现类

setName 'Judith'
greet()
~~~



## 可选的抽象方法

我们知道基类是一个单抽象方法类型，默认情况下需要实现 `run` 方法。`run` 方法由脚本引擎自动执行。在某些情况下，可能需要基类实现 `run` 方法，但提供一个替代的抽象方法供脚本体使用。例如，基类的 `run` 方法可能在执行脚本之前执行某些初始化。这可以通过如下方式实现：

```
abstract class MyBaseClass extends Script {
    int count
    abstract void scriptBody()
    def run() {
        count++
        scriptBody()
        count
    }
}
```

- 基类应该定义一个（且只能定义一个）抽象方法。
- `run` 方法可以被重写，并在执行脚本体之前执行任务。
- `run` 调用抽象的 `scriptBody` 方法，后者将委托给用户脚本。
- 然后可以返回除脚本值以外的其他内容。

如果执行以下代码：

```
def result = shell.evaluate """
    println 'Ok'
"""
assert result == 1
```

你会看到脚本被执行，但计算结果为 `1`，这是基类 `run` 方法返回的结果。如果使用 `parse` 而不是 `evaluate`，则可以多次执行 `run` 方法并获得不同的结果：

```
groovy复制代码def script = shell.parse("println 'Ok'")
assert script.run() == 1
assert script.run() == 2
```

# DSL

## 链式调用

在Groovy中对于方法的调用, 可以省略方法调用的括号

这种形式也适用于多个参数、闭包参数，甚至命名参数。此外，这种命令链还可以出现在赋值语句的右侧。

~~~groovy
// 等价于: turn(left).then(right)
turn left then right

// 等价于: take(2.pills).of(chloroquinine).after(6.hours)
take 2.pills of chloroquinine after 6.hours

// 等价于: paint(wall).with(red, green).and(yellow)
paint wall with red, green and yellow

// 也适用于命名参数
// 等价于: check(that: margarita).tastes(good)
check that: margarita tastes good

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// 带有闭包作为参数
// 等价于: given({}).when({}).then({})
given { } when { } then { }
~~~



如果函数没有参数, 那么必须添加上括号

```
// 等价于: select(all).unique().from(names)
select all unique() from names
```



如果命令链包含奇数个元素，那么链将由方法/参数组成，最后会以属性访问结束：

```groovy
// 等价于: take(3).cookies
// 也等价于: take(3).getCookies()
take 3 cookies
```



创建这种 DSL 有多种策略，以下是几个例子——首先使用 `map` 和 `闭包`：

```groovy
show = { println it }
square_root = { Math.sqrt(it) }

def please(action) {
  // 返回一个map, 其中有一个key为the, value为一个接受what参数的闭包
  [the: { what ->
    // 闭包返回一个map, 其中key为of, value为一个接受n参数的闭包  
    [of: { n -> action(what(n)) }]
  }]
}

// 等价于: please(show).the(square_root).of(100)
please show the square_root of 100
```

作为第二个例子，假设我们想为已有的 API 编写一个简化的 DSL。也许你需要将此代码展示给客户、业务分析师或测试人员，他们可能不是硬核 Java 开发者。我们将使用 Google [Guava 库](https://github.com/google/guava) 中的 `Splitter`，它本身已经有一个不错的流式 API。这里是如何直接使用它的示例：

```groovy
@Grab('com.google.guava:guava:r09')
import com.google.common.base.*
    
def result = Splitter.on(',').trimResults(CharMatcher.is('_' as char)).split("_a ,_b_ ,c__").iterator().toList()
```

对于 Java 开发者来说，这种写法还不错，但如果你的目标用户不是开发者，或者你有很多类似的语句要写，这可能会显得有些冗长。我们可以使用 `map` 和 `闭包` 来编写一个简单的 DSL。首先，编写一个辅助方法：

```groovy
@Grab('com.google.guava:guava:r09')
import com.google.common.base.*
def split(string) {
  [on: { sep ->
    [trimming: { trimChar ->
      Splitter.on(sep).trimResults(CharMatcher.is(trimChar as char)).split(string).iterator().toList()
    }]
  }]
}
```

现在我们可以用这种方式编写代码，而不是原始示例中的这行：

```groovy
def result = Splitter.on(',').trimResults(CharMatcher.is('_' as char)).split("_a ,_b_ ,c__").iterator().toList()
```

我们可以写成这样：

```groovy
def result = split "_a ,_b_ ,c__" on ',' trimming '_'
```



## DelegatesTo



### 为什么需要DelegatesTo

假设我们想要实现如下的DSL

~~~groovy
email {
    from 'dsl-guru@mycompany.com'
    to 'john.doe@waitaminute.com'
    subject 'The pope has resigned!'
    body {
        p 'Really, the pope has resigned!'
    }
}
~~~

我们可以这样实现

~~~groovy
class EmailSpec {
    void from(String from) { println "From: $from"}
    void to(String... to) { println "To: $to"}
    void subject(String subject) { println "Subject: $subject"}
    void body(Closure body) {
        // body也接受一个闭包, 并委托给BodySpec
        def bodySpec = new BodySpec()
        def code = body.rehydrate(bodySpec, this, this)
        code.resolveStrategy = Closure.DELEGATE_ONLY
        code()
    }
}

def email(Closure cl) {
    // EmailSpec实现了from, to, subject, body
    def email = new EmailSpec()
    
    // 复制cl创建一个新的闭包, 并设置闭包的delegate, owner, this
    // 即将闭包委托给email
    def code = cl.rehydrate(email, this, this)
    // 设置闭包的委托策略, 即只在委托上查找闭包中没有的属性和方法
    code.resolveStrategy = Closure.DELEGATE_ONLY
    code()
}
~~~



尽管上面的实现可以编写出想要的DSL, 但是有如下几个问题:

1. 首先，`email` 方法的使用者不知道在闭包中可以调用哪些方法，唯一可能的帮助是方法的文档

2. IDE 也无法提供智能提示。如果用户在闭包中调用了一个 `EmailSpec` 类中不存在的方法，IDE 也无法发出警告

3. 静态类型检测的不兼容

   类型检查可以帮助用户在编译时识别出哪些方法调用是被允许的，而不是在运行时才报错。尝试在这段代码上执行类型检查时，编译器将会因为无法识别 `from` 等方法而报错：

   ```groovy
   @groovy.transform.TypeChecked
   void sendEmail() {
       email {
           from 'dsl-guru@mycompany.com'
           to 'john.doe@waitaminute.com'
           subject 'The pope has resigned!'
           body {
               p 'Really, the pope has resigned!'
           }
       }
   }
   ```

为了解决上面的的问题, 可以使用`@Delegate`注解, 它的目的是解决文档和 IDE 提示问题，同时为类型检查器提供闭包中可能的方法接收者的提示信息。

~~~groovy
// 标注这个闭包委托给了EmailSpec, 这样就可以在闭包中调用EmailSpec中的方法和属性
// 告诉编译器委托的策略
def email(@DelegatesTo(strategy=Closure.DELEGATE_ONLY, value=EmailSpec) Closure cl) {
    def email = new EmailSpec()
    def code = cl.rehydrate(email, this, this)
    code.resolveStrategy = Closure.DELEGATE_ONLY
    code()
}
~~~



### @DelegatesTo 的参数

`@DelegatesTo` 支持多种模式，我们将在本节中通过示例进行描述。

#### 简单委托

此模式中，唯一的必填参数是 `value`，它指定要委托的类。闭包的 `delegate` 将始终为此类型：

```groovy
void body(@DelegatesTo(BodySpec) Closure cl) {
    // ...
}
```

#### 指定委托策略

在这种模式中，除了委托类，还必须指定委托策略，适用于闭包未使用默认的 `Closure.OWNER_FIRST` 策略的情况：

```groovy
void body(@DelegatesTo(strategy=Closure.DELEGATE_ONLY, value=BodySpec) Closure cl) {
    // ...
}
```

#### 委托给参数

```groovy
// 告诉编译器Closure委托给了target参数
def exec(@DelegatesTo.Target Object target, @DelegatesTo Closure code) {
   def clone = code.rehydrate(target, this, this)
   clone()
}
```



#### 多个闭包

当有多个闭包时, 我们可以这样

~~~groovy
class Foo { void foo(String msg) { println "Foo ${msg}!" } }
class Bar { void bar(int x) { println "Bar ${x}!" } }
class Baz { void baz(Date d) { println "Baz ${d}!" } }

void fooBarBaz(@DelegatesTo(Foo) Closure foo, @DelegatesTo(Bar) Closure bar, @DelegatesTo(Baz) Closure baz) {
   ...
}
~~~

~~~groovy
void fooBarBaz(
    @DelegatesTo.Target('foo') foo,
    @DelegatesTo.Target('bar') bar,
    @DelegatesTo.Target('baz') baz,

    @DelegatesTo(target='foo') Closure cl1,
    @DelegatesTo(target='bar') Closure cl2,
    @DelegatesTo(target='baz') Closure cl3) {
    cl1.rehydrate(foo, this, this).call()
    cl2.rehydrate(bar, this, this).call()
    cl3.rehydrate(baz, this, this).call()
}
~~~



#### 委托给泛型

有时，你可能想告诉 IDE 或编译器，委托类型是一个泛型类型而不是参数。想象一下，一个针对元素列表运行的配置器：

```groovy
public <T> void configure(
    @DelegatesTo.Target List<T> elements,
    // 指定委托给Target的第一个泛型
    @DelegatesTo(strategy=Closure.DELEGATE_FIRST, genericTypeIndex=0) Closure configuration) {
   def clone = configuration.rehydrate(e, this, this)
   clone.resolveStrategy = Closure.DELEGATE_FIRST
   clone.call()
}
```



#### 委托给任意类型

有时候, 需要委托的类型**根据就没有出现在参数列表**中, 那么你就无法使用上述的任意一种方式来指定委托类型

~~~groovy
class Mapper<T,U> {                             
    final T value                               
    Mapper(T value) { this.value = value }
    // 通过代码我们可以知道, 委托的类型是T, 但是T根据就没有出现在参数列表中
    // 那么我们就无法通过上述的任意一种方式来执行
    U map(Closure<U> producer) {                
        producer.delegate = value
        producer()
    }
}
~~~

那么你可以通过@DelegatesTo的type属性来指定任意类型

```groovy
class Mapper<T,U> {
    final T value
    Mapper(T value) { this.value = value }
    U map(@DelegatesTo(type="T") Closure<U> producer) {  
        producer.delegate = value
        producer()
    }
}
```





# 异常

## try / catch / finally

```groovy
try {
    1/0
} catch ( IOException | NullPointerException e ) {
    // 捕获多个类型的异常
} catch ( e ) { 
    // 捕获任何类型的异常
} finally{
    // 一定会执行
}
```



## try with resource

groovy支持java中的try with resource语法

~~~groovy
try(
    def file = new File() // 会自动调用close方法
) {
    
}catch (e) {
    
}
~~~





# 注解

### 定义注解

groovy中的注解与Java中的注解类似

~~~groovy
@interface SomeAnnotation {} // 定义注解
~~~



### 注解使用的位置

可以使用`java.lang.annotation.Target` 来指定注解可以使用的位置

如果没有指定, 那么任何位置都可以使用

~~~groovy
import java.lang.annotation.ElementType
import java.lang.annotation.Target

// 只能使用在类或者方法上
@Target([ElementType.METHOD, ElementType.TYPE])     
@interface SomeAnnotation {} 
~~~



### 注解的属性

注解的成员类型只能是

-   基础类型
-   java.lang.String
-   java.lang.Class
-   java.lang.Enum
-   另外一个注解类型
-   或者以上类型的数组

~~~groovy
@interface SomeAnnotation {
    String value() default 'something'      
}
@interface SomeAnnotation {
    int step()                              
}
@interface SomeAnnotation {
    Class appliesTo()                       
}
@interface SomeAnnotations {
    SomeAnnotation[] value()                
}
enum DayOfWeek { mon, tue, wed, thu, fri, sat, sun }
@interface Scheduled {
    DayOfWeek dayOfWeek()                   
}
~~~

如果注解没有默认值, 那么在使用注解的时候一定需要设置

~~~groovy
@interface Page {
    int statusCode()
}

@Page(statusCode=404)
void notFound() {
    // ...
}
~~~

如果 `value` 是唯一需要被设置的成员，则可以在注解值的声明中省略 `value=` 

~~~groovy
@interface Page {
    String value()
    int statusCode() default 200
}
@Page('/users')                         
void userList() {
    // ...
}
~~~



### 保留策略

可以使用`java.lang.annotation.Retention` 来定义注解的保留策略

~~~groovy
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy

// 只在源码阶段保留
@Retention(RetentionPolicy.SOURCE)                   
@interface SomeAnnotation {}    
~~~



### 闭包作为注解的值

如果一个注解的属性类型是Class, 那么他可以接收一个闭包作为参数

~~~groovy
@Retention(RetentionPolicy.RUNTIME)
@interface OnlyIf {
    Class value()                    
}

class Tasks {
    Set result = []
    void alwaysExecuted() {
        result << 1
    }
    @OnlyIf({ jdk>=7 && windows })
    void requiresJDK7AndWindows() {
        result << 'JDK 7 Windows'
    }
}

	// 这个方法用于解析Tasks上的OnlyIf中的闭包
	static <T> T run(Class<T> taskClass) {
        def tasks = taskClass.newInstance()                                         
        def params = [jdk: 6, windows: false]                                       
        tasks.class.declaredMethods.each { m ->                                     
            if (Modifier.isPublic(m.modifiers) && m.parameterTypes.length == 0) {   
                def onlyIf = m.getAnnotation(OnlyIf)                                
                if (onlyIf) {
                    Closure cl = onlyIf.value().newInstance(tasks,tasks)            
                    cl.delegate = params                                            
                    if (cl()) {                                                     
                        m.invoke(tasks)                                             
                    }
                } else {
                    m.invoke(tasks)                                                 
                }
            }
        }
        tasks                                                                       
    }
~~~



### 元注解

元注解，也称为注解别名，是 **在编译时被其他注解替换的注解**

~~~groovy
@Service                                        
@Transactional                                  
@AnnotationCollector // 表示定义元注解                            
@interface TransactionalService {}

@TransactionalService // 等效于同时使用@Service, @Transactional                       
class MyTransactionalService {}
~~~



元注解可以收集带有参数的注解, 同时还可以覆盖特定的值

~~~groovy
@Timeout(after=3600)
@Dangerous(type='explosive')
@AnnotationCollector // 定义元注解
public @interface Explosive {}

@Explosive // 等效于@Timeout(after=3600), @Dangerous(type='explosive')  
class MyTransactionalService {}

@Explosive(after=0) // 覆盖指定的值             
class Bomb {}
~~~



如果两个注解定义了相同的参数名称，则默认处理器会将注解值复制到所有接受该参数的注解

如果两个注解的相同参数, 但是他们的含义是不一样的, 那么可能需要使用@AnnotationCollector 注解的mode 参数

~~~groovy
public @interface Foo { String value()  }
public @interface Bar { String value() }

@Foo
@Bar
@AnnotationCollector
public @interface FooBar {} 

@FooBar('a')
class Joe {}                                        
assert Joe.getAnnotation(Foo).value() == 'a'        
println Joe.getAnnotation(Bar).value() == 'a'  
~~~



#### 自定义元注解处理器

自定义注解处理器将允许您选择如何将元注解转换为收集后的注解, 只需要

-   创建一个元注解处理器，扩展 org.codehaus.groovy.transform.AnnotationCollectorTransform
-   声明要在元注解声明中使用的处理器

详细过程百度



# 元编程

在 Groovy 中，默认情况下是动态类型的，代码在编译时不会进行严格的类型检查。

Groovy 可以在运行时可以动态修改类和对象的行为。因此，即使在代码中调用了不存在的方法或属性，编译器也不会报错，而是通过运行时元编程来处理。

```groovy
class Person {
    String firstName
    String lastName
}

def p = new Person(firstName: 'Raymond', lastName: 'Devos')
assert p.formattedName == 'Raymond Devos' // 编译时不会报错, 但是在运行时会报错
```

你可以在运行时通过元编程给 `Person` 类动态添加 `formattedName` 方法：

```groovy
Person.metaClass.getFormattedName = { "$delegate.firstName $delegate.lastName" }
```

如果你不想依赖于 Groovy 的动态特性，并希望在编译时就捕获类似的错误，你可以使用 `@TypeChecked` 注解来启用静态类型检查。这样，Groovy 就会在编译时检查类型和方法是否存在。

~~~groovy
import groovy.transform.TypeChecked
import groovy.transform.TypeCheckingMode

// GreetingService开启类型检查, 这会在编译的时候保证传入和返回的参数都是指定的类型
@TypeChecked
class GreetingService {
    // 会在编译时检查参数类型和返回值类型
    String greeting() {
        doGreet()
    }

    // 跳过类型检查
    @TypeChecked(TypeCheckingMode.SKIP)
    private String doGreet() {
        def b = new SentenceBuilder()
        b.Hello.my.name.is.John
        b
    }
}
~~~



# 语法糖

1. 如果至少有一个参数并且没有歧义，方法调用可以省略括号

   ~~~groovy
   println 'Hello World'
   def maximum = Math.max 5, 10
   
   println() // 没有参数, 方法调用必须加上()
   println(Math.max(5, 10)) // 有歧义, 不能省略
   ~~~

2. 一行的末尾可以省略分号

   ~~~groovy
   println 'Hello World'
   def maximum = Math.max 5, 10
   ~~~

3. 对于方法, 会自动return最后一个表达式的计算结果

   ~~~groovy
   int add(int a, int b) {
       a+b // 自动return
   }
   ~~~

4. Groovy 类和方法是 public, public可以省略

   ~~~groovy
   class Server { // 默认public
       String toString() { "a server" }
   }
   ~~~




# Groovy集成机制

// todo 没有看, 没时间翻译

The Groovy language proposes several ways to integrate itself into applications (Java or even Groovy) at runtime, from the most basic, simple code execution to the most complete, integrating caching and compiler customization.

All the examples written in this section are using Groovy, but the same integration mechanisms can be used from Java.

## Eval

The `groovy.util.Eval` class is the simplest way to execute Groovy dynamically at runtime. This can be done by calling the `me` method:

    import groovy.util.Eval
    
    assert Eval.me('33*3') == 99
    assert Eval.me('"foo".toUpperCase()') == 'FOO'

`Eval` supports multiple variants that accept parameters for simple evaluation:

    assert Eval.x(4, '2*x') == 8                
    assert Eval.me('k', 4, '2*k') == 8          
    assert Eval.xy(4, 5, 'x*y') == 20           
    assert Eval.xyz(4, 5, 6, 'x*y+z') == 26     

-   Simple evaluation with one bound parameter named `x`

-   Same evaluation, with a custom bound parameter named `k`

-   Simple evaluation with two bound parameters named `x` and `y`

-   Simple evaluation with three bound parameters named `x`, `y` and `z`

The `Eval` class makes it very easy to evaluate simple scripts, but doesn't scale: there is no caching of the script, and it isn't meant to evaluate more than one-liners.

## GroovyShell

### Multiple sources

The `groovy.lang.GroovyShell` class is the preferred way to evaluate scripts with the ability to cache the resulting script instance. Although the `Eval` class returns the result of the execution of the compiled script, the `GroovyShell` class offers more options.

    def shell = new GroovyShell()                           
    def result = shell.evaluate '3*5'                       
    def result2 = shell.evaluate(new StringReader('3*5'))   
    assert result == result2
    def script = shell.parse '3*5'                          
    assert script instanceof groovy.lang.Script
    assert script.run() == 15                               

-   create a new `GroovyShell` instance

-   can be used as `Eval` with direct execution of the code

-   can read from multiple sources (`String`, `Reader`, `File`, `InputStream`)

-   can defer execution of the script. `parse` returns a `Script` instance

-   `Script` defines a `run` method

### Sharing data between a script and the application

It is possible to share data between the application and the script using a `groovy.lang.Binding`:

    def sharedData = new Binding()                          
    def shell = new GroovyShell(sharedData)                 
    def now = new Date()
    sharedData.setProperty('text', 'I am shared data!')     
    sharedData.setProperty('date', now)                     
    
    String result = shell.evaluate('"At $date, $text"')     
    
    assert result == "At $now, I am shared data!"

-   create a new `Binding` that will contain shared data

-   create a `GroovyShell` using this shared data

-   add a string to the binding

-   add a date to the binding (you are not limited to simple types)

-   evaluate the script

Note that it is also possible to write from the script into the binding:

    def sharedData = new Binding()                          
    def shell = new GroovyShell(sharedData)                 
    
    shell.evaluate('foo=123')                               
    
    assert sharedData.getProperty('foo') == 123             

-   create a new `Binding` instance

-   create a new `GroovyShell` using that shared data

-   use an **undeclared** variable to store the result into the binding

-   read the result from the caller

It is important to understand that you need to use an undeclared variable if you want to write into the binding. Using `def` or an `explicit` type like in the example below would fail because you would then create a *local variable*:

    def sharedData = new Binding()
    def shell = new GroovyShell(sharedData)
    
    shell.evaluate('int foo=123')
    
    try {
        assert sharedData.getProperty('foo')
    } catch (MissingPropertyException e) {
        println "foo is defined as a local variable"
    }

You must be very careful when using shared data in a multithreaded environment. The `Binding` instance that you pass to `GroovyShell` is **not** thread safe, and shared by all scripts.

It is possible to work around the shared instance of `Binding` by leveraging the `Script` instance which is returned by `parse`:

    def shell = new GroovyShell()
    
    def b1 = new Binding(x:3)                       
    def b2 = new Binding(x:4)                       
    def script = shell.parse('x = 2*x')
    script.binding = b1
    script.run()
    script.binding = b2
    script.run()
    assert b1.getProperty('x') == 6
    assert b2.getProperty('x') == 8
    assert b1 != b2

-   will store the `x` variable inside `b1`

-   will store the `x` variable inside `b2`

However, you must be aware that you are still sharing the **same instance** of a script. So this technique cannot be used if you have two threads working on the same script. In that case, you must make sure of creating two distinct script instances:

    def shell = new GroovyShell()
    
    def b1 = new Binding(x:3)
    def b2 = new Binding(x:4)
    def script1 = shell.parse('x = 2*x')            
    def script2 = shell.parse('x = 2*x')            
    assert script1 != script2
    script1.binding = b1                            
    script2.binding = b2                            
    def t1 = Thread.start { script1.run() }         
    def t2 = Thread.start { script2.run() }         
    [t1,t2]*.join()                                 
    assert b1.getProperty('x') == 6
    assert b2.getProperty('x') == 8
    assert b1 != b2

-   create an instance of script for thread 1

-   create an instance of script for thread 2

-   assign first binding to script 1

-   assign second binding to script 2

-   start first script in a separate thread

-   start second script in a separate thread

-   wait for completion

In case you need thread safety like here, it is more advisable to use the [GroovyClassLoader](#groovyclassloader) directly instead.

### Custom script class

We have seen that the `parse` method returns an instance of `groovy.lang.Script`, but it is possible to use a custom class, given that it extends `Script` itself. It can be used to provide additional behavior to the script like in the example below:

    abstract class MyScript extends Script {
        String name
    
        String greet() {
            "Hello, $name!"
        }
    }

The custom class defines a property called `name` and a new method called `greet`. This class can be used as the script base class by using a custom configuration:

    import org.codehaus.groovy.control.CompilerConfiguration
    
    def config = new CompilerConfiguration()                                    
    config.scriptBaseClass = 'MyScript'                                         
    
    def shell = new GroovyShell(this.class.classLoader, new Binding(), config)  
    def script = shell.parse('greet()')                                         
    assert script instanceof MyScript
    script.setName('Michel')
    assert script.run() == 'Hello, Michel!'

-   create a `CompilerConfiguration` instance

-   instruct it to use `MyScript` as the base class for scripts

-   then use the compiler configuration when you create the shell

-   the script now has access to the new method `greet`

You are not limited to the sole *scriptBaseClass* configuration. You can use any of the compiler configuration tweaks, including the [compilation customizers](core-domain-specific-languages.xml#compilation-customizers).

## GroovyClassLoader

In the [previous section](#integ-groovyshell), we have shown that `GroovyShell` was an easy tool to execute scripts, but it makes it complicated to compile anything but scripts. Internally, it makes use of the `groovy.lang.GroovyClassLoader`, which is at the heart of the compilation and loading of classes at runtime.

By leveraging the `GroovyClassLoader` instead of `GroovyShell`, you will be able to load classes, instead of instances of scripts:

    import groovy.lang.GroovyClassLoader
    
    def gcl = new GroovyClassLoader()                                           
    def clazz = gcl.parseClass('class Foo { void doIt() { println "ok" } }')    
    assert clazz.name == 'Foo'                                                  
    def o = clazz.newInstance()                                                 
    o.doIt()                                                                    

-   create a new `GroovyClassLoader`

-   `parseClass` will return an instance of `Class`

-   you can check that the class which is returns is really the one defined in the script

-   and you can create a new instance of the class, which is not a script

-   then call any method on it

A GroovyClassLoader keeps a reference of all the classes it created, so it is easy to create a memory leak. In particular, if you execute the same script twice, if it is a String, then you obtain two distinct classes!

    import groovy.lang.GroovyClassLoader
    
    def gcl = new GroovyClassLoader()
    def clazz1 = gcl.parseClass('class Foo { }')                                
    def clazz2 = gcl.parseClass('class Foo { }')                                
    assert clazz1.name == 'Foo'                                                 
    assert clazz2.name == 'Foo'
    assert clazz1 != clazz2                                                     

-   dynamically create a class named \"Foo\"

-   create an identical looking class, using a separate `parseClass` call

-   make sure both classes have the same name

-   but they are actually different!

The reason is that a `GroovyClassLoader` doesn't keep track of the source text. If you want to have the same instance, then the source **must** be a file, like in this example:

    def gcl = new GroovyClassLoader()
    def clazz1 = gcl.parseClass(file)                                           
    def clazz2 = gcl.parseClass(new File(file.absolutePath))                    
    assert clazz1.name == 'Foo'                                                 
    assert clazz2.name == 'Foo'
    assert clazz1 == clazz2                                                     

-   parse a class from a `File`

-   parse a class from a distinct file instance, but pointing to the same physical file

-   make sure our classes have the same name

-   but now, they are the same instance

Using a `File` as input, the `GroovyClassLoader` is capable of **caching** the generated class file, which avoids creating multiple classes at runtime for the same source.

## GroovyScriptEngine

The `groovy.util.GroovyScriptEngine` class provides a flexible foundation for applications which rely on script reloading and script dependencies. While `GroovyShell` focuses on standalone `Script`s and `GroovyClassLoader` handles dynamic compilation and loading of any Groovy class, the `GroovyScriptEngine` will add a layer on top of `GroovyClassLoader` to handle both script dependencies and reloading.

To illustrate this, we will create a script engine and execute code in an infinite loop. First of all, you need to create a directory with the following script inside:

**ReloadingTest.groovy**

    class Greeter {
        String sayHello() {
            def greet = "Hello, world!"
            greet
        }
    }
    
    new Greeter()

then you can execute this code using a `GroovyScriptEngine`:

    def binding = new Binding()
    def engine = new GroovyScriptEngine([tmpDir.toURI().toURL()] as URL[])          
    
    while (true) {
        def greeter = engine.run('ReloadingTest.groovy', binding)                   
        println greeter.sayHello()                                                  
        Thread.sleep(1000)
    }

-   create a script engine which will look for sources into our source directory

-   execute the script, which will return an instance of `Greeter`

-   print the greeting message

At this point, you should see a message printed every second:

    Hello, world!
    Hello, world!
    ...

**Without** interrupting the script execution, now replace the contents of the `ReloadingTest` file with:

**ReloadingTest.groovy**

    class Greeter {
        String sayHello() {
            def greet = "Hello, Groovy!"
            greet
        }
    }
    
    new Greeter()

And the message should change to:

    Hello, world!
    ...
    Hello, Groovy!
    Hello, Groovy!
    ...

But it is also possible to have a dependency on another script. To illustrate this, create the following file into the same directory, without interrupting the executing script:

**Dependency.groovy**

    class Dependency {
        String message = 'Hello, dependency 1'
    }

and update the `ReloadingTest` script like this:

**ReloadingTest.groovy**

    import Dependency
    
    class Greeter {
        String sayHello() {
            def greet = new Dependency().message
            greet
        }
    }
    
    new Greeter()

And this time, the message should change to:

    Hello, Groovy!
    ...
    Hello, dependency 1!
    Hello, dependency 1!
    ...

And as a last test, you can update the `Dependency.groovy` file without touching the `ReloadingTest` file:

**Dependency.groovy**

    class Dependency {
        String message = 'Hello, dependency 2'
    }

And you should observe that the dependent file was reloaded:

    Hello, dependency 1!
    ...
    Hello, dependency 2!
    Hello, dependency 2!

## CompilationUnit

Ultimately, it is possible to perform more operations during compilation by relying directly on the `org.codehaus.groovy.control.CompilationUnit` class. This class is responsible for determining the various steps of compilation and would let you introduce new steps or even stop compilation at various phases. This is for example how stub generation is done, for the joint compiler.

However, overriding `CompilationUnit` is not recommended and should only be done if no other standard solution works.

Unresolved directive in guide-integrating.adoc - include::../../../subprojects/groovy-jsr223/src/spec/doc/\_integrating-jsr223.adoc\[leveloffset=+1\]



# todo

如果接口或者抽象类或者特质只有一个抽象方法, 那么可以直接将闭包转换为这个接口

~~~groovy
interface Predicate<T> {
    boolean accept(T obj)
}

Predicate filter = { it.contains 'G' } // 转换Predicate类型为并赋值
assert filter.accept('Groovy') == true

abstract class Greeter {
    abstract String getName()
    void greet() {
        println "Hello, $name"
    }
}
Greeter greeter = { 'Groovy' } // 转换为Greeter类型, 并赋值
~~~

同时也可以在传参的时候进行转换

~~~groovy
// 接受一个闭包
public <T> List<T> filter(List<T> source, Predicate<T> predicate) {
    source.findAll { predicate.accept(it) }
}
filter(['Java', 'Groovy'], { it.contains 'G'})
// 如果方法最后一个参数是闭包, 那么可以将他放到外面
filter(['Java', 'Groovy']){ it.contains 'G'}
~~~

你还可以使用`as`强制将闭包转换为接口或者类

~~~groovy
interface FooBar {
    int foo()
    void bar()
}
// 这会创建一个子类, 实现FooBar接口
// 然后创建这个子类的对象
def impl = { println 'ok'; 123 } as FooBar 
assert impl.foo() == 123
impl.bar()

class FooBar {
    int foo() { 1 }
    void bar() { println 'bar' }
}
// 这会创建一个子类, 使用闭包中的实现来重写父类的所有方法
// 然后创建这个子类的对象
def impl = { println 'ok'; 123 } as FooBar
assert impl.foo() == 123
impl.bar()
~~~



同时你还可以将map转换为对应的接口或者类,  map的key会被解释为方法的名称, 而值是方法的实现

map中的key必须和类中的属性名/方法名全部匹配

~~~groovy
def map
map = [
  i: 10,
  hasNext: { map.i > 0 },
  next: { map.i-- },
]
def iter = map as Iterator
~~~







