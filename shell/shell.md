#### shell交互式与非交互式，登录式与非登录式

> 查看是否交互式

~~~shell
[c.biancheng.net]$ echo $-
himBH

[c.biancheng.net]$ cat test.sh
#!/bin/bash
echo $-
[c.biancheng.net]$ bash ./test.sh
hB
~~~

**如果输出字母中包含i，则为交互式**



或者查看`PS1`的值，如果非空，则为交互式，否则为非交互式，因为非交互式会清空该变量。

~~~shell
[mozhiyan@localhost]$ echo $PS1
[\u@\h \W]\$

[c.biancheng.net]$ cat test.sh
#!/bin/bash
echo $PS1
[c.biancheng.net]$ bash ./test.sh
~~~



> 判断是否为登录式

执行`shopt login_shell`即可，值为`on`表示为登录式，`off`为非登录式。

> 同时判断登录式和交互式

~~~shell
echo $-; shopt login_shell
echo $PS1; shopt login_shell
~~~



> 常见的情况

登录交互式：

- 使用账号密码登录linux
- `ssh user@ip`通过ssh登录linux
- `su - user`切换用户

登录非交互式：

- `bash --login test.sh`选项执行脚本

非登录非交互式：

- `bash test.sh`直接执行脚本, 脚本是以非登录非交互方式执行的
- `ssh localhost a.sh`执行脚本, 脚本是以非登录非交互方式执行的

非登录交互式：

- 桌面环境下打开终端
- 直接在终端执行`bash`进入子进程
- `ssh user@ip "echo $PS1; shopt login_shell"`命令是通过非登录交互式执行的
- `su user`切换用户

这里特别要区分的是ssh执行的方式，

~~~shell
$ cat b.sh
#!/bin/bash
 echo $- && shopt login_shell
 
 # 这里执行b.sh,在脚本里面是非登录非交互式的
$ ssh localhost bash b.sh
hB
login_shell     off

 # 这里直接执行命令,命令时在非登录交互式下执行的
$ ssh localhost echo $- && shopt login_shell
himBHs
login_shell     off
~~~



> 登录式与非登录式区别

不同的运行方式， bash在启动时加载的配置文件不同，这会导致在不同运行方式下，环境变量不同。

#### shell配置文件

无论是否是交互式，是否是登录式，Bash  在启动时总要配置其运行环境，例如初始化环境变量、设置命令提示符、指定系统命令路径等。这个过程是通过加载一系列配置文件完成的，这些配置文件其实就是 Shell 脚本文件。

> 登录式shell

如果是登录式的 Shell首先会读取和执行 /etc/profiles。

接着会以 ~/.bash_profile、~/.bash_login 或者 ~/.profile的顺序**查找并执行第一个存在且可读的文件**。不同的 linux 发行版附带的个人配置文件也不同，有的可能只有其中一个，有的可能三者都有。

注意，/etc/profiles 文件还会嵌套加载 /etc/profile.d/*.sh（不同版本可能不同，具体请查看对应文件），请看下面的代码：

```shell
for i in /etc/profile.d/*.sh ; do
    if [ -r "$i" ]; then
        if [ "${-#*i}" != "$-" ]; then
            . "$i"
        else
            . "$i" >/dev/null
        fi
    fi
done
```


同样，~/.bash_profile 也使用类似的方式加载 ~/.bashrc(不同版本可能不同，具体查看对应文件)：

```shell
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
```

![image-20220617170329402](img/shell/image-20220617170329402.png)

当登录式bash退出时，会执行~/.bash_logout

> 非登录式shell

如果交互非登录式shell（类似`echo $PS1; shopt login_shell`）启动时，

- Ubuntu下, 读取并执行/etc/bash.bashrc和~/.bashrc
- Centos下, 读取并执行~/.bashrc

~/.bashrc 文件还会嵌套加载 /etc/bashrc，请看下面的代码：

```shell
if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi
```

![image-20220617185422765](img/shell/image-20220617185422765.png)

如果是非登录非交互式的话，会获取变量BASH_ENV的值，并将该值当做文件名进行执行。



> ssh网络调用bash

特别需要注意的是，bash会尝试判断他的标准输入是否来自一个网络(`ssh localhost echo $-`)，如果 bash 确定它正在以这种方式运行，它会从 ~/.bashrc读取并执行命令，前提文件存在并且可读。如果作为 sh 调用，它将不会执行此操作。 

特别坑的是，Ubuntu中的~/.bashrc文件的开头有这样一段代码, centos则没有：

~~~shell
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
~~~

也就是说，使用ssh执行脚本，在脚本里面是非登录非交互模式，所以即使当前bash加载了~/.bashrc文件，但是执行到了上述代码判断是非交互式就退出去了，导致和没有执行一样。所以如果希望在ssh网络调用某些脚本时，能够在脚本里面读取到某些环境变量，需要将export语句加在上述代码以前。（说的就是你，hadoop的start-dfs.sh, 老是读取不到java_home）



> sh调用bash

如果使用名称 sh 调用 bash时：

- 当作为登录式调用时，它首先尝试按顺序从 /etc/profile 和 ~/.profile 读取和执行命令。 
- 当作为名为 sh 的交互式 shell 调用时，bash 查找变量 ENV并将其用作要读取和执行的文件的名称。由于作为 sh 调用的 shell 不会尝试从任何其他启动文件读取和执行命令，因此 --rcfile 选项无效。
- 使用名称 sh 调用的非交互式 shell 不会尝试读取任何其他启动文件。

> 选项

`--init-file file`， `--rcfile file`: 如果是交互式shell，可以使用这两个选项指定配置文件，而不是默认的配置文件。

`--noprofile`: 如果是登录式，使用该选项可以禁用默认配置文件。

`--norc`：如果是交互式，使用该选项可以禁用默认配置文件。





#### 查看当前系统支持的shell解释器

~~~shell
cat /etc/shells 
/bin/sh # /bin/dash的软连接
/usr/bin/sh # /usr/bin/dash的软连接
/bin/bash 
/usr/bin/bash 
/bin/dash
/usr/bin/dash 
~~~

同时`/usr/bin/bash`其实就是`/bin/bash`的一个软连接



#### 查看默认的shell解释器

1. 方式1

   ~~~shell
   ll ll /bin/ | grep sh # /bin/sh其实就是/bin/dash的软连接, 所以默认的shell解释器就是dash
   lrwxrwxrwx  1 root root           4 10月 26  2022 sh -> dash
   
   ll /usr/bin | grep sh 
   lrwxrwxrwx  1 root root           4 10月 26  2022 sh -> dash
   ~~~

   通过上面, 我们发现`/bin/sh`是`/bin/dash`的软连接,  `/usr/bin/sh`是`/usr/bin/dash`的软连接

   **所以当前系统的默认shell解释器就是dash**

2. 方式2

   ~~~shell
   echo $SHELL
   /usr/bin/zsh
   ~~~

   `echo $SHELL`输出的是当前用户登录使用的shell环境,  **在默认情况下他与默认的shell解释器相同**,  但是用户也可以修改默认登录的shell解释器





#### 执行shell脚本的几种方式

1. 通过`bash`或者`sh` 和脚本的相对路径和绝对路径来调用脚本

   ~~~shell
   bash hello.sh
   sh /root/helo.sh
   ~~~

   因为bash和sh是在一个子shell中调用的脚本, 所有脚本不需要有`x(执行)`的权限

2. 直接通过`相对路径`和`绝对路径`来调用脚本

   ~~~shell
   /root/hello.sh
   ./hello.sh # 这里必须写./  如果直接写hello.sh, 那么会被当做一个命令, 从path中查找
   ~~~

   因为是在当前窗shell调用的脚本, 所以需要脚本有`x`的权限

   这种方式会根据脚本第一行中指定的shell解释器来执行

   

3. 通过`source`或者`.`来调用脚本

   ~~~shell
   source /root/hello.sh
   . hello.sh
   ~~~

   强制执行脚本, 忽略忽略脚本文件的权限

区别:  

1. 通过`source`或者`.`都是在当前shell调用的脚本, 所以脚本中修改了环境变量, 定义的局部变量在脚本退出后, 都还会再当前的shell中生效
2. 使用方式1, 2的本质都是在当前shell又启动了一个子shell, 然后在子shell中执行脚本, 所以脚本中修改了环境变量, 定义的局部变量在脚本退出后不会继续生效



## 变量

### 定义和使用变量

> 定义变量

~~~shell
variable=value
variable='value'
variable="value"
~~~

`=`左右不能有空格

在shell中，每一个变量的值都是字符串，无论是否使用引号。

如果需要指定类型可以使用`declare`关键字

> 使用变量

~~~shell
a=100
echo $a
echo "haha${a}"
~~~

`{}`是可选的，用于帮助解释器识别变量的边界

> 修改值

~~~shell
url="http://c.biancheng.net"
echo ${url}
url="/d/file/202003/tnqgclnw4zm1221"
echo ${url}
~~~

> 单引号和双引号的区别

单引号直接输出，双引号会对变量取值

~~~shell
url="http://c.biancheng.net"
website1='C语言中文网：${url}'
website2="C语言中文网：${url}"
echo $website1
C语言中文网：${url}

echo $website2
C语言中文网：http://c.biancheng.net
~~~

> 只读变量

~~~shell
readonly a=100 # 不能被unset
b=200
readonly b 
~~~

> 删除变量

~~~shell
a=100
unset a
~~~

unset不能删除只读变量



### shell变量作用域

shell变量的作用域分为三种

- 只能在函数内部使用，这叫做局部变量（local variable）；
- 仅当前 Shell 进程中使用，这叫做全局变量（global variable）；
- 在当前进程和子进程中使用，这叫做环境变量（environment variable）。

需要注意的是，默认情况下在shell 函数里面定义的也是全局变量

~~~shell
function add() {
 	a=99
}
echo $a
~~~

**想要定义局部变量需要加上local关键字, 否则默认为全局变量**

~~~shell
local a=99
~~~

> shell环境变量

全局变量只在当前 Shell 进程中有效，对其它 Shell 进程和子进程都无效。如果使用`export`命令将全局变量导出，那么他就成为了环境变量, 那么它就在所有的子进程中也有效了

**子进程通过`aa=xxx`修改了环境变量, 本质上是创建了一个全局变量, 覆盖了环境变量**

**通过 export 导出的环境变量只对当前 Shell 进程以及所有的子进程有效，如果最顶层的父进程被关闭了，那么环境变量也就随之消失了，其它的进程也就无法使用了，所以说环境变量也是临时的。**

只有将变量写入 Shell 配置文件中才能达到这个目的！Shell 进程每次启动时都会执行配置文件中的代码做一些初始化工作，如果将变量放在配置文件中，那么每次启动进程都会定义这个变量。



### shell命令替换

作用是将命令的**输出**结果复制给某个变量

~~~shell
variable=`commands`
variable=$(commands)
~~~

比如

~~~shell
# date是输出当前时间，将输出的时间赋值给time
time=$(date)
~~~



注意，如果被替换的命令的输出内容包括多行（也即有换行符），或者含有多个连续的空白符，那么在输出变量时应该将变量用双引号包围，否则系统会使用默认的空白符来填充，这会导致换行无效，以及连续的空白符被压缩成一个。请看下面的代码：

```shell
#!/bin/bash

LSL=`ls -l`
echo $LSL  #不使用双引号包围
echo "--------------------------"  #输出分隔符
echo "$LSL"  #使用引号包围
```

运行结果：

```
total 8 drwxr-xr-x. 2 root root 21 7月 1 2016 abc -rw-rw-r--. 1 mozhiyan mozhiyan 147 10月 31 10:29 demo.sh -rw-rw-r--. 1 mozhiyan mozhiyan 35 10月 31 10:20 demo.sh~
--------------------------
total 8
drwxr-xr-x. 2 root     root      21 7月   1 2016 abc
-rw-rw-r--. 1 mozhiyan mozhiyan 147 10月 31 10:29 demo.sh
-rw-rw-r--. 1 mozhiyan mozhiyan  35 10月 31 10:20 demo.sh~
```

所以，为了防止出现格式混乱的情况，我建议在输出变量时加上双引号。

> 反引号和$()区别

反引号很像单引号，不易辨别

反引号在多种shell中可用，而$()仅在bash shell中可用

$()支持嵌套，如`$(wc -l $(ls | sed -n '1p'))`



### shell位置参数

给shell脚本或者shell函数传递的参数，在内部可以使用$n的形式来接收，如$1表示第一个参数，$2 表示第二个参数，依次类推。如果参数个数太多，达到或者超过了 10 个，那么就得用`${n}`的形式来接收了，例如 ${10}、${23}

并且对于函数，shell没有所谓的形参和实参，所以在定义shell函数时不能带参数，而是直接调用位置参数



### shell特殊变量

$0 当前脚本文件名

$n (n>=1) 传递给函数或者脚本的参数

$# 传递给脚本的参数的个数

$* 传递给脚本的所有参数

$@ 传递给脚本的所有参数，当被双引号`" "`包含时，$@ 与 $* 稍有不同

$? 上一个命令的退出状态(exit 0)，或者函数的返回值(return 0)

$$ 当前脚本的PID、

> $*和$#的区别

当 $* 和 $@ 不被双引号`" "`包围时，它们之间没有任何区别，都是将接收到的**每个参数看做一份数据，彼此之间以空格来分隔。**

但是当它们被双引号`" "`包含时，就会有区别了：

- `"$*"`会将所有的参数从整体上看做一份数据，而不是把每个参数都看做一份数据。

- `"$@"`仍然将每个参数都看作一份数据，彼此之间是独立的。

比如传递了 5 个参数，那么对于`"$*"`来说，这 5 个参数会合并到一起形成一份数据，它们之间是无法分割的；而对于`"$@"`来说，这 5 个参数是相互独立的，它们是 5 份数据。

编写下面的代码，并保存为 test.sh：

```shell
#!/bin/bash

echo "print each param from \"\$*\""
for var in "$*"
do
    echo "$var"
done

echo "print each param from \"\$@\""
for var in "$@"
do
    echo "$var"
done
```

运行 test.sh，并附带参数：

~~~shell
[mozhiyan@localhost demo]$ . ./test.sh a b c
print each param from "$*"
a b c
print each param from "$@"
a
b
c
~~~







## 运算符

在默认情况下, 如果你直接定义`a=1+1`, 你会发现shell将`1+1`当做了字符串

~~~shell
a=1+1
echo $a
~~~

如果你想要进行数值运算的话, 可以使用`$((表达式))`或者`$[表达式]`

~~~shell
a=$[( 2 + 3 ) * 4]
echo $a # 20

b=$(( (2+3) * 4 ))
echo $b # 20
~~~



## if判断

### 条件判断的方式

在linux中, 想要判断有两种方式

1. 通过`test condition`来判断, 如果成功返回0, 否则返回1, 我们可以通过`$?`来获取命令的返回值

   ~~~shell
   a=hello
   test $a = hello # !!!!!这里一定要有空格, 不能写成$a=hello
   echo $? # 0
   
   a=hello1
   test $a != hello
   echo $? # 0
   ~~~

2. 通过`[ condition ]`来判断, 如果成功返回0, 否则返回1, 我们可以通过`$?`来获取命令的返回值

   注意condition前后有空格

   ~~~shell
   a=hello
   [ $a = hello ] # !!!!!这里一定要有空格, 不能写成$a=hello, 同时表达式前后有空格
   echo $? # 0
   
   a=hello1
   [ $a != hello ]
   echo $? # 0
   ~~~

### if判断的格式

if判断

~~~shell
if [ condition ]; then command1; else command2; fi

# 方式1 这里本质就是把if和then写在了一行, 通过;隔开
if [ condition ]; then 
    # do something
fi

# 方式2
if [ condition ]
then
    # do something
if
~~~

if-elif-else判断

~~~shell
if [ condition ]; then 
    # do something
elif [ condition ]; then
    # do something
elif [ condition ]; then
    # do something
else
    # do something
fi
~~~





### 常用的条件判断

常用的比较

1. 变量是否存在

   ~~~shell
   var=100
   # var是要判断的变量,  x可以是任意值,abc都可以
   # 原理是var如果存在, 那么${var+x}会返回x, 那么[]就返回真, 
   # 如果var不存在, 那么${var+x}就返回空字符串, 那么[]就返回假
   if [ ${var+x} ]; then 
     echo "变量非空"
   fi
   ~~~

2. 数值的比较

   -eq 等于 -ne 不等于 -lt 小于 -gt 大于 -le 小于等于 -ge 大于等于

   ~~~shell
   a=5
   b=5
   if [ "$a" -eq "$b" ]; then
     echo "a 等于 b"
   fi
   ~~~

3. 字符串的比较

   = 相等    != 不相等   -z 判断变量未定义或者字符串长度为0    -n 变量存在并且非空

   ~~~shell
   str1="hello"
   str2="hello"
   if [ "$str1" = "$str2" ]; then
     echo "两个字符串相等"
   fi
   
   var=100
   if [ -n "$var" ]; then
     echo "变量var存在, 并且变量非空"
   fi
   
   if [ -z "$a" ]; then
           echo "变量a为空, 或者变量a不存在"
   fi
   ~~~

4. 文件权限判断

   -r 有读的权限 -w 有写的权限 -x 有执行的权限

   ~~~shell
   file="./testfile"
   
   # -r 有读的权限
   if [ -r "$file" ]; then
     echo "$file 有读权限"
   fi
   ~~~

5. 文件类型判断

   -e 文件存在

   -f 文件存在并且是一个常规文件

   -d 文件存在并且是一个目录

   ~~~shell
   file="./testfile"
   if [ -e "$file" ]; then
     echo "$file 存在"
   fi
   ~~~


6. 取反操作

   取反就是在条件判断之前添加一个`!`

   ~~~shell
   if [[ ! -d "/tmp/testdir" ]]; then
     echo "目录不存在"
   fi
   ~~~

   



### 多条件判断

shell的多条件判断有三种写法

写法1 ( 常用 )

~~~shell
# 写法1
if [[ "$a" -lt 10 && "$b" -gt 5 ]]; then
    echo "条件都成立"
fi

if [[ "$a" -lt 3 || "$b" -lt 3 ]]; then
    echo "至少一个条件成立"
fi
~~~

写法2(了解)

~~~shell
if [ "$a" -lt 3 ] || [ "$b" -lt 3 ]; then
    echo "a 小于 3 或 b 小于 3"
fi

if [ "$a" -lt 10 ] && [ "$b" -gt 5 ]; then
    echo "a 小于 10 且 b 大于 5"
fi
~~~

写法3(了解)

~~~shell
a=3
b=7

if [ "$a" -lt 5 -o "$b" -gt 10 ]; then # -o 表示 or
  echo "a 小于 5 或 b 大于 10"
fi

if [ "$a" -lt 5 -a "$b" -lt 10 ]; then # -a 表示 and
  echo "a 小于 5 且 b 小于 10"
fi
~~~







### 条件判断特别注意的地方

在条件判断的时候, 最好是带上双引号

~~~shell
a=
if [ -n $a ]; then 
    echo 'a非空'
fi
~~~
上面的代码在执行的时候会报格式错误, 因为$a为空, 所以判断变成了` [ -n ]`, 然后报错


~~~shell
a=
if [ -n "$a" ]; then 
    echo 'a非空'
fi
~~~

上面代码不会报错, 即使$a为空, 那么判断也是`[ -n "" ]`, 所以他会返回false, 而不是报错





## case分支

语法

~~~shell
case $变量名 in
  值1)
      # do something
      ;; # ;;表示break
  值2)
      # do something
      ;;
  *)
      # default
      ;;
esac
~~~



案例

~~~shell
#!/usr/bin/env bash

read -p "请输入操作命令 (start/stop/restart/status): " cmd

case "$cmd" in
  start)
    echo "正在启动服务..."
    ;;
  stop)
    echo "正在停止服务..."
    ;;
  restart)
    echo "正在重启服务..."
    ;;
  status)
    echo "服务正在运行。"
    ;;
  *)
    echo "未知命令：$cmd"
    echo "用法: start | stop | restart | status"
    ;;
esac
~~~



## for循环

### 普通的for循环

语法

~~~shell
for (( 初始条件; 循环控制条件;变量变化)); do
    # do something
done

# 或者
for (( 初始条件; 循环控制条件;变量变化))
do
    # do something
done
~~~

案例

~~~shell
#!/usr/bin/env bash
sum=0
for (( i=1; i<=100; i++ )); do
  sum=$[$sum+$i] # $[]用于计算$sum+$i
done
echo $sum
~~~



### for range语法

~~~shell
sum=0
for {1..100}; do
  sum=$[$sum+$i] # $[]用于计算$sum+$i
done
echo $sum
~~~

### for in语法

~~~shell
for name in Alice Bob Charlie; do
  echo "Hello, $name!"
done
~~~

遍历文件

~~~shell
for file in *.txt; do
  echo "找到了文件：$file"
done
~~~

遍历命令行参数

~~~shell
for arg in "$@"; do
  echo "你传入的参数：$arg"
done
~~~







## while循环

语法

~~~shell
while [ condition ]; do
    # do something
done

# 或者
while [ condition ]
do 
    # do something
done
~~~

累加案例

~~~shell
#!/usr/bin/env bash

i=1
sum=0

while [ "$i" -le 100 ]; do
  sum=$((sum + i))
  i=$((i + 1))
done

echo "1 到 100 的总和是：$sum"
~~~



## until循环

语法

~~~shell
until [ 条件 ]; do
  # 循环体（条件为 false 时执行）
  ...
done
~~~

案例

~~~shell
# 等待文件被其他人创建成功
until [ -f /tmp/ready ]; do
  echo "Waiting for /tmp/ready..."
  sleep 1
done

echo "File is ready!"
~~~











## 从控制台读取输入

~~~shell
# -p指定提示信息
# -t表示等待用户10s, 如果10s到了没有输入, 那么直接返回空字符串, 如果不加-t的话会一直等待
# 输入读取到name中
read -p "请输入你的名字: " -t 10 name 
echo "你好，$name！"
~~~





## 函数



### 常用的系统函数

1. basename

   basename的作用从一个路径中拆分出文件名, 本质上就是一个字符串拆分

   ~~~shell
   # $0获取文件, 会带上路径, 比如./test.sh /root/test.sh
   # basename 从路径中拆分出文件名
   echo `basename $0`  # test.sh
   
   # basename还可以去除掉文件名的后缀
   echo `basename $0 .sh`  # 去除掉.sh后缀, 返回test
   ~~~

2. dirname

   dirname的作用是从一个路径中拆分出路径, 本质上是一个字符串拆分

   ~~~shell
   a=/root/a
   echo `dirname $a` # /root
   
   b=.././.././a
   echo `dirname $b` # .././../.
   ~~~

   dirname也可以用于获取当前脚本所在的文件夹

   ~~~shell
   # 默认情况下可以执行
   # 但是考虑到软连接, $0 是链接路径，不是原脚本路径。
   # 同时如果脚本被 source 执行，$0 不一定是脚本路径，而是当前 shell。
   echo $(cd `dirname $0`; pwd) 
   
   # 推荐
   # ${BASH_SOURCE[0]} 可能包含空格或特殊字符, 使用双引号括起来
   # ${BASH_SOURCE[0]} 是文件的真实路径
   DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   echo "脚本所在目录是：$DIR"
   ~~~



### 自定义函数

语法

~~~shell
# function可以省略, 函数后面的()可以省略, return可以省略
function xxx(){
    # do something
    return int;
}

xxx param1 parma2 # 函数调用
~~~

1. 必须先声明函数, 才可以调用, 因为shell是解释执行的
2. 函数不需要声明参数, 直接通过 `$1, $2, $3`的形式来获取位置参数
3. **return后面只能跟`0-255`的数值, 表示函数执行的状态码, 而不是函数的结果, 0表示正常**
4. 如果省略return, 那么会将最后一条命令的状态码return回去
5. 可以通过`$?`获取函数的return的状态码
6. 如果你想要返回一个结果, 那么可以使用echo, 那么在外层使用命令替换

~~~shell
function add(){
    s=$[ $1 + $2 ]
    echo $s
}
read -p "请输入第一个参数: " a
read -p "请输入第二个参数: " b

sum=`add $a $b`
echo 结果是$sum
~~~



### 小案例

写一个脚本, 可以对指定的目录进行归档, 归档文件名带上日期

~~~shell
#!/bin/bash

if [ 1 -ne $# ]; then
    echo "必须指定一个参数"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "输入的参数不是一个目录, 或者目录不存在"
    exit 1
fi

DIR_NAME=$( basename $1 ) # 获取要归档的目录
DIR_PATH=$( cd $(dirname $1) && pwd) # 获取归档的目录所在的目录
DATE=$(date +%Y%m%d) # 当前的日期
FILE=archive_${DIR_NAME}_${DATE}.tar.gz # 归档文件的文件名
DEST=/root/archive/$FILE # 归档文件的完整路径

tar -czf $DEST $DIR_PATH/$DIR_NAME # 归档文件
if [ ! $? -ne 0 ]; then
    echo "tar命令执行失败"
    exit 1
else
    echo "归档成功"
    echo "归档文件为: $DEST"
fi
~~~





## 正则表达式

1. `^`匹配开头

2. `$`匹配结尾

3. `.`匹配任意字符

4. `*`匹配任意次数, 0次或者1次或者多次

   ~~~shell
   cat /etc/passwd | grep '^root.*zsh$' # grep也可以使用正则表达式, 必须使用单引号括起来
   root:x:0:0:root:/root:/usr/bin/zsh
   ~~~

5. `[]`表示匹配一个范围

   | 表达式     | 作用                         |
   | ---------- | ---------------------------- |
   | [6, 8]     | 匹配6或者8                   |
   | [0-9]      | 匹配0-9中的任意数字          |
   | [0-9]*     | 匹配任意长度的数字字符串     |
   | [a-z]      | 匹配a到z之间的一个字符       |
   | [a-z]*     | 匹配任意长度的字符字符串     |
   | [a-c, e-f] | 匹配a-c或者e-f之间的任意字符 |

6. `\`表示转移, 比如要匹配$的时候, 就要进行转移

   ~~~shell
   echo '$aaa' | grep '\$'
   ~~~

   



## 文本处理

### cut

cut主要用于处理字符串的拆分

`cut [选项参数] filename`

- `-f` 指定每一行都拆分后, 需要保存第几列的数据
- `-d` 指定分隔符, 默认为制表符, 分隔符只能是一个字符
- `-c` 按照字符进行切割

~~~shell
# 文件为test.txt
hello, world
hello, java

# 按照,拆分文本, 并保留每一行的第二列数据
cut -d "," -f 2 test.txt
 world
 java
~~~

~~~shell
# 匹配/etc/passwd中以zsh结尾的行
# 然后根据:拆分, 保留1,6,7行
# !!!!!如果保留多列, cut会将多列按照分隔符拼接, 然后返回
cat /etc/passwd | grep 'zsh$' | cut -d ":" -f 1,6,7
root:/root:/usr/bin/zsh
tiger:/home/tiger:/usr/bin/zsh

# -2表示前2列, 5-6表示第5列到第6列, 7-表示第7列和以后的所有列
cat /etc/passwd | grep 'zsh$' | cut -d ":" -f -2,3,4,5-6,7
root:x:0:0:root:/root:/usr/bin/zsh
~~~



### awk

awk将文本逐行的读入, 并按照分隔符进行拆分, 拆分后再进行处理

`awk [选项参数] 'BEGIN{action0} /pattern1/{action1} /pattern1/{action2} ... END{actionN} ' filename`

- `-F` 指定分隔符, 默认是空格
- `-v` 赋值一个用户自定义变量, 可以在action中使用

awk的运行原理是:

1. 先执行BEGIN中的action, BEGIN可以省略

2. 将一整行去匹配pattern1, pattern2, pattern3

   pattern可以省略, 表示匹配所有的行

3. 如果匹配成功, 那么拆分字符串, 并将拆分后的内容作为参数, 传递到action1, action2, action3中

4. 最后执行END中的action, END可以省略

~~~shell
# 拆分每一行
# 匹配z结尾的行, 并将拆分的单词作为参数传入到 print $1 中
echo -e "xyz:ha:nz\nzz:al:xz" |  awk -F ":" '/z$/{print $1}'

# 搜索/etc/passed中以root开头的行, 并输出第1列和第7列, 并使用逗号隔开
awk -F ":" '/^root/{print $1","$7}' /etc/passwd

# pattern也可以没有, 表示匹配所有的行
awk -F ":" '{print $1","$7}' /etc/passwd # 输出第一列和第七列, 使用逗号隔开

# 先输出begin, 然后输出每一行的第一列和第7列, 然后输出end
awk -F ":" 'BEGIN{print "begin"} {print $1","$7} END{print "end"}'
~~~



`-v`参数的作用

~~~shell
# 获取每一本书的数量, 并加10
echo -e 'java,1\npython,4' | awk -v i=10 -F "," '{print $2+i}'
11
14
~~~



同时awk中也内置了一些变量

- `FILENAME`:  文件名
- `NR`: 当前的行号
- `NF`: 当前行, 拆分后的个数

~~~shell
# 假设有 test.txt
java, 10
python, 20, 2016
goland, 33, 2017

awk -F "," 'print FILENAME NR NF' test.txt
~~~





## 其他命令

### wc

wc的意思是"word count", 主要用来获取文件的行数, 单词数, 字节数

~~~shell
# 格式: wc [选项] [文件]
wc hello.txt
10 200 300 hello.txt # 行数, 单词数, 字节数

wc -l hello.txt
10 hello.txt # 查看行数

wc -w hello.txt
200 hello.txt # 查看单词数

wc -c hello.txt
300 hello.txt # 查看字节数

wc -m hello.txt
400 hello.txt # 查看字符数

wc  hello.txt world.txt # 查看多个文件

wc * # 查看当前目录下所有文件的行数, 单词数量, 字节数, 并统计
~~~



### getopts

https://kodekloud.com/blog/bash-getopts/

getopts主要用来解析传入脚本的参数, 格式是: `getopts optstring name`

- optstring主要用来告诉getopts你需要解析什么选项

  比如`:ab`告诉getopts从脚本的参数中解析a,b这两个选项, 并且这两个选项不需要参数

  `:abx:y:`告诉getopts从脚本中解析abxy这四个选项, ab不需要参数, xy需要参数

- name用来接收getopts解析选项后的参数

getopts常常和while-do-done,  case分支一起使用

~~~shell
#!/bin/bash

# getopts解析脚本的abxy四个参数, 并将结果放到opt中
while getopts ":abx:y:" opt; do
  # opt是解析出来的选项
  case ${opt} in
    a)
      # 这里会匹配a选项
      echo "Option -a was triggered."
      ;; # break
    b)
      echo "Option -b was triggered."
      ;;
    x)
      # 这里会匹配x选项, 并将x选项的参数传入到OPTARG中
      echo "Option -x was triggered, Argument: ${OPTARG}"
      ;;
    y)
      echo "Option -y was triggered, Argument: ${OPTARG}"
      ;;
    :)
      # 如果一个选项必须要参数, 但是调用脚本的时候没有传参数, 只是指定了选项, 那么就会匹配:
      # 并且会将选项目名传入到OPTARG中
      echo "Option -${OPTARG} requires an argument."
      exit 1
      ;;
    ?)
      # ?会匹配无效的选项, 并将选项传入到OPTARG中
      # 比如传入了一个 -z选项, 那么就会匹配?, 并将z传入到OPTARG中
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done
~~~

~~~shell
[root@uc24023 ~]# ./test.sh -a
Option -a was triggered.
[root@uc24023 ~]# ./test.sh -a -b
Option -a was triggered.
Option -b was triggered.
[root@uc24023 ~]# ./test.sh -a -b -x hello -y world
Option -a was triggered.
Option -b was triggered.
Option -x was triggered, Argument: hello
Option -y was triggered, Argument: world
[root@uc24023 ~]# ./test.sh -x
Option -x requires an argument.
[root@uc24023 ~]# ./test.sh -z
Invalid option: -z.
~~~

需要注意的是, getopts只负责解析参数, 他没有办法实现一定要指定某个选项的功能, 如果要实现这个功能, 你可以将参数赋值给某个变量, 然后等while循环结束后, 看看这个参数是否为空, 然后报错

下面是实际脚本中的一段代码

~~~shell
function echoUsage() {
    echo "Usage:"
    echo "  ./package_Common_all.sh -c {SYSTEMNAME} -s {SBOM} -v {VERSION}"
    echo "Options:"
    echo "  -c: cpu enviroment; x86 or arm, default is x86"
    echo "  -s:  build sbom files or not; true or false, default is false;"
    echo "  -v:  version;"
    exit 0
}


while getopts :u:c:s:v: opt
do
    case $opt in
        u) BUILD=$OPTARG;;
        c) SYSTEMNAME=$OPTARG;;
        s) SBOM=${OPTARG};;
        v) VERSION=${OPTARG};;
        ?) echoUsage
        ;;
    esac
done
~~~



### find

find命令用于查找文件, 格式: `find path [args]`

- `-name "filename"`: 按照名称查找
- `-iname "filename"`: 按照名称查找, 并忽略大小写
- `-type [f | d | l]`: 按照文件类型查找, f文件, d目录, l符号链接
- `-size [+-]n[k|M|G|T]`: 按照文件带下来查
- `-delete`: 删除查找到的文件, 常常用在shell中

~~~shell
# 查找名为filename的文件, 忽略大小写, 文件类型为file, 大小超过100G
# 查找到后直接删除掉
find /path/to/search -iname "filename" -type f -size +100G -delete
~~~



### pushd和popd

格式:`pushd /path/to/directory` 和 `popd `

- pushd: cd到指定的目录, 然后将当前目录压入目录栈中
- popd: 从目录栈中pop出一个目录, 然后cd到这个目录

这两个命令常常用在shell中, 切换到一个目录中执行命令, 然后切换回来

~~~shell
popd /root/hello/world # 切换到/root/hello/world目录, 并将目录压入栈
pwd # 执行一系列命令
popd # 将/root/hello/world弹出栈, 并cd到这个目录
~~~

### readlink

readlink用于获取一个文件的真实路径, 这个文件可能是一个软链接, 指向了其他文件

~~~shell
readlink -f file # 如果 link_to_file 指向另一个符号链接，-f 选项会递归解析，直到找到最终的目标路径。
readlink -n file # 输出文件的原始路径，不会解析它指向的目标
~~~

readlink可以用来在脚本中获取当前脚本所在的目录

~~~shell
#!/bin/bash
# 获取脚本的目录路径
basedir=$(dirname "$(readlink -f "$0")")
echo "脚本的真实路径：$basedir"
~~~





### timeout

timeout的作用是: `在指定的时间内运行一个命令，如果超时则终止该命令的执行`

他的格式如下:

~~~shell
# command表示要执行的命令, args表示执行命令的参数
timeout [OPTION] DURATION COMMAND [ARG]...
~~~

1. duration是超时的时间, 可以指定1s, 3m, 4h, 7d这种格式
2. 默认情况下, 如果超时了, 那么timeout会发送SIGTERM(信号15)给这个command, 如果这个command接受到信号后没有退出, 那么也不会强制kill这个命令, 而是继续等待command执行, 直到退出
3. 默认情况下
   - 如果命令在时间内执行完, 那么$?就是command的状态码
   - 如果command超时了, 被timeout发送的信号15终止了, 那么返回码是124
   - 如果command被其他程序发出的信号终止了, 那么返回码是128+信号, 比如137表示command被其他程序kill -9了

~~~shell
timeout 2m ./long_running_script.sh
~~~

参数:

- `--preserve-status`: 告诉timeout, 即使超时了, 也使用command的状态码作为timeout命令的状态码

  ~~~shell
  # example.sh
  #!/bin/bash
  sleep 2
  exit 42
  
  # 不加--preserve-status参数, 那么timeout的状态码是124, 因为超时了
  timeout 1s ./example.sh
  echo $?
  
  # 加--preserve-status参数, 那么timeout的状态码是42, 即使超时了也使用example.sh的状态码作为timeout的状态码
  timeout --preserve-status 1s ./example.sh
  echo $?
  ~~~

- `-s signale`: 指定在超时的时候, 要发送的终止command的信号, 默认是SIGTERM(信号15), 你也可以指定为SIGKILL(信号9)来强制杀死command

  ~~~shell
  timeout -s SIGKILL 5s ./hang_script.sh # 超时强制kill
  timeout  5s ./hang_script.sh # 超时发送SIGTERM
  ~~~

- `--kill-after=5s`: 被 timeout 的命令是在 **子进程中执行**，所以如果该命令再 fork 出子进程，它们可能不会被一并杀掉。解决方案可以用 `--kill-after` 强制终止整个进程组。

  ~~~shell
  timeout --kill-after=5s 10s ./my_script.sh # 10s后超时, 并且在超时的5s后, 杀死整个进程组
  ~~~

- `--foreground`: 用于在交互式环境下（尤其是使用 Ctrl+C 等终端信号时）**让被执行的command接收输入和终端信号**，而不是由 `timeout` 命令本身处理这些信号。

  如果你在脚本中执行timeout命令, 并且希望用户能随时用 `Ctrl+C` 终止的程序，加上 `--foreground` 是非常必要的

  ~~~shell
  # 如果不加--foreground, 我在终端按ctrl+c, 那么实际上终端信号被timeout处理掉了, timeout退出来了, 但是bash命令还在执行
  timeout 10s bash
  
  # 加--foreground, 我在终端按ctrl+c, 那么是bash在处理ctrl+c信号, 那么是bash命令退出了, 然后timeout也退出了
  timeout --foreground 10s bash
  ~~~

  

### trap











## 其他







### shell操作字符串

字符串的三种形式

1) 由单引号`' '`包围的字符串：

- 任何字符都会原样输出，在其中使用变量是无效的。
- 字符串中不能出现单引号，即使对单引号进行转义也不行。

2) 由双引号`" "`包围的字符串：
- 如果其中包含了某个变量，那么该变量会被解析（得到该变量的值），而不是原样输出。
- 字符串中可以出现双引号，只要它被转义了就行。

3) 不被引号包围的字符串
- 不被引号包围的字符串中出现变量时也会被解析，这一点和双引号`" "`包围的字符串一样。
- 字符串中不能出现空格，否则空格后边的字符串会作为其他变量或者命令解析。

> 获取字符串长度

${#stringname}   stringname表示变量名

> 字符串拼接

在shell中，不需要任何操作符就可以拼接字符串

~~~shell
name="hello"
url="world"

str1=$name$url  #中间不能有空格 helloworld
str2="$name $url"  #如果被双引号包围，那么中间可以有空格 hello world
str3=$name": "$url  #中间可以出现别的字符串 hello: world
str4="$name: ${url}aaa"  #这样写也可以 hello: worldaaa
~~~

> 字符串截取

- 从左边开始计数

  ~~~shell
  ${string:start:length} #格式
  ~~~

  ~~~shell
  $ url="c.biancheng.net"
  $ echo ${url:2:9}
  biancheng
  ~~~

  从0开始计数，忽略length表示直到结束

- 从右边开始计数

  ~~~shell
  ${string:0-start:length} #格式
  ~~~

  ~~~shell
  $ url="c.biancheng.net"
  $ echo ${url:0-13:9}
  biancheng
  ~~~

  需要注意的是：

  - 从右边开始计数是从1开始的
  - 不管从那边开始计数，截取方向都是从左到右
  - 忽略length表示直到结束

- 从指定字符串开始截取

  ~~~shell
  ${string#chars} # 匹配左边保留右边
  ${string%chars} # 匹配右边保留左边
  ~~~

  ~~~shell
  url="http://aaa.http"
  $ echo ${url#http}
  ://aaa.http
  $ echo ${url%http}
  http://aaa.
  ~~~

  可以使用通配符*表示任意字符

  ~~~shell
  url="http://aaa/b.html"
  $ echo ${url#*/}  #  */表示以/结尾的任意字符串，#匹配左边，所以匹配到了http:/,保留右边
  /aaa/b.html
  $ echo ${url%/*} # /*表示匹配/开始的任意字符串，%匹配右边，所以匹配到了/b.html，保留左边
  http://aaa
  ~~~

  同时在使用通配符时，#和%都是非贪心模式，只要匹配到了相应字符串即结束。

  可以使用##和%%切换到贪心模式

  ~~~shell
  $ url="http://aaa/b.html"
  $ echo ${url##*/}
  b.html # */使用贪心模式，匹配到了http://aaa/
  $ echo ${url%%/*}
  http: # /*使用贪心模式，匹配到了//aaa/b.html
  ~~~


> 字符串替换

| 命令              | 解释                     | 结果                           |
| ----------------- | ------------------------ | ------------------------------ |
| ${file/dir/path}  | 将第一个 dir 提换为 path | /path1/dir2/dir3/my.file.txt   |
| ${file//dir/path} | 将全部 dir 提换为 path   | /path1/path2/path3/my.file.txt |

使用${file//dir/}可以将file中的dir字符串全部是删除



### shell数组

shell只支持一维数组

~~~shell

~~~



### shell sed

![image-20220215000534758](img/shell/image-20220215000534758.png)

![image-20220215000559622](img/shell/image-20220215000559622.png)



![image-20220215000329297](img/shell/image-20220215000329297.png)

![image-20220215000451845](img/shell/image-20220215000451845.png)

![image-20220215000430439](img/shell/image-20220215000430439.png)



![image-20220215000624182](img/shell/image-20220215000624182.png)

![image-20220215000640887](img/shell/image-20220215000640887.png)

![image-20220215001007423](img/shell/image-20220215001007423.png)

![image-20220215002101134](img/shell/image-20220215002101134.png)



### shell BASH_SOURCE和FUNCNAME变量

参考https://www.cnblogs.com/sunfie/p/5943979.html

> FUNCNAME

在shell脚本中，FUNCNAME是一个数组，里面保存着当前shell的函数调用栈，其中${FUNCNAME[0]}是当前函数，1是外层函数，示例如下

~~~shell
#!/bin/bash

function test_func()
{
    echo "Current $FUNCNAME, \$FUNCNAME => (${FUNCNAME[@]})"
    another_func
    echo "Current $FUNCNAME, \$FUNCNAME => (${FUNCNAME[@]})"
}

function another_func()
{
    echo "Current $FUNCNAME, \$FUNCNAME => (${FUNCNAME[@]})"
}

echo "Out of function, \$FUNCNAME => (${FUNCNAME[@]})"
test_func
echo "Out of function, \$FUNCNAME => (${FUNCNAME[@]})"
~~~

输出

~~~shell
Out of function, $FUNCNAME => ()
Current test_func, $FUNCNAME => (test_func main)
Current another_func, $FUNCNAME => (another_func test_func main)
Current test_func, $FUNCNAME => (test_func main)
Out of function, $FUNCNAME => ()
~~~

> BASH_SOURCE

BASH_SOURCE与FUNCNAME类似，在使用source执行子脚本的时候，在子脚本里面BASH_SOURCE数组中记录着脚本的调用栈，${BASH_SOURCE[0]}表示的是当前脚本，1表示的是父脚本。${BASH_SOURCE[0]}与$BASH_SOURCE相同。

但是在子脚本中，$0依旧是最外层的父脚本。

~~~shell
shen@Wind:~$ cat a.sh
#!/bin/bash
echo ${BASH_SOURCE[*]}
echo $0
. b.sh

shen@Wind:~$ cat b.sh
#!/bin/bash
echo $0
echo ${BASH_SOURCE[*]}

shen@Wind:~$ bash a.sh
a.sh # a.sh中的BASH_SOURCE
a.sh # a.sh中的$0
a.sh # b.sh中的$0依旧是与a.sh不变
b.sh a.sh # 记录当前脚本的调用栈
~~~



### 根据状态为变量赋值

| 命令                 | 解释                                                         | 备注                            |
| -------------------- | ------------------------------------------------------------ | ------------------------------- |
| ${file-my.file.txt}  | 若 $file 没设定,则使用 my.file.txt 作传回值                  | 有设定（ 空值及非空值）不作处理 |
| ${file:-my.file.txt} | 若 $file 没设定或为空值,则使用 my.file.txt 作传回值          | 非空值时不作处理                |
| ${file+my.file.txt}  | 若$file 有设定（空值或非空值）,均使用my.file.txt作传回值     | 没设定时不作处理                |
| ${file:+my.file.txt} | 若 $file 有设定且不为空值（为非空值）,则使用 my.file.txt 作传回值 | 没设定及空值不作处理            |
| ${file=txt}          | 若 $file 没设定,则回传 txt ,并将 $file 赋值为 txt            | 有设定（ 空值及非空值）不作处理 |
| ${file:=txt}         | 若 $file 没设定或空值,则回传 txt ,将 $file 赋值为txt         | 非空值时不作处理                |
| ${file?my.file.txt}  | 若 $file 没设定,则将 my.file.txt 输出至 STDERR               | 有设定（ 空值及非空值）不作处理 |
| ${file:?my.file.txt} | 若 $file没设定或空值,则将my.file.txt输出至STDERR             | 非空值时不作处理                |



### shell eval的用法

格式：eval command

eval用于执行命令，他与直接执行命令不同的是，eval在执行命令之前会对命令进行一遍扫描，并解析其中的变量，解析变量之后才会执行该命令

- 案例1

  ~~~shell
  pipe="|"
  eval ls $pipe grep java # eval会先解析命令成 ls | grep java然后再执行
  ~~~

- 按理2：获取位置参数的最后一个参数

  ~~~shell
  eval echo \$$# #eval会先现将$#解析成位置参数的个数，然后再执行命令
  ~~~

- 按理3

  ~~~shell
  x=100
  ptrx=x
  eval echo \$$prtx # eval先将命令解析成echo $x，然后再执行命令
  ~~~

  

### shell 间接取值

格式： ${!var}

表示的意思是取$var的值，然后再使用$var的值进行再次取值

案列1：

~~~shell
x=100
ptrx=x
# 先回去$ptr的值为x, 然后再获取$x的值, 一共做两次取值
echo ${!ptrx} #100
~~~

案列2: 写一个交换两个变量的值的函数

~~~shell
## @description  exchange `oldvar` and `newvar`
## @param        oldvar
## @param        newvar
function exchange
{
  local a_value=${!1}
  local b_value=${!2}

  eval "$1=$b_value"
  eval "$2=$a_value"
}

a=100
b=200

exchange a b
echo $a,$b #200,100
~~~









### 实验技巧

#### shell获取当前执行文件的绝对路径

~~~shell
# cd -P 和 pwd -P表示使用物理路径，该选项会忽略软连接
# 比如家目录下有test文件夹，testln软连接到test
# cd testln将进入到testln目录下, cd -P testln将进入到test目录下
# 在testln目录下pwd将会获得~/testln, pwd -P 将会获得~/test

# -- 用于区分选项和参数，详细请查看当前笔记的关于--的记录
$(cd -P -- "$(dirname -- "${BASH_SOURCE:-$0}")" >/dev/null && pwd -P)
~~~

#### shell --和-的用法

在shell中使用命令的一般格式为command option args

比如`cd -P ~`，这里的-P表示选项，~表示参数

使用`man bash`可以看到

![image-20220219173003137](img/shell/image-20220219173003137.png)

`--` 的作用是作为option和args的分割符。`--`和`-`的作用是相等的。`--`是可选的。

在一般情况下，加不加`--`都无所谓，但是在一些特殊情况下必须加`--`。

比如想要创建一个名叫`-i`的目录，使用`mkdir -i`时，bash会认为-i是一个选项，但是实际上我们想要表示的是`-i`是一个参数，所以必须使用`mkdir -- -i`才能创建。

cd到一个`-i`目录也是同理，必须使用`cd -- -i`。

所以在shell中，使用从外部接收参数进行命令拼接时，为了防止参数被解析成选项，一般在参数面前加`--`，比如`cd -- $(dirname -- $0)`



#### shell shift的作用

位置参数可以用`shift`命令左移。比如`shift 3`表示原来的`$4`现在变成`$1`，原来的`$5`现在变成`$2`等等，原来的`$1`、`$2`、`$3`丢弃，`$0`不移动。不带参数的`shift`命令相当于`shift 1`。

我们知道，对于位置变量或命令行参数，其个数必须是确定的，或者当 Shell 程序不知道其个数时，可以把所有参数一起赋值给变量$*。若用户要求 Shell 在不知道位置变量个数的情况下，还能逐个的把参数一一处理，也就是在 $1 后为 $2,在 $2 后面为 $3 等。在 shift 命令执行前变量 $1 的值在 shift 命令执行后就不可用了。

示例如下：

\#测试 shift 命令(x_shift.sh)

~~~shell
until [ $# -eq 0 ]
do
echo "第一个参数为: $1 参数个数为: $#"
shift
done
~~~

执行以上程序x_shift.sh：
$./x_shift.sh 1 2 3 4

结果显示如下：

~~~shell
第一个参数为: 1 参数个数为: 4
第一个参数为: 2 参数个数为: 3
第一个参数为: 3 参数个数为: 2
第一个参数为: 4 参数个数为: 1
~~~





































