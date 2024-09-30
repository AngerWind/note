密封类、接口和特征限制了哪些子类可以扩展/实现它们。在密封类出现之前，类层次结构设计者有两个主要选择：

-   将class设置为final, 不允许继承

-   将class设置为public, 非final, 运行任何人继承

与这些全有或全无的选择相比，密封类提供了一个中间立场。

例如，假设我们要创建一个仅包含圆形和正方形的形状层次结构。我们还希望形状接口能够引用层次结构中的实例。我们可以按如下方式创建层次结构：

    sealed interface ShapeI permits Circle,Square { }
    final class Circle implements ShapeI { }
    final class Square implements ShapeI { }

Groovy 还支持替代注解语法。我们认为关键字样式更好，但如果您的编辑器尚不支持 Groovy 4，您可以选择注解样式。

    @Sealed(permittedSubclasses=[Circle,Square]) interface ShapeI { }
    final class Circle implements ShapeI { }
    final class Square implements ShapeI { }

我们可以有一个 ShapeI 类型的引用，由于 permits 子句，它可以指向 Circle 或 Square ，并且，由于我们的类是 final ，我们知道将来不会将其他类添加到我们的层次结构中。

一般来说，我们可能希望立即锁定类层次结构的某些部分，就像我们在这里将子类标记为 final 但其他时候我们可能希望允许进一步控制继承。

    sealed class Shape permits Circle,Polygon,Rectangle { }
    
    final class Circle extends Shape { }
    
    class Polygon extends Shape { }
    non-sealed class RegularPolygon extends Polygon { }
    final class Hexagon extends Polygon { }
    
    sealed class Rectangle extends Shape permits Square{ }
    final class Square extends Rectangle { }
    @Sealed(permittedSubclasses=[Circle,Polygon,Rectangle]) class Shape { }
    
    final class Circle extends Shape { }
    
    class Polygon extends Shape { }
    @NonSealed class RegularPolygon extends Polygon { }
    final class Hexagon extends Polygon { }
    
    @Sealed(permittedSubclasses=Square) class Rectangle extends Shape { }
    final class Square extends Rectangle { }

 \
在此示例中， Shape 允许的子类是 Circle 、 Polygon 和 Rectangle 。 Circle 是 final ，因此层次结构的该部分无法扩展。

Polygon 是隐式非密封， RegularPolygon 显式标记为 non-sealed 。这意味着我们可以通过子类进行任何进一步的扩展，如 `Polygon → RegularPolygon` 和 `RegularPolygon → Hexagon` 所示。

`Rectangle` 是密封的，并且仅允许 Square 子类。

密封类对于创建需要包含实例特定数据的类似枚举的相关类非常有用。例如，我们可能有以下枚举：

    enum Weather { Rainy, Cloudy, Sunny }
    def forecast = [Weather.Rainy, Weather.Sunny, Weather.Cloudy]
    assert forecast.toString() == '[Rainy, Sunny, Cloudy]'

但我们现在还希望将天气特定数据添加到天气预报中。我们可以按如下方式改变我们的抽象：

    sealed abstract class Weather { }
    @Immutable(includeNames=true) class Rainy extends Weather { Integer expectedRainfall }
    @Immutable(includeNames=true) class Sunny extends Weather { Integer expectedTemp }
    @Immutable(includeNames=true) class Cloudy extends Weather { Integer expectedUV }
    def forecast = [new Rainy(12), new Sunny(35), new Cloudy(6)]
    assert forecast.toString() == '[Rainy(expectedRainfall:12), Sunny(expectedTemp:35), Cloudy(expectedUV:6)]'

在指定代数(Algebraic)或抽象数据类型(Abstract Data Types) (ADT) 时，密封层次结构也很有用，如下例所示：

    import groovy.transform.*
    
    sealed interface Tree<T> {}
    @Singleton final class Empty implements Tree {
        String toString() { 'Empty' }
    }
    @Canonical final class Node<T> implements Tree<T> {
        T value
        Tree<T> left, right
    }
    
    Tree<Integer> tree = new Node<>(42, new Node<>(0, Empty.instance, Empty.instance), Empty.instance)
    assert tree.toString() == 'Node(42, Node(0, Empty, Empty), Empty)'

密封层次结构与Record类也可以配合使用，如以下示例所示：

    sealed interface Expr {}
    record ConstExpr(int i) implements Expr {}
    record PlusExpr(Expr e1, Expr e2) implements Expr {}
    record MinusExpr(Expr e1, Expr e2) implements Expr {}
    record NegExpr(Expr e) implements Expr {}
    
    def threePlusNegOne = new PlusExpr(new ConstExpr(3), new NegExpr(new ConstExpr(1)))
    assert threePlusNegOne.toString() == 'PlusExpr[e1=ConstExpr[i=3], e2=NegExpr[e=ConstExpr[i=1]]]'

# 与 Java 的差异

-   Java provides no default modifier for subclasses of sealed classes and requires that one of `final`, `sealed` or `non-sealed` be specified. Groovy defaults to *non-sealed* but you can still use `non-sealed/@NonSealed` if you wish. We anticipate the style checking tool CodeNarc will eventually have a rule that looks for the presence of `non-sealed` so developers wanting that stricter style will be able to use CodeNarc and that rule if they want.

-   目前，Groovy 不会检查 permittedSubclasses 中提到的所有类在编译时是否可用并与基本密封类一起编译。这可能会在 Groovy 的未来版本中发生变化。

Groovy支持 native封闭类, 也支持通过注解将class标记为封闭类

\@SealedOptions 注解支持 mode 注解属性，该属性可以采用三个值之一（ AUTO 为默认值）：

NATIVE

:   Produces a class similar to what Java would do. Produces an error when compiling on JDKs earlier than JDK17.

EMULATE

:   Indicates the class is sealed using the `@Sealed` annotation. This mechanism works with the Groovy compiler for JDK8+ but is not recognised by the Java compiler.

AUTO

:   Produces a native record for JDK17+ and emulates the record otherwise.

Whether you use the `sealed` keyword or the `@Sealed` annotation is independent of the mode.
