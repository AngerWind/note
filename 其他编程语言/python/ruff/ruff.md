要使用ruff有两种方式: 

- 你需要使用pip来安装为每一个项目都ruff
- 使用uvx来全局安装这个工具

安装完之后, 你可以使用如下的命令来查看ruff的版本

~~~shell
ruff --version
~~~







安装ruff之后, 你可以**在项目的根目录下**使用如下命令来进行代码检查和格式化

~~~shell
ruff check . # 校验整个项目的代码

ruff check main.py # 校验单个文件

ruff check --fix . # 校验当前项目, 并自动修复不规范的代码, 有些代码可能无法修复, 需要手动修改

ruff check --watch . # 监控当前项目下的文件, 当你修改代码的时候, 会事实的显示出不规范的代码

ruff format . # 对项目中的代码进行格式化
~~~





你可以对ruff进行配置, 让他应用某些规则, 或者不应用某些规则

配置分为全局的配置和项目级别的配置,  项目级别的配置会覆盖全局的配置



要想配置项目级别的配置, 你可以在项目的根目录下创建一个名为`ruff.toml`或者`pyproject.toml`的文件, 内容如下

~~~ toml
[ruff]
lint.extend-select = [] # 使用默认的配置
lint.extend-select = ["PTH"] # 除了使用默认的配置, 同时应用PTH规则
lint.extend-select = ["ALL"] # 应用所有的规则

lint.ignore = ["T201"] # 不应用T201规则
~~~



如果你想要全局配置ruff, 那么可以创建一个`~\AppData\Roaming\ruff\ruff.toml`的文件, 可以添加的内容和上面的项目级别一样







如果想要在pycharm中使用ruff, 那么你可以在安装`ruff`插件, 这个插件可以在你保存文件的时候, 自动格式化文件, 高亮问题代码, alter+enter提示修复, 自动检测ruff的配置文件, 自动检测虚拟环境中的ruff等等功能

你也可以在github中访问这个项目的源码

https://github.com/koxudaxi/ruff-pycharm-plugin