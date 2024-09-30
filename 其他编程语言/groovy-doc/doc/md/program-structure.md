

# 程序结构

本章介绍 Groovy 编程语言的程序结构。

## 包名

包名称的作用与 Java 中的作用完全相同。它们允许我们在没有任何冲突的情况下分离代码库。 Groovy 类必须在类定义之前指定其包，否则采用默认包。

定义包与 Java 非常相似：

```auto
// defining a package named com.yoursite
package com.yoursite
```

要引用 `com.yoursite.com` 包中的某些类 `Foo` ，您需要使用完全限定名称 `com.yoursite.com.Foo` ，或者您可以像如下说明的那样使用 `import`

## Imports

为了引用类，您需要对其包的限定引用。 Groovy 遵循 Java 的概念，允许 import 语句解析类引用。

例如，Groovy 提供了多个构建器类，例如 `MarkupBuilder` 。 `MarkupBuilder` 位于包 `groovy.xml` 内，因此为了使用此类，您需要 `import` 它，如下所示：

```auto
// importing the class MarkupBuilder
import groovy.xml.MarkupBuilder

// using the imported class to create an object
def xml = new MarkupBuilder()

assert xml != null
```

### 默认导入

默认导入是 Groovy 语言默认提供的导入。例如看下面的代码：

```auto
new Date()
```

Java 中的相同代码需要对 `Date` 类使用 `import` 语句，如下所示：import java.util.Date 。 Groovy 默认情况下会为您导入这些类。

以下导入由 groovy 为您自动添加：

```auto
import java.lang.*
import java.util.*
import java.io.*
import java.net.*
import groovy.lang.*
import groovy.util.*
import java.math.BigInteger
import java.math.BigDecimal
```

这样做是因为这些包中的类最常用。通过导入这些样板代码可以减少。

### 简单导入

简单导入是一个导入语句，您可以在其中完全定义类名和包。例如，下面代码中的 `import` 语句 `import groovy.xml.MarkupBuilder` 是一个简单的导入，它直接引用包内的类。

```auto
// importing the class MarkupBuilder
import groovy.xml.MarkupBuilder

// using the imported class to create an object
def xml = new MarkupBuilder()

assert xml != null
```

### \* 导入

Groovy 与 Java 一样，使用 `*` 从包中导入所有类，即所谓的星号导入。 `MarkupBuilder` 是一个位于包 `groovy.xml` 中的类，与另一个名为 `StreamingMarkupBuilder` 的类一起。如果您需要使用这两个类，您可以这样做：

```auto
import groovy.xml.MarkupBuilder
import groovy.xml.StreamingMarkupBuilder

def markupBuilder = new MarkupBuilder()

assert markupBuilder != null

assert new StreamingMarkupBuilder() != null
```

这是完全有效的代码。但是通过 **导入，我们只需一行即可达到相同的效果。** 导入包 `groovy.xml` 下的所有类：

```auto
import groovy.xml.*

def markupBuilder = new MarkupBuilder()

assert markupBuilder != null

assert new StreamingMarkupBuilder() != null
```

`*` 的一个问题是它们可能会扰乱您的本地命名空间。但通过 Groovy 提供的别名类型，这个问题可以轻松解决。

### Static 导入

Groovy 的静态导入功能允许您使用导入的类，就像它们是您自己的类中的静态方法一样：

```auto
import static java.lang.Boolean.FALSE

assert !FALSE //use directly, without Boolean prefix!
```

这类似于 Java 的静态导入功能，但比 Java 更加动态，因为它允许您定义与导入方法同名的方法，只要您具有不同的类型：

```auto
import static java.lang.String.format // (1)

class SomeClass {

    String format(Integer i) { // (2)
        i.toString()
    }

    static void main(String[] args) {
        assert format('String') == 'String' // (3)
        assert new SomeClass().format(Integer.valueOf(1)) == '1'
    }
}
```

1.  方法的静态导入
    
2.  方法声明与上面静态导入的方法同名，但参数类型不同
    
3.  java中编译错误，但是有效的groovy代码
    

如果类型相同，则导入的类优先。

### 静态导入别名

使用 `as` 关键字的静态导入为命名空间问题提供了一种优雅的解决方案。假设您想使用 `getInstance()` 方法获取 `Calendar` 实例。它是一个静态方法，因此我们可以使用静态导入。但是，我们可以使用别名导入它，以增加代码的可读性，而不是每次都调用 `getInstance()` ，这在与类名分开时可能会产生误导：

```auto
import static Calendar.getInstance as now

assert now().class == Calendar.getInstance().class
```

现在，一切都干净了！

### 静态星号导入

静态星形导入与常规星形导入非常相似。它将导入给定类中的所有静态方法。

例如，假设我们需要为我们的应用程序计算正弦和余弦。类 `java.lang.Math` 有名为 `sin` 和 `cos` 的静态方法，满足我们的需要。借助静态星号导入，我们可以执行以下操作：

```auto
import static java.lang.Math.*

assert sin(0) == 0.0
assert cos(0) == 1.0
```

如您所见，我们能够直接访问方法 `sin` 和 `cos` ，无需 `Math.` 前缀。

### 导入别名

通过类型别名，我们可以使用我们选择的名称来引用完全限定的类名。这可以像以前一样使用 `as` 关键字来完成。

例如，我们可以将 `java.sql.Date` 导入为 `SQLDate` 并在与 `java.util.Date` 相同的文件中使用它，而不必使用任一类的完全限定名称：

```auto
import java.util.Date
import java.sql.Date as SQLDate

Date utilDate = new Date(1000L)
SQLDate sqlDate = new SQLDate(1000L)

assert utilDate instanceof java.util.Date
assert sqlDate instanceof java.sql.Date
```

### 命名空间冲突

与Java类似，在Groovy中，如果指定了相同名称但类型不同的多个导入，这将是一个错误。

```auto
import java.awt.List
import java.util.List // error: name already declared
```

使用相同的名字声明import和顶级类型一样会导致error

```auto
import java.util.List
class List { } // error: name already declared
```

然而，内部类可以在单元作用域内隐藏名称:

```auto
import java.util.List
class Main {
    class List { } // allowed; "List" refers to this type within `Main`'s scope and `java.util.List` elsewhere
}
```

## 脚本与类

Groovy支持脚本与类

从 Groovy 5开始, Groovy 也支持 [JEP 445](https://openjdk.org/jeps/445) 兼容的脚本.

### Motivation for scripts

以下面的代码为例：

Main.groovy

```auto
class Main {                                    // (1)
    static void main(String... args) {          // (2)
        println 'Groovy world!'                 // (3)
    }
}
```

1.  定义一个 `Main` 类，名称任意
    
2.  `public static void main(String[])` 方法可用作类的主方法
    
3.  该方法的主体
    

这是来自 Java 的典型代码，其中代码必须嵌入到类中才能执行。 Groovy 使它变得更容易，以下代码是等效的：

Main.groovy

```auto
println 'Groovy world!'
```

脚本可以认为是一个无需显示声明的类, 但他们仍然有一些差异, 我们将在接下来进行介绍。首先，我们将介绍Groovy的 main ``Script`类。然后，我们将介绍与 `JEP 445`` 兼容的类。

### `Script` class

`groovy.lang.Script` 总是被编译进一个类。 Groovy 编译器将为您编译该类，并将脚本主体复制到 `run` 方法中。因此，前面的示例被编译为如下所示：

Main.groovy

```auto
import org.codehaus.groovy.runtime.InvokerHelper
class Main extends Script {                     // (1)
    def run() {                                 // (2)
        println 'Groovy world!'                 // (3)
    }
    static void main(String[] args) {           // (4)
        InvokerHelper.runScript(Main, args)     // (5)
    }
}
```

1.  `Main` 类继承了 `groovy.lang.Script` 类
    
2.  `groovy.lang.Script` 需要 `run` 方法返回值
    
3.  脚本主体进入 `run` 方法
    
4.  `main` 方法是自动生成的
    
5.  并委托 `run` 方法执行脚本
    

如果脚本位于文件中，则使用该文件的基本名称来确定生成的脚本类的名称。在此示例中，如果文件名是 `Main.groovy` ，则脚本类将为 `Main` 。

### 方法

可以将方法定义到脚本中，如下所示：

```auto
int fib(int n) {
    n < 2 ? 1 : fib(n-1) + fib(n-2)
}
assert fib(10)==89
```

您还可以混合方法和代码。生成的脚本类会将所有方法携带到脚本类中，并将所有脚本体组装到 run 方法中：

```auto
println 'Hello'                                 // (1)

int power(int n) { 2**n }                       // (2)

println "2^6==${power(6)}"                      // (3)
```

1.  脚本开始
    
2.  方法在脚本主体中定义
    
3.  脚本继续
    

语句1和3有时被称为“松散”语句。它们不包含在显式的封闭方法或类中。松散语句会按顺序组装到run方法中。

因此，上述代码在内部被转换为：

```auto
import org.codehaus.groovy.runtime.InvokerHelper
class Main extends Script {
    int power(int n) { 2** n}                   // (1)
    def run() {
        println 'Hello'                         // (2)
        println "2^6==${power(6)}"              // (3)
    }
    static void main(String[] args) {
        InvokerHelper.runScript(Main, args)
    }
}
```

1.  `power` 方法按原样复制到生成的脚本类中
    
2.  第一条语句被复制到 run 方法中
    
3.  第二条语句被复制到 run 方法中
    

<table><tbody><tr><td class="icon"><div class="title">Tip</div></td><td class="content">即使 Groovy 从您的脚本创建一个类，它对用户来说也是完全透明的。特别是，脚本被编译为字节码，并保留行号。这意味着，如果脚本中引发异常，堆栈跟踪将显示与原始脚本相对应的行号，而不是我们显示的生成代码。</td></tr></tbody></table>

### 变量

脚本中的变量不需要类型定义。这意味着该脚本：

```auto
int x = 1
int y = 2
assert x+y == 3
```

其行为将与以下内容相同：

```auto
x = 1
y = 2
assert x+y == 3
```

然而，两者之间存在语义差异：

+   如果变量按照第一个示例中的方式声明，则它是 *局部变量* 。它将在编译器生成的 `run` 方法中声明，并且在脚本主体之外不可见。特别是，这样的变量在脚本的其他方法中将不可见
    
+   如果变量未声明，它将进入 gapi:groovy.lang.Script#getBinding()\[script binding\] 。绑定从方法中可见，如果您使用脚本与应用程序交互并且需要在脚本和应用程序之间共享数据，则绑定尤其重要。读者可以参阅integrating\_groovy\_in\_a\_java\_application以获取更多信息。
    

<table><tbody><tr><td class="icon"><div class="title">Tip</div></td><td class="content">使变量对所有方法可见的另一种方法是使用 <code>@Field</code> 注释。以这种方式注释的变量将成为生成的脚本类的字段，并且对于局部变量，访问不会涉及脚本 <code>Binding</code> 。虽然不推荐，但如果您有与绑定变量同名的局部变量或脚本字段，则可以使用 <code>binding.varName</code> 访问绑定变量。</td></tr></tbody></table>

### Convenience variations

正如之前提到的，通常情况下，`public static void main` 和 `run` 方法会被自动添加到您的脚本中，因此通常不允许添加您自己版本；如果尝试这样做，您将看到一个重复方法的编译错误。

然而，有一些例外情况，不适用上述规则。如果您的脚本仅包含与主兼容的主方法而没有其他松散语句，或者仅包含无参数的 `run` 实例方法（从Groovy 5开始），那么是允许的。在这种情况下，没有松散语句（因为没有任何松散语句）会被收集到 `run` 方法中。您提供的方法将被用来替代Groovy自动添加的相应方法。

如果需要向隐式添加的 main 或 run 方法添加注释，这就很有用，正如下面的例子所示：

```auto
@CompileStatic
static main(args) {
    println 'Groovy world!'
}
```

为了被识别为方便变体，并且没有松散语句，`main` 方法的参数应该是：

与上面一样是无类型的（ `Object` 类型）， 或者是类型为 `String[]`， 或者是没有参数的（从Groovy 5开始）。 从Groovy 5开始，还支持不带参数的 `run` 实例变体。这也允许添加注解。`run` 变体遵循 `JEP 445` 中关于字段声明的规则（因此不需要使用 @Field 注解），正如涉及到Jackson JSON序列化的以下示例所示：

```auto
@JsonIgnoreProperties(["binding"])
def run() {
    var mapper = new ObjectMapper()
    assert mapper.writeValueAsString(this) == '{"pets":["cat","dog"]}'
}

public pets = ['cat', 'dog']
```

如果您的脚本需要扩展Script类并访问脚本上下文和绑定，建议使用run 变体。如果您没有这个要求，提供 main 变体之一将创建一个兼容 JEP 445 的类，该类不会扩展 Script。接下来我们将更详细地介绍 JEP 445 兼容的脚本。

## JEP 445 compatible scripts

从Groovy 5开始，添加了对包含 main 方法的 JEP 445 兼容脚本的支持。这样的脚本与普通的Groovy Script类有一些区别：

+   它们不会添加 public static void main 方法
    
+   它们不会扩展 Script 类，因此无法访问脚本上下文或绑定变量
    
+   允许在 main 之外定义额外的类级别的 字段 和 方法，除了 main
    
+   不能在 main 方法之外有"松散"语句（不包括任何字段定义）
    

一个简单的例子可能如下所示：

```auto
void main(args) {
    println new Date()
}
```

一个包含额外字段和方法的例子可能如下所示：

```auto
def main() {
    assert upper(foo) + lower(bar) == 'FOObar'
}

def upper(s) { s.toUpperCase() }

def lower = String::toLowerCase
def (foo, bar) = ['Foo', 'Bar']      // (1)
```

1.  请注意，多重赋值语法是受支持的，并导致为每个组件生成单独的字段定义。
    

### 与Java JEP 445行为的差异

Groovy的JEP 445支持与Java的支持存在一些差异：

+   Java支持无参数的main方法或包含单个String\[\]参数的方法。 Groovy还添加了对单一无类型（`Object` ）参数的支持，例如 `def main(args) { … }` This addition is known by the Groovy runner but would not be known by the Java launch protocol for a JDK supporting JEP 445.
    
+   Java支持 `void` 的主方法。Groovy还添加了对无类型 `def（Object）` 方法的支持，例如 `def main(…)` 以及 `void main(…)` 。 This addition is known by the Groovy runner but would not be known by the Java launch protocol for a JDK supporting JEP 445.
    
+   For static `main` variants, Groovy *promotes* the no-arg or untyped variants to have the standard `public static void main(String[] args)` signature. This is for compatibility with versions of Groovy prior to Groovy 5 (where JEP 445 support was added). As a consequence, such classes are compatible with the Java launch protocol prior to JEP 445 support.
    
+   Groovy’s runner has been made aware of JEP 445 compatible classes and can run all variations for JDK11 and above and without the need for preview mode to be enabled.
    

Last updated 2024-09-06 17:12:15 +0800