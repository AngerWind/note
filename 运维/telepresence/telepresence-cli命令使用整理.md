# Telepresence CLI 命令使用整理

- 来源页面：[Telepresence CLI Reference](https://telepresence.io/docs/reference/cli/telepresence)
- 版本分支：`release/v2`（官方文档页面显示 Telepresence 2.28；少量子页面仍标注 2.27，本文按当前 `release/v2` 源文件整理）
- 生成时间：2026-05-19 09:58:56
- 命令页数量：87

## 阅读说明

- 本文按官方 `docs/reference/cli` 目录整理，包含顶层命令及其子命令。
- `用法` 和 `参数` 保留官方 CLI 语法，便于直接复制到命令行对照。
- 大多数命令都可追加 `--help` 查看本机安装版本对应的完整帮助。

## 全局参数

以下参数出现在大多数 `telepresence` 命令中：

```text
--config string     指定 Telepresence 配置文件路径，默认 $HOME/.config/telepresence/config.yml
--output string     输出格式：json、yaml、default，默认 default
--progress string   进度输出类型：auto、tty、plain、json、quiet，默认 auto
--use string        匹配并唯一标识 daemon 容器的表达式
```

## 命令索引

- [telepresence](#telepresence)：将你的工作站连接到 Kubernetes 集群
- [telepresence completion](#telepresence-completion)：生成 shell 补全脚本
- [telepresence compose](#telepresence-compose)：使用 Telepresence 和 Docker 定义并运行多容器应用
- [telepresence compose attach](#telepresence-compose-attach)：将本地标准输入、输出和错误流附加到服务正在运行的容器
- [telepresence compose bridge](#telepresence-compose-bridge)：将 Compose 文件转换为另一种模型
- [telepresence compose build](#telepresence-compose-build)：构建或重新构建服务
- [telepresence compose commit](#telepresence-compose-commit)：基于服务容器的变更创建新镜像
- [telepresence compose config](#telepresence-compose-config)：解析、解析引用并以规范格式渲染 Compose 文件
- [telepresence compose cp](#telepresence-compose-cp)：docker compose cp [OPTIONS] SRC_PATH|- SERVICE:DEST_PATH
- [telepresence compose create](#telepresence-compose-create)：为服务创建容器
- [telepresence compose down](#telepresence-compose-down)：停止并删除容器和网络
- [telepresence compose events](#telepresence-compose-events)：接收容器的实时事件
- [telepresence compose exec](#telepresence-compose-exec)：在运行中的容器内执行命令
- [telepresence compose export](#telepresence-compose-export)：将服务容器的文件系统导出为 tar 归档
- [telepresence compose images](#telepresence-compose-images)：列出已创建容器使用的镜像
- [telepresence compose kill](#telepresence-compose-kill)：强制停止服务容器
- [telepresence compose logs](#telepresence-compose-logs)：查看容器输出
- [telepresence compose ls](#telepresence-compose-ls)：列出正在运行的 Compose 项目
- [telepresence compose pause](#telepresence-compose-pause)：暂停服务
- [telepresence compose port](#telepresence-compose-port)：打印端口绑定对应的公开端口
- [telepresence compose ps](#telepresence-compose-ps)：列出容器
- [telepresence compose publish](#telepresence-compose-publish)：发布 Compose 应用
- [telepresence compose pull](#telepresence-compose-pull)：拉取服务镜像
- [telepresence compose push](#telepresence-compose-push)：推送服务镜像
- [telepresence compose restart](#telepresence-compose-restart)：重启服务容器
- [telepresence compose rm](#telepresence-compose-rm)：删除已停止的服务容器
- [telepresence compose run](#telepresence-compose-run)：在服务上运行一次性命令
- [telepresence compose scale](#telepresence-compose-scale)：扩缩容服务
- [telepresence compose start](#telepresence-compose-start)：启动服务
- [telepresence compose stats](#telepresence-compose-stats)：实时显示容器资源使用统计
- [telepresence compose stop](#telepresence-compose-stop)：停止服务
- [telepresence compose top](#telepresence-compose-top)：显示正在运行的进程
- [telepresence compose unpause](#telepresence-compose-unpause)：恢复暂停的服务
- [telepresence compose up](#telepresence-compose-up)：创建并启动容器
- [telepresence compose version](#telepresence-compose-version)：显示 Docker Compose 版本信息
- [telepresence compose volumes](#telepresence-compose-volumes)：列出卷
- [telepresence compose wait](#telepresence-compose-wait)：阻塞等待全部或指定服务的容器停止。
- [telepresence compose watch](#telepresence-compose-watch)：监视服务的构建上下文，并在文件更新时重新构建或刷新容器
- [telepresence config](#telepresence-config)：Telepresence 配置命令
- [telepresence config view](#telepresence-config-view)：查看当前 Telepresence 配置
- [telepresence connect](#telepresence-connect)：连接到集群
- [telepresence curl](#telepresence-curl)：使用 daemon 网络执行 curl
- [telepresence docker-run](#telepresence-docker-run)：使用 daemon 网络执行 docker run
- [telepresence gather-logs](#telepresence-gather-logs)：收集 traffic-manager、traffic-agent、用户 daemon 和 root daemon 的日志，并导出为 zip 文件。
- [telepresence genyaml](#telepresence-genyaml)：生成可用于 Kubernetes manifest 的 YAML。
- [telepresence genyaml annotations](#telepresence-genyaml-annotations)：生成 Pod 模板 metadata annotations 的 YAML。
- [telepresence genyaml config](#telepresence-genyaml-config)：生成 telepresence-agents ConfigMap 中 agent 条目的 YAML。
- [telepresence genyaml container](#telepresence-genyaml-container)：生成 traffic-agent 容器的 YAML。
- [telepresence genyaml initcontainer](#telepresence-genyaml-initcontainer)：生成 traffic-agent init 容器的 YAML。
- [telepresence genyaml volume](#telepresence-genyaml-volume)：生成 traffic-agent 卷的 YAML。
- [telepresence helm](#telepresence-helm)：使用内置 Telepresence Helm chart 的 Helm 命令。
- [telepresence helm install](#telepresence-helm-install)：安装 Telepresence traffic manager
- [telepresence helm lint](#telepresence-helm-lint)：验证内置 Telepresence Helm chart
- [telepresence helm uninstall](#telepresence-helm-uninstall)：卸载 Telepresence traffic manager
- [telepresence helm upgrade](#telepresence-helm-upgrade)：升级 Telepresence traffic manager
- [telepresence helm version](#telepresence-helm-version)：打印 Helm 客户端版本
- [telepresence ingest](#telepresence-ingest)：接入一个容器
- [telepresence intercept](#telepresence-intercept)：拦截一个服务
- [telepresence leave](#telepresence-leave)：移除现有拦截
- [telepresence list-contexts](#telepresence-list-contexts)：显示所有 context
- [telepresence list-namespaces](#telepresence-list-namespaces)：显示所有 namespace
- [telepresence list](#telepresence-list)：列出当前拦截
- [telepresence loglevel](#telepresence-loglevel)：临时修改 traffic-manager、traffic-agent、用户 daemon 和 root daemon 的日志级别
- [telepresence mcp](#telepresence-mcp)：MCP 服务器管理
- [telepresence mcp claude](#telepresence-mcp-claude)：管理 Claude Desktop MCP 服务器
- [telepresence mcp claude disable](#telepresence-mcp-claude-disable)：从 Claude 配置中移除服务器
- [telepresence mcp claude enable](#telepresence-mcp-claude-enable)：将服务器添加到 Claude 配置
- [telepresence mcp claude list](#telepresence-mcp-claude-list)：显示 Claude MCP 服务器
- [telepresence mcp cursor](#telepresence-mcp-cursor)：管理 Cursor MCP 服务器
- [telepresence mcp cursor disable](#telepresence-mcp-cursor-disable)：从 Cursor 配置中移除服务器
- [telepresence mcp cursor enable](#telepresence-mcp-cursor-enable)：将服务器添加到 Cursor 配置
- [telepresence mcp cursor list](#telepresence-mcp-cursor-list)：显示 Cursor MCP 服务器
- [telepresence mcp start](#telepresence-mcp-start)：启动 MCP 服务器
- [telepresence mcp stream](#telepresence-mcp-stream)：通过 HTTP 流式暴露 MCP 服务器
- [telepresence mcp tools](#telepresence-mcp-tools)：将工具导出为 JSON
- [telepresence mcp vscode](#telepresence-mcp-vscode)：管理 VSCode MCP 服务器
- [telepresence mcp vscode disable](#telepresence-mcp-vscode-disable)：从 VSCode 配置中移除服务器
- [telepresence mcp vscode enable](#telepresence-mcp-vscode-enable)：将服务器添加到 VSCode 配置
- [telepresence mcp vscode list](#telepresence-mcp-vscode-list)：显示 VSCode MCP 服务器
- [telepresence quit](#telepresence-quit)：通知 Telepresence daemon 退出
- [telepresence replace](#telepresence-replace)：替换一个容器
- [telepresence revoke](#telepresence-revoke)：通过拦截 ID 撤销拦截。拦截 ID 的格式必须为 &lt;session_id&gt;:&lt;intercept_name&gt;
- [telepresence serve](#telepresence-serve)：在远程服务上启动浏览器
- [telepresence status](#telepresence-status)：显示连接状态
- [telepresence uninstall](#telepresence-uninstall)：卸载 Telepresence agent
- [telepresence version](#telepresence-version)：显示版本
- [telepresence wiretap](#telepresence-wiretap)：旁路监听一个服务

## telepresence

**用途**：将你的工作站连接到 Kubernetes 集群

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence](https://telepresence.io/docs/reference/cli/telepresence)

### 概要

Telepresence 可以连接到 Kubernetes 集群，并将工作站的出站流量路由到该集群。这样，本地运行的软件就可以像在集群内部运行一样与集群资源通信。使用以下命令连接：
```bash
telepresence connect
```

Telepresence 还可以拦截集群中发往某个特定服务的流量，并将其重定向到你的本地工作站：

```bash
telepresence intercept <name of service>
```

Telepresence 使用后台进程（user daemon）管理集群会话，并使用系统服务（root daemon）修改工作站的网络和 DNS，使集群服务可以在本地访问。

如果 Telepresence 是以独立二进制文件形式安装的，系统服务不会自动存在。这时必须使用 `sudo` 启动 root daemon，过程中可能会提示输入密码。

### 用法
```
  telepresence [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [completion](telepresence_completion) | 生成 shell 补全脚本 |
| [compose](telepresence_compose) | 使用 Telepresence 和 Docker 定义并运行多容器应用 |
| [config](telepresence_config) | Telepresence 配置命令 |
| [connect](telepresence_connect) | 连接到集群 |
| [curl](telepresence_curl) | 使用 daemon 网络执行 curl |
| [docker-run](telepresence_docker-run) | 使用 daemon 网络执行 docker run |
| [gather-logs](telepresence_gather-logs) | 收集 traffic-manager、traffic-agent、用户 daemon 和 root daemon 的日志，并导出为 zip 文件。 |
| [genyaml](telepresence_genyaml) | 生成可用于 Kubernetes manifest 的 YAML。 |
| [helm](telepresence_helm) | 使用内置 Telepresence Helm chart 的 Helm 命令。 |
| [ingest](telepresence_ingest) | 接入一个容器 |
| [intercept](telepresence_intercept) | 拦截一个服务 |
| [leave](telepresence_leave) | 移除现有拦截 |
| [list](telepresence_list) | 列出当前拦截 |
| [list-contexts](telepresence_list-contexts) | 显示所有 context |
| [list-namespaces](telepresence_list-namespaces) | 显示所有 namespace |
| [loglevel](telepresence_loglevel) | 临时修改 traffic-manager、traffic-agent、用户 daemon 和 root daemon 的日志级别 |
| [mcp](telepresence_mcp) | MCP 服务器管理 |
| [quit](telepresence_quit) | 通知 Telepresence daemon 退出 |
| [replace](telepresence_replace) | 替换一个容器 |
| [revoke](telepresence_revoke) | 通过拦截 ID 撤销拦截。拦截 ID 必须采用 <session_id>:<intercept_name> 格式 |
| [serve](telepresence_serve) | 在远程服务上启动浏览器 |
| [status](telepresence_status) | 显示连接状态 |
| [uninstall](telepresence_uninstall) | 卸载 Telepresence agent |
| [version](telepresence_version) | 显示版本 |
| [wiretap](telepresence_wiretap) | 旁路监听一个服务 |

### 参数
```
  -h, --help   远程呈现帮助
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看 `telepresence [command] --help`。

## telepresence completion

**用途**：生成 shell 补全脚本

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_completion](https://telepresence.io/docs/reference/cli/telepresence_completion)

### 概要

加载补全脚本：

### Bash:
```bash
  $ source <(telepresence completion bash)

  # 要加载每个会话的完成内容，请执行一次：
  # Linux：
  $ telepresence completion bash > /etc/bash_completion.d/telepresence
  # macOS：
  $ telepresence completion bash > $(brew --prefix)/etc/bash_completion.d/telepresence
```

### Zsh:
```zsh

  # 如果您的环境中尚未启用 shell 完成，
  # 您需要启用它。  您可以执行一次以下命令：

  $ echo "autoload -U compinit; compinit" >> ~/.zshrc

  # 要加载每个会话的完成内容，请执行一次：
  $ telepresence completion zsh > "${fpath[1]}/_telepresence"

  # 您需要启动一个新的 shell 才能使此设置生效。
```

### fish:
```fish

  $ telepresence completion fish | source

  # 要加载每个会话的完成内容，请执行一次：
  $ telepresence completion fish > ~/.config/fish/completions/telepresence.fish
```

### PowerShell:
```powershell

  PS> telepresence completion powershell | Out-String | Invoke-Expression

  # 要加载每个新会话的完成情况，请运行：
  PS> telepresence completion powershell > telepresence.ps1
  # 并从您的 PowerShell 个人资料中获取此文件。
```

### 用法
```
  telepresence completion [flags]
```

### 参数
```
  -h, --help   帮助完成
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose

**用途**：使用 Telepresence 和 Docker 定义并运行多容器应用

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose](https://telepresence.io/docs/reference/cli/telepresence_compose)

### 用法
```
  telepresence compose [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [attach](telepresence_compose_attach) | 将本地标准输入、输出和错误流附加到服务正在运行的容器 |
| [bridge](telepresence_compose_bridge) | 将 Compose 文件转换为另一种模型 |
| [build](telepresence_compose_build) | 构建或重新构建服务 |
| [commit](telepresence_compose_commit) | 基于服务容器的变更创建新镜像 |
| [config](telepresence_compose_config) | 解析、解析引用并以规范格式渲染 Compose 文件 |
| [cp](telepresence_compose_cp) | docker compose cp [OPTIONS] SRC_PATH|- SERVICE:DEST_PATH |
| [create](telepresence_compose_create) | 为服务创建容器 |
| [down](telepresence_compose_down) | 停止并删除容器和网络 |
| [events](telepresence_compose_events) | 接收容器的实时事件 |
| [exec](telepresence_compose_exec) | 在运行中的容器内执行命令 |
| [export](telepresence_compose_export) | 将服务容器的文件系统导出为 tar 归档 |
| [images](telepresence_compose_images) | 列出已创建容器使用的镜像 |
| [kill](telepresence_compose_kill) | 强制停止服务容器 |
| [logs](telepresence_compose_logs) | 查看容器输出 |
| [ls](telepresence_compose_ls) | 列出正在运行的 Compose 项目 |
| [pause](telepresence_compose_pause) | 暂停服务 |
| [port](telepresence_compose_port) | 打印端口绑定对应的公开端口 |
| [ps](telepresence_compose_ps) | 列出容器 |
| [publish](telepresence_compose_publish) | 发布 Compose 应用 |
| [pull](telepresence_compose_pull) | 拉取服务镜像 |
| [push](telepresence_compose_push) | 推送服务镜像 |
| [restart](telepresence_compose_restart) | 重启服务容器 |
| [rm](telepresence_compose_rm) | 删除已停止的服务容器 |
| [run](telepresence_compose_run) | 在服务上运行一次性命令 |
| [scale](telepresence_compose_scale) | 扩缩容服务 |
| [start](telepresence_compose_start) | 启动服务 |
| [stats](telepresence_compose_stats) | 实时显示容器资源使用统计 |
| [stop](telepresence_compose_stop) | 停止服务 |
| [top](telepresence_compose_top) | 显示正在运行的进程 |
| [unpause](telepresence_compose_unpause) | 恢复暂停的服务 |
| [up](telepresence_compose_up) | 创建并启动容器 |
| [version](telepresence_compose_version) | 显示 Docker Compose 版本信息 |
| [volumes](telepresence_compose_volumes) | 列出卷 |
| [wait](telepresence_compose_wait) | 阻塞等待全部或指定服务的容器停止。 |
| [watch](telepresence_compose_watch) | 监视服务的构建上下文，并在文件更新时重新构建或刷新容器 |

### 参数
```
  -h, --help   帮助撰写
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看`telepresence compose [command] --help`。

## telepresence compose attach

**用途**：将本地标准输入、输出和错误流附加到服务正在运行的容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_attach](https://telepresence.io/docs/reference/cli/telepresence_compose_attach)

### 用法
```
  telepresence compose attach [flags] [services]
```

### 参数
```
  -h, --help   帮助附加
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose attach 参数
```
      --detach-keys string   覆盖用于从容器分离的按键序列。
      --index int            如果服务有多个副本，则容器的索引。
      --no-stdin             请勿附加STDIN
      --sig-proxy            将所有接收到的信号代理给进程（默认 true）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose bridge

**用途**：将 Compose 文件转换为另一种模型

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_bridge](https://telepresence.io/docs/reference/cli/telepresence_compose_bridge)

### 用法
```
  telepresence compose bridge [flags] [services]
```

### 参数
```
  -h, --help   bridge 帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose bridge 参数
```

```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose build

**用途**：构建或重新构建服务

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_build](https://telepresence.io/docs/reference/cli/telepresence_compose_build)

### 用法
```
  telepresence compose build [flags] [services]
```

### 参数
```
  -h, --help   build 帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose build 参数
```
      --build-arg stringArray   设置服务的构建时变量
      --builder string          设置要使用的 builder
      --check                   检查构建配置
  -m, --memory bytes            设置构建容器的内存限制。 BuildKit 不支持。
      --no-cache                构建镜像时不要使用缓存
      --print                   打印等效烘焙文件
      --provenance string       添加出处证明
      --pull                    始终尝试拉取更新版本的映像
      --push                    推送服务镜像
  -q, --quiet                   抑制构建输出
      --sbom string             添加SBOM证明
      --ssh string              设置构建服务映像时使用的SSH身份验证。 （使用“默认”来使用您的默认SSH代理）
      --with-dependencies       还构建依赖关系（传递性）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose commit

**用途**：基于服务容器的变更创建新镜像

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_commit](https://telepresence.io/docs/reference/cli/telepresence_compose_commit)

### 用法
```
  telepresence compose commit [flags] [services]
```

### 参数
```
  -h, --help   帮助提交
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose commit 参数
```
  -a, --author string    作者（例如“约翰·汉尼拔·史密斯 <hannibal@a-team.com>”）
  -c, --change list      将 Dockerfile 指令应用到创建的镜像
      --index int        如果服务有多个副本，则容器的索引。
  -m, --message string   提交消息
  -p, --pause            在提交期间暂停容器（默认 true）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose config

**用途**：解析、解析引用并以规范格式渲染 Compose 文件

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_config](https://telepresence.io/docs/reference/cli/telepresence_compose_config)

### 用法
```
  telepresence compose config [flags] [services]
```

### 参数
```
  -h, --help   配置帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose config 参数
```
      --environment             用于插值的打印环境。
      --format string           格式化输出。值：[yaml | json]
      --hash string             打印服务配置哈希，每行一个。
      --images                  打印图像名称，每行一个。
      --lock-image-digests      生成带有图像摘要的覆盖文件
      --models                  打印型号名称，每行一个。
      --networks                打印网络名称，每行一个。
      --no-consistency          不检查模型一致性 - 警告：可能会产生无效的 Compose 输出
      --no-env-resolution       不解析服务环境文件
      --no-interpolate          不要插入环境变量
      --no-normalize            不要规范化 compose 模型
      --no-path-resolution      不解析文件路径
  -o, --output string           保存到文件（默认为标准输出）
      --profiles                打印配置文件名称，每行一个。
  -q, --quiet                   只验证配置，不打印任何内容
      --resolve-image-digests   将图像标签固定到摘要
      --services                打印服务名称，每行一个。
      --variables               打印模型变量和default。
      --volumes                 打印卷名称，每行一个。
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose cp

**用途**：docker compose cp [OPTIONS] SRC_PATH|- SERVICE:DEST_PATH

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_cp](https://telepresence.io/docs/reference/cli/telepresence_compose_cp)

### 用法
```
  telepresence compose cp [flags] [services]
```

### 参数
```
  -h, --help   帮助cp
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose cp 参数
```
      --all           包含由运行命令创建的容器
  -a, --archive       归档模式（复制所有uid/gid信息）
  -L, --follow-link   始终遵循 SRC_PATH 中的符号链接
      --index int     如果服务有多个副本，则容器的索引
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose create

**用途**：为服务创建容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_create](https://telepresence.io/docs/reference/cli/telepresence_compose_create)

### 用法
```
  telepresence compose create [flags] [services]
```

### 参数
```
  -h, --help   帮助创建
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose create 参数
```
      --build            在启动容器之前构建镜像
      --force-recreate   即使容器的配置和映像未更改，也重新创建容器
      --no-build         不要树立形象，即使这是政策
      --no-recreate      如果容器已存在，请勿重新创建它们。与--force-recreate不兼容。
      --pull string      运行前拉取镜像（“always”|“missing”|“never”|“build”）（默认“policy”）
      --quiet-pull       拉取而不打印进度信息
      --remove-orphans   删除 Compose 文件中未定义的服务的容器
      --scale uint32     将 SERVICE 缩放至 NUM 实例。覆盖 Compose 文件中的比例设置（如果存在）。
  -y, --yes              假设所有提示的答案都是“是”并以非交互方式运行
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose down

**用途**：停止并删除容器和网络

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_down](https://telepresence.io/docs/reference/cli/telepresence_compose_down)

### 用法
```
  telepresence compose down [flags] [services]
```

### 参数
```
  -h, --help   帮助下降
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose down 参数
```
      --remove-orphans   删除 Compose 文件中未定义的服务的容器
      --rmi string       删除服务使用的图像。 “local”仅删除没有自定义标签的图像（“local”|“all”）
  -t, --timeout int      指定关闭超时（以秒为单位）
  -v, --volumes          删除在 Compose 文件的“卷”部分中声明的命名卷以及附加到容器的匿名卷
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose events

**用途**：接收容器的实时事件

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_events](https://telepresence.io/docs/reference/cli/telepresence_compose_events)

### 用法
```
  telepresence compose events [flags] [services]
```

### 参数
```
  -h, --help   活动帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose events 参数
```
      --json           将事件输出为 json 对象流
      --since string   显示自时间戳以来创建的所有事件
      --until string   流式传输事件直至此时间戳
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose exec

**用途**：在运行中的容器内执行命令

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_exec](https://telepresence.io/docs/reference/cli/telepresence_compose_exec)

### 用法
```
  telepresence compose exec [flags] [services]
```

### 参数
```
  -h, --help   执行帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose exec 参数
```
  -d, --detach            分离模式：在后台运行命令
  -e, --env stringArray   设置环境变量
      --index int         如果服务有多个副本，则容器的索引
  -T, --no-tty            禁用伪TTY分配。默认情况下，“docker compose exec”分配一个TTY。 （默认为真）
      --privileged        授予进程扩展权限
  -u, --user string       以该用户身份运行命令
  -w, --workdir string    此命令的 workdir 目录的路径
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose export

**用途**：将服务容器的文件系统导出为 tar 归档

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_export](https://telepresence.io/docs/reference/cli/telepresence_compose_export)

### 用法
```
  telepresence compose export [flags] [services]
```

### 参数
```
  -h, --help   出口帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose export 参数
```
      --index int       如果服务有多个副本，则容器的索引。
  -o, --output string   写入文件，而不是STDOUT
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose images

**用途**：列出已创建容器使用的镜像

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_images](https://telepresence.io/docs/reference/cli/telepresence_compose_images)

### 用法
```
  telepresence compose images [flags] [services]
```

### 参数
```
  -h, --help   图像帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose images 参数
```
      --format string   格式化输出。值：[表| json]（默认“表”）
  -q, --quiet           只显示ID
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose kill

**用途**：强制停止服务容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_kill](https://telepresence.io/docs/reference/cli/telepresence_compose_kill)

### 用法
```
  telepresence compose kill [flags] [services]
```

### 参数
```
  -h, --help   帮助杀人
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose kill 参数
```
      --remove-orphans   删除 Compose 文件中未定义的服务的容器
  -s, --signal string    SIGNAL发送到容器（默认“\”SIGKILL\“”）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose logs

**用途**：查看容器输出

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_logs](https://telepresence.io/docs/reference/cli/telepresence_compose_logs)

### 用法
```
  telepresence compose logs [flags] [services]
```

### 参数
```
  -h, --help   日志帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose logs 参数
```
  -f, --follow          跟踪日志输出
      --index int       如果服务有多个副本，则容器的索引
      --no-color        产生单色输出
      --no-log-prefix   不要在日志中打印前缀
      --since string    显示自时间戳（例如 2013-01-02T13:23:37Z）或相对时间（例如 42m 42 分钟）以来的日志
  -n, --tail string     从每个容器的日志末尾开始显示的行数（默认“全部”）
  -t, --timestamps      显示时间戳
      --until string    显示时间戳之前的日志（例如 2013-01-02T13:23:37Z）或相对时间戳（例如 42m 42 分钟）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose ls

**用途**：列出正在运行的 Compose 项目

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_ls](https://telepresence.io/docs/reference/cli/telepresence_compose_ls)

### 用法
```
  telepresence compose ls [flags] [services]
```

### 参数
```
  -h, --help   帮助 ls
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose ls 参数
```
  -a, --all             显示所有已停止的Compose项目
      --filter string   根据提供的条件过滤输出
      --format string   格式化输出。值：[表| json]（默认“表”）
  -q, --quiet           只显示项目名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose pause

**用途**：暂停服务

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_pause](https://telepresence.io/docs/reference/cli/telepresence_compose_pause)

### 用法
```
  telepresence compose pause [flags] [services]
```

### 参数
```
  -h, --help   帮助暂停
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose pause 参数
```

```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose port

**用途**：打印端口绑定对应的公开端口

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_port](https://telepresence.io/docs/reference/cli/telepresence_compose_port)

### 用法
```
  telepresence compose port [flags] [services]
```

### 参数
```
  -h, --help   端口帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose port 参数
```
      --index int         如果服务有多个副本，则容器的索引
      --protocol string   tcp 或 udp（默认“\”tcp\“”）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose ps

**用途**：列出容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_ps](https://telepresence.io/docs/reference/cli/telepresence_compose_ps)

### 用法
```
  telepresence compose ps [flags] [services]
```

### 参数
```
  -h, --help   帮忙ps一下
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose ps 参数
```
  -a, --all                  显示所有已停止的容器（包括由 run 命令创建的容器）
      --filter string        按属性过滤服务（支持的过滤器：状态）
      --format string        使用自定义模板设置输出格式： 'table'：以带有列标题的表格格式打印输出（默认） 'table TEMPLATE'：使用给定的 Go 模板以表格格式打印输出 'json'：以 JSON 格式打印 'TEMPLATE'：使用给定的 Go 模板打印输出。有关使用模板（默认“表格”）格式化输出的更多信息，请参阅https://docs.docker.com/go/formatting/
      --no-trunc             不要截断输出
      --orphans              包括孤立服务（项目未声明）（默认 true）
  -q, --quiet                只显示ID
      --services             显示服务
      --status stringArray   按状态过滤服务。值：[暂停|重新启动|删除|跑步|死了|创建|退出]
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose publish

**用途**：发布 Compose 应用

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_publish](https://telepresence.io/docs/reference/cli/telepresence_compose_publish)

### 用法
```
  telepresence compose publish [flags] [services]
```

### 参数
```
  -h, --help   帮助发布
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose publish 参数
```
      --app                     已发布的撰写应用程序（包括引用的图像）
      --oci-version string      OCI图像/工件规范版本（默认自动确定）
      --resolve-image-digests   将图像标签固定到摘要
      --with-env                在已发布的 OCI 工件中包含环境变量
  -y, --yes                     假设所有提示的答案都是“是”
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose pull

**用途**：拉取服务镜像

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_pull](https://telepresence.io/docs/reference/cli/telepresence_compose_pull)

### 用法
```
  telepresence compose pull [flags] [services]
```

### 参数
```
  -h, --help   帮助拉动
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose pull 参数
```
      --ignore-buildable       忽略可以构建的图像
      --ignore-pull-failures   尽可能拉取并忽略拉取失败的图像
      --include-deps           还拉取声明为依赖项的服务
      --policy string          应用拉取策略（“缺失”|“始终”）
  -q, --quiet                  拉取而不打印进度信息
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose push

**用途**：推送服务镜像

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_push](https://telepresence.io/docs/reference/cli/telepresence_compose_push)

### 用法
```
  telepresence compose push [flags] [services]
```

### 参数
```
  -h, --help   帮助推送
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose push 参数
```
      --ignore-push-failures   尽可能推送并忽略推送失败的图像
      --include-deps           还推送声明为依赖项的服务的镜像
  -q, --quiet                  推送而不打印进度信息
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose restart

**用途**：重启服务容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_restart](https://telepresence.io/docs/reference/cli/telepresence_compose_restart)

### 用法
```
  telepresence compose restart [flags] [services]
```

### 参数
```
  -h, --help   帮助重新启动
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose restart 参数
```
      --no-deps       不要重新启动依赖服务
  -t, --timeout int   指定关闭超时（以秒为单位）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose rm

**用途**：删除已停止的服务容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_rm](https://telepresence.io/docs/reference/cli/telepresence_compose_rm)

### 用法
```
  telepresence compose rm [flags] [services]
```

### 参数
```
  -h, --help   帮助 rm
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose rm 参数
```
  -f, --force     不要要求确认删除
  -s, --stop      如果需要，在移除之前停止容器
  -v, --volumes   删除附加到容器的所有匿名卷
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose run

**用途**：在服务上运行一次性命令

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_run](https://telepresence.io/docs/reference/cli/telepresence_compose_run)

### 用法
```
  telepresence compose run [flags] [services]
```

### 参数
```
  -h, --help   帮助跑步
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose run 参数
```
      --build                       启动容器之前构建镜像
      --cap-add list                添加Linux功能
      --cap-drop list               删除Linux能力
  -d, --detach                      在后台运行容器并打印容器 ID
      --entrypoint string           覆盖图像的入口点
  -e, --env stringArray             设置环境变量
      --env-from-file stringArray   从文件设置环境变量
  -i, --interactive                 即使未附加，也保持 STDIN 打开（默认 true）
  -l, --label stringArray           添加或覆盖标签
      --name string                 为容器指定名称
  -T, --no-TTY                      禁用伪TTY分配（默认：自动检测）（默认 true）
      --no-deps                     不要启动链接服务
  -p, --publish stringArray         将容器的端口发布到主机
      --pull string                 运行前拉取镜像（“always”|“missing”|“never”）（默认“policy”）
  -q, --quiet                       不要向 STDOUT 打印任何内容
      --quiet-build                 抑制构建过程的进度输出
      --quiet-pull                  拉取而不打印进度信息
      --remove-orphans              删除 Compose 文件中未定义的服务的容器
      --rm                          容器退出时自动移除
  -P, --service-ports               在启用所有服务端口并将其映射到主机的情况下运行命令
      --use-aliases                 使用容器连接到的网络中的服务网络 useAliases
  -u, --user string                 以指定的用户名或uid运行
  -v, --volume stringArray          绑定挂载卷
  -w, --workdir string              容器内的工作目录
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose scale

**用途**：扩缩容服务

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_scale](https://telepresence.io/docs/reference/cli/telepresence_compose_scale)

### 用法
```
  telepresence compose scale [flags] [services]
```

### 参数
```
  -h, --help   规模帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose scale 参数
```
      --no-deps   不要启动链接服务
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose start

**用途**：启动服务

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_start](https://telepresence.io/docs/reference/cli/telepresence_compose_start)

### 用法
```
  telepresence compose start [flags] [services]
```

### 参数
```
  -h, --help   帮助开始
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose start 参数
```
      --wait               等待服务运行|健康。表示分离模式。
      --wait-timeout int   等待项目运行|健康的最长时间（以秒为单位）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose stats

**用途**：实时显示容器资源使用统计

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_stats](https://telepresence.io/docs/reference/cli/telepresence_compose_stats)

### 用法
```
  telepresence compose stats [flags] [services]
```

### 参数
```
  -h, --help   统计帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose stats 参数
```
  -a, --all             显示所有容器（默认显示刚刚运行）
      --format string   使用自定义模板设置输出格式： 'table'：以带有列标题的表格格式打印输出（默认） 'table TEMPLATE'：使用给定的 Go 模板以表格格式打印输出 'json'：以 JSON 格式打印 'TEMPLATE'：使用给定的 Go 模板打印输出。有关使用模板格式化输出的更多信息，请参阅https://docs.docker.com/engine/cli/formatting/
      --no-stream       禁用流统计并仅提取第一个结果
      --no-trunc        不要截断输出
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose stop

**用途**：停止服务

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_stop](https://telepresence.io/docs/reference/cli/telepresence_compose_stop)

### 用法
```
  telepresence compose stop [flags] [services]
```

### 参数
```
  -h, --help   帮助停止
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose stop 参数
```
  -t, --timeout int   指定关闭超时（以秒为单位）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose top

**用途**：显示正在运行的进程

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_top](https://telepresence.io/docs/reference/cli/telepresence_compose_top)

### 用法
```
  telepresence compose top [flags] [services]
```

### 参数
```
  -h, --help   帮助顶部
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose top 参数
```

```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose unpause

**用途**：恢复暂停的服务

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_unpause](https://telepresence.io/docs/reference/cli/telepresence_compose_unpause)

### 用法
```
  telepresence compose unpause [flags] [services]
```

### 参数
```
  -h, --help   帮助取消暂停
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose unpause 参数
```

```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose up

**用途**：创建并启动容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_up](https://telepresence.io/docs/reference/cli/telepresence_compose_up)

### 用法
```
  telepresence compose up [flags] [services]
```

### 参数
```
  -h, --help   帮助向上
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose up 参数
```
      --abort-on-container-exit      如果任何容器已停止，则停止所有容器。与 -d 不兼容
      --abort-on-container-failure   如果任何容器失败退出，则停止所有容器。与 -d 不兼容
      --always-recreate-deps         重新创建依赖容器。与--no-recreate不兼容。
      --attach stringArray           限制附加到指定的服务。与--attach-dependencies不兼容。
      --attach-dependencies          自动附加到依赖服务的日志输出
      --build                        在启动容器之前构建镜像
  -d, --detach                       分离模式：在后台运行容器
      --exit-code-from string        返回所选服务容器的退出代码。意味着--abort-on-container-exit
      --force-recreate               即使容器的配置和映像未更改，也重新创建容器
      --menu                         附加运行时启用交互式快捷方式。与--detach不兼容。也可以通过设置COMPOSE_MENU环境变量来启用/禁用。
      --no-attach stringArray        不附加（流日志）到指定的服务
      --no-build                     不要树立形象，即使这是政策
      --no-color                     产生单色输出
      --no-deps                      不要启动链接服务
      --no-log-prefix                不要在日志中打印前缀
      --no-recreate                  如果容器已存在，请勿重新创建它们。与--force-recreate不兼容。
      --no-start                     创建服务后不要启动它们
      --pull string                  运行前拉取镜像（“always”|“missing”|“never”）（默认“policy”）
      --quiet-build                  抑制构建输出
      --quiet-pull                   拉取而不打印进度信息
      --remove-orphans               删除 Compose 文件中未定义的服务的容器
  -V, --renew-anon-volumes           重新创建匿名卷，而不是从以前的容器中检索数据
      --scale uint32                 将 SERVICE 缩放至 NUM 实例。覆盖 Compose 文件中的比例设置（如果存在）。
  -t, --timeout int                  使用此超时（以秒为单位）在连接时或容器已在运行时关闭容器
      --timestamps                   显示时间戳
      --wait                         等待服务运行|健康。表示分离模式。
      --wait-timeout int             等待项目运行|健康的最长时间（以秒为单位）
  -w, --watch                        文件更新时监视源代码并重建/刷新容器。
  -y, --yes                          假设所有提示的答案都是“是”并以非交互方式运行
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose version

**用途**：显示 Docker Compose 版本信息

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_version](https://telepresence.io/docs/reference/cli/telepresence_compose_version)

### 用法
```
  telepresence compose version [flags] [services]
```

### 参数
```
  -h, --help   version 帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose version 参数
```
  -f, --format string   格式化输出。 Values: [pretty | json]. (Default: pretty)
      --short           仅显示 Compose 的版本号
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose volumes

**用途**：列出卷

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_volumes](https://telepresence.io/docs/reference/cli/telepresence_compose_volumes)

### 用法
```
  telepresence compose volumes [flags] [services]
```

### 参数
```
  -h, --help   卷帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose volumes 参数
```
      --format string   使用自定义模板设置输出格式： 'table'：以带有列标题的表格格式打印输出（默认） 'table TEMPLATE'：使用给定的 Go 模板以表格格式打印输出 'json'：以 JSON 格式打印 'TEMPLATE'：使用给定的 Go 模板打印输出。有关使用模板（默认“表格”）格式化输出的更多信息，请参阅https://docs.docker.com/go/formatting/
  -q, --quiet           仅显示卷名
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose wait

**用途**：阻塞等待全部或指定服务的容器停止。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_wait](https://telepresence.io/docs/reference/cli/telepresence_compose_wait)

### 用法
```
  telepresence compose wait [flags] [services]
```

### 参数
```
  -h, --help   帮助等待
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose wait 参数
```
      --down-project   当第一个容器停止时删除项目
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence compose watch

**用途**：监视服务的构建上下文，并在文件更新时重新构建或刷新容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_compose_watch](https://telepresence.io/docs/reference/cli/telepresence_compose_watch)

### 用法
```
  telepresence compose watch [flags] [services]
```

### 参数
```
  -h, --help   手表帮助
```

### Compose 参数
```
      --env-file stringArray       可选的环境变量文件
  -f, --file stringArray           Compose 配置文件
      --profile stringArray        要启用的 profile
      --project-directory string   指定备用工作目录（默认：第一个指定的Compose文件的路径）
      --project-name string        项目名称
```

### Compose watch 参数
```
      --no-up   观看前请勿构建和启动服务
      --prune   重建时修剪悬挂图像（默认 true）
      --quiet   隐藏构建输出
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence config

**用途**：Telepresence 配置命令

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_config](https://telepresence.io/docs/reference/cli/telepresence_config)

### 用法
```
  telepresence config [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [view](telepresence_config_view) | 查看当前 Telepresence 配置 |

### 参数
```
  -h, --help   配置帮助
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看`telepresence config [command] --help`。

## telepresence config view

**用途**：查看当前 Telepresence 配置

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_config_view](https://telepresence.io/docs/reference/cli/telepresence_config_view)

### 用法
```
  telepresence config view [flags]
```

### 参数
```
  -c, --client-only   仅从客户端文件查看配置。
  -h, --help          帮助查看
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence connect

**用途**：连接到集群

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_connect](https://telepresence.io/docs/reference/cli/telepresence_connect)

### 用法
```
  telepresence connect [flags] [-- <command to run while connected>]
```

### 参数
```
      --allow-conflicting-subnets strings   允许与本地子网冲突的 CIDR 的逗号分隔列表
      --also-proxy strings                  用于代理的 CIDR 的附加逗号分隔列表
      --docker                              启动或连接到 docker 容器中的daemon
      --expose stringArray                  容器化 daemon将公开的端口。请参阅 docker run -p 了解更多信息。可以重复
  -h, --help                                帮助连接
      --hostname string                     容器化 daemon使用的主机名
      --manager-namespace string            要在其中查找 traffic-manager的 namespace。覆盖配置中设置的任何其他管理器namespace
      --mapped-namespaces strings           DNS 解析器和 NAT 考虑的出站连接的 namespace 的逗号分隔列表。默认为所有 namespace
      --name string                         用于连接的可选名称
  -n, --namespace string                    如果存在，则此 CLI 请求的 namespace 范围
      --never-proxy strings                 逗号分隔的 CIDR 列表，从不代理
      --proxy-via strings                   使用网络地址转换为给定的 CIDR 创建虚拟 IP，并通过 WORKLOAD进行路由。格式必须为 CIDR=WORKLOAD。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
      --reroute-local strings               将localhost上的端口重新路由到远程主机。格式为<local port>:<host>:<port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --reroute-remote strings              重新路由远程主机上的端口。格式为<host>:<port>:<new port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --vnat strings                        使用网络地址转换为给定的 CIDR 创建虚拟 IP。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API server 的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence curl

**用途**：使用 daemon 网络执行 curl

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_curl](https://telepresence.io/docs/reference/cli/telepresence_curl)

### 用法
```
  telepresence curl
```

### 参数
```
  -h, --help   帮助卷曲
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence docker-run

**用途**：使用 daemon 网络执行 docker run

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_docker-run](https://telepresence.io/docs/reference/cli/telepresence_docker-run)

### 用法
```
  telepresence docker-run
```

### 参数
```
  -h, --help   docker 运行帮助
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence gather-logs

**用途**：收集 traffic-manager、traffic-agent、用户 daemon 和 root daemon 的日志，并导出为 zip 文件。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_gather-logs](https://telepresence.io/docs/reference/cli/telepresence_gather-logs)

### 概要

从traffic-manager、traffic-agent、用户和root daemon收集日志，
并将它们导出到 zip 文件中。如果您要打开 Github 问题或询问，这很有用
有人帮助您调试Telepresence。

### 用法
```
  telepresence gather-logs [flags]
```

### 示例
```
下面是几个使用该命令的示例：
# 获取所有日志并导出到给定文件
telepresence gather-logs -o /tmp/telepresence_logs.zip

# 获取 kubernetes 集群中组件的所有日志和 pod yaml 清单
telepresence gather-logs -o /tmp/telepresence_logs.zip --get-pod-yaml

# 仅获取daemon的所有日志
telepresence gather-logs --traffic-agents=None --traffic-manager=False

# 获取名称中包含“echo-easy”的 Pod 的所有日志，如果您有多个副本，则非常有用
telepresence gather-logs --traffic-manager=False --traffic-agents=echo-easy

# 获取特定 Pod 的所有日志
telepresence gather-logs --traffic-manager=False --traffic-agents=echo-easy-6848967857-tw4jw

# 从除daemon之外的所有内容获取日志
telepresence gather-logs --daemons=None

```

### 参数
```
  -a, --anonymize               对日志中的 Pod 名称 + namespace进行匿名化
      --daemons string          您想要日志的daemon的逗号分隔列表：all、root、user、kubeauth、None（默认“all”）
  -y, --get-pod-yaml            获取您正在获取其日志的任何 Pod 的 yaml
  -h, --help                    收集日志的帮助
  -o, --output-file string      您要将日志输出到的文件。
      --traffic-agents string   用于收集日志的traffic-agent：全部、名称子字符串、无（默认“全部”）
      --traffic-manager         如果你想从traffic-manager收集日志（默认 true）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence genyaml

**用途**：生成可用于 Kubernetes manifest 的 YAML。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_genyaml](https://telepresence.io/docs/reference/cli/telepresence_genyaml)

### 概要

生成traffic-agent yaml 以在 kubernetes 清单中使用。
这允许将traffic-agent手动注入到现有的 kubernetes 清单中。
为了使修改后的工作负载有效，您必须手动注入注释，
容器，以及工作负载中的卷；你可以通过运行“genyaml config”来做到这一点，
“genyaml 容器”、“genyaml initcontainer”、“genyaml 注释”和“genyaml 卷”。

NOTE：除非绝对必要，否则建议您不要这样做。相反，我们建议让
telepresence 的 webhook 注入器按需配置traffic-agent。

### 用法
```
  telepresence genyaml [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [annotations](telepresence_genyaml_annotations) | 生成 Pod 模板 metadata annotations 的 YAML。 |
| [config](telepresence_genyaml_config) | 生成 telepresence-agents ConfigMap 中 agent 条目的 YAML。 |
| [container](telepresence_genyaml_container) | 生成 traffic-agent 容器的 YAML。 |
| [initcontainer](telepresence_genyaml_initcontainer) | 生成 traffic-agent init 容器的 YAML。 |
| [volume](telepresence_genyaml_volume) | 生成 traffic-agent 卷的 YAML。 |

### 参数
```
  -h, --help            帮助 genyaml
  -o, --output string   放置输出的文件的路径。默认为“-”，表示标准输出。 （默认 ”-”）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看`telepresence genyaml [command] --help`。

## telepresence genyaml annotations

**用途**：生成 Pod 模板 metadata annotations 的 YAML。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_genyaml_annotations](https://telepresence.io/docs/reference/cli/telepresence_genyaml_annotations)

### 概要

为 Pod 模板元数据注释生成 YAML。有关这意味着什么的更多信息，请参阅 genyaml

### 用法
```
  telepresence genyaml annotations [flags]
```

### 参数
```
  -a, --agent string    包含生成的代理配置的 yaml 的路径
  -h, --help            注释帮助
  -o, --output string   放置输出的文件的路径。默认为“-”，表示标准输出。 （默认 ”-”）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence genyaml config

**用途**：生成 telepresence-agents ConfigMap 中 agent 条目的 YAML。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_genyaml_config](https://telepresence.io/docs/reference/cli/telepresence_genyaml_config)

### 概要

为远程呈现代理配置映射中的代理条目生成 YAML。有关这意味着什么的更多信息，请参阅 genyaml

### 用法
```
  telepresence genyaml config [flags]
```

### 参数
```
      --agent-image string         代理映像的限定名称（默认“ghcr.io/telepresenceio/tel2:<current version>”）
      --agent-port uint16          您希望代理侦听的端口号。 （默认9900）
  -h, --help                       配置帮助
  -i, --input string               包含工作负载定义（即 Deployment、StatefulSet 等）的 yaml 路径。对标准输入传递“-”。与 --workload 互斥
      --loglevel                   生成的traffic-agent sidecar 的日志级别（默认INFO）
      --manager-namespace string   traffic-managernamespace（默认“ambassador”）
      --manager-port uint16        traffic-managerAPI端口（默认8081）
  -n, --namespace string           如果存在，则此 CLI 请求的 namespace 范围
  -o, --output string              放置输出的文件的路径。默认为“-”，表示标准输出。 （默认 ”-”）
  -w, --workload string            工作负载的名称。如果给定，将从集群中检索工作负载，与 --input 互斥
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence genyaml container

**用途**：生成 traffic-agent 容器的 YAML。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_genyaml_container](https://telepresence.io/docs/reference/cli/telepresence_genyaml_container)

### 概要

为traffic-agent容器生成YAML。有关这意味着什么的更多信息，请参阅 genyaml

### 用法
```
  telepresence genyaml container [flags]
```

### 参数
```
  -a, --agent string       包含生成的代理配置的 yaml 的路径
  -h, --help               容器帮助
  -i, --input string       包含工作负载定义（即 Deployment、StatefulSet 等）的 yaml 的可选路径。将“-”传递给标准输入。默认从集群加载
  -n, --namespace string   如果存在，则此 CLI 请求的 namespace 范围
  -o, --output string      放置输出的文件的路径。默认为“-”，表示标准输出。 （默认 ”-”）
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence genyaml initcontainer

**用途**：生成 traffic-agent init 容器的 YAML。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_genyaml_initcontainer](https://telepresence.io/docs/reference/cli/telepresence_genyaml_initcontainer)

### 概要

为traffic-agent初始化容器生成YAML。有关这意味着什么的更多信息，请参阅 genyaml

### 用法
```
  telepresence genyaml initcontainer [flags]
```

### 参数
```
  -a, --agent string       包含生成的代理配置的 yaml 的路径
  -h, --help               initcontainer 的帮助
  -n, --namespace string   如果存在，则此 CLI 请求的 namespace 范围
  -o, --output string      放置输出的文件的路径。默认为“-”，表示标准输出。 （默认 ”-”）
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence genyaml volume

**用途**：生成 traffic-agent 卷的 YAML。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_genyaml_volume](https://telepresence.io/docs/reference/cli/telepresence_genyaml_volume)

### 概要

为traffic-agent量生成 YAML。有关这意味着什么的更多信息，请参阅 genyaml

### 用法
```
  telepresence genyaml volume [flags]
```

### 参数
```
  -a, --agent string       包含生成的代理配置的 yaml 的路径
  -h, --help               音量帮助
  -i, --input string       包含工作负载定义（即 Deployment、StatefulSet 等）的 yaml 的可选路径。将“-”传递给标准输入。默认从集群加载
  -n, --namespace string   如果存在，则此 CLI 请求的 namespace 范围
  -o, --output string      放置输出的文件的路径。默认为“-”，表示标准输出。 （默认 ”-”）
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence helm

**用途**：使用内置 Telepresence Helm chart 的 Helm 命令。

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_helm](https://telepresence.io/docs/reference/cli/telepresence_helm)

### 用法
```
  telepresence helm [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [install](telepresence_helm_install) | 安装 Telepresence traffic manager |
| [lint](telepresence_helm_lint) | 验证内置 Telepresence Helm chart |
| [uninstall](telepresence_helm_uninstall) | 卸载 Telepresence traffic manager |
| [upgrade](telepresence_helm_upgrade) | 升级 Telepresence traffic manager |
| [version](telepresence_helm_version) | 打印 Helm 客户端版本 |

### 参数
```
  -h, --help   帮助Helm
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看`telepresence helm [command] --help`。

## telepresence helm install

**用途**：安装 Telepresence traffic manager

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_helm_install](https://telepresence.io/docs/reference/cli/telepresence_helm_install)

### 用法
```
  telepresence helm install [flags]
```

### 参数
```
      --allow-conflicting-subnets strings   允许与本地子网冲突的 CIDR 的逗号分隔列表
      --also-proxy strings                  用于代理的 CIDR 的附加逗号分隔列表
      --create-namespace                    如果不存在，则为traffic-manager创建一个namespace（默认 true）
      --docker                              启动或连接到 docker 容器中的daemon
      --expose stringArray                  容器化 daemon将公开的端口。请参阅 docker run -p 了解更多信息。可以重复
  -h, --help                                安装帮助
      --hostname string                     容器化 daemon使用的主机名
      --manager-namespace string            要在其中查找 traffic-manager的 namespace。覆盖配置中设置的任何其他管理器namespace
      --mapped-namespaces strings           DNS 解析器和 NAT 考虑的出站连接的 namespace 的逗号分隔列表。默认为所有 namespace
      --name string                         用于连接的可选名称
  -n, --namespace string                    如果存在，则此 CLI 请求的 namespace 范围
      --never-proxy strings                 逗号分隔的 CIDR 列表，从不代理
      --no-hooks                            防止钩子在安装过程中运行
      --proxy-via strings                   使用网络地址转换为给定的 CIDR 创建虚拟 IP，并通过 WORKLOAD进行路由。格式必须为 CIDR=WORKLOAD。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
      --reroute-local strings               将localhost上的端口重新路由到远程主机。格式为<local port>:<host>:<port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --reroute-remote strings              重新路由远程主机上的端口。格式为<host>:<port>:<new port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --set stringArray                     将值指定为 a.b=v（可以用逗号指定多个或单独的值：a.b=v1,a.c=v2）
      --set-file stringArray                设置通过命令行指定的各个文件的值（可以用逗号指定多个或单独的值：key1=path1,key2=path2）
      --set-json stringArray                在命令行上设置JSON值（可以用逗号指定多个或单独的值：a.b=jsonval1,a.c=jsonval2）
      --set-string stringArray              在命令行上设置STRING值（可以用逗号指定多个或单独的值：a.b=val1,a.c=val2）
  -f, --values stringArray                  指定 YAML 文件或 URL 中的值（可以指定多个）
      --version string                      如果与客户端版本不同，则为智真版本。可能是一个范围（例如 ^2.21.0）
      --vnat strings                        使用网络地址转换为给定的 CIDR 创建虚拟 IP。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence helm lint

**用途**：验证内置 Telepresence Helm chart

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_helm_lint](https://telepresence.io/docs/reference/cli/telepresence_helm_lint)

### 用法
```
  telepresence helm lint [flags]
```

### 参数
```
      --allow-conflicting-subnets strings   允许与本地子网冲突的 CIDR 的逗号分隔列表
      --also-proxy strings                  用于代理的 CIDR 的附加逗号分隔列表
      --docker                              启动或连接到 docker 容器中的daemon
      --expose stringArray                  容器化 daemon将公开的端口。请参阅 docker run -p 了解更多信息。可以重复
  -h, --help                                帮助 lint
      --hostname string                     容器化 daemon使用的主机名
      --manager-namespace string            要在其中查找 traffic-manager的 namespace。覆盖配置中设置的任何其他管理器namespace
      --mapped-namespaces strings           DNS 解析器和 NAT 考虑的出站连接的 namespace 的逗号分隔列表。默认为所有 namespace
      --name string                         用于连接的可选名称
  -n, --namespace string                    如果存在，则此 CLI 请求的 namespace 范围
      --never-proxy strings                 逗号分隔的 CIDR 列表，从不代理
      --proxy-via strings                   使用网络地址转换为给定的 CIDR 创建虚拟 IP，并通过 WORKLOAD进行路由。格式必须为 CIDR=WORKLOAD。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
      --reroute-local strings               将localhost上的端口重新路由到远程主机。格式为<local port>:<host>:<port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --reroute-remote strings              重新路由远程主机上的端口。格式为<host>:<port>:<new port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --set stringArray                     将值指定为 a.b=v（可以用逗号指定多个或单独的值：a.b=v1,a.c=v2）
      --set-file stringArray                设置通过命令行指定的各个文件的值（可以用逗号指定多个或单独的值：key1=path1,key2=path2）
      --set-json stringArray                在命令行上设置JSON值（可以用逗号指定多个或单独的值：a.b=jsonval1,a.c=jsonval2）
      --set-string stringArray              在命令行上设置STRING值（可以用逗号指定多个或单独的值：a.b=val1,a.c=val2）
  -f, --values stringArray                  指定 YAML 文件或 URL 中的值（可以指定多个）
      --version string                      如果与客户端版本不同，则为智真版本。可能是一个范围（例如 ^2.21.0）
      --vnat strings                        使用网络地址转换为给定的 CIDR 创建虚拟 IP。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence helm uninstall

**用途**：卸载 Telepresence traffic manager

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_helm_uninstall](https://telepresence.io/docs/reference/cli/telepresence_helm_uninstall)

### 用法
```
  telepresence helm uninstall [flags]
```

### 参数
```
      --allow-conflicting-subnets strings   允许与本地子网冲突的 CIDR 的逗号分隔列表
      --also-proxy strings                  用于代理的 CIDR 的附加逗号分隔列表
      --docker                              启动或连接到 docker 容器中的daemon
      --expose stringArray                  容器化 daemon将公开的端口。请参阅 docker run -p 了解更多信息。可以重复
  -h, --help                                卸载帮助
      --hostname string                     容器化 daemon使用的主机名
      --manager-namespace string            要在其中查找 traffic-manager的 namespace。覆盖配置中设置的任何其他管理器namespace
      --mapped-namespaces strings           DNS 解析器和 NAT 考虑的出站连接的 namespace 的逗号分隔列表。默认为所有 namespace
      --name string                         用于连接的可选名称
  -n, --namespace string                    如果存在，则此 CLI 请求的 namespace 范围
      --never-proxy strings                 逗号分隔的 CIDR 列表，从不代理
      --no-hooks                            防止卸载期间运行挂钩
      --proxy-via strings                   使用网络地址转换为给定的 CIDR 创建虚拟 IP，并通过 WORKLOAD进行路由。格式必须为 CIDR=WORKLOAD。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
      --reroute-local strings               将localhost上的端口重新路由到远程主机。格式为<local port>:<host>:<port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --reroute-remote strings              重新路由远程主机上的端口。格式为<host>:<port>:<new port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --vnat strings                        使用网络地址转换为给定的 CIDR 创建虚拟 IP。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence helm upgrade

**用途**：升级 Telepresence traffic manager

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_helm_upgrade](https://telepresence.io/docs/reference/cli/telepresence_helm_upgrade)

### 用法
```
  telepresence helm upgrade [flags]
```

### 参数
```
      --allow-conflicting-subnets strings   允许与本地子网冲突的 CIDR 的逗号分隔列表
      --also-proxy strings                  用于代理的 CIDR 的附加逗号分隔列表
      --create-namespace                    如果不存在则创建发布名称空间（默认 true）
      --docker                              启动或连接到 docker 容器中的daemon
      --expose stringArray                  容器化 daemon将公开的端口。请参阅 docker run -p 了解更多信息。可以重复
  -h, --help                                帮助升级
      --hostname string                     容器化 daemon使用的主机名
      --manager-namespace string            要在其中查找 traffic-manager的 namespace。覆盖配置中设置的任何其他管理器namespace
      --mapped-namespaces strings           DNS 解析器和 NAT 考虑的出站连接的 namespace 的逗号分隔列表。默认为所有 namespace
      --name string                         用于连接的可选名称
  -n, --namespace string                    如果存在，则此 CLI 请求的 namespace 范围
      --never-proxy strings                 逗号分隔的 CIDR 列表，从不代理
      --no-hooks                            禁用升级前/升级后挂钩
      --proxy-via strings                   使用网络地址转换为给定的 CIDR 创建虚拟 IP，并通过 WORKLOAD进行路由。格式必须为 CIDR=WORKLOAD。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
      --reroute-local strings               将localhost上的端口重新路由到远程主机。格式为<local port>:<host>:<port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --reroute-remote strings              重新路由远程主机上的端口。格式为<host>:<port>:<new port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --reset-values                        升级时，将值重置为图表中内置的值
      --reuse-values                        升级时，重用上一个版本的值并通过 --set 和 -f 从命令行合并任何覆盖
      --set stringArray                     将值指定为 a.b=v（可以用逗号指定多个或单独的值：a.b=v1,a.c=v2）
      --set-file stringArray                设置通过命令行指定的各个文件的值（可以用逗号指定多个或单独的值：key1=path1,key2=path2）
      --set-json stringArray                在命令行上设置JSON值（可以用逗号指定多个或单独的值：a.b=jsonval1,a.c=jsonval2）
      --set-string stringArray              在命令行上设置STRING值（可以用逗号指定多个或单独的值：a.b=val1,a.c=val2）
  -f, --values stringArray                  指定 YAML 文件或 URL 中的值（可以指定多个）
      --version string                      如果与客户端版本不同，则为智真版本。可能是一个范围（例如 ^2.21.0）
      --vnat strings                        使用网络地址转换为给定的 CIDR 创建虚拟 IP。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence helm version

**用途**：打印 Helm 客户端版本

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_helm_version](https://telepresence.io/docs/reference/cli/telepresence_helm_version)

### 用法
```
  telepresence helm version [flags]
```

### 参数
```
  -h, --help   版本帮助
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence ingest

**用途**：接入一个容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_ingest](https://telepresence.io/docs/reference/cli/telepresence_ingest)

### 用法
```
  telepresence ingest [flags] <name> [-- [[docker run flags] <image name>] OR [<command>]] args...]
```

### 参数
```
  -c, --container string               为接入提供环境和挂载的容器名称
      --docker-build string            从给定的 docker-context（路径或 URL）构建一个 Docker 容器，并使用接入的环境和卷挂载来运行它，方法是将 -- 之后的参数传递给“docker run”，例如'--docker-build /path/to/docker/context -- -it IMAGE /bin/bash'
      --docker-build-opt stringArray   docker-build 的选项采用 key=value 的形式，例如 --docker-build-opt tag=mytag。
      --docker-debug string            与 --docker-build 类似，但允许调试器以宽松的安全性在容器内运行
      --docker-mount string            docker 中的卷挂载点。默认与“--mount”相同
      --docker-run                     通过将 -- 之后的参数传递给“docker run”，运行具有接入环境、卷挂载的 Docker 容器，例如'--docker-run -- -it --rm ubuntu:20.04 /bin/bash'
  -e, --env-file string                还将远程环境发送到文件。文件中使用的语法可以使用标志 --env-syntax 确定
  -j, --env-json string                还将远程环境作为 JSON blob 发送到文件。
      --env-syntax string              用于 env 文件的语法。 “docker”、“compose”、“sh”、“csh”、“cmd”、“json”和“ps”之一；其中“sh”、“csh”和“ps”可以添加后缀“:export”（默认为“docker”）
  -h, --help                           帮助接入
      --local-mount-port uint16        不要挂载远程目录。相反，将localhost上的此端口公开给外部挂载器
      --mount string                   将挂载卷的根目录的绝对路径，$TELEPRESENCE_ROOT。使用“true”让 Telepresence 选择一个随机挂载点（默认）。使用“false”完全禁用文件系统挂载。 （默认“true”）
      --to-pod strings                 从接入的 Pod 转发的附加端口将在 localhost 上提供：PORT 使用此端口，例如，访问接入的 Pod 中的代理/辅助边车。默认协议是TCP。对 UDP 端口使用 <port>/UDP
      --wait-message string            接入处理程序启动时打印的消息
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence intercept

**用途**：拦截一个服务

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_intercept](https://telepresence.io/docs/reference/cli/telepresence_intercept)

### 用法
```
  telepresence intercept [flags] <name> [-- [[docker run flags] <image name>] OR [<command>]] args...]
```

### 参数
```
      --address string                 要转发到的本地地址，例如'--address 10.0.0.2'（默认“127.0.0.1”或容器名称）
      --container string               为拦截提供环境和安装的容器的名称。默认为与第一个拦截端口匹配的容器。
      --detailed-output                与 --output=json 或 --output=yaml' 一起使用时提供有关拦截的非常详细的信息
      --docker-build string            从给定的 docker-context（路径或 URL）构建 Docker 容器，并使用拦截的环境和卷挂载来运行它，方法是将 -- 之后的参数传递给“docker run”，例如'--docker-build /path/to/docker/context -- -it IMAGE /bin/bash'
      --docker-build-opt stringArray   docker-build 的选项采用 key=value 的形式，例如 --docker-build-opt tag=mytag。
      --docker-debug string            与 --docker-build 类似，但允许调试器以宽松的安全性在容器内运行
      --docker-mount string            docker 中的卷挂载点。默认与“--mount”相同
      --docker-run                     通过将 -- 之后的参数传递给“docker run”，运行具有拦截环境、卷挂载的 Docker 容器，例如'--docker-run -- -it --rm ubuntu:20.04 /bin/bash'
  -e, --env-file string                还将远程环境发送到文件。文件中使用的语法可以使用标志 --env-syntax 确定
  -j, --env-json string                还将远程环境作为 JSON blob 发送到文件。
      --env-syntax string              用于 env 文件的语法。 “docker”、“compose”、“sh”、“csh”、“cmd”、“json”和“ps”之一；其中“sh”、“csh”和“ps”可以添加后缀“:export”（默认为“docker”）
  -h, --help                           帮助拦截
      --http-header strings            HTTP Header过滤器。只有具有匹配Header的请求才会被拦截。支持两种格式：--http-header“X-User-ID=dev123”或--http-header“X-User-ID:dev123”（curl -H 兼容）。多个 Header使用AND 逻辑。
      --http-path-equal strings        HTTP 路径过滤器。只有具有匹配路径的请求才会被拦截。精确的路径匹配。
      --http-path-prefix strings       HTTP 路径前缀过滤器。只有具有匹配路径前缀的请求才会被拦截。
      --http-path-regex strings        HTTP 路径正则表达式过滤器。只有路径与正则表达式匹配的请求才会被拦截。
      --local-mount-port uint16        不要挂载远程目录。相反，将localhost上的此端口公开给外部挂载器
      --mechanism mechanism            使用哪种扩展机制（默认“tcp”）
      --metadata strings               要附加到拦截的元数据。使用 --metadata key=value 设置单个键/值对，或使用 --metadata key1=value1 --metadata key2=value2 设置多个键/值对。可以使用 Telepresence API 服务器检索元数据。
      --mount string                   将挂载卷的根目录的绝对路径，$TELEPRESENCE_ROOT。使用“true”让 Telepresence 选择一个随机挂载点（默认）。使用“false”完全禁用文件系统挂载。附加“:ro”以只读方式挂载所有内容。 （默认“true”）
  -n, --namespace string               包含要拦截的工作负载的 namespace。默认为连接的 namespace
      --plaintext                      与拦截处理程序通信时使用纯文本而不是 TLS
  -p, --port strings                   要转发到的本地端口。使用 <local port>:<identifier>唯一标识服务端口，其中 <identifier>是端口名称或编号。对于 --docker-run 和不在 docker 中运行的daemon，请使用 <local port>:<container port> 或 <local port>:<container port>:<identifier>。
      --replace                        指示traffic-agent是否应替换工作负载 Pod 中的应用程序容器。默认行为是代理 sidecar 与现有容器一起安装。 （DEPRECATED：使用替换命令。）
      --service string                 要拦截的服务的可选名称。有时需要唯一标识被拦截的端口。
      --to-pod strings                 用于转发到拦截的 Pod 的其他端口将可用于连接到localhost：PORT。例如，使用它来访问被拦截的 pod 中的代理/辅助 sidecar。默认协议是TCP。对 UDP 端口使用 <port>/UDP
      --wait-message string            拦截处理程序启动时打印的消息
  -w, --workload string                要拦截的工作负载名称（Deployment、ReplicaSet、StatefulSet、Rollout）（如果与 <name> 不同）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence leave

**用途**：移除现有拦截

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_leave](https://telepresence.io/docs/reference/cli/telepresence_leave)

### 用法
```
  telepresence leave [flags] <intercept_name>
```

### 参数
```
  -c, --container string   集装箱名称
  -h, --help               帮助请假
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence list-contexts

**用途**：显示所有 context

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_list-contexts](https://telepresence.io/docs/reference/cli/telepresence_list-contexts)

### 用法
```
  telepresence list-contexts [flags]
```

### 参数
```
      --allow-conflicting-subnets strings   允许与本地子网冲突的 CIDR 的逗号分隔列表
      --also-proxy strings                  用于代理的 CIDR 的附加逗号分隔列表
      --docker                              启动或连接到 docker 容器中的daemon
      --expose stringArray                  容器化 daemon将公开的端口。请参阅 docker run -p 了解更多信息。可以重复
  -h, --help                                列表上下文的帮助
      --hostname string                     容器化 daemon使用的主机名
      --manager-namespace string            要在其中查找 traffic-manager的 namespace。覆盖配置中设置的任何其他管理器namespace
      --mapped-namespaces strings           DNS 解析器和 NAT 考虑的出站连接的 namespace 的逗号分隔列表。默认为所有 namespace
      --name string                         用于连接的可选名称
  -n, --namespace string                    如果存在，则此 CLI 请求的 namespace 范围
      --never-proxy strings                 逗号分隔的 CIDR 列表，从不代理
      --proxy-via strings                   使用网络地址转换为给定的 CIDR 创建虚拟 IP，并通过 WORKLOAD进行路由。格式必须为 CIDR=WORKLOAD。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
      --reroute-local strings               将localhost上的端口重新路由到远程主机。格式为<local port>:<host>:<port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --reroute-remote strings              重新路由远程主机上的端口。格式为<host>:<port>:<new port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --vnat strings                        使用网络地址转换为给定的 CIDR 创建虚拟 IP。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence list-namespaces

**用途**：显示所有 namespace

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_list-namespaces](https://telepresence.io/docs/reference/cli/telepresence_list-namespaces)

### 用法
```
  telepresence list-namespaces [flags]
```

### 参数
```
      --allow-conflicting-subnets strings   允许与本地子网冲突的 CIDR 的逗号分隔列表
      --also-proxy strings                  用于代理的 CIDR 的附加逗号分隔列表
      --docker                              启动或连接到 docker 容器中的daemon
      --expose stringArray                  容器化 daemon将公开的端口。请参阅 docker run -p 了解更多信息。可以重复
  -h, --help                                列表namespace 的帮助
      --hostname string                     容器化 daemon使用的主机名
      --manager-namespace string            要在其中查找 traffic-manager的 namespace。覆盖配置中设置的任何其他管理器namespace
      --mapped-namespaces strings           DNS 解析器和 NAT 考虑的出站连接的 namespace 的逗号分隔列表。默认为所有 namespace
      --name string                         用于连接的可选名称
  -n, --namespace string                    如果存在，则此 CLI 请求的 namespace 范围
      --never-proxy strings                 逗号分隔的 CIDR 列表，从不代理
      --proxy-via strings                   使用网络地址转换为给定的 CIDR 创建虚拟 IP，并通过 WORKLOAD进行路由。格式必须为 CIDR=WORKLOAD。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
      --reroute-local strings               将localhost上的端口重新路由到远程主机。格式为<local port>:<host>:<port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --reroute-remote strings              重新路由远程主机上的端口。格式为<host>:<port>:<new port>[/{tcp,udp}]。当 <host> 是服务名称时，<port> 可以是符号。
      --vnat strings                        使用网络地址转换为给定的 CIDR 创建虚拟 IP。 CIDR 可以替换符号名称“service”、“pods”、“also”或“all”。
```

### Kubernetes 参数
```
      --as string                      用于模拟操作的用户名。用户可以是namespace中的普通用户或ServiceAccount。
      --as-group stringArray           模拟组进行操作，可以重复该标志来指定多个组。
      --as-uid string                  UID 冒充进行操作。
      --as-user-extra stringArray      用户额外模拟操作，可以重复此标志以指定同一键的多个值。
      --cache-dir string               默认缓存目录（默认“$HOME/.kube/cache”）
      --certificate-authority string   证书颁发机构的证书文件的路径
      --client-certificate string      TLS 的客户端证书文件路径
      --client-key string              TLS 的客户端密钥文件路径
      --cluster string                 要使用的 kubeconfig 集群的名称
      --context string                 要使用的 kubeconfig 上下文的名称
      --disable-compression            如果为 true，则选择退出对服务器的所有请求的响应压缩
      --insecure-skip-tls-verify       如果为 true，则不会检查服务器证书的有效性。这将使你的 HTTPS连接不安全
      --kubeconfig string              用于 CLI 请求的 kubeconfig 文件的路径。
      --request-timeout string         放弃单个服务器请求之前等待的时间长度。非零值应包含相应的时间单位（例如 1s、2m、3h）。值为零意味着请求不会超时。 （默认“0”）
  -s, --server string                  Kubernetes API服务器的地址和端口
      --tls-server-name string         用于服务器证书校验的服务器名称。如果未提供，则使用连接服务器时使用的主机名
      --token string                   用于向 API 服务器进行身份验证的承载令牌
      --user string                    要使用的 kubeconfig 用户的名称
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence list

**用途**：列出当前拦截

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_list](https://telepresence.io/docs/reference/cli/telepresence_list)

### 用法
```
  telepresence list [flags]
```

### 参数
```
  -a, --agents             仅适用于已安装的代理
      --debug              包括调试信息
  -h, --help               帮助列表
  -g, --ingests            接入
  -i, --intercepts         拦截
  -n, --namespace string   如果存在，则此 CLI 请求的 namespace 范围
  -r, --replacements       替代品
  -t, --wiretaps           旁路监听
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence loglevel

**用途**：临时修改 traffic-manager、traffic-agent、用户 daemon 和 root daemon 的日志级别

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_loglevel](https://telepresence.io/docs/reference/cli/telepresence_loglevel)

### 用法
```
  telepresence loglevel <ERROR,WARN,INFO,DEBUG,TRACE> [flags]
```

### 参数
```
  -d, --duration duration   日志级别生效的时间（0s表示无限期）（默认30m0s）
  -h, --help                日志级别帮助
  -l, --local-only          只影响用户和rootdaemon
  -r, --remote-only         只影响traffic-manager和traffic-agent
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp

**用途**：MCP 服务器管理

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp](https://telepresence.io/docs/reference/cli/telepresence_mcp)

### 概要

管理 AI 助手和代码编辑器的MCP服务器

### 用法
```
  telepresence mcp [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [claude](telepresence_mcp_claude) | 管理 Claude Desktop MCP 服务器 |
| [cursor](telepresence_mcp_cursor) | 管理 Cursor MCP 服务器 |
| [start](telepresence_mcp_start) | 启动 MCP 服务器 |
| [stream](telepresence_mcp_stream) | 通过 HTTP 流式暴露 MCP 服务器 |
| [tools](telepresence_mcp_tools) | 将工具导出为 JSON |
| [vscode](telepresence_mcp_vscode) | 管理 VSCode MCP 服务器 |

### 参数
```
  -h, --help   帮助MCP
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看`telepresence mcp [command] --help`。

## telepresence mcp claude

**用途**：管理 Claude Desktop MCP 服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_claude](https://telepresence.io/docs/reference/cli/telepresence_mcp_claude)

### 概要

管理 MCP Claude 桌面的服务器配置

### 用法
```
  telepresence mcp claude [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [disable](telepresence_mcp_claude_disable) | 从 Claude 配置中移除服务器 |
| [enable](telepresence_mcp_claude_enable) | 将服务器添加到 Claude 配置 |
| [list](telepresence_mcp_claude_list) | 显示 Claude MCP 服务器 |

### 参数
```
  -h, --help   帮助Claude
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看`telepresence mcp claude [command] --help`。

## telepresence mcp claude disable

**用途**：从 Claude 配置中移除服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_claude_disable](https://telepresence.io/docs/reference/cli/telepresence_mcp_claude_disable)

### 概要

从 Claude 桌面 MCP 服务器中删除此应用程序

### 用法
```
  telepresence mcp claude disable [flags]
```

### 参数
```
      --config-path string   Claude配置文件的路径
  -h, --help                 帮助禁用
      --server-name string   要删除的 MCP 服务器的名称（default：从可执行文件名称派生）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp claude enable

**用途**：将服务器添加到 Claude 配置

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_claude_enable](https://telepresence.io/docs/reference/cli/telepresence_mcp_claude_enable)

### 概要

将此应用程序添加为 Claude 桌面中的 MCP 服务器

### 用法
```
  telepresence mcp claude enable [flags]
```

### 参数
```
      --config-path string   Claude配置文件的路径
  -e, --env stringToString   环境变量（例如，--env KEY1=value1 --env KEY2=value2）（默认 []）
  -h, --help                 帮助启用
      --log-level string     日志级别（调试、信息、警告、错误）
      --server-name string   MCP服务器的名称（默认：从可执行文件名称派生）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp claude list

**用途**：显示 Claude MCP 服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_claude_list](https://telepresence.io/docs/reference/cli/telepresence_mcp_claude_list)

### 概要

显示 Claude 桌面中配置的所有 MCP 服务器

### 用法
```
  telepresence mcp claude list [flags]
```

### 参数
```
      --config-path string   Claude配置文件的路径
  -h, --help                 帮助列表
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp cursor

**用途**：管理 Cursor MCP 服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_cursor](https://telepresence.io/docs/reference/cli/telepresence_mcp_cursor)

### 概要

管理 MCP Cursor 的服务器配置

### 用法
```
  telepresence mcp cursor [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [disable](telepresence_mcp_cursor_disable) | 从 Cursor 配置中移除服务器 |
| [enable](telepresence_mcp_cursor_enable) | 将服务器添加到 Cursor 配置 |
| [list](telepresence_mcp_cursor_list) | 显示 Cursor MCP 服务器 |

### 参数
```
  -h, --help   Cursor帮助
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看`telepresence mcp cursor [command] --help`。

## telepresence mcp cursor disable

**用途**：从 Cursor 配置中移除服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_cursor_disable](https://telepresence.io/docs/reference/cli/telepresence_mcp_cursor_disable)

### 概要

从 Cursor MCP 服务器中删除此应用程序

### 用法
```
  telepresence mcp cursor disable [flags]
```

### 参数
```
      --config-path string   Cursor配置文件的路径
  -h, --help                 帮助禁用
      --server-name string   要删除的 MCP 服务器的名称（default：从可执行文件名称派生）
      --workspace            从工作区设置 (.cursor/mcp.json) 中删除而不是从用户设置中删除
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp cursor enable

**用途**：将服务器添加到 Cursor 配置

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_cursor_enable](https://telepresence.io/docs/reference/cli/telepresence_mcp_cursor_enable)

### 概要

将此应用程序添加为 Cursor 中的 MCP 服务器

### 用法
```
  telepresence mcp cursor enable [flags]
```

### 参数
```
      --config-path string   Cursor配置文件的路径
  -e, --env stringToString   环境变量（例如，--env KEY1=value1 --env KEY2=value2）（默认 []）
  -h, --help                 帮助启用
      --log-level string     日志级别（调试、信息、警告、错误）
      --server-name string   MCP服务器的名称（默认：从可执行文件名称派生）
      --workspace            添加到工作区设置 (.cursor/mcp.json) 而不是用户设置
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp cursor list

**用途**：显示 Cursor MCP 服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_cursor_list](https://telepresence.io/docs/reference/cli/telepresence_mcp_cursor_list)

### 概要

显示 Cursor 中配置的所有 MCP 服务器

### 用法
```
  telepresence mcp cursor list [flags]
```

### 参数
```
      --config-path string   Cursor配置文件的路径
  -h, --help                 帮助列表
      --workspace            从工作区设置 (.cursor/mcp.json) 而非用户设置列表
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp start

**用途**：启动 MCP 服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_start](https://telepresence.io/docs/reference/cli/telepresence_mcp_start)

### 概要

启动 stdio 服务器以向 AI 助手公开 CLI 命令

### 用法
```
  telepresence mcp start [flags]
```

### 参数
```
  -h, --help               帮助开始
      --log-level string   日志级别（调试、信息、警告、错误）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp stream

**用途**：通过 HTTP 流式暴露 MCP 服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_stream](https://telepresence.io/docs/reference/cli/telepresence_mcp_stream)

### 概要

启动HTTP服务器以向AI助手公开CLI命令

### 用法
```
  telepresence mcp stream [flags]
```

### 参数
```
  -h, --help               流媒体帮助
      --host string        主机收听
      --log-level string   日志级别（调试、信息、警告、错误）
      --port int           监听的端口号（默认8080）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp tools

**用途**：将工具导出为 JSON

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_tools](https://telepresence.io/docs/reference/cli/telepresence_mcp_tools)

### 概要

将可用的MCP工具导出到mcp-tools.json以供检查

### 用法
```
  telepresence mcp tools [flags]
```

### 参数
```
  -h, --help               工具帮助
      --log-level string   日志级别（调试、信息、警告、错误）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp vscode

**用途**：管理 VSCode MCP 服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_vscode](https://telepresence.io/docs/reference/cli/telepresence_mcp_vscode)

### 概要

管理 Visual Studio Code 的MCP服务器配置

### 用法
```
  telepresence mcp vscode [command] [flags]
```

### 子命令
| 命令 | 说明 |
|---------|-------------|
| [disable](telepresence_mcp_vscode_disable) | 从 VSCode 配置中移除服务器 |
| [enable](telepresence_mcp_vscode_enable) | 将服务器添加到 VSCode 配置 |
| [list](telepresence_mcp_vscode_list) | 显示 VSCode MCP 服务器 |

### 参数
```
  -h, --help   vscode 的帮助
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

更多子命令详情可查看`telepresence mcp vscode [command] --help`。

## telepresence mcp vscode disable

**用途**：从 VSCode 配置中移除服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_vscode_disable](https://telepresence.io/docs/reference/cli/telepresence_mcp_vscode_disable)

### 概要

从 VSCode MCP 服务器中删除此应用程序

### 用法
```
  telepresence mcp vscode disable [flags]
```

### 参数
```
      --config-path string   VSCode配置文件的路径
  -h, --help                 帮助禁用
      --server-name string   要删除的 MCP 服务器的名称（default：从可执行文件名称派生）
      --workspace            从工作区设置 (.vscode/mcp.json) 而非用户设置中删除
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp vscode enable

**用途**：将服务器添加到 VSCode 配置

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_vscode_enable](https://telepresence.io/docs/reference/cli/telepresence_mcp_vscode_enable)

### 概要

将此应用程序添加为 VSCode 中的 MCP 服务器

### 用法
```
  telepresence mcp vscode enable [flags]
```

### 参数
```
      --config-path string   VSCode配置文件的路径
  -e, --env stringToString   环境变量（例如，--env KEY1=value1 --env KEY2=value2）（默认 []）
  -h, --help                 帮助启用
      --log-level string     日志级别（调试、信息、警告、错误）
      --server-name string   MCP服务器的名称（默认：从可执行文件名称派生）
      --workspace            添加到工作区设置 (.vscode/mcp.json) 而不是用户设置
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence mcp vscode list

**用途**：显示 VSCode MCP 服务器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_mcp_vscode_list](https://telepresence.io/docs/reference/cli/telepresence_mcp_vscode_list)

### 概要

显示 VSCode 中配置的所有 MCP 服务器

### 用法
```
  telepresence mcp vscode list [flags]
```

### 参数
```
      --config-path string   VSCode配置文件的路径
  -h, --help                 帮助列表
      --workspace            从工作区设置 (.vscode/mcp.json) 而非用户设置列表
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence quit

**用途**：通知 Telepresence daemon 退出

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_quit](https://telepresence.io/docs/reference/cli/telepresence_quit)

### 用法
```
  telepresence quit [flags]
```

### 参数
```
  -h, --help           戒烟帮助
  -s, --stop-daemons   停止所有本地网真daemon
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence replace

**用途**：替换一个容器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_replace](https://telepresence.io/docs/reference/cli/telepresence_replace)

### 用法
```
  telepresence replace [flags] <name> [-- [[docker run flags] <image name>] OR [<command>]] args...]
```

### 参数
```
      --address string                 要转发到的本地地址，例如'--address 10.0.0.2'（默认“127.0.0.1”或容器名称）
      --container string               应更换的容器名称。如果工作负载只有一个容器，则可以省略。
      --detailed-output                与 --output=json 或 --output=yaml' 一起使用时提供有关替换的非常详细的信息
      --docker-build string            从给定的 docker-context（路径或 URL）构建 Docker 容器，并使用替换的环境和卷挂载来运行它，方法是将 -- 之后的参数传递给“docker run”，例如'--docker-build /path/to/docker/context -- -it IMAGE /bin/bash'
      --docker-build-opt stringArray   docker-build 的选项采用 key=value 的形式，例如 --docker-build-opt tag=mytag。
      --docker-debug string            与 --docker-build 类似，但允许调试器以宽松的安全性在容器内运行
      --docker-mount string            docker 中的卷挂载点。默认与“--mount”相同
      --docker-run                     通过将 -- 之后的参数传递给“docker run”，运行具有替换环境、卷挂载的 Docker 容器，例如'--docker-run -- -it --rm ubuntu:20.04 /bin/bash'
  -e, --env-file string                还将远程环境发送到文件。文件中使用的语法可以使用标志 --env-syntax 确定
  -j, --env-json string                还将远程环境作为 JSON blob 发送到文件。
      --env-syntax string              用于 env 文件的语法。 “docker”、“compose”、“sh”、“csh”、“cmd”、“json”和“ps”之一；其中“sh”、“csh”和“ps”可以添加后缀“:export”（默认为“docker”）
  -h, --help                           帮助更换
      --local-mount-port uint16        不要挂载远程目录。相反，将localhost上的此端口公开给外部挂载器
      --mount string                   将挂载卷的根目录的绝对路径，$TELEPRESENCE_ROOT。使用“true”让 Telepresence 选择一个随机挂载点（默认）。使用“false”完全禁用文件系统挂载。附加“:ro”以只读方式挂载所有内容。 （默认“true”）
  -n, --namespace string               包含要替换的工作负载的 namespace。默认为连接的 namespace
  -p, --port strings                   要转发到的本地端口。使用 <local port>:<identifier>唯一标识集装箱港口，其中 <identifier>是港口名称或编号。使用“all”（default）将替换容器中声明的所有端口转发到其相应的本地端口。  （默认[全部]）
      --to-pod strings                 用于转发到包含已替换容器的 pod 的其他端口将可用于连接到 localhost：PORT。例如，可以使用它来访问 pod 中的代理/辅助 sidecar。默认协议是TCP。对 UDP 端口使用 <port>/UDP
      --wait-message string            替换处理程序启动时打印的消息
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence revoke

**用途**：通过拦截 ID 撤销拦截。拦截 ID 的格式必须为 &lt;session_id&gt;:&lt;intercept_name&gt;

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_revoke](https://telepresence.io/docs/reference/cli/telepresence_revoke)

通过拦截 ID 撤销拦截。拦截 ID 必须采用 <session_id>:<intercept_name> 格式

### 概要

通过拦截 ID 撤销拦截。这是一项行政操作
需要 RBAC 权限才能修改“traffic-manager”配置映射。

### 用法
```
  telepresence revoke <intercept_id> [flags]
```

### 参数
```
  -h, --help   帮助撤销
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence serve

**用途**：在远程服务上启动浏览器

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_serve](https://telepresence.io/docs/reference/cli/telepresence_serve)

### 用法
```
  telepresence serve <name of remote service> [flags]
```

### 参数
```
  -h, --help          帮助发球
  -p, --port uint16   服务端口（默认80）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence status

**用途**：显示连接状态

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_status](https://telepresence.io/docs/reference/cli/telepresence_status)

### 用法
```
  telepresence status [flags]
```

### 参数
```
  -h, --help           状态帮助
      --multi-daemon   始终使用多守护程序输出格式，即使仅连接一个守护程序
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence uninstall

**用途**：卸载 Telepresence agent

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_uninstall](https://telepresence.io/docs/reference/cli/telepresence_uninstall)

### 用法
```
  telepresence uninstall [flags] <workloads...>
```

### 参数
```
  -a, --all-agents   卸载所有工作负载上的拦截代理
  -h, --help         卸载帮助
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence version

**用途**：显示版本

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_version](https://telepresence.io/docs/reference/cli/telepresence_version)

### 用法
```
  telepresence version [flags]
```

### 参数
```
  -h, --help   版本帮助
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

## telepresence wiretap

**用途**：旁路监听一个服务

**官方来源**：[https://telepresence.io/docs/reference/cli/telepresence_wiretap](https://telepresence.io/docs/reference/cli/telepresence_wiretap)

### 用法
```
  telepresence wiretap [flags] <wiretap_base_name> [-- <command with arguments...>]
```

### 参数
```
      --address string                 要转发到的本地地址，例如'--address 10.0.0.2'（默认“127.0.0.1”或容器名称）
      --container string               为旁路监听提供环境和安装的容器的名称。默认为与第一个旁路监听端口匹配的容器。
      --detailed-output                与 --output=json 或 --output=yaml' 一起使用时提供有关旁路监听的非常详细的信息
      --docker-build string            从给定的 docker-context（路径或 URL）构建 Docker 容器，并使用旁路监听环境和卷挂载来运行它，方法是将 -- 之后的参数传递给“docker run”，例如'--docker-build /path/to/docker/context -- -it IMAGE /bin/bash'
      --docker-build-opt stringArray   docker-build 的选项采用 key=value 的形式，例如 --docker-build-opt tag=mytag。
      --docker-debug string            与 --docker-build 类似，但允许调试器以宽松的安全性在容器内运行
      --docker-mount string            docker 中的卷挂载点。默认与“--mount”相同
      --docker-run                     通过在 -- 后面传递参数到“docker run”，运行具有旁路监听环境、卷挂载的 Docker 容器，例如'--docker-run -- -it --rm ubuntu:20.04 /bin/bash'
  -e, --env-file string                还将远程环境发送到文件。文件中使用的语法可以使用标志 --env-syntax 确定
  -j, --env-json string                还将远程环境作为 JSON blob 发送到文件。
      --env-syntax string              用于 env 文件的语法。 “docker”、“compose”、“sh”、“csh”、“cmd”、“json”和“ps”之一；其中“sh”、“csh”和“ps”可以添加后缀“:export”（默认为“docker”）
  -h, --help                           旁路监听帮助
      --http-header strings            HTTP Header过滤器。只有具有匹配Header的请求才会被旁路监听。支持两种格式：--http-header“X-User-ID=dev123”或--http-header“X-User-ID:dev123”（curl -H 兼容）。多个 Header使用AND 逻辑。
      --http-path-equal strings        HTTP 路径过滤器。只有具有匹配路径的请求才会被旁路监听。精确的路径匹配。
      --http-path-prefix strings       HTTP 路径前缀过滤器。只有具有匹配路径前缀的请求才会被旁路监听。
      --http-path-regex strings        HTTP 路径正则表达式过滤器。只有路径与正则表达式匹配的请求才会被旁路监听。
      --local-mount-port uint16        不要挂载远程目录。相反，将localhost上的此端口公开给外部挂载器
      --mechanism mechanism            使用哪种扩展机制（默认“tcp”）
      --mount string                   将挂载卷的根目录的绝对路径，$TELEPRESENCE_ROOT。使用“true”让 Telepresence 选择一个随机挂载点（默认）。使用“false”完全禁用文件系统挂载。附加“:ro”以只读方式挂载所有内容。 （默认“true”）
  -n, --namespace string               包含要旁路监听的工作负载的 namespace。默认为连接的 namespace
      --plaintext                      与拦截处理程序通信时使用纯文本而不是 TLS
  -p, --port strings                   要转发到的本地端口。使用 <local port>:<identifier>唯一标识服务端口，其中 <identifier>是端口名称或编号。对于 --docker-run 和不在 docker 中运行的daemon，请使用 <local port>:<container port> 或 <local port>:<container port>:<identifier>。
      --service string                 旁路监听服务的可选名称。有时需要唯一标识被拦截的端口。
      --wait-message string            旁路监听处理程序启动时打印的消息
  -w, --workload string                要旁路监听的工作负载名称（Deployment、ReplicaSet、StatefulSet、Rollout）（如果与 <name> 不同）
```

### 全局参数
```
      --config string     Telepresence 配置文件的路径（默认“$HOME/.config/telepresence/config.yml”）
      --output string     设置输出格式，支持的值为'json'、'yaml'和'default'（默认为“default”）
      --progress string   设置进度输出的类型（auto、tty、plain、json、quiet）（默认“auto”）
      --use string        用于唯一标识 daemon 容器的匹配表达式
```

