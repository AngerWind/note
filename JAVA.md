## IO

核心类:5个类, 三个接口

![1555052887438](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1555052887438.png)

字节流: 按照字节读取数据

字符流: 按照字符读取数据, 因为文件编码不同, 从而有了对字符进行高效操作的字符流对象. 但是底层原理还是对字节流的操作, 自动搜寻了指定的字符集

File类: 文件和目录的路径名的抽象表示, 只表示路径名, 但是不保证文件存在.

java程序并不直接操作程序, 而是通过操作系统来操作程序

## 序列化

1. 序列化与解序列化一个类:

   ```java
   package com.sqt.javase.bean;
   
   import java.io.Serializable;
   
   //要想这个类能序列化, 必须实现这个接口,这个接口中没有任何方法,只是标记该类可以被序列化
   public class Car implements Serializable {
       String color ;
       String type;
       int id;
   
       public Car(String color, String type, int id) {
           this.color = color;
           this.type = type;
           this.id = id;
       }
   
       @Override
       public String toString() {
           return "Car{" +
                   "color='" + color + '\'' +
                   ", type='" + type + '\'' +
                   ", id=" + id +
                   '}';
       }
   }
   ```

   ````java
   //因为要将对象写到文中, 必须创建一个FileOutputStream
   FileOutputStream out = new FileOutputStream("D:\\myGame");
           ObjectOutputStream objectOutputStream = new ObjectOutputStream(out);
           objectOutputStream.writeObject(new Car("yellow", "big", 0));
           objectOutputStream.writeObject(new Car("red", "small", 1));
           objectOutputStream.close();
   
   //读取对象输出
           FileInputStream in = new FileInputStream("D:\\myGame");
           ObjectInputStream oi = new ObjectInputStream(in);
           Car yelloCar = (Car)oi.readObject();
           Car redCar = (Car)oi.readObject();
           System.out.println(yelloCar);
           System.out.println(redCar);
   ````

   ![1555073546530](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1555073546530.png)

   #### 序列化

   知识点:

   - 要想一个类能序列化, 必须实现Serializable接口,这个接口中没有任何方法,只是标记该类可以被序列化, 否则在调用writeObject()时会抛出异常

   - 当一个对象被序列化, 该对象的属性也会被序列化,并且所有被引用的对象也会被序列化

   - 静态的属性不会被序列化 在解序列化的时候, 这个静态属性会被还原成原本的(解序列化这个时候的)状态, 而不是存储时的状态(因为根本就不会存储那时的状态)

   - 整个对象都必须正确实例化, 否则全部失败. 上面Car中假如有People对象的引用, 那么People也要能够被序列化,因为car被序列化, people也会跟着序列化.

   - 如果某个实例变量不能或者不该序列化(如网络连接之类的东西要执行当场创建才有意义)要将该变量标记为transient.

     ```java
     public class Chat implements Serializable{
         public transient String currentID;
         public String userName;
     }
     ```

   - 当把某个对象反序列化的时候, transient修饰的对象变量会以null返回, 而基础类会以默认值返回

   - 如果两个对象中都有引用实例变量指向相同的一个对象, 例如两个Car类中都有同一个People的引用, 那么在存储着两个Car类的时候只会存储一个people.

   - 一段代码序列化两个对象, 两次运行这段代码, 序列化文件中不会存储四个对象, 而是两个, 也就是覆盖第一次运行结果.

   #### 解序列化

   - 当对象被解序列化的时候, jvm会尝试在堆上创建新的对象, 让他维持与被序列化时有相同的状态来恢复对象的原状, 但是这不包括transient的变量, 他们会以null(对象类型 )或者默认值(主数据类型)的状态恢复

   - 新的对象被配置在堆上, 但构造函数不会被调用.

   - 如果解序列化的类在继承树上有不可序列化的(自然也不可解序列化)的父类, 则该不可序列化的类及其以上的类的构造函数会被执行, 也就是说, 从第一个不可序列化的父类开始, 都会被调用构造函数, 回到初始状态.

   - 对序列化产生的文件进行反序列化不会改变文件内容

   #### serialVersionUID的作用(<http://swiftlet.net/archives/1268>)

   1. 简单来说，Java的序列化机制是通过判断类的serialVersionUID来验证版本一致性的。在进行反序列化时，JVM会把传来的字节流中的serialVersionUID与本地相应实体类的serialVersionUID进行比较，如果相同就认为是一致的，可以进行反序列化，否则就会出现序列化版本不一致的异常，即是InvalidCastException。

   2. serialVersionUID有两种显示的生成方式：        
      一是默认的1L，比如：private static final long serialVersionUID = 1L;        
      二是根据类名、接口名、成员方法及属性等来生成一个64位的哈希字段，比如：        
      private static final  long   serialVersionUID = xxxxL;

   3. 实现java.io.Serializable接口的类没有显式地定义一个serialVersionUID变量时候，Java序列化机制会根据编译的Class**自动生成一个serialVersionUID作序列化版本比较用**，这种情况下，如果Class文件(类名，方法明等)没有发生变化(增加空格，换行，增加注释等等)，就算再编译多次，serialVersionUID也不会变化的。

   4. 如果我们不希望通过编译来强制划分软件版本，即实现序列化接口的实体能够兼容先前版本，就需要显式地定义一个名为serialVersionUID，类型为long的变量，**不修改这个变量值的序列化实体都可以相互进行串行化和反串行化**。

   5. 序列化前后的版本增加减变量:

      - 假设两处serialVersionUID一致，如果A端增加一个字段，然后序列化，而B端不变，然后反序列化，会是什么情况呢?

        答:执行序列化，反序列化正常，但是A端增加的字段丢失(被B端忽略)

      - 假设两处serialVersionUID一致，如果B端减少一个字段，A端不变，会是什么情况呢?

        答:序列化，反序列化正常，B端字段少于A端，A端多的字段值丢失(被B端忽略)

      - 假设两处serialVersionUID一致，如果B端增加一个字段，A端不变，会是什么情况呢?

        答:序列化，反序列化正常，B端新增加的int字段被赋予了默认值0

      - 假设两处serialVersionUID一致，如果A端减少一个字段，B端不变，会是什么情况呢?

        答:序列化，反序列化正常，B端少于A端的int字段被赋予了默认值0
      **综上: B端多余A端的字段会以类型默认值被返回, 而B端少于A端的字段会被忽略.**
      

   

## 集合

#### Collection简单层次结构

![1555318470345](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1555318470345.png)

#### Collection

1. 集合中只能放对象的引用, 不能放基础类型,需要使用基础类型的包装类才能加到集合中

### List: 有序可重复的集合

1. 实现类: LinkList, Vector, ArrayList
2. 继承了Collection, 可以按照索引的顺序访问
3. 元素是按添加的先后顺序进行排列的
4. 运行重复的元素, 允许多个null元素
5. 因为有序, 所以除了iterator遍历还可以使用for循环遍历

#### ArrayList

1. 底层数据结构是数组, 随机访问快, 增加删除慢, 因为操作之后后序的元素需要移动,线程不安全, 效率高

#### Vector

1. 底层数据结构是数组, 随机访问快, 增加删除慢, 因为操作之后后序的元素需要移动, 线程安全, 效率低,几乎淘汰了这个集合

#### LinkedList

1. 底层数据结构是双向链表, 随机访问慢, 增加删除快, 线程不安全,效率高



#### Stack(栈): Vector的子类

1. 

#### 关于equals()和hashcode()的问题

​	在set中, 元素是不能重复的, 那么怎么定义一个元素是否重复呢? 那就是调用equals()方法, 如果返回true那么两者就是 重复的, false就是不重复的.

​	但是，如果每增加一个元素就检查一次，那么当元素很多时，后添加到集合中的元素比较的次数就非常多了。也就是说，如果集合中现在已经有1000个元素，那么第1001个元素加入集合时，它就要调用1000次equals方法。这显然会大大降低效率。

​	于是，Java采用了先判断hashcode再判断equals的办法。当集合要添加新的元素时，先调用这个元素的hashCode方法，就一下子能定位到它应该放置的物理位置上。如果这个位置上没有元素，它就可以直接存储在这个位置上，不用再进行任何比较了；如果这个位置上已经有元素了，就调用它的equals方法与新元素进行比较，相同的话就不存了，不相同就散列其它的地址。所以这里存在一个冲突解决的问题。这样一来实际调用equals方法的次数就大大降低了，几乎只需要一两次。 

​	简而言之，在集合查找时，hashcode能大大降低对象比较次数，提高查找效率！

Java对象的eqauls方法和hashCode方法是这样规定的：

**1、相等(相同)的对象必须具有相等的哈希码(或者散列码)。**

**2、如果两个对象的hashCode相同，它们并不一定相同。**

 以下是Object对象API关于equal方法和hashCode方法的说明：

- If two objects are equal according to the `equals(Object)` method, then calling the `hashCode` method on each of the two objects must produce the same integer result.
- It is *not* required that if two objects are unequal according to the [`equals(java.lang.Object)`](http://docs.oracle.com/javase/7/docs/api/java/lang/Object.html#equals(java.lang.Object)) method, then calling the `hashCode` method on each of the two objects must produce distinct integer results. However, the programmer should be aware that producing distinct integer results for unequal objects may improve the performance of hash tables.

**关于第一点，相等（相同）的对象必须具有相等的哈希码（或者散列码），为什么？**

 想象一下，假如两个Java对象A和B，A和B相等（eqauls结果为true），但A和B的哈希码不同，则A和B存入HashMap时的哈希码计算得到的HashMap内部数组位置索引可能不同，那么A和B很有可能允许同时存入HashMap，显然相等/相同的元素是不允许同时存入HashMap，HashMap不允许存放重复元素。

 

 **关于第二点，两个对象的hashCode相同，它们并不一定相同**

 也就是说，不同对象的hashCode可能相同；假如两个Java对象A和B，A和B不相等（eqauls结果为false），但A和B的哈希码相等，将A和B都存入HashMap时会发生哈希冲突，也就是A和B存放在HashMap内部数组的位置索引相同这时HashMap会在该位置建立一个链接表，将A和B串起来放在该位置，显然，该情况不违反HashMap的使用原则，是允许的。但是两个对象不想的, hashcode也不相等可以提高效率, 因为哈希冲突越少越好，尽量采用好的哈希算法以避免哈希冲突.

​	

### Set: 无序不可重复的集合

#### HashSet

1. 不能保证元素的顺序, 不可重复, 不是线程安全, 集合最多一个null
2. 底层是一个数组, 我们知道在一般的数组中，元素在数组中的索引位置是随机的，元素的取值和元素的位置之间不存在确定的关系，因此，在数组中查找特定的值时，需要把查找值和一系列的元素进行比较，此时的查询效率依赖于查找过程中比较的次数。而 HashSet 集合底层数组的索引和值有一个确定的关系：index=hash(value),那么只需要调用这个公式，就能快速的找到元素或者索引。
3. equals()相等的元素必须hashcode一样

#### LinkedHashSet

1. 不可以重复，有序, 非线程安全
2. 因为底层采用 链表和哈希表的算法。链表保证元素的添加顺序，哈希表保证元素的唯一性

#### TreeSet

1. 不可重复, 不能够存放null,不是线程安全

2. 不保证元素的添加顺序，但是**会对集合中的元素进行排序, compare返回负数代表小于, 正数表示大于, 0表示相等(不在添加), 小的排在前面, 大的排在后面**

3. 底层使用红黑色算法, 擅长用于范围查询

4. **通过对加入的元素进行比较, compare返回0表示相同, 相同的元素不在添加**

5. 排序规则: 

   - 元素自身具备比较性:

     元素自身具备比较性，需要元素实现Comparable接口，重写compareTo方法，也就是让元素自身具备比较性，这种方式叫做元素的自然排序也叫做默认排序.

     

   - 容器具备比较性: 

     当元素自身不具备比较性，或者自身具备的比较性不是所需要的。那么此时可以让容器自身具备。需要定义一个类实现接口Comparator，重写compare方法，并将该接口的子类实例对象作为参数传递给TreeMap集合的构造方法

     ````java
     class Person implements Comparable {
     	private String name;
     	private int age;
     	private String gender;
         //无参, 有参构造函数 
     	//Getter, Setter.....
         //toString.....
      
     	@Override
     	public int hashCode() {
     		return name.hashCode() + age * 37;
     	}
      
     	public boolean equals(Object obj) {
     		System.err.println(this + "equals :" + obj);
     		if (!(obj instanceof Person)) {
     			return false;
     		}
     		Person p = (Person) obj;
     		return this.name.equals(p.name) && this.age == p.age;
      
     	}
         
     	@Override
     	public int compareTo(Object obj) {
     		
     		Person p = (Person) obj;
     		System.out.println(this+" compareTo:"+p);
     		if (this.age > p.age) {
     			return 1;
     		}
     		if (this.age < p.age) {
     			return -1;
     		}
     		return this.name.compareTo(p.name);
     	}
     ````

     

   - 当Comparable比较方式和Comparator比较方式同时存在时，以Comparator的比较方式为主

     ```java
     class MyComparator implements Comparator {
      
     	public int compare(Object o1, Object o2) {
     		Book b1 = (Book) o1;
     		Book b2 = (Book) o2;
     		System.out.println(b1+" comparator "+b2);
     		if (b1.getPrice() > b2.getPrice()) {
     			return 1;
     		}
     		if (b1.getPrice() < b2.getPrice()) {
     			return -1;
     		}
     		return b1.getName().compareTo(b2.getName());
     	}
     }
     TreeSet ts = new TreeSet(new MyComparator());
     ```

     

### Map

#### HashMap

最常用的Map,它根据键的HashCode 值存储数据,根据键可以直接获取它的值，具有很快的访问速度。HashMap最多只允许一条记录的键为Null(多条会覆盖)。非同步的。

#### HashTable

与 HashMap类似,不同的是:key和value的值均不允许为null;它支持线程的同步，即任一时刻只有一个线程能写Hashtable,因此也导致了Hashtale在写入时会比较慢。

#### TreeMap

能够把它保存的记录根据键(key)排序,默认是按升序排序，也可以指定排序的比较器，当用Iterator 遍历TreeMap时，得到的记录是排过序的。TreeMap不允许key的值为null。非同步的。

#### LinkedHashMap

保存了记录的插入顺序，在用Iterator遍历LinkedHashMap时，先得到的记录肯定是先插入的.在遍历的时候会比HashMap慢。key和value均允许为空，非同步的。 

## [泛型](<https://blog.csdn.net/s10461/article/details/53941091>)

### 1. 概述

什么是泛型？为什么要使用泛型？

泛型，即**“参数化类型”**。一提到参数，最熟悉的就是定义方法时有形参，然后调用此方法时传递实参。那么参数化类型怎么理解呢？顾名思义，就是将类型由原来的具体的类型参数化，类似于方法中的变量参数，此时类型也定义成参数形式（可以称之为类型形参），然后在使用/调用时传入具体的类型（类型实参）。

泛型的本质是为了参数化类型（在不创建新的类型的情况下，通过泛型指定的不同类型来控制形参具体限制的类型）。也就是说在泛型使用过程中，操作的数据类型被指定为一个参数，这种参数类型可以用在类、接口和方法中，分别被称为泛型类、泛型接口、泛型方法。



一个被举了无数次的例子：

```java
List arrayList = new ArrayList();
arrayList.add("aaaa");
arrayList.add(100);

for(int i = 0; i< arrayList.size();i++){
    String item = (String)arrayList.get(i);
    Log.d("泛型测试","item = " + item);
}
```
毫无疑问，程序的运行结果会以崩溃结束：

```java
java.lang.ClassCastException: java.lang.Integer cannot be cast to java.lang.String
```


ArrayList可以存放任意类型，例子中添加了一个String类型，添加了一个Integer类型，再使用时都以String的方式使用，因此程序崩溃了。为了解决类似这样的问题（在编译阶段就可以解决），泛型应运而生。

我们将第一行声明初始化list的代码更改一下，编译器会在编译阶段就能够帮我们发现类似这样的问题。

List<String> arrayList = new ArrayList<String>();
...
//arrayList.add(100); 在编译阶段，编译器就会报错

### 2. 特性
泛型只在编译阶段有效。看下面的代码：

```java
List<String> stringArrayList = new ArrayList<String>();
List<Integer> integerArrayList = new ArrayList<Integer>();

Class classStringArrayList = stringArrayList.getClass();
Class classIntegerArrayList = integerArrayList.getClass();

System.out.println(classIntegerArrayList);
System.out.println(classStringArrayList);
if(classStringArrayList.equals(classIntegerArrayList)){
    System.out.println("相同");
}
```

![1555404395473](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1555404395473.png)

**通过上面的例子可以证明，在编译之后程序会采取去泛型化的措施。也就是说Java中的泛型，只在编译阶段有效。在编译过程中，正确检验泛型结果后，会将泛型的相关信息擦出，并且在对象进入和离开方法的边界处添加类型检查和类型转换的方法。也就是说，泛型信息不会进入到运行时阶段。**

对此总结成一句话：泛型类型在逻辑上看以看成是多个不同的类型，实际上都是相同的基本类型。

### 3. 泛型的使用

泛型有三种使用方式，分别为：泛型类、泛型接口、泛型方法

#### 3.1泛型类

泛型类型用于类的定义中，被称为泛型类。通过泛型可以完成对一组类的操作对外开放相同的接口。最典型的就是各种容器类，如：List、Set、Map。

泛型类的最基本写法（这么看可能会有点晕，会在下面的例子中详解）：

```java
class 类名称 <泛型标识：可以随便写任意标识号，标识指定的泛型的类型>{
  private 泛型标识 /*（成员变量类型）*/ var; 
  .....
  }
}
```
一个最普通的泛型类：
```java
//此处T可以随便写为任意标识，常见的如T、E、K、V等形式的参数常用于表示泛型
//在实例化泛型类时，必须指定T的具体类型
public class Generic<T>{ 
    //key这个成员变量的类型为T,T的类型由外部指定  
    private T key;

    //下面两个只是泛型类中的普通方法, 而不是泛型方法. 这个T类型和Generic<T>中的T相同
    public Generic(T key) { //构造方法形参key的类型也为T，T的类型由外部指定
        this.key = key;
    }
    
    public T getKey(){ //方法getKey的返回值类型为T，T的类型由外部指定
        return key;
    }
}
```

```java
//泛型的类型参数只能是类类型（包括自定义类），不能是简单类型
//传入的实参类型需与泛型的类型参数类型相同，即为Integer, 这是由构造参数决定的
Generic<Integer> genericInteger = new Generic<Integer>(123456);

//传入的实参类型需与泛型的类型参数类型相同，即为String.
Generic<String> genericString = new Generic<String>("key_vlaue");
genericInteger.getKey();
genericString.getKey();
```

定义的泛型类，就一定要传入泛型类型实参么？并不是这样，**在使用泛型的时候如果传入泛型实参，则会根据传入的泛型实参做相应的限制，此时泛型才会起到本应起到的限制作用。如果不传入泛型类型实参的话，在泛型类中使用泛型的方法或成员变量定义的类型可以为任何的类型。**

看一个例子：

```java
Generic generic = new Generic("111111");
Generic generic1 = new Generic(4444);
Generic generic2 = new Generic(55.55);
Generic generic3 = new Generic(false);
```


注意：

**泛型的类型参数只能是类类型，不能是简单类型。**
**不能对确切的泛型类型使用instanceof操作。如下面的操作是非法的，编译时会出错。**

```java
if(ex_num instanceof Generic<Number>){   
} 
```

#### 3.2 泛型接口

泛型接口与泛型类的定义及使用基本相同。泛型接口常被用在各种类的生产器中，可以看一个例子：

```java
//定义一个泛型接口
public interface Generator<T> {
    public T next();
}
```
当实现泛型接口的类，未传入泛型实参时：

```java
/**
 * 未传入泛型实参时，与泛型类的定义相同，在声明类的时候，需将泛型的声明也一起加到类中
 * 即：class FruitGenerator<T> implements Generator<T>{
 * 如果不声明泛型，如：class FruitGenerator implements Generator<T>，编译器会报错："Unknown class"
    */
    class FruitGenerator<T> implements Generator<T>{
    @Override
    public T next() {
        return null;
    }
    }
```
当实现泛型接口的类，传入泛型实参时：
```java
/**
 * 传入泛型实参时：
 * 定义一个生产器实现这个接口,虽然我们只创建了一个泛型接口Generator<T>
 * 但是我们可以为T传入无数个实参，形成无数种类型的Generator接口。
 * 在实现类实现泛型接口时，如已将泛型类型传入实参类型，则所有使用泛型的地方都要替换成传入的实参类型
 * 即：Generator<T>，public T next();中的的T都要替换成传入的String类型。
    */
    public class FruitGenerator implements Generator<String> {

    private String[] fruits = new String[]{"Apple", "Banana", "Pear"};

    @Override
    public String next() {
        Random rand = new Random();
        return fruits[rand.nextInt(3)];
    }
}
```
#### 3.3 泛型通配符

我们知道Ingeter是Number的一个子类，同时在前面我们也验证过Generic<Ingeter>与Generic<Number>实际上是相同的一种基本类型。那么问题来了，在使用Generic<Number>作为形参的方法中，能否使用Generic<Ingeter>的实例传入呢？**在逻辑上类似于Generic<Number>和Generic<Ingeter>是否可以看成具有父子关系的泛型类型呢？**

为了弄清楚这个问题，我们使用Generic<T>这个泛型类继续看下面的例子：

```java
public void showKeyValue(Generic<Number> obj){
    Log.d("泛型测试","key value is " + obj.getKey());
}

Generic<Integer> gInteger = new Generic<Integer>(123);
Generic<Number> gNumber = new Generic<Number>(456);

showKeyValue(gNumber);
// showKeyValue这个方法编译器会为我们报错：Generic<java.lang.Integer> 
// cannot be applied to Generic<java.lang.Number>
// showKeyValue(gInteger);
```

通过提示信息我们可以看到**Generic<Integer>不能被看作为`Generic<Number>的子类**。由此可以看出:同一种泛型可以对应多个版本（因为参数类型是不确定的），不同版本的泛型类实例是不兼容的。

回到上面的例子，如何解决上面的问题？总不能为了定义一个新的方法来处理Generic<Integer>类型的类，这显然与java中的多台理念相违背。因此我们需要一个在逻辑上可以表示同时是Generic<Integer>和Generic<Number>父类的引用类型。由此类型通配符应运而生。

我们可以将上面的方法改一下：

```java
public void showKeyValue(Generic<?> obj){
    System.out.println(obj.getT());
}
```

类型通配符一般是使用？代替具体的类型实参，注意了，此处’？’是类型实参，而不是类型形参 。重要说三遍！此处’？’是类型实参，而不是类型形参 ！ 此处’？’是类型实参，而不是类型形参 ！再直白点的意思就是，==**此处的？和Number、String、Integer一样都是一种实际的类型，可以把？看成所有类型的父类。是一种真实的类型。**==

可以解决当具体类型不确定的时候，这个通配符就是 ?  ；当操作类型时，不需要使用类型的具体功能时，只使用Object类中的功能。那么可以用 ? 通配符来表未知类型。

#### 3.4 泛型方法

在java中,泛型类的定义非常简单，但是泛型方法就比较复杂了。

尤其是我们见到的大多数泛型类中的成员方法也都使用了泛型，有的甚至泛型类中也包含着泛型方法，这样在初学者中非常容易将泛型方法理解错了。

泛型类，是在实例化类的时候指明泛型的具体类型；泛型方法，是在调用方法的时候指明泛型的具体类型 。
```java

/**
 * 泛型方法的基本介绍
 * @param tClass 传入的泛型实参
 * @return T 返回值为T类型
 * 说明：
 * 1）public 与 返回值中间<T>非常重要，可以理解为声明此方法为泛型方法。
 * 2）只有声明了<T>的方法才是泛型方法，泛型类中的使用了泛型的成员方法并不是泛型方法。
 * 3）<T>表明该方法将使用泛型类型T，此时才可以在方法中使用泛型类型T。
 * 4）与泛型类的定义一样，此处T可以随便写为任意标识，常见的如T、E、K、V等形式的参数常用于表示泛型。
   */
   public <T> T genericMethod(Class<T> tClass)throws InstantiationException ,
     IllegalAccessException{
    T instance = tClass.newInstance();
    return instance;
   }

   Object obj = genericMethod(Class.forName("com.test.test"));
```
1. 泛型方法的基本用法

   光看上面的例子有的同学可能依然会非常迷糊，我们再通过一个例子，把我泛型方法再总结一下。

```java
public class GenericTest {
   //这个类是个泛型类，在上面已经介绍过
   public class Generic<T>{     
        private T key;

        public Generic(T key) {
            this.key = key;
        }
    
        //我想说的其实是这个，虽然在方法中使用了泛型，但是这并不是一个泛型方法。
        //这只是类中一个普通的成员方法，只不过他的返回值是在声明泛型类已经声明过的泛型。
        //所以在这个方法中才可以继续使用 T 这个泛型。
        public T getKey(){
            return key;
        }
    
        /**
         * 这个方法显然是有问题的，在编译器会给我们提示这样的错误信息"cannot reslove symbol E"
         * 因为在类的声明中并未声明泛型E，所以在使用E做形参和返回值类型时，编译器会无法识别。
        public E setKey(E key){
             this.key = keu
        }
        */
    }
    
    /** 
     * 这才是一个真正的泛型方法。
     * 首先在public与返回值之间的<T>必不可少，这表明这是一个泛型方法，并且声明了一个泛型T
     * 这个T可以出现在这个泛型方法的任意位置.
     * 泛型的数量也可以为任意多个 
     *    如：public <T,K> K showKeyName(Generic<T> container){
     *        ...
     *        }
     */
    public <T> T showKeyName(Generic<T> container){
        System.out.println("container key :" + container.getKey());
        //当然这个例子举的不太合适，只是为了说明泛型方法的特性。
        T test = container.getKey();
        return test;
    }
    
    //这也不是一个泛型方法，这就是一个普通的方法，只是使用了Generic<Number>这个泛型类做形参而已。
    public void showKeyValue1(Generic<Number> obj){
        Log.d("泛型测试","key value is " + obj.getKey());
    }
    
    //这也不是一个泛型方法，这也是一个普通的方法，只不过使用了泛型通配符?
    //同时这也印证了泛型通配符章节所描述的，?是一种类型实参，可以看做为Number等所有类的父类
    public void showKeyValue2(Generic<?> obj){
        Log.d("泛型测试","key value is " + obj.getKey());
    }
    
     /**
     * 这个方法是有问题的，编译器会为我们提示错误信息："UnKnown class 'E' "
     * 虽然我们声明了<T>,也表明了这是一个可以处理泛型的类型的泛型方法。
     * 但是只声明了泛型类型T，并未声明泛型类型E，因此编译器并不知道该如何处理E这个类型。
    public <T> T showKeyName(Generic<E> container){
        ...
    }  
    */
    
    /**
     * 这个方法也是有问题的，编译器会为我们提示错误信息："UnKnown class 'T' "
     * 对于编译器来说T这个类型并未项目中声明过，因此编译也不知道该如何编译这个类。
     * 所以这也不是一个正确的泛型方法声明。
    public void showkey(T genericObj){
    
    }
    */
    
    public static void main(String[] args) {


    }
}
```
2. 泛型类中的泛型方法

   当然这并不是泛型方法的全部，泛型方法可以出现杂任何地方和任何场景中使用。但是有一种情况是非常特殊的，当泛型方法出现在泛型类中时，我们再通过一个例子看一下

```java
public class GenericFruit {
    class Fruit{
        @Override
        public String toString() {
            return "fruit";
        }
    }

    class Apple extends Fruit{
        @Override
        public String toString() {
            return "apple";
        }
    }
    
    class Person{
        @Override
        public String toString() {
            return "Person";
        }
    }
    
    class GenerateTest<T>{
        public void show_1(T t){
            System.out.println(t.toString());
        }
    
        //在泛型类中声明了一个泛型方法，使用泛型E，这种泛型E可以为任意类型。可以类型与T相同，也可以不同。
        //由于泛型方法在声明的时候会声明泛型<E>，因此即使在泛型类中并未声明泛型，编译器也能够正确识别泛型方法中识别的泛型。
        public <E> void show_3(E t){
            System.out.println(t.toString());
        }
    
        //在泛型类中声明了一个泛型方法，使用泛型T，注意这个T是一种全新的类型，可以与泛型类中声明的T不是同一种类型。
        public <T> void show_2(T t){
            System.out.println(t.toString());
        }
    }
    
    public static void main(String[] args) {
        Apple apple = new Apple();
        Person person = new Person();
    
        GenerateTest<Fruit> generateTest = new GenerateTest<Fruit>();
        //apple是Fruit的子类，所以这里可以
        generateTest.show_1(apple);
        //编译器会报错，因为泛型类型实参指定的是Fruit，而传入的实参类是Person
        //generateTest.show_1(person);
    
        //使用这两个方法都可以成功
        generateTest.show_2(apple);
        generateTest.show_2(person);
    
        //使用这两个方法也都可以成功
        generateTest.show_3(apple);
        generateTest.show_3(person);
    }
}
```

3. 泛型方法与可变参数

  再看一个泛型方法和可变参数的例子：
```java
public <T> void printMsg( T... args){
    for(T t : args){
        Log.d("泛型测试","t is " + t);
    }
}

printMsg("111",222,"aaaa","2323.4",55.55);
```
4. 静态方法与泛型
   静态方法有一种情况需要注意一下，那就是在类中的静态方法使用泛型：静态方法无法访问类上定义的泛型；如果静态方法操作的引用数据类型不确定的时候，必须要将泛型定义在方法上.

   即：如果静态方法要使用泛型的话，必须将静态方法也定义成泛型方法 。
```java
public class StaticGenerator<T> {
    ....
    ....
    /**
     * 如果在类中定义使用泛型的静态方法，需要添加额外的泛型声明（将这个方法定义成泛型方法）
     * 即使静态方法要使用泛型类中已经声明过的泛型也不可以。
     * 如：public static void show(T t){..},此时编译器会提示错误信息：
          "StaticGenerator cannot be refrenced from static context"
     */
    public static <T> void show(T t){

    }
}
```
5.  泛型方法总结

   泛型方法能使方法独立于类而产生变化，以下是一个基本的指导原则：

   无论何时，如果你能做到，你就该尽量使用泛型方法。也就是说，如果使用泛型方法将整个类泛型化，那么就应该使用泛型方法。另外对于一个static的方法而已，无法访问泛型类型的参数。所以如果static方法要使用泛型能力，就必须使其成为泛型方法。

### 4. 泛型上下边界

在使用泛型的时候，我们还可以为传入的泛型类型实参进行上下边界的限制，如：类型实参只准传入某种类型的子类。
为泛型类

限定上下界:

```java
public class Generic<T extends Number>{
    private T key;

    public Generic(T key) {
        this.key = key;
    }
    
    public T getKey(){
        return key;
    }
}
//这一行代码也会报错，因为String不是Number的子类
//Generic<String> generic1 = new Generic<String>("11111");
```
为泛型方法限定上下界:
```java
//泛型方法
public <T extends Fruit> T test(T t){
    return t;
}
//下面会报错, 因为People不是Fruit子类
//test(new People());
```

```java
//为泛型添加上边界，即传入的类型实参必须是指定类型的子类型
 public void showKeyValue(Generic<? extends Number> obj){
    Log.d("泛型测试","key value is " + obj.getKey());
}

Generic<String> generic1 = new Generic<String>("11111");
Generic<Integer> generic2 = new Generic<Integer>(2222);
Generic<Float> generic3 = new Generic<Float>(2.4f);
Generic<Double> generic4 = new Generic<Double>(2.56);

//这一行代码编译器会提示错误，因为String类型并不是Number类型的子类
//showKeyValue(generic1);

showKeyValue1(generic2);
showKeyValue1(generic3);
showKeyValue1(generic4);
```

再来一个泛型方法的例子：
```java
//在泛型方法中添加上下边界限制的时候，必须在权限声明与返回值之间的<T>上添加上下边界，即在泛型声明的时候添加
//public <T> T showKeyName(Generic<T extends Number> container)，编译器会报错："Unexpected bound"
public <T extends Number> T showKeyName(Generic<T> container){
    System.out.println("container key :" + container.getKey());
    T test = container.getKey();
    return test;
}
```
通过上面的两个例子可以看出：泛型的上下边界添加，必须与泛型的声明在一起 。

### 5. 泛型数组

看到了很多文章中都会提起泛型数组，经过查看sun的说明文档，在java中是”**不能创建一个确切的泛型类型的数组**”的。

也就是说下面的这个例子是不可以的：

```java
//List<String>[] ls = new ArrayList<String>[10];  
```

而使用通配符创建泛型数组是可以的，如下面这个例子：

```java
List<?>[] ls = new ArrayList<?>[10];  
List<String>[] ls = new ArrayList[10];
```

下面使用[Sun的一篇文档](<https://docs.oracle.com/javase/tutorial/extra/generics/fineprint.html>)的一个例子来说明这个问题：

```java
List<String>[] lsa = new List<String>[10]; // Not really allowed.    
Object o = lsa;    
Object[] oa = (Object[]) o;    
List<Integer> li = new ArrayList<Integer>();    
li.add(new Integer(3));    
oa[1] = li; // Unsound, but passes run time store check    
String s = lsa[1].get(0); // Run-time error: ClassCastException.
```

这种情况下，由于JVM泛型的擦除机制，在运行时JVM是不知道泛型信息的，所以可以给oa[1]赋上一个ArrayList而不会出现异常，但是在取出数据的时候却要做一次类型转换，所以就会出现ClassCastException，如果可以进行泛型数组的声明，上面说的这种情况在编译期将不会出现任何的警告和错误，只有在运行时才会出错。

而对泛型数组的声明进行限制，对于这样的情况，可以在编译期提示代码有类型安全问题，比没有任何提示要强很多。

下面采用通配符的方式是被允许的:数组的类型不可以是类型变量，除非是采用通配符的方式，因为对于通配符的方式，最后取出数据是要做显式的类型转换的。

```java
List<?>[] lsa = new List<?>[10]; // OK, array of unbounded wildcard type.    
Object o = lsa;    
Object[] oa = (Object[]) o;    
List<Integer> li = new ArrayList<Integer>();    
li.add(new Integer(3));    
oa[1] = li; // Correct.    
Integer i = (Integer) lsa[1].get(0); // OK 
```

### 6.对泛型上下界的应用

~~~~java
// 泛型对于extend的应用常常发生于确定了上界的时候
// 比如Map中的putAll（）方法
// 在这个方法中，上界在创建被调用map的实例的时候已经确定了， 这样通过？ extend K就可以限制传入的map的key的类型是泛型k的子类。
void putAll(Map<? extends K, ? extends V> m);
~~~~

~~~~java
// 泛型对于super的应用常常发生于确定了下界的时候
// 比如Collections的sout方法
// 在这个方法中，需要排序的目标类list的泛型T确定了下界，这样通过? super T就可以现在传入进来的Comparator的泛型是T的父类，这样Comparator才能正确处理list
    public static <T> void sort(List<T> list, Comparator<? super T> c) {
        list.sort(c);
    }

~~~~



## [深入理解java的clone](<https://www.iteye.com/topic/483469>)

#### 预备知识

为了理解java的clone，有必要先温习以下的知识。 

java的类型，java的类型分为两大类，一类为primitive，如int，另一类为引用类型,如String,Object等等。 

java引用类型的存储，java的引用类型都是存储在堆上的。 

````java
public class B {  
    int a;  
    String b;  
  
    public B(int a, String b) {  
        super();  
        this.a = a;  
        this.b = b;  
    }  
}  
````

对这样一个引用类型的实例，我们可以推测，在堆上它的内存存储形式（除去指向class的引用，锁的管理等等内务事务所占内存），应该有一个int值表示a,以及一个引用，该引用指向b在堆上的存储空间。 

#### 为什么要clone

有名的GoF设计模式里有一个模式为原型模式，用原型实例指定创建对象的种类,并且通过拷贝这些原型创建新的对象. 

简单的说就是clone一个对象实例。使得clone出来的copy和原有的对象一模一样。 

插一个简单使用clone的例子，如果一个对象内部有可变对象实例的话，public API不应该直接返回该对象的引用，以防调用方的code改变该对象的内部状态。这个时候可以返回该对象的clone。 

问题来了，什么叫一模一样。 

一般来说，有 

x.clone() != x 

x.clone().getClass() == x.getClass() 

x.clone().equals(x) 

但是这些都不是强制的。 

我们需要什么样的clone就搞出什么样的clone好了。 

一般而言，我们要的clone应该是这样的。copy和原型的内容一样，但是又是彼此隔离的。即在clone之后，改变其中一个不影响另外一个。 

#### Object的clone以及为什么如此实现

Object的clone的行为是最简单的。以堆上的内存存储解释的话（不计内务内存），对一个对象a的clone就是在堆上分配一个和a在堆上所占存储空间一样大的一块地方，然后把a的堆上内存的内容复制到这个新分配的内存空间上。

看例子。 

````java
class User {  
    String name;  
    int age;  
}  
  
class Account implements Cloneable {  
    User user;  
    long balance;  
  
    @Override  
    public Object clone() throws CloneNotSupportedException {  
        return super.clone();  
    }  
}  
````

````java
// user.  
User user = new User();  
user.name = "user";  
user.age = 20;  
// account.  
Account account = new Account();  
account.user = user;  
account.balance = 10000;  
// copy.  
Account copy = (Account) account.clone();  
  
// balance因为是primitive，所以copy和原型是相等且独立的。  
Assert.assertEquals(copy.balance, account.balance);  
copy.balance = 20000;  
// 改变copy不影响原型。  
Assert.assertTrue(copy.balance != account.balance);  
  
// user因为是引用类型，所以copy和原型的引用是同一的。  
Assert.assertTrue(copy.user == account.user);  
copy.user.name = "newName";  
// 改变的是同一个东西。  
Assert.assertEquals("newName", account.user.name);  
````

恩，默认实现是帮了我们一些忙，但是不是全部。 

primitive的确做到了相等且隔离。 

引用类型仅仅是复制了一下引用，copy和原型引用的东西是一样的。 

这个就是所谓的浅copy了。 

要实现深copy，即复制原型中对象的内存copy，而不仅仅是一个引用。只有自己动手了。 

等等，是不是所有的引用类型都需要深copy呢？ 

不是！ 

我们之所以要深copy，是因为默认的实现提供的浅copy不是隔离的，换言之，改变copy的东西，会影响到原型的内部。比如例子中，改变copy的user的name，影响了原型。 

如果我们要copy的类是不可变的呢，如String，没有方法可以改变它的内部状态呢。 

```java
class User implements Cloneable {  
    String name;  
    int age;  
  
    @Override  
    public Object clone() throws CloneNotSupportedException {  
        return super.clone();  
    }  
}  
```

```java
// user.  
User user = new User();  
user.name = "user";  
user.age = 20;  
  
// copy  
User copy = (User) user.clone();  
  
// age因为是primitive，所以copy和原型是相等且独立的。  
Assert.assertEquals(copy.age, user.age);  
copy.age = 30;  
// 改变copy不影响原型。  
Assert.assertTrue(copy.age != user.age);  
  
// name因为是引用类型，所以copy和原型的引用是同一的。  
Assert.assertTrue(copy.name == user.name);  
// String为不可变类。没有办法可以通过对copy.name的字符串的操作改变这个字符串。  
// 改变引用新的对象不会影响原型。  
copy.name = "newname";  
Assert.assertEquals("newname", copy.name);  
Assert.assertEquals("user", user.name);  
```

可见，在考虑clone时，primitive和不可变对象类型是可以同等对待的。 

java为什么如此实现clone呢？ 

也许有以下考虑。 

1 效率和简单性，简单的copy一个对象在堆上的的内存比遍历一个对象网然后内存深copy明显效率高并且简单。 

2 不给别的类强加意义。如果A实现了Cloneable，同时有一个引用指向B，如果直接复制内存进行深copy的话，意味着B在意义上也是支持Clone的，但是这个是在使用B的A中做的，B甚至都不知道。破坏了B原有的接口。 

3 有可能破坏语义。如果A实现了Cloneable，同时有一个引用指向B，该B实现为单例模式，如果直接复制内存进行深copy的话，破坏了B的单例模式。 

4 方便且更灵活，如果A引用一个不可变对象，则内存deep copy是一种浪费。Shadow copy给了程序员更好的灵活性。 

#### 如何clone

 clone三部曲。 

1 声明实现Cloneable接口。 

2 调用super.clone拿到一个对象，如果父类的clone实现没有问题的话，在该对象的内存存储中，所有父类定义的field都已经clone好了，该类中的primitive和不可变类型引用也克隆好了，可变类型引用都是浅copy。 

3 把浅copy的引用指向原型对象新的克隆体。 

给个例子。 

```java
class User implements Cloneable {  
    String name;  
    int age;  
  
    @Override  
    public User clone() throws CloneNotSupportedException {  
        return (User) super.clone();  
    }  
}  
  
class Account implements Cloneable {  
    User user;  
    long balance;  
  
    @Override  
    public Account clone() throws CloneNotSupportedException {  
        Account account = null;  
  
        account = (Account) super.clone();  
        if (user != null) {  
            account.user = user.clone();  
        }  
  
        return account;  
    }  
}  
```

#### 对clone的态度

 clone嘛，我觉得是个好东西，毕竟系统默认实现已经帮我们做了很多事情了。 

但是它也是有缺点的。 

1 手工维护clone的调用链。这个问题不大，程序员有责任做好。 

2 如果class的field是个final的可变类，就不行了。三部曲的第三步没有办法做了。 

考虑一个类对clone的态度，有如下几种。 

1 公开支持：好吧，按照clone三部曲实现吧。前提是父类支持（公开或者默默）。 

2 默默支持：不实现Cloneable接口，但是在类里面有正确的protected的clone实现，这样，该类不支持clone，但是它的子类如果想支持的话也不妨碍。 

3 不支持：好吧，为了明确该目的，提供一个抛CloneNotSupportedException 异常的protected的clone实现。 

4 看情况支持：该类内部可以保存其他类的实例，如果其他类支持则该类支持，如果其他类不支持，该类没有办法，只有不支持。 

#### 其他的选择

 可以用原型构造函数，或者静态copy方法来手工制作一个对象的copy。 

好处是即使class的field为final，也不会影响该方法的使用。不好的地方是所有的primitive赋值都得自己维护。 

#### 和Serializable的比较

 使用Serializable同样可以做到对象的clone。但是： 

Cloneable本身就是为clone设计的，虽然有一些缺点，但是如果它可以clone的话无疑用它来做clone比较合适。如果不行的话用原型构造函数，或者静态copy方法也可以。 

Serializable制作clone的话，添加了太多其它的东西，增加了复杂性。 

1 所有的相关的类都得支持Serializable。这个相比支持Cloneable只会工作量更大 

2 Serializable添加了更多的意义，除了提供一个方法用Serializable制作Clone，该类等于也添加了其它的public API，如果一个类实现了Serializable，等于它的2进制形式就已经是其API的一部分了，不便于该类以后内部的改动。 

3 当类用Serializable来实现clone时，用户如果保存了一个老版本的对象2进制，该类升级，用户用新版本的类反系列化该对象，再调用该对象用Serializable实现的clone。这里为了一个clone的方法又引入了类版本兼容性的问题。不划算。 

#### 性能

 不可否认，JVM越来越快了。 

但是系统默认的native实现还是挺快的。 

clone一个有100个元素的int数组，用系统默认的clone比静态copy方法快2倍左右。



## Java8

### lambda表达式、函数接口、方法引用、流、可选方法

### 接口中的静态方法和[默认方法](https://liushiming.cn/2020/02/23/java-default-methods/)。