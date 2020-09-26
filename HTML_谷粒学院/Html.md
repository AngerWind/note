## HTML

#### 主要学习内容

![1553046600757](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553046600757.png)

**结构: HTML用于描述页面的结构**

**表现: css用于控制页面的元素的样式**

**行为: JavaScript用于相应用户的操作**

#### HTML骨架

```html
<html>
    <head>
        <!-- 这里面写的内容告诉浏览器如何去解析我们的网页 -->
    </head>
    <body>
        <!-- 这里写一切我们希望用户看到的内容 -->
    </body>
</html>


```

#### 相关标签

**关于样式的标签不建议使用,因为样式应该使用css来表现**

**在html中,任何多的空格和换行在显示的时候都会被当成一个空格**



```html
<title>
    <!-- 这里面写网页的 -->
</title>
```
```html
<h1>
	<!-- 这是一个一级标题,相应的还有h2, h3, h4 -->
</h1>
```

```html


<h1>
    这是我的<font color="blue">第二个</font>网页
</h1>
```
效果:

<h1>
    这是我的<font color="blue">第二个</font>网页
</h1>


```html
<p>  
    <!-- 段落标签 -->
</p>

<!-- br标签是一个换行标签 -->
<br />

<!-- hr是水平分割线 -->
<hr>
```

```html
<meta charset="UTF-8"/>
<!-- 关键字和网页描述被搜索引擎用来检索网页的大致内容 -->
<!-- 指定网页的关键字-->
<meta name="keywords" content="HTML5, java"/>
<!-- 设置网页的描述 -->
<meta name="description" content="发布h5, js前端相关信息" />
<!-- meta标签除了可以定义html使用的编码方式还可以定义其他的元数据 -->
```

![1553051670859](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553051670859.png)

![1553051698441](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553051698441.png)

<!-- 超链接文本 -->

<!-- target表示在何处打开新连接, _self在当前页面打开, _blank在新的页面打开,默认是_self -->

<!-- 在创建超链接是,如果连接地址不确定,可以使用#占位符, href="#",在使用占位符后,点击链接会回到当前页面的顶部 -->

<!-- 对于HTML中的每一元素,都可以定义他的id,在a标签中使用href="#id属性值"就可以跳转到该标签的位置-->

<a href="www.baidu.com" target="_self">

#### html的版本声明

声明html的版本,这段内容写在文件的开始部分,推荐使用h5的版本:

![1553049267642](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553049267642.png)

![1553049316980](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553049316980.png)

![1553049427291](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553049427291.png)

#  

#### 转义字符

```html
<   &lt;
>	&gt;
空格	&nbsp;
版权符号 &copy;
```

![1553071617910](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553071617910.png)

**更多的转义字符前往w3c查找**

#### 图片标签:image

![1553072256517](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553072256517.png)

#### HTML中的语法规范

1. HTML中不区分大小写

2. 注释不能嵌套

3. HTML标签结构必须完整,要么成对出现,要么自结束标签

4. HTML标签可以嵌套,但是不能交叉嵌套

5. HTML标签中的属性必须有值,且值必须加引号,单引号双引号都行

   
## CSS

   

#### CSS基础

css可存在的地方:

​	1.内联样式: 可以将css写在标签的style属性当中:<p style="color:red;"></p>,  <p style="color:red;font-size:40px;"></p>

​	2.还可以在head标签中写css样式:

<head>
    <!-- 这个type属性一般是固定写法 -->
    <style type="text/css">
        /* 这是给当前页面的所有p标签设置样式 */
        </style>
</head>


​	3.外部样式表:还可以将样式写到外部的css文件中,然后通过link标签来将外部的css文件引入到当前的页面中,这样外部文件中的css样式将会应用到当前页面中:

<head>
    <!-- rel和type属性是一般写法,不改变,href是需要引入的css样式文件的地址
		这样引入css样式表将会直接应用到当前文件中 -->
    <link rel="stylesheet" type="text/css" href="style.css" />
</head>

```css
/* 在css文件中写如下内容,不需要其他的东西 */
p{
	color:red;
	font-size:40px;
}
```

#### CSS语法(选择器和声明块)

在<style></style>标签中的内容已经不算HTML的内容了,算是CSS的内容,尽管他可以写在html网页中,所以css文件中或者<style>标签中的内容应该遵守css的语法而不是html中的语法,比如css中的注释为/* */而html中的注释为<!-- -->

css语法:

​	选择器   声明块

选择器:

​	通过选择器可以选中页面中指定的标签,并将生声明块中的样式运用到选择器对应样上.

声明块:

​	声明块紧跟在选择器后面,使用一对{}括起来

​	声明块实际上就是一组一组的名值对结构,

​	每个名值对分号结尾

​	样式名和样式值使用:来连接

```css
/* 在这个样式表中,p是选择器,选中<p>标签, 大括号中的是声明块 */
p{
    color:red;
    font-size:50px;
}
```

#### 常用的选择器

1. 标签选择器

   ```css
   /* 标签选择器就是为标签设置样式的,选择器的名字就是标签的名字,所以每一个标签都有一个标签选择器 */
   /* 这样写会给页面中所有的p标签都设置相同的样式 */
   p{
       color:red;
       font-size:20px;
   }
   ```

2. id选择器

   ```html
   <style>
    /* id选择器是以#开头,加上要选择标签的id名即可 */
   /* 这样写会给id为sdk的标签设置样式, 因为id在页面中的唯一性,所以这样一次只能设置一个标签 */
   #sdk{
    	color:red;
       font-size:20px;
   }
   </stype>
       
   <p id="sdk">这是一点内容</p>
   ```

   

3. 类选择器
   ```html
   <!--类选择器必须以点号开头,然后跟上类名 -->
   <!--这样写会将所有声明了class="man"的标签都设置样式 -->
   <style>
       .man{
            color:red;
       	font-size:20px;
       }
       .bcd{
           background:green;
       }
   </style>
   
   <p class="man">这是一个内容</p>
   <p class="man">这是一个内容</p>
   
   <!-- 一个标签可以设置多个class属性值,多个属性值之间使用空格隔开 -->
   <p class="man abc">这是一个内容</p>
   ```

4. 通用选择器

   ```html
   
   <!-- 通用选择器会为所有的标签设置样式, 写法就是*{} -->
   <style>
       *{
            color:red;
       	font-size:20px;
       }
   </style>
   
   <p class="man">这是一个内容</p>
   <p class="man">这是一个内容</p>
   ```

   

5. 选择器并集

   ```html
   <!-- 想为多个选择器设置一样的颜色是时可以使用选择器并集 -->
   <style>
       /* 这样写会为id选择器abc和标签选择器h1设置上相同样式, 两者之间使逗号隔开 */
       #abc, h1{
            color:red;
       	font-size:20px;
       }
   </style>
   ```
```html
  6. 选择器交集


<style>
    /* 这样写会为h1标签并且class="p2"的标签设置上样式, 两者之间不隔开隔开,直接连载一起写 */
    /* 对于id选择器不推荐使用选择器交集, 因为每一个id选择器都对应唯一的一个标签 */
    h1.p2{
         color:red;
    	font-size:20px;
    }
</style>
```

​    7.后代选择器

元素之间的关系:

​	父元素:直接包含子元素

​	子元素:直接被父元素包含

​	祖先元素:直接或间接包含后代的元素

​	后代元素:直接或间接被祖先包含的元素

​	兄弟元素:拥有相同父元素的元素

```html
<!-- 后代选择器的写法,两个选择器之间使用空格隔开 -->
<style>
    div p{
        /* 这样写标签div的后代元素p */
    }
    #dk p span{
        /* 这样写表示id="dk"的后代元素p的后代元素span */
    }
</style>
```

​    8.子元素选择器
```html
<!-- 子选择器的写法,两个选择器之间使用>隔开 -->

<style>
    div>p{
        /* 这样写标签div的子元素p */
    }
    #dk>p{
        /* 这样写表示id="dk"的子元素p */
    }
</style>
```

#### 块元素和内联元素

内联元素:只占自身大小,不会独占一行,如a, span,

块元素: 独占一行,,如div, p

<a>标签中可以放任何元素

<p>中不能放任何块元素,包括自身

```html
<div>
    <!-- div是一个典型的块元素,主要用来做页面的布局 -->
</div>
<span font-size="20px">
    <!--想要为文本设置样式就要使用标签将文本括起来,然而其他的标签会有一些其他的默认样式路center标签,这时我们就需要不带任何样式的标签来选中文本,span就是这个时候使用的 -->
    <!--span标签专门用来选中文字然后设置文本的样式-->
    这是一段内容
</span>

```

#### 样式的继承

在CSS中,祖先元素的样式会被后代元素继承,利用继承可以将一些基本的样式设置给祖先元素,这样所有后代元素就会自动继承这些样式.

但是有一些样式不会被继承,比如北背景相关的样式. 具体是否被继承可以查询w3c的离线手册,查看样式具体的几继承性.

#### 样式选择器的优先级

优先级规则:

内联样式>id选择器>类选择器和伪类选择器>通配选择器*>继承的样式

同样优先级的样式选择在<style>中声明靠后的

选择器并集是分开算优先级的,如

```html
<style>
    /* 这将的选择器交集就相当于选择器分开写,所以优先级是分开算的 */
    p, .man{
    }
    /*
    p{
    }
    .man{
    }
    */
/style>

```

选择器交集的优先级比其中优先级最大的大一点

```html
<style>
    /* 这个交集选择器中最大有限级是类选择器,所以这个选择器的优先级比类选择器大一点,但是不会超过id选择器和内联样式,只是大一点 */
    p.man{
    }
</style>
```



## 表单

表单的作用:将用户所填写的信息提交给服务器

​	比如:百度的搜索框,注册, 登录这些操作都需要填写表单

#### 基本表单的创建

```html
<!-- 表单中必须指定action的属性, 该属性指向的是一个服务器地址
		当我们提交表单时会将信息提交到action属性对应的地址 -->
<form action="">
    <!-- form创建的仅仅是一个空白的表单,我们还需要向form表单中添加不同的表单项 -->
    <!-- 使用input来创建一个文本框,必须添加name属性来告诉服务器提交的内容,否则表单项内容将不会提交 -->
    <!-- 使用value来设置表单项中的默认内容 -->
    用户名:<input type="text" name="username" value="admin"/> <br>
    <!-- 密码框也是使用input, type="password" -->
    密码:<input type="password" name="password" /> <br>
    <!-- 提交按钮可以将表单中的信息提交给服务器,也是使用input来创建提交按钮,但是type="submit",value值表示提交按钮上的字的内容 -->
    <input type="submit" value="注册"/>  
</form>
```

效果如下:

![1553241934551](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553241934551.png)

#### 单选框

```html
<form action="">
    <!-- 使用radio来指定这是一个单选按钮,使用name来进行分组,name相同的是一组,还需要指定value来确定按钮所表示的内容 -->
    性别:<input type="radio" name="gender" value="male"/>男		<input type="radio" name="gender" value="female"/>女 <br>

    <input type="submit" value="注册"/>  
</form>
```

![1553244251889](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553244251889.png)

![1553244303388](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553244303388.png)

#### 多选框

```html
<form action="">
    <!-- 使用checkbox来指定这是一个单选按钮,使用name来进行分组,name相同的是一组,还需要指定value来确定按钮所表示的内容 -->
    爱好:<input type="checkbox" name="hobby" value="basketball"/>篮球<br>		
    <input type="checkbox" name="hobby" value="yumao"/>羽毛球 <br>
    <input type="checkbox" name="hobby" value="football"/>足球

    <input type="submit" value="注册"/>  
</form>
```

![1553245096061](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553245107296.png)

![1553245121627](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553245121627.png)

#### 单选按钮和多选按钮的默认选择值

如果希望在单选按钮或者多选按钮中选中指定的选择,可以在希望选中的选项中添加checked="checked"属性

```html
<form action="">
    爱好:<input type="checkbox" name="hobby" value="basketball" />篮球<br>		
    <input type="checkbox" name="hobby" value="yumao" checked="checked" />羽毛球 <br>
    <input type="checkbox" name="hobby" value="football" checked="checked" />足球

    <input type="submit" value="注册"/>  
</form>
```

<form action="">
    爱好:<input type="checkbox" name="hobby" value="basketball" />篮球<br>		
    <input type="checkbox" name="hobby" value="yumao" checked="checked" />羽毛球 <br>
    <input type="checkbox" name="hobby" value="football" checked="checked" />足球
    <input type="submit" value="注册"/>  
</form>


#### 下拉列表

```html
<form>
    <!-- 可以通过option中添加selected="selected"来将选项设置为默认选择 -->
    <select name="star">
        <option value="fbb">范冰冰</option>
        <option value="lxr" selected="selected">林心如</option>
        <option value="zbs">赵本山</option>
    </select>
</form>
```

<form>
    <select name="star">
        <option value="fbb">范冰冰</option>
        <option value="lxr" selected="selected">林心如</option>
        <option value="zbs">赵本山</option>
    </select>
</form>

#### 文本域

input所表示的文本框只是一个单行的文本框,然后我们想要写一个多行的文本域用来写自我介绍等内容较多的东西,可以使用textarea标签

```html
<form>
    <textarea name="info"></textarea>
</form>
```

#### 重置按钮

如果想将表单中的所有改变都重置到最开始的状态可以使用重置按钮

```html
<form>
    <input type="reset" value="重置" />
</form>
```

#### 普通按钮

```html
<form>
    <!-- 除了可以使用input标签来创建按钮,还可以直接使用button来创建按钮 -->
    <input type="button" value="按钮" />
    
    <!-- button的值就是button标签中的文字, 这种方式比input方式的按钮跟灵活,因为button标签中可以放置其他的东西 -->
    <button type="submit">提交按钮</button>
    <button type="reset">重置按钮</button>
    <button type="button">普通按钮</button>
</form>

```

#### lable标签

```html
<!-- 在表单中我们还可以专门使用lable标签将文本框前面的提示文字括起来,这样可以方便给这些文字设置样式,使用for属性指定这个lable标签服务的对象的id,将两者绑定在一起 -->
<!-- 以前使用的方法只是在文本框前面有提示文字,告诉用户文本框中应该输入的内容,但是两者直接并没有关系,只是并排在一起. 但是使用lable标签后,可以将提示文字和文本框联系在一起,这样用户点击提示文字时文本框也会被focus -->
<form>
    <!-- 普通文本框 -->
    <lable for="username">用户名:</lable>
    <input type="text" name="username" id="username"/>
    <br>
    <lable for="password">密码:</lable>
    <input type="text" name="password" id="password"/>
    <br>
    <!-- 单选按钮 -->
    <input type="radio" name="gender" id="female"><lable for="female">女</lable>
    <input type="radio" name="gender" id="male"><lable for="male">男</lable>
</form>
```

#### 长表单分组

当表单要填写的内容太长时,我们可以使用<fieldset>标签来给表单项分组

````html
<form action="">
	<fieldset>
        <legend>
            用户信息
        </legend>
        <lable for="username">用户名:</lable>
        <input type="text" name="username" id="username"> <br>
        <lable for="passworld">密码:</lable>
        <input type="passworld" name="password" id="password">
    </fieldset>
    <fieldset>
        <legend>
            其他信息
        </legend>
        性别:<input type="radio" name="gender" id="female">
        <lable for="female">女</lable>
        <input type="radio" name="gender" id="male">
        <lable for="female">男</lable>
        <br>
        明星:<input type="checkbox" name="star" id="fbb">
        <lable for="female">范冰冰</lable>
        <input type="checkbox" name="star" id="zbs">
        <lable for="female">赵本山</lable>
        <br>
    </fieldset>
</form>
````

![1553409558892](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553409558892.png)



## JavaScript

#### helloworld

````html
<!doctype>
<html>
    <head>
        <script>
            alert("helloworld");
            document.write("document");
            console.log("console");
        </script>
    </head>
    <body>
        
    </body>
</html>
````

js代码是又上往下执行的,当一条没有执行完时下面的代码会等待他执行完再执行

![1553412794970](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553412794970.png)

只有当点击确定之后alert("helloworld")才算执行完,才会执行后面的语句



#### js书写的位置

1. 可以将js代码写在标签的onlcick属性中,当我们点击标签时,js代码才会执行

   ````html
   <button onclick="alert('点我');">点我一下</button>
   ````

2. 还可以将js代码写在a标签的href属性中,这样当点击超链接时,会执行js代码

   ````html
   <a href="javascript:alert('点一下我');">
       点一下</a>
   ````

   ```html
   <!-- 这样写的话,当点击链接的时候,不会执行任何js代码, 这种方式也非常常用 -->
   <a href="javascript:;">点一下</a>
   ```

3.  还可以将js代码写在<script>标签中

   ````html
   <html>
       <head>
           <script type="text/javascript"></script>
       </head>
       <body>
           
       </body>
   </html>
   ````

4. 写在js外部文件,然后使用script标签的src属性来引入, scirpt标签一旦用来引入外部的js文件,就不能再在里面写js代码了, 如果需要的话可以再新建一个script来执行

   ````html
   <html>
       <head>
           <!--scirpt标签一旦用来引入外部的js文件,就不能再在里面写js代码了 -->
           <script type="text/javascript" scr="js/script.js">
               /* 这一句不会被执行 */
               alert("内部js");
           </script>
           <script>
               alert("这就会被执行");
           </script>
       </head>
       <body>
           
       </body>
   </html>
   ````

   

#### js中的数据类型

1. String

   var a="hello";

2. Number

   var b=123456;

3. Boolean

4. Null

   var c = null;

   虽然c是null,但是c的类型还是object;

5. Undefined

   没有初始化的变量类型就是undefined;

   var a;

   这个a的类型就是undefined;

6. Object

7. 数组

js变量均为对象,声明一个变量的时候,就声明了一个新的对象



#### js数据类型转换

1. 其他数据类型转换为String, 调用要转换数据的toString方法或者String()函数;

   var a = 123;

   console.log(typeof a);

   var b = a.toString();

   console.log(typeof b);

![1553418479594](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553418479594.png)

2. 其他数据类型转换为Numble类型,使用Numble()函数;boolean类型会被转换成01;null转换成0;

   var a = "19";

   var b = Number(a);

#### js算数和赋值运算符

算数运算符: +, -, *, /, %, ++, --.

赋值运算符: =, +=, -=, *=, /=, %=.

#### js逻辑运算符

 &&: 短路与

||: 短路或

!: 非

![1553421831475](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553421831475.png)

![1553421855094](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553421855094.png)

#### +和逻辑运算符的特殊用法

字符串的加法: 使用+还可以进行字符串的加法

````js
var t1 = "hello";
var t2 = "world";
var t3 = t1 + t2; //t3 = "helloworld"
//在这里就是字符串的拼接
//如果要两个字符串之间增加一个空格,如下
var t4 = t1 + " " + t3; //t4 = "hello world"

````

字符串加数字:先将数字转换为字符串,然后进行拼接

```js
var t = "hello";
var b = 123;
var h = t + b;
```

![1553421428323](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553421428323.png)

使用&&和||对字符串和数字进行运算:

​	先将字符串和数字转换为bool值,然后进行运算

​	空制符串为false,其他为true

​	数字0为false,其他为true

## 对象

#### 对象种类

内建对象:由ES标准中定义的对象,如:Math, String, Number, Boolean, Function, Object....

宿主对象: 由运行环境提供的对象, 目前来讲主要指由浏览器提供的对象, 如BOM, DOM, DOM和BOM都代表一系列的对象,如document

自定义对象: 由开发人员自己定义的对象

#### 自定义对象

````js
/* 第一种方式: 构造函数 */
var obj = new Object();

/* 向obj中添加属性 */
obj.name = "孙悟空";
obj.gender = "man";
obj["age"] = 18;
obj.sayHello = function(){
    console.log("hello");
}

/* 读取obj中没有的属性并不会报错, obj.hello undefined */
console.log(obj.hello)

/* 删除对象中的属性 */
delete obj.name;

// 使用in来判断对象中是否含有一个属性
console.log("gender" in obj);
````

````js
/* 第二张方式 */
/* 属性之间使用逗号隔开, 最后一个属性后面不用逗号 */
var obj = {
    name: "孙悟空",
    gender: "man",
    age: 18,
    test: {
        name: "沙和尚"
    }
    sayHello: function(){
        console.log("hello");
    }
};
````



## 函数

#### 函数的创建

````js
/* js函数不支持重载, 重载即覆盖 */ 
var fun = new Function("console.log('hello world');");

function fun2(){
    console.log("hello world");
}

var fun = function(){
    console.log("hello world");
};
````

#### 函数的参数

````js
function sum(a, b){
    console.log(a + b);
}
/* 调用函数时,解析器不会检查实参的类型, 所以要注意是否有可能接受到非法的参数
	如果有可能则需要对类型进行检查 */
/* 调用函数时, 解析器也不会检查实参的数量, 多余的实参会被丢弃掉 */
/* 如果实参数量小于形参, 则没有对应实参的形参是undefined */
console(sum(123, 159, "hello", null);
/* 也可以将函数,对象当做实参传递给函数的形参 */
````

![1553482607432](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553482607432.png)![1553482615092](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553482615092.png)

#### 函数返回值

````js
/* 普通类型 */
function sum(a, b, c){
    return a + b + c;
}
/* 对象 */
function fun(){
    return {
        name: "孙悟空",
        age: 18"
    };
}
/* 函数 */
function fun(){
    // 函数中还可以创建函数
    var fun1 = function(a, b, c){
        return a + b + c;
    }
    return fun1;
}  
/* fun()()就相当于fun1(); */
a = fun();
console.log(a(1, 2, 3));
console.log(fun()(1, 2, 3));

````

#### 立即执行函数

立即执行函数在写完就会被调用,写法有点像匿名函数

````js
// 下面创建了一个fun函数
var fun = function(){
};
//下面创建了一个匿名函数
function(){  
};
//下面创建一个立即执行函数
//先创建一个匿名函数, 然后用括号括起来,表示一个整体, 然后在后面加()表示调用
(function(a, b){
    console.log(a + b);
})(3, 2);
````

#### 使用for in枚举对象中的属性

````js
var person = {
    name: "孙悟空",
    age: 18,
    sayHello: function(){
        console.log("hello");
    }
};
for(var n in person){
    console.log(n + " " + person[n]); 
}
````

![1553487906657](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553487906657.png)

#### js作用域

全局作用域: 

​	直接写在script标签中的js代码, 都是全局作用域

​	全局作用域在界面创建是创建,在页面关闭时销毁

​	在全局作用域中有一个全局变量window, 我们可以直接使用,他代表的是当前的窗口

​	在全局作用域中创建的变量都会作为window对象的属性被保存

​	创建的函数都会作为window对象的方法保存

````js
var a = 10;
console.log(window.a);

function fun(){
    d = 100;  
}
window.fun();
````

函数作用域:

​	在函数作用域中可以访问全局作用域中的变量

````js
var a = 10;
function fun(){
    console.log(a);
}
fun();
````

​	在函数作用域操作一个变量时, 他会先在自身作用域中寻找, 如果有就直接使用, 如果没有就前往上一级作用域中寻找, 直到全局作用域. 如果仍然没有则报错.

​	如果要再函数中直接使用全局作用域中的变量, 可以直接使用window.

​	

#### 声明提前

**声明提前不管在函数作用域中还是在全局作用域中都存在.只不过函数作用域中的声明提前仅限于函数作用域.**

变量的声明提起:

​	对于使用var 声明的对线, 会在所有代码执行之前被声明, 但是只有执行到该语句是才会被赋值

````js
console.log(a);
var a = 10;

var a;
console.log(a);
a = 10;
````

函数的声明提前:

​	对于使用函数声明function 函数(){}创建的函数,会在所有代码执行之前被创建

​	而对于使用var fun = function(){}创建的函数, 会在所有代码执行之前声明fun,但是此时fun为undefined类型, 只有到执行该函数声明时才会对fun赋值

````js
sayHello();
function sayHello(){}  //这段函数声明会被提前,在所有代码执行之前被执行
````

````js
var fun = function(){};
// 上面相当于
var fun;   //这段会在任何代码执行之前被执行
fun = function(){};  //这段只会在执行var fun = function(){}时才进行赋值
````

#### 构造函数创建对象

````js
/* 构造函数与普通函数声明没有区别, 但是首字母一般大写 */
/* 在调用方式上, 构造函数使用new来调用 */
function Person(name, age, gender){
    this.name = name;
   	this.age = age;
    this.gender = gender;
}
var p = new Person("烧烤味", 18, "man");
````

#### instanceof

使用instanceof来判断一个对象是否是类的实例

````js
console.log(p instanceof Person);
````

#### 原型对象

​	当创建函数时,同时会在函数中创建一个属性prototype, 当创建的函数作为普通函数时,这个prototype对象没有任何作用, 当这个函数作为构造函数被调用的时候, 他所创建的每一个对象都会有这个这个属性, 这个属性相当于java中静态的属性

​	**当我们访问对线的一个属性或方法时, 他会先在对象自身中寻找, 如果有则直接使用, 如果没有会去原型中寻找, 如果有直接使用, 没有就前往原型中的原型寻找, 如果还没有就保错**

​	**使用in坚查对象中是否含有有个属性时,对象中没有但是原型中有, 也会返回true**

**使用hasOwnProperty()函数可以检查自身中有没有某个属性, 而不会检查原型**

````js
function Person(a){
    this.name = a;
}
Person.prototype.sayName = function(){
    console.log(this.name);
}
console.log(Person.prototype);
console.log(Person.prototype.prototype);
console.log(Person.prototype.prototype.prototype);
console.log(Person.prototype.prototype.hasOwnProperty(toString));
var p = new Person("swk");
var p1 = new Person("zbj");
p.sayName();
p1.sayName();
console.log(p.prototype == p1.prototype);
````

#### toString方法

````js
function Person(name, age, gender){
    this.name = name;
    this.age = age;
    this.gender = gender;
}
Person.prototype.toString = function(){
    return this.name + this.age + this.gender;
}
var p = new Person("swk", 18, "man");
console.log(p);
````

![1553566262078](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553566262078.png)

#### js正则表达式

使用构造函数创建正则表达式:

````js
/* 语法  var 变量 = new RegExp(a, b);
	其中a代码正则表达式, b表示匹配模式, ab均为字符串 */
/* a表示字符串中含有a即可,i表示忽略大小写
	a|b表示字符串中含有a或者含有b即可, |表示或
 	[]里的内容也是或关系 a|b和[ab]相同
 	[a-z]表示任意小写字母
 	[A-Z]表示任意大写字母
 	[A-z]表示任意字母
 	[0-9]表示任意数字
*/
var reg = new RegExp("a", "i"); 
console.log(reg.test("abc"));  //true

var reg = new RegExp("[A-z]", "i"); //含有任意字母即可
console.log(reg.test("abc")); //true

//检测一个字符串中是否含有abc或者adc或者aec
var reg = new RegExp("abc|adc|aec");// 或者a[bde]c
````

使用字面量创建正则表达式:

````js
/* 语法: var 变量 = /正则表达式/匹配模式 */
var reg = /ab/i;
console.log(reg.test("abcd"));
//检测一个字符串中是否含有abc或者adc或者aec
var reg = /abc|adc|aec/; // 或者/a[bde]c/
````

## DOM

#### 对象种类

内建对象:由ES标准中定义的对象,如:Math, String, Number, Boolean, Function, Object....

宿主对象: 由运行环境提供的对象, 目前来讲主要指由浏览器提供的对象, 如BOM, DOM, DOM和BOM都代表一系列的对象,如document

自定义对象: 由开发人员自己定义的对象

#### 什么是DOM

- DOM, Document Object Model文档对象模型

- js通过dom来对html文档进行操作, 只要理解了dom就可以随心所欲的操作web页面

- 文档:  整个HTML网页文档

- 对象: 将网页中的每一个部分都转换成一个对象

- 模型: 使用模型来表示对象之间的关系, 这样方便我们获取对象

#### 节点
- 节点(node): 构成html中最基本的单元

- 常用节点分为四类:

  - 文档节点: 整个html文档

  - 元素节点: html文档中的标签

  - 属性节点: 元素中的属性

  - 文本节点: html标签中的文本内容

![1555470892258](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1555470892258.png)

- **html为我们提供了document对象, 代表当前页面, 通过该对线可以获取到当前页面的其他节点对象**

#### 事件

为按钮添加click事件

```html
<!-- 这种写法直接将js写在了<body>标签中, 加大了耦合度, 不推荐这种使用方法 -->
<button id="btn" value="按钮"></button>
<script>
    var btn = document.getElementById("btn");
    btn.onclick = function () {
        alert("hello");
        
    }
</script>
```
```html
<!-- 这种写法将js代码写在了<head>标签里面, 但是html是从上到下读取一行执行一行, 所以必须将btn的点击事件放在window的onload事件里面 -->
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script>
        //onload事件会在整个页面加载完成之后发生, 这样可以避免上述事情发生 -->
        window.onload = function () {
            var btn = document.getElementById("btn");
            btn.onclick = function () {
                alert("hello");
            }

        }
    </script>
</head>
```

#### 获取页面中元素的对象及对象属性

- getElementById(), 通过id属性获取**当前对象下的**对应的节点

  ```js
  //获取btn对象
  var btn = document.getElementById("btn");
  //为btn对象设置点击事件
  btn.onclick = function () {
      alert("hello");
  }
  ```

- getElementsByTagName(), 通过标签名获取**当前对象**下的一组对应的对象

  ```html
  <ul>
      <li id="dier">第二</li>
      <li id="diyi">第一 </li>
  </ul>
  <script>
      var li = document.getElementsByTagName("li");
      //遍历数组
      for(var i=0; i<li.length; i++){
          //获取li标签中的文本(标签和文本)和li的id属性的值
          alert(li[i].innerHTML + li[i].id);
          //
          alert(li[i].innerText + li[i].id);
      }
  </script>
  ```

- getElementByName(), 通过name属性获取**当前对象**下的对应的一组对象

  ```html
  <form action="" method="post">
      gender:
      <input type="redio" name="gender" id="female"><label for="female">女</label>
      <input type="redio" name="gender" id="male"><lable for="male">男</lable>
  </form>
  <script>
      var gender = document.getElementsByTagName("input");
      //遍历数组并输出input标签的id属性
      for(var i = 0; i < gender.length; i++){
           alert(gender[i].id);
      }
  </script>
  ```

- document.querySelector(), 通过选择器来查询一个对象, **如果符合条件的元素有多个, 那么只会返回第一个**

  ```html
  <div class="box">
  </div>
  <div class="box">
  </div>
  <div class="box">
  </div>
  <script>
      //只会返回第一个div对象
      var box = document.querySelector(".box");
  </script>
  ```

- document.querySelectorAll(), 通过选择器来查询一个对象, 如果符合条件的元素有多个, 那么返回全部

  ```html
  <div class="box">
  </div>
  <div class="box">
  </div>
  <div class="box">
  </div>
  <script>
      //返回一个数组
      var box = document.querySelector(".box");
      alert(box.length);
  </script>
  ```

- 获取标签的属性

  ```js
  //获取btn对象
  var btn = document.getElementById("btn");
  //通过对象名.属性名获取属性值
  
  //class因为是保留字, 所以获取class属性使用className
  alert(btn.id);
  ```

- previousSibling和previousElementSibling
```html
<!-- 两个li之间有换行, 会被转换成一个文本节点 -->
<!-- 注释会被转换成一个注释节点 -->
<div id="box">
    <ul id="ul">
        <li>第一个</li>
        <li id="one">第二个</li>
        <li>第三个</li>
    </ul>
    <p>我是第二个子节点</p>
</div>
```
```js
//previousSibling：获取元素的上一个兄弟节点；（既包含元素节点、文本节点、注释节点）
var one = document.getElementById("one");
console.log(one.previousSibling.nodeName);//#text

//previousElementSibling：获取上一个兄弟元素节点；（只包含元素节点）；
//如果已经是第一个节点返回null
console.log(one.previousElementSibling.nodeName);//LI

```

- childNodes, firstChild, lastChild

  ```js
  //childNodes, 属性, 表示当前节点的所有子节点
  //firstChild, 表示当前节点的第一个子节点
  //lastChild, 表示当前节点的最后一个节点
  ```

- innerHTML, innerText

  如果元素只包含文本，那么innerText和innerHTML返回相同的值。但是，如果同时包含文本和其他元素，innerText将只返回文本的表示，而innerHTML，将返回所有元素和文本的HTML代码.

![1555561129069](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1555561129069.png)

- document.body、document.documentElement和document.all

  body表示<body>标签,

  documentElement表示<html>标签

  all表示当前页面的所有标签

## JSON

#### 概述

​	JSON(javascript object notation)    js对象表示法

​	js中对象只要js认识, 其他语言都不认识, 而其他语言中的对象js也不认识, 所以在数据交换中, 需要一种大家都认识的格式来进行数据交换, JSON就是这样一个特殊格式的字符串, 这个字符串可以被任意语言所识别, 并且可以转换为任意语言中的对象, JSON在开发中主要用来进行数据交换.

#### js格式

​	json和js对象的格式一样, 只不过json字符串中的属性名必须加双引号, 其他和js语法一致

````js
var obj = '{"name":"swk", "age": "18", "gender": "man"}';
````



json分类:

​	对象:{}

​	数组[]

````js
var obj = '{"name":"swk", "age": "18", "gender": "man"}';
var arr = '[1, "hello", 5, "txt"]';
````

json中允许的值:

​	1.字符串 	2. 数值	3.布尔值	4.null	5.普通  对象	6.数组

#### json转js对象

````js
/* 在js中,为我们提供了一个工具类, 就叫json
	这个对象可以帮助我们将一个json转换为js对象, 也可以将一个js对象转换为json */
/* JSON.parse()可以将json字符串转换为js对象, 他需要一个json字符串作为参数, 会将该字符串转换为js对象并返回 */

var json = '{"name":"swk", "age": "18", "gender": "man"}';
var obj = JSON.parse(json);
console.log(obj.name);

var arr = '[1, "hello", 5, "txt"]';
var obj2 = JSON.parse(arr);
console.log(obj2);
console.lgo(obj2[2]);
````

#### js对象转json

````js
/* JSON.stringify()可以将一个js对象转换为json字符串
		这需要一个js对象作为参数, 会返回一个json字符串 */
var obj ={
    name: "zhangsan",
    age: 12,
    son: {
    	name: "lisi",
    	age: 19,
    	star:["fbb", "zbs"]
	}
};
var str = JSON.stringify(obj);
console.log(str);
````

![1553592587191](C:\Users\700-15\AppData\Roaming\Typora\typora-user-images\1553592587191.png)

