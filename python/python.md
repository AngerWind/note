## python注释

- 单行注释

  ```python
  # 这里是单行注释, #与内容之间有一个空格
  print("hello")  # hello, 语句与注释添加两个空格
  ```

- 多行注释

  ```python
  """
     双引号多行注释
  """
  '''
     单引号多行注释
  '''
  ```

  

## 导入包或者模块

- 导入模块

  - import 模块 [as 别名]

    调用: 模块名.功能名

    ```python
    import math as m
    m.sqrt(9)   # sqrt是根号
    ```

  - from 模块 import 功能 [as 别名]

    调用:  功能名()

    ```python
    from math import sqrt as s
    s(9)
    ```

  - from 模块 import *

    调用: 功能名()

    ```python
    from math import *
    sqrt(9)
    ```

  

- 导入包

  - import 包名 [as 别名]

  - from 包名 import *

    ```python
    import sound
    from sound import *
    
    # https://www.jianshu.com/p/178c26789011
    
    """
    1. 在 from sound import *和 import sound 语句中，如果 __init__.py 中定义了 __all__ 魔法变量，那么在__all__内的所有元素都会被作为模块自动被导入（ImportError任然会出现，如果自动导入的模块不存在的话）。
    2. 如果 __init__.py 中没有 __all__ 变量，导出将按照以下规则执行：
       1. 此 package 被导入，并且执行 __init__.py 中可被执行的代码
       2. __init__.py 中定义的 variable 被导入
       3. __init__.py 中被显式导入的 module 被导入
       
    """
    ```

  - import 包名.模块名



## 函数参数

### 1. 位置参数

位置参数：根据参数位置来传递参数

```python
def add(a, b):
    return a + b
add(1, 2)
```

### 2. 关键字参数

关键字参数: 通过形参名来传递参数

<font color=red>如果有位置参数时，位置参数必须在关键字参数的前面，但关键字参数之间不存在先后顺序</font>

```python
def add(a, b, c):
    return a + b + c

add(10, c=20, b=30)
```

### 3. 默认参数

调用函数时可不传该默认参数的值

<font color=red>所有位置参数必须出现在默认参数前，包括函数定义和调用</font>

```
def add(a, b, c=10):
    return a + b +c
add(10, 10)
```

### 不定长参数

- 包裹位置传递

  <font color=red>传进的所有参数都会被args变量收集，它会根据传进参数的位置合并为一个元组(tuple)，args是元组类型</font>

  ```python
  def add(*args):
      print(args)
  add(18, 12, 13)  # (18, 12, 13)这是一个tuple
  ```

- 包裹关键字传递

  ```python
  def add(**kwargs):
      print(kwargs)
  add(name="张三", age=18)  #{"name" : "张三", "age" : 18} 这是一个map
  ```

  **无论是包裹位置传递还是包裹关键字传递，都是一个组包的过程。**