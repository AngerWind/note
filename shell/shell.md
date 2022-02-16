### 运行shell脚本

> 将shell脚本作为程序运行

~~~shell
./test.sh
~~~

`./`表示当前目录，如果不写会从path环境变量下查找test.sh

这种方式需要当前用户对shell脚本有执行权限

这种方式会根据脚本第一行中指定的shell解释器来执行

> 通过bash执行

~~~shell
bash test.sh
~~~

通过这种方式运行脚本，不需要在脚本文件的第一行指定解释器信息，写了也没用。

这种方式会新开一个bash进程来执行shell脚本，可以分别在当前进程中和脚本中执行`echo $$`来获取进程PID

> 在当前进程中执行shell

~~~shell
source test.sh
~~~

简写

~~~shell
. test.sh
~~~

source会在当前进程中强制执行脚本文件中的全部内容而忽略脚本文件的权限



### shell交互式与非交互式，登录式与非登录式

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

如果输出字母中包含i，则为交互式



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

- `bash test.sh`直接执行脚本

非登录交互式：

- 桌面环境下打开终端
- 直接执行`bash`进入子进程
- `ssh user@ip "echo $-; shopt login_shell"`通过ssh直接执行脚本
- `su user`切换用户



> 登录式与非登录式区别

当bash以交互登录式shell调用，或者以非交互登录式shell（`bash --login`）调用时，先加载全局配置文件`/etc/profile`，然后只加载`~/.bash_profile`、`~/.bash_login` 、`~/.profile`中第一个存在并且可读的文件。

此外在执行`/etc/profile`中发现有下面这段代码，下面这段代码会加载`/etc/profile.d`目录下所有可读的shell脚本

~~~shell
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
~~~



并且当交互登录式shell执行logout时，或者非交互登录式shell执行exit时，bash还会读取并执行（如果存在）`~/.bash_logout`



以非登录式shell运行时，bash会从`/etc/bash.bashrc`和`~/.bashrc`中读取并执行命令



### shell配置文件

无论是否是交互式，是否是登录式，Bash  在启动时总要配置其运行环境，例如初始化环境变量、设置命令提示符、指定系统命令路径等。这个过程是通过加载一系列配置文件完成的，这些配置文件其实就是 Shell 脚本文件。

> 登录式shell

如果是登录式的 Shell，首先会读取和执行 /etc/profiles，这是所有用户的全局配置文件。

接着会到用户主目录中寻找 ~/.bash_profile、~/.bash_login 或者 ~/.profile，它们都是用户个人的配置文件。不同的 linux 发行版附带的个人配置文件也不同，有的可能只有其中一个，有的可能三者都有。

如果三个文件同时存在的话，到底应该加载哪一个呢？它们的优先级顺序是 ~/.bash_profile > ~/.bash_login > ~/.profile。

如果 ~/.bash_profile 存在，那么一切以该文件为准，并且到此结束，不再加载其它的配置文件。

如果 ~/.bash_profile 不存在，那么尝试加载 ~/.bash_login。~/.bash_login 存在的话就到此结束，不存在的话就加载 ~/.profile。

注意，/etc/profiles 文件还会嵌套加载 /etc/profile.d/*.sh，请看下面的代码：

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


同样，~/.bash_profile 也使用类似的方式加载 ~/.bashrc：

```shell
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
```

> 非登录式shell

如果以非登录的方式启动 Shell，那么就不会读取以上所说的配置文件，而是直接读取 ~/.bashrc。

~/.bashrc 文件还会嵌套加载 /etc/bashrc，请看下面的代码：

```shell
if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi
```



### shell变量

> 定义变量

~~~shell
variable=value
variable='value'
variable="value"
~~~

`=`左右不能有空格

在shell中，每一个变量的值都是字符串，无论是否使用引号。

如果需要指定类型可以使用declare关键字

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
readonly a=100
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

想要定义局部变量需要加上local关键字

~~~shell
local a=99
~~~

> shell环境变量

全局变量只在当前 Shell 进程中有效，对其它 Shell 进程和子进程都无效。如果使用`export`命令将全局变量导出，那么它就在所有的子进程中也有效了

通过 export 导出的环境变量只对当前 Shell 进程以及所有的子进程有效，如果最顶层的父进程被关闭了，那么环境变量也就随之消失了，其它的进程也就无法使用了，所以说环境变量也是临时的。

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

```
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