![image-20210109193921971](img/image-20210109193921971.png)git commit撤销

写完代买之后, 一般是

git add . //提交文档的暂存区

git commit -m "完成功能" // 提交一个版本

如果commit之后想撤回怎么办呢?



- 使用git reset 进行撤回commit, 其中几个参数讲下

  | 参数    | 作用                                                         | 备注                                                         |
  | ------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
  | --mixed | 不删除工作空间代码改动, 撤销commit, 撤销git add, 这个为**默认**参数,git reset --mixed HEAD^ 和 git reset HEAD^ 效果是一样的。 | 回退到你想要的那个版本,  保留工作空间代码改动, 但是改动变成没有add的状态 |
  | --soft  | 不删除工作空间代码改动, 撤销commit, 不撤销git add            | 回退到你想要的那个版本,  保留工作空间代码改动, 但是改动变成已经add的状态 |
  | --hard  | 回退到指定的版本, 删除工作空间的代码改动                     | 回退到你想要的那个版本,  但是你那个版本之后的改动都没了.     |

  举个例子, 我现在有个仓库test, 里面有个空文件readme.txt, 我在其中添加一句"first commit", 之后进行提交, 之后再添加一句"second commit"进行提交, 这样我就提交两次了.

  ![](img\image-20200820194430656.png)

  之后我想撤回这两次提交怎么办呢?

  - git reset --hard HEAD^^, 回退到指定的版本, 一点不多一点不少

    ![](img\image-20200820194912749.png)

    cat之后什么都没有

  - git reset --mixed HEAD^^或者 git reset HEAD^^

    ![](img\image-20200820195654508.png)

    撤销了之前的两次提交, 但是提交的内容还在, 并且readme.txt是已修改状态的

  - git reset --soft HEAD^^

    ![](img\image-20200820200132075.png)

    撤销了之前的两次提交, 但是提交的内容还在, 并且readme.txt是已暂存状态的

如果只是commit注释写错了, 只想改下注释, 只要git commit --amend

此时会进入默认vim编辑器, 修改注释完毕保存好就行了.



#### 撤销git push

- 执行git log查看日志获取需要回退的版本号

  ![](img/788599-20180927164303193-2084393469.png)

- 执行 git reset –-soft <版本号> ，如 git reset --soft 4f5e ，重置至指定版本的提交，达到撤销提交的目的

  然后执行 git log 查看

  ![](img/788599-20180927164827547-451137005.png)

  此时，已重置至指定版本的提交，log中已经没有了需要撤销的提交

- 执行 git push origin 分支名 –-force ，强制提交当前版本号。至此，撤销push提交完成。

#### git 查看提交的具体改动

- git log --stat查看每次提交设计的文件以及修改的行数

  ![](img\image-20200821194218114.png)

- git log -p展开查看每次提交的文件差异, -2仅显示最近两次更新

  ![](img\image-20200821194911307.png)

- git show查看最新提交中的文件差异

  ![](img/668985-20191011103535678-173351629.png)

- git show commitid查看指定提交中所有的文件修改

  ![](img/668985-20191011103630912-1475810245.png)

- git show commitid fileName

  查看某次提交中具体某个文件的改动



#### Java 折叠代码块

ctrl + alt + T in IDEA

//region Description

Some code

//endregion



## [反射框架reflections](https://github.com/ronmamo/reflections)

#### 简介

使用Reflections可以很轻松的获取以下元数据信息：

- 获取某个类型的全部子类
- 只要类型、构造器、方法，字段上带有特定注解，便能获取带有这个注解的全部信息（类型、构造器、方法，字段）
- 获取所有能匹配某个正则表达式的资源
- 获取所有带有特定签名的方法，包括参数，参数注解，返回类型
- 获取所有方法的名字
- 获取代码里所有字段、方法名、构造器的使用

#### Maven依赖

~~~java
<dependency>
    <groupId>org.reflections</groupId>
    <artifactId>reflections</artifactId>
    <version>0.9.11</version>
</dependency>
~~~

#### 实例化

```java
// 实例化Reflections，指定扫描的包为my.package及其子包，使用默认的scanners（扫描器）
Reflections reflections = new Reflections("my.package");

// 使用ConfigurationBuilder进行实例化
new Reflections(new ConfigurationBuilder()
     .setUrls(ClasspathHelper.forPackage("my.project.prefix"))
     .setScanners(new SubTypesScanner(), 
                  new TypeAnnotationsScanner().filterResultsBy(optionalFilter), ...),
     .filterInputsBy(new FilterBuilder().includePackage("my.project.prefix"))
     ...);
```

#### 使用

- 扫描子类

  ~~~java
  //SubTypesScanner
  Set<Class<? extends Module>> modules = 
      reflections.getSubTypesOf(com.google.inject.Module.class);
  ~~~

- 扫描带有某个注解的类

  ~~~java
  //TypeAnnotationsScanner 
  Set<Class<?>> singletons = 
      reflections.getTypesAnnotatedWith(javax.inject.Singleton.class);
  ~~~

- 扫描资源

  ~~~java
  //ResourcesScanner
  Set<String> properties = 
      reflections.getResources(Pattern.compile(".*\\.properties"));
  ~~~

- 扫描带有某个注解的方法/构造方法

  ~~~java
  //MethodAnnotationsScanner
  Set<Method> resources =
      reflections.getMethodsAnnotatedWith(javax.ws.rs.Path.class);
  Set<Constructor> injectables = 
      reflections.getConstructorsAnnotatedWith(javax.inject.Inject.class);
  ~~~

- 扫描带有某个注解的字段

  ~~~java
  //FieldAnnotationsScanner
  Set<Field> ids = 
      reflections.getFieldsAnnotatedWith(javax.persistence.Id.class);
  ~~~

- 扫描特定的方法

  ~~~java
  //MethodParameterScanner
  //扫描特定参数类型的方法
  Set<Method> someMethods =
      reflections.getMethodsMatchParams(long.class, int.class);
  //扫描特定返回类型的方法
  Set<Method> voidMethods =
      reflections.getMethodsReturn(void.class);
  //扫描方法参数上带有某个注解的方法
  Set<Method> pathParamMethods =
      reflections.getMethodsWithAnyParamAnnotated(PathParam.class);
  ~~~

- 扫描方法的参数名

  ~~~java
  //MethodParameterNamesScanner
  List<String> parameterNames = 
      reflections.getMethodParamNames(Method.class)
  ~~~

- 扫描？？？

  ~~~java
  //MemberUsageScanner
  Set<Member> usages = 
      reflections.getMethodUsages(Method.class)
  ~~~




#### git 拉取指定的分支

- 一般使用git clone的时候，虽然会把所有的远程分支拉取到本地，但是只会在本地创建一个master分支，并且追踪origin/master分支。

  使用 git clone -b 分支代码名称 仓库地址， 例：git clone -b dev https://xxx.git。指定拉去xxx仓库的dev分支到本地

- 如果本地已经clone了仓库并且有了master，还想拉取dev分支到本地怎么办呢？

  使用git fetch拉取所有的远程分支到本地，然后`git checkout -b dev origin/dev`，dev和origin/dev自动建立追踪

  ~~~shell
  git checkout -b dev_local origin/dev # 根据origin/dev生产dev_local并自动跟踪
  git checkout --track origin/dev # 根据远程分支生成同名的本地分支并自动跟踪
  
  git switch -c dev origin/dev # 同上
  git switch --track origin/dev
  ~~~
  
  
  
  

#### git 查看本地分支的远程分支

git branch -vv

#### git log的使用

git log -p -2展示每次提交的内容差异，-2表示仅显示最近两次

git log --stat 显示每次提交的增改行数

git log --graph --pretty=oneline --abbrev-commit显示图像表示的分支数，--pretty=oneline表示仅显示一行，--abbrev-commit表示缩略显示commitid

git log --grep 搜索提交说明中的关键字

**git log -1 -- [file path] 显示文件变化，即使文件被删除也能正常工作**



#### git 将本地项目推送到远程仓库

- 本地项目不是git仓库：
  - git clone下远程分支
  - 复制项目到仓库中
  - git commit
  - git push -u origin master
- 本地仓库已经是一个git 仓库的话
  - git remote add origin 远程仓库地址
  - git pull origin master --allow-unrelated-histories，拉取远程仓库，使用--allow-unrelated-histories忽略本地仓库和远程仓库的无关性
  - git push -u origin master推送本地仓库到远程origin仓库，并设置origin为默认主机。

#### git 命令别名

~~~shell
git config --global alias.br branch
git config --golbal alias.cm commit
git config --global alias.st status
git config --global alias.co checkout
~~~





## git rebase详解

参考

http://jartto.wang/2018/12/11/git-rebase/

https://www.jianshu.com/p/4a8f4af4e803

《Pro Git》变基部分

### 合并多个commit为一个commit

当你在实现一个功能的时候，有非常多次的无用的无意义的提交的时候，会有如下几个问题：

1. 不利于代码review

   设想一下，你要做 `code review` ，结果一个很小的功能，提交了 `60` 多次，会不会有一些崩溃？

2. 会造成分支污染
   你的项目充满了无用的 `commit` 纪录，如果有一天线上出现了紧急问题，你需要回滚代码，却发现海量的 `commit` 需要一条条来看。

3. 提交的记录非常不简洁明了，让人迷惑

我们希望把如下分支B、C、D三个提交记录合并为一个完整的提交，然后再push到公共仓库。

![](img/2147642-42195cacced56729.webp)

现在我们在测试分支上添加了四次提交，我们的目标是把最后三个提交合并为一个提交：



<img src="img/2147642-ce849c4eab3d803b.webp" alt="img" style="zoom: 67%;" />

这里我们使用命令:

```css
  git rebase -i  [startpoint]  [endpoint]
```

其中`-i`的意思是`--interactive`，即弹出交互式的界面让用户编辑完成合并操作，`[startpoint]`  `[endpoint]`则指定了一个编辑区间，如果不指定`[endpoint]`，则该区间的终点默认是当前分支`HEAD`所指向的`commit`(注：该区间指定的是一个**前开后闭**的区间)。

 在查看到了log日志后，我们运行以下命令：

```undefined
git rebase -i 36224db
```

或:

```undefined
git rebase -i HEAD~3 
```

然后我们会看到如下界面:

<img src="img/2147642-03d48aa767efb307.webp" alt="img" style="zoom:67%;" />


 上面未被注释的部分列出的是我们本次rebase操作包含的所有提交，下面注释部分是git为我们提供的命令说明。每一个commit id 前面的`pick`表示指令类型，git 为我们提供了以下几个命令:



> - pick：保留该commit（缩写:p）
> - reword：保留该commit，但我需要修改该commit的注释（缩写:r）
> - edit：保留该commit, 但我要停下来修改该提交(不仅仅修改注释)（缩写:e）
> - squash：将该commit和前一个commit合并（缩写:s）
> - fixup：将该commit和前一个commit合并，但我不要保留该提交的注释信息（缩写:f）
> - exec：执行shell命令（缩写:x）
> - drop：我要丢弃该commit（缩写:d）





根据我们的需求，我们将commit内容编辑如下:

![img](img/2147642-a651234e62ed20a5.webp)

然后是注释修改界面:



<img src="img/2147642-44bbd784dcadfb31.webp" alt="img" style="zoom:67%;" />

编辑完保存即可完成commit的合并了：

![img](img/2147642-334e0a5c47a24f87.webp)





#### git rabse合并分支

在 Git 中整合来自不同分支的修改主要有两种方法：**merge** 以及 **rebase**  

假如有两个分支experiment和master

![image-20200914230420251](img\image-20200914230420251.png)

使用git merge合并时，它会**把两个分支的最新快照（C3 和 C4）以及二者最近的**
**共同祖先（C2）进行三方合并，合并的结果是生成一个新的快照（并提交）**。  

![image-20200914230605515](img\image-20200914230605515.png)

当使用git rebase时，可以提取在 C4 中引入的补丁和修改，然后在 C3 的基础上应用一次。 在 Git 中，这种操作就叫做 变基（rebase）。 你可以使用 rebase 命令将提交到某一分支上的所有修改都移至另一分支上，就好像“重新播放”一样。  

在图一的基础上：

~~~shell
git switch experiment
git rebase master
~~~

- 首先找到这两个分支（即当前分支 experiment、变基操作的目标基底分支 master） 的最近共同祖先 C2
- 然后对比当前分支相对于该祖先的历次提交，提取历次的修改并存为临时文件， 然后将当前分支指向目标基底 C3, 最后以此将之前另存为临时文件的修改依序应用。  

![image-20200914231146644](img\image-20200914231146644.png)

在 `rebase` 的过程中，也许会出现冲突 `conflict`。在这种情况，`git` 会停止 `rebase` 并会让你去解决冲突。

在解决完冲突后，用 `git add` 命令去更新这些内容。

注意，你无需执行 git-commit，只要执行 continue

```
git rebase --continue
```

这样 `git` 会继续应用余下的 `patch` 补丁文件。

在任何时候，我们都可以用 `--abort` 参数来终止 `rebase` 的行动，并且分支会回到 `rebase` 开始前的状态。

```
git rebase —abort
```

合并冲突后，回到master上进行一次快进合并

~~~shell
git switch master
git merge experiment
~~~

![image-20200914231532914](img\image-20200914231532914.png)

此时，C4' 指向的快照就和使用git merge 中 C5 指向的快照一模一样了。 这两种整合方法的**最终结果没有任何区别，但是变基使得提交历史更加整洁**。 你在查看一个经过变基的分支的历史记录时会发现，尽管实际的开发工作是并行的， 但它们看上去就像是串行的一样，提交历史是一条直线没有分叉。
一般我们这样做的目的是为了确保在向远程分支推送时能保持提交历史的整洁——例如向某个其他人维护的项目贡献代码时。 在这种情况下，你首先在自己的分支里进行开发，当开发完成时你需要先将你的代码变基到origin/master 上，然后再向主项目提交修改。 这样的话，该项目的维护者就不再需要进行整合工作，只需要快进合并便可。
请注意，无论是**通过变基，还是通过三方合并，整合的最终结果所指向的快照始终是一样的，只不过提交历史不同罢了**。 变基是将一系列提交按照原有次序依次应用到另一分支上，而合并是把最终结果合在一起。  



#### git rebase的危险操作

<font color=red>**如果你的提交已经推送到了远程仓库, 别人可能基于这些提交进行开发,那么就不要执行rebase.**</font>

假如你从远程分支拉取下c1,并再次基础上提交了c2,c3, 下图是远程分支和本地分支的情况.

![image-20200917192401578](img\668985-20191011103535678-17335161229.png)

某人又向中央服务器提交了一些修改，其中还包括一次合并。 你pull了这些在远程分支上的修改，并将其合并到你本地的开发分支，然后你的提交历史就会变成这样  

![image-20200917193108976](img\image-20200917193108976.png)

然后这个人又决定把合并操作回滚，改用变基；继而又用 git push --force 命令覆盖了服务器上的提交历史。 之后你从服务器抓取更新，会发现多出来一些新的提交。  

![image-20200917193239859](img\image-20200917193239859.png)

如果你执行 git pull 命令，你将合并来自两条提交历史的内容，生成
一个新的合并提交，最终仓库会如图所示  

![image-20200917193320532](img\image-20200917193320532.png)

此时如果你执行 git log 命令，你**会发现有两个提交的作者、日期、日志居然是一样的**，这会令人感到混乱。
此外，如果你将这一堆又推送到服务器上，你实际上是将那些已经被变基抛弃的提交又找了回来，这会令人感到
更加混乱。 很明显对方并不想在提交历史中看到 C4 和 C6，因为之前就是他把这两个提交通过变基丢弃的。  









## git stash(将修改暂存到缓存栈中)

**使用场景:** 

**需要切换分支时,工作区或者暂存区有修改,又不想进行一次多余的提交,导致提交混乱.**



#### git stash暂存的文件

默认情况下，`git stash`会缓存下列文件：

- 添加到暂存区的修改（staged changes）
- Git跟踪的但并未添加到暂存区的修改（unstaged changes）

但不会缓存一下文件：

- 在工作目录中新的文件（untracked files）
- 被忽略的文件（ignored files）

`git stash`命令提供了参数用于缓存上面两种类型的文件。使用`-u`或者`--include-untracked`可以stash untracked文件。使用`-a`或者`--all`命令可以stash当前目录下的所有修改。



#### git stash或者git stash save

`git stash`会把所有未提交的修改（包括暂存的和非暂存的）都保存起来,并且将当前代码切换到`HEAD`提交上.

```shell
$ git status
On branch master
Changes to be committed:

new file:   style.css

Changes not staged for commit:

modified:   index.html

$ git stash
Saved working directory and index state WIP on master: 5002d47 our new homepage
HEAD is now at 5002d47 our new homepage

$ git status
On branch master
nothing to commit, working tree clean
```

需要说明一点，**stash是本地的**，不会通过`git push`命令上传到git server上。
实际应用中推荐给每个stash加一个message，用于记录版本，使用`git stash save`取代`git stash`命令。

```shell
$ git stash save "test-cmd-stash"
Saved working directory and index state On autoswitch: test-cmd-stash

$ git stash list
stash@{0}: On autoswitch: test-cmd-stash
```



#### 查看stash缓栈

可以使用`git stash list`命令

```shell
$ git stash list
stash@{0}: WIP on master: 049d078 added the index file
stash@{1}: WIP on master: c264051 Revert "added file_size"
stash@{2}: WIP on master: 21d80a5 added number to log
```



#### 重新应用缓存的stash

可以通过`git stash pop`命令恢复之前缓存的工作目录, 这个指令**将缓存堆栈中的第一个stash删除，并将对应修改应用到当前的工作目录下**。，输出如下：

```shell
$ git status
On branch master
nothing to commit, working tree clean
$ git stash pop
On branch master
Changes to be committed:

    new file:   style.css

Changes not staged for commit:

    modified:   index.html

Dropped refs/stash@{0} (32b3aa1d185dfe6d57b3c3cc3b32cbf3e380cc6a)
```

你也可以**使用`git stash apply`命令，将缓存堆栈中的stash多次应用到工作目录中，但并不删除stash拷贝。在使用`git stash apply`命令时可以通过名字指定使用哪个stash，默认使用最近的stash（即stash@{0}）**命令输出如下：

```shell
$ git stash apply stash@{0}
On branch master
Changes to be committed:

    new file:   style.css

Changes not staged for commit:

    modified:   index.html
```

#### git stash drop移除stash

可以使用`git stash drop`命令，后面可以跟着stash名字。下面是一个示例：

```
$ git stash list
stash@{0}: WIP on master: 049d078 added the index file
stash@{1}: WIP on master: c264051 Revert "added file_size"
stash@{2}: WIP on master: 21d80a5 added number to log
$ git stash drop stash@{0}
Dropped stash@{0} (364e91f3f268f0900bc3ee613f9f733e82aaed43)
```

或者使用`git stash clear`命令，删除所有缓存的stash。

#### git stash show查看指定stash的diff

可以使用`git stash show`命令，后面可以跟着stash名字。示例如下：

```
$ git stash show
 index.html | 1 +
 style.css | 3 +++
 2 files changed, 4 insertions(+)
```

在该命令后面添加`-p`或`--patch`可以查看特定stash的全部diff，如下：

```
$ git stash show -p
diff --git a/style.css b/style.css
new file mode 100644
index 0000000..d92368b
--- /dev/null
+++ b/style.css
@@ -0,0 +1,3 @@
+* {
+  text-decoration: blink;
+}
diff --git a/index.html b/index.html
index 9daeafb..ebdcbd2 100644
--- a/index.html
+++ b/index.html
@@ -1 +1,2 @@
+<link rel="stylesheet" href="style.css"/>
```



## 合并分支的三种形式

merge前

![image-20200917200653217](img\image-20200917200653217.png)

#### git merge

```shell
git checkout master
git merge devel
```

- 优点: commit line笔直
- 缺点: 如果devel分支上commit比较多比较乱的话也会导致master分支上commit比较多比较乱

![image-20200917200949759](img\image-20200917200949759.png)

#### git merge --squash

```shell
git checkout master
git merge --squash devel
```

然后你会发现master分支上有未提交的修改, 需要你在master上主动提交修改. 注意, 这里是你的commit, 也就是说改变了commit的author. 

- 优点: 合并了多个commit为一个
- 缺点: 改变了提交信息

![image-20200917201716573](img\image-20200917201716573.png)

#### git merge -- rebase

```shell
git checkout devle
git rebase -i master
git checkout master
git merge devle
```

- 优点: 多个commit合并为1个, 保留作者信息
- 缺点: 需要在devel分支上执行git rebase, 导致devel分支上的原始commit history变化了.

![image-20200917201930425](img\image-20200917201930425.png)



## git remote 详解

#### git remote --help 显示帮助文档

#### git remote add 添加远程仓库

~~~shell
git remote add <remote_name> <url>
~~~

#### git remote -v 显示所有远程仓库及地址

![image-20201012192953309](img/image-20201012192953309.png)

#### git remote rename 重命名远程仓库

![image-20201012193158852](img/image-20201012193158852.png)

#### git remote remove 删除远程仓库

~~~shell
git remote remove <remote_name>
~~~

#### git remote show 显示远程仓库的详细信息

![image-20201012193406972](img/image-20201012193406972.png)

红色框显示了可以pull和push的分支

![image-20201012193804584](img/image-20201012193804584.png)

同时显示了所有的远程分支以及远程分支的状态, **tracked为正常状态, new表示新建的远程分支,下次fetch会在本地新建这个远程分支, stale表示该分支已经在远程仓库删除了, 请使用git remote prune删除本地的这个远程分支**

#### git remote prune 

~~~shell
# 删除远程仓库中已经删除的本地的远程分支
git remote prune <remote_name>
# 列出远程仓库中已经删除的分支
git remote prune --dry-run <remote_name>

# git fetch + git remote prune
git fetch --prune
~~~

#### git remote update

~~~shell
# 同git fetch
git remote update
~~~

### git 实用技巧

> 查看文件是在哪一个commit中被删除的？

~~~shell
# 显示文件的变化，即使文件被删除也能正常工作。
git log -1 -- [file path]
~~~

> 从远程分支创建本地分支

~~~shell
git switch -c test_branch origin/test_branch
~~~

> 删除本地分支与远程分支

~~~shell
git branch -D test_branch # 删除本地分支
git push origin :test_branch # 删除远程分支， 相当于推送了一个空的本地分支到远程分支上。
git remote prune origin #从远程仓库同步分支情况到本地仓库，针对远程分支被删除而本地分支还保留的情况，只要同步一下分支情况即可删除对应的本地分支。
~~~





## Linux 命令使用

#### 查看端口占用

~~~shell
# 查看8080端口的占用
lsof -i:8080
~~~

#### gz压缩包

- 解压

  gzip -d fileName

- 压缩

  gzip fileName

- 查看文件压缩内容

  zcat fileName, 可结合管道使用

- 不解压直接搜索压缩文件

  zgrep 模式 文件名

  ~~~shell
  # 在压缩文件中直接搜索字符a
  zgrep a /root.gz
  ~~~

  

#### 压缩、解压、tar命令

> 常见的压缩文件压缩和解压缩

| 文件后缀名 | 说明                           | 压缩                              | 解压缩                    |
| ---------- | ------------------------------ | --------------------------------- | ------------------------- |
| *.zip      | zip 程序打包压缩的文件         | zip fileName.zip dirName          | unzip fileName.zip        |
| *.rar      | rar 程序压缩的文件             | rar a fileName.rar dirName        | rar x fileName.rar        |
| *.7z       | 7zip 程序压缩的文件            | 7z a fileName.7z dirName          | 7z x fileName.7z          |
| *.tar      | tar 程序打包，未压缩的文件     | tar cvf fileName.tar dirName      | tar xvf fileName.tar      |
| *.gz       | gzip 程序 (GNU zip) 压缩的文件 | gzip fileName                     | gzip -d fileName.gz       |
| *.bz2      | tar 打包，gzip 程序压缩的文件  | bzip2 -z FileName                 | bzip2 -d FileName.bz2     |
| *.tar.gz   | tar打包，gzip程序压缩的文件    | tar zcvf FileName.tar.gz dirName  | tar zxvf FileName.tar.gz  |
| *.tar.xz   | tar打包，xz程序压缩的文件      | tar cvJf fileName.tar.xz dirName  | tar -xvJf fileName.tar.xz |
| *.tar.bz2  | tar打包，bzip2程序压缩的文件   | tar jcvf FileName.tar.bz2 dirName | tar jxvf FileName.tar.bz2 |
| *.Z        | compress命令解压缩rar文件      | compress fileName                 | uncompress fileName.Z     |

> 参数

必选参数：

- -c：建立一个压缩文件的参数指令(create 的意思)；   
- -x：解开一个压缩文件的参数指令！  
- -t：查看 tarfile 里面的文件！   
- -r：向压缩归档文件末尾追加文件   
- -u：更新原压缩包中的文件   

可选参数：

- -z：有gzip属性,即需要用 gzip 压缩   
- -j：有bz2属性,即需要用 bzip2 压缩   
- -Z：有compress属性的   
- -v ：压缩的过程中显示文件(显示所有过程)！这个常用，但不建议用在背景执行过程！   
- -O：将文件解开到标准输出   
- -f ：使用档名，请留意，在 f 之后要立即接档名！不要再加参数！       例如：使用『 tar -zcvfP tfile sfile』就是错误的写法，要写成『 tar -zcvPf tfile sfile』才对喔！  -p ：使用原文件的原来属性（属性不会依据使用者而变）   
- -P ：可以使用绝对路径来压缩！   
- -N ：比后面接的日期(yyyy/mm/dd)还要新的才会被打包进新建的文件中！   --exclude FILE：在压缩的过程中，不要将 FILE 打包！     
- -f: 使用档案名字，切记，这个参数是最后一个参数，后面只能接档案名。 
- -C：指定目录

> 解压

~~~shell
# 将/source/kernel.tgz解压到 /source/linux-2.6.29 目录
tar zxvf /source/kernel.tgz -C /source/linux-2.6.29

tar –xvf file.tar         // 解压 tar包  
tar -zxvf file.tar.gz     // 解压tar.gz  
tar -jxvf file.tar.bz2    // 解压 tar.bz2  
tar –Zxvf file.tar.Z      // 解压tar.Z  
~~~

> 压缩

~~~shell
# 将linux-2.6.29 目录压缩到 kernel.tgz
tar -czvf kernel.tgz linux-2.6.29

# 将目录里所有jpg文件打包成tar.jpg  
tar -cvf jpg.tar *.jpg       

# 将目录里所有jpg文件打包成jpg.tar后，并且将其用gzip压缩，生成一个gzip压缩过的包，命名为jpg.tar.gz  
tar –czf jpg.tar.gz *.jpg   

# 将目录里所有jpg文件打包成jpg.tar后，并且将其用bzip2压缩，生成一个bzip2压缩过的包，命名为jpg.tar.bz2 
tar –cjf jpg.tar.bz2 *.jpg 

# 将目录里所有jpg文件打包成jpg.tar后，并且将其用compress压缩，生成一个umcompress压缩过的包，命名为jpg.tar.Z  
tar –cZf jpg.tar.Z *.jpg     
~~~

> 查看

~~~shell
# 列出压缩包中所有文件
tar -tf aaa.tar.gz
~~~

#### ps命令

选项：

- a：显示一个终端的所有进程，除会话引线外；
- u：显示进程的归属用户及内存的使用情况；
- x：显示没有控制终端的进程；
- -a：显示同意终端下所有进行
- -A:  显示所有进程
- -l：长格式显示更加详细的信息；
- -e：显示所有进程，等于-A；
- -u：指定用户的所有进程

~~~shell
# 显示所有进程
ps aux

USER PID %CPU %MEM  VSZ  RSS   TTY STAT START TIME COMMAND
root   1  0.0  0.2 2872 1416   ?   Ss   Jun04 0:02 /sbin/init
root   2  0.0  0.0    0    0   ?    S   Jun04 0:00 [kthreadd]

USER	该进程是由哪个用户产生的。
PID	进程的 ID。
%CPU	该进程占用 CPU 资源的百分比，占用的百分比越高，进程越耗费资源。
%MEM	该进程占用物理内存的百分比，占用的百分比越高，进程越耗费资源。
VSZ	该进程占用虚拟内存的大小，单位为 KB。
RSS	该进程占用实际物理内存的大小，单位为 KB。
TTY	该进程是在哪个终端运行的。
STAT	进程状态。
START	该进程的启动时间。
TIME	该进程占用 CPU 的运算时间，注意不是系统时间。
COMMAND	产生此进程的命令名。
~~~

~~~shell
# 显示指定用户进程
ps -u root
~~~

~~~shell
# 显示所有进程信息，连同命令行
ps -ef 
~~~

~~~shell
ps -le
~~~

#### man命令查看帮助文档

man命令是Linux下最核心的命令之一。而man命令也并不是英文单词“man”的意思，它是单词**manual**的缩写，即使用手册的意思。



**man手册页文件存放在/usr/share/man目录下。**



Linux的man手册共有以下几个章节：

| 代號 | 代表內容                                                     |
| ---- | ------------------------------------------------------------ |
| 1    | Executable programs or shell commands<br/> 使用者在shell中可以操作的指令或可执行档 |
| 2    | System calls (functions provided by the kernel)<br/>系統核心可呼叫的函数与工具等 |
| 3    | Library calls (functions within program libraries)<br/>一些常用的函数(function)与函数库(library)，大部分是C的函数库(libc) |
| 4    | Special files (usually found in /dev)<br/>装置档案的说明，通常在/dev下的档案 |
| 5    | File formats and conventions eg /etc/passwd<br/>设定档或者是某些档案的格式 |
| 6    | Games<br/>游戏                                               |
| 7    | Miscellaneous (including macro packages and conventions), e.g. man(7), groff(7)<br/>惯例与协定等，例如Linux档案系统、网络协定、ASCII code等等的說明 |
| 8    | System administration commands (usually only for root)<br/>系統管理員可用的管理指令 |
| 9    | Kernel routines [Non standard]<br>跟kernel有关的文件         |

我们输入`man ls`，它会在最左上角显示“LS（1）”，在这里，“LS”表示手册名称，而“（1）”表示该手册位于第一节章，表示可执行命令。

**man是按照手册的章节号的顺序进行搜索的**，比如：

```
man sleep
```

只会显示sleep命令的手册,如果想查看库函数sleep，就要输入:

```
man 3 sleep
```

> 选项

- -a：在所有的man帮助手册中搜索

  ~~~shell
  man -a sleep
  ~~~

  显示sleep(1)按q推出后将会询问还有sleep(3)是否查看

  ![image-20201014112806163](img/image-20201014112806163.png)

- -w：显示手册所在位置

  man -w只会显示搜索到的第一个文档的位置

  man -aw显示搜索到的全部文档的位置

  ![image-20201014113051046](img/image-20201014113051046.png)





#### shell输入输出重定向

输入输出类型：

| 类型                        | 文件描述符 | 默认情况               | 对应文件句柄位置 |
| :-------------------------- | :--------- | :--------------------- | :--------------- |
| 标准输入（standard input）  | 0          | 从键盘获得输入         | /proc/self/fd/0  |
| 标准输出（standard output） | 1          | 输出到屏幕（即控制台） | /proc/self/fd/1  |
| 错误输出（error output）    | 2          | 输出到屏幕（即控制台） | /proc/self/fd/2  |

> 重定向输出

| 命令                | 介绍                                                         |
| :------------------ | :----------------------------------------------------------- |
| command >filename   | 把标准输出重定向到新文件中(**删除文件再新建再写入**, 等于**覆盖**内容)（**没有文件新建**） |
| command 1>filename  | 同上                                                         |
| command >>filename  | 把标准输出**追加**到文件中（**没有文件新建**）               |
| command 1>>filename | 同上                                                         |
| command 2>filename  | 把标准错误重定向到新文件中                                   |
| command 2>>filename | 把标准错误追加到新文件中                                     |

案例：
~~~shell
$ ls
Dockerfile
$ ls Dockerfile a.txt
ls: cannot access a.txt: No such file or directory
Dockerfile
~~~

上面命令，我们目录下只有Dockerfile一个文件， 使用`ls Dockerfile a.txt`命令以后，`ls: cannot access a.txt: No such file or directory`是错误输出，`Dockerfile`是标准输出。所以我们可以将错误内容输出到error.txt文件中，把标准输出输入到stadand.txt文件中。

~~~shell
$ ls Dockerfile a.txt > error.txt 2>error.txt
~~~

~~~shell
# 把"hello world输入到a.txt中"
echo "hello world" > a.txt
~~~





> 输入重定向

| 命令                | 介绍                                      |
| :------------------ | :---------------------------------------- |
| command <filename   | 以filename文件作为标准输入                |
| command 0<filename  | 同上                                      |
| command <<delimiter | 从标准输入中读入，直到遇到delimiter分隔符 |

案例：

~~~shell
# 从标准输入中读取，直到遇到结束符， <<后面的是自定义的结束符
$ cat >a.txt  <<end
hello
world
end

$ cat a.txt 
hello
world
~~~
> 高级用法(https://blog.csdn.net/qq_31073871/article/details/80810306)

**>/dev/null**

这条命令的作用是将标准输出1重定向到`/dev/null`中。 `/dev/null`代表linux的空设备文件，所有往这个文件里面写入的内容都会丢失，俗称“黑洞”。那么执行了`>/dev/null`之后，标准输出就会不再存在，没有任何地方能够找到输出的内容。

**2  >&1**

这条命令用到了重定向绑定，采用&可以将两个输出绑定在一起。这条命令的作用是**将错误输出输入到标准输出**

2>&1，可以这样理解：按照前面讲解的知识，“2>”表示要把标准错误信息进行重定向，一般来说，重定向的目标是某个文件，而这条语句把重定向的目标设置成了文件描述符1的输入了，也即“&1”，也即，fd2的输出会被送到fd1的输入中去，后果就是，fd2的输入从fd1的输出口送了出来，流程是这样的：fd2输入 -> fd2输出 -> fd1的输入 -> fd的输出。

linux在执行shell命令之前，就会**确定好所有的输入输出位置，并且从左到右依次执行重定向的命令**，所以`>/dev/null 2>&1`的作用就是让标准输出重定向到`/dev/null`中（丢弃标准输出），然后错误输出由于重用了标准输出的描述符，所以错误输出也被定向到了`/dev/null`中，错误输出同样也被丢弃了。执行了这条命令之后，该条shell命令将不会输出任何信息到控制台，也不会有任何信息输出到文件中。

**>/dev/null 2>&1 和 2>&1 >/dev/null**

乍眼看这两条命令貌似是等同的，但其实大为不同。刚才提到了，linux在执行shell命令之前，就会确定好所有的输入输出位置，并且从左到右依次执行重定向的命令。

那么我们同样从左到右地来分析`2>&1 >/dev/null`：`2>&1`，将错误输出绑定到标准输出上。由于此时的标准输出是默认值，也就是输出到屏幕，所以错误输出会输出到屏幕。`>/dev/null`，将标准输出1重定向到`/dev/null`中。

**>/dev/null 2>&1 和 >/dev/null 2>/dev/null**

那么可能会有些同学会疑问，为什么要用重定向绑定，而不是像`>/dev/null 2>/dev/null`这样子重复一遍呢。

为了回答这个问题，我们回到刚才介绍输出重定向的场景。我们尝试将标准输出和错误输出都定向到out文件中：

```
# ls a.txt b.txt >out 2>out
# cat out
a.txt
无法访问b.txt: 没有那个文件或目录
```

WTF？竟然出现了乱码，这是为啥呢？这是因为采用这种写法，标准输出和错误输出会抢占往out文件的管道，所以可能会导致输出内容的时候出现缺失、覆盖等情况。现在是出现了乱码，有时候也有可能出现只有error信息或者只有正常信息的情况。不管怎么说，采用这种写法，最后的情况是无法预估的。

而且，由于out文件被打开了两次，两个文件描述符会抢占性的往文件中输出内容，所以整体IO效率不如`>/dev/null 2>&1`来得高。



#### 环境变量与export

> Linux环境变量分类

一、按照生命周期来分，Linux环境变量可以分为两类：
 1、永久的：需要用户修改相关的配置文件，变量永久生效。
 2、临时的：用户利用export命令，在当前终端下声明环境变量，关闭Shell终端失效。

二、按照作用域来分，Linux环境变量可以分为：
 1、系统环境变量：系统环境变量对该系统中所有用户都有效。
 2、用户环境变量：顾名思义，这种类型的环境变量只对特定的用户有效。

>  Linux设置环境变量的方法

一、在`/etc/profile`文件中添加变量 **对所有用户生效（永久的）**
 用vim在文件`/etc/profile`文件中增加变量，该变量将会对Linux下所有用户有效，并且是“永久的”。
 例如：编辑/etc/profile文件，添加CLASSPATH变量

```bash
  vim /etc/profile    
  export CLASSPATH=./JAVA_HOME/lib;$JAVA_HOME/jre/lib
```

注：修改文件后要想马上生效还要运行`source /etc/profile`不然只能在下次重进此用户时生效。



 二、在用户目录下的.bash_profile文件中增加变量 **【对单一用户生效（永久的）】**
 用`vim ~/.bash_profile`文件中增加变量，改变量仅会对当前用户有效，并且是“永久的”。

```bash
vim ~/.bash.profile
export CLASSPATH=./JAVA_HOME/lib;$JAVA_HOME/jre/lib
```

注：修改文件后要想马上生效还要运行$ source ~/.bash_profile不然只能在下次重进此用户时生效。



 三、直接运行export命令定义变量 **【只对当前shell（BASH）有效（临时的）】**
 在shell的命令行下直接使用`export 变量名=变量值`
 定义变量，该变量只在当前的shell（BASH）或其子shell（BASH）下是有效的，shell关闭了，变量也就失效了，再打开新shell时就没有这个变量，需要使用的话还需要重新定义。



#### awk

功能：逐行扫描文件，寻找含有目标文本的行，如果匹配成功，则会在该行上执行用户想要的操作；反之，则不对行做任何处理。

格式：用来指定脚本命令可以作用到文本内容中的具体行，可以使用字符串（**比如 /demo/，表示查看含有 demo 字符串的行**）或者正则表达式指定。另外需要注意的是，整个脚本命令是用单引号''括起，而其中的执行命令部分需要用大括号{}括起来。

在 awk 程序执行时，如果没有指定执行命令，则默认会把匹配的行输出；如果不指定匹配规则，则默认匹配文本中所有的行。

~~~shell
 awk [选项] '匹配规则{执行命令}' 文件名
~~~

选项：

| 选项       | 含义                                                         |
| ---------- | ------------------------------------------------------------ |
| -F fs      | 指定以 fs 作为输入行的分隔符，awk 命令**默认分隔符为空格或制表符**。 |
| -f file    | 从脚本文件中读取 awk 脚本指令，以取代直接在命令行中输入指令。 |
| -v var=val | 在执行处理过程之前，设置一个变量 var，并给其设备初始值为 val。 |

默认情况下，awk 会将如下变量分配给它在文本行中发现的数据字段：

- $0 代表整个文本行；
- $1 代表文本行中的第 1 个数据字段；
- $2 代表文本行中的第 2 个数据字段；
- $n 代表文本行中的第 n 个数据字段。

前面说过，**在 awk 中，默认的字段分隔符是任意的空白字符（例如空格或制表符）。 在文本行中，每个数据字段都是通过字段分隔符划分的。awk 在读取一行文本时，会用预定义的字段分隔符划分每个数据字段。**

例子：

~~~shell
[root@localhost ~] cat data2.txt
One line of test text.
Two lines of test text.
Three lines of test text.
[root@localhost ~] awk '{print $1}' data2.txt
One
Two
Three
~~~

~~~shell
docker ps -a | awk '/elasticsearch/{print $1}' # 执行docker ps -a，然后显示所有跟es有关的容器的id

docker ps -a | awk '/elasticsearch/{print "docker rm "$1}' | sh # 删除所有跟es有关的容器
~~~



#### shell $(),${}

> 1、在 bash shell 中，$()是将括号内命令的执行结果赋值给变量：

```shell
#将命令 ls 赋值给变量 a
$ a=$(ls)
$ echo $a
a.sh data.sh results.txt
```

~~~shell
# 将$()中计算的结果给docker rm, 所以这里是删除所有跟es有关的容器
docker rm $(docker ps -a | awk '/elasticsearch/{print $1}')
~~~

>  2、${} 是用来作变量替换。一般情况下，$var 与 ${var} 并没有啥不一样。但是用 ${ } 会比较精确的界定变量名称的范围：

```bash
$ A=B
#目的想打印变量A，然后再加上一个B，结果返回无。
$ echo $AB
#此时，${ }可以较为精确的确定变量的范围
$ echo ${A}B
BB
```

#### watch

在Linux下，watch是周期性的执行下个程序，并全屏显示执行结果。

命令格式：`watch` `[参数]` `[命令]`

多个命令使用''引器来

-n或--interval watch缺省每2秒运行一下程序，可以用-n或-interval来指定间隔的时间。

-d或--differences 用-d或--differences 选项watch 会高亮显示变化的区域。 而-d=cumulative选项会把变动过的地方(不管最近的那次有没有变动)都高亮显示出来。

~~~shell
# 每隔一秒高亮显示http链接数的变化情况
watch -n 1 -d 'pstree|grep http'
~~~

#### top

https://man.linuxde.net/top

**top命令**可以实时动态地查看系统的整体运行情况，是一个综合了多方信息监测系统性能和运行信息的实用工具。通过top命令所提供的互动式界面，用热键可以管理。

> 语法 

```
top(选项)
```

> 选项 

- -b：以批处理模式操作；
- -c：显示完整的进程运行命令；
- **-d：屏幕刷新间隔时间；**
- -I：忽略失效过程；
- -s：保密模式；
- -S：累积模式；
- -i<时间>：设置间隔时间；
- **-u<用户名>：指定用户名；**
- **-p<进程号>：指定进程；**
- -n<次数>：循环显示的次数。

> top交互命令 

在top命令执行过程中可以使用的一些交互命令。这些命令都是单字母的，如果在命令行中使用了-s选项， 其中一些命令可能会被屏蔽。

- **h：显示帮助画面，给出一些简短的命令总结说明；**
- **k：终止一个进程；**
- i：忽略闲置和僵死进程，这是一个开关式命令；
- **q：退出程序；**
- r：重新安排一个进程的优先级别；
- S：切换到累计模式；
- **s：改变两次刷新之间的延迟时间（单位为s），如果有小数，就换算成ms。输入0值则系统将不断刷新，默认值是5s；**
- f或者F：从当前显示中添加或者删除项目；
- o或者O：改变显示项目的顺序；
- l：切换显示平均负载和启动时间信息；
- m：切换显示内存信息；
- t：切换显示进程和CPU状态信息；
- **c：切换显示命令名称还是完整命令行；同-c参数**
- **M：根据驻留内存大小进行排序；**
- **P：根据CPU使用百分比大小进行排序；**
- T：根据时间/累计时间进行排序；
- w：将当前设置写入~/.toprc文件中。

> 实例 

```
top - 09:44:56 up 16 days, 21:23,  1 user,  load average: 9.59, 4.75, 1.92
Tasks: 145 total,   2 running, 143 sleeping,   0 stopped,   0 zombie
Cpu(s): 99.8%us,  0.1%sy,  0.0%ni,  0.2%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   4147888k total,  2493092k used,  1654796k free,   158188k buffers
Swap:  5144568k total,       56k used,  5144512k free,  2013180k cached
```

**解释：**

- top - 09:44:56[当前系统时间],
- 16 days[系统已经运行了16天],
- 1 user[个用户当前登录],
- load average: 9.59, 4.75, 1.92[系统负载，即任务队列的平均长度]
- Tasks: 145 total[总进程数],
- 2 running[正在运行的进程数],
- 143 sleeping[睡眠的进程数],
- 0 stopped[停止的进程数],
- 0 zombie[冻结进程数],
- Cpu(s): 99.8%us[用户空间占用CPU百分比],
- 0.1%sy[内核空间占用CPU百分比],
- 0.0%ni[用户进程空间内改变过优先级的进程占用CPU百分比],
- 0.2%id[空闲CPU百分比], 0.0%wa[等待输入输出的CPU时间百分比],
- 0.0%hi[],
- 0.0%st[],
- Mem: 4147888k total[物理内存总量],
- 2493092k used[使用的物理内存总量],
- 1654796k free[空闲内存总量],
- 158188k buffers[用作内核缓存的内存量]
- Swap: 5144568k total[交换区总量],
- 56k used[使用的交换区总量],
- 5144512k free[空闲交换区总量],
- 2013180k cached[缓冲的交换区总量],

#### less

> option

-i：忽略搜索时的大小写

-N：显示行号

-m：显示百分比

> 常用

h：帮助文档

q：退出

> 移动

方向键：上下左右

f(forward) 、PageDown：后一页

b(backward)、PageUp：前一页

> 搜索

/字符串：向下搜索“字符串”的功能

?字符串：向上搜索“字符串”的功能

n：重复前一个搜索（与 / 或 ? 有关）

N：反向重复前一个搜索（与 / 或 ? 有关）

> 跳转

g：跳转到第一行

G：跳转到最后一行



#### curl

https://blog.csdn.net/wuhuagu_wuhuaguo/article/details/90764856#%E4%B8%80%E3%80%81%E6%9C%80%E5%B8%B8%E7%94%A8%E7%9A%84curl%E5%91%BD%E4%BB%A4

http://aiezu.com/article/linux_curl_command.html

| 选项                                                         | 作用                                                         | 示例                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| -X                                                           | 设置请求方式POST/GET/HEAD/DELETE/PUT/PATCH                   | curl -X GET www.baidu.com, 使用GET方式请求百度               |
| -H "name: value"<br />--header "name: value"                 | 添加http的请求头                                             | curl -H "cookie: token=123" -H "origin: https://www.baidu.com" www.baidu.com， 设置请求头 |
| -H "name: "<br />--header "name: "                           | 移除一个http header                                          |                                                              |
| -A "string"<br />--user-agent "string"                       | 设置Http请求头“User-Agent”，服务器通过“User-Agent”可以判断客户端使用的浏览器名称和操作系统类型，伪造此参数能导致服务器做出错误判断。<br/>也可以使用“-H”, “--header option”设置此选项；<br />使用-A "" 将会移除User-Agent请求头 |                                                              |
| -e "url"<br />--referer "url"                                | 设置Referer请求头，告诉http服务从哪个页面进入到此页面；      |                                                              |
| -b "name1=value1;name2=value2"<br />--cookie "name1=value1;name2=value2" | 设置cookie，设置多个cookie使用分号隔开，使用多个-b选项只有最后一个生效（与-H不同）。 |                                                              |
| -d "data"<br />--data "data"<br /> --data-ascii "data"<br />--data-binary "data"<br />--data-raw "data" | 发送指定数据给服务器, 就像html表单一样.curl将会使用content-type application/x-www-form-urlencoded 发送数据<br />-d, --data --data-ascii效果一样. --data-raw 与上述一样但不会转义@字符.<br />要发送二进制数据请使用--data-binary.  <br />要讲数据进行url编码请使用--data-urlencode.<br/>以上选项多次使用将会把数据通过&合并在一起，因此使用 '-d name=daniel -d skill=lousy' 将会生成 'name=daniel&skill=lousy'.<br/>If you start the data with the letter @, the rest should be a file name to read the data from, or - if you want curl to read the  data  from              stdin.  Multiple files can also be specified. Posting data from a file named 'foobar' would thus be done with --data @foobar. 读取文件时，回车和换行将被丢弃。如果不想@作为转义字符请使用--data-raw instead. | curl -d "login=root&pwd=123"  www.baidu.com 向百度post"login=root&pwd=123"字符串。<br />**curl -d "@data.txt" www.baidu.com 读取`data.txt`文件的内容，作为数据体向服务器发送。** |
| --data-urlencode `<data>`                                    | 除了执行url编码，与--data一样<br/>`<data>`需要符合以下格式<br /><br />content   这会将content进行编码，content中不能包含任何@，=<br/><br /> =content  这会将content进行编码，包括= @都会进行编码.<br/><br /> name=content  仅编码content内容，name需要是已经进行url编码的<br/> @filename 将文件内容读取出来编码<br/><br/>name@filename  将文件内容进行编码需要是已经进行url编码的。 |                                                              |
| -I <br />--head                                              | 只输出返回的请求头，不输出请求体                             |                                                              |
| -i<br />--include                                            | 输出返回的请求头和请求体                                     |                                                              |
| -D file<br />--dump-header file                              | 保存http响应头到指定的文件                                   | curl -D hello.txt www.baidu.com 将响应头保存在hello.txt中    |
| -c file<br />--cookie-jar file                               | 将服务器返回cookie保存到指定文件中                           | curl -c hello.txt www.baidu.com 将cookie保存在hello.txt中    |
| -G                                                           |                                                              |                                                              |
| -F, --form <name=content>                                    | 模拟html表单，并将Content-Type设置为  multipart/form-data.<br />如果content是文件，filename 请以@开头. 如果content是从文件中读取的，filename请以<开头.  <br/>@和<的区别是，@将会上传文件，而<将会读取文件内容转换为text上传。<br />Example, to send your password file to the server, where 'password' is the name of the form-field to which /etc/passwd will be the input:<br/><br/>              curl -F password=@/etc/passwd www.mypasswords.com<br/><br/>              To read content from stdin instead of a file, use - as the filename. This goes for both @ and < constructs.<br/><br/>可以通过'type='来设置Content-Type:curl -F "web=@index.html;type=text/html" url.com 或者 curl -F "name=daniel;type=text/foo" url.com<br/><br/>可以通过'filename='来显式改变文件名：curl -F "file=@localfile;filename=nameinpost" url.com<br/><br/>如果filename或者path含有逗号和分号，必须使用""括起来：curl -F "file=@\"localfile\";filename=\"nameinpost\"" url.com 或者 curl -F 'file=@"localfile";filename="nameinpost"' url.com<br/>如果被""括起来的filename和path中含有双引号和反斜杠，则必须使用反斜杠进行转义<br/><br/>该选项可以被多次使用 |                                                              |
| -#<br/>--progress-bar                                        | 显式进度条                                                   |                                                              |
| -o <file> <br />--output <file>                              | 将返回内容输出到文件。 如果是用过通配符获取多个url，可以使用“#”后跟“数字序号”，curl会自动将它替换对应的关键词，如： 　　curl "http://aiezu.com/{a,b}.txt" -o "#1.txt"; 　　将保存为：“a.txt”,“b.txt”;  　　curl "http://aiezu.com/{a,b}_[1-3].txt" -o "#1#2.txt"; 　　将保存为：a1.txt、a2.txt、a3.txt、b1.txt、b2.txt、b3.txt  　　如果要根据规则创建保存目录，参考：“--create-dirs”  指定“-”将定向到标准输出“如控制台”； |                                                              |
| -O --remote-name                                             | 将返回内容输出到当前目录下，并将 URL 的最后部分当作文件名；  |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |



#### nohup







## 杂乱

#### 打印日志的注意点

#### java静态变量、静态代码块、代码块、成员变量初始化时机

>  Java中静态变量初始化、static块执行时机（https://www.cnblogs.com/aflyun/p/9562885.html）

演示例子

在使用static进行初始化的操作，怎么也执行不了！代码如下：

```java
public class StaticDemo {

    public static final String INIT = "init";
    static {
        System.out.println("------StaticDemo----");
    }
}

public class TestStatic {

    public static void main(String[] args) {
        System.out.println(StaticDemo.INIT);
    }
}
//打印
init
```

怎么没有执行 static 块的代码呢？

最后发现是因为调用的静态属性被final修饰导致的。去掉final修饰，结果OK！

```
public class StaticDemo {

    //去掉 final
    public static String INIT = "init";
    static {
        System.out.println("------StaticDemo----");
    }
}

public class TestStatic {

    public static void main(String[] args) {
        System.out.println(StaticDemo.INIT);
    }
}
//打印结果
------StaticDemo----
init
```

(static final的基础类型和String可能在编译的时候就定下来了吧)

这里就和类加载机制中的 **初始化** 相关！**类被加载了不一定就会执行静态代码块，只有一个类被主动使用的时候，静态代码才会被执行**！

　当一个类被主动使用时，Java虚拟就会对其初始化，如下六种情况为主动使用：

1. 当创建某个类的新实例时（如通过new或者反射，克隆，反序列化等）

2. 当调用某个类的静态方法时

3. **当使用某个类或接口的静态字段时**

4. 当调用Java API中的某些反射方法时，比如类Class中的方法，或者java.lang.reflect中的类的方法时

5. 当初始化某个子类时

6. 当虚拟机启动某个被标明为启动类的类（即包含main方法的那个类）

   Java编译器会收集所有的类变量初始化语句和类型的静态初始化器，将这些放到一个特殊的方法中：clinit。

**重点：使用final修饰的静态字段，在调用的时候不会对类进行初始化！**

> 静态变量、静态代码块、代码块、成员变量调用顺序

1. 类被主动使用时，静态代码被执行
   - 为非final的静态变量分配内存空间，并赋初始值（不对变量进行初始化）
   - 从上到下为静态变量初始化和执行静态代码块
2. 类实例化的时候，执行普通代码块和对成员变量初始化
   - 为成员变量分配内存空间，并赋初始值
   - 从上到下为成员变量初始化和执行普通代码块
   - 执行构造函数

案例分析（https://blog.csdn.net/tongyi55555/article/details/46627415）

~~~java
public class VarOrder {

    public static int k = 0;
    public static VarOrder t1 = new VarOrder("t1");
    public static VarOrder t2 = new VarOrder("t2");
    public static int i = print("i");
    public static int n = 99;
    private int a = 0;
    public int j = print("j");
    {
        print("构造块");
    }
    static {
        print("静态块");
    }

    public VarOrder(String str) {
        System.out.println((++k) + ":" + str + " i=" + i + " n=" + n);
        ++i;
        ++n;
    }

    public static int print(String str) {
        System.out.println((++k) + ":" + str + " i=" + i + " n=" + n);
        ++n;
        return ++i;
    }

    public static void main(String args[]) {
        VarOrder t = new VarOrder("init");
    }
}
~~~

　1). 静态的一定是最开始进行调用的，如果存在多个，那么写在前面的先调用，因此静态变量int k先调用，没有输出；

　　2). 静态变量t1开始调用，t1是该类的实例对象，因此在实例对象中，非静态变量和代码块要首先进行初始化，因此int a和int j先进行调用进行赋值，然后是代码块进行调用。**虽然类的静态变量和静态代码块的调用顺序要高于非静态变量和代码块，但是因为这里的t1是实例对象，因此不会跳转到t1和t2后面的静态变量int i和int n中执行赋值，打印输出的都是i和n的初始值，从0开始。**最后才是自身的构造函数进行调用，输出如下：

```
1:j i=0 n=0
2:构造块 i=1 n=1
3:t1 i=2 n=2123
```

　　同理t1调用后，t2进行调用，输出的内容与t1实例化时相似，如下：

```
4:j i=3 n=3
5:构造块 i=4 n=4
6:t2 i=5 n=5123
```

　　3). t2实例化后，继续顺序执行，开始执行静态变量int i，此时输出内容：

```
7:i i=6 n=61
```

　　4). 继续进行静态变量int n赋值，没有输出，但是要记住此时n的值已经由6变为99；

　　5). 最后一个静态调用，即静态块调用，此时输出如下：

```
8:静态块 i=7 n=991
```

　　6). 静态变量和静态块调用完毕后，此时才开始进入到主方法的代码中执行，主方法中的代码就一句，实例化对象，与2)分析的一致，先调用非静态变量和代码块，最后调用构造函数，因此输出如下：

```
9:j i=8 n=100
10:构造块 i=9 n=101
11:init i=10 n=102123
```

**综上所述，最终的输出结果为：**

```
1:j i=0 n=0
2:构造块 i=1 n=1
3:t1 i=2 n=2
4:j i=3 n=3
5:构造块 i=4 n=4
6:t2 i=5 n=5
7:i i=6 n=6
8:静态块 i=7 n=99
9:j i=8 n=100
10:构造块 i=9 n=101
11:init i=10 n=102
```



#### window和wsl的文件互访

> wls访问windows文件

cd /mnt

> windows访问wls文件



#### 记一次排序引起的慢查询

> 起因

测试项目某个页面调用后端api经常超时，但是并发并不高

> 排查

在api代码各处打log记录执行时间（low），发现是一个排序引起的慢查询，每次查询都要两秒多，并且还是在一个循环里面，导致前端调用api超时。

查看连接的mysql数据库，发现：

- 排序字段上面没有索引
- 使用count统计表数据，发现表数据六百多万

> 解决：备份表数据，删除表一个月以前的数据

>总结

原理：

排序导致的慢查询可以从以下几个方面排查:

- 查看排序的数据量是否很大
- 是否利用索引



#### 完整的协议组成

```
协议://用户名:密码@地址:端口/路径?queryString#锚点

mongodb://wesee:3wgmhyRkiHlQ5N7tkPOYTHG@10.1.0.126:37017/wesee

https://docs.spring.io/spring-framework/docs/5.2.9.RELEASE/spring-framework-reference/core.html#beans-postconstruct-and-predestroy-annotations
```

#### Class.getReources和Class.getClassLoader.getResources的区别

今天在Java程序中读取resources资源下的文件，由于对Java结构了解不透彻，遇到很多坑。正常在Java工程中读取某路径下的文件时，可以采用绝对路径和相对路径，绝对路径没什么好说的，相对路径，即相对于当前类的路径。在本地工程和服务器中读取文件的方式有所不同，以下图配置文件为例：

　![img](img/1543609-20190708153434326-94020132.png)

> 本地读取资源文件

　　Java类中需要读取properties中的配置文件，可以采用**文件（File）**方式进行读取：

```java
File file = new File("src/main/resources/properties/test.properties");
InputStream in = new FileInputStream(file);
```

　　注意：**当在IDEA中运行（不部署在服务器上），可以读取到该文件；**

　　原因：JavaWeb项目部署服务器中，会将项目打包成Jar包或者war包，此时就不会存在 src/main/resources 目录，JVM会在编译项目时，主动将 java文件编译成 class文件 和 resources 下的静态文件放在 target/classes目录下；

　　理解：Java文件只有编译成 class文件才会被JVM执行，本地执行时会，当前项目即为Java进程的工作空间，虽然class文件在target/classes目录下，但是target/classes不是class文件运行的目录，只是存放的目录，运行目录还是在IDEA的模块下，所以运行时会找到 src/main/resources 资源文件！

> 服务器（Tomcat）读取资源文件

　　当工程部署到Tomcat中时，按照上边方式，则会抛出异常：FileNotFoundException。原因：Java工程打包部署到Tomcat中时，properties的路径变到顶层（classes下），这是由Maven工程结构决定的。由Maven构建的web工程，主代码放在src/main/java路径下，资源放在src/main/resources路径下，当构建jar包 或 war包时，JVM虚拟机会自动编译java文件为class文件存放在 target/classes目录下，resource资源下的文件会原封不动的拷贝一份到 target/classes 目录下：

![img](img/1543609-20190709195004669-345524878.png)

> 案例

\#java获取文件目录
├── pom.xml
├── src
│  ├── main
│  │  ├── java
│  │  │  ├── com
│  │  │  │  ├── alipay
│  │  │  │  │  ├── ResourceTest.java
│  │  │  │  │  └── Resource.java
│  │  └── resources
│  │  │  ├── conf
│  │  │  │  ├── sysConf.json
│  │  │  └── request.xml
└── local.iml

~~~java

public class ResourceTest {
    public static void main(String[] args) {
        // 1、通过Class的getResource方法
        // 使用绝对路径
        String a3 = ResourceTest.class.getResource("/request.xml").getPath();
        // 使用相对路径
        String a4 = ResourceTest.class.getResource("../../request.xml").getPath();
 
        // 2、通过本类的ClassLoader的getResource方法
        // 只能使用绝对路径
        String b2 = ResourceTest.class.getClassLoader().getResource("request.xml").getPath();
    }
}
~~~

Class.getResources和ClassLoader.getReources的区别在于：

- **Class.getResources可以使用相对路径，也可以使用绝对路径，使用相对路径时不加"/", 使用绝对路径时使用"/"**
- **ClassLoader.getResources不能使用相对路径，只能使用绝对路径，使用绝对路径时不用加"/", 默认就是绝对路径就是项目根目录。**

~~~java
// 读取properties时，可以通过getResourcesAsStream读取流，然后通过Properties进行加载。
InputStream in = this.getClass().getResourceAsStream("/properties/test.properties");
Properties properties = new Properties();
properties.load(in);
properties.getProperty("name");
~~~



#### 虚拟机Ubuntu磁盘扩容

**随着编译路由器的型号和数量的增多，原本50G的硬盘大小已经不够用了。**
**因此扩展了ubuntu硬盘容量，并将扩容的笔记分享给大家。**

**虚拟机关机状态下，点击编辑设置**
<img src="img/061619_0749_VMubuntu1.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**找到硬盘，点击扩展**
<img src="img/061619_0749_VMubuntu2.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom: 50%;" />

**修改磁盘大小，这里50G扩展到100G**
![《VM虚拟机ubuntu硬盘容量扩展》](img/061619_0749_VMubuntu3.png)

**扩展中**
<img src="img/061619_0749_VMubuntu4.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**虚拟机提示扩展完成**
<img src="img/061619_0749_VMubuntu5.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**开机进入系统，安装gparted分区管理工具，终端中运行**
sudo apt-get install gparted
<img src="img/061619_0749_VMubuntu6.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom: 25%;" />

**在软件管理中，找到gparted软件**
<img src="img/061619_0749_VMubuntu7.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom: 33%;" />

**提示输入密码**
<img src="img/061619_0749_VMubuntu8.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**记录sda2大小，并删除sda2**
<img src="img/061619_0749_VMubuntu9.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**选中sda5，右键禁用交换空间**
<img src="img/061619_0749_VMubuntu10.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**禁用后，再次选中sda5，右键选中删除**
<img src="img/061619_0749_VMubuntu11.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**删除sda5后，选中sda2，右键删除**
<img src="img/061619_0749_VMubuntu12.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**选中sda1，右键更改大小**
<img src="img/061619_0749_VMubuntu13.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**弹出的窗口，调整剩余空间为1024即可。**
<img src="img/061619_0749_VMubuntu14.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**完成调整后，选中未分配空间，右键新建**
<img src="img/061619_0749_VMubuntu15.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**弹出的窗口，选择创建为扩展分区**
<img src="img/061619_0749_VMubuntu16.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**完成后，选中新出现的未分配分区，右键新建**
<img src="img/061619_0749_VMubuntu17.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**弹出的窗口，选择文件系统为：linux-swap**
<img src="img/061619_0749_VMubuntu18.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**确认参数无误，点击上面(√)确认按钮**
<img src="img/061619_0749_VMubuntu19.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**点击应用，执行修改**
<img src="img/061619_0749_VMubuntu20.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**大约10分钟，完成所有操作**
<img src="img/061619_0749_VMubuntu21.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom:50%;" />

**查看系统硬盘是否成功扩展**
df -h
<img src="img/061619_0749_VMubuntu22.png" alt="《VM虚拟机ubuntu硬盘容量扩展》" style="zoom: 50%;" />

**成功扩展，以上就是VM虚拟机ubuntu硬盘大小扩展的所有操作。**





## 多线程

#### synchronized

1. synchronized关键字**不能**被继承 即父类方法是同步方法 子类方法继承后默认不是同步方法
2. synchronized**不能**修饰接口方法 因为接口是特殊的抽象类 不能新建实例 实例锁应归实现其的类所有
3. synchronized**不能**修饰构造方法（但可在内部使用synchronized代码块来同步
4. 对成员方法修饰 -> synchronized(this)
5. 对静态方法修饰 -> synchronized(ClassA.class)
6. 尝试获取该对象锁的线程会被阻塞，并不影响其他线程不获取锁的操作，所以要在涉及同步量操作的所有地方采用同步方法（如加锁），否则引起线程安全问题几乎是必然的。
7. 可重进入, 在父子类继承的情况下也支持.

#### synchronized原理

#### 多线程状态

#### 常用方法

> sleep

强制当前正在执行的线程休眠（），但是不会释放锁，不需要在同步块中调用，当前线程sleep时如果

> yield

释放线程所占有的CPU资源，从而让其他线程有机会运行，但是并不能保证某个特定的线程能够获得CPU资源。谁能获得CPU完全取决于调度器，在有些情况下调用yield方法的线程甚至会再次得到CPU资源。所以，依赖于yield方法是不可靠的，它只能尽力而为。yield()并不释放锁。

> sleep与yield的区别

- sleep让当前正在执行的线程暂停一段时间，并**进入阻塞状态**，则可以通过调用Thread类的静态sleep()方法来实现。当前线程调用sleep()方法进入阻塞状态后，在其睡眠时间内，该线程不会获得执行的机会，而**其它任何优先级的线程都可以得到执行的机会**，即使系统中没有其它可执行的线程，处于sleep()的线程也不会执行，sleep()是用来暂停线程的执行。

  yield()方法是一个和sleep()方法有点相似的方法，它也是Thread类提供的一个静态方法。可以让当前正在执行的线程暂停，但它不会阻塞该线程，只是**将该线程转入就绪状态**。yeild()只是让当前线程暂停一下，**让系统的线程调度器重新调度一次**，完全可能的情况是：当某个线程调用了yield()线程暂停之后，线程调度器又将其调度出来重新执行。
  当某个线程调用了yield()方法暂停之后，**只有优先级与当前线程相同，或者优先级比当前线程更高的处于就绪状态的线程才会获得执行机会**。

- sleep()方法的声明抛出了InterruptedException异常，所以调用sleep()方法时要么捕捉异常，要么抛出该异常。
- sleep()方法比yield()方法具有更好的可移动性，所以建议不要使用yield()方法来控制并发线程的执行



> 暂停线程suspend(废弃)和resume(废弃)

> 停止线程stop

> 中断线程interrupt

调用interrupt方法仅仅是在当前线程中打了一个停止的标记，并不是真正的停止线程。线程中断并不会立即终止线程，而是通知目标线程，有人希望你终止。至于目标线程收到通知后会如何处理，则完全由目标线程自行决定。

~~~java
public boolean Thread.isInterrupted() //判断是否被中断
public static boolean Thread.interrupted() //判断是否被中断，并清除当前中断状态
~~~

这两个方法使得当前线程能够感知到是否被中断了（通过检查标志位）。否则当前线程是不会管这个标志位的，也就不会被中断了。

~~~java
@Override
public void run() {
    super.run();
    for(int i = 0; i <= 200000; i++) {
        //判断是否被中断
        if(Thread.currentThread().isInterrupted()){
            //处理中断逻辑
            break;
        }
        System.out.println("i=" + i);
    }
}
~~~

Thread.sleep() 方法会抛出一个 InterruptedException 异常，当线程被 sleep() 休眠时，如果被中断，这会就抛出这个异常。
（注意：Thread.sleep() 方法由于中断而抛出的异常，是会清除中断标记的。）

> wait, notify, notifyAlls

wait()方法使当前线程进行等待，并阻塞在当前代码处直到接到通知或者被中断为止。在调用wait()方法之前，线程必须获得调用wait()方法的对象的对象级别锁，即只能在同步块或者同步方法中调用wait()方法。如果调用wait时没有获得该对象的锁，则抛出IllegalMonitorStateException。执行wait()后，当前线程释放锁。接到通知后，在wait()返回前，线程需要与其他线程竞争重新获得锁。

wait(long)方法与wait()类似，但超过设定时间自动唤醒。

当线程wait状态时，调用线程对象的interrupt()方法出现InterruptedException异常。

notify()也要在同步方法中，即调用时当前线程必须获得调用对象的对象级别锁。没有持有锁抛出IllegalMonitorStateException。该方法用来通知那些可能等待该对象的对象锁的其他线程。如果有多个线程等待，线程规划器随机挑选一个呈wait状态的线程，对其发出notify。执行notify()后，当前线程不会立刻释放该对象锁，要等到退出synchronized代码块后才会释放锁。当第一个获得该对象锁的wait线程运行完毕，他会是否掉该对象锁，此时如果该对象没有再次使用notify语句，则即便该对象已经空闲，其他wait状态的线程依旧阻塞知道该对象发出notify或者notifyAll。

若notify时，没有wait的线程，该notify将被忽略。

notifyAll()与notify()类似，只是唤醒所有wait的线程。

因线程调度的随机性，若先线程A先调用notify()之后线程B才进入wait()状态，将会导致线程B永久wait。

> wait与sleep的区别

- wait需要在同步块中调用， 释放锁。sleep不需要再同步块中调用，不释放锁。
- wait需要notify唤醒，而sleep可以自动醒来。
- sleep是静态方法，wait是对象方法.

> join



#### 线程中断

#### ThreadLocal与ThreadLocalMap

> ThreadLocal的作用

ThreadLocal类提供了线程局部 (thread-local) 变量。每个线程都可以通过其 get 或 set方法来访问自己的独立初始化的变量副本。ThreadLocal中的变量是线程隔离的。

```java
public class ThreadId {
    // Atomic integer containing the next thread ID to be assigned
    private static final AtomicInteger nextId = new AtomicInteger(0);

    // Thread local variable containing each thread's ID
    private static final ThreadLocal<Integer> threadId =
            new ThreadLocal<Integer>() {
                @Override protected Integer initialValue() {
                    return nextId.getAndIncrement();
                }
            };

    // Returns the current thread's unique ID, assigning it if necessary
    public static int get() {
        return threadId.get();
    }

    public static void main(String[] args) {
        for (int i = 0; i < 5; i++) {
            new Thread(new Runnable() {
                public void run() {
                    System.out.print(threadId.get());
                }
            }).start();
        }
    }
    // 输出结果01234
```

> ThreadLocal

ThreadLocal中重要的方法有：

- remove()清除ThreadLocal中保存的变量
- get() 设置ThreadLocal中保存的变量
- set(T)获取ThreadLocal中保存的变量
- initialValue()子类可以覆盖这个方法来对ThreadLocal设置一个初始值， 默认为null。

~~~java
	public void set(T value) {
    	// 获取当前线程的ThreadLocalMap对象
    	Thread t = Thread.currentThread();
	    ThreadLocalMap map = getMap(t);
 	   // 设置值
  	  if (map != null)
  	      map.set(this, value);
  	  else
     	   createMap(t, value);
	}
    public T get() {
        // 获取当前线程的ThreadLocalMap对象
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            // 获取ThreadLocalMap中对应的entry，需要注意的是这里传入的是this，也就是说ThreadLocalMap中的key是ThreadLocal。
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        // 没有对应的值就获取初始值， 初始值可以继承TheadLocal类并覆盖其initialValue()方法来设置
        return setInitialValue();
    }
     public void remove() {
         // 获取当前线程的ThreadLocalMap对象
         ThreadLocalMap m = getMap(Thread.currentThread());
         // 清除ThreadLocalMap中key为当前对象的entry
         if (m != null)
             m.remove(this);
     }
	// 假如当前TheadLocal对象没有通过set()方法设置值就调用get()方法的话，那ThreadLocalMap对象中肯定无法获得对应的entry，那么get()方法中就会调用该方法。
	private T setInitialValue() {
        // 获取初始值，默认的话是null，可以通过子类覆盖这个方法。
        T value = initialValue();
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        // 想ThreadLocalMap中设置这个初始值。
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
        return value;
    }
~~~

综上可以看出，对ThreadLocal对象调用set/get方法，其实就是调用了Thread.currentThread()中的ThreadLocalMap对象。

> ThreadLocalMap

ThreadLocalMap是一个类似于HashMap的结构，但是他是自己实现的Map功能，与集合中的Map并没有什么继承关系。

关键的是，**每一个Thread对象中维护着一个ThreadLocalMap对象，当调用的ThreadLocal进行set/get时，操作的ThreadLocalMap是当前线程Thread.currentThread()的，所以保存在ThreadLocal中的对象是线程隔离的。**

![image-20201105194031217](img/image-20201105194031217.png)

ThreadLocalMap成员变量如下：

```java
    //初始容量 —— 必须是2的幂
    private static final int INITIAL_CAPACITY = 16;
    //存放数据的table，Entry类的定义在下面分析，同样，数组长度必须是2的幂
    private Entry[] table;
    // 数组里面entrys的个数，可以用于判断table当前使用量是否超过负因子。
    private int size = 0;
    // 进行扩容的阈值，表使用量大于它的时候进行扩容。
    private int threshold;
    // 长度的2/3
    private void setThreshold(int len) {
        threshold = len * 2 / 3;
    }
```

存储结构Entry：

```java
/**
 * Entry继承WeakReference，并且用ThreadLocal作为key.如果key为null
 * (entry.get() == null)表示key不再被引用，表示ThreadLocal对象被回收
 * 因此这时候这个entry也可以从table从清除。
 */
static class Entry extends WeakReference<ThreadLocal<?>> {
    /** The value associated with this ThreadLocal. */
    Object value;

    Entry(ThreadLocal<?> k, Object v) {
        super(k);
        value = v;
    }
}
```

**ThreadLocalMap中的key是ThreadLocal对象，这样当调用ThreadLocal的set/get方法时，传入this便可以获取对应保存的value。**

> ThreadLocal和ThreadLocalMap中的set

先看看ThreadLocal中set()源码。

```java
    public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocal.ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
    }
    
    ThreadLocal.ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;
    }

    void createMap(Thread t, T firstValue) {
        t.threadLocals = new ThreadLocal.ThreadLocalMap(this, firstValue);
    }
```

- 代码很简单，获取当前线程，并获取当前线程的ThreadLocalMap实例（从getMap(Thread t)中很容易看出来）。
- 如果获取到的map实例不为空，调用map.set()方法，否则调用构造函数 ThreadLocal.ThreadLocalMap(this, firstValue)实例化map。

可以看出来线程中的ThreadLocalMap使用的是延迟初始化，在第一次调用get()或者set()方法的时候才会进行初始化。下面来看看构造函数`ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue)` 。

```java
    ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
        //初始化table
        table = new ThreadLocal.ThreadLocalMap.Entry[INITIAL_CAPACITY];
        //计算索引
        int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
        //设置值
        table[i] = new ThreadLocal.ThreadLocalMap.Entry(firstKey, firstValue);
        size = 1;
        //设置阈值
        setThreshold(INITIAL_CAPACITY);
    }
```

主要说一下计算索引，`firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1)`。

- 关于`& (INITIAL_CAPACITY - 1)`, 这是快速取模法，相当于 `%INITIAL_CAPACITY` ，前提是`INITIAL_CAPACITY` 必须是2的幂。这也就是为啥容量必须为2的幂。
- 关于`firstKey.threadLocalHashCode`：

```java
    private final int threadLocalHashCode = nextHashCode();
    private static int nextHashCode() {
        return nextHashCode.getAndAdd(HASH_INCREMENT);
    }
    private static AtomicInteger nextHashCode =
            new AtomicInteger();     
    private static final int HASH_INCREMENT = 0x61c88647;
```

定义了一个AtomicInteger类型，每次获取当前值并加上HASH_INCREMENT，`HASH_INCREMENT = 0x61c88647`,关于这个值和`斐波那契散列`有关，其原理这里不再深究，感兴趣可自行搜索，其**主要目的就是为了让哈希码能均匀的分布在2的n次方的数组里, 也就是`Entry[] table`中。**

在了解了上面的源码后，终于能进入正题了，下面开始进入ThreadLocalMap中的set()。

ThreadLocalMap使用`线性探测法`来解决哈希冲突，线性探测法的地址增量di = 1, 2, ... , m-1，其中，i为探测次数。该方法一次探测下一个地址，直到有空的地址后插入，若整个空间都找不到空余的地址，则产生溢出。假设当前table长度为16，也就是说如果计算出来key的hash值为14，如果table[14]上已经有值，并且其key与当前key不一致，那么就发生了hash冲突，这个时候将14加1得到15，取table[15]进行判断，这个时候如果还是冲突会回到0，取table[0],以此类推，直到可以插入。

按照上面的描述，`可以把table看成一个环形数组`。

先看一下线性探测相关的代码，从中也可以看出来table实际是一个环：

```java
    // 获取环形数组的下一个索引
    private static int nextIndex(int i, int len) {
        return ((i + 1 < len) ? i + 1 : 0);
    }
    // 获取环形数组的上一个索引
    private static int prevIndex(int i, int len) {
        return ((i - 1 >= 0) ? i - 1 : len - 1);
    }
```

ThreadLocalMap的set()及其set()相关代码如下：

```java
    private void set(ThreadLocal<?> key, Object value) {
        ThreadLocal.ThreadLocalMap.Entry[] tab = table;
        int len = tab.length;
        //计算索引，上面已经有说过。
        int i = key.threadLocalHashCode & (len-1);

        /**
         * 根据获取到的索引进行循环，如果当前索引上的table[i]不为空，在没有return的情况下，
         * 就使用nextIndex()获取下一个（上面提到到线性探测法）。
         */
        for (ThreadLocal.ThreadLocalMap.Entry e = tab[i];
             e != null;
             e = tab[i = nextIndex(i, len)]) {
            ThreadLocal<?> k = e.get();
            //table[i]上key不为空，并且和当前key相同，更新value
            if (k == key) {
                e.value = value;
                return;
            }
            /**
             * table[i]上的key为空，说明被回收了（上面的弱引用中提到过）。
             * 这个时候说明改table[i]可以重新使用，用新的key-value将其替换,并删除其他无效的entry
             */
            if (k == null) {
                replaceStaleEntry(key, value, i);
                return;
            }
        }

        //找到为空的插入位置，插入值，在为空的位置插入需要对size进行加1操作
        tab[i] = new ThreadLocal.ThreadLocalMap.Entry(key, value);
        int sz = ++size;

        /**
         * cleanSomeSlots用于清除那些e.get()==null，也就是table[index] != null && table[index].get()==null
         * 之前提到过，这种数据key关联的对象已经被回收，所以这个Entry(table[index])可以被置null。
         * 如果没有清除任何entry,并且当前使用量达到了负载因子所定义(长度的2/3)，那么进行rehash()
         */
        if (!cleanSomeSlots(i, sz) && sz >= threshold)
            rehash();
    }


    /**
     * 替换无效entry
     */
    private void replaceStaleEntry(ThreadLocal<?> key, Object value,
                                   int staleSlot) {
        ThreadLocal.ThreadLocalMap.Entry[] tab = table;
        int len = tab.length;
        ThreadLocal.ThreadLocalMap.Entry e;

        /**
         * 根据传入的无效entry的位置（staleSlot）,向前扫描
         * 一段连续的entry(这里的连续是指一段相邻的entry并且table[i] != null),
         * 直到找到一个无效entry，或者扫描完也没找到
         */
        int slotToExpunge = staleSlot;//之后用于清理的起点
        for (int i = prevIndex(staleSlot, len);
             (e = tab[i]) != null;
             i = prevIndex(i, len))
            if (e.get() == null)
                slotToExpunge = i;

        /**
         * 向后扫描一段连续的entry
         */
        for (int i = nextIndex(staleSlot, len);
             (e = tab[i]) != null;
             i = nextIndex(i, len)) {
            ThreadLocal<?> k = e.get();

            /**
             * 如果找到了key，将其与传入的无效entry替换，也就是与table[staleSlot]进行替换
             */
            if (k == key) {
                e.value = value;

                tab[i] = tab[staleSlot];
                tab[staleSlot] = e;

                //如果向前查找没有找到无效entry，则更新slotToExpunge为当前值i
                if (slotToExpunge == staleSlot)
                    slotToExpunge = i;
                cleanSomeSlots(expungeStaleEntry(slotToExpunge), len);
                return;
            }

            /**
             * 如果向前查找没有找到无效entry，并且当前向后扫描的entry无效，则更新slotToExpunge为当前值i
             */
            if (k == null && slotToExpunge == staleSlot)
                slotToExpunge = i;
        }

        /**
         * 如果没有找到key,也就是说key之前不存在table中
         * 就直接最开始的无效entry——tab[staleSlot]上直接新增即可
         */
        tab[staleSlot].value = null;
        tab[staleSlot] = new ThreadLocal.ThreadLocalMap.Entry(key, value);

        /**
         * slotToExpunge != staleSlot,说明存在其他的无效entry需要进行清理。
         */
        if (slotToExpunge != staleSlot)
            cleanSomeSlots(expungeStaleEntry(slotToExpunge), len);
    }

    /**
     * 连续段清除
     * 根据传入的staleSlot,清理对应的无效entry——table[staleSlot],
     * 并且根据当前传入的staleSlot,向后扫描一段连续的entry(这里的连续是指一段相邻的entry并且table[i] != null),
     * 对可能存在hash冲突的entry进行rehash，并且清理遇到的无效entry.
     *
     * @param staleSlot key为null,需要无效entry所在的table中的索引
     * @return 返回下一个为空的solt的索引。
     */
    private int expungeStaleEntry(int staleSlot) {
        ThreadLocal.ThreadLocalMap.Entry[] tab = table;
        int len = tab.length;

        // 清理无效entry，置空
        tab[staleSlot].value = null;
        tab[staleSlot] = null;
        //size减1，置空后table的被使用量减1
        size--;

        ThreadLocal.ThreadLocalMap.Entry e;
        int i;
        /**
         * 从staleSlot开始向后扫描一段连续的entry
         */
        for (i = nextIndex(staleSlot, len);
             (e = tab[i]) != null;
             i = nextIndex(i, len)) {
            ThreadLocal<?> k = e.get();
            //如果遇到key为null,表示无效entry，进行清理.
            if (k == null) {
                e.value = null;
                tab[i] = null;
                size--;
            } else {
                //如果key不为null,计算索引
                int h = k.threadLocalHashCode & (len - 1);
                /**
                 * 计算出来的索引——h，与其现在所在位置的索引——i不一致，置空当前的table[i]
                 * 从h开始向后线性探测到第一个空的slot，把当前的entry挪过去。
                 */
                if (h != i) {
                    tab[i] = null;
                    while (tab[h] != null)
                        h = nextIndex(h, len);
                    tab[h] = e;
                }
            }
        }
        //下一个为空的solt的索引。
        return i;
    }

    /**
     * 启发式的扫描清除，扫描次数由传入的参数n决定
     * @param i 从i向后开始扫描（不包括i，因为索引为i的Slot肯定为null）
     * @param n 控制扫描次数，正常情况下为 log2(n) ，
     * 如果找到了无效entry，会将n重置为table的长度len,进行段清除。
     * map.set()点用的时候传入的是元素个数，replaceStaleEntry()调用的时候传入的是table的长度len
     *
     * @return true if any stale entries have been removed.
     */
    private boolean cleanSomeSlots(int i, int n) {
        boolean removed = false;
        ThreadLocal.ThreadLocalMap.Entry[] tab = table;
        int len = tab.length;
        do {
            i = nextIndex(i, len);
            ThreadLocal.ThreadLocalMap.Entry e = tab[i];
            if (e != null && e.get() == null) {
                //重置n为len
                n = len;
                removed = true;
                //依然调用expungeStaleEntry来进行无效entry的清除
                i = expungeStaleEntry(i);
            }
        } while ( (n >>>= 1) != 0);//无符号的右移动，可以用于控制扫描次数在log2(n)
        return removed;
    }
    private void rehash() {
        //全清理
        expungeStaleEntries();

        /**
         * threshold = 2/3 * len
         * 所以threshold - threshold / 4 = 1en/2
         * 这里主要是因为上面做了一次全清理所以size减小，需要进行判断。
         * 判断的时候把阈值调低了。
         */
        if (size >= threshold - threshold / 4)
            resize();
    }
    /**
     * 扩容，扩大为原来的2倍（这样保证了长度为2的冥）
     */
    private void resize() {
        ThreadLocal.ThreadLocalMap.Entry[] oldTab = table;
        int oldLen = oldTab.length;
        int newLen = oldLen * 2;
        ThreadLocal.ThreadLocalMap.Entry[] newTab = new ThreadLocal.ThreadLocalMap.Entry[newLen];
        int count = 0;

        for (int j = 0; j < oldLen; ++j) {
            ThreadLocal.ThreadLocalMap.Entry e = oldTab[j];
            if (e != null) {
                ThreadLocal<?> k = e.get();
                //虽然做过一次清理，但在扩容的时候可能会又存在key==null的情况。
                if (k == null) {
                    //这里试试将e.value设置为null
                    e.value = null; // Help the GC
                } else {
                    //同样适用线性探测来设置值。
                    int h = k.threadLocalHashCode & (newLen - 1);
                    while (newTab[h] != null)
                        h = nextIndex(h, newLen);
                    newTab[h] = e;
                    count++;
                }
            }
        }
        //设置新的阈值
        setThreshold(newLen);
        size = count;
        table = newTab;
    }

    /**
     * 全清理，清理所有无效entry
     */
    private void expungeStaleEntries() {
        ThreadLocal.ThreadLocalMap.Entry[] tab = table;
        int len = tab.length;
        for (int j = 0; j < len; j++) {
            ThreadLocal.ThreadLocalMap.Entry e = tab[j];
            if (e != null && e.get() == null)
                //使用连续段清理
                expungeStaleEntry(j);
        }
    }
```

> ThreadLocal和ThreadLocalMap中的get

ThreadLocalMap中的getEntry()及其相关

同样的对于ThreadLocalMap中的getEntry()也从ThreadLocal的get()方法入手。

ThreadLocal中的get()

```java
public T get() {
    //同set方法类似获取对应线程中的ThreadLocalMap实例
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null) {
        ThreadLocalMap.Entry e = map.getEntry(this);
        if (e != null) {
            @SuppressWarnings("unchecked")
            T result = (T)e.value;
            return result;
        }
    }
    //为空返回初始化值
    return setInitialValue();
}
/**
 * 初始化设值的方法，可以被子类覆盖。
 */
protected T initialValue() {
   return null;
}

private T setInitialValue() {
    //获取初始化值，默认为null(如果没有子类进行覆盖)
    T value = initialValue();
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    //不为空不用再初始化，直接调用set操作设值
    if (map != null)
        map.set(this, value);
    else
        //第一次初始化，createMap在上面介绍set()的时候有介绍过。
        createMap(t, value);
    return value;
}
```

ThreadLocalMap中的getEntry()

```java
    private ThreadLocal.ThreadLocalMap.Entry getEntry(ThreadLocal<?> key) {
        //根据key计算索引，获取entry
        int i = key.threadLocalHashCode & (table.length - 1);
        ThreadLocal.ThreadLocalMap.Entry e = table[i];
        if (e != null && e.get() == key)
            return e;
        else
            return getEntryAfterMiss(key, i, e);
    }

    /**
     * 通过直接计算出来的key找不到对于的value的时候适用这个方法.
     */
    private ThreadLocal.ThreadLocalMap.Entry getEntryAfterMiss(ThreadLocal<?> key, int i, ThreadLocal.ThreadLocalMap.Entry e) {
        ThreadLocal.ThreadLocalMap.Entry[] tab = table;
        int len = tab.length;

        while (e != null) {
            ThreadLocal<?> k = e.get();
            if (k == key)
                return e;
            if (k == null)
                //清除无效的entry
                expungeStaleEntry(i);
            else
                //基于线性探测法向后扫描
                i = nextIndex(i, len);
            e = tab[i];
        }
        return null;
    }
```

ThreadLocalMap中的remove()

```java
    private void remove(ThreadLocal<?> key) {
        ThreadLocal.ThreadLocalMap.Entry[] tab = table;
        int len = tab.length;
        //计算索引
        int i = key.threadLocalHashCode & (len-1);
        //进行线性探测，查找正确的key
        for (ThreadLocal.ThreadLocalMap.Entry e = tab[i];
             e != null;
             e = tab[i = nextIndex(i, len)]) {
            if (e.get() == key) {
                //调用weakrefrence的clear()清除引用
                e.clear();
                //连续段清除
                expungeStaleEntry(i);
                return;
            }
        }
    }
```

remove()在有上面了解后可以说极为简单了，就是找到对应的table[],调用weakrefrence的clear()清除引用，然后再调用expungeStaleEntry()进行清除。

> Entry使用弱引用的原因与内存泄漏

~~~java
public void test(){
    ThreadLocal tl = new ThreadLocal();
    tl.set("hello");
}
~~~

上面调用test后，会往当前线程的threadLocalMap中添加一个“hello”。但是**当test方法结束后，tl对象的引用被销毁，那么也就无法通过tl来获取threadLocalMap中的“hello”这个字符串了。tl对应的entry会一致保存在entry[]数组中，这就造成了内存泄漏。**

但是因为Entry是继承WeakReference的，这就导致当tl对象的引用被销毁的时候，因为threadLocalMap中的Entry[]数组只是持有tl的弱引用，当堆内存不够时，会gc回收tl对象，这样对应的entry调用的get方法返回的是null，从而可以判断该tl对象已经被回收了。（gc只是对entry的key进行回收，即tl对象，而不是对entry对象回收，因为entry类是将key保存在弱引用中）使用弱引用的话可以将entry中过期的key通过gc进行回收，但是entry和entry中的value是不会回收的。**也就是说即使使用了弱引用也不能防止内存泄漏，但是可以通过entry的key是不是null来判断这个entry是不是过期的，从而手动释放掉他。**

事实上，在ThreadLocalMap的set/get中也会通过e.get()==null来判断当前entry是否过期，从而手动释放掉这个entry。

![img](img/企业微信截图_16045025138073.png)![img](img/企业微信截图_16045025774716.png)

![image-20201105205929710](img/image-20201105205929710.png)

![img](img/企业微信截图_16045033491830.png)

> 使用中注意的点

- 使用完ThreadLocal调用remove方法清除ThreadLocalMap中的值。

- ThreadLocal对象推荐使用static，因为static对象虽然是类所有的，但是因为是通过ThreadLocal获取的不同Thread中的ThreadLocalMap的value，所以ThreadLocal是线程隔离的。





#### 内存可见性与volatile

公共堆栈和线程私有堆栈





#### 原子类



#### ReentrantLock

> Condition

> 公平锁, 先进先出





#### Lock类

```
ReentrantReadWriteLock.ReadLock
ReentrantReadWriteLock.WriteLock
```







#### java 加密算法

加密算法大体上分为大体上分为**双向加密**和**单向加密(摘要加密)**，而双向加密又分为**对称加密**和**非对称加密**(有些资料将加密直接分为对称加密和非对称加密)。

 双向加密大体意思就是明文加密后形成密文，可以通过算法还原成明文。而单向加密只是对信息进行了摘要计算，不能通过算法生成明文，单向加密从严格意思上说不能算是加密的一种，应该算是摘要算法吧。

> 常用对称加密算法

**DES**、**RC2**、**RC4**、**SKIPJACK**、**RC5**、**AES**

> 常用非对称加密算法

**RSA** 、**DSA** 

> 常用单向加密算法

 **MD5**、**SHA**、**HMAC**







# mysql中的内置函数

mysql内置函数列表可以从mysql官方文档查询，这里仅分类简单介绍一些可能会用到的函数。

https://dev.mysql.com/doc/refman/5.6/en/sql-function-reference.html

https://www.cnblogs.com/noway-neway/p/5211401.html

https://www.w3cschool.cn/mysql/func-date-add.html

#### 1 数学函数

abs(x)
pi()
mod(x,y)
sqrt(x)
ceil(x)或者ceiling(x)
rand(),rand(N):返回0-1间的浮点数，使用不同的seed N可以获得不同的随机数
round(x, D)：四舍五入保留D位小数，D默认为0， 可以为负数， 如round(19, -1)返回20
truncate(x, D):截断至保留D位小数，D可以为负数， 如trancate(19,-1)返回10
sign(x): 返回x的符号，正负零分别返回1， -1， 0
pow(x,y)或者power(x,y)
exp(x)：e^x
log(x)：自然对数
log10(x)：以10为底的对数
radians(x):角度换弧度
degrees(x):弧度换角度
sin(x)和asin(x):
cos(x)和acos(x):
tan(x)和atan(x):
cot(x):

#### 2 字符串函数

char_length(str):返回str所包含的字符数，一个多字节字符算一个字符
length(str): 返回字符串的字节长度，如utf8中，一个汉字3字节，数字和字母算一个字节
concat(s1, s1, ...): 返回连接参数产生的字符串
concat_ws(x, s1, s2, ...): 使用连接符x连接其他参数产生的字符串
INSERT(str,pos,len,newstr):返回str,其起始于pos，长度为len的子串被newstr取代。
\1. 若pos不在str范围内，则返回原字符串str
\2. 若str中从pos开始的子串不足len,则将从pos开始的剩余字符用newstr取代
\3. 计算pos时从1开始，若pos=3,则从第3个字符开始替换
lower（str)或者lcase(str):
upper(str)或者ucase(str):
left(s,n):返回字符串s最左边n个字符
right(s,n): 返回字符串最右边n个字符
lpad(s1, len, s2): 用s2在s1左边填充至长度为len, 若s1的长度大于len,则截断字符串s1至长度len返回
rpad(s1, len, s2):
ltrim(s):删除s左侧空格字符
rtrim(s):
TRIM([{BOTH | LEADING | TRAILING} [remstr] FROM] str)或TRIM([remstr FROM] str)：从str中删除remstr, remstr默认为空白字符
REPEAT(str,count)：返回str重复count次得到的新字符串
REPLACE(str,from_str,to_str)： 将str中的from_str全部替换成to_str
SPACE(N):返回长度为N的空白字符串
STRCMP(str1,str2):若str1和str2相同，返回0， 若str1小于str2, 返回-1， 否则返回1.
SUBSTRING(str,pos), SUBSTRING(str FROM pos), SUBSTRING(str,pos,len), SUBSTRING(str FROM pos FOR len),MID(str,pos,len): 获取特定位置，特定长度的子字符串
LOCATE(substr,str), LOCATE(substr,str,pos),INSTR(str,substr),POSITION(substr IN str): 返回字符串中特定子串的位置，注意这里INSTR与其他函数的参数位置是相反的
REVERSE(str)
ELT(N,str1,str2,str3,...)：返回参数strN, 若N大于str参数个数，则返回NULL
FIELD(str,str1,str2,str3,...): 返回str在后面的str列表中第一次出现的位置，若找不到str或者str为NULL, 则返回0
FIND_IN_SET(str,strlist)：strlist是由','分隔的字符串，若str不在strlist或者strlist为空字符串，则返回0；若任意一个参数为NULL则返回ＮＵＬＬ
MAKE_SET(bits,str1,str2,...): 由bits的作为位图来选取strN参数，选中的参数用','连接后返回

#### 3 日期和时间函数

**CURDATE(), CURRENT_DATE, CURRENT_DATE():用于获取当前日期，格式为'YYYY-MM-DD'; 若+0则返回YYYYMMDD**
UTC_DATE, UTC_DATE():返回当前世界标准时间
CURTIME([fsp]), CURRENT_TIME, CURRENT_TIME([fsp]): 用于获取当前时间， 格式为'HH:MM:SS' 若+0则返回 HHMMSS
UTC_TIME, UTC_TIME([fsp])
CURRENT_TIMESTAMP, CURRENT_TIMESTAMP([fsp]), LOCALTIME, LOCALTIME([fsp]), SYSDATE([fsp]), NOW([fsp]): 用于获取当前的时间日期，格式为'YYYY-MM-DD HH:MM:SS'，若+0则返回YYYYMMDDHHMMSS
UTC_TIMESTAMP, UTC_TIMESTAMP([fsp])
UNIX_TIMESTAMP(), UNIX_TIMESTAMP(date)：返回一个unix时间戳（'1970-01-01 00:00:00' UTC至今或者date的秒数），这实际上是从字符串到整数的一个转化过程
FROM_UNIXTIME(unix_timestamp), FROM_UNIXTIME(unix_timestamp,format)：从时间戳返回'YYYY-MM-DD HH:MM:SS' 或者YYYYMMDDHHMMSS，加入format后根据所需的format显示。
**MONTH(date)**
MONTHNAME(date)
DAYNAME(date)
DAY(date)，DAYOFMONTH(date)：1-31或者0
**DAYOFWEEK(date)：1-7==>星期天-星期六**
**DAYOFYEAR(date)： 1-365（366）**
WEEK(date[,mode])：判断是一年的第几周，如果1-1所在周在新的一年多于4天，则将其定为第一周；否则将其定为上一年的最后一周。mode是用来人为定义一周从星期几开始。
WEEKOFYEAR(date)：类似week(date,3)，从周一开始计算一周。
QUARTER(date)：返回1-4
**HOUR(time)：返回时间中的小时数，可以大于24**
**MINUTE(time)：**
**SECOND(time)：**
EXTRACT(unit FROM date)：提取日期时间中的要素

```sql
    SELECT EXTRACT(YEAR FROM '2009-07-02'); ##2009
    SELECT EXTRACT(YEAR_MONTH FROM '2009-07-02 01:02:03');##200907
    SELECT EXTRACT(DAY_MINUTE FROM '2009-07-02 01:02:03');##20102
    SELECT EXTRACT(MICROSECOND FROM '2003-01-02 10:30:00.000123');##123
```

TIME_TO_SEC(time)
SEC_TO_TIME(seconds)

TO_DAYS(date): 从第0年开始的天数
TO_SECNDS(expr)：从第0年开始的秒数

ADDDATE(date,INTERVAL expr unit), ADDDATE(expr,days),DATE_ADD(date,INTERVAL expr unit)
DATE_SUB(date,INTERVAL expr unit), DATE_SUB(date,INTERVAL expr unit)
ADDTIME(expr1,expr2)
SUBTIME(expr1,expr2)

```sql
    SELECT ADDTIME('2007-12-31 23:59:59.999999', '1 1:1:1.000002');##'2008-01-02 01:01:01.000001'
    SELECT ADDTIME('01:00:00.999999', '02:00:00.999998');##'03:00:01.999997'
```

注意：时间日期的加减也可以直接用+/-来进行

```sql
    date + INTERVAL expr unit
    date - INTERVAL expr unit
    如：
    SELECT '2008-12-31 23:59:59' + INTERVAL 1 SECOND;##'2009-01-01 00:00:00'
    SELECT INTERVAL 1 DAY + '2008-12-31';##'2009-01-01'
    SELECT '2005-01-01' - INTERVAL 1 SECOND;##'2004-12-31 23:59:59'
```

DATE_FORMAT(date,format):
DATEDIFF(expr1,expr2):返回相差的天数
TIMEDIFF(expr1,expr2)：返回相隔的时间

#### 4 条件判断函数

IF(expr1,expr2,expr3)：如果expr1不为0或者NULL,则返回expr2的值，否则返回expr3的值
IFNULL(expr1,expr2)：如果expr1不为NULL,返回expr1,否则返回expr2
NULLIF(expr1,expr2): 如果expr1=expr2则返回NULL, 否则返回expr2
CASE value WHEN [compare_value] THEN result [WHEN [compare_value] THEN result ...] [ELSE result] END
当compare_value=value时返回result
CASE WHEN [condition] THEN result [WHEN [condition] THEN result ...] [ELSE result] END
当condition为TRUE时返回result

```sql
    SELECT CASE 1 WHEN 1 THEN 'one'
        WHEN 2 THEN 'two' ELSE 'more' END;##'one'
    SELECT CASE WHEN 1>0 THEN 'true' ELSE 'false' END;##'true'
    SELECT CASE BINARY 'B'
        WHEN 'a' THEN 1 WHEN 'b' THEN 2 END;##NULL
```

#### 5 系统信息函数

VERSION():返回mysql服务器的版本，是utf8编码的字符串
CONNECTION_ID()：显示连接号（连接的线程号）
DATABASE()，SCHEMA()：显示当前使用的数据库
SESSION_USER(), SYSTEM_USER(), USER(), CURRENT_USER, CURRENT_USER():返回当前的用户名@主机，utf8编码字符串
CHARSET(str)
COLLATION(str)
LAST_INSERT_ID()：自动返回最后一个insert或者update查询， 为auto_increment列设置的第一个发生的值

#### 6 加密和压缩函数

PASSWORD(str):这个函数的输出与变量old_password有关。old_password 在mysql5.6中默认为0。 不同取值的效果如下表
![img](https://images2015.cnblogs.com/blog/865265/201602/865265-20160224150201724-1500361171.png)
old_password=1时， password(str)的效果与old_password(str)相同，由于其不够安全已经弃用（5.6.5以后）。
old_password=2时，在生成哈希密码时会随机加盐。

MD5(str):计算MD5 128位校验和，返回32位16进制数构成的字符串，当str为NULL时返回NULL。可以用作哈希密码
SHA1(str), SHA(str)：计算160位校验和，返回40位16进制数构成的字符串，当str为NULL时返回NULL。
SHA2(str, hash_length)：计算SHA-2系列的哈希方法(SHA-224, SHA-256, SHA-384, and SHA-512). 第一个参数为待校验字符串，第二个参数为结果的位数（224， 256， 384， 512）
ENCRYPT(str[,salt]): 用unix crypt()来加密str. salt至少要有两位字符，否则会返回NULL。若未指定salt参数，则会随机添加salt。

ECODE(crypt_str,pass_str):解密crypt_str, pass_str用作密码
ENCODE(str,pass_str)：用pass_str作为密码加密str

DES_ENCRYPT(str[,{key_num|key_str}])：用Triple-DES算法编码str， 这个函数只有在mysql配置成支持ssl时才可用。
DES_DECRYPT(crypt_str[,key_str])

AES_ENCRYPT(str,key_str[,init_vector])
AES_DECRYPT(crypt_str,key_str[,init_vector])

COMPRESS(string_to_compress)：返回二进制码
UNCOMPRESS(string_to_uncompress)

#### 7 聚合函数

若在没使用group by时使用聚合函数，相当于把所有的行都归于一组来进行处理。除非特殊说明，一般聚合函数会忽略掉NULL.
AVG([DISTINCT] expr): 返回expr的平均值，distinct选项用于忽略重复值
COUNT([DISTINCT] expr)：返回select中expr的非0值个数，返回值为bigint类型
group_concat:连接组内的非空值，若无非空值，则返回NULL

```sql
        GROUP_CONCAT([DISTINCT] expr [,expr ...]
             [ORDER BY {unsigned_integer | col_name | expr}
                    [ASC | DESC] [,col_name ...]]
            [SEPARATOR str_val])
```

MAX([DISTINCT] expr)
MIN([DISTINCT] expr)

SUM([DISTINCT] expr)
VAR_POP(expr)
VARIANCE(expr)：同VAR_POP(expr)，但是这是标准sql的一个扩展函数
VAR_SAMP(expr)
STD(expr): 这是标准sql的一个扩展函数
STDDEV(expr)：这个函数是为了跟oracle兼容而设置的
STDDEV_POP(expr)：这个是sql标准函数

STDDEV_SAMP(expr)：样本标准差

#### 8 格式或类型转化函数

FORMAT(X,D[,locale])：将数字X转化成'#,###,###.##'格式，D为保留的小数位数
CONV(N,from_base,to_base)：改变数字N的进制，返回值为该进制下的数字构成的字符串
INET_ATON(expr)：ip字符串转数字
INET_NTOA(expr)：数字转ip字符串
CAST(expr AS type)：转换数据类型
CONVERT(expr,type), CONVERT(expr USING transcoding_name)： type可以为BINARY[(N)]，CHAR[(N)]，DATE，DATETIME， DECIMAL[(M[,D])]，DECIMAL[(M[,D])]，TIME，UNSIGNED [INTEGER]等等。transcoding_name如utf8等等

#### MySQL DATA_FORMAT函数

https://dev.mysql.com/doc/refman/5.6/en/date-and-time-functions.html#function_date-format

https://www.w3school.com.cn/sql/func_date_format.asp

| %a   | 缩写星期名                                     |
| ---- | ---------------------------------------------- |
| %b   | 缩写月名                                       |
| %c   | 月，数值                                       |
| %D   | 带有英文前缀的月中的天                         |
| %d   | 月的天，数值(00-31)                            |
| %e   | 月的天，数值(0-31)                             |
| %f   | 微秒                                           |
| %H   | 小时 (00-23)                                   |
| %h   | 小时 (01-12)                                   |
| %I   | 小时 (01-12)                                   |
| %i   | 分钟，数值(00-59)                              |
| %j   | 年的天 (001-366)                               |
| %k   | 小时 (0-23)                                    |
| %l   | 小时 (1-12)                                    |
| %M   | 月名                                           |
| %m   | 月，数值(00-12)                                |
| %p   | AM 或 PM                                       |
| %r   | 时间，12-小时（hh:mm:ss AM 或 PM）             |
| %S   | 秒(00-59)                                      |
| %s   | 秒(00-59)                                      |
| %T   | 时间, 24-小时 (hh:mm:ss)                       |
| %U   | 周 (00-53) 星期日是一周的第一天                |
| %u   | 周 (00-53) 星期一是一周的第一天                |
| %V   | 周 (01-53) 星期日是一周的第一天，与 %X 使用    |
| %v   | 周 (01-53) 星期一是一周的第一天，与 %x 使用    |
| %W   | 星期名                                         |
| %w   | 周的天 （0=星期日, 6=星期六）                  |
| %X   | 年，其中的星期日是周的第一天，4 位，与 %V 使用 |
| %x   | 年，其中的星期一是周的第一天，4 位，与 %v 使用 |
| %Y   | 年，4 位                                       |
| %y   | 年，2 位                                       |

~~~~text
'%Y-%m-%d %T' '%Y-%m-%d %H:%i:%s' XXXX-XX-XX XX:XX:XX 24小时制
'%Y-%m-%d %H' xxxx-xx-xx xx 保留年月日和小时
~~~~

#### mysql 关于时间的类型

> 时间的类型

|   类型    | 字节数 |                  取值                   |        零值         | 获取当前值                          |
| :-------: | :----: | :-------------------------------------: | :-----------------: | ----------------------------------- |
|   YEAR    |   1    |                1901~2155                |        0000         | now()                               |
|   DATE    |   4    |          1000-01-01~9999-12-31          |     0000-00-00      | current_date, now()                 |
|   TIME    |   3    |          -938:59:59~838:59:59           |      00:00:00       | current_time, current_time(), now() |
| DATETIME  |   8    | 1000-01-01 00:00:00~9999-12-31 23:59:59 | 0000-00-00 00:00:00 | now()                               |
| TIMESTAMP |   4    |      19700101080001~20380119111407      |   00000000000000    | current_timestamp                   |

> 关于YEAR

| 输入格式     | 具体例子              | 备注                                                         |
| ------------ | --------------------- | ------------------------------------------------------------ |
| 'YYYY'或YYYY | 1901，'1901'          | 如果超过了范围，就会插入0000。                               |
| ‘YY’或YY     | 01, '01'，‘1’表示2001 | ‘00’\~~‘69’转换为2000\~~2069，‘70’~~‘99’转换为1970~1999。数字同。<br>**'00'和‘0’转换为2000， 而00和0被转换为0000** |



> 关于DATE类型

| 输入格式                           | 具体例子                                                   | 说明                                                         |
| ---------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------ |
| YYMMDD或'YYMMDD'或'YY-MM-DD'       | ‘00-01-01’，'00-1-1',表示2000-01-01， 191101表示2019-11-01 | 其中，YY的取值，00\~~69转换为2000\~~2069，70\~~99转换为1970~~1999。字母同。<br>任何标点都可以用来做间隔符。如’YY/MM/DD‘，’YY@MM@DD‘，’YY.MM.DD‘等分隔形式。 |
| YYYYMMDD或'YYYYMMDD'或'YYYY-MM-DD' | 40080308表示4008-03-08                                     | ’00‘\~~’69‘转换为2000\~~2069，’70‘\~~’99‘转换为1970~~1999。<br>任何标点都可以用来做间隔符。如’YYYY/MM/DD‘，’YYYY@MM@DD‘，’YYYY.MM.DD‘等分隔形式。<br>**数字0表示零值0000-00-00。** |

> 关于TIME类型

| 格式                                      | 具体例子                                     | 说明                                                         |
| ----------------------------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| 'D HH:MM:SS', 'D HH:MM','D HH'            | ‘2 11：30：50’，Time类型会转换为59：30：50。 | D表示天数，取值范围是0~~34。保存时，小时的值等于（D\*24+HH） |
| ‘HH:MM:SS’,'HH:MM','SS'，'HHMMSS', HHMMSS |                                              | 如果输入0或者‘0’，那么TIME类型会转换为null                   |

> DateTime

datetime类型使用8个字节来表示日期和时间。\*\*MySQL中以‘YYYY-MM-DD HH:MM:SS’的形式来显示

1，‘YYYY-MM-DD HH:MM:SS’或‘YYYYMMDDHHMMSS’格式的字符串表示。这种方式可以表达的范围是‘1000-01-01 00:00:00’~~‘9999-12-31 23:59:59’。举个例子，比如我现在输入‘2008-08-08 08:08:08’，dateTime类型转换为2008-08-08 08:08:08，输入‘20080808080808’，同样转换为2008-08-08 08:08:08。

2，MySQL中还支持一些不严格的语法格式，任何的标点都可以用来做间隔符。情况与date类型相同，而且时间部分也可以使用任意的分隔符隔开，这与Time类型不同，Time类型只能用‘:’隔开呢。
举个例子，比如我现在输入‘2008@08@08 08\*08\*08’，数据库中dateTime类型统一转换为2008-08-08 08:08:08。

3，‘YY-MM-DD HH:MM:SS’或‘YYMMDDHHMMSS’格式的字符串表示。其中‘YY’的取值，‘00'\~~‘69’转换为2000\~~2069，‘70’\~~‘99’转换为1970~~1999。与year型和date型相同。举个例子，比如我现在输入‘69-01-01 11:11:11’，数据库中插入2069-01-01 11:11:11；比如我现在输入‘70-01-01 11:11:11’，数据库中插入1970-01-01 11:11:11。

4，当然这种格式化的省略YY的简写也是支持一些不严格的语法格式的，比如用‘@’，‘\*’来做间隔符。

>  timestamp类型

timestamp类型使用4个字节来表示日期和时间。timestamp类型的范围是从1970-01-01 08:00:01~~2038-01-19 11:14:07。

MySQL中也是以‘YYYY-MM-DD HH:MM:SS’的形式显示timestamp类型的值。从其形式可以看出，timestamp类型与dateTime类型显示的格式是一样的。

给timestamp类型的字段复制的表示方法基本与dateTime类型相同。值得注意的是，timestamp类型范围比较小，没有dateTime类型的范围那么大。所以输入值时要保证在timestamp类型的有效范围内。



#### MySQL中的交并差

aname：![image-20210109185635634](img/image-20210109185635634.png)

bname: ![image-20210109185711567](img/image-20210109185711567.png)

> 并集

~~~sql
SELECT oname,odesc FROM object_a
UNION ALL
SELECT oname,odesc FROM object_b
~~~

![image-20210109185948788](img/image-20210109185948788.png)

~~~sql
# union 自带去重
select * from aname union select * from bname
~~~

![image-20210109190049474](img/image-20210109190049474.png)

> 交集

~~~sql
select * from aname join bname on aname.name = bname.bname
~~~

![image-20210109193943868](img/image-20210109193943868.png)

> 差集

~~~sql
select * from aname left join bname on aname.name = bname.bname where bname.bname is null
select * from aname right join bname on aname.name = bname.bname where aname.name is null
~~~

![image-20210109194239678](img/image-20210109194239678.png)

![image-20210109194405827](img/image-20210109194405827.png)



#### mysql case when的用法

可以认为case when是**一个函数，传入一条数据，返回一个值**。所以他可以使用在任何需要值的地方，比如select后面，聚合函数的入参， where字句后面，用于赋值。

case 具有两种格式：简单case函数和case搜索函数。

- **简单case函数**

  ~~~sql
  CASE sex
      WHEN '1' THEN '男'
      WHEN '2' THEN '女'
      ELSE '其他' 
      END
  ~~~

- **case搜索函数**

  ~~~sql
  case when sex = '1' then '男'
       when sex = '2' then '女'
       else '其他'
       end
  ~~~

简单case函数写法简单，比较简洁。case搜索函数功能比较强大。

case函数只返回第一个符合条件的值，剩下的case部分自动被忽略。类似于java的if else。

> case when 使用在select后面



- 统计亚洲和北美洲的人口数量![image-20210130144748378](img/image-20210130144748378.png)

  ~~~sql
  select (case when country in ('中国', '印度', '日本') then '亚洲'
           when country in ('美国', '加拿大', '墨西哥') then '北美洲'
           else '其他'
           end) as `洲`, sum(population) as `人口`
           from table_A
           group by `洲`;
  ~~~

- 统计各个国家不同性别的人

  ![image-20210130151453697](img/image-20210130151453697.png)

  ~~~sql
  select country as `国家`,
         sum(case sex when 1 then population else 0 end) as `男`,
         sum(case sex when 2 then population else 0 end) as `女` 
  from table_a 
  group by country
  ~~~

> case when使用在where后面

- 规定所有学生都有code，并且男生(sex = 1)的code以nan开头，女生的code已nv开头，找出表中的错误数据。

  ![image-20210130162539667](img/image-20210130162539667.png)

  ```SQl
  select * from table_b where 1=1 and 
  	(case when code is null then 1
  		  when sex = 1 and code not like 'nan%' then 1
  	      when sex = 0 and code not like 'nv%' then 1
  	      else 0
  	      end ) = 1
  ```



#### mysql 多表连接删除

https://www.jb51.net/article/107813.htm

假设有张学生表student(id, name, age, class_id),  班级表class(id, class_name)

- 单表的删除 -----------------删除id为3的学生的记录

  ~~~mysql
  delete from student s where s.id = 3;
  ~~~

- 多表连接删除---------------------删除A班级的张三同学的记录

  需要删除记录的表跟在delete后面, 连接条件所用到的表放在from后面

  ~~~mysql
  # 下面使用了两个表进行连接， 但是只需要删除s表中的记录， 使用delete s进行表示
  # 如果使用delete s, c 会将s表和c表中的记录一起删除。
  delete s from student s, class c where s.class_id = c.id and s.name = '张三' and c.class_name = 'A';
  ~~~
  
  使用高级连接进行删除

  ~~~mysql
  delete s from student s join class c on s.class_id = c.id where s.name = '张三' and c.class_name = 'A';
  ~~~




#### 重命名列

~~~~sql
-- 使用change可以改变列名和列类型， first和after用于更新后列的定位
ALTER TABLE aaa CHANGE old_column_name new_column_NAME datatype[first | after column_name ]

-- mysql 8.0以后新增 rename column to
alter table aaa rename column old_column_name to new_column_name;
~~~~





#### Runnable Callable Future Executor Executors ExecutorService

线程池的基本思想还是一种对象池的思想，开辟一块内存空间，里面存放了众多(未死亡)的线程，池中线程执行调度由池管理器来处理。当有线程任务时，从池中取一个，执行完成后线程对象归池，这样可以避免反复创建线程对象所带来的性能开销，节省了系统的资源。

在Java5之前，要实现一个线程池是相当有难度的，现在Java5为我们做好了一切，我们只需要按照提供的API来使用，即可享受线程池带来的极大便利。

Java5的线程池分好多种：具体的可以分为两类，固定尺寸的线程池、可变尺寸连接池。

Executor框架主要包含三个部分：

**任务：**包括Runnable和Callable，其中Runnable表示一个可以异步执行的任务，而Callable表示一个会产生结果的任务。 Runnable和Callable的区别在于Callable可以有返回值并且可以抛出异常而Runnable无法做到这一点。

**任务的执行：**包括Executor框架的核心接口Executor以及其子接口ExecutorService。在Executor框架中有两个关键类ThreadPoolExecutor和ScheduledThreadPoolExecutor实现了ExecutorService接口。

**异步计算的结果：**包括接口Future和其实现类FutureTask。

**Executors**：用于创建各种线程池的工具类。





### java队列

####  Queue

~~~java
public interface Queue<E> extends Collection<E>
~~~

设计用于数据处理之前容纳数据的集合。 除了基本的Collection操作外，队列还提供其他插入，提取和检查操作。 这些方法中的每一种都以两种形式存在：一种在操作失败时引发异常，另一种返回一个特殊值（null/false, 取决于具体操作）。 **插入操作的后一种形式是专门为与容量受限的Queue实现一起使用而设计的**； 在大多数实现中，插入操作不会失败。 

| 操作 | 抛出异常 |   返回特定值   |
| :--: | :------: | :------------: |
| 插入 |   add    | offer（false） |
| 去除 |  remove  |  poll（null）  |
| 检查 | element  |  peek（null）  |

队列通常但不一定以FIFO（先进先出）的方式对元素进行排序。 例外情况包括优先级队列（根据提供的比较器对元素进行排序或元素的自然排序）和LIFO队列（或堆栈），对LIFO进行排序（后进先出）。每个Queue实现必须指定其排序属性。
Queue实现通常不允许插入null元素，尽管某些实现（例如LinkedList不允许插入null 。 即使在允许的实现中，也不应将null插入到Queue ，因为poll方法还将null用作特殊的返回值，以指示该队列不包含任何元素。
Queue实现通常不定义方法equals和hashCode的基于元素的版本，而是从Object类继承基于身份的版本，因为对于具有相同元素但顺序属性不同的队列，基于元素的相等性并不总是很好定义的

#### Deque

双端队列。 大多数Deque实现对它们可能包含的元素数量没有固定的限制，但是此接口支持容量受限的双端队列以及没有固定大小限制的双端队列。

|      |          头 | 部         |         尾 | 部        |
| :--: | ----------: | :--------- | ---------: | :-------- |
|      |    引发异常 | 特殊值     |   引发异常 | 特殊值    |
| 插入 |    addFirst | offerFirst |    addLast | offerLast |
| 去除 | removeFirst | pollFirst  | removeLast | pollLast  |
| 检查 |    getFirst | peekFirst  |    getLast | peekLast  |

 当双端队列用作队列时，将导致FIFO（先进先出）行为。 元素在双端队列的末尾添加，并从开头删除。 继承自Queue接口的方法与Deque方法完全等效，如下表所示：

| Queue方法 |  Deque方法  |
| :-------: | :---------: |
|    add    |   addLast   |
|   offer   |  offerLast  |
|  remove   | removeFirst |
|   poll    |  pollFirst  |
|  element  |  getFirst   |
|   peek    |  peekFirst  |

 当双端队列用作堆栈时，元素从双端队列的开头被压入并弹出。 堆栈方法完全等同于Deque方法，如下表所示：

| 堆栈方法 |  Deque方法  |
| :------: | :---------: |
|   push   |  addFirst   |
|   pop    | removeFirst |
|   peek   |  peekFirst  |


此接口提供了两种删除内部元素的方法： 

|             方法              |              功能              |
| :---------------------------: | :----------------------------: |
| removeFirstOccurrence(Object) | 移除从队首开始首次出现的该元素 |
| removeLastOccurrence(Object)  | 移除从队尾开始首次出现的该元素 |

尽管严格不要求Deque实现禁止插入null元素，但强烈建议这样做。

#### BlockingQueue

~~~~java
BlockingQueue<E> extends Queue<E>
~~~~

当检索和移除元素时支持等待队列由空转为非空， 添加元素时支持等待队列由不可用转为可用。

BlockingQueue方法有四种形式，它们以不同的方式处理操作，这些操作无法立即满足，但将来可能会满足：

- 一种抛出异常

- 第二种返回特殊值（ null或false ，具体取决于操作）

- 第三个块将无限期地阻塞当前线程，直到操作成功为止

- 第四个块仅在给定的最大时间限制内放弃。 

下表总结了这些方法：

|      | 引发异常  | 返回特殊值 |  堵塞  |         超时         |
| :--: | :-------: | :--------: | :----: | :------------------: |
| 插入 |  add(e)   |  offer(e)  | put(e) | offer(e, time, unit) |
| 去除 | remove()  |   poll()   | take() |   poll(time, unit)   |
| 检查 | element() |   peek()   | 不适用 |        不适用        |

- BlockingQueue不接受null元素。 实现会在尝试add ， put或offer null抛出NullPointerException 。null值用作标记值，以指示poll操作失败
- BlockingQueue可能受容量限制。 在任何给定时间，它都可能具有remainingCapacity容量，超过该容量就不能put其他元素而不会阻塞。 没有任何内部容量约束的BlockingQueue始终返回Integer.MAX_VALUE的剩余容量。
- BlockingQueue实现被设计为主要用于生产者-消费者队列，但另外还支持Collection接口。 因此，例如，可以使用remove(x)从队列中remove(x)任意元素。 但是，这样的操作通常不能非常有效地执行，并且仅用于偶尔的使用，例如当取消排队的消息时。
  BlockingQueue实现是线程安全的。 所有排队方法都是使用内部锁或其他形式的并发控制来原子地实现其效果的。 然而，大量的Collection操作addAll ， containsAll ， retainAll和removeAll不一定原子除非在实现中另有规定执行。 因此，例如，仅在c添加一些元素之后， addAll(c)可能会失败（引发异常）。
- BlockingQueue本质上不支持任何类型的“关闭”或“关闭”操作，以指示将不再添加任何项目。 此类功能的需求和使用往往取决于实现。 例如，一种常见的策略是让生产者插入特殊的流尾对象或有毒对象，当消费者采取这种方法时会对其进行相应的解释。
  使用示例，基于典型的生产者-消费者方案。 请注意， BlockingQueue可以安全地与多个生产者和多个消费者一起使用。











### Janino编译器



#### 简介

   Janino 是一个极小、极快的 开源Java 编译器（Janino is a super-small, super-fast Java™ compiler.）。Janino 不仅可以像 JAVAC 一样将 Java 源码文件编译为字节码文件，还可以编译内存中的 Java 表达式、块、类和源码文件，加载字节码并在 JVM 中直接执行。Janino 同样可以用于静态代码分析和代码操作。

项目地址：https://github.com/janino-compiler/janino

官网地址：http://janino-compiler.github.io/janino/    <font color=red>官网简单一看即可，更重要的是看javadoc</font>


#### ExpressEvaluator

~~~java
 public static void main(String[] args) throws Exception {
        // Create "ExpressionEvaluator" object.
        IExpressionEvaluator ee = CompilerFactoryFactory.getDefaultCompilerFactory().newExpressionEvaluator();
        // 设置返回值类型
        ee.setExpressionType(double.class);
        // 设置参数名与类型
        ee.setParameters(new String[] { "total" }, new Class[] { double.class });
        // 设置抛出异常的类型
        ee.setThrownExceptions(new Class[]{Exception.class});
        // 设置表达式体
        ee.cook("total*100");
        // 传入参数并执行表达式体, 没有参数时传入null
        Double res = (Double)ee.evaluate(new Object[]{7.5D});
        System.out.println(res);

    }
~~~

#### ScriptEvaluator

~~~java
public static void main(String[] args) throws CompileException, InvocationTargetException {
        // ScriptEvaluator可以用于编译和执行代码块
        // 如果有return的返回值，则该块必须返回该类型的值。
        // 作为一项特殊功能，它允许声明方法。方法声明的位置和顺序无关紧要。
        ScriptEvaluator se = new ScriptEvaluator();
        se.setParameters(new String[] { "arg1", "arg2" }, new Class[] { String.class, int.class });
        se.cook(
                ""
                        + "System.out.println(arg1);\n"
                        + "System.out.println(arg2);\n"
                        + "\n"
                        + "static void method1() {\n"
                        + "    System.out.println(\"run in method1()\");\n"
                        + "}\n"
                        + "\n"
                        + "public static void method2() {\n"
                        + "    System.out.println(\"run in method2()\");\n"
                        + "}\n"
                        + "\n"
                        + "method1();\n"
                        + "method2();\n"
                        + "\n"

        );
        se.evaluate(new Object[]{"aaa",22});
    }
~~~

#### ClassBodyEvaluator

ClassBodyEvaluator的作用是编译类的主体，然后生成一个用于反射的Class对象。

![image-20210430194947060](img/image-20210430194947060.png)

#### Janino使用Compiler

~~~java
public static void main(String[] args) throws IOException, CompileException, ClassNotFoundException,
            NoSuchMethodException, InvocationTargetException, IllegalAccessException {

        ICompiler compiler = new CompilerFactory().newCompiler();
        // 用于保存编译后的class字节码的map
        Map<String, byte[]> classes = new HashMap<String, byte[]>();
        // 设置字节码生产器为MapResourceCreator
        compiler.setClassFileCreator(new MapResourceCreator(classes));

        // Now compile two units from strings:
        compiler.compile(new Resource[] {
            new StringResource("pkg1/A.java",
                "package pkg1; public class A { public static int meth() { return pkg2.B.meth(); } }"),
            new StringResource("pkg2/B.java",
                "package pkg2; public class B { public static int meth() { return 77;            } }"),});

        // Set up a class loader that uses the generated classes.
        ClassLoader cl = new ResourceFinderClassLoader(new MapResourceFinder(classes), // resourceFinder
            ClassLoader.getSystemClassLoader() // parent
        );
        Assert.assertEquals(77, cl.loadClass("pkg1.A").getDeclaredMethod("meth").invoke(null));
    }
~~~

#### Janino使用ClassLoader

~~~java
ClassLoader cl = new JavaSourceClassLoader(
    this.getClass().getClassLoader(),  // parentClassLoader
    new File[] { new File("srcdir") }, // optionalSourcePath
    (String) null,                     // optionalCharacterEncoding
    DebuggingInformation.NONE          // debuggingInformation
);
 
// Load class A from "srcdir/pkg1/A.java", and also its superclass
// B from "srcdir/pkg2/B.java":
Object o = cl.loadClass("pkg1.A").newInstance();
 
// Class "B" implements "Runnable", so we can cast "o" to
// "Runnable".
((Runnable) o).run(); 
~~~

#### Debug

idea貌似可以调试，但是无法看到生成的java文件，所以两样一抹黑

```
org.codehaus.janino.source_debugging.enable=true\
org.codehaus.janino.source_debugging.dir=C:\tmp\
```

![image-20210430195942917](img/image-20210430195942917.png)



#### java8 default和static方法

> static方法

在接口中可以定义一个或者多个static方法，默认为public。子类不会继承接口中的静态方法，但是子类可以继承抽象类中的静态方法

~~~java
public interface HelloInterface {
    static void say(){}
}

public abstract class SimpleAbstractClass {
    public static void say1(){}
}

public class HelloInterfaceImpl extends SimpleAbstractClass implements HelloInterface {
    public void sayHello() {
        // 接口中的static方法不会被继承， 还是要通过类名.方法名调用
        HelloInterface.say();
        // 抽象类中的static方法可以被继承
        say1();
    }
}
~~~

> default方法

在接口中可以定义一个或者多个default方法，默认为public。default方法可以调用抽象方法

~~~java
public interface HelloInterface2 {
    void sayHello(String say);
    default void play(String sport) {
        // default方法中调用抽象方法
        sayHello("haha");
    }
}
~~~

当子类实现的两个接口中有相同方法签名（方法名相同，参数类型及顺序相同）的default方法时， 子类必须实现该default方法。否则编译失败。

当子类实现的接口中有与抽象类中相同方法签名的default方法时， 默认调用父类的方法。

当子类实现的两个接口或者接口和抽象类有相同的方法签名， 但是两个方法的返回值不同时，将会编译失败。







#### IDEA 查看jdk源码

https://blog.csdn.net/rain_zhao_0102/article/details/106041697

> 前言

最近想研究下jdk的ClassLoader。发现jdk 1.8下没有包含sun.*的源码。所以在idea中打开sun.*下的类，都只能查看通过反编译得到的代码，由于缺少相应的注释，且某些变量变成了val1，val2等，可读性变得很差，给源码的学习效率造成影响。
我们可以通过引入外部的源码文件依赖，使得idea在打开sun.*包下的类时，可以找到并打开对应的源码

1. 下载OpenJDK源码到本地, sun包的源码就在src\share\classes目录下

   ~~~shell
   git clone https://github.com/openjdk-mirror/jdk.git
   cd jdk
   git checkout jdk8u/jdk8u/master
   ~~~

2. 在项目中添加源码路径
   在idea中打开项目，右上角点击file -> project structure

   ![image-20210617201809321](img/image-20210617201809321.png)

3. 在弹出窗口选择SDKs -> 右侧窗口选择 sourcepath -> 点击左下方“+” 添加刚才下载的源码路径，点ok。

   ![image-20210617202019299](img/image-20210617202019299.png)

可以发现，sun包下的类已经可以读取到相应的java文件源码了
