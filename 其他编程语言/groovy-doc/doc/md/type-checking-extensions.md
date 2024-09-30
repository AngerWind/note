# 编写类型检查扩展

## 更智能的类型检查器

尽管 Groovy 是一种动态语言，但它可以在编译时与[静态类型检查器](#static-type-checking)一起使用，并使用 \@TypeChecked 注释启用。在这种模式下，编译器会变得更加冗长，并会抛出错误，例如拼写错误、不存在的方法等。不过，这也有一些限制，其中大部分来自 Groovy 本质上仍然是一种动态语言。例如，您将无法对使用标记生成器的代码进行类型检查：

    def builder = new MarkupBuilder(out)
    builder.html {
        head {
            // ...
        }
        body {
            p 'Hello, world!'
        }
    }

在前面的示例中， html 、 head 、 body 或 p 方法都不存在。但是，如果您执行该代码，它就会起作用，因为 Groovy 使用动态调度并在运行时转换这些方法调用。在此builder中，您可以使用的标签数量和属性都没有限制，这意味着类型检查器没有机会在编译时了解所有可能的方法（标签），除非您创建一个build专用于 HTML。

Groovy 是实现内部 DSL 的首选平台。灵活的语法与运行时和编译时元编程功能相结合，使 Groovy 成为一个有趣的选择，因为它允许程序员专注于 DSL 而不是工具或实现。由于 Groovy DSL 是 Groovy 代码，因此很容易获得 IDE 支持，而无需编写专用插件等。

In a lot of cases, DSL engines are written in Groovy (or Java) then user code is executed as scripts, meaning that you have some kind of wrapper on top of user logic. The wrapper may consist, for example, in a `GroovyShell` or `GroovyScriptEngine` that performs some tasks transparently before running the script (adding imports, applying AST transforms, extending a base script,...). Often, user written scripts come to production without testing because the DSL logic comes to a point where **any** user may write code using the DSL syntax. In the end, a user may just ignore that what they write is actually **code**. This adds some challenges for the DSL implementer, such as securing execution of user code or, in this case, early reporting of errors.

For example, imagine a DSL which goal is to drive a rover on Mars remotely. Sending a message to the rover takes around 15 minutes. If the rover executes the script and fails with an error (say a typo), you have two problems:

-   first, feedback comes only after 30 minutes (the time needed for the rover to get the script and the time needed to receive the error)

-   second, some portion of the script has been executed and you may have to change the fixed script significantly (implying that you need to know the current state of the rover...)

类型检查扩展机制，允许 DSL 引擎的开发人员通过应用在常规Groovy类上进行的静态类型来使这些脚本更安全。

这里的原则是尽早失败，也就是说尽快使脚本编译失败，并且如果可能的话向用户提供反馈（包括好的错误消息）。

简而言之，类型检查扩展背后的想法是让编译器了解 DSL 使用的所有运行时元编程技巧，以便脚本可以受益于与详细静态编译代码相同级别的编译时检查。我们将看到您可以通过执行普通类型检查器无法执行的检查来更进一步，为您的用户提供强大的编译时检查。

## `extensions` 属性

\@TypeChecked 注释支持名为 extensions 的属性。该参数是类型检查扩展脚本的字符串数组。

这些脚本是在编译时在类路径中找到的。例如，您可以写：

    @TypeChecked(extensions='/path/to/myextension.groovy')
    void foo() { ...}

在这种情况下，将使用 myextension.groovy 脚本中找到的正常类型检查器的规则对 foo 方法进行类型检查。请注意，虽然类型检查器内部支持多种机制来实现类型检查扩展（包括普通的旧 java 代码），但推荐的方法是使用这些类型检查扩展脚本。

## 应用于类型检查的DSL

类型检查扩展背后的想法是使用 DSL 来扩展类型检查器功能。该 DSL 允许您使用"事件驱动"API 挂钩编译过程，更具体地说是类型检查阶段。例如，当类型检查器进入方法主体时，它会引发扩展的 `beforeVisitMethod` 事件：

    beforeVisitMethod { methodNode ->
     println "Entering ${methodNode.name}"
    }

Imagine that you have this rover DSL at hand. A user would write:

    robot.move 100

If you have a class defined as such:

    class Robot {
        Robot move(int qt) { this }
    }

The script can be type checked before being executed using the following script:

    def config = new CompilerConfiguration()
    config.addCompilationCustomizers(
        new ASTTransformationCustomizer(TypeChecked)            
    )
    def shell = new GroovyShell(config)                         
    def robot = new Robot()
    shell.setVariable('robot', robot)
    shell.evaluate(script)                                      

-   a compiler configuration adds the `@TypeChecked` annotation to all classes

-   use the configuration in a `GroovyShell`

-   so that scripts compiled using the shell are compiled with `@TypeChecked` without the user having to add it explicitly

Using the compiler configuration above, we can apply *\@TypeChecked* transparently to the script. In that case, it will fail at compile time:

    [Static type checking] - The variable [robot] is undeclared.

Now, we will slightly update the configuration to include the \`\`extensions\'\' parameter:

    config.addCompilationCustomizers(
        new ASTTransformationCustomizer(
            TypeChecked,
            extensions:['robotextension.groovy'])
    )

Then add the following to your classpath:

**robotextension.groovy**

    unresolvedVariable { var ->
        if ('robot'==var.name) {
            storeType(var, classNodeFor(Robot))
            handled = true
        }
    }

Here, we're telling the compiler that if an *unresolved variable* is found and that the name of the variable is *robot*, then we can make sure that the type of this variable is `Robot`.

## Type checking extensions API

### AST

The type checking API is a low level API, dealing with the Abstract Syntax Tree. You will have to know your AST well to develop extensions, even if the DSL makes it much easier than just dealing with AST code from plain Java or Groovy.

### Events

The type checker sends the following events, to which an extension script can react:

+-----------------+-------------------------------------------------------+
| **Event name**  | setup                                                 |
+-----------------+-------------------------------------------------------+
| **Called When** | Called after the type checker finished initialization |
+-----------------+-------------------------------------------------------+
| **Arguments**   | none                                                  |
+-----------------+-------------------------------------------------------+
| **Usage**       |     setup {                                           |
|                 |         // this is called before anything else        |
|                 |     }                                                 |
|                 |                                                       |
|                 | Can be used to perform setup of your extension        |
+-----------------+-------------------------------------------------------+

+-----------------+---------------------------------------------------------------------------------------+
| **Event name**  | finish                                                                                |
+-----------------+---------------------------------------------------------------------------------------+
| **Called When** | Called after the type checker completed type checking                                 |
+-----------------+---------------------------------------------------------------------------------------+
| **Arguments**   | none                                                                                  |
+-----------------+---------------------------------------------------------------------------------------+
| **Usage**       |     finish {                                                                          |
|                 |         // this is after completion                                                   |
|                 |         // of all type checking                                                       |
|                 |     }                                                                                 |
|                 |                                                                                       |
|                 | Can be used to perform additional checks after the type checker has finished its job. |
+-----------------+---------------------------------------------------------------------------------------+

+-----------------+-----------------------------------------------------------------------------+
| **Event name**  | unresolvedVariable                                                          |
+-----------------+-----------------------------------------------------------------------------+
| **Called When** | Called when the type checker finds an unresolved variable                   |
+-----------------+-----------------------------------------------------------------------------+
| **Arguments**   | VariableExpression vexp                                                     |
+-----------------+-----------------------------------------------------------------------------+
| **Usage**       |     unresolvedVariable { VariableExpression vexp ->                         |
|                 |         if (vexp.name == 'people') {                                        |
|                 |             storeType(vexp, LIST_TYPE)                                      |
|                 |             handled = true                                                  |
|                 |         }                                                                   |
|                 |     }                                                                       |
|                 |                                                                             |
|                 | Allows the developer to help the type checker with user-injected variables. |
+-----------------+-----------------------------------------------------------------------------+

+-----------------+---------------------------------------------------------------------+
| **Event name**  | unresolvedProperty                                                  |
+-----------------+---------------------------------------------------------------------+
| **Called When** | Called when the type checker cannot find a property on the receiver |
+-----------------+---------------------------------------------------------------------+
| **Arguments**   | PropertyExpression pexp                                             |
+-----------------+---------------------------------------------------------------------+
| **Usage**       |     unresolvedProperty { PropertyExpression pexp ->                 |
|                 |         if (pexp.propertyAsString == 'longueur' &&                  |
|                 |                 getType(pexp.objectExpression) == STRING_TYPE) {    |
|                 |             storeType(pexp, int_TYPE)                               |
|                 |             handled = true                                          |
|                 |         }                                                           |
|                 |     }                                                               |
|                 |                                                                     |
|                 | Allows the developer to handle \"dynamic\" properties               |
+-----------------+---------------------------------------------------------------------+

+-----------------+-----------------------------------------------------------------------+
| **Event name**  | unresolvedAttribute                                                   |
+-----------------+-----------------------------------------------------------------------+
| **Called When** | Called when the type checker cannot find an attribute on the receiver |
+-----------------+-----------------------------------------------------------------------+
| **Arguments**   | AttributeExpression aexp                                              |
+-----------------+-----------------------------------------------------------------------+
| **Usage**       |     unresolvedAttribute { AttributeExpression aexp ->                 |
|                 |         if (getType(aexp.objectExpression) == STRING_TYPE) {          |
|                 |             storeType(aexp, STRING_TYPE)                              |
|                 |             handled = true                                            |
|                 |         }                                                             |
|                 |     }                                                                 |
|                 |                                                                       |
|                 | Allows the developer to handle missing attributes                     |
+-----------------+-----------------------------------------------------------------------+

+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | beforeMethodCall                                                                                                                                                                                                                                                                                 |
+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called before the type checker starts type checking a method call                                                                                                                                                                                                                                |
+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | MethodCall call                                                                                                                                                                                                                                                                                  |
+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     beforeMethodCall { call ->                                                                                                                                                                                                                                                                   |
|                 |         if (isMethodCallExpression(call)                                                                                                                                                                                                                                                         |
|                 |                 && call.methodAsString=='toUpperCase') {                                                                                                                                                                                                                                         |
|                 |             addStaticTypeError('Not allowed',call)                                                                                                                                                                                                                                               |
|                 |             handled = true                                                                                                                                                                                                                                                                       |
|                 |         }                                                                                                                                                                                                                                                                                        |
|                 |     }                                                                                                                                                                                                                                                                                            |
|                 |                                                                                                                                                                                                                                                                                                  |
|                 | Allows you to intercept method calls before the type checker performs its own checks. This is useful if you want to replace the default type checking with a custom one for a limited scope. In that case, you must set the handled flag to true, so that the type checker skips its own checks. |
+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | afterMethodCall                                                                                                                                                                                                                                                                                                                                                                              |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called once the type checker has finished type checking a method call                                                                                                                                                                                                                                                                                                                        |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | MethodCall call                                                                                                                                                                                                                                                                                                                                                                              |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     afterMethodCall { call ->                                                                                                                                                                                                                                                                                                                                                                |
|                 |         if (getTargetMethod(call).name=='toUpperCase') {                                                                                                                                                                                                                                                                                                                                     |
|                 |             addStaticTypeError('Not allowed',call)                                                                                                                                                                                                                                                                                                                                           |
|                 |             handled = true                                                                                                                                                                                                                                                                                                                                                                   |
|                 |         }                                                                                                                                                                                                                                                                                                                                                                                    |
|                 |     }                                                                                                                                                                                                                                                                                                                                                                                        |
|                 |                                                                                                                                                                                                                                                                                                                                                                                              |
|                 | Allow you to perform additional checks after the type checker has done its own checks. This is in particular useful if you want to perform the standard type checking tests but also want to ensure additional type safety, for example checking the arguments against each other.Note that `afterMethodCall` is called even if you did `beforeMethodCall` and set the handled flag to true. |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | onMethodSelection                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called by the type checker when it finds a method appropriate for a method call                                                                                                                                                                                                                                                                                                                                                                                              |
+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | Expression expr, MethodNode node                                                                                                                                                                                                                                                                                                                                                                                                                                             |
+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     onMethodSelection { expr, node ->                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|                 |         if (node.declaringClass.name == 'java.lang.String') {                                                                                                                                                                                                                                                                                                                                                                                                                |
|                 |             // calling a method on 'String'                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|                 |             // let’s perform additional checks!                                                                                                                                                                                                                                                                                                                                                                                                                              |
|                 |             if (++count>2) {                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|                 |                 addStaticTypeError("You can use only 2 calls on String in your source code",expr)                                                                                                                                                                                                                                                                                                                                                                            |
|                 |             }                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|                 |         }                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
|                 |     }                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|                 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
|                 | The type checker works by inferring argument types of a method call, then chooses a target method. If it finds one that corresponds, then it triggers this event. It is for example interesting if you want to react on a specific method call, such as entering the scope of a method that takes a closure as argument (as in builders).Please note that this event may be thrown for various types of expressions, not only method calls (binary expressions for example). |
+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | methodNotFound                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called by the type checker when it fails to find an appropriate method for a method call                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | ClassNode receiver, String name, ArgumentListExpression argList, ClassNode\[\] argTypes,MethodCall call                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     methodNotFound { receiver, name, argList, argTypes, call ->                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|                 |         // receiver is the inferred type of the receiver                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
|                 |         // name is the name of the called method                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
|                 |         // argList is the list of arguments the method was called with                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|                 |         // argTypes is the array of inferred types for each argument                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|                 |         // call is the method call for which we couldn’t find a target method                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|                 |         if (receiver==classNodeFor(String)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|                 |                 && name=='longueur'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|                 |                 && argList.size()==0) {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|                 |             handled = true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|                 |             return newMethod('longueur', classNodeFor(String))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|                 |         }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|                 |     }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|                 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|                 | Unlike `onMethodSelection`, this event is sent when the type checker cannot find a target method for a method call (instance or static). It gives you the chance to intercept the error before it is sent to the user, but also set the target method.For this, you need to return a list of `MethodNode`. In most situations, you would either return: an empty list, meaning that you didn't find a corresponding method, a list with exactly one element, saying that there's no doubt about the target methodIf you return more than one MethodNode, then the compiler would throw an error to the user stating that the method call is ambiguous, listing the possible methods.For convenience, if you want to return only one method, you are allowed to return it directly instead of wrapping it into a list. |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | beforeVisitMethod                                                                                                                                                                                                                                                                                                                                                            |
+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called by the type checker before type checking a method body                                                                                                                                                                                                                                                                                                                |
+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | MethodNode node                                                                                                                                                                                                                                                                                                                                                              |
+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     beforeVisitMethod { methodNode ->                                                                                                                                                                                                                                                                                                                                        |
|                 |         // tell the type checker we will handle the body by ourselves                                                                                                                                                                                                                                                                                                        |
|                 |         handled = methodNode.name.startsWith('skip')                                                                                                                                                                                                                                                                                                                         |
|                 |     }                                                                                                                                                                                                                                                                                                                                                                        |
|                 |                                                                                                                                                                                                                                                                                                                                                                              |
|                 | The type checker will call this method before starting to type check a method body. If you want, for example, to perform type checking by yourself instead of letting the type checker do it, you have to set the handled flag to true. This event can also be used to help define the scope of your extension (for example, applying it only if you are inside method foo). |
+-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | afterVisitMethod                                                                                                                                                                                                                             |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called by the type checker after type checking a method body                                                                                                                                                                                 |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | MethodNode node                                                                                                                                                                                                                              |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     afterVisitMethod { methodNode ->                                                                                                                                                                                                         |
|                 |         scopeExit {                                                                                                                                                                                                                          |
|                 |             if (methods>2) {                                                                                                                                                                                                                 |
|                 |                 addStaticTypeError("Method ${methodNode.name} contains more than 2 method calls", methodNode)                                                                                                                                |
|                 |             }                                                                                                                                                                                                                                |
|                 |         }                                                                                                                                                                                                                                    |
|                 |     }                                                                                                                                                                                                                                        |
|                 |                                                                                                                                                                                                                                              |
|                 | Gives you the opportunity to perform additional checks after a method body is visited by the type checker. This is useful if you collect information, for example, and want to perform additional checks once everything has been collected. |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | beforeVisitClass                                                                                                                                                                                                                                                                                                                                                                                              |
+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called by the type checker before type checking a class                                                                                                                                                                                                                                                                                                                                                       |
+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | ClassNode node                                                                                                                                                                                                                                                                                                                                                                                                |
+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     beforeVisitClass { ClassNode classNode ->                                                                                                                                                                                                                                                                                                                                                                 |
|                 |         def name = classNode.nameWithoutPackage                                                                                                                                                                                                                                                                                                                                                               |
|                 |         if (!(name[0] in 'A'..'Z')) {                                                                                                                                                                                                                                                                                                                                                                         |
|                 |             addStaticTypeError("Class '${name}' doesn't start with an uppercase letter",classNode)                                                                                                                                                                                                                                                                                                            |
|                 |         }                                                                                                                                                                                                                                                                                                                                                                                                     |
|                 |     }                                                                                                                                                                                                                                                                                                                                                                                                         |
|                 |                                                                                                                                                                                                                                                                                                                                                                                                               |
|                 | If a class is type checked, then before visiting the class, this event will be sent. It is also the case for inner classes defined inside a class annotated with `@TypeChecked`. It can help you define the scope of your extension, or you can even totally replace the visit of the type checker with a custom type checking implementation. For that, you would have to set the `handled` flag to `true`.  |
+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | afterVisitClass                                                                                                                                                                                                      |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called by the type checker after having finished the visit of a type checked class                                                                                                                                   |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | ClassNode node                                                                                                                                                                                                       |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     afterVisitClass { ClassNode classNode ->                                                                                                                                                                         |
|                 |         def name = classNode.nameWithoutPackage                                                                                                                                                                      |
|                 |         if (!(name[0] in 'A'..'Z')) {                                                                                                                                                                                |
|                 |             addStaticTypeError("Class '${name}' doesn't start with an uppercase letter",classNode)                                                                                                                   |
|                 |         }                                                                                                                                                                                                            |
|                 |     }                                                                                                                                                                                                                |
|                 |                                                                                                                                                                                                                      |
|                 | Called for every class being type checked after the type checker finished its work. This includes classes annotated with `@TypeChecked` and any inner/anonymous class defined in the same class with is not skipped. |
+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | incompatibleAssignment                                                                                                                                                                                                                                                                                                                                                                                          |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called when the type checker thinks that an assignment is incorrect, meaning that the right-hand side of an assignment is incompatible with the left-hand side                                                                                                                                                                                                                                                  |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | ClassNode lhsType, ClassNode rhsType, Expression assignment                                                                                                                                                                                                                                                                                                                                                     |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     incompatibleAssignment { lhsType, rhsType, expr ->                                                                                                                                                                                                                                                                                                                                                          |
|                 |         if (isBinaryExpression(expr) && isAssignment(expr.operation.type)) {                                                                                                                                                                                                                                                                                                                                    |
|                 |             if (lhsType==classNodeFor(int) && rhsType==classNodeFor(Closure)) {                                                                                                                                                                                                                                                                                                                                 |
|                 |                 handled = true                                                                                                                                                                                                                                                                                                                                                                                  |
|                 |             }                                                                                                                                                                                                                                                                                                                                                                                                   |
|                 |         }                                                                                                                                                                                                                                                                                                                                                                                                       |
|                 |     }                                                                                                                                                                                                                                                                                                                                                                                                           |
|                 |                                                                                                                                                                                                                                                                                                                                                                                                                 |
|                 | Gives the developer the ability to handle incorrect assignments. This is for example useful if a class overrides `setProperty`, because in that case it is possible that assigning a variable of one type to a property of another type is handled through that runtime mechanism. In that case, you can help the type checker just by telling it that the assignment is valid (using `handled` set to `true`). |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | incompatibleReturnType                                                                                                                                                                                                                                                                                                                                       |
+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called when the type checker thinks that a return value is incompatibe with the return type of the enclosing closure or method                                                                                                                                                                                                                               |
+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | ReturnStatement statement, ClassNode valueType                                                                                                                                                                                                                                                                                                               |
+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     incompatibleReturnType { stmt, type ->                                                                                                                                                                                                                                                                                                                   |
|                 |         if (type == STRING_TYPE) {                                                                                                                                                                                                                                                                                                                           |
|                 |             handled = true                                                                                                                                                                                                                                                                                                                                   |
|                 |         }                                                                                                                                                                                                                                                                                                                                                    |
|                 |     }                                                                                                                                                                                                                                                                                                                                                        |
|                 |                                                                                                                                                                                                                                                                                                                                                              |
|                 | Gives the developer the ability to handle incorrect return values. This is for example useful when the return value will undergo implicit conversion or the enclosing closure's target type is difficult to infer properly. In that case, you can help the type checker just by telling it that the assignment is valid (by setting the `handled` property). |
+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Event name**  | ambiguousMethods                                                                                                                                                                                                                                                                                                                                                                                                |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Called When** | Called when the type checker cannot choose between several candidate methods                                                                                                                                                                                                                                                                                                                                    |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Arguments**   | List\<MethodNode\> methods,  Expression origin                                                                                                                                                                                                                                                                                                                                                                  |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Usage**       |     ambiguousMethods { methods, origin ->                                                                                                                                                                                                                                                                                                                                                                       |
|                 |         // choose the method which has an Integer as parameter type                                                                                                                                                                                                                                                                                                                                             |
|                 |         methods.find { it.parameters.any { it.type == classNodeFor(Integer) } }                                                                                                                                                                                                                                                                                                                                 |
|                 |     }                                                                                                                                                                                                                                                                                                                                                                                                           |
|                 |                                                                                                                                                                                                                                                                                                                                                                                                                 |
|                 | Gives the developer the ability to handle incorrect assignments. This is for example useful if a class overrides `setProperty`, because in that case it is possible that assigning a variable of one type to a property of another type is handled through that runtime mechanism. In that case, you can help the type checker just by telling it that the assignment is valid (using `handled` set to `true`). |
+-----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Of course, an extension script may consist of several blocks, and you can have multiple blocks responding to the same event. This makes the DSL look nicer and easier to write. However, reacting to events is far from sufficient. If you know you can react to events, you also need to deal with the errors, which implies several *helper* methods that will make things easier.

## Working with extensions

### Support classes

The DSL relies on a support class called gapi:org.codehaus.groovy.transform.stc.GroovyTypeCheckingExtensionSupport\[\] . This class itself extends gapi:org.codehaus.groovy.transform.stc.TypeCheckingExtension\[\] . Those two classes define a number of *helper* methods that will make working with the AST easier, especially regarding type checking. One interesting thing to know is that you **have access to the type checker**. This means that you can programmatically call methods of the type checker, including those that allow you to **throw compilation errors**.

The extension script delegates to the gapi:org.codehaus.groovy.transform.stc.GroovyTypeCheckingExtensionSupport\[\] class, meaning that you have direct access to the following variables:

-   *context*: the type checker context, of type gapi:org.codehaus.groovy.transform.stc.TypeCheckingContext\[\]

-   *typeCheckingVisitor*: the type checker itself, a gapi:org.codehaus.groovy.transform.stc.StaticTypeCheckingVisitor\[\] instance

-   *generatedMethods*: a list of \"generated methods\", which is in fact the list of \"dummy\" methods that you can create inside a type checking extension using the `newMethod` calls

The type checking context contains a lot of information that is useful in context for the type checker. For example, the current stack of enclosing method calls, binary expressions, closures, ... This information is in particular important if you have to know *where* you are when an error occurs and that you want to handle it.

In addition to facilities provided by `GroovyTypeCheckingExtensionSupport` and `StaticTypeCheckingVisitor`, a type-checking DSL script imports static members from gapi:org.codehaus.groovy.ast.ClassHelper\[\] and gapi:org.codehaus.groovy.transform.stc.StaticTypeCheckingSupport\[\] granting access to common types via `OBJECT_TYPE`, `STRING_TYPE`, `THROWABLE_TYPE`, etc. and checks like `missesGenericsTypes(ClassNode)`, `isClassClassNodeWrappingConcreteType(ClassNode)` and so on.

### Class nodes

Handling class nodes is something that needs particular attention when you work with a type checking extension. Compilation works with an abstract syntax tree (AST) and the tree may not be complete when you are type checking a class. This also means that when you refer to types, you must not use class literals such as `String` or `HashSet`, but to class nodes representing those types. This requires a certain level of abstraction and understanding how Groovy deals with class nodes. To make things easier, Groovy supplies several helper methods to deal with class nodes. For example, if you want to say \"the type for String\", you can write:

    assert classNodeFor(String) instanceof ClassNode

You would also note that there is a variant of *classNodeFor* that takes a `String` as an argument, instead of a `Class`. In general, you should **not** use that one, because it would create a class node for which the name is `String`, but without any method, any property, ... defined on it. The first version returns a class node that is *resolved* but the second one returns one that is *not*. So the latter should be reserved for very special cases.

The second problem that you might encounter is referencing a type which is not yet compiled. This may happen more often than you think. For example, when you compile a set of files together. In that case, if you want to say \"that variable is of type Foo\" but `Foo` is not yet compiled, you can still refer to the `Foo` class node using `lookupClassNodeFor`:

    assert lookupClassNodeFor('Foo') instanceof ClassNode

### Helping the type checker

Say that you know that variable `foo` is of type `Foo` and you want to tell the type checker about it. Then you can use the `storeType` method, which takes two arguments: the first one is the node for which you want to store the type and the second one is the type of the node. If you look at the implementation of `storeType`, you would see that it delegates to the type checker equivalent method, which itself does a lot of work to store node metadata. You would also see that storing the type is not limited to variables: you can set the type of any expression.

Likewise, getting the type of an AST node is just a matter of calling `getType` on that node. This would in general be what you want, but there's something that you must understand:

-   `getType` returns the **inferred type** of an expression. This means that it will not return, for a variable declared of type `Object` the class node for `Object`, but the inferred type of this variable **at this point of the code** (flow typing)

-   if you want to access the origin type of a variable (or field/parameter), then you must call the appropriate method on the AST node

### Throwing an error

To throw a type checking error, you only have to call the `addStaticTypeError` method which takes two arguments:

-   a *message* which is a string that will be displayed to the end user

-   an *AST node* responsible for the error. It's better to provide the best suiting AST node because it will be used to retrieve the line and column numbers

### isXXXExpression

It is often required to know the type of an AST node. For readability, the DSL provides a special isXXXExpression method that will delegate to `x instance of XXXExpression`. For example, instead of writing:

    if (node instanceof BinaryExpression) {
       ...
    }

you can just write:

    if (isBinaryExpression(node)) {
       ...
    }

### Virtual methods

When you perform type checking of dynamic code, you may often face the case when you know that a method call is valid but there is no \"real\" method behind it. As an example, take the Grails dynamic finders. You can have a method call consisting of a method named *findByName(...)*. As there's no *findByName* method defined in the bean, the type checker would complain. Yet, you would know that this method wouldn't fail at runtime, and you can even tell what is the return type of this method. For this case, the DSL supports two special constructs that consist of *phantom methods*. This means that you will return a method node that doesn't really exist but is defined in the context of type checking. Three methods exist:

-   `newMethod(String name, Class returnType)`

-   `newMethod(String name, ClassNode returnType)`

-   `newMethod(String name, Callable<ClassNode> return Type)`

All three variants do the same: they create a new method node which name is the supplied name and define the return type of this method. Moreover, the type checker would add those methods in the `generatedMethods` list (see `isGenerated` below). The reason why we only set a name and a return type is that it is only what you need in 90% of the cases. For example, in the `findByName` example upper, the only thing you need to know is that `findByName` wouldn't fail at runtime, and that it returns a domain class. The `Callable` version of return type is interesting because it defers the computation of the return type when the type checker actually needs it. This is interesting because in some circumstances, you may not know the actual return type when the type checker demands it, so you can use a closure that will be called each time `getReturnType` is called by the type checker on this method node. If you combine this with deferred checks, you can achieve pretty complex type checking including handling of forward references.

    newMethod(name) {
        // each time getReturnType on this method node will be called, this closure will be called!
        println 'Type checker called me!'
        lookupClassNodeFor(Foo) // return type
    }

Should you need more than the name and return type, you can always create a new `MethodNode` by yourself.

### Scoping

Scoping is very important in DSL type checking and is one of the reasons why we couldn't use a *pointcut* based approach to DSL type checking. Basically, you must be able to define very precisely when your extension applies and when it does not. Moreover, you must be able to handle situations that a regular type checker would not be able to handle, such as forward references:

    point a(1,1)
    line a,b // b is referenced afterwards!
    point b(5,2)

Say for example that you want to handle a builder:

    builder.foo {
       bar
       baz(bar)
    }

Your extension, then, should only be active once you've entered the `foo` method, and inactive outside this scope. But you could have complex situations like multiple builders in the same file or embedded builders (builders in builders). While you should not try to fix all this from start (you must accept limitations to type checking), the type checker does offer a nice mechanism to handle this: a scoping stack, using the `newScope` and `scopeExit` methods.

-   `newScope` creates a new scope and puts it on top of the stack

-   `scopeExits` pops a scope from the stack

A scope consists of:

-   a parent scope

-   a map of custom data

If you want to look at the implementation, it's simply a `LinkedHashMap` (gapi:org.codehaus.groovy.transform.stc.GroovyTypeCheckingExtensionSupport.TypeCheckingScope\[\]), but it's quite powerful. For example, you can use such a scope to store a list of closures to be executed when you exit the scope. This is how you would handle forward references: 

    def scope = newScope()
    scope.secondPassChecks = []
    //...
    scope.secondPassChecks << { println 'executed later' }
    // ...
    scopeExit {
        secondPassChecks*.run() // execute deferred checks
    }

That is to say, that if at some point you are not able to determine the type of an expression, or that you are not able to check at this point that an assignment is valid or not, you can still make the check later... This is a very powerful feature. Now, `newScope` and `scopeExit` provide some interesting syntactic sugar:

    newScope {
        secondPassChecks = []
    }

At anytime in the DSL, you can access the current scope using `getCurrentScope()` or more simply `currentScope`:

    //...
    currentScope.secondPassChecks << { println 'executed later' }
    // ...

The general schema would then be:

-   determine a *pointcut* where you push a new scope on stack and initialize custom variables within this scope

-   using the various events, you can use the information stored in your custom scope to perform checks, defer checks,...

-   determine a *pointcut* where you exit the scope, call `scopeExit` and eventually perform additional checks

### Other useful methods

For the complete list of helper methods, please refer to the gapi:org.codehaus.groovy.transform.stc.GroovyTypeCheckingExtensionSupport\[\] and  gapi:org.codehaus.groovy.transform.stc.TypeCheckingExtension\[\] classes. However, take special attention to those methods:

-   `isDynamic`: takes a VariableExpression as argument and returns true if the variable is a DynamicExpression, which means, in a script, that it wasn't defined using a type or `def`.

-   `isGenerated`: takes a MethodNode as an argument and tells if the method is one that was generated by the type checker extension using the `newMethod` method

-   `isAnnotatedBy`: takes an AST node and a Class (or ClassNode), and tells if the node is annotated with this class. For example: `isAnnotatedBy(node, NotNull)`

-   `getTargetMethod`: takes a method call as argument and returns the `MethodNode` that the type checker has determined for it

-   `delegatesTo`: emulates the behaviour of the `@DelegatesTo` annotation. It allows you to tell that the argument will delegate to a specific type (you can also specify the delegation strategy)

# Advanced type checking extensions

## Precompiled type checking extensions

All the examples above use type checking scripts. They are found in source form in classpath, meaning that:

-   a Groovy source file, corresponding to the type checking extension, is available on compilation classpath

-   this file is compiled by the Groovy compiler for each source unit being compiled (often, a source unit corresponds to a single file)

It is a very convenient way to develop type checking extensions, however it implies a slower compilation phase, because of the compilation of the extension itself for each file being compiled. For those reasons, it can be practical to rely on a precompiled extension. You have two options to do this:

-   write the extension in Groovy, compile it, then use a reference to the extension class instead of the source

-   write the extension in Java, compile it, then use a reference to the extension class

Writing a type checking extension in Groovy is the easiest path. Basically, the idea is that the type checking extension script becomes the body of the main method of a type checking extension class, as illustrated here:

    import org.codehaus.groovy.transform.stc.GroovyTypeCheckingExtensionSupport
    
    class PrecompiledExtension extends GroovyTypeCheckingExtensionSupport.TypeCheckingDSL {     
        @Override
        Object run() {                                                                          
            unresolvedVariable { var ->
                if ('robot'==var.name) {
                    storeType(var, classNodeFor(Robot))                                         
                    handled = true
                }
            }
        }
    }

-   extending the `TypeCheckingDSL` class is the easiest

-   then the extension code needs to go inside the `run` method

-   and you can use the very same events as an extension written in source form

Setting up the extension is very similar to using a source form extension:

    config.addCompilationCustomizers(
        new ASTTransformationCustomizer(
            TypeChecked,
            extensions:['typing.PrecompiledExtension'])
    )

The difference is that instead of using a path in classpath, you just specify the fully qualified class name of the precompiled extension.

In case you really want to write an extension in Java, then you will not benefit from the type checking extension DSL. The extension above can be rewritten in Java this way:

    import org.codehaus.groovy.ast.ClassHelper;
    import org.codehaus.groovy.ast.expr.VariableExpression;
    import org.codehaus.groovy.transform.stc.AbstractTypeCheckingExtension;


    import org.codehaus.groovy.transform.stc.StaticTypeCheckingVisitor;
    
    public class PrecompiledJavaExtension extends AbstractTypeCheckingExtension {                   
    
        public PrecompiledJavaExtension(final StaticTypeCheckingVisitor typeCheckingVisitor) {
            super(typeCheckingVisitor);
        }
    
        @Override
        public boolean handleUnresolvedVariableExpression(final VariableExpression vexp) {          
            if ("robot".equals(vexp.getName())) {
                storeType(vexp, ClassHelper.make(Robot.class));
                setHandled(true);
                return true;
            }
            return false;
        }
    
    }

-   extend the `AbstractTypeCheckingExtension` class

-   then override the `handleXXX` methods as required

## Using \@Grab in a type checking extension

It is totally possible to use the `@Grab` annotation in a type checking extension. This means you can include libraries that would only be available at compile time. In that case, you must understand that you would increase the time of compilation significantly (at least, the first time it grabs the dependencies).

## Sharing or packaging type checking extensions

A type checking extension is just a script that need to be on classpath. As such, you can share it as is, or bundle it in a jar file that would be added to classpath.

## Global type checking extensions

While you can configure the compiler to transparently add type checking extensions to your script, there is currently no way to apply an extension transparently just by having it on classpath.

## Type checking extensions and \@CompileStatic

Type checking extensions are used with `@TypeChecked` but can also be used with `@CompileStatic`. However, you must be aware that:

-   a type checking extension used with `@CompileStatic` will in general not be sufficient to let the compiler know how to generate statically compilable code from \"unsafe\" code

-   it is possible to use a type checking extension with `@CompileStatic` just to enhance type checking, that is to say introduce **more** compilation errors, without actually dealing with dynamic code

Let's explain the first point, which is that even if you use an extension, the compiler will not know how to compile your code statically: technically, even if you tell the type checker what is the type of a dynamic variable, for example, it would not know how to compile it. Is it `getBinding('foo')`, `getProperty('foo')`, `delegate.getFoo()`,...? There's absolutely no direct way to tell the static compiler how to compile such code even if you use a type checking extension (that would, again, only give hints about the type).

One possible solution for this particular example is to instruct the compiler to use [mixed mode compilation](#mixed-mode). The more advanced one is to use [AST transformations during type checking](#ast-xform-as-extension) but it is far more complex.

Type checking extensions allow you to help the type checker where it fails, but it also allows you to fail where it doesn't. In that context, it makes sense to support extensions for `@CompileStatic` too. Imagine an extension that is capable of type checking SQL queries. In that case, the extension would be valid in both dynamic and static context, because without the extension, the code would still pass.

## Mixed mode compilation

In the previous section, we highlighted the fact that you can activate type checking extensions with `@CompileStatic`. In that context, the type checker would not complain anymore about some unresolved variables or unknown method calls, but it would still wouldn't know how to compile them statically.

Mixed mode compilation offers a third way, which is to instruct the compiler that whenever an unresolved variable or method call is found, then it should fall back to a dynamic mode. This is possible thanks to type checking extensions and a special `makeDynamic` call.

To illustrate this, let's come back to the `Robot` example:

    robot.move 100

And let's try to activate our type checking extension using `@CompileStatic` instead of `@TypeChecked`:

    def config = new CompilerConfiguration()
    config.addCompilationCustomizers(
        new ASTTransformationCustomizer(
            CompileStatic,                                      
            extensions:['robotextension.groovy'])               
    )
    def shell = new GroovyShell(config)
    def robot = new Robot()
    shell.setVariable('robot', robot)
    shell.evaluate(script)

-   Apply `@CompileStatic` transparently

-   Activate the type checking extension

The script will run fine because the static compiler is told about the type of the `robot` variable, so it is capable of making a direct call to `move`. But before that, how did the compiler know how to get the `robot` variable? In fact by default, in a type checking extension, setting `handled=true` on an unresolved variable will automatically trigger a dynamic resolution, so in this case you don't have anything special to make the compiler use a mixed mode. However, let's slightly update our example, starting from the robot script:

    move 100

Here you can notice that there is no reference to `robot` anymore. Our extension will not help then because we will not be able to instruct the compiler that `move` is done on a `Robot` instance. This example of code can be executed in a totally dynamic way thanks to the help of a gapi:groovy.util.DelegatingScript\[\]:

    def config = new CompilerConfiguration()
    config.scriptBaseClass = 'groovy.util.DelegatingScript'     
    def shell = new GroovyShell(config)
    def runner = shell.parse(script)                            
    runner.setDelegate(new Robot())                             
    runner.run()                                                

-   we configure the compiler to use a `DelegatingScript` as the base class

-   the script source needs to be parsed and will return an instance of `DelegatingScript`

-   we can then call `setDelegate` to use a `Robot` as the delegate of the script

-   then execute the script. `move` will be directly executed on the delegate

If we want this to pass with `@CompileStatic`, we have to use a type checking extension, so let's update our configuration:

    config.addCompilationCustomizers(
        new ASTTransformationCustomizer(
            CompileStatic,                                      
            extensions:['robotextension2.groovy'])              
    )

-   apply `@CompileStatic` transparently

-   use an alternate type checking extension meant to recognize the call to `move`

Then in the previous section we have learnt how to deal with unrecognized method calls, so we are able to write this extension:

**robotextension2.groovy**

    methodNotFound { receiver, name, argList, argTypes, call ->
        if (isMethodCallExpression(call)                        
            && call.implicitThis                                
            && 'move'==name                                     
            && argTypes.length==1                               
            && argTypes[0] == classNodeFor(int)                 
        ) {
            handled = true                                      
            newMethod('move', classNodeFor(Robot))              
        }
    }

-   if the call is a method call (not a static method call)

-   that this call is made on \"implicit this\" (no explicit `this.`)

-   that the method being called is `move`

-   and that the call is done with a single argument

-   and that argument is of type `int`

-   then tell the type checker that the call is valid

-   and that the return type of the call is `Robot`

If you try to execute this code, then you could be surprised that it actually fails at runtime:

    java.lang.NoSuchMethodError: java.lang.Object.move()Ltyping/Robot;

The reason is very simple: while the type checking extension is sufficient for `@TypeChecked`, which does not involve static compilation, it is not enough for `@CompileStatic` which requires additional information. In this case, you told the compiler that the method existed, but you didn't explain to it **what** method it is in reality, and what is the receiver of the message (the delegate).

Fixing this is very easy and just implies replacing the `newMethod` call with something else:

**robotextension3.groovy**

    methodNotFound { receiver, name, argList, argTypes, call ->
        if (isMethodCallExpression(call)
            && call.implicitThis
            && 'move'==name
            && argTypes.length==1
            && argTypes[0] == classNodeFor(int)
        ) {
            makeDynamic(call, classNodeFor(Robot))              
        }
    }

-   tell the compiler that the call should be make dynamic

The `makeDynamic` call does 3 things:

-   it returns a virtual method just like `newMethod`

-   automatically sets the `handled` flag to `true` for you

-   but also marks the `call` to be done dynamically

So when the compiler will have to generate bytecode for the call to `move`, since it is now marked as a dynamic call, it will fall back to the dynamic compiler and let it handle the call. And since the extension tells us that the return type of the dynamic call is a `Robot`, subsequent calls will be done statically!

Some would wonder why the static compiler doesn't do this by default without an extension. It is a design decision:

-   if the code is statically compiled, we normally want type safety and best performance

-   so if unrecognized variables/method calls are made dynamic, you loose type safety, but also all support for typos at compile time!

In short, if you want to have mixed mode compilation, it **has** to be explicit, through a type checking extension, so that the compiler, and the designer of the DSL, are totally aware of what they are doing.

`makeDynamic` can be used on 3 kind of AST nodes:

-   a method node (`MethodNode`)

-   a variable (`VariableExpression`)

-   a property expression (`PropertyExpression`)

If that is not enough, then it means that static compilation cannot be done directly and that you have to rely on AST transformations.

## Transforming the AST in an extension

Type checking extensions look very attractive from an AST transformation design point of view: extensions have access to context like inferred types, which is often nice to have. And an extension has a direct access to the abstract syntax tree. Since you have access to the AST, there is nothing in theory that prevents you from modifying the AST. However, we do not recommend you to do so, unless you are an advanced AST transformation designer and well aware of the compiler internals:

-   First of all, you would explicitly break the contract of type checking, which is to annotate, and only annotate the AST. Type checking should **not** modify the AST tree because you wouldn't be able to guarantee anymore that code without the *\@TypeChecked* annotation behaves the same without the annotation.

-   If your extension is meant to work with *\@CompileStatic*, then you **can** modify the AST because this is indeed what *\@CompileStatic* will eventually do. Static compilation doesn't guarantee the same semantics at dynamic Groovy so there is effectively a difference between code compiled with *\@CompileStatic* and code compiled with *\@TypeChecked*. It's up to you to choose whatever strategy you want to update the AST, but probably using an AST transformation that runs before type checking is easier.

-   if you cannot rely on a transformation that kicks in before the type checker, then you must be **very** careful

The type checking phase is the last phase running in the compiler before bytecode generation. All other AST transformations run before that and the compiler does a very good job at \"fixing\" incorrect AST generated before the type checking phase. As soon as you perform a transformation during type checking, for example directly in a type checking extension, then you have to do all this work of generating a 100% compiler compliant abstract syntax tree by yourself, which can easily become complex. That's why we do not recommend to go that way if you are beginning with type checking extensions and AST transformations.

## Examples

Examples of real life type checking extensions are easy to find. You can download the source code for Groovy and take a look at the [TypeCheckingExtensionsTest](https://github.com/apache/groovy/blob/master/src/test/groovy/transform/stc/TypeCheckingExtensionsTest.groovy) class which is linked to [various extension scripts](https://github.com/apache/groovy/tree/master/src/test-resources/groovy/transform/stc).

An example of a complex type checking extension can be found in the [Markup Template Engine](../markup-template-engine.html) source code: this template engine relies on a type checking extension and AST transformations to transform templates into fully statically compiled code. Sources for this can be found [here](https://github.com/apache/groovy/tree/master/subprojects/groovy-templates/src/main/groovy/groovy/text/markup).
