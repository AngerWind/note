Record类是一种特殊的类，可用于对普通数据聚合进行建模。它们提供了比普通类更少的紧凑语法。 Groovy 已经具有 AST 转换，例如 \@Immutable 和 \@Canonical ，它们已经大大减少了仪式，但Record已经在 Java 中引入，并且 Groovy 中的Record类被设计为与 Java Record类保持一致。

例如，假设我们要创建代表电子邮件的 Message 的Record类。出于本示例的目的，我们将此类消息简化为仅包含发件人电子邮件地址、收件人电子邮件地址和消息正文。我们可以如下定义这样的Record类：

    record Message(String from, String to, String body) { }

我们将以与普通类相同的方式使用Record类，如下所示：

    def msg = new Message('me@myhost.com', 'you@yourhost.net', 'Hello!')
    assert msg.toString() == 'Message[from=me@myhost.com, to=you@yourhost.net, body=Hello!]'

简化的仪式使我们免于定义显式字段、getter 和 toString 、 equals 和 hashCode 方法。事实上，它是以下粗略等效的简写：

    final class Message extends Record {
        private final String from
        private final String to
        private final String body
        private static final long serialVersionUID = 0
    
        /* constructor(s) */
    
        final String toString() { /*...*/ }
    
        final boolean equals(Object other) { /*...*/ }
    
        final int hashCode() { /*...*/ }
    
        String from() { from }
        // other getters ...
    }

请注意Record类的getter的特殊命名约定。它们与字段同名（而不是常见的 JavaBean 惯例，大写并带有"get"前缀）。

就像在 Java 中一样，您可以通过编写自己的方法来覆盖通常隐式提供的方法：

    record Point3D(int x, int y, int z) {
        String toString() {
            "Point3D[coords=$x,$y,$z]"
        }
    }
    
    assert new Point3D(10, 20, 30).toString() == 'Point3D[coords=10,20,30]'

您还可以以正常方式对Record类使用泛型。例如，考虑以下 Coord Record类定义：

    record Coord<T extends Number>(T v1, T v2){
        double distFromOrigin() { Math.sqrt(v1()**2 + v2()**2 as double) }
    }

它可以按如下方式使用：

    def r1 = new Coord<Integer>(3, 4)
    assert r1.distFromOrigin() == 5
    def r2 = new Coord<Double>(6d, 2.5d)
    assert r2.distFromOrigin() == 6.5d

# Record类的特殊功能

## 紧凑的构造函数

记录有一个隐式构造函数。这可以通过提供您自己的构造函数来覆盖 - 如果您这样做，您需要确保设置所有字段。

然而，为了简洁起见，可以使用紧凑的构造函数语法。

对于这种特殊情况，仍然提供正常的隐式构造函数，但通过紧凑构造函数定义中提供的语句进行了扩充：

    public record Warning(String message) {
        public Warning {
            Objects.requireNonNull(message)
            message = message.toUpperCase()
        }
    }
    
    def w = new Warning('Help')
    assert w.message() == 'HELP'

## 序列化

Groovy native records类遵循适用于 Java record的可序列化性的https://docs.oracle.com/en/java/javase/16/docs/specs/records-serialization.html\[特殊约定\]。 Groovy record-like 的类（下面讨论）遵循普通的 Java 类可序列化约定。

Groovy *native* records follow the

for serializability which apply to Java records. Groovy *record-like* classes (discussed below) follow normal Java class serializability conventions.

# Groovy 对Record类的增强

## 参数默认值

Groovy 支持构造函数参数的默认值。此功能也适用于记录，如以下记录定义所示，该定义具有 y 和 color 的默认值：

    record ColoredPoint(int x, int y = 0, String color = 'white') {}

Arguments when left off (dropping one or more arguments from the right) are replaced with their defaults values as shown in the following example:

    assert new ColoredPoint(5, 5, 'black').toString() == 'ColoredPoint[x=5, y=5, color=black]'
    assert new ColoredPoint(5, 5).toString() == 'ColoredPoint[x=5, y=5, color=white]'
    assert new ColoredPoint(5).toString() == 'ColoredPoint[x=5, y=0, color=white]'

此处理遵循构造函数默认参数的常规 Groovy 约定，本质上自动为构造函数提供以下签名：

    ColoredPoint(int, int, String)
    ColoredPoint(int, int)
    ColoredPoint(int)

也可以使用命名参数（默认值也适用于此）：

    assert new ColoredPoint(x: 5).toString() == 'ColoredPoint[x=5, y=0, color=white]'
    assert new ColoredPoint(x: 0, y: 5).toString() == 'ColoredPoint[x=0, y=5, color=white]'

您可以禁用默认参数处理，如下所示：

    @TupleConstructor(defaultsMode=DefaultsMode.OFF)
    record ColoredPoint2(int x, int y, String color) {}
    assert new ColoredPoint2(4, 5, 'red').toString() == 'ColoredPoint2[x=4, y=5, color=red]'

这将按照 Java 的默认值生成一个构造函数。如果在这种情况下省略参数，将会出现错误。

您可以强制所有属性具有默认值，如下所示：

    @TupleConstructor(defaultsMode=DefaultsMode.ON)
    record ColoredPoint3(int x, int y = 0, String color = 'white') {}
    assert new ColoredPoint3(y: 5).toString() == 'ColoredPoint3[x=0, y=5, color=white]'

任何没有显式初始值的属性/字段都将被赋予参数类型的默认值（null，0, false）。

我们之前描述了 Message 记录并显示了它的粗略等效项。 Groovy 实际上会经历一个中间阶段，其中 record 关键字被 class 关键字和随附的 \@RecordType 注释替换：

    @RecordType
    class Message {
        String from
        String to
        String body
    }

然后，@RecordType 本身被处理为元注解（注解集合器），并扩展为其组成的子注解，如 \@TupleConstructor、@POJO、@RecordBase 等。在某种意义上，这是一个可以经常忽略的实现细节。然而，如果您希望自定义或配置记录实现，您可能希望回退到 \@RecordType 风格，或者用其中一个组成子注解来增强您的记录类。

## 自定义toString

根据 Java，您可以通过编写自己的方法来自定义记录的 toString 方法。如果您更喜欢更具声明性的样式，您也可以使用 Groovy 的 \@ToString 转换来覆盖默认记录 toString 。例如，可以按如下方式记录三维点：

    package threed
    
    import groovy.transform.ToString
    
    @ToString(ignoreNulls=true, cache=true, includeNames=true,
              leftDelimiter='[', rightDelimiter=']', nameValueSeparator='=')
    record Point(Integer x, Integer y, Integer z=null) { }
    
    assert new Point(10, 20).toString() == 'threed.Point[x=10, y=20]'

自定义 toString:

-   includeNames=true, 包含包名和类名, 默认为false

-   cache=true, 缓存toString的值, 因为我们不会改变Record中的值

-   ignoreNulls=true, 忽略null值

对于二维点，我们可以有类似的定义：

    package twod
    
    import groovy.transform.ToString
    
    @ToString(ignoreNulls=true, cache=true, includeNames=true,
              leftDelimiter='[', rightDelimiter=']', nameValueSeparator='=')
    record Point(Integer x, Integer y) { }
    
    assert new Point(10, 20).toString() == 'twod.Point[x=10, y=20]'

我们可以在这里看到，如果没有包名称，它将具有与前面的示例相同的 toString。

## 获取Record中所有属性的值

我们可以从记录中获取组件值作为列表，如下所示：

    record Point(int x, int y, String color) { }
    
    def p = new Point(100, 200, 'green')
    def (x, y, c) = p.toList()
    assert x == 100
    assert y == 200
    assert c == 'green'

您可以使用 \@RecordOptions(toList=false) 禁用此功能。

## 获取Record中所有属性对应的map

我们可以从记录中获取组件值作为映射，如下所示：

    record Point(int x, int y, String color) { }
    
    def p = new Point(100, 200, 'green')
    assert p.toMap() == [x: 100, y: 200, color: 'green']

您可以使用 \@RecordOptions(toMap=false) 禁用此功能。

## 获取Record中属性的个数

我们可以像这样获取记录中的组件数量：

    record Point(int x, int y, String color) { }
    
    def p = new Point(100, 200, 'green')
    assert p.size() == 3

您可以使用 \@RecordOptions(size=false) 禁用此功能。

## 从Record中获取第n个属性

我们可以使用 Groovy 的正常位置索引来获取记录中的特定组件，如下所示：

    record Point(int x, int y, String color) { }
    
    def p = new Point(100, 200, 'green')
    assert p[1] == 200

您可以使用 \@RecordOptions(getAt=false) 禁用此功能。

# 可选的 Groovy 功能

## Copying

创建某些更改了属性的Record副本可能很有用。这可以使用带有命名参数的可选 copyWith 方法来完成。

复制的Record类的属性是根据提供的参数设置的。

对于未设置的属性，使用原Record的（浅）副本。以下是您可以如何使用 copyWith 作为 Fruit 记录：

    @RecordOptions(copyWith=true)
    record Fruit(String name, double price) {}
    def apple = new Fruit('Apple', 11.6)
    assert 'Apple' == apple.name()
    assert 11.6 == apple.price()
    
    def orange = apple.copyWith(name: 'Orange')
    assert orange.toString() == 'Fruit[name=Orange, price=11.6]'

可以通过将 RecordOptions#copyWith 注释属性设置为 false 来禁用 copyWith 功能。

## 深度不可变

与 Java 一样，记录默认提供浅层不变性。 Groovy 的 \@Immutable 转换对一系列可变数据类型执行防御性复制。记录可以利用这种防御性复制来获得深度不变性，如下所示：

    @ImmutableProperties
    record Shopping(List items) {}
    
    def items = ['bread', 'milk']
    def shop = new Shopping(items)
    items << 'chocolate'
    assert shop.items() == ['bread', 'milk']

这些示例说明了 Groovy 记录功能背后的原理，提供了三个级别的便利性：

-   使用 record 关键字以获得最大程度的简洁性

-   使用注释支持简单的定制

-   当需要完全控制时允许通过正常方法实现

## 获取Record属性对应的tuple

您可以获取记录的组成部分作为类型化元组：

    import groovy.transform.*
    
    @RecordOptions(components=true)
    record Point(int x, int y, String color) { }
    
    @CompileStatic
    def method() {
        def p1 = new Point(100, 200, 'green')
        def (int x1, int y1, String c1) = p1.components()
        assert x1 == 100
        assert y1 == 200
        assert c1 == 'green'
    
        def p2 = new Point(10, 20, 'blue')
        def (x2, y2, c2) = p2.components()
        assert x2 * 10 == 100
        assert y2 ** 2 == 400
        assert c2.toUpperCase() == 'BLUE'
    
        def p3 = new Point(1, 2, 'red')
        assert p3.components() instanceof Tuple3
    }
    
    method()

Groovy 的 TupleN 类数量有限。如果您的记录中有大量属性，则可能无法使用此功能。

# 与 Java 的其他差异

Groovy 支持创建 *record-like* 的Record类以及native records。*record-like* 的Record类不会扩展 Java 的 Record 类，并且此类不会被 Java 视为Record，但会具有类似的属性。

\@RecordOptions 注释（ \@RecordType 的一部分）支持 mode 注释属性，该属性可以采用三个值之一（ AUTO 是默认值） ）：

NATIVE

:   生成一个与 Java 类似的类。在 JDK16 之前的 JDK 上编译时会产生错误。

EMULATE

:   为所有 JDK 版本生成 *record-like* 的Record类。

AUTO

:   Produces a native record for JDK16+ and emulates the record otherwise.

Whether you use the `record` keyword or the `@RecordType` annotation is independent of the mode.
