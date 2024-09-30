特质是groovy的结构构造，它允许：

-   行为的构成

-   接口的运行时实现

-   行为的重写

-   与静态类型检查/编译的兼容性

**它们可以被视为携带默认实现和状态的interface**。使用 trait 关键字定义特质：

    trait FlyingAbility {                           
            String fly() { "I'm flying!" }          
    }

-   特性的声明

-   特质内方法的声明

然后就可以像接口一样使用 `implements` 关键字来使用它：

    class Bird implements FlyingAbility {}          
    def b = new Bird()                              
    assert b.fly() == "I'm flying!"                 

-   将特质 FlyingAbility 添加到 Bird 类功能中

-   实例化一个新的 Bird

-   Bird 类自动获取 FlyingAbility 特质的行为

特质提供了广泛的功能，从简单的组合到测试，本节将对此进行详细描述。

# 方法

## Public 方法

在特质中声明方法可以像类中的常规方法一样：

    trait FlyingAbility {                           
            String fly() { "I'm flying!" }          
    }

-   特性的声明

-   特质内方法的声明

## Abstract methods

此外，特质也可以声明抽象方法，因此需要在实现特质的类中实现：

    trait Greetable {
        abstract String name()                              
        String greeting() { "Hello, ${name()}!" }           
    }

-   实现类必须声明 name 方法

-   可与具体方法进行混合

然后可以像这样使用该特质：

    class Person implements Greetable {                     
        String name() { 'Bob' }                             
    }
    
    def p = new Person()
    assert p.greeting() == 'Hello, Bob!'                    

-   实现特质 Greetable

-   由于 name 是抽象的，因此需要实现它

-   然后可以调用 greeting

## Private 方法

特质还可以定义私有方法。这些方法不会出现在实现特质的子类中：

    trait Greeter {
        private String greetingMessage() {                      
            'Hello from a private method!'
        }
        String greet() {
            def m = greetingMessage()                           
            println m
            m
        }
    }
    class GreetingMachine implements Greeter {}                 
    def g = new GreetingMachine()
    assert g.greet() == "Hello from a private method!"          
    try {
        assert g.greetingMessage()                              
    } catch (MissingMethodException e) {
        println "greetingMessage is private in trait"
    }

-   在特质中定义私有方法 greetingMessage

-   公共 greet 消息默认调用 greetingMessage

-   创建一个实现该特质的类

-   greet 可以被调用

-   但 greetingMessage 不行

特质仅支持 public 和 private 方法。 protected 和 `package private` 范围均不受支持。

## Final 方法

如果我们有一个实现特质的类，从概念上讲，特质方法的实现将"继承"到该类中。但实际上，不存在包含此类实现的基类。相反，它们直接融入课堂。方法的最终修饰符仅指示编织方法的修饰符。虽然继承和覆盖或乘以具有相同签名但混合了最终和非最终变体的继承方法可能被认为是不好的风格，但 Groovy 并不禁止这种情况。应用正常方法选择，并且所使用的修饰符将根据结果方法确定。如果您想要无法重写的特质实现方法，您可以考虑创建一个实现所需特质的基类。

If we have a class implementing a trait, conceptually implementations from the trait methods are \"inherited\" into the class. But, in reality, there is no base class containing such implementations. Rather, they are woven directly into the class. A final modifier on a method just indicates what the modifier will be for the woven method. While it would likely be considered bad style to inherit and override or multiply inherit methods with the same signature but a mix of final and non-final variants, Groovy doesn't prohibit this scenario. Normal method selection applies and the modifier used will be determined from the resulting method. You might consider creating a base class which implements the desired trait(s) if you want trait implementation methods that can't be overridden.

# this的含义

this 代表具体实现的实例。将特质视为一个父类。这意味着当你写：

    trait Introspector {
        def whoAmI() { this }
    }
    class Foo implements Introspector {}
    def foo = new Foo()

然后调用：

    foo.whoAmI()

将返回相同的实例：

    assert foo.whoAmI().is(foo)

# 接口

特质可以实现接口，在这种情况下，使用 `implements` 关键字声明接口：

    interface Named {                                       
        String name()
    }
    trait Greetable implements Named {                      
        String greeting() { "Hello, ${name()}!" }
    }
    class Person implements Greetable {                     
        String name() { 'Bob' }                             
    }
    
    def p = new Person()
    assert p.greeting() == 'Hello, Bob!'                    
    assert p instanceof Named                               
    assert p instanceof Greetable                           

-   普通接口的声明

-   将 Named 添加到已实现的接口列表中

-   声明一个实现 Greetable 特质的类

-   实现缺少的 name 方法

-   greeting 实现来自特质

-   确保 Person 实现 Named 接口

-   确保 Person 实现 Greetable 特质

# 属性

特质可以定义属性，如下例所示：

    trait Named {
        String name                             
    }
    class Person implements Named {}            
    def p = new Person(name: 'Bob')             
    assert p.name == 'Bob'                      
    assert p.getName() == 'Bob'                 

-   在特质中声明属性 name

-   声明一个实现该特质的类

-   该属性自动可见

-   可以使用属性访问器来访问它

-   或使用常规 getter 语法

# 字段

## Private字段

由于特质允许使用私有方法，因此使用私有字段来存储状态也很有趣。特质可以让你做到这一点：

    trait Counter {
        private int count = 0                   
        int count() { count += 1; count }       
    }
    class Foo implements Counter {}             
    def f = new Foo()
    assert f.count() == 1                       
    assert f.count() == 2

-   在特质中声明私有字段 count

-   声明一个公共方法 count 来增加计数器并返回它

-   声明一个实现 Counter 特质的类

-   count 方法可以使用私有字段来保存状态

这是与 Java 8 [Java 8 virtual extension methods](http://docs.oracle.com/javase/tutorial/java/IandI/defaultmethods.html)的一个主要区别。虽然虚拟扩展方法不携带状态，但特质可以。此外，从 Java 6 开始支持 Groovy 中的特质，因为它们的实现不依赖于虚拟扩展方法。这意味着即使一个特质可以从 Java 的角度视为常规接口，该接口也不会具有default方法，只有抽象方法。

## Public字段

公共字段的工作方式与私有字段相同，但为了避免http://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem\[菱形问题\]问题，字段名称在实现类中重新映射：

    trait Named {
        public String name                      
    }
    class Person implements Named {}            
    def p = new Person()                        
    p.Named__name = 'Bob'                       

-   在特质内声明一个公共字段

-   声明一个实现该特质的类

-   创建该类的一个实例

-   公共字段可用，但已重命名

字段的名称取决于特质的完全限定名称。包中的所有点（ . ）都替换为下划线（ \_ ），最终名称包含双下划线。因此，如果字段的类型为 String ，包的名称为 my.package ，特质的名称为 Foo ，字段的名称为 bar ，在实现类中，公共字段将显示为：

    String my_package_Foo__bar

虽然特质支持公共字段，但不建议使用它们，并被认为是一种不好的做法。

# 行为的组合

Traits 可用于实现多重继承。例如，我们可以具有以下特质：

    trait FlyingAbility {                           
            String fly() { "I'm flying!" }          
    }
    trait SpeakingAbility {
        String speak() { "I'm speaking!" }
    }

以及一个实现这两个特质的类：

    class Duck implements FlyingAbility, SpeakingAbility {} 
    
    def d = new Duck()                                      
    assert d.fly() == "I'm flying!"                         
    assert d.speak() == "I'm speaking!"                     

-   Duck 类同时实现 FlyingAbility 和 SpeakingAbility

-   创建 Duck 的新实例

-   我们可以从 FlyingAbility 调用方法 fly

-   还有 SpeakingAbility 中的方法 speak

特质鼓励对象之间重用功能，并通过现有行为的组合来创建新类。

# 重写default方法

特质提供方法的默认实现，但可以在实现类中重写它们。例如，我们可以稍微改变上面的例子，让鸭子嘎嘎叫：

    class Duck implements FlyingAbility, SpeakingAbility {
        String quack() { "Quack!" }                         
        String speak() { quack() }                          
    }
    
    def d = new Duck()
    assert d.fly() == "I'm flying!"                         
    assert d.quack() == "Quack!"                            
    assert d.speak() == "Quack!"                            

-   定义一个特定于 Duck 的方法，名为 quack

-   覆盖 speak 的默认实现，以便我们使用 quack 代替

-   鸭子仍然在飞

-   quack 来自 Duck 类

-   speak 不再使用 SpeakingAbility 中的默认实现

# 特质的继承

## 简单继承

特质可能会扩展另一个特质，在这种情况下，您必须使用 extends 关键字：

    trait Named {
        String name                                     
    }
    trait Polite extends Named {                        
        String introduce() { "Hello, I am $name" }      
    }
    class Person implements Polite {}
    def p = new Person(name: 'Alice')                   
    assert p.introduce() == 'Hello, I am Alice'         

-   Named 特质定义单个 name 属性

-   Polite 特性扩展了 Named 特性

-   Polite 添加了一个新方法，可以访问父特质的 name 属性

-   name 属性在实现 Polite 的 Person 类中可见

-   与 introduce 方法一样

## 多重继承

一个特质可以继承多个特质。在这种情况下，所有父特质都必须在 implements 子句中声明：

    trait WithId {                                      
        Long id
    }
    trait WithName {                                    
        String name
    }
    trait Identified implements WithId, WithName {}     

-   WithId 特质定义 id 属性

-   WithName 特质定义 name 属性

-   Identified 是继承 WithId 和 WithName 的特质

# 鸭子类型与特质

## 动态代码

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

## 特质中的动态方法

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

# 多重继承的冲突

## 默认冲突解决方案

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

## User conflict resolution

如果这种行为不是您想要的，您可以使用 Trait.super.foo 语法显式选择要调用的方法。在上面的示例中，我们可以通过编写以下内容来确保调用特质 A 中的方法：

    class C implements A,B {
        String exec() { A.super.exec() }    
    }
    def c = new C()
    assert c.exec() == 'A'                  

-   从特质 A 显式调用 exec

-   调用 A 中的版本，而不是使用默认的 B 中的版本

# 特质的运行时实现

## 在运行时实现特质

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

## 一次实现多个特质

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

# 链式行为

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

## Trait 内 super 的语义

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

# 高级功能

## SAM 类型强制

如果一个特质定义了单个抽象方法，那么它就是 SAM（单个抽象方法）类型强制的候选者。例如，想象一下以下特质：

    trait Greeter {
        String greet() { "Hello $name" }        
        abstract String getName()               
    }

-   greet 方法不是抽象方法，调用抽象方法 getName

-   getName 是一个抽象方法

由于 getName 是 Greeter 特质中的单个抽象方法，因此您可以编写：

    Greeter greeter = { 'Alice' }               

-   闭包"成为" getName 单个抽象方法的实现

or even:

    void greet(Greeter g) { println g.greet() } 
    greet { 'Alice' }                           

-   greet 方法接受 SAM 类型 Greeter 作为参数

-   我们可以直接调用它, 并传递闭包

## 与 Java 8 默认方法的差异

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

# 与 mixins 的区别

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

# 静态的方法、属性和字段

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

# 状态继承的陷阱

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

# Self types

## 特质的类型限制

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

## \@SelfType注解

为了使这个契约明确，并使类型检查器了解其自身的类型，Groovy 提供了一个 \@SelfType 注解，它将：

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

## 与 Sealed 注解（孵化中）的差异

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

# 局限性

## 与 AST 转换的兼容性

Traits 与 AST 转换不是正式兼容。其中一些（例如 \@CompileStatic ）将应用于特质本身（而不是实现类），而其他一些将应用于实现类和特质。绝对不能保证 AST 转换会像在常规类上一样在特质上运行，因此使用它需要您自担风险！

## 前缀和后缀操作

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
