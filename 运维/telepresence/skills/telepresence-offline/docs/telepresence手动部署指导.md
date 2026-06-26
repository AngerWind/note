# Telepresence v2 离线部署指导

本文档记录在离线环境中安装 Telepresence v2.28.0 的完整步骤及对应命令。

## 环境信息

| 项目 | 值 |
|------|-----|
| 服务器 IP | 10.144.183.157 |
| 服务器系统 | NingOS V3 (x86_64) |
| K8s 版本 | v1.32.6 |
| Helm 版本 | v3.17.4 |
| Telepresence 版本 | v2.28.0 |
| Harbor 地址 | matrix-registry.h3c.com:8088 |
| Harbor 项目 | library |
| 本机系统 | Windows |

## 前置条件

- 已在可联网环境下下载好所有资源文件（RPM 包、Docker 镜像 tarball、Windows 安装程序）
- 本机可通过 SSH 连接到服务器
- 服务器上已安装 Docker、kubectl、Helm

---

## 步骤 1：检查 SSH 免密登录

**目的：** 确认本机可以通过 SSH 免密登录到服务器，后续步骤需要通过 SSH 执行远程命令和 SCP 传输文件。

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 root@10.144.183.157 "echo ok"
```

**预期输出：** `ok`

**如果失败**，说明尚未配置免密登录，需要先分发 SSH 公钥：

```bash
# 方式1：使用 ssh-copy-id
ssh-copy-id root@10.144.183.157

# 方式2：手动将公钥追加到服务器
cat ~/.ssh/id_rsa.pub | ssh root@10.144.183.157 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

> 如果本机还没有 SSH 密钥对，先执行：`ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa`

---

## 步骤 2：检查 kubectl 版本

**目的：** Telepresence 要求 kubectl 版本 >= 1.24，版本过低会导致安装失败。

```bash
ssh root@10.144.183.157 "kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | grep GitVersion"
```

**预期输出：** 版本号 >= v1.24（本次环境为 v1.32.6，满足要求）

**如果版本 < 1.24：** 需要先升级 kubectl，Telepresence 不支持低版本。

---

## 步骤 3：检查服务器架构并传输资源文件

**目的：** 确认服务器的 CPU 架构（x86_64 对应 amd64，aarch64 对应 arm64），然后上传对应的 RPM 包和镜像文件。

**3.1 检查架构：**

```bash
ssh root@10.144.183.157 "uname -m"
```

**预期输出：** `x86_64`（对应 amd64 目录下的资源）

**3.2 传输文件到服务器：**

```bash
# 上传 RPM 包
scp d:/tmp/telepresence/amd64/telepresence-linux-amd64.rpm root@10.144.183.157:/tmp/

# 上传镜像 tarball
scp d:/tmp/telepresence/amd64/ghcr.io_telepresenceio_tel2_2.28.0-amd64.tar.gz root@10.144.183.157:/tmp/
scp d:/tmp/telepresence/amd64/docker.io_busybox_latest-amd64.tar.gz root@10.144.183.157:/tmp/
scp d:/tmp/telepresence/amd64/docker.io_curlimages_curl_8.1.1-amd64.tar.gz root@10.144.183.157:/tmp/
```

> `d:/tmp/telepresence/amd64/` 为本机项目目录，根据实际路径替换。

---

## 步骤 4：RPM 安装 Telepresence

**目的：** 在服务器上安装 Telepresence 客户端二进制文件，该客户端同时包含了 `telepresence helm install` 所需的 Helm Chart。

```bash
ssh root@10.144.183.157 "rpm -ivh /tmp/telepresence-linux-amd64.rpm"
```

**验证安装：**

```bash
ssh root@10.144.183.157 "telepresence version"
```

**预期输出包含：** `OSS Client : v2.28.0`

> 如果已安装旧版本，先卸载：`ssh root@10.144.183.157 "rpm -e telepresence"`

---

## 步骤 5：加载镜像并推送到 Harbor

**目的：** 离线环境下集群无法从公网拉取镜像，需要将镜像加载到服务器的 Docker 中，打上 Harbor 的 tag 后推送，使集群能从内网 Harbor 拉取。

**5.1 加载镜像到 Docker：**

```bash
ssh root@10.144.183.157 "docker load < /tmp/ghcr.io_telepresenceio_tel2_2.28.0-amd64.tar.gz"
ssh root@10.144.183.157 "docker load < /tmp/docker.io_busybox_latest-amd64.tar.gz"
ssh root@10.144.183.157 "docker load < /tmp/docker.io_curlimages_curl_8.1.1-amd64.tar.gz"
```

**5.2 为镜像打 Harbor tag：**

```bash
ssh root@10.144.183.157 "
docker tag ghcr.io/telepresenceio/tel2:2.28.0 matrix-registry.h3c.com:8088/library/tel2:2.28.0
docker tag busybox:latest matrix-registry.h3c.com:8088/library/busybox:latest
docker tag curlimages/curl:8.1.1 matrix-registry.h3c.com:8088/library/curl:8.1.1
"
```

> tag 格式为 `<HARBOR_URL>/<项目>/<名称>:<版本>`，这里 Harbor 项目为 `library`。

**5.3 登录 Harbor 并推送镜像：**

```bash
ssh root@10.144.183.157 "docker login matrix-registry.h3c.com:8088 -u admin -p Harbor12345"
ssh root@10.144.183.157 "docker push matrix-registry.h3c.com:8088/library/tel2:2.28.0"
ssh root@10.144.183.157 "docker push matrix-registry.h3c.com:8088/library/busybox:latest"
ssh root@10.144.183.157 "docker push matrix-registry.h3c.com:8088/library/curl:8.1.1"
```

> Harbor 账号密码根据实际情况替换。

---

## 步骤 6：telepresence helm install

**目的：** 在 K8s 集群中部署 Traffic Manager（Telepresence 的服务端组件），通过 `--set` 参数指定从 Harbor 拉取镜像，而非公网。

```bash
ssh root@10.144.183.157 "telepresence helm install \
  --set image.registry=matrix-registry.h3c.com:8088/library \
  --set image.name=tel2 \
  --set hooks.busybox.registry=matrix-registry.h3c.com:8088/library \
  --set hooks.curl.registry=matrix-registry.h3c.com:8088/library \
  --set hooks.curl.image=curl"
```

**参数说明：**
- `image.registry` + `image.name`：Traffic Manager 主镜像地址，组合后为 `matrix-registry.h3c.com:8088/library/tel2:2.28.0`
- `hooks.busybox.registry`：Helm Hook 中 busybox 镜像的仓库地址
- `hooks.curl.registry` + `hooks.curl.image`：Helm Hook 中 curl 镜像的地址，组合后为 `matrix-registry.h3c.com:8088/library/curl:8.1.1`

**验证 Pod 状态：**

```bash
ssh root@10.144.183.157 "kubectl get pods -n ambassador"
```

**预期输出：** 看到 `traffic-manager-*` Pod 状态为 `Running`。

> **注意：** 如果 K8s 版本 < 1.24，`telepresence helm install` 会报 grpc startupProbe 不支持的错误，需额外添加参数将 grpc 探针替换为 TCP 探针：
> ```bash
> --set 'startupProbe.tcpSocket.port=8081' --set 'startupProbe.periodSeconds=2' --set 'startupProbe.failureThreshold=5'
> ```

---

## 步骤 7：安装 Windows 客户端

**目的：** 在本地 Windows 机器上安装 Telepresence 客户端，用于建立与远程集群的连接。

**7.1 卸载旧版本 WinFSP 和 SSHFS-Win（如果已安装）：**

> Telepresence 安装程序自带兼容版本的 WinFSP 和 SSHFS-Win，旧版本会导致安装报错（版本冲突）。

通过 **设置 > 应用 > 已安装的应用** 搜索并卸载 WinFSP 和 SSHFS-Win，或在 PowerShell 中执行：

```powershell
Get-Package -Name "WinFSP" -ErrorAction SilentlyContinue | Uninstall-Package
Get-Package -Name "SSHFS-Win" -ErrorAction SilentlyContinue | Uninstall-Package
```

**7.2 运行安装程序：**

双击运行 `d:/tmp/telepresence/telepresence-windows-amd64-setup.exe`，按提示完成安装。

**7.3 验证安装：**

```bash
telepresence version
```

**预期输出包含：** `OSS Client : v2.28.0`

---

## 步骤 8：拷贝 kubeconfig 到本机

**目的：** 将服务器上的 K8s 集群认证配置文件拷贝到本机，供本地 kubectl 和 Telepresence 使用。文件按 `<服务器IP>-kubeconfig` 命名，便于管理多集群。

```bash
scp root@10.144.183.157:/etc/kubernetes/admin.conf d:/tmp/telepresence/10.144.183.157-kubeconfig
```

---

## 步骤 9：修改 kubeconfig 中的 API Server 地址

**目的：** 服务器上的 kubeconfig 中 API Server 地址为主机名（如 `matrix-apiserver:6443`），本机无法解析该主机名，需要替换为服务器的实际 IP 地址。

将 kubeconfig 中的：

```yaml
server: https://matrix-apiserver:6443
```

替换为：

```yaml
server: https://10.144.183.157:6443
```

可用 sed 命令替换：

```bash
sed -i 's/https:\/\/matrix-apiserver:6443/https:\/\/10.144.183.157:6443/' d:/tmp/telepresence/10.144.183.157-kubeconfig
```

**测试连通性：**

```bash
kubectl --kubeconfig d:/tmp/telepresence/10.144.183.157-kubeconfig cluster-info
```

**预期输出：** 显示集群信息，无连接错误。

> **如果连接超时：** 说明本机无法直接访问服务器的 6443 端口（防火墙限制），有两种解决方式：
> 1. 请管理员开放 6443 端口
> 2. 使用 SSH 隧道：`ssh -f -N -L 16443:localhost:6443 root@10.144.183.157`，然后将 kubeconfig 中地址改为 `https://localhost:16443`，并在 `telepresence connect` 时添加 `--insecure-skip-tls-verify`（因为证书是签给原主机名的，localhost 不匹配）

---

## 步骤 10：telepresence connect 验证

**目的：** 使用 Telepresence 连接到远程集群，验证整个安装流程是否成功。

**10.1 连接集群：**

```bash
telepresence connect --kubeconfig d:/tmp/telepresence/10.144.183.157-kubeconfig
```

**预期输出：** `Connected to context kubernetes-admin@kubernetes`

**10.2 查看连接状态：**

```bash
telepresence status
```

**预期输出：**

```
OSS User Daemon: Running
  Version           : 2.28.0
  Status            : Connected
  Kubernetes server : https://10.144.183.157:6443
  Manager namespace : ambassador
  Mapped namespaces : [ambassador default kube-public matrix service-software]
```

**10.3 访问集群内服务验证：**

```bash
# 通过 SVC 名称直接访问集群内服务的健康检查接口
curl -s http://liccmgr-svc.service-software:8080/probe
# 预期输出：true

curl -s http://seasql-operator.service-software:8080/readyz/
# 预期输出：ok

curl -s http://logcenter-analysis-grafana-clickhouse-svc.service-software:3000/api/health
# 预期输出：{"database":"ok"}
```

> 如果能正常返回结果，说明 Telepresence 已成功将本机接入 K8s 集群网络，可以像集群内的 Pod 一样访问所有服务。

---

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| SSH 连接超时 | 网络不通 | 检查网络/防火墙 |
| SSH 免密登录失败 | 公钥未分发 | 执行 `ssh-copy-id` |
| kubectl 版本过低 | < 1.24 | 升级 kubectl |
| RPM 安装冲突 | 已有旧版本 | `rpm -e telepresence` 先卸载 |
| docker login 失败 | Harbor 凭据错误 | 检查用户名密码 |
| helm install 报 grpc probe 错误 | K8s < 1.24 不支持 grpc startupProbe | 添加 `--set startupProbe.tcpSocket.port=8081` |
| Windows setup 报 WinFSP 错误 | 旧版 WinFSP 冲突 | 先卸载旧版 WinFSP 和 SSHFS-Win |
| telepresence connect TLS 错误 | kubeconfig 地址与证书不匹配 | 使用 `--insecure-skip-tls-verify` 或通过 hosts 映射 |
| 本机无法访问 6443 | 防火墙限制 | 开放端口或使用 SSH 隧道 |
