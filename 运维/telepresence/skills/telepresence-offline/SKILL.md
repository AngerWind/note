---
name: telepresence-offline
description: 在离线环境中安装 Telepresence v2 到 K8s 集群，支持 amd64/arm64 架构，通过 Harbor 镜像仓库分发镜像
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# Telepresence 离线安装 Skill

在离线 K8s 集群环境中安装 Telepresence，将本地开发机连接到远程集群，实现本地调试远程服务。

## 适用场景

- K8s 集群在离线/内网环境中，无法直接访问公网
- 需要通过 Harbor 镜像仓库分发 Telepresence 所需镜像
- 本机 Windows + 远程 Linux K8s 集群

## 前置条件

Skill 已包含所有所需资源（RPM 包、镜像包、Windows 安装包），无需用户额外下载。

### 服务器 GLIBC 版本要求

Telepresence 的 Linux 二进制对服务器 GLIBC 版本有要求，版本不匹配会导致 `telepresence` 命令无法执行（报错 `GLIBC_2.xx not found`）。

| Telepresence 版本 | 编译 Go 版本 | 最低 GLIBC 要求 | 兼容 OS |
|---|---|---|---|
| v2.14.x 及更早 | Go 1.20 | 2.17 | CentOS 7 / RHEL 7 及以上 |
| v2.15.0+ | Go 1.21+ | 2.34 | CentOS 9 / RHEL 9 / Ubuntu 22.04 及以上 |

**在步骤 2 检查 kubectl 版本时，需同时检查服务器 GLIBC 版本**：

```bash
ssh root@${SERVER_IP} "ldd --version | head -1"
```

- 如果输出 `ldd (GNU libc) 2.17`，说明是 CentOS 7 级别，**必须使用 v2.14.x** 的 RPM 和镜像
- 如果输出 `ldd (GNU libc) 2.34+`，可以使用 v2.28.0

> **注意**：不要尝试升级服务器 GLIBC，这极可能导致系统不可用。如果 GLIBC 不满足要求，应降级 Telepresence 版本。

### 资源目录结构

```
<skill目录>/
├── resources/
│   ├── amd64/
│   │   ├── docker.io_busybox_latest-amd64.tar.gz
│   │   ├── docker.io_curlimages_curl_8.1.1-amd64.tar.gz
│   │   ├── ghcr.io_telepresenceio_tel2_2.28.0-amd64.tar.gz
│   │   └── telepresence-linux-amd64.rpm
│   ├── arm64/
│   │   ├── docker.io_busybox_latest-arm64.tar.gz
│   │   ├── docker.io_curlimages_curl_8.1.1-arm64.tar.gz
│   │   ├── ghcr.io_telepresenceio_tel2_2.28.0-arm64.tar.gz
│   │   └── telepresence-linux-arm64.rpm
│   └── telepresence-windows-amd64-setup.exe
└── docs/
    ├── telepresence手动部署指导.md
    ├── telepresence-cli命令使用整理.md
    └── telepresence使用场景指南.md
```

### 必要信息

在执行前需要用户提供：
- `SERVER_IP`：目标服务器 IP 地址
- `HARBOR_URL`：Harbor 镜像仓库地址（如 `matrix-registry.h3c.com:8088`）
- `HARBOR_USER`：Harbor 用户名（默认 admin）
- `HARBOR_PASSWORD`：Harbor 密码

---

## 执行流程

### 步骤 1：检查免密 SSH 登录

测试到服务器的免密 SSH 连接：

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 root@${SERVER_IP} "echo ok"
```

**如果失败**，引导用户配置免密登录。显示公钥内容并提供命令：

```bash
# 查看本机公钥
cat ~/.ssh/id_rsa.pub

# 方式1：使用 ssh-copy-id（如果可用）
ssh-copy-id root@${SERVER_IP}

# 方式2：手动分发公钥
cat ~/.ssh/id_rsa.pub | ssh root@${SERVER_IP} "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

等待用户确认完成后，再次验证免密登录。

**如果本机没有 SSH 密钥对**，先引导用户生成：
```bash
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
```

### 步骤 2：检查 kubectl 版本

```bash
ssh root@${SERVER_IP} "kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | grep GitVersion"
```

解析版本号，判断 Major 和 Minor：
- **如果 kubectl 版本 < 1.24**：直接报错退出
  
  > 错误：当前 kubectl 版本 v{X}.{Y}.{Z} 低于 v1.24，Telepresence 不支持此版本。请升级 kubectl 到 v1.24 或更高版本。
- **如果 kubectl 版本 >= 1.24**：继续执行

### 步骤 3：检查服务器架构，选择对应资源并传输

```bash
ssh root@${SERVER_IP} "uname -m"
```

- `x86_64` → 使用 `amd64/` 目录下的资源
- `aarch64` → 使用 `arm64/` 目录下的资源
- 其他架构 → 报错退出

根据架构 SCP 传输文件到服务器：

```bash
# 以 amd64 为例
scp <skill目录>/resources/amd64/telepresence-linux-amd64.rpm root@${SERVER_IP}:/tmp/
scp <skill目录>/resources/amd64/ghcr.io_telepresenceio_tel2_2.28.0-amd64.tar.gz root@${SERVER_IP}:/tmp/
scp <skill目录>/resources/amd64/docker.io_busybox_latest-amd64.tar.gz root@${SERVER_IP}:/tmp/
scp <skill目录>/resources/amd64/docker.io_curlimages_curl_8.1.1-amd64.tar.gz root@${SERVER_IP}:/tmp/
```

### 步骤 4：RPM 安装 Telepresence

```bash
ssh root@${SERVER_IP} "rpm -ivh /tmp/telepresence-linux-*.rpm"
```

验证安装：
```bash
ssh root@${SERVER_IP} "telepresence version"
```

预期输出包含 `OSS Client : v2.28.0`。

### 步骤 5：docker load 镜像 → 打 tag → 推送 Harbor

**5.1 加载镜像：**
```bash
ssh root@${SERVER_IP} "docker load < /tmp/ghcr.io_telepresenceio_tel2_*.tar.gz"
ssh root@${SERVER_IP} "docker load < /tmp/docker.io_busybox_*.tar.gz"
ssh root@${SERVER_IP} "docker load < /tmp/docker.io_curlimages_curl_*.tar.gz"
```

**5.2 确定 Harbor tag 命名规范：**
```bash
# 查看服务器现有镜像的 tag 格式
ssh root@${SERVER_IP} "docker images --format '{{.Repository}}:{{.Tag}}' | head -5"
```

按照现有规范重新打 tag，格式为 `${HARBOR_URL}/library/<name>:<tag>`：
```bash
ssh root@${SERVER_IP} "
docker tag ghcr.io/telepresenceio/tel2:2.28.0 ${HARBOR_URL}/library/tel2:2.28.0
docker tag busybox:latest ${HARBOR_URL}/library/busybox:latest
docker tag curlimages/curl:8.1.1 ${HARBOR_URL}/library/curl:8.1.1
"
```

**5.3 登录并推送 Harbor：**
```bash
ssh root@${SERVER_IP} "docker login ${HARBOR_URL} -u ${HARBOR_USER} -p ${HARBOR_PASSWORD}"
ssh root@${SERVER_IP} "docker push ${HARBOR_URL}/library/tel2:2.28.0"
ssh root@${SERVER_IP} "docker push ${HARBOR_URL}/library/busybox:latest"
ssh root@${SERVER_IP} "docker push ${HARBOR_URL}/library/curl:8.1.1"
```

### 步骤 6：telepresence helm install

```bash
ssh root@${SERVER_IP} "telepresence helm install \
  --set image.registry=${HARBOR_URL}/library \
  --set image.name=tel2 \
  --set hooks.busybox.registry=${HARBOR_URL}/library \
  --set hooks.curl.registry=${HARBOR_URL}/library \
  --set hooks.curl.image=curl"
```

验证 Pod 状态：
```bash
ssh root@${SERVER_IP} "kubectl get pods -n ambassador"
```

预期看到 `traffic-manager-*` Pod 状态为 `Running`。

**注意**：如果 K8s 版本 < 1.24，需要额外添加 `--set` 参数替换 grpc startupProbe 为 TCP：
```bash
--set 'startupProbe.tcpSocket.port=8081' --set 'startupProbe.periodSeconds=2' --set 'startupProbe.failureThreshold=5'
```

### 步骤 7：引导用户安装 Windows Setup

**7.1 检查本机是否已安装：**
```bash
telepresence version 2>/dev/null
```

**7.2 如果未安装，告知用户：**

> 安装 Telepresence Windows 客户端前，需要先卸载旧版本的 WinFSP 和 SSHFS-Win。
>
> **原因**：Telepresence 安装程序自带兼容版本的 WinFSP 和 SSHFS-Win。旧版本会导致安装程序报错（版本冲突），无法继续安装。
>
> 卸载方式：
> - 通过 **设置 > 应用 > 已安装的应用** 搜索并卸载 WinFSP 和 SSHFS-Win
> - 或在 PowerShell 中执行：
>   ```powershell
>   Get-Package -Name "WinFSP" -ErrorAction SilentlyContinue | Uninstall-Package
>   Get-Package -Name "SSHFS-Win" -ErrorAction SilentlyContinue | Uninstall-Package
>   ```
>
> 卸载完成后，运行 skill 目录下的 `resources/telepresence-windows-amd64-setup.exe` 进行安装。

等待用户确认安装完成。

### 步骤 8：拷贝 kubeconfig 到本机

```bash
scp root@${SERVER_IP}:/etc/kubernetes/admin.conf <skill目录>/${SERVER_IP}-kubeconfig
```

命名规范：`<SERVER_IP>-kubeconfig`，例如 `10.144.183.157-kubeconfig`

### 步骤 9：修改 kubeconfig API Server 地址

将 kubeconfig 中的 `server: https://matrix-apiserver:6443` 替换为 `server: https://${SERVER_IP}:6443`。

测试连通性：
```bash
kubectl --kubeconfig <skill目录>/${SERVER_IP}-kubeconfig cluster-info
```

**如果 kubectl 连接成功但 telepresence connect 报 TLS 证书错误**：

K8s API Server 的 TLS 证书是签给 `matrix-apiserver` 主机名的，用 IP 地址连接时证书主机名不匹配。需要在 kubeconfig 文件的 cluster 配置中：

1. 去掉 `certificate-authority-data` 行（CA 证书）
2. 添加 `insecure-skip-tls-verify: true`

修改后的 cluster 配置示例：
```yaml
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://10.141.206.187:6443
  name: kubernetes
```

> 这样 telepresence 内部的 kubectl port-forward 也会自动跳过 TLS 验证。不要使用 `--insecure-skip-tls-verify` 命令行参数，因为 telepresence 不会将此参数传递给内部的 port-forward 调用。

**如果连接超时**，说明本机无法直接访问服务器 6443 端口，需要：
1. 请管理员开放 6443 端口

### 步骤 10：telepresence connect 验证

```bash
telepresence connect --kubeconfig <skill目录>/${SERVER_IP}-kubeconfig
telepresence status
```

可选：通过访问集群内 SVC 进一步验证：
```bash
# 查找有健康检查的服务
ssh root@${SERVER_IP} "kubectl get svc --all-namespaces | head -10"

# 本机通过 SVC 名称访问
curl -s http://<svc-name>.<namespace>:<port>/<health-path>
```

---

## 参考文档

Skill 目录 `docs/` 下包含以下参考文档，当用户提问相关问题时，应读取对应文档进行回答：

| 文档 | 路径 | 适用场景 |
|------|------|----------|
| telepresence手动部署指导.md | `docs/telepresence手动部署指导.md` | 用户询问离线部署的具体步骤细节、命令参数含义、某一步骤的预期输出或排错方法时，读取此文档。它记录了完整的 10 步部署流程及每步的目的、命令和预期结果。 |
| telepresence-cli命令使用整理.md | `docs/telepresence-cli命令使用整理.md` | 用户询问 Telepresence CLI 某个具体命令的用法、参数、子命令时，读取此文档。它整理了官方 CLI Reference 的 87 个命令页，包含全局参数、命令索引和每个命令的用法与参数说明。 |
| telepresence使用场景指南.md | `docs/telepresence使用场景指南.md` | 用户询问 Telepresence 的使用方式（connect/ingest/intercept/replace/wiretap 怎么选）、场景推荐、命令参数含义、Kafka 消费者调试、HTTP 联调、多人协作等使用层面问题时，读取此文档。它包含场景决策表、各模式的流量行为说明和最佳实践。 |

---

## 故障排除

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| SSH 连接超时 | 网络不通 | 检查网络/防火墙 |
| SSH 免密登录失败 | 公钥未分发 | 执行 ssh-copy-id |
| kubectl 版本过低 | < 1.24 | 升级 kubectl |
| RPM 安装冲突 | 已有旧版本 | `rpm -e telepresence` 先卸载 |
| docker login 失败 | Harbor 凭据错误 | 检查用户名密码 |
| helm install 报 grpc probe 错误 | K8s < 1.24 不支持 grpc startupProbe | 添加 `--set startupProbe.tcpSocket.port=8081` |
| Windows setup 报 WinFSP 错误 | 旧版 WinFSP 冲突 | 先卸载旧版 WinFSP 和 SSHFS-Win |
| telepresence connect TLS 错误 | kubeconfig 中 server 地址为 IP，但 K8s 证书签给主机名（如 matrix-apiserver） | 在 kubeconfig 的 cluster 配置中去掉 `certificate-authority-data`，添加 `insecure-skip-tls-verify: true` |
| telepresence connect port-forward 超时 | 服务器上 socat 缺少 libwrap.so.0 等库（glibc 升级后旧 socat 不兼容） | 在服务器上 `yum install -y socat` 安装兼容新版 glibc 的 socat |
| 本机无法访问 6443 | 防火墙限制 | 开放端口或使用 SSH 隧道 |
| SSH 隧道 TLS handshake 失败 | Windows SSH 隧道转发 TLS 数据兼容性问题 | 建议直接开放 6443 端口，避免通过 SSH 隧道 |

## 变量参考

| 变量 | 默认值 | 说明 |
|------|--------|------|
| SERVER_IP | 无（必填） | 目标服务器 IP |
| SERVER_USER | root | SSH 用户名 |
| TELEPRESENCE_VERSION | 2.28.0 | Telepresence 版本 |
| HARBOR_URL | 自动推断 | Harbor 镜像仓库地址 |
| HARBOR_USER | admin | Harbor 用户名 |
| HARBOR_PASSWORD | 无（必填） | Harbor 密码 |
| PROJECT_DIR | 当前 skill 目录路径 | 本机 skill 路径 |
