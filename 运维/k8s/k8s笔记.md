k8s相关命令

## 集群相关

~~~shell
# 切换当前命令行默认使用的namespace
kubectl config set-context --current --namespace=my-namespace

kubectl get nodes # 查看node状态
kubectl get nodes --show-labels # 查看node状态, 带label
kubecttl get nodes -o wide # 查看node状态, 带node的ip地址, 当你想看集群中的所有节点的ip的时候特别有用


kubectl label nodes hostnamexxx  name=value # 给node打label标签
kubectl label nodes hostnamexxx  name=value- # 删除label标签


kubectl apply -f xxx.yaml # 按照yaml的指示创建对应的资源
kubectl delete -f xxx.yaml # 按照yaml的指示删除对应的资源, 

kubectl edit svc svc_name # 直接修改已经创建的svc的配置, 直接生效
kubectl edit deploy deployment_name # 直接修改已经创建的deployment的配置, 直接生效
~~~

宿主机和Pod之间的文件复制

~~~shell
# 格式, source, destination可以是本地路径也可以是pod内的路径
# -n 用于指定pod所在的namespace
kubectl cp <source> <destination> [options] -n <namespace>
~~~

案例:

~~~shell
# 将本地的文件复制到pod中
kubectl cp ./file.txt my-namespace/mypod:/tmp/file.txt 

# 将mydir目录, 复制到/tmp/mydir下面
kubectl cp ./mydir my-namespace/mypod:/tmp/mydir 

# 如果你想要让mydir目录下的所有文件复制到/tmp/mydir下面, 那你可能要对mydir下的每个文件或者目录都调用一次cp命令才能实现了
~~~

如果一个pod下面有多个容器, 那么你还要通过`-c`来指定container的名字

```
kubectl cp my-namespace/mp-pod:/tmp/file.txt ./file.txt -c contianer_name
```







## pod相关命令

~~~shell
kubectl get pod # 查看默认namespace下有哪些pod, 默认的namespace默认情况下是default
kubectl get pod -n namespace # 查看指定namespace下有哪些pod
kubectl get pod -n namespace -o wild # 查看指定namespace下有哪些pod, 并附带pod的ip和存在的node
kubectl get pod -A # 查看所有namespace中的pods
kubectl get pod -n namespace # 查看指定namespace中的pods
kubectl get pod -n namespace pod_name # 查看一个pod的状态
kubectl get pod pod_name --watch # 监视pod的状态


kubectl describe pod pod_name -n namespace # 查看指定namespace中的pod的详细信息
kubectl describe pod pod_name -n namespace -o yaml # 查看指定namespace的pod的详细情况, 并以yaml的形式显示


kubectl delete pod --all # 删除所有pod
kubectl delete pod -n namespace_name --all # 删除一个namespace中所有的pod
kubectl delete pod -n namespace_name pod_name # 删除一个pod, 如果这个pod被deployment管理了, 那么deployment还会重新创建出一个pod副本


kubectl exec  -n namespace_name pod_name -c container_name -it -- /bin/bash # 进入容器内部, 如果pod只有一个container, 那么可以省略-c参数
kubectl log -n namespace_name pod_name -c container_name # 查看pod中指定容器的日志

kubectl get pod --show-labels # 查看pod的label
kubectl label pod pod_name label1=value1 --overwrite=True # 给pod添加标签, 如果已经存在同名的标签就修改
~~~

如果想要查看当前这个pod是哪个controller创建出来的

```shell
[root@node173 ~]# kubectl describe pod -n service-software seasql-base-0
Name:         seasql-base-0
Namespace:    service-software
Priority:     0
Node:         node173/10.99.209.173
Start Time:   Fri, 04 Jul 2025 14:38:35 +0800
Labels:       ...
Annotations:  ....
Status:       Running
Controlled By:  StatefulSet/seasql-base
Containers:
```

可以通过`Controlled By:  StatefulSet/seasql-base`发现当前的pod是被`seasql-base`这个StatefulSet创建出来的











## deployment相关命令

~~~shell
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# 根据命令生成yaml文件, --dry-run表示不执行命令
kubectl create deployment web1 --image=nginx:1.24 --dry-run -o yaml > deployment.yaml
~~~





## svc相关命令

~~~shell
kubectl expose deployment deploy_name --port=xx --type=NodePort --targetPort=xx --nodePort=xx

kubectl get svc # 查看default命名空间所有svc
kubectl get svc -A # 查看所有命名空间的svc
kubectl get svc -n namespace # 查看指定命名空间的svc
kubectl get svc -n namespace svc_name # 查看指定命名空间的指定svc

kubectl describe svc -n namespace svc_name # 查看svc的详细情况
kubectl describe svc -n namespace svc_nam -o yaml # 以yaml的形式查看svc的详细情况

kubectl delete svc --all # 删除所有的svc
kubectl delete svc -n namespace_name svc_name # 删除指定命名空间的指定svc

kubectl edit svc svc_name # 修改svc的配置
~~~





# 二进制方式安装kubernetes

参考尚硅谷k8s新版视频

https://www.bilibili.com/video/BV1GT4y1A756

## master安装etcd

安装前需要注意的事项

- **在master节点上面单独执行**

- **可以将要下载的东西通过浏览器下载好, 然后放在~目录下**, 通过wget下载会很慢

  需要下载的东西如下:

  https://pkg.cfssl.org/R1.2/cfssl_linux-amd64

  https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

  https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64

  https://github.com/etcd-io/etcd/releases/download/v3.4.9/etcd-v3.4.9-linux-amd64.tar.gz



生成etcd证书

~~~shell
cd ~

# 获取cfssl
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
mv cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo

# 准备etcd证书的配置文件
mkdir -p ~/TLS/{etcd,k8s}
cd TLS/etcd
cat > ca-config.json<< EOF
{
    "signing": {
        "default": {
            "expiry": "87600h"
        },
        "profiles": {
            "www": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF

cat > ca-csr.json<< EOF
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF

# 生成证书
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
ls *pem

# 使用自签ca签发etcd https证书
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  修改为自己的集群ip 
cat > server-csr.json<< EOF
{
    "CN": "etcd",
    "hosts": [
        "192.168.31.102",
        "192.168.31.103",
        "192.168.31.104"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "BeiJing",
            "ST": "BeiJing"
        }
    ]
}
EOF

# 生成证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www server-csr.json | cfssljson -bare server
ls server*pem
~~~

安装etcd

~~~shell
cd ~
# 下载安装包
wget https://github.com/etcd-io/etcd/releases/download/v3.4.9/etcd-v3.4.9-linux-amd64.tar.gz

mkdir /opt/etcd/{bin,cfg,ssl} –p
tar zxvf etcd-v3.4.9-linux-amd64.tar.gz
mv etcd-v3.4.9-linux-amd64/{etcd,etcdctl} /opt/etcd/bin

# 创建etcd配置文件
# !!!!!!!!!!!!!!!!!!!!!!!!!需要修改ip
cat > /opt/etcd/cfg/etcd.conf << EOF
#[Member]
ETCD_NAME="etcd-1"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.31.102:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.31.102:2379"
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.31.102:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.31.102:2379"
ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.31.102:2380,etcd-2=https://192.168.31.103:2380,etcd-3=https://192.168.31.104:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

# systemd管理etcd
cat > /usr/lib/systemd/system/etcd.service << EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
[Service]
Type=notify
EnvironmentFile=/opt/etcd/cfg/etcd.conf
ExecStart=/opt/etcd/bin/etcd \
--cert-file=/opt/etcd/ssl/server.pem \
--key-file=/opt/etcd/ssl/server-key.pem \
--peer-cert-file=/opt/etcd/ssl/server.pem \
--peer-key-file=/opt/etcd/ssl/server-key.pem \
--trusted-ca-file=/opt/etcd/ssl/ca.pem \
--peer-trusted-ca-file=/opt/etcd/ssl/ca.pem \
--logger=zap
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

# 拷贝刚刚的证书到目标位置
cp ~/TLS/etcd/ca*pem ~/TLS/etcd/server*pem /opt/etcd/ssl/
~~~

## worker安装etcd

将master上的所有文件拷贝到节点2和节点3上面

~~~shell
scp -r /opt/etcd/ root@192.168.31.103:/opt/
scp -r /opt/etcd/ root@192.168.31.104:/opt/

scp /usr/lib/systemd/system/etcd.service root@192.168.31.103:/usr/lib/systemd/system/ 
scp /usr/lib/systemd/system/etcd.service
root@192.168.31.104:/usr/lib/systemd/system/

scp -r /opt/etcd/ root@192.168.31.103:/opt/
scp -r /opt/etcd/ root@192.168.31.104:/opt/

scp /usr/lib/systemd/system/etcd.service root@192.168.31.103:/usr/lib/systemd/system/
scp /usr/lib/systemd/system/etcd.service root@192.168.31.104:/usr/lib/systemd/system/
~~~

修改节点2和节点3的etcd.conf为当前ip

~~~shell
vi /opt/etcd/cfg/etcd.conf
#[Member]
ETCD_NAME="etcd-2" # 修改此处， 节点 2 改为 etcd-2， 节点 3 改为 etcd-3
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.31.102:2380" # 修改此处为当前服务器 IP
ETCD_LISTEN_CLIENT_URLS="https://192.168.31.102:2379" # 修改此处为当前服务器 IP
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.31.102:2380" # 修改此处为当前
服务器 IP
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.31.102:2379" # 修改此处为当前服务器
IP
ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.31.71:2380,etcd-2=https://192.168.31.72:2380,etcd-3=https://192.168.31.73:2380"  # 修改为自己集群的ip

ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
~~~

自启动

~~~shell
# 设置开机自启动
systemctl daemon-reload
systemctl start etcd
systemctl status etcd
systemctl enable etcd
~~~

查看集群状态

~~~shell
ETCDCTL_API=3 /opt/etcd/bin/etcdctl --cacert=/opt/etcd/ssl/ca.pem --cert=/opt/etcd/ssl/server.pem --key=/opt/etcd/ssl/server-key.pem --endpoints="https://192.168.31.102:2379,https://192.168.31.103:2379,https://192.168.31.104:2379" endpoint health
~~~

## 总结

- 在安装之前下载好多有的包, 否则wget很慢

- **安装好master后不要着急启动, 因为配置了集群, master上的etcd启动后连接不到worker上的etcd, 不会退出命令行, 所有要master和worker一起安装好后, 再启动**

- **其实不用配置etcd集群, 只要配置一个etcd就好, 后面的k8s就用这一个etcd**
- **如果通过systemctl启动失败, 可以将etcd.service中的EnvironmentFile和ExecStart拼接上, 来执行, 如果能够执行, 说明etcd.service配置有问题, 如果不能执行, 说明etcd的配置文件有问题**

## Worker安装docker

先设置稳定的存储库

~~~shell
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
~~~

安装docker

~~~shell
sudo yum install docker-ce docker-ce-cli containerd.io -y
~~~

启动docker并运行hello world

~~~shell
sudo systemctl start docker
sudo systemctl enable docker
sudo docker run hello-world
~~~

修改docker镜像为阿里镜像

~~~shell
cat > /etc/docker/daemon.json << eof
{
 "registry-mirrors":["https://6kx4zyno.mirror.aliyuncs.com"]
}
eof
systemctl daemon-reload 
systemctl restart docker
~~~

## master安装kube-apiserver

签发证书

~~~shell
cd ~/TLS/k8s
cat > ca-config.json<< EOF
{
    "signing": {
        "default": {
            "expiry": "87600h"
        },
        "profiles": {
            "kubernetes": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF
cat > ca-csr.json<< EOF
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
# 生成证书
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
ls *pem
~~~

使用自签ca签发kube-apiserver https证书

~~~shell
cd ~/TLS/k8s
cat > server-csr.json<< EOF
{
    "CN": "kubernetes",
    "hosts": [
        "127.0.0.1",
        "192.168.31.104",
        "192.168.31.103",
        "192.168.31.102",
        "kubernetes",
        "kubernetes.default",
        "kubernetes.default.svc",
        "kubernetes.default.svc.cluster",
        "kubernetes.default.svc.cluster.local"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "BeiJing",
            "ST": "BeiJing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
~~~

生成证书

~~~shell
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json | cfssljson -bare server
ls server*pem
~~~

下载k8s并放到家目录下

~~~shell
cd ~
mkdir -p /opt/kubernetes/{bin,cfg,ssl,logs}
tar -zxvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
cp kube-apiserver kube-scheduler kube-controller-manager /opt/kubernetes/bin
cp kubectl /usr/bin/
~~~

部署kube-apiserver

~~~shell
cat > /opt/kubernetes/cfg/kube-apiserver.conf << EOF
KUBE_APISERVER_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--etcd-servers=https://192.168.31.102:2379,https://192.168.31.103:2379,https://192.168.31.104:2379 \\
--bind-address=192.168.31.102 \\
--secure-port=6443 \\
--advertise-address=192.168.31.102 \\
--allow-privileged=true \\
--service-cluster-ip-range=10.0.0.0/24 \\
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction \\
--authorization-mode=RBAC,Node \\
--enable-bootstrap-token-auth=true \\
--token-auth-file=/opt/kubernetes/cfg/token.csv \\
--service-node-port-range=30000-32767 \\
--kubelet-client-certificate=/opt/kubernetes/ssl/server.pem \\
--kubelet-client-key=/opt/kubernetes/ssl/server-key.pem \\
--tls-cert-file=/opt/kubernetes/ssl/server.pem \\
--tls-private-key-file=/opt/kubernetes/ssl/server-key.pem \\
--client-ca-file=/opt/kubernetes/ssl/ca.pem \\
--service-account-key-file=/opt/kubernetes/ssl/ca-key.pem \\
--etcd-cafile=/opt/etcd/ssl/ca.pem \\
--etcd-certfile=/opt/etcd/ssl/server.pem \\
--etcd-keyfile=/opt/etcd/ssl/server-key.pem \\
--audit-log-maxage=30 \\
--audit-log-maxbackup=3 \\
--audit-log-maxsize=100 \\
--audit-log-path=/opt/kubernetes/logs/k8s-audit.log"
EOF
~~~

拷贝刚刚的证书

~~~shell
cp ~/TLS/k8s/ca*pem ~/TLS/k8s/server*pem /opt/kubernetes/ssl/
~~~

TLS bootstraping 配置

~~~shell
cat > /opt/kubernetes/cfg/token.csv << EOF
c47ffb939f5ca36231d9e3121a252940,kubelet-bootstrap,10001,"system:nodebootstrapper"
EOF
~~~

systemd管理apiserver

~~~shell
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kube-apiserver.conf
ExecStart=/opt/kubernetes/bin/kube-apiserver \$KUBE_APISERVER_OPTS
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
~~~

开机自启

~~~shell
systemctl daemon-reload
systemctl start kube-apiserver
systemctl status kube-apiserver
systemctl enable kube-apiserver
~~~

授权 kubelet-bootstrap 用户允许请求证书

~~~shell
kubectl create clusterrolebinding kubelet-bootstrap \
--clusterrole=system:node-bootstrapper \
--user=kubelet-bootstrap  
~~~

## master安装kube-controller-manager

创建配置文件

~~~shell
cat > /opt/kubernetes/cfg/kube-controller-manager.conf << EOF
KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--leader-elect=true \\
--master=127.0.0.1:8080 \\
--bind-address=127.0.0.1 \\
--allocate-node-cidrs=true \\
--cluster-cidr=10.244.0.0/16 \\
--service-cluster-ip-range=10.0.0.0/24 \\
--cluster-signing-cert-file=/opt/kubernetes/ssl/ca.pem \\
--cluster-signing-key-file=/opt/kubernetes/ssl/ca-key.pem \\
--root-ca-file=/opt/kubernetes/ssl/ca.pem \\
--service-account-private-key-file=/opt/kubernetes/ssl/ca-key.pem \\
--experimental-cluster-signing-duration=87600h0m0s"
EOF
~~~

systemd管理controller-manager

~~~shell
cat > /usr/lib/systemd/system/kube-controller-manager.service << EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kube-controller-manager.conf
ExecStart=/opt/kubernetes/bin/kube-controller-manager \$KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
~~~

开机自启

~~~shell
systemctl daemon-reload
systemctl start kube-controller-manager
systemctl status kube-controller-manager
systemctl enable kube-controller-manager
~~~

## master部署kube-scheduler

创建配置文件

~~~shell
cat > /opt/kubernetes/cfg/kube-scheduler.conf << EOF
KUBE_SCHEDULER_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--leader-elect \\
--master=127.0.0.1:8080 \\
--bind-address=127.0.0.1"
EOF
~~~

systemd管理scheduler

~~~shell
cat > /usr/lib/systemd/system/kube-scheduler.service << EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kube-scheduler.conf
ExecStart=/opt/kubernetes/bin/kube-scheduler \$KUBE_SCHEDULER_OPTS
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
~~~

开机自启动

~~~shell
systemctl daemon-reload
systemctl start kube-scheduler
systemctl status kube-scheduler.service
systemctl enable kube-scheduler
~~~

查看集群状态

~~~shell
kubectl get cs
~~~

## worker部署kubelet

下载k8s包在家目录下

~~~shell
cd ~
tar zxvf kubernetes-server-linux-amd64.tar.gz
mkdir -p /opt/kubernetes/{bin,cfg,ssl,logs}
mkdir -p /root/TLS/k8s/ 
cd kubernetes/server/bin
cp kubelet kube-proxy /opt/kubernetes/bin
cp kubectl /usr/bin/ # 后面要用这个文件
~~~

创建kubelet配置文件, **hostname-override需要改为当前worker节点的主机名**

~~~shell
cat > /opt/kubernetes/cfg/kubelet.conf << EOF
KUBELET_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--hostname-override=hadoop104 \\
--network-plugin=cni \\
--kubeconfig=/opt/kubernetes/cfg/kubelet.kubeconfig \\
--bootstrap-kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig \\
--config=/opt/kubernetes/cfg/kubelet-config.yml \\
--cert-dir=/opt/kubernetes/ssl \\
--pod-infra-container-image=lizhenliang/pause-amd64:3.0"
EOF

cat > /opt/kubernetes/cfg/kubelet-config.yml << EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS:
  - 10.0.0.2
clusterDomain: cluster.local
failSwapOn: false
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /opt/kubernetes/ssl/ca.pem
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s
evictionHard:
  imagefs.available: "15%"
  memory.available: "100Mi"
  nodefs.available: "10%"
  nodefs.inodesFree: "5%"
EOF
~~~

生成bootstrap.kubeconfig文件, 

~~~shell
# 先把master中/opt/kubernetes/ssl/ca*赋值到worker同样目录下
# 因为worker节点上没有这些东西
scp /root/TLS/k8s/ca* root@192.168.31.103:/root/TLS/k8s/ 

cp /root/TLS/k8s/ca* /opt/kubernetes/ssl/ # 同样拷贝到ssl目录下一份
KUBE_APISERVER="https://192.168.31.102:6443" # apiserver IP:PORT
TOKEN="c47ffb939f5ca36231d9e3121a252940" # 与 token.csv 里保持一致
kubectl config set-cluster kubernetes \
--certificate-authority=/opt/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=bootstrap.kubeconfig
kubectl config set-credentials "kubelet-bootstrap" \
--token=${TOKEN} \
--kubeconfig=bootstrap.kubeconfig
kubectl config set-context default \
--cluster=kubernetes \
--user="kubelet-bootstrap" \
--kubeconfig=bootstrap.kubeconfig
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
~~~

拷贝到配置文件路径下

~~~shell
cp bootstrap.kubeconfig /opt/kubernetes/cfg
~~~

systemd管理kubelet

~~~shell
cat > /usr/lib/systemd/system/kubelet.service << EOF
[Unit]
Description=Kubernetes Kubelet
After=docker.service
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kubelet.conf
ExecStart=/opt/kubernetes/bin/kubelet \$KUBELET_OPTS
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
~~~

开机自启动

~~~shell
systemctl daemon-reload
systemctl start kubelet
systemctl status kubelet
systemctl enable kubelet
~~~

在master上批准kublet证书申请并假如集群

~~~shell
# 查看申请
kubectl get csr
NAME AGE SIGNERNAME  REQUESTOR CONDITION
node-csr-uCEGPOIiDdlLODKts8J658HrFq9CZ--K6M4G7bjhk8A 6m3s kubernetes.io/kube-apiserver-client-kubelet kubelet-bootstrap Pending
# 批准申请
kubectl certificate approve node-csr-uCEGPOIiDdlLODKts8J658HrFq9CZ--K6M4G7bjhk8A
# 查看节点
kubectl get node
~~~

## worker部署kube-proxy

创建配置文件

~~~shell
cat > /opt/kubernetes/cfg/kube-proxy.conf << EOF
KUBE_PROXY_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--config=/opt/kubernetes/cfg/kube-proxy-config.yml"
EOF
~~~

创建配置参数文件, 需要修改hostnameOverride为当前ip地址

~~~shell
cat > /opt/kubernetes/cfg/kube-proxy-config.yml << EOF
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
metricsBindAddress: 0.0.0.0:10249
clientConnection:
  kubeconfig: /opt/kubernetes/cfg/kube-proxy.kubeconfig
hostnameOverride: hadoop104
clusterCIDR: 10.0.0.0/24
EOF
~~~

生成kube-proxy.kubeconfig文件

~~~shell
cd ~/TLS/k8s
# 创建证书请求文件
cat > kube-proxy-csr.json<< EOF
{
    "CN": "system:kube-proxy",
    "hosts": [],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "BeiJing",
            "ST": "BeiJing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
# 生成证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
ls kube-proxy*pem
~~~

生成kubeconfig文件

~~~shell
KUBE_APISERVER="https://192.168.31.102:6443"
kubectl config set-cluster kubernetes \
--certificate-authority=/opt/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \--kubeconfig=kube-proxy.kubeconfig
kubectl config set-credentials kube-proxy \
--client-certificate=./kube-proxy.pem \
--client-key=./kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=kube-proxy.kubeconfig
kubectl config set-context default \
--cluster=kubernetes \
--user=kube-proxy \
--kubeconfig=kube-proxy.kubeconfig
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
# 拷贝到指定目录下
cp kube-proxy.kubeconfig /opt/kubernetes/cfg/
~~~

systemd 管理 kube-proxy

~~~shell
cat > /usr/lib/systemd/system/kube-proxy.service<< EOF
[Unit]
Description=Kubernetes Proxy
After=network.target
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kube-proxy.conf
ExecStart=/opt/kubernetes/bin/kube-proxy \$KUBE_PROXY_OPTS
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
~~~

开机自启动

~~~shell
systemctl daemon-reload
systemctl start kube-proxy
systemctl status kube-proxy
systemctl enable kube-proxy
~~~

## 部署cni网络

**(没部署好, 一直都是notReady)**

前往https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz下载cni二进制文件

并赋值到~目录

~~~shell
mkdir /opt/cni/bin /etc/cni/net.d -p
tar zxvf cni-plugins-linux-amd64-v0.8.6.tgz -C /opt/cni/bin
# 部署cni网络
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sed -i -r "s#quay.io/coreos/flannel:.*-amd64#lizhenliang/flannel:v0.12.0-amd64#g" kube-flannel.yml
kubectl apply -f kube-flannel.yml
kubectl get pods -n kube-flannel
kubectl get node
~~~

授权apiserver访问kubelet

~~~shell
cat > apiserver-to-kubelet-rbac.yaml<< EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
      - pods/log
    verbs:
      - "*"
 
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF

kubectl apply -f apiserver-to-kubelet-rbac.yaml
~~~





# kubeadm安装k8s

参考https://zhuanlan.zhihu.com/p/613288409

该文章搭建了多个master的集群, 但是这里只需要一个master

> <font color=red>一定要让虚拟机能够连接上外网, 否则kubeadm在安装k8s的时候, 会非常的慢</font>
>
> <font color=red>同时也不要设置任何的镜像为阿里云, 阿里云非常的垃圾, 经常会将镜像下架掉</font>
>
> <font color=red>如果你觉得能连上外网了, 那么如下命令打开firefox</font>
>
> ```shell
> firefox &
> ```
>
> 然后访问:
>
> - registry.k8s.io
> - youtube.com
> - https://hub.docker.com/
>
> 如果这三个网站在虚拟机上都可以访问, 那么基本就没什么问题了

> <font color=red>如果你使用clash作为代理, 那么一定不要使用`sudo`来执行命令, 因为clash代理是通过当前终端的环境变量来实现的, sudo会切换环境变量, 导致clash的代理无效!!!!!!!!!!!!!!!!!</font>





## 安装及优化

### 基本环境配置

1.环境介绍

高可用Kubernetes集群规划

| 主机名 | IP地址         | 说明       |
| ------ | -------------- | ---------- |
| cdh105 | 192.168.31.105 | master节点 |
| cdh106 | 192.168.31.106 | node节点   |
| cdh107 | 192.168.31.107 | node节点   |

2.配置信息

| 配置信息    | 备注      |
| ----------- | --------- |
| 系统版本    | Centos7.9 |
| Docker版本  | 20.10x    |
| Kubeadm版本 | v1.23.17  |

```shell
$ cat /etc/redhat-release 
CentOS Linux release 7.9.2009 (Core)

$ docker --version
Docker version 26.1.4, build 5650f9b

$ kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"28", GitVersion:"v1.28.2", GitCommit:"89a4ea3e1e4ddd7f7572286090359983e0387b2f", GitTreeState:"clean", BuildDate:"2023-09-13T09:34:32Z", GoVersion:"go1.20.8", Compiler:"gc", Platform:"linux/amd64"}
```

3.修改主机名

(1)根据规划信息在每台机器上修改主机名

```shell
hostnamectl set-hostname cdh105
hostnamectl set-hostname cdh106
hostnamectl set-hostname cdh107
```

4.修改host文件

(1)每台机器安装vim工具,如果安装过请忽略

```shell
yum install vim -y
```

(2)每台机器上修改hosts文件

```shell
$ vim /etc/hosts

192.168.31.105 cdh105
192.168.31.106 cdh106
192.168.31.107 cdh107
```

5.安装yum源

(1)在每台机器上执行以下命令配置默认yum源并安装依赖

~~~shell
# 使用官方的yum源
sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
sudo tee /etc/yum.repos.d/CentOS-Base.repo > /dev/null <<'EOF'
[base]
name=CentOS-7 - Base
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-7 - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-7 - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

yum clean all
yum makecache
~~~

你也可以使用aliyun来作为yum源

~~~shell
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
~~~



6.必备工具安装

(1)在每台机器上执行以下命令安装必备工具

```shell
yum install -y yum-utils device-mapper-persistent-data lvm2
yum install wget jq psmisc vim net-tools telnet yum-utils device-mapper-persistent-data lvm2 git -y
```

7.关闭防火墙、swap分区、dnsmasq、selinux

(1)在每台机器上执行以下命令关闭防火墙

```shell
systemctl disable --now firewalld
```

(2)在每台机器上执行以下命令关闭selinux

```shell
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/sysconfig/selinux
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

(3)在每台机器上执行以下命令关闭dnsmasq

```shell
$ systemctl disable --now dnsmasq
Failed to execute operation: No such file or directory
```

**注意:这里如果是通过VMware虚拟机实践的，会因为没有这个服务而报错!!!**

(4)在每台机器上执行以下命令关闭NetworkManager

```shell
systemctl disable --now NetworkManager
```

**注意:公有云不要关闭NetworkManager!!!**

(5)在每台机器上执行以下命令关闭swap分区

```shell
#临时关闭
swapoff -a && sysctl -w vm.swappiness=0

#永久关闭
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
```

8.时钟同步

(1)在每台机器上执行以下命令安装ntpdate

```shell
rpm -ivh http://mirrors.wlnmp.com/centos/wlnmp-release-centos.noarch.rpm
yum install ntpdate -y
```

(2)在每台机器上执行以下命令同步时间

```shell
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo 'Asia/Shanghai' >/etc/timezone

# 手动同步一次时间
ntpdate time.google.com

# 添加定时任务（每5分钟自动校时）
crontab -e
# 输入 */5 * * * * /usr/sbin/ntpdate time.google.com
```

9.在每台机器上执行以下命令

```shell
# 更新除了系统以外的所有依赖包到最新
yum update -y --exclude=kernel*
```

### 内核配置

Centos7默认内核为3.10

```shell
$ uname -a

Linux k8s-master01 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

在Centos中, 有两种内核版本

- kernel-ml

  kernel-ml 中的ml是英文【 mainline stable 】的缩写，elrepo-kernel中罗列出来的是最新的稳定主线版本。

- kernel-lt

  kernel-lt 中的lt是英文【 long term support 】的缩写，elrepo-kernel中罗列出来的长期支持版本。

k8s推荐使用lt版本的内核

我们前往http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/下载最新的rpm内核安装包

需要下载如下三个类型的安装包

- kernel-lt-devel
- kernel-lt-headers
- kernel-lt

下面的wget分别选项这三个包的5.4版本, 这也就表示我们的内核会升级到5.4版本

1.内核升级

```shell
cd /root
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-headers-5.4.278-1.el7.elrepo.x86_64.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-5.4.278-1.el7.elrepo.x86_64.rpm
```

在每台机器上执行以下命令安装内核

```shell
cd /root && yum localinstall -y kernel-lt*
```

查看是否安装成功

~~~shell
[root@chd111 tmp]# rpm -qa | grep kernel-lt
kernel-lt-5.4.278-1.el7.elrepo.x86_64
kernel-lt-headers-5.4.278-1.el7.elrepo.x86_64
kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64
~~~



在每台机器上执行以下命令更改内核启动顺序

```shell
grub2-set-default  0 && grub2-mkconfig -o /etc/grub2.cfg
grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"
```

在每台机器上执行以下命令检查默认内核是不是5.4

```shell
$ grubby --default-kernel
/boot/vmlinuz-5.4.278-1.el7.elrepo.x86_64
```

(6)在每台机器上执行以下命令重启并检查默认内核是不是5.4

```shell
reboot
uname -a  # 一定要重启才可以

Linux cdh107 5.4.278-1.el7.elrepo.x86_64 #1 SMP Sun Jun 16 15:37:11 EDT 2024 x86_64 x86_64 x86_64 GNU/Linux
```

2.**配置ipvs模块**, 一定要配置, 不了无法启动k8s

(1)在每台机器上执行以下命令安装ipvsadm

```shell
yum install ipvsadm ipset sysstat conntrack libseccomp -y
```

(2)在每台机器上执行以下命令配置ipvs模块,在内核`4.19+`版本nf_conntrack_ipv4已经改为nf_conntrack， 4.18以下使用nf_conntrack_ipv4即可

```shell
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
```

(3)在每台机器上修改/etc/modules-load.d/ipvs.conf文件，在文件末尾添加以下内容

```shell
$ vim /etc/modules-load.d/ipvs.conf
ip_vs
ip_vs_lc
ip_vs_wlc
ip_vs_rr
ip_vs_wrr
ip_vs_lblc
ip_vs_lblcr
ip_vs_dh
ip_vs_sh
ip_vs_fo
ip_vs_nq
ip_vs_sed
ip_vs_ftp
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
```

(4)在每台机器上设置开机自启

```shell
systemctl enable --now systemd-modules-load.service
```

(5)在每台机器上执行以下命令开启一些k8s集群中必须的内核参数，所有节点配置k8s内核

```shell
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
fs.may_detach_mounts = 1
net.ipv4.conf.all.route_localnet = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720

net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384
EOF

#应用
sysctl --system
```

上面参数说明:

- net.ipv4.ip_forward：允许系统在网络接口之间转发IP数据包
- net.bridge.bridge-nf-call-iptables：启用iptables处理桥接的网络流量
- net.bridge.bridge-nf-call-ip6tables：启用ip6tables处理桥接的网络流量
- fs.may_detach_mounts：允许在使用时卸载文件系统
- net.ipv4.conf.all.route_localnet：允许本地源IP地址的数据包路由
- vm.overcommit_memory：控制内存分配的过度提交行为
- vm.panic_on_oom：控制当发生内存不足条件时内核崩溃的行为
- fs.inotify.max_user_watches：指定每个用户的最大inotify监视数
- fs.file-max：指定最大打开文件数
- fs.nr_open：指定可打开的文件句柄的最大数
- net.netfilter.nf_conntrack_max：指定最大跟踪连接数
- net.ipv4.tcp_keepalive_time：指定TCP keepalive探测之间的间隔时间
- net.ipv4.tcp_keepalive_probes：指定可以发送的TCP keepalive探测的数量
- net.ipv4.tcp_keepalive_intvl：指定TCP keepalive探测之间的间隔时间
- net.ipv4.tcp_max_tw_buckets：指定timewait套接字的最大数量
- net.ipv4.tcp_tw_reuse：控制timewait套接字是否可以被重用
- net.ipv4.tcp_max_orphans：指定最大孤立套接字数量
- net.ipv4.tcp_orphan_retries：指定孤立套接字的重试次数
- net.ipv4.tcp_syncookies：启用TCP syncookies以防止SYN洪泛攻击
- net.ipv4.tcp_max_syn_backlog：指定侦听队列的最大大小
- net.ipv4.ip_conntrack_max：指定最大跟踪连接数
- net.ipv4.tcp_max_syn_backlog：指定侦听队列的最大大小
- net.ipv4.tcp_timestamps：启用TCP时间戳以进行性能优化
- net.core.somaxconn：指定侦听队列中的最大连接数

(6)重启每台机器

```shell
reboot
```

(7)在每台机器上执行以下命令进行验证，有"nf_conntrack"和"ip_vs"字样代表成功

```shell
lsmod | grep --color=auto -e ip_vs -e nf_conntrack
```

![img](img/k8s笔记/v2-c08ef1a43661731cad99091d8613d819_1440w.webp)



### Containerd作为Runtime

如果安装的版本低于1.24，选择Docker和Containerd均可，高于1.24选择Containerd作为Runtime。

1.在每台机器上执行以下命令安装docker-ce,注意这里安装docker时会把Containerd也装上

```shell
# 移除旧版本的docker
yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# 安装依赖包
yum install -y yum-utils device-mapper-persistent-data lvm2

# 添加docker 官方yum源
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 添加阿里云 Docker 仓库(可选)
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 清理缓存并更新元数据
yum clean all
yum makecache fast

# 安装 Docker最新稳定版, 这里的最新版由 官方云/阿里云(如果使用的是aliyundocker仓库) 决定
# 不一定是官方的最新版
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 查看docker版本
docker --version
Docker version 26.1.4, build 5650f9b

# Docker Compose V2 是以 插件形式集成在 Docker CLI 中的, 并且命令变成了docker compose
# 而不是docker-compose
docker compose version
Docker Compose version v2.27.1

# 查看containerd的状态
systemctl start containerd.service
systemctl status containerd.service
systemctl enable --now containerd.service
```

**注意!!:**  如果这里安装docker报兼容性错误, 说明之前安装过docker, 没有删除干净

使用一下命令

~~~shell
$ yum list installed | grep docker
containerd.io.x86_64                    1.6.33-3.1.el7                 @docker-ce-stable
docker-buildx-plugin.x86_64             0.14.1-1.el7                   @docker-ce-stable
docker-ce.x86_64                        3:26.1.4-1.el7                 @docker-ce-stable
docker-ce-cli.x86_64                    1:26.1.4-1.el7                 @docker-ce-stable
docker-ce-rootless-extras.x86_64        26.1.4-1.el7                   @docker-ce-stable
docker-compose-plugin.x86_64            2.27.1-1.el7                   @docker-ce-stable


sudo systemctl stop docker
sudo systemctl stop containerd

sudo yum remove -y docker-ce docker-ce-cli docker-ce-rootless-extras docker-buildx-plugin docker-compose-plugin containerd.io
~~~



2.在每台机器上执行以下命令配置Containerd所需的模块

```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```

3.在每台机器上执行以下命令加载模块

```shell
modprobe -- overlay
modprobe -- br_netfilter
```

4.在每台机器上执行以下命令配置Containerd所需的内核

```shell
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
```

5.在每台机器上执行以下命令加载内核

```shell
sysctl --system
```

6.在每台机器上执行以下命令配置Containerd的配置文件

```shell
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
```

7.在每台机器上执行以下命令将`Containerd`的`Cgroup`改为`Systemd`,找到**containerd.runtimes.runc.options**，添加**SystemdCgroup = true（如果已存在直接修改，否则会报错）**

```shell
$ vim /etc/containerd/config.toml
...
...
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  BinaryName = ""
  CriuImagePath = ""
  CriuPath = ""
  CriuWorkPath = ""
  IoGid = 0
  IoUid = 0
  NoNewKeyring = false
  NoPivotRoot = false
  Root = ""
  ShimCgroup = ""
  SystemdCgroup = true
```

<img src="img/k8s笔记/v2-4e3076a3f0c87af691dc553eab815486_1440w.webp" alt="img"  />

将docker的cgroup设置为systemd, 添加如下内容

~~~shell
vim /etc/docker/daemon.json

{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
~~~



8.在每台机器上执行以下命令将sandbox_image的Pause镜像改成符合自己版本的地址[http://registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6](https://link.zhihu.com/?target=http%3A//registry.cn-hangzhou.aliyuncs.com/google_containers/pause%3A3.6)

<font color=red>如果你的网络能连接外网的话, 不要配置这个, 因为阿里云非常的垃圾</font>

```shell
$ vim /etc/containerd/config.toml

#原本内容
sandbox_image = "registry.k8s.io/pause:3.6"
#修改后的内容
sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6"
```

<img src="img/k8s笔记/v2-b913213f4d01818a107e0e0d31ecac26_1440w.webp" alt="img" style="zoom:50%;" />

9.在每台机器上执行以下命令启动Containerd，并配置开机自启动

```shell
systemctl daemon-reload
systemctl enable --now containerd
systemctl enable --now docker
# 查看containerd和docker的状态
systemctl status containerd
systemctl status docker

$ ls /run/containerd/containerd.sock
/run/containerd/containerd.sock

# 查看docker使用的cgroup
$ docker info | grep -i cgroup
 Cgroup Driver: systemd
 Cgroup Version: 1
```

10.在每台机器上执行以下命令配置crictl客户端连接的容器运行时环境为containerd

```shell
cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

systemctl restart containerd
```

11.在每台机器上执行以下命令进行验证

```shell
$ ctr image ls
REF TYPE DIGEST SIZE PLATFORMS LABELS
```

12.修改docker镜像为阿里镜像

具体的地址可以登录阿里云查看, https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors

<font color=red>如果你的网络能连接外网的话, 不要配置这个, 因为阿里云非常的垃圾</font>

~~~shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://4q9ahtha.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
~~~

## 搭建集群



### 安装Kubernetes组件Kubeadm&Kubelet

1.在每台机器上执行以下命令配置kubernetes的yum源

~~~shell
# 此操作会覆盖 /etc/yum.repos.d/kubernetes.repo 中现存的所有配置
# 这个仓库只包含kubectl 1.34的相关软件包
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/repodata/repomd.xml.key
EOF
~~~

当然你也可以使用aliyun的yum源

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
```

更新yum缓存

~~~shell
yum clean all
yum makecache fast
~~~

在Master01节点查看最新的Kubernetes版本是多少

```shell
yum list kubeadm.x86_64 --showduplicates | sort -r
```

2.在每台机器上执行以下命令安装1.23最新版本kubeadm、kubelet和kubectl

```shell
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes -y

#查看版本, 一定要看清楚, 装的是1.28版本的kubenetes
kubeadm version
```

**注意!!!!**如果这里安装的不是1.28版本的k8s, 说明之前安装过了其他版本的, 使用以下脚本删除掉

~~~shell
$ yum list installed | grep kube
cri-tools.x86_64                        1.26.0-0                       @kubernetes
kubeadm.x86_64                          1.28.2-0                       @kubernetes
kubectl.x86_64                          1.28.2-0                       @kubernetes
kubelet.x86_64                          1.28.2-0                       @kubernetes
kubernetes-cni.x86_64                   1.2.0-0                        @kubernetes


$  yum remove -y kubeadm.x86_64 kubectl.x86_64 kubelet.x86_64  kubernetes-cni.x86_64
~~~



3.在每台机器上执行以下命令更改Kubelet的配置使用Containerd作为Runtime，如果选择的是docker作为的Runtime,则不需要进行更改**(k8s1.24+不需要这个步骤, k8s默认使用cni控制containerd)**

```shell
cat >/etc/sysconfig/kubelet<<EOF
KUBELET_KUBEADM_ARGS="--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF
```

4.在每台机器上执行以下命令设置Kubelet开机自启动

```shell
systemctl daemon-reload
systemctl status kubelet
systemctl enable --now kubelet
```

**说明:由于还未初始化，没有kubelet的配置文件，此时kubelet无法启动，无需管理**

5.设置k8s使用的cgroup为systemd

<font color=red>一定要保证containerd, k8s使用的cgroup都是一样的, 同时推荐使用现代的systemd作为cgroup</font>

~~~shell
vim /var/lib/kubelet/config.yaml

# 添加如下内容
cgroupDriver: systemd
~~~



### Master节点初始化

<font color=red>(如果按照以下步骤初始化master节点, 会报错, could not find node cdh105, 猜测应该是哪里的ip地址配错了, 因为这里作者搭建的高可用的master, 而我们这里只搭建了一个master), 可以使用尚硅谷的初始化命令来初始化master </font>

~~~shell
# 提前拉取镜像, 即使这里不拉取, 下面这个命令也会拉取的
# 需要在多个节点上执行!!!!!
kubeadm config images pull

# 初始化master, 只需要在一个master节点上执行, 即使你需要多个master
# worker上不需要执行
# Note: 需要修改下面的ip为当前master的ip, 和当前k8s的版本号!!!!!!!!!!!!!!!!!!!!!!!!

# 使用aliyun拉取
kubeadm init \
--apiserver-advertise-address=192.168.1.105 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.28.2 \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16

# 不使用阿里云的版本, 默认从官方仓库拉取(推荐)
kubeadm init \
--apiserver-advertise-address=192.168.1.105  \
--kubernetes-version v1.28.2 \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16
~~~

执行完成之后, 会显示如下的内容

~~~shell
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.105:6443 --token 4nmo11.lz9pz0c056uma8rz \
        --discovery-token-ca-cert-hash sha256:fb8fe2f9d8a93a82f9da4849174bf104c9807575872b56c0e4626ed6aa8548e6
~~~

我们根据上面显示的步骤

1. 查看kubelet的状态

   ~~~shell
   # 如果不是running需要检查失败原因
   systemctl status  kubelet
   ~~~

   

2. 如果你想让某个用户能够执行kubectl命令控制k8s, 那么就使用这个用户来执行如下的命令

   ~~~shell
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ~~~

3. 如果你是root用户, 那么你可以执行如下的命令

   ~~~shell
   export KUBECONFIG=/etc/kubernetes/admin.conf
   ~~~

4. 之后你需要安装一个CNI的网络插件, 这样pod之间就能够通讯了

   这个通讯插件你可以在https://kubernetes.io/docs/concepts/cluster-administration/addons/选择一个

   这里我们选择flannel

   ~~~shell
   # 从github下载flannel的yaml文件
   $ wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
   
   # 安装插件
   $ kubectl apply -f kube-flannel.yml
   
   # 查看flannel使用的pod
   $ kubectl get pod -n kube-flannel
   NAME                    READY   STATUS    RESTARTS   AGE
   kube-flannel-ds-c2bpd   1/1     Running   0          4m33s
   kube-flannel-ds-xqn7q   1/1     Running   0          4m33s
   kube-flannel-ds-zwkrp   1/1     Running   0          4m33s
   
   $ kubectl get pod -n kube-system
   NAME                             READY   STATUS    RESTARTS   AGE
   coredns-6d8c4cb4d-4hmkp          1/1     Running   0          23m
   coredns-6d8c4cb4d-5676h          1/1     Running   0          23m
   etcd-cdh105                      1/1     Running   1          23m
   kube-apiserver-cdh105            1/1     Running   1          23m
   kube-controller-manager-cdh105   1/1     Running   1          23m
   kube-proxy-4vf2s                 1/1     Running   0          22m
   kube-proxy-855xx                 1/1     Running   0          22m
   kube-proxy-m6db6                 1/1     Running   0          23m
   kube-scheduler-cdh105            1/1     Running   1          23m
   
   # 查看节点是否ready
   kubectl get nodes
   $ NAME     STATUS   ROLES                  AGE   VERSION
   cdh105   Ready    control-plane,master   23m   v1.23.17
cdh106   Ready    <none>                 23m   v1.23.17
   cdh107   Ready    <none>                 22m   v1.23.17
   ~~~
   
   

### 初始化失败, 重置

如果你在初始化的时候, 失败了, 或者中断了, 那么可以使用如下命令来重置（没有失败不要执行）

~~~shell
# 重置 kubeadm
kubeadm reset -f ; ipvsadm --clear  ; rm -rf ~/.kube

# 清理 kubelet 数据（防止节点状态残留）
sudo systemctl stop kubelet
sudo rm -rf /var/lib/kubelet/*
sudo rm -rf /etc/cni/net.d/*

# 确认 /etc/kubernetes/manifests/ 已空
ls /etc/kubernetes/manifests/
~~~





### 添加Master和Node到k8s集群

根据上面`kubeadm init`的结果, 我们将master和node加入到集群中

1. 添加Master02节点和Master03节点到k8s集群(通过`--control-plane`确定加入进来的是master)

   分别在master2和master3上执行

   ~~~shell
   $ kubeadm join 192.168.1.105:6443 
   --control-plane \
   --token 4nmo11.lz9pz0c056uma8rz \
           --discovery-token-ca-cert-hash sha256:fb8fe2f9d8a93a82f9da4849174bf104c9807575872b56c0e4626ed6aa8548e6
   ~~~

2. 添加Node01节点和Node02节点到k8s集群

   分别在node1和node2上执行

   ~~~shell
   $ kubeadm join 192.168.1.105:6443 --token 4nmo11.lz9pz0c056uma8rz \
           --discovery-token-ca-cert-hash sha256:fb8fe2f9d8a93a82f9da4849174bf104c9807575872b56c0e4626ed6aa8548e6
   ~~~

3. 在Master01节点上查看节点状态

   ~~~shell
   $ kubectl get node 
   NAME           STATUS     ROLES                  AGE     VERSION
   k8s-master01   NotReady   control-plane,master   7m11s   v1.23.17
   k8s-master02   NotReady   control-plane,master   2m28s   v1.23.17
   k8s-master03   NotReady   control-plane,master   102s    v1.23.17
   k8s-node01     NotReady   <none>                 106s    v1.23.17
   k8s-node02     NotReady   <none>                 84s 
   ~~~

4. 设置开机自启动

   ~~~shell
   systemctl enable --now kubelet
   ~~~

> 这里完成了k8s的搭建, 但是之后一定要关闭clash的tun模式, 否则通过svc的域名访问其他的pod会有问题
>
> ```shell
> systemctl restart containerd
> systemctl restart kubelet
> ```



### 测试集群

~~~shell
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pod,svc  
~~~

![image-20231028211718019](img/k8s笔记/image-20231028211718019.png)

访问`cdh105:32015`

<img src="img/k8s笔记/image-20231028211752090.png" alt="image-20231028211752090" style="zoom:33%;" />



### 卸载k8s和kubeadmin

~~~shell
# 停止 kubeadm 管理的组件
kubeadm reset -f

# 清理网络插件残留（flannel, calico 等）
rm -rf /etc/cni/net.d
rm -rf /var/lib/cni/
rm -rf /var/lib/kubelet/*
ip link delete cni0
ip link delete flannel.1

# 删除配置文件和证书
rm -rf ~/.kube
rm -rf /etc/kubernetes
rm -rf /var/lib/etcd

# 停止并禁用 kubelet
systemctl stop kubelet
systemctl disable kubelet

# 删除 kubeadm/kubelet/kubectl
yum remove -y kubeadm kubelet kubectl

# 清理镜像
crictl rmi --prune
~~~



# sealos搭建k8s集群

https://www.cnblogs.com/huangSir-devops/p/18847938

https://www.bilibili.com/video/BV1yT7SzkERQ/?spm_id_from=333.337.search-card.all.click&vd_source=f79519d2285c777c4e2b2513f5ef101a

## 什么是sealos？

Sealos 是一款基于 Kubernetes 的轻量级操作系统，专为云原生环境设计，主要用于快速部署和管理 Kubernetes 集群。它采用“容器化内核”的概念，将操作系统和 Kubernetes 深度集成，简化了集群的安装、运维和扩展流程。
sealos 是一个简单的 Golang 二进制文件，可以安装在大多数 Linux 操作系统中。支持在线和离线安装，适用于amd64和arm64架构。轻松管理节点，安装分布式应用，支持Containerd和Docker运行时。



### sealos核心特点

- 极简安装

  只需一条命令即可部署完整的 Kubernetes 集群（包括 Master 和 Worker 节点）。
  支持离线安装，适合内网或无外网环境。

- 容器化内核

  将操作系统核心组件（如 kubelet、containerd）容器化，实现环境隔离和版本控制。
  避免传统 Linux 发行版的依赖冲突问题。

- 多集群管理

  统一管理多个 Kubernetes 集群，支持集群生命周期管理（创建、扩容、升级、销毁）。

- 内置应用市场

  提供常见云原生应用（如 Prometheus、Istio、Nginx）的一键部署。

- 兼容性

  支持主流 Linux 发行版（如 CentOS、Ubuntu）作为底层系统。 适配 ARM 和 x86 架构。



### sealos相关资源

GitHub地址：https://github.com/labring/sealos
中文文档：https://sealos.run/docs/k8s/quick-start/install-cli



### sealos相关命令

sealos的相关命令，除了集群、节点操作管理之外需要注意一下，关于容器和镜像的命令都和docker一样，我们只需要把`docker`替换成`sealos`即可
示例：

```shell
[root@master01 ~]# sealos --help
sealos is a Kubernetes distribution, a unified OS to manage cloud native applications.
 
## 集群操作
Cluster Management Commands:
  apply         Run cloud images within a kubernetes cluster with Clusterfile
  cert          update Kubernetes API server's cert
  run           Run cloud native applications with ease, with or without a existing cluster
  reset         Reset all, everything in the cluster
  status        state of sealos
 
# 节点管理，添加node节点，删除node节点
Node Management Commands:
  add           Add nodes into cluster
  delete        Remove nodes from cluster
 
# 远程操作管理
Remote Operation Commands:
  exec          Execute shell command or script on specified nodes
  scp           Copy file to remote on specified nodes
 
Experimental Commands:
  registry      registry related
 
# 容器和镜像命令，和dockers一样
Container and Image Commands:
  build         Build an image using instructions in a Containerfile or Kubefile
  create        Create a cluster without running the CMD, for inspecting image
  diff          Inspect changes to the object's file systems
  inspect       Inspect the configuration of a container or image
  images        List images in local storage
  load          Load image(s) from archive file
  login         Login to a container registry
  logout        Logout of a container registry
  manifest      Manipulate manifest lists and image indexes
  merge         merge multiple images into one
  pull          Pull images from the specified location
  push          Push an image to a specified destination
  rmi           Remove one or more images from local storage
  save          Save image into archive file
  tag           Add an additional name to a local image
 
Other Commands:
  completion    Generate the autocompletion script for the specified shell
  docs          generate API reference
  env           prints out all the environment information in use by sealos
  gen           generate a Clusterfile with all default settings
  version       Print version info
 
Use "sealos <command> --help" for more information about a given command.
 
```



## kubernetes集群镜像版本支持说明



### 支持Containerd的k8s

推荐使用 Containerd 作为容器运行时 (CRI) 的集群镜像版本，Containerd 是一种轻量级、高性能的容器运行时，与 Docker 兼容。使用 Containerd 的 Kubernetes 镜像可以提供更高的性能和资源利用率。以下是支持 Containerd 的集群镜像版本支持说明：
![image](img/k8s笔记/3468887-20250426121645409-343133498.png)



### 支持Docker的k8s

当然，你也可以选择使用 Docker 作为容器运行时，以下是支持 Docker 的集群镜像版本支持说明：
![image](img/k8s笔记/3468887-20250426121723408-1107859490.png)



### 查看集群镜像

sealos 所有的集群镜像都可以在 cluster-image-docs 仓库里找到。

除了推送到 Docker Hub 之外，这些镜像还被同步到了阿里云的镜像仓库。

Docker Hub 上可以通过以下链接查看 Sealos 所有的集群镜像：https://hub.docker.com/u/labring

使用 [Registry Explorer](https://explore.ggcr.dev/) 可以查看 K8s 集群镜像的所有版本，直接输入 `registry.cn-shanghai.aliyuncs.com/labring/kubernetes`，然后点击“Submit Query”：
![image](img/k8s笔记/3468887-20250426122107582-1415535085.png)
就会看到这个集群镜像的所有 tag。

Docker Hub 同理，输入 `docker.io/labring/kubernetes` 即可查看所有 tag。

> Note: K8s 的小版本号越高，集群越稳定。例如 v1.29.x，其中的 x 就是小版本号。建议使用小版本号比较高的 K8s 版本。到本文截止时间为止，v1.29 最高的版本号是 v1.29.9，而 v1.30 最高的版本号是 v1.30.5，所以建议使用 v1.29.9。你需要根据实际情况来选择最佳的 K8s 版本



### Kubernetes集群镜像说明

Sealos 官方发布的集群镜像主要包括以下几种：

- kubernetes：使用 containerd 作为容器运行时（CRI）的 Kubernetes 镜像。
- kubernetes-docker：使用 docker 作为容器运行时（CRI）的 Kubernetes 镜像。
- kubernetes-crio：使用 crio 作为容器运行时（CRI）的 Kubernetes 镜像。



## 安装前置准备



### 环境信息

| 主机名   | IP地址    | 系统内核    | 系统规格 |
| -------- | --------- | ----------- | -------- |
| master01 | 10.0.0.30 | ubuntu22.04 | 2c4g     |
| node01   | 10.0.0.31 | ubuntu22.04 | 2c4g     |
| node02   | 10.0.0.32 | ubuntu22.04 | 2c4g     |



### sealos安装kubernetes要求

- 每个集群节点应该有不同的主机名。主机名不要带下划线。
- 所有节点的时间需要同步。
- 需要在 K8s 集群的第一个 master 节点上运行 sealos run 命令，目前集群外的节点不支持集群安装。
- 建议使用干净的操作系统来创建集群。不要自己装 Docker！
- 支持大多数 Linux 发行版，例如：Ubuntu、CentOS、Rocky linux。
- 支持 Docker Hub 中的所有 Kubernetes 版本。
- 支持使用 Containerd 作为容器运行时。
- 在公有云上安装请使用私有 IP。

[回到顶部](https://www.cnblogs.com/huangSir-devops/p/18847938#_labelTop)

## 极简安装以Docker为容器运行时的kubernetes单节点集群



### 前置准备

- 设置主机名，所有节点执行

```cpp
hostnamectl set-hostname master01
hostnamectl set-hostname node01
hostnamectl set-hostname node02
```

- 时间同步，所有节点执行

```bash
#同步时区
ln -svf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 
#下载ntpdate工具用于同步时间
apt -y install ntpdate
ntpdate ntp.aliyun.com
```

- 需要放开端口，所有节点执行
  尤其是云环境需要注意
  参考kubernetes官网：https://kubernetes.io/zh-cn/docs/reference/networking/ports-and-protocols/
  ![image](img/k8s笔记/3468887-20250426123310250-104476576.png)
  ![image](img/k8s笔记/3468887-20250426123318162-1110381153.png)
- 下载 Kubernetes 和容器化环境中常用的底层网络和系统工具，所有节点执行

```sql
apt-get update -y && apt-get install -y ebtables ethtool socat iptables
```



### master01节点下载sealos安装工具

下载地址：https://github.com/labring/sealos/releases/tag/v5.0.1

```yaml
[root@master01 ~]# wget https://github.com/labring/sealos/releases/download/v5.0.1/sealos_5.0.1_linux_amd64.tar.gz
[root@master01 ~]# tar -xvf sealos_5.0.1_linux_amd64.tar.gz
[root@master01 ~]# cp sealos /usr/bin/
# 查看信息
[root@master01 ~]# sealos version
SealosVersion:
  buildDate: "2024-10-09T02:18:27Z"
  compiler: gc
  gitCommit: 2b74a1281
  gitVersion: 5.0.1
  goVersion: go1.20.14
  platform: linux/amd64
```



### 下载集群镜像

这里使用sealos下载镜像，语法和docker一样，只不过docker替换成sealos即可

```csharp
# 下载k8s镜像
[root@master01 ~]# sealos pull registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.26.15
 
# 下载helm镜像
[root@master01 ~]# sealos pull  registry.cn-shanghai.aliyuncs.com/labring/helm:v3.13.2
 
# 下载calico镜像
[root@master01 ~]# sealos pull registry.cn-shanghai.aliyuncs.com/labring/calico:v3.26.5
```



### 运行命令安装集群

```dockerfile
sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.26.15 registry.cn-shanghai.aliyuncs.com/labring/helm:v3.13.2 registry.cn-shanghai.aliyuncs.com/labring/calico:v3.26.5 \
     --masters 10.0.0.30 \
     --nodes 10.0.0.31,10.0.0.32 -p root123
```

参数说明：

- --masters：k8s master节点地址列表
- --nodes：k8s node节点列表
- -p：ssh登录密码,这里我们使用密码即可
- -i：ssh登录的密钥，

最终显示如图即表示安装成功！！！
![image](img/k8s笔记/3468887-20250426125723482-859697525.png)

安装成功之后，我们等待所有的pod都启动成功。

```sql
[root@master01 ~]# kubectl get po -A
NAMESPACE          NAME                                       READY   STATUS    RESTARTS   AGE
calico-apiserver   calico-apiserver-59965665cb-dsfd8          1/1     Running   0          83s
calico-apiserver   calico-apiserver-59965665cb-k96cz          1/1     Running   0          83s
calico-system      calico-kube-controllers-5699c5bff4-744hp   1/1     Running   0          2m27s
calico-system      calico-node-972ns                          1/1     Running   0          2m28s
calico-system      calico-node-fqlml                          1/1     Running   0          2m28s
calico-system      calico-node-snmlg                          1/1     Running   0          2m28s
calico-system      calico-typha-6fdb6c64d6-b6pjb              1/1     Running   0          2m19s
calico-system      calico-typha-6fdb6c64d6-rsphw              1/1     Running   0          2m28s
calico-system      csi-node-driver-5bght                      2/2     Running   0          2m27s
calico-system      csi-node-driver-hgx6h                      2/2     Running   0          2m27s
calico-system      csi-node-driver-p4fsh                      2/2     Running   0          2m27s
kube-system        coredns-787d4945fb-2x7hw                   1/1     Running   0          2m56s
kube-system        coredns-787d4945fb-tnbgh                   1/1     Running   0          2m56s
kube-system        etcd-master01                              1/1     Running   0          3m9s
kube-system        kube-apiserver-master01                    1/1     Running   0          3m9s
kube-system        kube-controller-manager-master01           1/1     Running   0          3m10s
kube-system        kube-proxy-g92s8                           1/1     Running   0          2m56s
kube-system        kube-proxy-gdhd7                           1/1     Running   0          2m41s
kube-system        kube-proxy-tbmmc                           1/1     Running   0          2m42s
kube-system        kube-scheduler-master01                    1/1     Running   0          3m9s
kube-system        kube-sealos-lvscare-node01                 1/1     Running   0          2m34s
kube-system        kube-sealos-lvscare-node02                 1/1     Running   0          2m35s
tigera-operator    tigera-operator-5d4855cc5b-2pp5k           1/1     Running   0          2m36s
 
```

查看node节点是否都处于`Ready`状态

```sql
[root@master01 ~]# kubectl get nodes
NAME       STATUS   ROLES           AGE     VERSION
master01   Ready    control-plane   3m34s   v1.26.15
node01     Ready    <none>          3m2s    v1.26.15
node02     Ready    <none>          3m3s    v1.26.15
```

检查docker是否安装成功

```csharp
[root@master01 ~]# docker -v
Docker version 27.3.1, build ce12230
```

**到此为止，我们的K8s集群安装成功了！！！**



### 清理K8s集群

如果中途因为一些配置导致K8s集群安装失败，需要修改配置重新安装的话，我们可以使用`sealos reset`命令来重置集群继续安装

```delphi
[root@master01 ~]# sealos reset
2025-04-26T12:58:42 info are you sure to delete these nodes?
Do you want to continue on 'master01' cluster? Input 'master01' to continue: master01 ##这里需要输入主节点的名称
```

显示如图即表示清理成功
![image](img/k8s笔记/3468887-20250426131254092-365423709.png)

[回到顶部](https://www.cnblogs.com/huangSir-devops/p/18847938#_labelTop)

## 自定义配置安装（推荐使用！！！）

sealos支持自定义配置Kubernetes集群，实现高效的集群管理，可以自定义pod的网段以及calico的网段.

使用`sealos gen`生成一个Clusterfile

```bash
sealos gen registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.26.15 registry.cn-shanghai.aliyuncs.com/labring/helm:v3.13.2 registry.cn-shanghai.aliyuncs.com/labring/calico:v3.26.5 \
     --masters 10.0.0.30 \
     --nodes 10.0.0.31,10.0.0.32 \
     -p root123 \
     -o Clusterfile
```

生成Clusterfile后，可以根据需要更新集群的配置，例如要修改pods的CIDR范围，就可以修改`networking.podSubnet` 和 `spec.data.spec.calicoNetwork.ipPools.cidr` 字段。

最终生成的Clusterfile像这样

```yaml
[root@master01 ~]# cat Clusterfile
apiVersion: apps.sealos.io/v1beta1
kind: Cluster
metadata:
  creationTimestamp: null
  name: default
spec:
  hosts:
    - ips:
        - 192.168.0.2:22
        - 192.168.0.3:22
        - 192.168.0.4:22
      roles:
        - master
        - amd64
    - ips:
        - 192.168.0.5:22
        - 192.168.0.6:22
        - 192.168.0.7:22
      roles:
        - node
        - amd64
  image:
    - labring/kubernetes:v1.25.0
    - labring/helm:v3.8.2
    - labring/calico:v3.24.1
  ssh:
    passwd: xxx
    pk: /root/.ssh/id_rsa
    port: 22
    user: root
status: {}
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  podSubnet: 10.160.0.0/12
---
apiVersion: apps.sealos.io/v1beta1
kind: Config
metadata:
  name: calico
spec:
  path: charts/calico/values.yaml
  strategy: merge
  data: |
    installation:
      enabled: true
      kubernetesProvider: ""
      calicoNetwork:
        ipPools:
        - blockSize: 26
          cidr: 10.160.0.0/12
          encapsulation: IPIP
          natOutgoing: Enabled
          nodeSelector: all()
        nodeAddressAutodetectionV4:
          interface: "eth.*|en.*"
 
```



### 启动集群

运行 `sealos apply -f Clusterfile` 启动集群。集群运行成功后会把 Clusterfile 保存到 `/root/.sealos/default/Clusterfile` 文件中，可以修改其中字段来重新 apply 对集群进行变更。

```csharp
# 启动集群，
[root@master01 ~]# sealos apply -f Clusterfile
 
# 检查节点
[root@master01 ~]# kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   81s   v1.26.15
node01     Ready    <none>          47s   v1.26.15
node02     Ready    <none>          49s   v1.26.15
 
# 查看/root/.sealos/default/Clusterfile
[root@master01 ~]# ll /root/.sealos/default/Clusterfile
-rw-r--r-- 1 root root 8401 Apr 26 13:20 /root/.sealos/default/Clusterfile
```

[回到顶部](https://www.cnblogs.com/huangSir-devops/p/18847938#_labelTop)

## 安装以Containerd为容器运行时的kubernetes集群

运行下面的命令即可，当然也可以使用Clusterfile自定配置安装

```dockerfile
# 直接运行
sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.26.15 registry.cn-shanghai.aliyuncs.com/labring/helm:v3.13.2 registry.cn-shanghai.aliyuncs.com/labring/calico:v3.26.5 \
     --masters 10.0.0.30 \
     --nodes 10.0.0.31,10.0.0.32 -p root123
```

安装成功，显示如图：
![image](img/k8s笔记/3468887-20250426133319145-1138960186.png)

以containerd为容器运行时的kubernetes集群没有docker命令，只有sealos命令，sealos可以完成docker的大部分操作，例如拉取镜像，运行容器，构建镜像等等一系列操作。语法和docker一样

[回到顶部](https://www.cnblogs.com/huangSir-devops/p/18847938#_labelTop)

## 安装高可用的kubernetes集群

安装高可用的kubernetes集群也很简单，只需要通过`sealos run`命令中的`--masters`选项指定多个节点即可
示例：

```dockerfile
sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.26.15 registry.cn-shanghai.aliyuncs.com/labring/helm:v3.13.2 registry.cn-shanghai.aliyuncs.com/labring/calico:v3.26.5 \
     --masters 10.0.0.30,10.0.0.34,10.0.0.33 \
     --nodes 10.0.0.31,10.0.0.32 -p root123
```

[回到顶部](https://www.cnblogs.com/huangSir-devops/p/18847938#_labelTop)

## sealos针对集群的扩缩容



### 前置准备

- 时间同步
- 云环境要放开端口
  参考kubernetes官网：https://kubernetes.io/zh-cn/docs/reference/networking/ports-and-protocols/
- 安装k8s使用的底层工具

```sql
apt-get update -y && apt-get install -y ebtables ethtool socat iptables
```



### 添加node节点

```csharp
sealos add --nodes='10.0.0.21' -p '!Xinxin123'
```

如图表示扩容成功
![image](img/k8s笔记/3468887-20250426134637990-1049358351.png)

检查一下

```sql
[root@master01 ~]# kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master     Ready    <none>          40s   v1.26.15
master01   Ready    control-plane   14m   v1.26.15
node01     Ready    <none>          14m   v1.26.15
node02     Ready    <none>          14m   v1.26.15
```



### 删除node节点

```go
sealos delete --nodes='10.0.0.21'
```



### 添加master节点

```csharp
sealos add --master='10.0.0.21' -p '!Xinxin123'
```



### 删除master节点

```go
sealos delete --master='10.0.0.21' -p '!Xinxin123'
```

[回到顶部](https://www.cnblogs.com/huangSir-devops/p/18847938#_labelTop)

## sealos的私有镜像仓库

参考文档：https://sealos.run/docs/k8s/operations/registry/using_sealoshub_private_registry
sealos 的私有仓库默认运行在集群的第一个节点上，第一个节点是指创建集群的时候输入的第一个节点的地址，使用下面的命令查看守护进程的状态。

```yaml
[root@master01 ~]# systemctl status registry.service
● registry.service - registry: The sealos registry
     Loaded: loaded (/etc/systemd/system/registry.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-04-26 13:32:01 CST; 23min ago
       Docs: https://www.sealos.io/docs/Intro
   Main PID: 32257 (registry)
      Tasks: 7
     Memory: 72.5M
        CPU: 40.117s
     CGroup: /system.slice/registry.service
             └─32257 /usr/bin/registry serve /etc/registry/registry_config.yml
```



### 登录私有容器镜像仓库

sealos 私有仓库使用 --net host 参数运行在 HTTP 下，应当在本地配置 insecure-registries，然后使用第一个节点的 IP 地址进行连接，Docker 客户端配置参考如下：

```json
{
  "insecure-registries": ["192.168.1.10:5000"],
}
```

使用 `sealos login` 命令来进行登录，默认用户名与密码是 `admin:passw0rd`，默认域名是：sealos.hub，该域名在我们安装k8s集群时，sealos默认帮我们添加好了hosts解析，默认端口是5000

```csharp
[root@master01 ~]# cat /etc/hosts
127.0.0.1 localhost
127.0.1.1 master
# sealos
10.0.0.30 sealos.hub
10.0.0.30 apiserver.cluster.local
 
```

sealos登录私有仓库

```css
sealos login -u admin -p passw0rd sealos.hub:5000
```

也可以使用 docker login 命令。

```css
docker login -u admin -p passw0rd sealos.hub:5000
```

# K8S的网络模型

Kubernetes的网络模型假定了所有的Pod都在一个现成可以直接连通的扁平的网络空间中, 这在GCE (Google Compute Engine) 里面是现成的网络模型,  Kubernetes假定这个网络已经存在了

但是在私有云里面搭建Kubernetes集群, 就不能假定这个网络已经存在了, 我们需要自己实现这个网络, 将不同节点上的Docker容器之间的相互访问先打通, 然后才能运行Kubernetes



在同一个Pod之间, 不同的容器因为共享`Pause`容器的网络栈, 所以可以直接通过`localhost`来调用

而不同的Pod之间, 我们可以通过Overlay Network 来相互通讯, 而Overlay Network可以通过Flannel来实现

Pod与Service之间的通讯, 我们可以通过各个节点的Iptables规则来实现

Pod与外网通讯:  Pod向外网发送请求，查找路由表，转发数据包到宿主机的网卡，宿主网卡完成路由选择后，iptables执行Masquerade，把源IP更改为宿主网卡的IP，然后向外网服务器发送请求

外网访问Pod:Service   



# Namespace

namespace主要用于隔离pod, controller, service, pv, pvc等资源

如果我们直接调用`kubectl get xxx` 实际上获取的是`default`命名空间下的资源信息

如果我们要查看其他命名空间中的资源的话, 那么可以调用`kubectl get xxx -n namespace_name` 来获取指定命名空间下的namespace



相关命令

1. 创建namespace

   - 直接命令调用

     ~~~shell
     kubectl create ns xxx # 来创建namespace
     ~~~

   - 通过yaml来调用

     ~~~yaml
     kind: Namespace  #类型为Namespace
     apiVersion: v1 #类型为Namespace
     metadata:
       name: orange-test  #命名空间名称
       labels:
         name: orange-test-v1 
     ~~~

     ```shell
     kubectl create -f ns.yaml
     ```

2. 查看和设置默认的namespace

   ~~~shell
   kubectl config view --minify --output 'jsonpath={..namespace}' # 如果不输出任何内容, 那么使用的是默认的命名空间
   
   kubectl config set-context --current --namespace=<your-namespace> # 设置当前命令行默认使用的namespace, 这样就不用每次输入 -n xxx来指定需要使用的namespace了
   ~~~

   

3. 其他的命令

   ~~~shell
   kubectl get ns # 查看所有的namespace
   
   kubectl delete ns xxx # 删除ns
   ~~~

   











# Pod

对于一个Pod, K8S首先会启动一个名为`Pause`的容器,  然后其他的业务容器会共享`Pause`的网络栈和数据卷, 他有业务容器就可以使用`localhost`的来调用其他的容器中的应用了

同时多个业务容器的端口也不能冲突了, 因为他们共享`Pause`的网络栈



## pod的生命周期以及创建的过程

![image-20250704221832091](img/k8s笔记/image-20250704221832091.png)

当我们通过`kubectl create -f xxx.yaml`来创建pod的时候,  Kubernetes

- 首先会对容器的环境进行初始化

- 创建出`Pause`容器, 并挂载数据卷到他身上

- 创建InitC 容器, 来执行一些准备步骤

  如果我们的业务Pod, 需要在存储卷中有特定的文件, 才能够启动, 那么我们就可以通过InitC容器, 让他来准备这些文件, 到存储卷中

  InitC容器可以有多个, 只要上一个InitC容器执行完毕, 正常退出, 那么就会启动下一个InitC容器, 执行下一个步骤

- 所有的InitC容器都正常执行完毕

- **并行**创建Pod中所有的容器, 并且并发执行容器的`containers[].lifecycle.postStart`钩子

- 对容器进行启动探针检测, 就绪探针/存活探针检测

- 执行容器的`containers[].lifecycle.preStop`钩子, 并销毁容器



## InitC容器

一个Pod里面有多个容器,  并且也可以有多个先于业务容器启动的InitC容器

InitC容器与业务容器非常的像, 除了如下两点:

- InitC容器总是运行到完成为止
- 每个InitC容器必须在上一个InitC容器完成后, 才能启动
- 如果pod重启了, 那么所有的InitC容器都必须重新执行

如果Pod的InitC容器启动失败, 那么Kubernetes会根据restartPolicy来重新处理这个Pod



InitC的主要作用有

- 因为InitC容器是在`pause`容器启动之后启动的, 所以可以访问数据卷, 所以可以帮助业务容器来准备一些启动时必须的文件

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-init-demo
spec:
  containers:
    - name: main-container
      image: nginx
      ports:
        - containerPort: 80
      volumeMounts:
        - name: shared-data
          mountPath: /usr/share/nginx/html

  initContainers:
    - name: init-download-data
      image: busybox
      command: ['sh', '-c', 'echo "Downloading data..." > /data/index.html']
      volumeMounts:
        - name: shared-data
          mountPath: /data
    - name: init-permissions
      image: busybox
      command: ['sh', '-c', 'chmod 755 /data/index.html']
      volumeMounts:
        - name: shared-data
          mountPath: /data
  volumes:
    - name: shared-data
      emptyDir: {}
~~~

## 探针

探针是由Kubelet对容器的定期诊断,  主要由三种形式的探测

- startupProbe 启动探针

  主要是用来检查容器中的应用是否启动成功, 特别是针对慢启动应用

  如果在规定时间内没有启动成功就会杀死容器并执行restartPolicy

  如果探测成功就表示应用成功启动了, 后续就不会再进行探测了

- livenessProbe 存活探针

  启动探针成功之后才会启动存活探针, 他主要用来检查容器中的应用是否存活

  检查失败会杀死容器,然后根据restartPolicy来操作

  存活探针会伴随pod的一生, 直到pod被删除

- readinessProbe 就绪检查

  启动探针成功之后才会启动继续探针, 他主要用来检查应用是否能够正常提供服务

  检查失败表示当前应用不能正常提供服务, 就把pod的ready状态改为false并从Service的负载均衡中从剔除

  检查成功后, 又会将pod的ready状态改为true,并重新加入到Service的负载均衡中

  当一个 Pod 内的所有容器都就绪时，才能认为该 Pod 就绪

  就绪检查会伴随pod的一生, 直到pod被删除



同时上面的三种形式的探针, 都可以通过如下的三种形式来实现

- ExecAction: 在容器内执行指定命令, 如果命令退出时返回码为0, 那么认为诊断成功
- TCPSocketAction: 对指定容器的端口进行tcp检查,  如果端口打开, 那么认为是诊断成功
- HTTPGetAction: 对指定容器的端口, 调用http get请求, 如果响应状态码 >=200 并且 < 400, 那么认为诊断成功

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: jvm-app-with-cmd-probes
spec:
  containers:
    - name: jvm-app
      image: openjdk:17
      # jvm启动之后, 会创建一个app-started文件
      command: ["sh", "-c", "java -jar /app/myapp.jar & touch /tmp/app-started && wait"]

      # 启动探针：
      startupProbe:
        exec:
          # 检测 /tmp/app-started 是否存在, 如果存在, 那么命令的状态码为0, 表示检测成功
          command: ["sh", "-c", "test -f /tmp/app-started"] 
        iniinitialDelaySeconds: 10 # 延迟10s之后开始探测
        timeoutSeconds: 1 # 如果命令1s内没有返回, 认为检测失败了
        periodSeconds: 5  # 每5s执行一次探测
        failureThreshold: 30 # 如果连续30次探测失败了, 那么认为启动失败, 根据restartPolicy处理
        successThreshold: 1 # 连续1次探测成功了后, 认为探测成功了, 因为这里是启动探测, 必须设置为1
        terminationGracePeriodSeconds: 30 # 如果探针失败, 会关闭容器, 然后根据restartPolicy来处理Pod, 这里表示等待容器停止的时间, 超过这个时间会强制停止

      # 存活探针（容器是否挂掉）
      livenessProbe:
        tcpSocket:
          port: 8080 # 看看8080端口是否开启了tcp, 如果开启了认为检测成功
        iniinitialDelaySeconds: 10 
        timeoutSeconds: 1 # 如果命令1s内没有返回, 认为检测失败了
        periodSeconds: 5  # 每5s执行一次探测
        failureThreshold: 30 # 如果连续30次探测失败了, 那么认为启动失败
        successThreshold: 1 # 连续1次探测成功了后, 认为探测成功了, 存活探针这里必须是1
        terminationGracePeriodSeconds: 30 # 如果探针失败, 会关闭容器, 然后根据restartPolicy来处理Pod, 这里表示等待容器停止的时间, 超过这个时间会强制停止

      # 就绪探针（应用是否可以对外服务）
      readinessProbe:
        httpGet:
          # 访问容器的http://8080:/read, 看看状态码是不是>=200 < 400, 如果是, 那么探测成功
          path: /ready
          port: 8080
          HttpHeaders:
          - name: aaa
            value: bbb
        iniinitialDelaySeconds: 10 
        timeoutSeconds: 1 # 如果命令1s内没有返回, 认为检测失败了
        periodSeconds: 5  # 每5s执行一次探测
        failureThreshold: 30 # 如果连续30次探测失败了, 那么认为启动失败
        successThreshold: 3 # 连续3次探测成功了后, 认为探测成功了, 因为这里是启动探测, 必须设置为1
        terminationGracePeriodSeconds: 30 # 如果探针失败, 会关闭容器, 然后根据restartPolicy来处理Pod, 这里表示等待容器停止的时间, 超过这个时间会强制停止
~~~

## 容器的启动和关闭钩子

Kubernetes在启动容器的时候, 会并行的调用`lifecycle.postStart`中的钩子

同时在容器关闭之前, 会调用`lifecycle.preStop`中的钩子

~~~YAML
apiVersion: v1
kind: Pod
metadata:
  name: jvm-lifecycle-demo
spec:
  containers:
    - name: jvm-app
      image: openjdk:17
      command: ["sh", "-c"]
      args:
        - |
          echo "Starting Java app..." && \
          java -jar /app/myapp.jar

      lifecycle:
        postStart:
          exec:
            command:
              - sh
              - -c
              - echo "[postStart] App started at $(date)" >> /tmp/lifecycle.log

        preStop:
          exec:
            command:
              - sh
              - -c
              - |
                echo "[preStop] Cleaning up at $(date)" >> /tmp/lifecycle.log && \
                sleep 5  # 模拟清理动作

      volumeMounts:
        - name: tmp-volume
          mountPath: /tmp

  volumes:
    - name: tmp-volume
      emptyDir: {}
~~~



## Pod的状态

当我们调用`kubectl get pod -n namespace_name`的时候, 会显示pod的状态

~~~shell
kubectl get pods -A
NAMESPACE          NAME                                        READY   STATUS              RESTARTS   AGE
kube-system        calico-kube-controllers-68fb684666-lmrcn    1/1     Running             0          27h
kube-system        calico-node-dq5lx                           1/1     Running             0          27h
~~~

status的状态有如下几种

- Pending 挂起

  表示创建Pod的命令已经被Kubernetes, 但是Pod中还有一个或者多个容器尚未创建. 

  可能是因为还在调度Pod到特定的容器上, 或者通过网络下载镜像

- Running 运行中

  一个Pod已经被绑定到了一个Node上, Pod中所有的容器都已经创建完毕

  至少有一个容器正在运行, 或者正在处于启动/重启状态

- Succeeded 成功

  Pod中所有的容器都一个成功停止, 执行完毕

- Failed 失败

  Pod中所有的容器都已经停止, 并且至少有一个容器是失败停止的

- Unknown 未知

  Kubernetes Master与Node网络通讯失败,  无法获取Pod的状态









## Pod文件格式解析

你可以通过`kubectl explain pod`来查看pod文件中可以写哪些内容

如果你想要看特定的字段下, 有哪些子字段, 那么可以通过类似`kubectl explain pod.apiVersion`, `kubectl explian pod.spec.nodeSelector`的形式来查看

~~~yaml
apiVersion: v1       #必选，版本号，例如v1
kind: Pod       #必选，Pod
metadata:       #必选，元数据
  name: string       #必选，Pod名称
  namespace: string    #必选, Pod所属的命名空间
  labels:      # 指定pod的label
    name1: string1  
    name2: string2
  annotations:       #自定义注释列表
    name1: string1  
    name2: string2
spec:         #必选，Pod中容器的详细定义
#-----------------------重启策略-----------------------------------------------
  # pod重启策略 [Always(默认, 容器退出后总是重启容器) | OnFailure(只有退出状态码为非0时才重启容器) | Never(不管什么情况退出, 都不重启)] 
  # 注意: Always也不是立即重启容器, 而是随重启次数等待越来越长的时间, 在等待的时候会显示CrashLoopBackOff状态
  restartPolicy: Always 
#-----------------------------节点选择器----------------------------------------    
  # 设置NodeSelector表示将该Pod调度到包含这个label的node上，以key：value的格式指定
  # 通过kubectl label node node_name  label_name=value  来给node设置label
  # 通过kubectl get nodes --show-labels 来显示node的label
  nodeSelector: 
    lable1: value
    lable2: value
#----------------------------------------------------------------------------
  affinity:
#-----------------------节点亲和性------------------------------
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution: # 硬亲和性, 选择的节点的label必须满足这些条件
        nodeSelectorTerms:
          - matchExpressions:
            - key: disktype # key
              operator: In # 操作符[In NotIn Exists Gt Lt Equal DoesNotExists]
              values: # value
              - ssd 
      preferredDuringSchedulingIgnoredDuringExecution: # 软亲和性, 优先选择label满足这些条件的节点
      - weight: 1 # 权重
        preference:
          matchExpressions:
            - key: disktype # key
              operator: In  # 操作符[In NotIn Exists Gt Lt Equal DoesNotExists]
              values: # value
              - ssd 
#---------------------------------------------------------------
  imagePullSecrets: #Pull镜像时使用的secret名称，以key：secretkey格式指定
  - name: string
  hostNetwork: false  #是否使用主机网络模式，默认为false，如果设置为true，表示使用宿主机网络,而不是docker网桥, 同时设置了true将导致同一台主机上无法启动两个相同的副本
#---------------------container-----------------------------------
  containers:      #必选，Pod中容器列表, 是一个数组, 可以指定多个containers
  - name: string     #可选，容器名称, 不写随机创建
    image: string    #必选，容器的镜像名称
    # 可选, 获取镜像的策略 IfnotPresent(默认)表示优先使用本地镜像，否则下载镜像，Nerver表示仅使用本地镜像, Alawys表示总是下载镜像 
    imagePullPolicy: [Always | Never | IfNotPresent] 
    # command和args都是可选的, 都是数组, command不指定时会使用打包时使用的启动命令, args默认为空
    command: ["sh", "-c"]
    args: ["echo Hello && sleep 3600"]
    workingDir: string     #可选,容器的工作目录
#----------- 端口暴露-----------------------------------------------------
    ports:       #需要暴露的端口库号列表
      - name: string     #端口号名称
        containerPort: int   # 需要占用的容器的端口号
        hostPort: int    # 主机端口号，默认与Container相同, !!!!注意!!!!如果指定了hostPort, 那么同一台主机上无法启动两个相同的副本, 因为端口号会冲突
        protocol: string     #端口协议，支持TCP和UDP，默认TCP
#---------------环境变量-----------------------------------------------------
    env:       #容器运行前需设置的环境变量列表
      - name: string     #环境变量名称
        value: string    #环境变量的值
#--------------------数据卷挂载------------------------------------
    volumeMounts:    #挂载到容器内部的存储卷配置
      - name: string     # 引用pod定义的共享存储卷的名称，需用volumes[]部分定义的的卷名
        mountPath: string    #存储卷在容器内mount的绝对路径，应少于512字符
        readOnly: boolean    #是否为只读模式
#--------------------资源限制-----------------------------------------
    resources:       #资源限制和请求的设置
      limits:      # 资源最大的设置
        cpu: string    #Cpu的限制，1000m表示1个core，将用于docker run --cpu-shares参数
        memory: string     #内存限制，单位可以为Mib/Gib，将用于docker run --memory参数
      requests:      #资源最小的设置
        cpu: string    #Cpu请求，容器启动的初始可用数量
        memory: string     #内存清楚，容器启动的初始可用数量
#--------------资源调整时是否重启-------------------------------------
    # 指定在运行时, 重新分配资源时是否需要重启容器(一般调整cpu都无需重启容器, 而调整内存需要)
    # resourceName: 调整的资源 cpu, memory
    # restartPolicy: NotRequired(默认)不重启容器,  RestartContainer重启容器
    resizePolicy:
      - resourceName: cpu
        restartPolicy: NotRequired
      - resourceName: memory
        restartPolicy: RestartContainer
#-----------------启动销毁钩子函数----------------------
    lifecycle:
      postStart: # 容器创建后立即执行, 和容器的代码是异步执行的
        exec:
          command: ["/bin/sh", "-c", "echo helloworld > /usr/share/message"]
      preStop: # 容器结束前执行
        exec:
          command: ["/bin/sh", "-c", "echo stop > /usr/share/message"]
#--------------------------健康检查和重启机制---------------
    # 探针主要有三种: startupProbe, livenessProbe, readinessProbe
    # 
    # startupProbe 启动探针: 
    #   主要是用来检查容器中的应用是否启动成功, 特别是针对慢启动应用
    #   如果在规定时间内没有启动成功就会杀死容器并执行restartPolicy, 
    #   如果探测成功就表示应用成功启动了, 后续就不会再进行探测了
    # livenessProbe 存活探针: 
    #   启动探针成功之后才会启动存活探针, 他主要用来检查容器中的应用是否存活
    #   检查失败会杀死容器,然后根据restartPolicy来操作
    #   存活探针会伴随pod的一生, 直到pod被删除
    # readinessProbe 就绪检查: 
    #   启动探针成功之后才会启动继续探针, 他主要用来检查应用是否能够正常提供服务
    #   检查失败表示当前应用不能正常提供服务, 就把pod的ready状态改为false并从Service的负载均衡中从剔除
    #   当检查成功后, 又会将pod的ready状态改为true,并重新加入到Service的负载均衡中
    #   当一个 Pod 内的所有容器都就绪时，才能认为该 Pod 就绪
    #   就绪检查会伴随pod的一生, 直到pod被删除
    # 
    # 在实际中, 就绪探针和存活探针都使用相同的http, 但是存活探针的failureThreshold比较大, 这样如果短时间失败就把pod从负载均衡器中提出, 如果长时间失败就会杀死容器
    
    livenessProbe:     
      # 检查方法有exec、httpGet和tcpSocket
      # exec: 执行command进行状态检查, 如果command的退出状态码是0, 表示成功, 其他表示不成功, 可以通过echo $? 来输出上一个命令的退出状态码
      # http: 对容器调用http方式检查状态, 返回>=200  <400范围的状态码表示成功
      # tcopSocket: 发起tcp socket建立成功即表示存活   
      exec:      #对Pod容器内检查方式设置为exec方式
        command: [string]  #exec方式需要制定的命令或脚本
      httpGet:       #对Pod内个容器健康检查方法设置为HttpGet，需要制定Path、port
        path: string
        port: number
        host: string
        scheme: string
        HttpHeaders:
        - name: string
          value: string
      tcpSocket:     #发起tcp socket建立成功即表示存活
         port: number
      initialDelaySeconds: 10  # 初次探测的延迟时间，单位为秒, 如果定义了启动探针，则存活探针和就绪探针的延迟将在启动探针已成功之后才开始计算。 默认是 0 秒，最小值是 0。
      timeoutSeconds: 1   #对容器健康检查探测等待响应的超时时间，单位秒，默认1秒, 最小值1秒
      periodSeconds: 1    #对容器监控检查的定期探测时间设置，单位秒，默认10秒一次, 最小值1秒
      successThreshold: 1 # 探针在失败后，被视为成功的最小连续成功数。默认值是 1。 存活和启动探测的这个值必须是 1。最小值是 1。
      failureThreshold:  # 探针连续失败了 failureThreshold 次之后， Kubernetes 认为总体上检查已失败
      terminationGracePeriodSeconds: 30 # 触发停止操作等待容器停止的时间, 超过这个事件将会强制停止容器, 默认为30 秒，最小值为 1
#---------------------定义数据卷---------------------------------------------
  volumes:       #在该pod上定义共享存储卷列表
    - name: string     # 共享存储卷名称 （volumes类型有很多种）
      emptyDir: {}     #类型为emtyDir的存储卷，与Pod同生命周期的一个临时目录, 即使pod重启和停止。
      
      hostPath: string     #类型为PersistentVolume 的存储卷，表示挂载Pod所在宿主机的目录, 生产上不会使用
        path: string     #Pod所在宿主机的目录，将被用于同期中mount的目录
      secret:      #类型为secret的存储卷，挂载集群与定义的secre对象到容器内部
        scretname: string  
        items:     
        - key: string
          path: string
      configMap:     #类型为configMap的存储卷，挂载预定义的configMap对象到容器内部
        name: string
        # 也可以不写items, 默认会将configmap中的所有配置都作为数据卷
        items:
        - key: string
          path: string
#------------------------init容器------------------
  # 这些容器在 Pod 初始化期间运行, 运行完就结束了, 然后再启动正常的container
  # 文档: https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-pod-initialization/
  # init C 不能并行执行, 并且执行失败, 会重新执行pod的restartPolicy
  initContainers:
  - name: install
    image: busybox:1.28
    command: ["wget", "-O", "/work-dir/index.html", "http://info.cern.ch"] # 下载文件到挂载目录下, 给业务容器使用
    volumeMounts:
    - name: workdir
      mountPath: "/work-dir"
~~~











# Controller

## ReplicationController 和 ReplicaSet

ReplicationController用来确保容器的副本数始终保持在用户定义的副本数,  即如果有容器异常退出, 那么就会创建出新的Pod来替代;  而如果异常多出来的容器, 那么就会自动回收

在新版本的Kubernetes中建议使用ReplicaSet来替代ReplicationController



ReplicaSet相较于ReplicationController来说, 也是用于保存容器副本数处于用户的期望值上, 但是区别在于ReplicaSet支持集合式的Selector



虽然ReplicaSet可以独立使用, 但是一般还是建议使用Deployment来自动管理ReplicaSet, 因为Deployment相较于ReplicaSet能够支持滚动更新



### yaml

详细的模板信息可以通过`kubectl explain rs `来查看

如果想要查看更详细的字段, 可以通过`kubectl explain rs.spec.replicas`来查看spec下的replicas字段的说明

~~~yaml
apiVersion: extensions/v1beta1
kind: ReplicaSet
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec: # 这一部分跟pod是一样的, pod中可以指定什么这里就能指定什么
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 80
~~~

然后通过`kubectl create -f rs.yaml`来创建这个ReplicaSet

### 相关shell

~~~ shell
kubectl get rs -A # 查看所有namespace中的rs
kubectl get rs -n namespace # 查看指定namespace中的rs
kubectl get rs -n namespae -o wide # 查看指定namespace中的rs, 并显示相对详细的信息

kubectl describe rs -n namespace rs_name # 描述rs的详细信息
kubectl describe rs -n namespace rs_name -o json # 以json的形式显示rs的详细信息

kubectl delete rs -n namespace_name rs_name # 删除指定的rs, 会连同pod一起删除
~~~



## 实践

1. 查看当前的ReplicaSet是哪个Deployment创建的

   ~~~shell
   ​~~~shell
   [root@node173 ~]# kubectl describe rs -n service-software   seasqlcache-cluster-live-68c59c7dd9
   Name:           seasqlcache-cluster-live-68c59c7dd9
   Namespace:      service-software
   Selector:       app.kubernetes.io/name=seasql-base-live,pod-template-hash=68c59c7dd9
   Labels:         app.kubernetes.io/name=seasql-base-live
                   pod-template-hash=68c59c7dd9
   Annotations:    deployment.kubernetes.io/desired-replicas: 1
                   deployment.kubernetes.io/max-replicas: 2
                   deployment.kubernetes.io/revision: 1
                   meta.helm.sh/release-name: seasqlcache-cluster
                   meta.helm.sh/release-namespace: service-software
   Controlled By:  Deployment/seasqlcache-cluster-live
   Replicas:       1 current / 1 desired
   Pods Status:    1 Running / 0 Waiting / 0 Succeeded / 0 Failed
   Pod Template:
   ...................
   ~~~

   可以看到`Controlled By:  Deployment/seasqlcache-cluster-live`表示当前这个ReplicaSet是被Deployment中的`seasqlcache-cluster-live`创建并控制的

2. 如何查看当前ReplicaSet管理了哪些pod?

   可以通过名字来确认, 如果我们创建了一个名为`example`的ReplicaSet,  那么这个ReplicaSet创建的Pod就会名为`example-${random}`

   ~~~shell
   [root@node173 ~]# kubectl get rs -n service-software | grep seaio-6fc66db57f
   seaio-6fc66db57f                      1         1         1       33h
   [root@node173 ~]# kubectl get pod -n service-software | grep seaio-6fc66db57f
   seaio-6fc66db57f-5nk4v                      1/1     Running             0          33h
   ~~~

   











## Deployment 控制器

### 概述

**一个Deployment只能控制一个Pod, 一个pod可以有多个副本**

Deployment控制器能够实现的功能

1. 副本保持

   Deployment并没有实现直接实现副本保持的功能, 而是通过控制ReplicaSet来间接实现副本控制的功能

   在创建Deployment Controller的时候, 会创建出一个ReplicaSet Controller, 通过ReplicaSet控制器来控制pod的副本数量

   <img src="img/k8s笔记/image-20231013150941431.png" alt="image-20231013150941431" style="zoom:33%;" />

2. 滚动升级和回滚

   在滚动升级的时候, Deployment Controller会再创建一个ReplicaSet Controller, 然后由这个ReplicaSet来产生新的版本的容器, 原来的ReplicaSet Controller将会被停用(不会删除)

   并且更新过程是这样的:

   1. 新的ReplicaSetController先创建25%replica的容器, 等他们启动
   2. 旧的ReplicaSetController关闭25%replica的容器, 依次循环

   <img src="img/k8s笔记/image-20231013151055594.png" alt="image-20231013151055594" style="zoom:33%;" />

   而在回滚的时候, 旧的ReplicaSet会被重写启用, 重新创建旧版本的Pod, 而新的ReplicaSet会被停用,并关闭新版本的Pod

   当然, 你也可以通过参数来控制升级和回滚过程中的策略

   ~~~yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: my-app
     labels:
       app: my-app
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: my-app
     template:
       metadata:
         labels:
           app: my-app
       spec:
         containers:
         - name: nginx
           image: nginx:latest
           ports:
           - containerPort: 80
     # 当我们使用kubectl upgrade更新pod的时候, 或者通过kubectl delete同时删除多个pod的时候
     # 应该应该使用怎么样的策略去替换已经存在的pod
     strategy:
       # 可选地值有:
       # RollingUpdate: 默认的选项, 删除一部分旧的pod然后启动一部分新版本的pod, 如此往复直到替换所有旧的pod, 确保服务不中断
       # Recreate: 全部删除旧的pod, 然后再创建新版的pod, 会造成服务暂时不可用
       type: RollingUpdate
       # 只有在type为RollingUpdate的时候可以选择这个参数, 用于指定RollingUpdate的参数
       rollingUpdate:
         maxSurge: 25% # 允许临时超出副本数的最大比例（或固定数值，如 1）
         # 更新过程中允许不可用的 Pod 比例（或固定数值，如 1）
         # 默认值为25%, 此时会先删除25%的旧版本的pod, 然后创建25%新版本的pod, 如此往复
         # 如果设置为1, 那么会先删除1个旧版本的pod, 然后创建1个新版本的pod, 直到更新完所有的pod
         maxUnavailable: 25%
   ~~~

   

3. 扩缩容

4. 暂停和继续Deployment





### yaml解析

~~~yaml
apiVersion: apps/v1      
kind: Deployment     
metadata:       
  name: string       # 必填，Deployment名称, 同时根据该名字生成pod名字, 生成Deployment也会删除pod
  # #必填，Deployment名称空间, 创建的pod也会在该命名空间下
  # 该命名空间必须先存在, 可以通过kubectl create ns xxx 来创建namespace
  # 通过kubectl get ns 查看namespace
  # 通过kubectl delete ns xxx 删除ns
  namespace: string    
  labels:      #自定义标签
    - name: string     #自定义标签名字<key: value>
  annotations:       #自定义注释列表
    - name: string
spec:         #必填，部署的详细定义
  selector: 
    matchLabels:
      name1: string #必填，通过此标签匹配对应pod<key: value>
      name2: string
  replicas: number #必填，副本数量
#-------------template中填写的内容和pod yaml中填写的内容一样----------------------
  template: #必填，应用容器模版定义
    metadata: 
      labels: 
        name: string #必填，遇上面matchLabels的标签相同
    spec: 
      containers:      #必填，定义容器列表
#------------------pod的更新策略--------------------------------------------      
  strategy:
    # 可选地值有:
    # RollingUpdate: 默认的选项, 删除一部分旧的pod然后启动一部分新版本的pod, 如此往复直到替换所有旧的pod, 确保服务不中断
    # Recreate: 全部删除旧的pod, 然后再创建新版的pod, 会造成服务暂时不可用
    type: RollingUpdate
    # 只有在type为RollingUpdate的时候可以选择这个参数, 用于指定RollingUpdate的参数
    rollingUpdate:
      maxSurge: 25% # 允许临时超出副本数的最大比例（或固定数值，如 1）
      # 更新过程中允许不可用的 Pod 比例（或固定数值，如 1）
      # 默认值为25%, 此时会先删除25%的旧版本的pod, 然后创建25%新版本的pod, 如此往复
      # 如果设置为1, 那么会先删除1个旧版本的pod, 然后创建1个新版本的pod, 直到更新完所有的pod
      maxUnavailable: 25%
~~~

案例

~~~yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
~~~

然后通过`kubectl create -f deployment.yaml`命令来创建这个deployment



**如果将Deployment生成的pod的标签改掉, 那么Deployment为了保持副本, 会重新生成pod**

**如果把原来的pod的label改回来, pod会被删除掉一个**





### 扩缩容

~~~shell
kubectl scale deployment deployment --replica 10 # 扩容到10个副本

# 自动根据容器cpu使用率进行扩缩容
# 最小副本10, 最大副本15
# 当容器cpu使用率大于80%的时候进行扩容, 当cpu小于80%的时候缩容
kubectl autoscale deployment deployment_name --min=10 --max=15 --cpu-percent=80
~~~





### 镜像更新和回滚

~~~shell
# 更新镜像, --record的作用是将该命令记录在版本号的change-cause字段中
kubectl set image  deployment/deployment_name  container_name=image_name --record
# 修改nginx-deployment下的容器nginx的镜像 修改为nginx:1.2
kubectl set image deployment/nginx-deployment nginx=nginx:1.25

# 将deployment回滚到上一个版本
kubectl rollout undo deployment/deployment_name 
# deployment回滚到指定版本, 每回滚或者升级都会生成一个新的版本号, 而不是跳回到原来的版本
kubectl rollout undo deployment/deployment_name --to-revision=1

# 查看deployment的回滚过程的执行状态
kubectl rollout status deployment/deployment_name

# 查看deployment的历史版本
kubectl rollout history deployment/deployment_name
~~~

![image-20231013151426897](img/k8s笔记/image-20231013151426897.png)

如上图所示:

1. --record将更新deployment的命令记录在change-cause中
2. rollout虽然是回退版本, 但是还是会生成一个新的版本
3. 上面创建了3个ReplicaSet控制器, 其中两个已经停止, 只有一个在运行, 用来控制副本数量



### 相关shell

~~~shell
kubectl get deploy -A # 查看所有的deploy
kubectl get deploy -n namespace # 查看指定命名空间中的deploy

kubectl describe deploy deploy_name -n namespace # 描述namespace中的deploy的详细信息

kubectl delete deploy --all # 删除所有的deploy
kubectl delete deploy -n namespae_name deploy_name # 删除指定命名空间中的deploy
~~~



### 实践

1. 如何查看Deployment创建出来的ReplicaSet, 以及ReplicaSet控制的Pod

   如果我们创建了一个名为`nginx-deployment`的Deployment, 那么这个Deployment创建出来的ReplicaSet的命名就是`nginx-deployment-${hash}`

   同时这个ReplicaSet创建出来的Pod就会名为`nginx-deployment-${hash}-${random}`, 如下图所示

   ![image-20250706001425007](img/k8s笔记/image-20250706001425007.png)





## StatefulSet 控制器

通过如下模板创建3个pv, 因为StatefulSet的replicas为3, 需要3个pv, 每个副本都会占据一个pv

~~~yaml
# 创建pv
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0004 # pv的名字
  labels:  
    pv-type: example-label
    environment: dev
spec:
  capacity:
    storage: 5Gi # 定义pv的容量
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs
  # 创建的是nfs类型的pv
  nfs:
    path: /nfs/data
    server: cdh107
~~~

![image-20231024221444559](img/k8s笔记/image-20231024221444559.png)

~~~yaml
# 创建headless service
apiVersion: v1
kind: Service
metadata:
  name: headless-svc-nginx
  labels:
    app: nginx
spec:
  ports:
    - port: 80
      name: web
  clusterIP: None # 指定ClusterIp为None, 创建无头服务
  selector:
    app: nginx
---
# 创建StatefulSet
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web4
spec:
  selector:
    matchLabels:
      app: nginx1
  serviceName: headless-svc-nginx # 使用上面创建的service来创建statefulset
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx1
    spec:
      containers:
        - name: nginx1
          image: nginx:1.24
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
  # 直接创建pvc, 并绑定到pod中, 因为有3个副本, 所以会创建3个pvc
  volumeClaimTemplates: 
    - metadata:
        name: www
      spec:
        accessModes: [ "ReadWriteOnce" ] 
        storageClassName: "nfs"
        resources:
          requests:
            storage: 1Gi
~~~

<img src="img/k8s笔记/image-20231024223220762.png" alt="image-20231024223220762" style="zoom:50%;" />

### StatefulSet的特点

- 顺序部署, 扩展, 删除:

  k8s会按照`{statefulset名称}-{index}`的名称来启动pod的多个副本, 并且多个副本会按照顺序启动,  如上图所示, 先启动web4-0, web4-1, web4-2, 只有前一个副本状态变为running和ready后才会启动下一个副本(基于initContainer实现)

  当删除pod的时候, 会从N-1到0顺序删除所有副本

  **通过init containers来实现**

- pod重新创建后名称不变

  当delete其中一个pod之后, 因为副本原因会重新启动一个pod, pod名称不会变, hostname不会变, 但是ip会变, 如下图所示

  <img src="img/k8s笔记/image-20231024223456458.png" alt="image-20231024223456458" style="zoom:50%;" />

- 删除pod并不会删除pvc, 需要手动处理

- 通过volumeClaimTemplates字段, k8s会为每一个StatefulSet都创建一个pvc, 名称格式为: `{volumeClaimTemplates.name}-{pod_name}`, 比如上面`{volumeClaimTemplates.name}`是www, 所以创建的pvc分别是www-web4-0, www-web4-1, www-web4-2

  

  

## DaemonSet 控制器

### 概述

Daemon确保在每个node(除了有污点的node)上都运行一个pod副本,  当node加入到集群中时, 会在node上创建一个新的pod, 当node退出集群时, Daemon也会删除在node上的pod副本.

删除DaemonSet会删除所有他创建所有的pod副本

使用DaemonSet的典型用法:

- 在每个集群上运行日志收集: fluentd, logstash
- 在每个集群上运行监控: Prometheus

### yaml解析

~~~yaml
apiVersion: apps/vl
kind: DaemonSet
metadata:
  name: deamonset-example
  labels: 
    app: daemonset
spec:
  selector:
    matchLabels:
      name: deamonset—example
  template:
    metadata:
      labels:
        name: deamonset—example
    spec: 
      containers:
        - name: daemonset-example
          image: nginx:1.24
~~~

然后通过`kubectl apply -f my-daemonset.yaml` 来创建这个DaemonSet

### 相关shell

~~~shell
kubectl get ds -n <namespace> # 查看指定namespace中的ds
kubectl get ds -A # 查看所有的ds

kubectl describe ds <ds-name> -n <namespace> # 查看指定namepsace中的ds的详细信息

kubectl delete ds <ds-name> -n <namespace> # 删除ds, 并删除相关的pod
~~~









## Job控制器

Job 负责批处理任务，我们可以定义并行执行Pod的个数, 多少个Pod执行成功后, Job才算执行成功, 

Pod最多重试次数等等



如果一个Pod失败了, 他会重新启动另外一个Pod来执行任务

Pod执行完毕后, 状态为Completed



### yaml解析

~~~yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi1
spec:
  completions: 4 # 总共需要有4个pod副本运行成功, 这个Job才算运行成功，默认为1
  parallelism: 2 # 每次最多并发运行2个pod，默认为1
  backoffLimit: 4 # 如果某个Pod运行失败了, 会重试, 总共最多重试4次, 如果超过了4次, 那么这个Job会被认为执行失败了
  activeDeadlineSeconds: 10 # 整个Job从启动最多允许10s, 超过10s就认为失败了
  ttlSecondsAfterFinished: 60  # Job执行成功60s后, 自动删除掉Job和对应的Pod, 防止占用空间
  template:
    metadata:
      name: pi
    spec: 
      containers:
        - name: pi
          image: perl
          command: ["perl","-Mbignum=bpi", "-wle", "print bpi(2000)"] # 通过perl语言计算圆周率后2000位
      restartPolicy: Never # RestartPolicy仅支持Never或OnFailure
~~~

<img src="img/k8s笔记/image-20231013155959022.png" alt="image-20231013155959022" style="zoom:50%;" />

### 相关shell

~~~shell
kubectl get job -n <namespace> # 查看指定namespace中的ds
kubectl get job -A # 查看所有的ds

kubectl describe job <job-name> -n <namespace> # 查看指定namepsace中的ds的详细信息

kubectl delete job <job-name> -n <namespace> # 删除ds, 并删除相关的pod
~~~







## CronJob控制器

CronJob 管理基于时间的Job，即:

- 在给定时间点只运行一次
- 周期性地在给定时间点运行

典型的用法如下所示:

- 在给定的时间点调度Job 运行
- 创建周期性运行的Job，例如: 数据库备份、发送邮件



CronJob的原理:

- cronjob是通过job controller来控制pod的, 即每次到了运行周期, cronjob都会创建出一个job controller来执行一次任务

  所以删除cronjob并不会删除创建出来的pod,  还需要删除cronjob创建出来的job才会删除pod



### yaml解析

~~~yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *" # 必须, 任务运行周期
  startingDeadlineSeconds: 10 # 因为某些原因, cronjob没有被准时的触发(controller manager不可用, kubelet宕机), 那么只要在触发点的10s内, 就可以补偿性触发, 超过了10s的话, 就需要等到下一次调度了
  # 并发策略, 可选, 指定如何处理被cron job创建的job的并发执行
  # Allow: 运行并发运行job
  # Forbid: 禁止并发运行, 如果前一个还没有完成, 则直接跳过下一个
  # Replace: 取消当前运行的job, 换新的来执行
  concurrencyPolicy: Allow
  suspend: false # 可选, 是否要暂停当前的CronJob, 不执行调度, 默认为false, 如果设置为true的话, 那么就相当于暂停了定时调度一样
  successfulJobsHistoryLimit: 3 # 保留最近3个成功执行的Job和关联的Pod, 旧的会被自动Job和Pod会被删除, 节省磁盘, 默认值为3
  failedJobsHistoryLimit: 1 # 保留最近1个执行失败的Job和关联的Pod, 旧的会被自动Job和Pod会被删除, 节省磁盘, 默认值为1
  ttlSecondsAfterFinished: 300 # 自动删除300s以前执行的Job和关联的Pod, 减少磁盘和内存的占用
  jobTemplate:  # 需要运行的任务, 公式同pod
    spec:
      template:
        spec:
          containers:
            - name: hello
              image: busybox
              args:
                - /bin/sh
                - -c
                - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
~~~



### 相关shell

~~~shell
kubectl get cronjob -n <namespace> # 查看指定namespace中的cronjob
kubectl get cronjob -A # 查看所有的cronjob

kubectl describe cronjob <cronjob-name> -n <namespace> # 查看指定namepsace中的cronjob的详细信息

kubectl patch cronjob <cronjob-name> -n <namespace> -p '{"spec" : {"suspend" : true}}' # 暂停cronjob
kubectl patch cronjob <cronjob-name> -n <namespace> -p '{"spec" : {"suspend" : false}}' # 恢复cronjob


kubectl delete job <job-name> -n <namespace> # 删除cronjob, 不会删除job和关联的pod
~~~









## Horizontal Pod Autoscaling

Horizontal Pod Autoscaling 仅适用于Deployment 和 ReplicaSet, 在v1版本中仅支持根据cpu的利用率扩容, 在vlapha版本中, 支持根据内存和用户自定义的metric扩缩容

# Service

**Service能够通过label匹配一组pod, 并记录这些pod的信息.** 

当有一组java pod需要访问mysql pod的时候, 因为pod的ip是会变化的(pod挂掉了Deployment会重新启动一个pod, 并且这个pod与上一个pod的ip地址是不一样的), 这个时候就需要为mysql pod创建一个service.

java pod只需要访问service的ip, service会把请求通过**轮询**转发到mysql pod中, 这样就可以无视mysql pod的ip变化了 

**并且当pod的副本死亡以后, 创建出来新的pod, svc也能监控到, 并将其更新到负载策略里面**

![image-20250706132011516](img/k8s笔记/image-20250706132011516.png)

**只有访问service 的 ip才会进请求转发给后面的一组pod, 即只能进行四层代理, 访问service的hostname是不行的**

**需要使用ingress后, 才能进行七层代理, 即访问域名或者hostname就可以进行请求的转发**

> Note: Service在重新调度之后, ip是会变化的, 所以在实际中, 都是通过ingress调用service的hostname的

Service 在 K8s 中有以下四种类型: ClusterIp,  NodePort, LoadBalancer, ExternalName

## ClusterIp

默认类型，这种类型的Service会被分配一个**仅 cluster 内部**可以访问的虚拟IP, 访问该虚拟ip后会轮询的将请求转发到pod上

> Note: 这里的转发是转发到容器内部的端口上, 即pod中指定的containerPort, 而不是hostPort

> Note: 如果一个pod没有指定hostPort, 那么他就只能通过ClusterIp或者Service来提供服务了

同时还会在集群内部的dns上创建一个A记录, 格式为`${service-name}.${namespace}.svc.cluster.local`, 当访问这个域名的时候, 访问到的就是service的ip



如果你的pod和clusterIp是在同一个namespace中, 那么你可以在pod中直接将clusterIp的名字作为域名来调用他, 而不必使用长域名

<img src="img/k8s笔记/image-20231013172054050.png" alt="image-20231013172054050" style="zoom:25%;" />

~~~yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deploy
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      release: stabel
  template:
    metadata:
      labels:
        app: myapp
        release: stabel
        env: test
    spec:
      containers:
        - name: myapp
          image: nicolaka/netshoot # 这个容器可以执行nslookup
          command: ["top"] # 执行一个前台命令, 防止容器退出
          ports:
            - name: http-web-svc # 端口名字
              containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: default
spec:
  type: ClusterIP
  selector:   # 表现选择器, 选择指定的pod
    app: myapp
    release: stabel
  ports:
    - name: name1
      port: 80 # service占用的端口
      protocol: TCP
      targetPort: http-web-svc # 转发到的端口, 可以直接写端口名字, 也可以使用数字
~~~

![image-20231106182304861](img/k8s笔记/image-20231106182304861.png)

可以看到, 通过nslookup进行域名解析, `myapp.default.svc.cluster.local`的ip就是service的ip

## NodePort

这种类似的Service会在`custerlP` 基础上为 Service 在**每台node机器**上绑定一个端口，这样就可以通过访问Node上的端口来访问到容器了

<img src="img/k8s笔记/image-20231013172823945.png" alt="image-20231013172823945" style="zoom:33%;" />

~~~yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deploy
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      release: stabel
  template:
    metadata:
      labels:
        app: myapp
        release: stabel
        env: test
    spec:
      containers:
        - name: myapp
          image: wangyanglinux/myapp:v2
          ports:
            - name: http-web-svc # 端口名字
              containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: default
spec:
  type: NodePort
  selector:   # 表现选择器, 选择指定的pod
    app: myapp
    release: stabel
  ports:
    - name: name1
      port: 80 # 访问service内部ip的端口
      protocol: TCP
      targetPort: http-web-svc # 转发到的端口, 可以直接写端口名字, 也可以使用数字
      nodePort: 30000 # 访问service的外部端口, 必须是在30000-32767, 同时要自己考虑端口冲突
~~~

需要注意的是, 虽然我们访问任何一台机器的NodePort端口, 他都会将我们的请求轮询的转发给Pod, 但是如果我们访问的这台Node都挂掉了的话, 那么我们的请求是无效的

所以在实际情况中, 我们的Client实际上是将请求发送到Nginx中, 然后通过Nginx做一个方向代理将请求发送到一台机器的NodePort的端口中

同时我们在Nginx中做健康检测, 监测哪些Node的端口是调不通的(Node挂掉了),  然后不将请求转发到这个Node上, 这样就实现了真正的负载均衡

![image-20250706140502842](img/k8s笔记/image-20250706140502842.png)





## LoadBalancer

他的主要的功能和NodePort是一样的, 都是在每一台机器上创建一个端口, 访问这个端口就可以负载均衡的访问到对应的Pod

但是他和NodePort的区别在于:

- 我们不需要手动的在NodePort前面加一个nginx, 来实现高可用, 而是通过云供应商提供的服务, 将我们的请求负载均衡到各个Node节点上

  当然了, 这种方式因为引入了云供应商, 所以是要收费的

  ![image-20250706141257146](img/k8s笔记/image-20250706141257146.png)





## ExternalName

这种方式主要用于Pod访问集群外部的服务

在集群内部创建一个Service, 这个Service会记录外部应用的ip和port,  这样内部的pod只需要访问这个service就可以范围到外部服务

当外部服务改变时, 只需要修改这个service中记录的ip和port即可, 不需要修改pod中的ip和port

~~~yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: default
spec:
  type: ExternalName
  externalName: hub.atguigu.com
~~~

当查询主机 `my-service.defalut.svc.cluster.local` ( SVC_NAME.NAMESPACE.svc.cluster.local )时，集群的
DNS 服务将返回一个值 hub.atguigu.com 的 CNAME 记录







## Headless Service

### 概述

对于ClusterIp和NodePort的方式

- 会在集群内部有一个确切的虚拟ip

- 会在集群内部的dns上添加一条A记录, 格式为`service-name.namespace.svc.cluster.local`, 这样pod中的程序访问这个域名, 就会被解析到service的ip上, **service再将请求轮询转发给pod**

  ![image-20231106182304861](img/k8s笔记/image-20231106182304861.png)

- 访问service的ip和域名, 就是访问到service, 然后service通过轮询的方式发送请求到pod中

- 如果svc和pod在同一个namespace中, 那么pod还可以直接使用短域名来访问svc, 短域名就是svc的name



而对于headless service

1. 如果他转发请求的pod是普通的请求的话

   - 不会分配一个确切的虚拟ip

   - 会在集群内部的dns上添加一条A记录, 格式为`<service-name>.<namespace>.svc.cluster.local`, 但是解析出来的ip并不是service的ip, 而直接是pod的ip, 如果有需要可以自己在客户端做些负载均衡策略

     ![image-20231106191538447](img/k8s笔记/image-20231106191538447.png)

     ![image-20231106191532663](img/k8s笔记/image-20231106191532663.png)

     

2. 如果他转发的pod是stateful set类型的pod的话, 那么他会为每一个他关联的pod创建一个域名`<pod-name>.<headless-service-name>.<namespace>.svc.cluster.local`,  你可以直接调用这个域名, 就可以将请求转发给这个statefulset类型的pod了

   如果你调用请求pod, 和statefulset类型的pod在同一个namespace的话, 那么你还可以使用短域名``<pod-name>.<headless-service-name>`来访问这个pod

   **这常常用在有状态的集群上面, 比如我们的java代码, 需要配置zk的时候, 就可以直接写zk的域名了**











### 创建headless service

headless并不是一个单独类型的Service, 他只是一个特殊的ClusterIp类型的svc, 所以他的本质还是ClusterIp

想要创建一个headless类型的svc, 你可以使用如下的yaml

~~~yaml
apiVersion: v1
kind: Service
metadata:
  name: my-headless-svc
spec:
  # type: ClusterIp    # 一般不指定type, 让他是默认是ClusterIp就好了
  clusterIP: None      # 关键：设置为 None, 这样就是一个headless类似的svc
  selector:
    app: my-app
  ports:
    - name: xxx # 端口的名字
      protocol: TCP # 支持的协议
      port: 80 # 必填, 在DNS SRV记录中会用到, 即_name._protocol.my-svc
      targetPort: 8080 # pod的实际端口, 在DNS SRV记录中用到
~~~



### headless service的使用场景

我们现在有一个redis集群, 三个节点一主一从

三个主节点分别是: `seasqlcache-cluster-0, seasqlcache-cluster-1, seasqlcache-cluster-2`

他们的ip分别是: `177.177.104.17,  177.177.166.185,177.177.135.62 `

三个从节点分别是: `seasqlcache-slave-0-0, seasqlcache-slave-1-0, seasqlcache-slave-2-0`

他们的ip分别是`177.177.166.175 177.177.135.19 177.177.104.61` 

~~~shell
[admin@node2 ~]$ kubectl get pod -A -o wide | grep seasqlcache
service-software   seasqlcache-cluster-0                              1/1     Running                 0          10d     177.177.104.17    node2   <none>           <none>
service-software   seasqlcache-cluster-1                              1/1     Running                 0          10d     177.177.166.185   node1   <none>           <none>
service-software   seasqlcache-cluster-2                              1/1     Running                 0          10d     177.177.135.62    node3   <none>           <none>
service-software   seasqlcache-slave-0-0                              1/1     Running                 0          10d     177.177.166.175   node1   <none>           <none>
service-software   seasqlcache-slave-1-0                              1/1     Running                 0          10d     177.177.135.19    node3   <none>           <none>
service-software   seasqlcache-slave-2-0                              1/1     Running                 0          10d     177.177.104.61    node2   <none>           <none>
~~~

现在我们有两个svc

~~~shell
[admin@node2 ~]$ kubectl get svc -A | grep seasqlcache
service-software   seasqlcache-cluster                   ClusterIP   10.96.227.109   <none>        6379/TCP                                                         54d
service-software   seasqlcache-cluster-headless          ClusterIP   None            <none>        6379/TCP,16379/TCP                                               54d
~~~

其中`seasqlcache-cluster ` 是 ClusterIp类型的svc, 他会将请求转发给所有的redis节点

~~~shell
[admin@node2 ~]$ kubectl describe endpoints  -n service-software   seasqlcache-cluster
Name:         seasqlcache-cluster
Namespace:    service-software
Labels:       app.kubernetes.io/instance=seasqlcache-cluster
              app.kubernetes.io/managed-by=Helm
              app.kubernetes.io/name=seasqlcache-cluster
              app.kubernetes.io/version=7.2.3
              helm.sh/chart=seasqlcache-cluster-9.1.4
Annotations:  endpoints.kubernetes.io/last-change-trigger-time: 2025-08-04T11:42:09+08:00
Subsets:
  Addresses:          177.177.104.17,177.177.104.61,177.177.135.19,177.177.135.62,177.177.166.175,177.177.166.185
  NotReadyAddresses:  <none>
  Ports:
    Name             Port  Protocol
    ----             ----  --------
    tcp-seasqlcache  6379  TCP

Events:  <none>
~~~

其中`seasqlcache-cluster-headless`是headless类型的ClusterIp类型的svc, 他会将所有的请求, 转发给redis的三个主节点

~~~shell
[admin@node2 ~]$ kubectl describe endpoints  -n service-software   seasqlcache-cluster-headless
Name:         seasqlcache-cluster-headless
Namespace:    service-software
Labels:       app.kubernetes.io/instance=seasqlcache-cluster
              app.kubernetes.io/managed-by=Helm
              app.kubernetes.io/name=seasqlcache-cluster
              app.kubernetes.io/version=7.2.3
              helm.sh/chart=seasqlcache-cluster-9.1.4
              service.kubernetes.io/headless=
Annotations:  endpoints.kubernetes.io/last-change-trigger-time: 2025-08-04T11:42:09+08:00
Subsets:
  Addresses:          177.177.104.17,177.177.135.62,177.177.166.185
  NotReadyAddresses:  <none>
  Ports:
    Name             Port   Protocol
    ----             ----   --------
    tcp-seasqlcache  6379   TCP
    tcp-cache-bus    16379  TCP

Events:  <none>
~~~

现在我们要在springboot程序中连接redis, 但是我们不能直接指定所有redis的ip地址, 因为pod一旦重启, 地址就会变, 所以我们应该指定svc的地址

~~~yaml
spring:
  redis:
    port: 6379
    host: seasqlcache-cluster
    password: y=twSG2+5vG=Te4_2o
    jedis:
      pool:
        # 连接池最大连接数（使用负值表示没有限制）
        max-active: 50
        # 连接池最大阻塞等待时间（使用负值表示没有限制）
        max-wait: 8000
        # 连接池中的最大空闲连接
        max-idle: 50
        # 连接池中的最小空闲连接
        min-idle: 0
    # 连接超时时间（毫秒）
    timeout: 20000
~~~

如果我们按照上面的代码, 通过`host`来指定redis的地址是`seasqlcache-cluster`, 那么我们实际上是将请求发送给了`seasqlcache-cluster`这个svc, 然后这个svc将我们的请求转发轮询转发给6个redis集群, 这样我们的redis客户端实际上是运行在单机模式下的, 因为他只知道将请求发送给了一个svc的ip地址, 他并不知道这个ip地址后面有6个redis节点, 这样我们在使用redis的时候就会出问题



我们应该使用如下的代码来配置我们的springboot项目

~~~yaml
spring:
  redis:
    password: y=twSG2+5vG=Te4_2o
    cluster:
      nodes: seasqlcache-cluster-headless:6379  # 如果 Service 支持集群发现
      max-redirects: 3  # 最大重定向次数
    jedis:
      pool:
        max-active: 50
        max-wait: 8000
        max-idle: 50
        min-idle: 0
    timeout: 20000
~~~

这样redis在解析这个seasqlcache-cluster-headless域名的时候,  因为这是一个headless service, 他不会转发请求, 而是直接返回对应pod的id地址, 这样redis client就会直接去连接这6个redis节点, 然后直接给这些节点发送消息, 这样redis client实际上是运行在集群模式下的





## 实践

### svc转发的pod

如果你创建了一个ClusterIp, 或者NodePort类型的Service, 如果你想要知道这个Service会将请求转发到哪些Pod中, 你可以通过如下命令查看

~~~shell
[root@uc24020 record]# kubectl describe svc -n service-software syslog-receive-test
Name:                     syslog-receive-test
Namespace:                service-software
Labels:                   app=itoa-syslog-receive
Annotations:              <none>
Selector:                 app=itoa-syslog-receive
Type:                     NodePort
IP Family Policy:         PreferDualStack
IP Families:              IPv4,IPv6
IP:                       10.96.0.224
IPs:                      10.96.0.224,fd00:10:96::9613
Port:                     <unset>  6003/TCP
TargetPort:               5555/TCP
NodePort:                 <unset>  6003/TCP
Endpoints:                177.177.111.188:5555,177.177.140.18:5555,177.177.59.128:5555
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
~~~

从上面的`Endpoints`中可以看出来, 这个NodePort会将请求转发到ip地址为`177.177.111.188:5555,177.177.140.18:5555,177.177.59.128:5555`这三个ip地址的容器中, 并且请求转发到5555端口

然后你就可以去看哪个容器占用了这三个端口



当然, 你也可以直接通过下面的命令来查看来查看一个svc的endpoints

~~~shell
[admin@node1 ~]$ kubectl get endpoints -n service-software   seasqlcache-cluster
NAME                  ENDPOINTS                                                                 AGE
seasqlcache-cluster   177.177.104.17:6379,177.177.104.61:6379,177.177.135.19:6379 + 3 more...   53d
~~~



如果你的svc的endpoints太多了, 超过三个的话, 那么**上面两个命令**都不会打印全部的endpoints, 只会打印三个, 比如`177.177.104.17:6379,177.177.104.61:6379,177.177.135.19:6379 + 3 more...   53d`

 如果你想要查看全部的endpoints的话, 可以通过如下的命令, 他会打印所有转发的地址

~~~shell
[admin@node2 ~]$ kubectl describe endpoints  -n service-software   seasqlcache-cluster
Name:         seasqlcache-cluster
Namespace:    service-software
Labels:       app.kubernetes.io/instance=seasqlcache-cluster
              app.kubernetes.io/managed-by=Helm
              app.kubernetes.io/name=seasqlcache-cluster
              app.kubernetes.io/version=7.2.3
              helm.sh/chart=seasqlcache-cluster-9.1.4
Annotations:  endpoints.kubernetes.io/last-change-trigger-time: 2025-08-04T11:42:09+08:00
Subsets:
  Addresses:          177.177.104.17,177.177.104.61,177.177.135.19,177.177.135.62,177.177.166.175,177.177.166.185
  NotReadyAddresses:  <none>
  Ports:
    Name             Port  Protocol
    ----             ----  --------
    tcp-seasqlcache  6379  TCP

Events:  <none>
~~~



如果你还想查看更详细的地址, 可以使用如下的命令, 他会显示具体转发到哪个pod, namespace, pod的uid等等信息

~~~shell
[admin@node1 ~]$ kubectl get endpoints -n service-software   seasqlcache-cluster -o json
{
    "apiVersion": "v1",
    "kind": "Endpoints",
    "metadata": {
        "annotations": {
            "endpoints.kubernetes.io/last-change-trigger-time": "2025-08-04T11:42:09+08:00"
        },
        "creationTimestamp": "2025-06-21T05:54:38Z",
        "labels": {
            "app.kubernetes.io/instance": "seasqlcache-cluster",
            "app.kubernetes.io/managed-by": "Helm",
            "app.kubernetes.io/name": "seasqlcache-cluster",
            "app.kubernetes.io/version": "7.2.3",
            "helm.sh/chart": "seasqlcache-cluster-9.1.4"
        },
        "name": "seasqlcache-cluster",
        "namespace": "service-software",
        "resourceVersion": "13142278",
        "uid": "46806804-dd39-49bd-a9be-ee72cac102d6"
    },
    "subsets": [
        {
            "addresses": [
                {
                    "ip": "177.177.104.17",
                    "nodeName": "node2",
                    "targetRef": {
                        "kind": "Pod",
                        "name": "seasqlcache-cluster-0",
                        "namespace": "service-software",
                        "resourceVersion": "13142277",
                        "uid": "cd4e0115-6ef0-4e23-b9c0-a8243a3114f5"
                    }
                },
                {
                    "ip": "177.177.104.61",
                    "nodeName": "node2",
                    "targetRef": {
                        "kind": "Pod",
                        "name": "seasqlcache-slave-2-0",
                        "namespace": "service-software",
                        "resourceVersion": "13141680",
                        "uid": "b5b1f424-f3f0-486a-8d5a-084b0c095840"
                    }
                },
                {
                    "ip": "177.177.135.19",
                    "nodeName": "node3",
                    "targetRef": {
                        "kind": "Pod",
                        "name": "seasqlcache-slave-1-0",
                        "namespace": "service-software",
                        "resourceVersion": "13141685",
                        "uid": "4d0354e0-8e48-4b2a-9b92-5b5775f0359e"
                    }
                },
                {
                    "ip": "177.177.135.62",
                    "nodeName": "node3",
                    "targetRef": {
                        "kind": "Pod",
                        "name": "seasqlcache-cluster-2",
                        "namespace": "service-software",
                        "resourceVersion": "13141727",
                        "uid": "59d06bb7-12cc-4a85-aba9-461c455987fa"
                    }
                },
                {
                    "ip": "177.177.166.175",
                    "nodeName": "node1",
                    "targetRef": {
                        "kind": "Pod",
                        "name": "seasqlcache-slave-0-0",
                        "namespace": "service-software",
                        "resourceVersion": "13141676",
                        "uid": "3d0bf1d2-ae4c-437f-b96b-c26343e5a868"
                    }
                },
                {
                    "ip": "177.177.166.185",
                    "nodeName": "node1",
                    "targetRef": {
                        "kind": "Pod",
                        "name": "seasqlcache-cluster-1",
                        "namespace": "service-software",
                        "resourceVersion": "13141811",
                        "uid": "108b23e6-3dac-4c98-8613-9f4e019f0d28"
                    }
                }
            ],
            "ports": [
                {
                    "name": "tcp-seasqlcache",
                    "port": 6379,
                    "protocol": "TCP"
                }
            ]
        }
    ]
}
~~~



### 能够在k8s宿主机上直接访问的节点

在k8s的宿主机上,  你可以直接通过如下的地址来范围pod

- pod的ip, 可以ping通
- svc的ip, 不能ping通, 但是可以直接调用

你不能通过如下的内容来访问pod

- svc的域名, 这个是coreDNS虚拟出来的, 只能在内部使用

下面的是实践

~~~shell
[root@node-157 tmp]# kubectl get svc -A | grep framework
service-software   k-framework-svc                  ClusterIP   10.96.133.120   <none>        8088/TCP   24d

# 无法通过域名调用
[root@node-157 tmp]# curl -X POST  -g --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"userName": "admin"}' "http://k-framework-svc.service-software.svc.cluster.local:8088/token/auth/generate"
curl: (6) Could not resolve host: k-framework-svc.service-software.svc.cluster.local

# 无法ping通svc的ip
[root@node-157 tmp]# ping 10.96.133.120
PING 10.96.133.120 (10.96.133.120) 56(84) 字节的数据。
^C
--- 10.96.133.120 ping 统计 ---
已发送 3 个包， 已接收 0 个包, 100% packet loss, time 2039ms

# 可以通过svc的ip来调用
[root@node-157 tmp]# curl -X POST  -g --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"userName": "admin"}' "http://10.96.133.120:8088/token/auth/generate"
{
  "token" : "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJXazNleUoxYzJWeVRtRnRaU0k2SW1Ga2JXbHVJaXdpYVdRaU9pSXhJaXdpY21WbmFXOXVTV1FpT2lJd0lpd2lhWEJCWkdSeVpYTnpJam9pTVRBdU1UUTBMakU0TXk0eE5UY2lmUT09c2d6eSIsImp0aSI6IjU0MDMwNyIsImlhdCI6MTc2NzAxMDIxOH0.C50K8oFXIemMBzNsyf0DKYUFsQ7CMXHWfNkYwO7kxDdWW70UgtiImkK3a_5FbyBNph-w_ti0x9N6eWx43-Nayw",
  "createTime" : "2025-12-29T12:10:18.318+00:00",
  "expire" : null,
  "userName" : "admin",
  "password" : null,
  "effectiveTime" : 7200,
  "effectiveUrl" : null,
  "ipAddress" : null,
  "ucTargetUrl" : null,
  "proxySubToken" : null,
  "msg" : "Succeed!"
}


[root@node-157 tmp]# kubectl get pod -A -o wide | grep base-rs
service-software   base-rs-pod-5fd8766cb6-sncbz                1/1     Running     1          24d    177.177.153.92    node-157   <none>           <none>

# 可以ping通pod的ip
[root@node-157 tmp]# ping 177.177.153.92
PING 177.177.153.92 (177.177.153.92) 56(84) 字节的数据。
64 字节，来自 177.177.153.92
~~~




### 关于SVC的网络栈说明

在svc的yaml文件中, 你可以通过`ipFamilyPolicy`来指定svc双栈还是单栈, 并且他也决定了`ipFamilies`和`clusterIPs`这两个属性的行为

ipFamilyPolicy有如下的可选值

- SingleStack: 单栈, 通过`ipFamilies`来指定ipv4还是ipv6, 如果k8s集群不支持对应的协议, 那么svc会创建失败

  ~~~yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: myservice
  spec:
    selector:
      app: demo
    ports:
      - port: 80
    ipFamilyPolicy: SingleStack # 指定使用单栈
    ipFamilies: 
      - IPv4 # 使用ipv4
  ~~~
~~~

- PreferDualStack: 双栈优先, 在你的集群支持双栈的时候分配双栈, 如果你的k8s集群不支持双栈, 那么会分配单栈, 到底是ipv4还是ipv6取决于你的k8s集群哪个协议可用

  ~~~yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: myservice
  spec:
    selector:
      app: demo
    ports:
      - port: 80
    ipFamilyPolicy: PreferDualStack # 优先双栈
    ipFamilies:
      - IPv4 # ipv4作为主地址
      - IPv6 # ipv6为次地址
~~~

- RequireDualStack: 强制双栈, 如果集群不支持双栈，那么svc创建失败

  ~~~yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: myservice
  spec:
    selector:
      app: demo
    ports:
      - port: 80
    ipFamilyPolicy: RequireDualStack # 强制双栈
    ipFamilies:
      - IPv6 # ipv6优先
      - IPv4 # ipv4为次地址
  ~~~



对于单栈和双栈, 有下面几点需要注意的:

1. **如果你在创建svc的时候, 没有指定ipFamilyPolicy的话, 那么会被设置为SingleStack, 并且优先使用ipv4(可用的话)**

2. 在双栈的情况下`ipFamilies`中优先指定的那个协议的ip, 会作为主ip, 另外一个会作为次pi

   如果你优先指定ipv4, 那么访问这个svc的时候, 会优先获取到他的ipv4的ip

3. 在单栈和双栈的切换中, 主ip是不可变的, 即

   - 单栈切换双栈, 你只能添加一个次ip
   - 双栈切单栈, 你只能将次ip删除掉

4.  `clusterIPs`这个字段来指定具体要使用的ip地址, 他指定的ip的顺序, 必须和ipFamilies的顺序一致

   一般情况下我们都不会直接通过这个地址来指定svc的地址, 而是通过系统自动分配ip地址



如果你要查看你的系统是否支持双栈, 那么你可以通过如下的配置文件来测试一下

~~~yaml
apiVersion: v1
kind: Service
metadata:
  name: test-dualstack
spec:
  ipFamilyPolicy: RequireDualStack
  ipFamilies: [IPv6, IPv4]  # IPv6 优先
  selector:
    app: non-existent-app  # 无实际 Pod，仅测试配置
  ports:
    - protocol: TCP
      port: 80
~~~

你直接describe一下这个svc

- 如果只有ipv4, 那么表示只支持ipv4
- 如果只有ipv6那么只支持ipv6
- 如果两个都有的话, 那么支持双栈

~~~shell
[root@node-157 ~]# kubectl describe svc test-dualstack
Name:              test-dualstack
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=non-existent-app
Type:              ClusterIP
IP Families:       <none>
IP:                10.96.192.124 # 只支持ipv4
IPs:               10.96.192.124
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         <none>
Session Affinity:  None
Events:            <none>
~~~





比如我们通过下面的yaml来创建一个svc

~~~yaml
apiVersion: v1
kind: Service
metadata:
  name: my-simple-service  # 服务名称
spec:
  selector:
    app: my-app  # 关联的 Pod 标签
  ports:
    - protocol: TCP       # 协议类型（TCP/UDP）
      port: 80            # 服务暴露的端口
      targetPort: 9376    # Pod 监听的端口
~~~

我们直接describe一下他

~~~shell
[root@node-157 ~]# kubectl describe svc my-simple-service
Name:              my-simple-service
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=my-app
Type:              ClusterIP
# 因为没有指定ipFamilyPolicy, ipFamilies, clusterIPs
# 所以ipFamilyPolicy被默认设置为了SingleStack, 并且当前集群支持ipv4和ipv6, 所有优先设置了ipv4
IP Families:       <none> 
IP:                10.96.224.4 # 当前svc的主ip
IPs:               10.96.224.4 # 当前svc使用的所有ip
Port:              <unset>  80/TCP
TargetPort:        9376/TCP
Endpoints:         <none>
Session Affinity:  None
Events:            <none>
~~~

下面我们通过patch命令, 将这个svc修改为双栈的, 并且ipv6优先

~~~shell
kubectl patch svc my-simple-service --type=merge -p '{
  "spec": {
    "ipFamilyPolicy": "RequireDualStack",
    "ipFamilies": ["IPv6", "IPv4"]
  }
}'
~~~

效果如下:

~~~shell

~~~

> 如果这个svc经过双栈和单栈之间的切换, 主ip有变化, 那么使用到这个svc的pod需要重启, 否则会访问不通这个svc











# Ingress

在上面的场景中, 我们介绍了如何创建pod, 如何将请求通过svc转发给其他的pod, 但是上面的内容中, pod都是在处理k8s内部的请求, 如果我们要访问pod的端口, 那么需要在宿主机上面调用svc的ip, 将请求发送到svc上, 然后转发给pod



但是真实情况是,  我们的pod必须处理来自外网的请求, 同时我们也不可能将每个服务都映射到NodePort的端口上, 因为我们不能暴露k8s的ip到外网上面

用户通过域名+端口+路径来调用我们的服务, 域名经过dns解析成k8s的集群, 然后发送到我们的k8s集群上面, 我们必须有一个统一的入口, 用它来管理所有从集群外部访问到集群内部的Pod的请求

这就是Ingress的作用, 他是**"从集群外部访问集群内部 Service 的统一入口规则"**, 我们可以通过他来描述哪些请求需要转发到哪个Service上面, 然后又Service再进行转发到pod上面

>  Service只能进行四层代理, 即只有访问service的ip地址才能够进行转发
>
> 而Ingress能够进行七层代理, 也就是通过域名访问service



Ingress有多重多样的实现方案, 只要能够实现统一管理外部请求到k8s内部的svc的方案都可以

~~~shell
Ingress 实现方案
├─ 通用 Ingress Controller
│  ├─ NGINX
│  ├─ Traefik
│  ├─ HAProxy
│  └─ Apache APISIX
│
├─ Envoy 系
│  ├─ Contour
│  ├─ Istio IngressGateway
│  └─ Ambassador / Emissary
│
├─ 云厂商托管
│  ├─ AWS ALB / NLB
│  ├─ GCP GCE Ingress
│  └─ 阿里云 / 腾讯云
│
└─ 新一代 Gateway API
   ├─ NGINX Gateway
   ├─ Contour Gateway
   └─ Istio Gateway
~~~

下面使用的是github中的一个开源项目ingress-nginx来实现的, 他也是k8s官方在维护的一个项目

https://kubernetes.github.io/ingress-nginx/deploy/#quick-start



要使用上面这个项目, 我们首先要在k8s集群中部署ingress-nginx的相关pod和svc

~~~shell
# 如果你的集群有helm, 那么也可以使用helm来按照, 这里使用yaml来安装
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# 等待安装完成
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
  
# 查看pod状态
kubectl get pods --namespace=ingress-nginx
~~~

![image-20231023223731466](D:\my_code\note\运维\k8s\img\image-20231023223731466.png)

![image-20231023224551164](D:\my_code\note\运维\k8s\img\image-20231023224551164.png)

上面的两个svc和一个pod, 我们主要关注ingress-nginx-controlle这个pod和ingress-nginx-controller这个NodePort的svc



外部请求的转发过程如下:

1. 用户通过域名请求我们的服务, 然后经过dns域名解析, 解析到我们的k8s集群上的80端口
2. 之后请求就会被ingress-nginx-controller这个svc接受到, 并转发给ingress-nginx-controller这个pod
3. ingress-nginx-controller这个pod再接受到svc转发过来的请求之后,  你可以理解他就是一个nginx, 他会按照你定义的规则, 将不同域名, 不同端口的, 不同路径的请求, 转发给特定服务的svc
4. 之后就是不同服务的svc接受到请求之后, 将请求负载均衡到各自的pod上面, 并返回请求了



上面我们通过ingress-nginx创建了对应的controller, 和对应的svc, 那么就要通过yaml文件来定义外部请求到内部svc的转发规则了

~~~yaml
apiVersion: networking.k8s.io/v1 # 配置nginx的转发规则
kind: Ingress
metadata:
  name: nginx-test
spec:
  # # 需要添加这个,否则ingress不会添加到nginx.config中. 参考https://www.cnblogs.com/dudu/p/15548461.html
  # 这个字段主要用于k8s集群中, 可能会部署多个ingress实现, 那么会有多个ingress controller
  # 这个字段用于指定当前的ingress规则到底归属于哪个ingress controller的
  ingressClassName: nginx 
  rules:
    - host: www1.atguigu.com # 指定访问的域名
      http:
        paths:
          - path: / # 指定路径前缀
            pathType: Prefix
            backend:
              service:
                name: demo-svc # 转发到的svc
                port: 
                  number: 80
~~~

![image-20231023225634418](img/k8s笔记/image-20231023225634418.png)

经过上面的配置, 我们只需要访问`www1.atguigu.com:31864`就会访问到ingress的nodeport端口, 然后转发给ingress controller, 然后ingress controller转发给对应的svc , 然后svc转发给特定的pod



## ingress-nginx镜像加速

> Note: 使用上面网站的yml安装ingress-nginx经常会失败, 因为镜像下载不下来, 可以使用下面这个文件
>
> 主要就是将k8s镜像更新为阿里云的镜像

~~~yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  name: ingress-nginx
---
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx
  namespace: ingress-nginx
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-admission
  namespace: ingress-nginx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx
  namespace: ingress-nginx
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - configmaps
  - pods
  - secrets
  - endpoints
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingressclasses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - coordination.k8s.io
  resourceNames:
  - ingress-nginx-leader
  resources:
  - leases
  verbs:
  - get
  - update
- apiGroups:
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - create
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs:
  - list
  - watch
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-admission
  namespace: ingress-nginx
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - nodes
  - pods
  - secrets
  - namespaces
  verbs:
  - list
  - watch
- apiGroups:
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingressclasses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs:
  - list
  - watch
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-admission
rules:
- apiGroups:
  - admissionregistration.k8s.io
  resources:
  - validatingwebhookconfigurations
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx
subjects:
- kind: ServiceAccount
  name: ingress-nginx
  namespace: ingress-nginx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-admission
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx-admission
subjects:
- kind: ServiceAccount
  name: ingress-nginx-admission
  namespace: ingress-nginx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx
subjects:
- kind: ServiceAccount
  name: ingress-nginx
  namespace: ingress-nginx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-admission
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx-admission
subjects:
- kind: ServiceAccount
  name: ingress-nginx-admission
  namespace: ingress-nginx
---
apiVersion: v1
data:
  allow-snippet-annotations: "true"
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-controller
  namespace: ingress-nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  externalTrafficPolicy: Local
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - appProtocol: http
    name: http
    port: 80
    protocol: TCP
    targetPort: http
  - appProtocol: https
    name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-controller-admission
  namespace: ingress-nginx
spec:
  ports:
  - appProtocol: https
    name: https-webhook
    port: 443
    targetPort: webhook
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  minReadySeconds: 0
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app.kubernetes.io/component: controller
      app.kubernetes.io/instance: ingress-nginx
      app.kubernetes.io/name: ingress-nginx
  strategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
        app.kubernetes.io/version: 1.8.2
    spec:
      containers:
      - args:
        - /nginx-ingress-controller
        - --publish-service=$(POD_NAMESPACE)/ingress-nginx-controller
        - --election-id=ingress-nginx-leader
        - --controller-class=k8s.io/ingress-nginx
        - --ingress-class=nginx
        - --configmap=$(POD_NAMESPACE)/ingress-nginx-controller
        - --validating-webhook=:8443
        - --validating-webhook-certificate=/usr/local/certificates/cert
        - --validating-webhook-key=/usr/local/certificates/key
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: LD_PRELOAD
          value: /usr/local/lib/libmimalloc.so
        image: registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:v1.1.1
        imagePullPolicy: IfNotPresent
        lifecycle:
          preStop:
            exec:
              command:
              - /wait-shutdown
        livenessProbe:
          failureThreshold: 5
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        name: controller
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        - containerPort: 443
          name: https
          protocol: TCP
        - containerPort: 8443
          name: webhook
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources:
          requests:
            cpu: 100m
            memory: 90Mi
        securityContext:
          allowPrivilegeEscalation: true
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - ALL
          runAsUser: 101
        volumeMounts:
        - mountPath: /usr/local/certificates/
          name: webhook-cert
          readOnly: true
      dnsPolicy: ClusterFirst
      nodeSelector:
        kubernetes.io/os: linux
      serviceAccountName: ingress-nginx
      terminationGracePeriodSeconds: 300
      volumes:
      - name: webhook-cert
        secret:
          secretName: ingress-nginx-admission
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-admission-create
  namespace: ingress-nginx
spec:
  template:
    metadata:
      labels:
        app.kubernetes.io/component: admission-webhook
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
        app.kubernetes.io/version: 1.8.2
      name: ingress-nginx-admission-create
    spec:
      containers:
      - args:
        - create
        - --host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.$(POD_NAMESPACE).svc
        - --namespace=$(POD_NAMESPACE)
        - --secret-name=ingress-nginx-admission
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: registry.cn-hangzhou.aliyuncs.com/google_containers/kube-webhook-certgen:v1.1.1
        imagePullPolicy: IfNotPresent
        name: create
        securityContext:
          allowPrivilegeEscalation: false
      nodeSelector:
        kubernetes.io/os: linux
      restartPolicy: OnFailure
      securityContext:
        fsGroup: 2000
        runAsNonRoot: true
        runAsUser: 2000
      serviceAccountName: ingress-nginx-admission
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-admission-patch
  namespace: ingress-nginx
spec:
  template:
    metadata:
      labels:
        app.kubernetes.io/component: admission-webhook
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
        app.kubernetes.io/version: 1.8.2
      name: ingress-nginx-admission-patch
    spec:
      containers:
      - args:
        - patch
        - --webhook-name=ingress-nginx-admission
        - --namespace=$(POD_NAMESPACE)
        - --patch-mutating=false
        - --secret-name=ingress-nginx-admission
        - --patch-failure-policy=Fail
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: registry.cn-hangzhou.aliyuncs.com/google_containers/kube-webhook-certgen:v1.1.1
        imagePullPolicy: IfNotPresent
        name: patch
        securityContext:
          allowPrivilegeEscalation: false
      nodeSelector:
        kubernetes.io/os: linux
      restartPolicy: OnFailure
      securityContext:
        fsGroup: 2000
        runAsNonRoot: true
        runAsUser: 2000
      serviceAccountName: ingress-nginx-admission
---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.2
  name: ingress-nginx-admission
webhooks:
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: ingress-nginx-controller-admission
      namespace: ingress-nginx
      path: /networking/v1/ingresses
  failurePolicy: Fail
  matchPolicy: Equivalent
  name: validate.nginx.ingress.kubernetes.io
  rules:
  - apiGroups:
    - networking.k8s.io
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - ingresses
  sideEffects: None

~~~



# 存储

## ConfigMap

许多应用程序会从配置文件、命令行参数或环境变量中读取配置信息。

ConfigMap AP 给我们提供了向容器中注入配置信息的机制，ConfigMap 可以被用来保存单个属性，也可以用来保存整个配置文件或者JSON 二进制大对象

### ConfigMap的创建

1. 通过配置文件或者目录来创建

   ~~~shell
   $ ls 
   game.properties
   ui.properties
   
   $ cat game.properties
   secret.code.allowed=true
   secret.code.lives=30
   
   $ cat ui.properties
   color.good=purple
   color.bad=yellow
   
   # 将当前文件下的所有properties文件中的配置都导入到当前configmap下
   $ kubectl create configmap game-config --from-file=./
   # 只将指定的文件中的配置包含到configmap中
   $ kubectl create configmap game-config --from-file=./game.properties
   ~~~

   通过上面这种方式创建的configmap,  一个文件名就是一个key, 文件内容就是对应的value

2. 通过命令行创建

   ~~~shell
   kubectl create cm cm_name --from-literal=color.good=purple --from-literal=color.bad=yellow
   ~~~

3. 通过yaml创建

   ~~~yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: env-config
     namespace: default
   data: 
     key1: value1
     key2: value2
   ~~~

### 相关命令行

~~~shell
kubectl get cm -n namespae # 查看指定命名空间中的configmap
kubectl get cm cm_name -o yaml -n namespace # 以yaml的形式显示configmap的信息

kubectl decribe cm -n namespace_name cm_name # 查看configmap的详细信息

kubectl delete cm -n namespace_name cm_name # 删除configmap
~~~





### 使用configmap

1. 将configmap中的单个key挂载到环境变量中

   ~~~yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: env-config
   data: 
     color.good: green
     color.bad: red
   ---
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: env-config1
   data: 
     color.warn: yellow
     color.forbidden: black
   ---
   apiVersion: v1
   kind: Pod
   metadata:
     name: test
   spec:
     containers:
       - name: test-container1
         image: bash
         command: ["/bin/sh", "-c", "env | grep color"]
         env:
           - name: color.good 
             valueFrom: # 将configmap中的key-value挂载到env中
               configMapKeyRef:
                 name: env-config # configmap的名字
                 key: color.good # configmap中key的名字
           - name: color.bad
             valueFrom:
               configMapKeyRef:
                 name: env-config
                 key: color.bad
         envFrom:
           - configMapRef:
               name: env-config1 # configmap的名字, 将整个configmap中的key-value挂载到环境变量中
     restartPolicy: Never
   ~~~

   然后通过下面命令可以查看到configmap中的配置确实加载进了容器的env中

   ~~~shell
   [root@cdh105 ~]# kubectl logs test
   color.warn=yellow
   color.bad=red
   color.good=green
   color.forbidden=black
   ~~~

2. 将configmap中的data, 作为配置文件的内容, 挂载到容器中

   **默认configmap中的每一个key都作为作为文件名, value作为文件内容**

   ~~~yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: env-config
   data: 
     color.good: green
     color.bad: red
     color.warn: yellow
     color.forbidden: black
   ---
   apiVersion: v1
   kind: Pod
   metadata:
     name: test
   spec:
     containers:
       - name: test-container1
         image: bash
         command: ["/bin/sh", "-c", "ls /etc/config & cat /etc/config/* & sleep 600s"]
         volumeMounts:
          - name: v1 # 要使用的存储卷的名字
            mountPath: /etc/config # 将configmap env-config中的所有kv都挂载到/etc/config下, 每个key一个文件
     volumes: 
       - name: v1 # 存储卷的名字
         configMap:
           name: env-config # configmap的名字
     restartPolicy: Never
   ~~~

   通过如下命令来查看结果

   ~~~shell
   [root@cdh105 ~]# kubectl exec test -it -- /bin/sh
   # cd /etc/config
   # ls
   color.bad        color.forbidden  color.good       color.warn
   # cat *
   redblackgreenyellow
   ~~~

3. 当然, 你也可以将configmap中指定的key, 作为文件, 挂载到容器中

   ~~~yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: env-config
   data: 
     application.properties: |
       server.port=8080
       aaa=bbb
     application-dev.properties: |
       server.port=8081
       cc=dd
   
   ---
   apiVersion: v1
   kind: Pod
   metadata:
     name: test
   spec:
     containers:
       - name: test-container1
         image: bash
         command: ["/bin/sh", "-c", "ls /etc/config & cat /etc/config/* & sleep 600s"]
         volumeMounts:
          - name: v1 # 要使用的存储卷的名字
            mountPath: /etc/config # 要挂载的目录
     volumes: 
       - name: v1 # 存储卷的名字
         configMap:
           name: env-config # configmap的名字
           items:
           - key: application.properties # 要挂载的key
             path: application.properties # 挂载后的文件的名称
           - key: application-dev.propertie
             path: application-dev.propertie
     restartPolicy: Never
   ~~~

   之后就会在容器中的`/etc/config`目录下生成两个文件`application.properties`和`application-dev.propertie`





## Secret

Secret 解决了密码、token、密钥等敏感数据的配置问题，而不需要把这些敏感数据暴露到镜像或者 Pod Spec中。

Secret 可以以 Volume 或者环境变量的方式使用
Secret 有三种类型:

- **service-account-token**: 用来访问 Kubernetes api-server中的rest api接口

- **Opaque**: Opaque和ConfigMap比较类似, 但是他要求value是base64编码的

  **并在作为数据卷和环境变量加载进容器的时候, k8s会先进行base64解码再加载进去**

- **docker-registry**:  在创建pod的时候, 如果镜像在私服, 那么我们将无法拉取进行, 这个时候要进行登录认证, 而登录认证所需要的信息就报错在docker-registry中

### service-account-token

k8s内部实现了一套rbac的权限控制系统, ServiceAccount就是rbac中的一种用户(还有其他类型的用户, 比如User, Group)

一个Service Account就相当于一个用户, 然后我们可以赋予这个用户一些角色, 这些角色是权限的集合, 有了这个权限之后, container中的进程就可以通过这个ServiceAccount来调用k8s api-server中的一些接口了, 同时k8s也会对请求进行认证, 鉴权, 看看是否有权限获取对应的资源



Service Account的主要作用就是为了container中的进程能够调用k8s-api的接口而存在的

我们可以为每个Service Account都关联一个`service-account-token`类型的Secret, `service-account-token`主要分为三个部分:

1. token:  他是一个jwt格式的token, 主要用于容器内的进程通过https方式访问api-server的时候, 用于身份认证和鉴权
2. ca.crt: ServiceAccount对应的证书, 主要用于容器内的进程通过https双向认证的方式访问api-server的时候, 用于身份认证和鉴权
3. namespace: 主要用于表示这个token的命名空间



每当我们创建一个namespace的时候, k8s就会自动在这个namespace下创建一个名为`default`的Service Account

> 需要注意的是: 
>
> 1. 在k8s 1.24及其以下版本下, k8s 会自动为ServiceAccount创建一个关联service-account-token, 名称为`<sa-name>-token-<random>`
> 2. 在k8s 1.24+, k8s不会为新创建的ServiceAccount创建关联的Secret, 而是需要手动申请一个关联Secret并指定他的有效期



当我们在这个namespace下创建pod的时候, 如果不在yaml文件中不指定这个pod关联的Service Account, 那么这个pod就会默认关联到`default`这个service account



在pod启动的时候, 会将pod关联的ServiceAccount的`service-account-token`信息写入到容器的`/run/secrets/kubernetes.io/serviceaccount/`目录里面, 用于容器内的进程进行身份认证

1. `token`文件: 文件的内容是ServiceAccount对应的Secret的jwt token

   如果container中的进程需要调用k8s-api的接口, 那么就将token的内容, 放在在https请求的header的`Authorization`中, 这样k8s就知道是哪个用户发送过来的请求了, 就可以对这个请求进行权限控制了

   比如我们container的java进程需要调用k8s-api的接口, 来请求一个configmap中的内容, 那么可以调用如下的接口

   ~~~shell
   curl -k \
   -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   https://kubernetes.default:443/api/v1/namespaces/${namespace_name}/configmaps/${configmap_name}
   ~~~

   调用上面的接口后, k8s会判断token是否正确, 关联的Service Account有没有权限能够访问configmap 这个资源

2. `ca.crt`: ServiceAccount对应的证书, 主要用户容器内的进程通过https双向认证的方式访问api-server的时候, 用于身份认证和鉴权

3. `namespace`文件: 主要用于表示这个token的命名空间

~~~shell
$ kubectl run nginx --image nginx
deployment "nginx" created
$ kubectl exec nginx -it -- /bin/sh
$ cd /run/secrets/kubernetes.io/serviceaccount
$ ls
ca.crt  namespace  token
~~~



#### 相关shell

1. 我们可以通过如下命令来查看k8s中有哪些ServiceAccount以及他们关联的`service-account-token`

   ~~~shell
   kubectl get sa -A # 查看所有命名空间的ServiceAccount
   kubectl get sa -n <namespace_name> # 查看指定命名空间中的ServiceAccount
   kubectl describe sa secret_name -n <namespace_name> # 查看ServieAccount的详细信息
   
   
   kubectl get secret -A # 查看所有命名空间的Secret, 其中包括了service-account-token, 也包括Qpaque
   kubectl get secret -n <namespace_name> # 查看指定命名空间中的Secret
   kubectl describe secret secret_name -n <namespace_name> # 查看Secret的内容
   ~~~

2. 我们可以通过如下的命令来创建一个ServiceAccount, 在k8s1.23及其以下会自动创建对应的service-account-token

   1. 通过yaml来创建sa

      ~~~yaml
      # sa.yaml
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: my-sa
        namespace: default
      automountServiceAccountToken: true   # 自动挂载 token（默认 true）
      ~~~

      然后通过`kubectl create -f sa.yaml`来创建这个sa

   2. 也可以你直接通过命令来创建service account

      ~~~shell
      kubectl create serviceaccount my-sa -n dev
      ~~~

3. 如果你是在k8s1.24+的版本, 那么在创建ServiceAccount的时候, 不会自动创建service-account-token, 而是需要手动申请一个关联的service-account-token

   ~~~yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: my-service-account-token
     annotations:
       kubernetes.io/service-account.name: my-service-account
   type: kubernetes.io/service-account-token
   ~~~
   
4. 如果你想要查看service-account-token属于哪个ServiceAccount, 那么你可以通过如下命令来查看

   ~~~shell
   [root@uc24020 record]# kubectl describe secret -n service-software websocket-sa-token-h5w64
   Name:         websocket-sa-token-h5w64
   Namespace:    service-software
   Labels:       <none>
   # 这个websocket-sa就是这个secret对应的service account
   Annotations:  kubernetes.io/service-account.name: websocket-sa 
                 kubernetes.io/service-account.uid: def3535f-03df-44d1-bd5e-fab47a1cb0f1
   
   Type:  kubernetes.io/service-account-token
   
   Data
   ====
   ca.crt:     1070 bytes
   namespace:  16 bytes
   token:      eyJhbGciOiJSUzI1NiIsImtpZCI6Imw1MlFCVGRja2RQSk1JV0VSX2xkOV9EamFwRGRiczAyNV84QkhVZjBoMTgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJzZXJ2aWNlLXNvZnR3YXJlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6IndlYnNvY2tldC1zYS10b2tlbi1oNXc2NCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJ3ZWJzb2NrZXQtc2EiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJkZWYzNTM1Zi0wM2RmLTQ0ZDEtYmQ1ZS1mYWI0N2ExY2IwZjEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6c2VydmljZS1zb2Z0d2FyZTp3ZWJzb2NrZXQtc2EifQ.WDG1vCWpaFnb8VLJezxgBYjNoE7NZKPUo6mas8py0y7DAJTVFFAJBEyU1VwDHOsVPDP8V9EY7wUjI15dLTaQDwsy-aIgetzMvwZg-39XHyhUZwYeyp_PkprNJwSkRn5AKCijCtDk8soRCSbNoXuH_BbUpTZFrJk-wGA-0Z9x7I8l035yY__f1OlKcZO7hf-BEzXnJtEweFS1lBr0lP25z23OY-EqTzVdDmJDQyLAXyzxO-FAUKKT94cSKQnb_2rV5Fmia6NVtvPPYme1M0TVJsxAcGzmV9Vy3_fCnWf6fO-G4lzdDCnH95LFMHsA5JkDYZMqYfbgyItUH6V4J-53-g
   ~~~

   **如果给pod分配权限, 可以使用这个账户名来和Role进行绑定**

5. 如果你想要指定pod关联的ServiceAccount, 那么你可以在pod的yaml文件中指定`spec.serviceAccountName`字段

   ~~~yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: my-sa
     namespace: default
   ---
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: sa-test-deploy
     namespace: default
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: sa-test
     template:
       metadata:
         labels:
           app: sa-test
       spec:
         serviceAccountName: my-sa # 指定关联的service acount
         containers:
         - name: curl
           image: curlimages/curl:7.85.0
           command: ["sleep", "3600"]
   ~~~

6. 如果你想查看当前运行的 Pod 实际使用了哪个 ServiceAccount，可以用这个命令：

   ~~~shell
   kubectl get pod <pod-name> -o jsonpath='{.spec.serviceAccountName}'
   # 如果输出为空, 那么使用的是当前命名空间中的default这个ServiceAccount
   ~~~

7. 如果你想要将ServiceAccount关联到角色上, 那么可以执行如下的yaml

   ~~~yaml
   # 1. 创建 ServiceAccount
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: my-sa
     namespace: default
   ---
   # 2. 创建 Role（允许读取 ConfigMap）
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     name: configmap-reader
     namespace: default
   rules:
   - apiGroups: [""]
     resources: ["configmaps"]
     verbs: ["get", "list", "watch"]
   ---
   # 3. 绑定 Role 到 ServiceAccount
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     name: bind-my-sa
     namespace: default
   subjects:
   - kind: ServiceAccount
     name: my-sa
     namespace: default
   roleRef:
     kind: Role
     name: configmap-reader
     apiGroup: rbac.authorization.k8s.io
   ~~~

   更详细的角色的信息, 可以查看安全 > 鉴权部分

8. 如果你想要查看一个ServiceAccount绑定了哪些Role和ClusterRole, 有哪些权限, 实际上ServiceAccount是不记录这个东西的, 我们只能去RoleBinding/ClusterRoleBinding中查看哪些角色绑定了哪些账户, 然后去出对应的角色中查看他的权限

   **但是你可以检测某个账户是否有什么的权限, 通过如下命令**

   ~~~shell
   kubectl auth can-i # 查收某个账户是否有操作某个资源的权限
   [-n <namesapce_name>] \ # 可选, 资源的命名空间, 如果不指定表示default命名空间
   <verb> \ # 操作的类型, 比如get,list,create,delete
   # 资源的类型, pod,secret, cm,deploy,ds,svc
   # 如果你想将资源限制在某个具体的资源, 那么可以通过跟在斜杠后面,  不指定的话表示同一个类型的所有资源
   <resource>/[<resource-name>] \ 
   # 指定要测试的账号
   # 如果是User类型的账号, 可以通过--as=<user>来指定
   # 如果是Group类型的账号, 可以通过--as-group=<group>来指定
   # 如果是ServiceAccount类型的账号, 可以通过--as=system:serviceaccount:<namespace>:<serviceaccount-name>来指定
   --as=<alice>
   
   # 案例: 测试ServiceAccount类型的账户kong, 能不能获取(get) service-software命名空间下的名为my-configmap的cm资源
   kubectl auth can-i get cm/my-configmap -n service-software --as=system:serviceaccount:service-software:kong
   
   # 案例: 查看ServiceAccount类型的账户default, 能不能获取(Get) default命名空间下的所有的pod的信息
   kubectl auth can-i get pod --as=system:serviceaccount:service-software:default
   
   # 案例: 测试User类型的账户default, 能不能获取(Get) default命名空间下名为my-pod的pod的信息
   kubectl auth can-i get pod/my-pod --as=default
   ~~~

   

#### 挂载的实现

上面说到, 每个pod都关联了一个ServiceAccount, k8s在启动pod的时候, 会将ServiceAccount对应的service-account-token挂载到容器的`/run/secrets/kubernetes.io/serviceaccount/`目录下面, 实际上他的实现方式和数据卷是类似的

- 首先k8s会为每一个pod分配一个uid, 你可以通过如下的命令来查看这个uid

  ~~~shell
  kubectl get pod -n <my-namespace> <pod_name> -o jsonpath='{.metadata.uid}'
  ~~~

- 之后k8s会为每个pod创建一个目录

  ~~~shell
  # 8a2121f1-6fe4-48fc-b78b-d63ff6481f3a是pod的uid
  /var/lib/kubelet/pods/8a2121f1-6fe4-48fc-b78b-d63ff6481f3a
  ~~~

- 之后将service-account-token的三个文件, 写到`/var/lib/kubelet/pods/${uid}/volumes/kubernetes.io~secret/${sa-token-name}`的目录下

  ~~~shell
  [root@node-157 8a2121f1-6fe4-48fc-b78b-d63ff6481f3a]# pwd
  /var/lib/kubelet/pods/8a2121f1-6fe4-48fc-b78b-d63ff6481f3a
  
  [root@node-157 8a2121f1-6fe4-48fc-b78b-d63ff6481f3a]# tree
  .
  ├── containers
  │   └── openjdk-container
  │       └── 62d8216d
  ├── etc-hosts
  ├── plugins
  │   └── kubernetes.io~empty-dir
  │       ├── temp-storage
  │       │   └── ready
  │       └── wrapped_default-token-r2x7t
  │           └── ready
  └── volumes
      ├── kubernetes.io~empty-dir
      │   └── temp-storage
      │       └── hello
      # 这个保存的是secret的目录
      └── kubernetes.io~secret
          # 这个是secret的名字
          └── default-token-r2x7t
              ├── ca.crt -> ..data/ca.crt
              ├── namespace -> ..data/namespace
              └── token -> ..data/token
  ~~~

- 之后将这个目录, 挂载到每一个container对应的目录下面, 这样每个container读取的都是一样的service-account-token了

你可以通过如下的pod命令来创建一个pod, 然后看看对应的目录

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: jdk-pod
spec:
  containers:
  - name: jdk-container
    image: openjdk:17-jdk-slim  # 选择合适的 JDK 镜像
    command: ["tail", "-f", "/dev/null"]  # 保持进程运行，防止容器退出
    volumeMounts:
    - name: temp-storage
      mountPath: /tmp/storage  # Mount emptyDir to this path
  volumes:
  - name: temp-storage
    emptyDir: {}
~~~









### Opaque

1. Opaque和ConfigMap比较类似, 但是他要求value是base64编码的

   **并在作为数据卷和环境变量加载进容器的时候, k8s会先进行base64解码再加载进去**

   ~~~yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: mysecret
   type: Opaque
   data:
     password: YWRtaW4= # admin
     username: dGlnZXI= # tiger
   ~~~

   通过如下命令查看创建的secret

   ~~~shell
   kubectl get secret
   ~~~

   

2. 使用方式

   1. 将secret挂载到volume中

      ~~~yaml
      apiVersion: v1
      kind: Secret
      metadata:
        name: mysecret
      type: Opaque
      data:
        password: YWRtaW4= # admin
        username: dGlnZXI= # tiger
      ---
      apiVersion: v1
      kind: Pod
      metadata:
        name: sep
      spec:
        volumes:
          - name: sev
            secret:
              secretName: mysecret # 将secrets作为卷
        containers:
          - image: bash
            name: bash
            command: ["/bin/sh", "-c", "cd /etc/secrets & ls & cat * & sleep 600s"]
            volumeMounts:
              - name: sev
                mountPath: "/etc/secrets" # 挂载到指定目录下
                readOnly: true
        restartPolicy: Never
      ~~~

      通过如下命令查看结果发现, secrets中的配置已经解密了

      ~~~shell
      $ kubectl exec sep -it -- /bin/bash
      $ cd /etc/secrets
      $ ls
      password  username
      $ cat password
      admin
      ~~~

   2. 将secrets加载进环境变量

      ~~~yaml
      apiVersion: v1
      kind: Secret
      metadata:
        name: mysecret1
      type: Opaque
      data:
        password: YWRtaW4= # admin
        username: dGlnZXI= # tiger
      --- 
      apiVersion: v1
      kind: Pod
      metadata:
        name: test
      spec:
        containers:
          - name: test-container1
            image: bash
            command: ["/bin/sh", "-c", "echo $PASSWORD"]
            env:
              - name: PASSWORD # env中的环境变量名
                valueFrom:
                  secretKeyRef:
                    name: mysecret1 # secret的名字
                    key: password # secret中key的名字
              - name: USERNAME
                valueFrom:
                  secretKeyRef:
                    name: mysecret1
                    key: username
            envFrom:
              - secretRef:
                  name: mysecret1 # configmap的名字, 将整个configmap中的配置都加载进env
        restartPolicy: Never
      ~~~

      通过如下命令查看结果

      ~~~shell
      $ kubectl logs test
      admin
      ~~~

### docker-registry

通过kubectl来创建docker registry类型的secret, 用来给docker私服仓库做认证

~~~shell
$ kubectl create secret docker-registry registrykey_name --docker-server=DOCKER REGISTRY SERVERdocker-username=DOCKER_USER --docker-password=DOCKER_PASSHORD --docke-email=DOCKER_EMAIL 
secret "myregistrykey” created.

# 上面的docker-registry表示secret的类型, registrykey_name表示secret的名称
~~~

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: foo
spec:
  containers:
    - name: foo
      image: roc/awangyang:v1  # 拉取私服中的这个镜像需要认证, 所以使用docker registry来认证
  imagePullSecrets:
    - name: registrykey_name # 使用的docker registry
~~~





## Volume

容器磁盘上的文件的生命周期是短暂的，这就使得在容器中运行重要应用时会出现一些问题。

首先，当容器崩溃时，kubelet 会重启它，但是容器中的文件将丢失——容器以干净的状态（镜像最初的状态）重新启动。其次，在Pod 中同时运行多个容器时，这些容器之间通常需要共享文件。Kubernetes 中的 Volume 抽象就很好的解决了这些问题

**Kubernetes 中的卷有明确的寿命 —— 与封装它的 Pod 相同, 只要Pod存在Volume就存在, 当pod消失的时候, Volume就消失了**

### emptyDir

**emptyDir的功能主要是用在一个pod有多个container的情况下, 这多个container共享同一个目录的, 这样container可以感知文件的变化, 进行通讯等等**



当 Pod 被分配给节点时，首先创建 emptyDir 卷

只要该 Pod 在该节点上运行，该卷就会存在。

正如卷的名字所述，它最初是空的。

该卷可以挂载到每个容器中的相同或不同路径上

pod中的容器共享该卷中的文件

当删除 Pod 时， emptyDir 中的数据将被永久删除

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
    - image: k8s.gcr.io/test-webserver
      name: test-container
      volumeMounts:
        - mountPath: /cache # 挂载的目录
          name: cache-volume # 挂载的卷的名字
  volumes:
    - name: cache-volume # volumes的名字
      emptyDir: {} # 定义emptyDir
~~~





#### emptyDir的实现方式

k8s创建pod的大概步骤如下:

- 首先k8s会为每一个pod分配一个uid, 你可以通过如下的命令来查看这个uid

  ~~~shell
  kubectl get pod -n <my-namespace> <pod_name> -o jsonpath='{.metadata.uid}'
  ~~~

- 之后k8s会为每个pod创建一个目录

  ~~~shell
  # 8a2121f1-6fe4-48fc-b78b-d63ff6481f3a是pod的uid
  /var/lib/kubelet/pods/8a2121f1-6fe4-48fc-b78b-d63ff6481f3a
  ~~~

- 之后k8s会创建一个如下的目录`/var/lib/kubelet/pods/${uid}/volumes/kubernetes.io~empty-dir/${volume-name}`的目录下

  ~~~shell
  [root@node-157 8a2121f1-6fe4-48fc-b78b-d63ff6481f3a]# pwd
  /var/lib/kubelet/pods/8a2121f1-6fe4-48fc-b78b-d63ff6481f3a
  
  [root@node-157 8a2121f1-6fe4-48fc-b78b-d63ff6481f3a]# tree
  .
  ├── containers
  │   └── openjdk-container
  │       └── 62d8216d
  ├── etc-hosts
  ├── plugins
  │   └── kubernetes.io~empty-dir
  │       ├── temp-storage
  │       │   └── ready
  │       └── wrapped_default-token-r2x7t
  │           └── ready
  └── volumes
          # 这个目录专门保持创建的empty-dir的
      ├── kubernetes.io~empty-dir
              # 这个是empty-dir的名字
      │   └── temp-storage
      │       └── hello
      └── kubernetes.io~secret
          └── default-token-r2x7t
              ├── ca.crt -> ..data/ca.crt
              ├── namespace -> ..data/namespace
              └── token -> ..data/token
  ~~~

- 之后将这个``/var/lib/kubelet/pods/${uid}/volumes/kubernetes.io~empty-dir/${volume-name}``目录, 挂载到每一个container对应的目录下面, 这样每个container读取的都是一样的宿主机目录了

你可以通过如下的pod命令来创建一个pod, 然后看看对应的目录

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: jdk-pod
spec:
  containers:
  - name: jdk-container
    image: openjdk:17-jdk-slim  # 选择合适的 JDK 镜像
    command: ["tail", "-f", "/dev/null"]  # 保持进程运行，防止容器退出
    volumeMounts:
    - name: temp-storage
      mountPath: /tmp/storage  # Mount emptyDir to this path
  volumes:
  - name: temp-storage
    emptyDir: {}
~~~







### hostPath

`hostPath` 卷将主机节点的文件系统中的**文件**或**目录**挂载到集群中

需要注意的是, 因为每次pod所在的node不同, 所以即使同样的配置, 挂载进pod的内容也会不同

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
    - image: k8s.gcr.io/test-webserver
      name: test-container
      volumeMounts:
        - mountPath: /test-pd # 挂载进容器的目录
          name: test-volume # 挂载的volume的名字
  volumes:
    - name: test-volume
      hostPath:
        path: /data
        # 可选, 如果为空表示不做任何检查
        # DirectoryOrCreate: 如果主机上没有该路径就创建, 权限为0755, 和kubelet具有相同的组和所有权
        # Directory: 必须存在给定的目录
        # FileOrCreate: 如果没有指定的文件, 那么就创建一个空文件, 权限为0644, 和kubelet具有相同的组和所有权
        # File: 必须存在给定的文件
        # Socker: 必须存在给定的套接字
        # CharDevice: 必须存在给定的字符设备
        # BlockDevice: 必须存在给定的块设备
        type: Directory 
~~~

### nfs(net file system)

能够将网络上其他服务器上的目录挂载到本机下面

我们现在需要将目标服务器上一个的目录,  挂载到客户机的一个目录下面, 步骤如下

1. 在目标服务器上安装net, 并指定需要被挂载的目录

   ~~~shell
   yum install -y nfs-common nfs-utils rpcbind # 安装nfs组件
   
   mkdir -p /nfs/data # 创建要被挂载的目录
   chmod 666 /nfs/data
   
   cat > /etc/exports << EOF # 导出要被挂载的目录, 是他能够被挂载到其他客户机的目录下
   /nfs/data *(rw,no_root_squash,no_all_squash,sync)
   EOF
   
   
   systemctl start rpcbind
   systemctl start nfs
   systemctl enable rpcbind
   systemctl enable nfs
   ~~~

2. 在所有的k8s的node主机上安装nfs相关组件, k8s需要通过这个来连接目标服务器

   ~~~shell
   yum install -y nfs-common nfs-utils rpcbind
   ~~~

3. 测试nfs

   ~~~shell
   # 在nfs主机上创建一个文件
   cat << EOF > /nfs/data/test.txt
   hello world
   EOF
   
   # 在nfs客户机上执行
   mkdir /test
   showmount -e cdh107 # 查看cdh107上被导出的, 能够被挂载的目录
   mount -t nfs cdh107:/nfs/data  /test # 将cdh107下的/nfs/data挂载到客户机/test目录下
   umount -t nfs /test # 卸载挂载的目录
   ~~~
   
   ![image-20231024193535590](img/k8s笔记/image-20231024193535590.png)
   
4. 通过如下yaml创建pod

   ~~~yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx-dep1
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
           - name: nginx
             image: nginx:1.24
             volumeMounts: # 挂载volume
               - name: wwwroot
                 mountPath: /usr/share/nginx/html # 挂载到容器的目录
                 readOnly: false
             ports:
               - containerPort: 80
         volumes: # 声明一个volume
           - name: wwwroot
             nfs:
               server: cdh107 # 指定目标服务器
               path: /nfs/data # 指定目标服务器上需要挂载的目录
   ~~~

   ![image-20231024194459482](img/k8s笔记/image-20231024194459482.png)





## PersistentVolume

PersistentVolume类似Volume, 但是他具有独立的生命周期.

PersistentVolumeClaim(PVC)是对PV的申请, 通过在Pod中指定PVC, 之后PVC会去寻找符合条件的pv进行绑定, **pvc和pv是一一映射的**, 即一个pv只能和一个pvc进行绑定, 一个pvc也只能和一个pv绑定

当pvc和pv绑定之后, pod就可以使用pvc了而无需关系pv的实现细节





pv的实现是多种多样的, 你可以指定多种存储实现

- hostPath

  直接使用集群中某个节点的宿主机路径, 使用这种类型的pv, 相当于hostPath类型的Volume

  pod与节点强绑定, 如果Pod换了节点, 数据就没有了

  常常用在单节点集群, 测试环境, 不推荐生产使用

- local

  使用集群中的某个节点的某个磁盘/SSD/NVMe来作为存储, **需要配合亲和性一起使用**

  同样的pod不能迁移

  性能相较于其他的存储较好, 因为pod和pv都在一个节点上, 常常用在数据库, 日志, 缓存的场景

- nfs

  使用nsf网络文件系统, 多pod可以共享nfs, 部署简单, 性能一般

其他的一些存储类型还有

`Ceph文件系统, ceph-rbd块存储, iSCSI网络块设备, azureDisk, azureFile, alicloudDisk, csi.cbs.tencent.com`等等



> pv的yaml中没有namespace这个字段, 因为pv资源属于整个集群



### 创建PV

#### nfs类型的pv

下面是通过nfs创建一个PersistentVolume的yaml案例

**记得根据上面创建nfs的Volume的教程安装nfs组件**

~~~yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0003 # pv的名字
  namespace: default # pv所在的命名空间
  labels:  # 定义pv的label
    pv-type: example-label
    environment: dev
spec:
  capacity:
    storage: 5Gi # 定义pv的容量
  # 存储卷模式: 可选值: [Filesystem | Block]
  # Filesystem: 文件系统, 默认值
  # Block: 块设备, 支持的类型有AWSElasticBlockStore、AzureDisk、FC、GCEPersistentDisk、iSCSI、Local volume、RBD（Ceph Block Device）、VsphereVolume（alpha）
  volumeMode: Filesystem 
  # 访问模式
  # ReadWriteOnce: 该pv只能被单个节点以读写模式挂载
  # ReadOnlyMany: 该pv可以被多个节点以只读模型挂载
  # ReadWriteMany: 该pv可以被多个节点以读写模型挂载
  # !!! 这里非常重要的是, 多个还是单个节点, 而不是单个还是多个pod
  # 因为真正pv真正是amoute到节点上的, 有些类型的pv只能amount到一个节点上, 比如hostPathl, local类型的
  # 如果你要使用ReadWriteMany和ReadOnlyMany的话, 那么pv的实现必须是分布式文件系统, 有一致性协议等功能, 比如NFS, CephFs等
  # 只要amoute上去了, 那么同一个节点的多个pod就可以同时使用这个pv
  accessModes:
    - ReadWriteOnce
  # 回收策略, 用于指定当与之关联的pvc被删除后, pv如何处理
  # Retain(保留): 当对应的pvc被删除后, pv将被保留并被标记为已释放(released), 
  #                   但是不能重新和其他的pvc进行绑定, 因为pv中还保留着上次的数据
  # Delete(删除): 在对应的pvc被删除后, 将pv进行删除, 并删除物理层面的数据
  # Recycle(回收): 已被废弃, 回收策略 Recycle 会在卷上执行一些基本的擦除 （rm -rf /thevolume/*）操作，之后允许该卷用于新的 PVC 申领
  persistentVolumeReclaimPolicy: Retain
  # 用于标记资源的特性和性能
  # 具有特定storageClassName的PV只能与相同storageClassName的PVC进行绑定。
  # 没有storageClassName的PV只能与没有storageClassName的PVC进行绑定。
  storageClassName: slow 
  # 挂载参数, 依据不同的实现类型不同而不同
  mountOptions:
    - hard
    - nfsvers=4.1
  # 创建的是nfs类型的pv
  nfs:
    path: /nfs/data
    server: cdh107
~~~



#### hostPath类型的pv

~~~yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: hostpath-pv-demo
  labels:
    type: local
    env: dev
spec:
  capacity:
    # 逻辑容量, k8s不会真正限制hostPath磁盘的使用, 这个只用于PVC的匹配
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    # hostpath类型的只能使用这个, 因为物理层面就不可能挂载到多个节点
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  # 用于匹配指定storageClassName的pv
  storageClassName: hostpath-sc
  mountOptions:
    - noatime 
  hostPath:
    path: /data/k8s/hostpath-pv
    # 可选的值有
    # Directory: 目录不行存在
    # Directory: 不存在就创建
    # File: path指定的必须是文件
    # FileOrCreate: path指定的文件, 不存在就创建
    # Socket: path指定的是Unix Socket
    # CharDevice: path指定的是字符设备
    # BlockDevice: path指定的是块设备
    type: DirectoryOrCreate
~~~

#### local类型的pv

local类型的pv和hostPath类型的pv的不同在于, hostPath挂载的是一个本地目录, 而local类型的挂载的是一个本地磁盘

~~~yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: openobserve-local-pv
  labels:
    app: openobserve
spec:
  capacity:
    storage: 200Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  # 这个名字可以随便起
  storageClassName: local-storage

  # 指定磁盘挂载的目录
  local:
    path: /data/openobserve

  # 必须有 nodeAffinity, 因为本地磁盘只有在特定的节点上有
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node-157   # 指定挂载磁盘的节点
~~~





### pv的亲和性

PV在创建的时候, 也可以指定PV的亲和性, 主要用于限制PV调度到的节点

> pv没有反亲和性

~~~yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: openobserve-local-pv
  labels:
    app: openobserve
spec:
  capacity:
    storage: 200Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /data/openobserve
  nodeAffinity:
    # 必须要满足的条件
    required:
      nodeSelectorTerms:
      # 通过lable来匹配node的label
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node-157   # 指定挂载磁盘的节点
~~~







查看pv以及他的描述信息

~~~shell
kubectl create -f pv.yaml # 根据yaml创建pv

kubectl get pv -n namespace # 查看指定命名空间中的pv
kubectl get pv -A # 查看所有命名空间中的pv

kubectl describe pv -n namespace_name pv0003 # 查看pv的详细情况
kubectl describe pv -n namespace_name pv0003 -o yaml# 以yaml的形式查看pv的详细情况

kubectl delete pv -n namespace_name pv0003 # 删除pv
~~~

<img src="img/k8s笔记/image-20231024195234180.png" alt="image-20231024195234180" style="zoom:50%;" />



### 创建pvc

下面是一个PersistentVolumeClaims的案例, 通过下面yaml创建pvc后, 他会找到一个符合条件的pv进行绑定

匹配条件如下:

- pv和pvc的storageClassName必须相等
- pv和pvc的accessModes必须相等
- pv和pvc的volumeMode必须相等
- pv的capacity必须大于pvc的capacity
- pvc的selector必须包含pv

~~~yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim # 定义pvc的名字
  namespace: default # pvc所在的命名空间
spec:
  accessModes:
    - ReadWriteOnce # 该pvc只会寻找同样accessModes的pv进行绑定
  volumeMode: Filesystem # 该pvc只会寻找同样volumeMode的pv进行绑定
  resources:
    requests:
      storage: 4Gi # 该pvc只会寻找大于等于storage的pv进行绑定
  # 该pvc只会寻找相同storageClassName的pv进行绑定, 如果没有指定storageClassName, 那么也只会找没有storageClassName的pv进行绑定
  storageClassName: slow 
  selector:
    matchLabels: # 定义绑定的pv需要对应的label
      pv-type: example-label
    matchExpressions: # 定义绑定的pv需要对应的label
      - {key: environment, operator: In, values: [dev]}
~~~

相关的shell

~~~shell
kubectl create -f pvc.yaml

kubectl get pvc -n namespace # 查看指定命名空间的pvc
kubectl get pvc -A # 查看所有的pvc

kubectl describe pvc -n namespace_name pvc_name # 查看指定命名空间中的指定pvc的详细情况

kubectl delete pvc -n namespcae_name pvc_name # 删除指定命名空间中的pvc
~~~

![image-20231024195827068](img/k8s笔记/image-20231024195827068.png)

如上图所示, pvc以及绑定到了pv0003上面





### 使用pvc

下面是一个使用pvc的案例

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html" # 绑定pvc对应的pv到指定路径
        name: mypd
  volumes: # 定义一个pvc类型的volumes
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim # pvc的名字叫myclaim
```

<img src="img/k8s笔记/image-20231024200104408.png" alt="image-20231024200104408" style="zoom: 33%;" />

<img src="img/k8s笔记/image-20231024200232138.png" alt="image-20231024200232138" style="zoom:50%;" />





### 自动创建的pvc

当然你也可以直接在创建Controller的时候, 直接创建要使用的pvc来

~~~shell
# 创建headless service
apiVersion: v1
kind: Service
metadata:
  name: headless-svc-nginx
  labels:
    app: nginx
spec:
  ports:
    - port: 80
      name: web
  clusterIP: None # 指定ClusterIp为None, 创建无头服务
  selector:
    app: nginx
---
# 创建StatefulSet
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: headless-svc-nginx # 使用上面创建的service来创建statefulset
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx1
          image: nginx:1.24
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
  # 直接创建pvc, 并绑定到pod中, 因为有3个副本, 所以会创建3个pvc
  # 并且pvc的名字的格式会按照如下的格式: $name-${podname}
  # 创建的pvc名字是 data-web-0, data-web-1, data-web-2
  volumeClaimTemplates: 
    - metadata:
        name: data
      spec:
        accessModes: [ "ReadWriteOnce" ] 
        # 指定匹配的pv的storageClassName
        storageClassName: "nfs"
        resources:
          requests:
            storage: 1Gi
~~~



### StorageClass

这里说的StorageClass并不是在pv和pvc中指定的storageClassName这个东西,  而是一种k8s资源, 和pv, controller, pvc一样,  你可以使用如下的命令来查看k8s中的StorageClass

> StorageClass 和 PV一样是集群资源, 所有没有命名空间

~~~shell
[admin@kygfb sys49482]$ kubectl get sc -A
NAME                                PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path                          rancher.io/local-path          Delete          WaitForFirstConsumer   false                  33h
seasql-base-local-storage           kubernetes.io/no-provisioner   Delete          Immediate              false                  33h

[admin@kygfb sys49482]$ kubectl describe sc seasql-base-local-storage
Name:                  seasql-base-local-storage
IsDefaultClass:        No
Annotations:           meta.helm.sh/release-name=seasql-base,meta.helm.sh/release-namespace=service-software
Provisioner:           kubernetes.io/no-provisioner
Parameters:            <none>
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
~~~



StorageClass使用的场景是云服务器, 在云服务器中, 你可以通过云服务提供的k8s插件, 动态的创建pv, 而无需提前创建出pv, 因为云的资源是无限的, 你想要多少就有多少(你有钱的话)

所以在这样的场景中, 你只需要创建对应的pvc, 就可以动态的创建pv



比如我有一个statefulset类型的controller, 他控制了3个pod, 每个pod都需要一个pv

~~~yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx1
          image: nginx:1.24
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
  # 直接创建pvc, 并绑定到pod中, 因为有3个副本, 所以会创建3个pvc
  # 并且pvc的名字的格式会按照如下的格式: $name-${podname}
  # 创建的pvc名字是 data-web-0, data-web-1, data-web-2
  volumeClaimTemplates: 
    - metadata:
        name: data
      spec:
        accessModes: [ "ReadWriteOnce" ] 
        # 指定匹配的pv的storageClassName
        storageClassName: "nfs"
        resources:
          requests:
            storage: 1Gi
~~~

按照上面的配置, 会创建出三个pvc, 分别是data-web-0, data-web-1, data-web-2, 那么按照k8s的匹配规则

1. 首先查找有一个存在的pv, 满足如下的条件
   - PV.spec.storageClassName == PVC.spec.storageClassName (如果pv和pvc都没有指定storageClassName的话, 也算匹配)
   2. PV.accessModes 能满足 PVC.accessModes
   3. PV容量 >= PVC请求的容量
   4. PV未被绑定

2. 如果匹配现有的PV失败的话, 会查找pvc的storageClassName的字段

   - 如果指定了, 那么就使用指定的值
   - 如果pvc没有指定storageClassName的话, 并且**系统有默认的storageClassName**的话, 那么就使用默认的storageClassName

   之后使用storageClassName字段的值, 去查找有没有相同名字的StorageClass资源, 如果有的话, 那么查找这个StorageClass的`provisioner`属性

3. 在获取到`provisioner`属性之后, 如果不是`kubernetes.io/no-provisioner`的话, 那么就使用对应的插件去创建出需要的pv, 然后和pvc进行绑定

   这样你就无需提前创建pv了, 只要创建了pvc, 然后storageClassName匹配上了StorageClass, 就会自动的创建出对应的pv

> 总结的话就是
>
> 当你创建 PVC 时，如果匹配现有的pv失败, Kubernetes 会根据 PVC 的 `storageClassName` 找到对应 StorageClass，然后调用 `provisioner` 来 **动态创建 PV（Dynamic Provisioning）** 。

> 一定要将pvc和pv的storageClassName和StorageName分开,  如果你不是云场景的话, 没有动态创建pv的能力, 那么storageClassName只是一个标签, 用来匹配pv和pvc的
>
> storageClassName是可以随便指定的,  不一定要和现有的StorageName重名

你可以通过如下的yaml来创建一个sc

~~~yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  # 指定StorageClass的名字
  name: local-storage
# 指定动态创建pv的插件, 可选的值有:
# kubernetes.io/no-provisioner: 不动态创建PV, 必须使用已经创建好的pv
# kubernetes.io/aws-ebs: aws云盘
# kubernetes.io/gce-pd: google云盘
# kubernetes.io/cinder: OpenStack Cinder
provisioner: kubernetes.io/no-provisioner

# 插件的参数
parameters:
  aa: bb
  cc: dd
  
# PV绑定的时机, 可选地值有:
# Immediate: pvc创建就绑定
# WaitForFirstConsumer: pod调度后再绑定
volumeBindingMode: WaitForFirstConsumer
# 卷删除后的行为, 可选择有:
# Delete: 
# Retain: 
reclaimPolicy: Retain
# 是否允许卷扩容, true/false
allowVolumeExpansion: true
# 卷挂载的选项
mountOptions:
 - noatime
 - aaa
~~~





## 特殊的变量

在上面的内容中, 我们可以将ConfigMap, Qpaque的挂载到环境变量中, 当然k8s中还有一些特殊的变量, 可以让我们挂在到环境变量中

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
  namespace: default
spec:
  containers:
    - name: example-container
      image: nginx:latest
      env:
        # spec.nodeName表示pod所在的node的名称, 可以通过kubectl get nodes来查看
        # 下面代码将spec.nodeName设置为pod的环境变量NODENAME
        - name: NODENAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        # metadata.name 表示当前pod的名称
        # 下面代码将metadata.name 设置为pod的POD_NAME环境变量
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        # metadata.namespace 表示当前pod所在的命名空间
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        # status.podIP表示当前pod在docker中的ip
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        # status.hostIP表示当前pod所在的node的ip
        - name: NODE_IP
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        # metadata.labels['app'] 表示当前pod的label app的
        - name: POD_LABEL
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['app']
        # 挂etadata.annotations['example-annotation'] 表示当前pod的annotations中的example-annotation的值
        - name: POD_ANNOTATION
          valueFrom:
            fieldRef:
              fieldPath: metadata.annotations['example-annotation']
        # spec.containers[0].name表示pod中第一个容器的名字（容器索引从 0 开始）
        - name: CONTAINER_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.containers[0].name


```







## 存储卷的细节

- 对于configmap类型的存储卷, 可以配置item, 这样可以不用挂载全部的文件和目录到pod中

  通过key来指定configmap中的key, path指定挂载到pod中文件的名称(默认是文件名就是key)

- volumeMounts中可以指定一个subPath选项

  不过不指定的话, mountPath默认是目录, 会把卷中的所有东西都挂载到mountPath中

  如果指定了subPath的话, mountPath就是subPath(subPath是文件, mountPath就是文件, subPath是目录, mountPath就是文件)

~~~yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-config
data: 
  a: aaa
  b: bbb
  c: ccc
  d: ddd
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: es
  name: es
spec:
  replicas: 1
  selector:
    matchLabels:
      app: es
  template:
    metadata:
      labels:
        app: es
    spec:
      containers:
        - name: container-sgydlp
          image: 'nginx:1.24'
          volumeMounts:
          # 如果不指定subPath的话, /test/c11会被认为是目录, 并且会把a1, b1, c1都挂载到/test/c11/下面
          # 下面指定了subPath, 如果c1是目录, 那么/test/c11就是c1目录
          # 如果c1是文件, 那么/test/c11也是文件
            - name: test-config
              readOnly: true
              mountPath: /test/c11 # 
              subPath: c1 # 因为configmap中指定了别名, 所以这里必须使用别名
            - name: test-config
              readOnly: true
              mountPath: /test/a11 # 
              subPath: a1 
      volumes:
        - name: test-config
          configMap:
            name: test-config
            # 不挂载configmap下面的所有配置, 只配置指定的配置
            items:
              - key: a # configmap下面的key
                path: a1 # 挂载到configmap下的别名(默认就是key)
              - key: b
                path: b1
              - key: c
                path: c1
~~~

上面这样配置可以适用在如下的场景中:

1. 一个共享卷挂载多个目录

   ~~~yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-lamp-site
   spec:
       containers:
       - name: mysql
         image: mysql
         env:
         - name: MYSQL_ROOT_PASSWORD
           value: "rootpasswd"
         volumeMounts:
         # 将site-data下的html目录挂载到/var/lib/mysql
         - mountPath: /var/lib/mysql
           name: site-data
           subPath: mysql
         - name: php
           image: php:7.0-apache
         volumeMounts:
         # 将site-data下的html目录挂载到/var/www/html
         - mountPath: /var/www/html
           name: site-data
           subPath: html
       volumes:
       - name: site-data
         persistentVolumeClaim:
           claimName: my-lamp-site-data
   ~~~

2. ConfigMap和Secret只挂载特定的文件, 并且只挂载到特定路径上, 而不覆盖整个目录

   ~~~yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: tomcat
   spec:
       containers:
       - name: tomcat
         image: tomcat
         volumeMounts:
         # 如果我不使用subpath, 直接将该ConfigMap 挂载到/opt/tomcat/bin目录下, 那么该目录下已有的文件全部被覆盖.
         - mountPath: /opt/tomcat/bin/setenv.sh
           name: volume-env
           subPath: setenv.sh
       volumes:
       - name: volume-env
         configMap:
           name: env-config
           items:
           # 只挂载指定的文件
           - key: setenv.sh
             path: setenv.sh # 文件别名
   ~~~

   

# 调度

## 调度过程

调度分为几个部分：

1. 先过滤掉不满足条件的节点，这个过程称为 `predicate` ；
2. 对通过的节点按照优先级排序，这个是 `priority` ；
3. 最后从中选择优先级最高的节点。如果中间任何一步骤有错误，就直接返回错误

Predicate 有一系列的算法可以使用：

- `PodFitsResources` ：节点剩余资源是否大于 pod 请求的资源
- `PodFitsHost` ：如果 pod 指定了 NodeName，检查节点名称是否和 NodeName 匹配
- `PodFitsHostPorts` ：如果pod指定了hostPort, 那么说明这个pod需要将宿主机的端口, 映射到pod容器内的端口, 所以还需要检查宿主机的端口有没有被其他的节点占用
- `PodSelectorMatches` ：过滤掉和 pod 指定的 label 不匹配的节点
- `NoDiskConflict` ：已经 mount 的 volume 和 pod 指定的 volume 不冲突，除非它们都是只读

如果在 predicate 过程中没有合适的节点，pod 会一直在 pending 状态，不断重试调度，直到有节点满足条件。



经过这个步骤，如果有多个节点满足条件，就继续 priorities 过程： 按照优先级大小对节点排

优先级由一系列键值对组成，键是该优先级项的名称，值是它的权重（该项的重要性）。

这些优先级选项包括：

- `LeastRequestedPriority` ：通过计算 CPU 和 Memory 的使用率来决定权重，使用率越低权重越高。换句话
  说，这个优先级指标倾向于资源使用比例更低的节点

- `BalancedResourceAllocation` ：节点上 CPU 和 Memory 使用率越接近，权重越高。这个应该和上面的一起
  使用，不应该单独使用

- `ImageLocalityPriority` ：倾向于已经有要使用镜像的节点，镜像总大小值越大，权重越高

通过算法对所有的优先级项目和权重进行计算，得出最终的结果



## 亲和性和反亲和性

### 节点亲和性

硬亲和性: **pod必须调度到label满足特定条件的node上**

软亲和性: pod优先调度到label满足特定条件的node上

每个Node上都会有一个label, key为 `kubernetes.io/hostname`, value为`当前主机hostname`

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity
  labels:
    app: node-affinity-pod
spec:
  containers:
    - name: with-node-affinity
      image: hub.atguigu.com/library/myapp:v1
  affinity:
    nodeAffinity:
      # 硬亲和性, pod必须调度到label满足以下条件的node上
      requiredDuringSchedulingIgnoredDuringExecution: 
        nodeSelectorTerms:
          # 如果在这里指定了多个matchExpressions, 那么只要其中一个, 节点就满足了条件
          # 即多个matchExpressions是或的关系
          - matchExpressions:
            # 如果在这里指定了多个key, 那么他们之间的关系是且的关系
            # 被分配的节点的label必须满足含有key为disktype, 并且value为ssd或者disk
            - key: disktype
              operator: In # 操作符[In NotIn Exists Gt Lt Equal DoesNotExists]
              values: 
              - ssd 
              - disk
      # 软亲和性, pod优先调度到label满足以下条件的node上
      preferredDuringSchedulingIgnoredDuringExecution: 
      # 符合条件的节点会获得weight指定的分数, 然后k8s会根据weight来计算总分, 分越高的节点优先级越高
      - weight: 1 
        preference:
          # 多个matchExpressions之间是或的关系
          # 同一个matchExpressions下面的多个key, 是且的关系
          matchExpressions:
            - key: disktype # key
              operator: In  # 操作符[In NotIn Exists Gt Lt Equal DoesNotExists]
              values: # value
              - ssd 
              - disk
~~~

### Pod亲和性和反亲和性

Pod 间亲和性与反亲和性使你可以基于已经在节点上运行的 **Pod** 的标签来约束 Pod 可以调度到的节点，而不是基于节点上的标签。



**在设置亲和性和反亲和性的时候, 需要设置一个label  key为`topologyKey`, 根据node上的该label的value将集群分为多个拓扑区域**

比如有如下四台机器ABCD, 其中AB在上海, CD在深圳, 那么我们可以指定AB节点的label为`location:sh`, CD的label为`location:zs`

<img src="img/k8s笔记/image-20231020224224332.png" alt="image-20231020224224332" style="zoom: 33%;" />

- 我们可以通过`topology=location`将集群分为sh和sz两个拓扑区域

- 也可以通过`topology=kubernetes.io/hostname`将集群的每一个节点划分为一个拓扑区域, 因为`kubernetes.io/hostname`这个label是每个node都默认有的, 值为每个节点的hostname, 所以能够将每个节点都划分为一个拓扑区域

> Note: 必须要每个节点上都有该label标签, 才能将label key作为topologyKey



Pod 间亲和性的意思为: **如果某个拓扑区域已经有符合某些条件的pod了,  那么就应该将pod分配到这个拓扑区域的随机节点上**

Pod间反亲和性的意思为: **如果某个拓扑区域已经有符合某些条件的pod了,  那么就不应该将pod分配到这个拓扑区域的随机节点上**

以下为pod亲和性案例: 

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: java
spec:
  affinity:
    # pod亲和性
    podAffinity:
      # 如果某个拓扑区域上有pod的label满足条件, 就必须调度上这个拓扑区域的节点上

      # 下面的作用是根据node的location label来划分拓扑区域
      # 如果某个拓扑区域中有label为app=mysql或者app=pg的pod
      # 那么当前的pod就必须分配在这个拓扑区域中
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - mysql
            - pg
        topologyKey: location
      # 如果某个拓扑区域上有pod的label满足条件, 就优先调度上这个拓扑区域的节点上

      # 下面的作用是根据node的location label来划分拓扑区域
      # 如果某个区域中有label为app=mysql或者app=pg的pod
      # 那么当前pod就优先分配在这个拓扑区域中, 并且这些node的权重得分+100
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector: # 标签选择器
            matchExpressions:
            - key: app
              operator: In
              values:
              - mysql
              - pg
          topologyKey: location # 指定通过location的label来划分拓扑区域
  containers:
  - name: java
    image: registry.k8s.io/pause:2.0

~~~

在上面的案例中, 我们通过location来划分拓扑区域, 那么AB为一个拓扑区域, CD为一个拓扑区域

如果在A节点上有pod的label满足app in (mysql),  那么就会将我们创建的名为java的pod 优先/ 必须调度到AB节点上

**这种情况适用于将两个服务的 Pod 放到同一个云提供商可用区内，因为它们彼此之间通信非常频繁**



以下是反亲和性的案例:

~~~yaml

apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    # 节点反亲和性
    podAntiAffinity:
      # 如果某个拓扑区域上有pod的label满足条件, 就一定不能调度将pod调度到这个区域的节点上

      # 下面的作用是根据node的location label来划分拓扑区域
      # 如果某个拓扑区域中有label为jdk=jdk11或者jdk=jdk18的pod
      # 那么当前的pod就一定不能分配在这个拓扑区域中
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: jdk
            operator: In
            values:
            - jdk11
            - jdk18
        topologyKey: location  # 指定通过location的label来划分拓扑区域
      # 如果某个拓扑区域上有pod的label满足条件, 就优先不将该pod调度到这个区域的节点上

      # 下面的作用是根据node的location label来划分拓扑区域
      # 如果某个区域中有label为security=S2或者security=S3的pod
      # 那么当前pod就不优先分配在这个拓扑区域中, 并且这些node的不优先权重得分+100
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
              - S3
          topologyKey: location  # 指定通过location的label来划分拓扑区域
  containers:
  - name: java1
    image: registry.k8s.io/pause:2.0
~~~

在上面的案例中, 我们通过location来划分拓扑区域, 那么AB为一个拓扑区域, CD为一个拓扑区域

如果在A节点上有pod的label满足app in (java2),  那么就会将我们创建的名为java1的pod 一定不能/优先不  调度到AB节点上

**这种情况适用于将同一服务的多个 Pod 分布到多个云提供商可用区中。**

## NodeSelector

nodeSelector是最简单的, 将pod分配到符合label的node上

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  nodeSelector:
    disktype: ssd # 将pod分配到节点的label中disktype=ssd的节点上
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent

```

对于k8s的master节点, 他固定会有两个特定的label用来标识他的master身份, 分别是`node-role.kubernetes.io/control-plane=`和`node-role.kubernetes.io/master=`

你可以通过`kubectl get nodes --show-labels`来查看到底有没有这两个label

如果你想要pod只跑在master上面, 那么可以通过这两label来指定

~~~shell
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: nginx
  nodeSelector:
    node-role.kubernetes.io/master: ""
~~~







## NodeName

**强制调度到指定的节点上面, 会跳过Scheduler的调度策略**

使用 `nodeName` 来选择节点的方式有一些局限性：

- 如果所指代的节点不存在，则 Pod 无法运行，而且在某些情况下可能会被自动删除。
- 如果所指代的节点无法提供用来运行 Pod 所需的资源，Pod 会失败， 而其失败原因中会给出是否因为内存或 CPU 不足而造成无法运行。
- 在云环境中的节点名称并不总是可预测的，也不总是稳定的。

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  nodeName: foo-node # 调度 Pod 到特定的节点
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
~~~

## 污点和污点容忍

污点(Taints)和污点容忍(Tolerations) 主要解决了以下的作用

- 节点排斥: 避免pod被调度到不合适的特定节点(专用于GPU的节点)上

- 节点隔离: 标记故障或者维护中的节点, 防止pod被调度到这些节点上

- 优先级调度: 运行特定的pod可以容忍污点, 调度到有污点的node上

每个node都可以被设置多个污点Taints, 如果pod不能容忍这些污点, 那么不会调度到这个pod上, 如果pod能够容忍这些污点, 那么就有可能调度到这个node上

### 污点

每个污点都有key, value, effect组成, 格式为`key=value:effect`

- key表示当前污点的名称

- value表示污点的值, 可选, 可以问空

- effect决定了排斥pod的方式, 他的取值如下
  
  1. NoSchedule: 表示k8s不会将新的pod调度到这个node上面, 但是已经在这个node上面的pod可以继续运行
  
  2. PreferNoSchedule: 表示k8s尽量避免将pod调度到该节点上面, 已经在这个node上面的pod可以继续运行
  
  3. NoExecute: 表示k8s不会将新的pod调度到当前node上面, 同时会将节点上已经存在的, 不能容忍这个污点的pod驱逐
     
     (**如果被驱逐的pod被deployment控制, 那么他会漂到其他机器上, 否则就直接没有了**)



```shell
# 设置污点到指定的node上
kubectl taint nodes <node-name> key1=value1:effect
# 案例: 禁止普通pod调度到GPU节点上
kubectl taint nodes node1 gpu=true:NoSchedule

# 查看node上面的污点
kubectl describe nodes <node-name> | grep Taints

# 去除指定node上的污点, 特别要注意后面有一个减号
kubectl taint nodes <node-name> key-
# 案例
kubectl taint nodes node1 gpu-
```

### 污点容忍


设置了污点的 Node, Pod 将在一定程度上不会被调度到 Node 上。 但我们可以在 Pod 上设置污点容忍 ( Toleration ) , 使得当前pod可以被调度到有污点的节点上.

~~~yaml
apiVersion: v1       
kind: Pod       
metadata:       
  name: string       
spec:         
  containers:      
  - name: nginx     
    image: nginx   
  tolerations:
    # 其中 key, vaule, effect 要与 Node 上设置的 taint 保持一致, 才能容忍污点
    - key: "key1"
      operator: "Equal" # [In NotIn Exists Gt Lt Equal DoesNotExists], 当值为Exists时将会忽略value值
      value: "value1"
      effect: "NoSchedule"
      # 这个配置仅对NoExecute有效
      # 描述当node被标记为NoExecute污点后, Pod再被关闭之前, 还可以运行多长时间
      tolerationSeconds: 3600
```

当不指定 key 值时，表示容忍所有的污点 key：

​~~~yaml
tolerations:
  - operator: "Exists"
~~~

当不指定 effect 值时，表示容忍所有的污点作用

~~~yaml
tolerations:
  - key: "key"
    operator: "Exists"
~~~

有多个 Master 存在时，防止资源浪费，可以如下设置

~~~shell
# 设置一个污点, 让pod尽量不要调度到master节点
kubectl taint nodes Node-Name node-role.kubernetes.io/master=:PreferNoSchedule
~~~





# Operator

## CRD

Kubernetes 内置资源有很多，比如Pod, Deployment, Service等等, 但这些资源**不可能覆盖所有业务场景**。
于是 Kubernetes 提供了一套**扩展 API 的能力** —— **Custom Resource Definition（CRD）**。



如果没有CRD的情况下, 如果我们要搭建一个flink集群的话就写一堆的yaml文件, 这些yaml文件就是告诉k8s一步一步怎么去创建对应的集群, 这是一种声明式的管理

但是在使用了自定义资源之后



自定义资源中有如下的核心概念

| 名称    | 含义                                             |
| ------- | ------------------------------------------------ |
| **CRD** | CustomResourceDefinition，**定义一种新资源类型** |
| **CR**  | Custom Resource，**该类型的具体实例**            |

CRD ≈ Java 里的 `class`, CR ≈ Java 里的 `new 对象()`









# 称加密, 非对称加密, 电子签名, CA证书, HTTPS

## 对称加密

即加密和解密都使用同一套规则, 会面临中间人攻击

## 非对称加密和中间人攻击

每个人都有一对公私钥,   私钥自己保留, 公钥公开给所有人

能够通过公钥加密, 私钥解密,   也可以私钥加密, 公钥解密(电子签名)

比如ab两个人进行通信, 那么ab两个人会分别生成一对公私钥, a(a_pri/a_pub),   b(b_pri, b_pub)

并且两个人都发送公钥给对方

当a发送消息给b的时候, 通过b_pub + message = 密文 发送给b,   b通过b_pri + 密文 = message

当b发送消息给a的时候, 通过a_pub + message = 密文 发送给a,   a通过a_pri + 密文 = message





但是上面的形式, 无法避免中间人攻击, 过程如下

ab分别生成公私钥,.  a(a_pri/a_pub),   b(b_pri, b_pub),   同时有一个中间人c也生成了两对公私钥(ca_pri/ca_pub)(cb_pri/cb_pub)

当a给b发送公钥a_pub的时候,  被中间人c截获, 并替换为自己的公钥ca_pub

当b给a发送公钥b_pub的时候,  被中间人c截获, 并替换为自己的公钥cb_pub

于是a给b发送消息的时候, a就会使用cb_pub进行加密生成密文, 如果这个密文再次被c截获, 就可以通过cb_pri解密, 然后c将解密后的明文通过b_pub进行加密发送给b,   这样b就无法发现自己的信息被截获了



## 电子签名

电子签名同样使用的是非对称加密, 但是和加密通信不同的是, 电子签名通过私钥进行加密, 通过公钥进行解密

通常情况下, 要对一个文件或者信息进行签名,  考虑到信息量很大,  通常使用效率更高且固定长度的 Hash算法(摘要算法)对文件或者信息提取摘要, 然后对提取的摘要通过私钥进行加密, 即签名

因为公钥是公开的, 所有人都能够获取, 所以如果这个签名能够被公钥进行解密, 并且解密出来的摘要和原文件的摘要一致, 那么就可以证明是私钥的持有者进行的加密,  因为只要他才能够生成这样一个特殊的签名



但是这样的方式也有一定的弊端,  即电子签名能够保证`这个签名一定是公钥对应的私钥的持有者进行签名的`, 但是不能够保证`私钥的持有者就是你认为的那个人`

打个比方, A需要对一个电子合同进行签名, 但是他却谎称B的公私钥是自己的公私钥,  并使用B的私钥进行签名, 合同的接收方也使用B的公钥进行解密, 来确认这个合同是A签署的

后面A却说这个合同和自己无关, 是B签署的,  同时B也可以耍赖, 说这个私钥的持有者不是自己



## CA证书 (Certificate Authority)

使用非对称加密来进行通信, 或者电子签名都会有一定的问题

即无法确认公钥是否可信

在加密通信中, 被中间人攻击, 是因为我们无法确认收到的公钥是否就是信息的接收方

在电子签名中, 我们无法确认私钥的持有者到底是谁

所以这个时候就需要一个权威机构来认证, 一个公钥到底属于谁, 该过程如下:

1. CA机构会生成一个公私钥(ca_pub/ca_pri), 并且这个公钥会发布给所有人, 所有人都知道这个公钥是CA机构的
2. A拿着自己的公钥和企业信息找CA机构申请证书, 来证明这个公钥就是A持有的
3. CA机构通过自己的私钥对A的公钥并附带其他信息进行加密
4. A把这个证书和自己的公钥发送给其他人
5. 其他人通过CA机构的公钥对证书进行解密, 得到A的公钥和附带信息, 并和A发送来的公钥做对比, 就能够证明这个公钥确实是A持有的

这样就能够避免加密通信中的中间人攻击

在上面的例子中, ab都找CA机构申请证书, 并且在交换的时候附带证书, 那么他们两个就可以确定, 自己要沟通的人就是对方, 而不是中间人

同时在电子签名中, 也可以通过证书找到对应的公钥的持有者

## CA机构的层级

https://www.bilibili.com/video/BV15P4y1S7Jw/?spm_id_from=333.337.search-card.all.click&vd_source=f79519d2285c777c4e2b2513f5ef101a

在CA机构中, 会有跟CA机构, 和中间CA机构以及一些比较小的CA机构

**跟CA机构是权威的, 是不需要别人证明, 他们的公钥一般会保存着浏览器或者操作系统中, 不能轻易被修改**

即我们不可能所有的证书都找跟CA机构签发, 所以会有一些中间CA机构,  找到跟CA机构申请证书, 用以证明, 自己签发的证书是有效的, 可信的

即跟CA机构给这些中间CA机构做担保

如下图可以查看b站的ca证书

<img src="img/k8s笔记/image-20231019151018367.png" alt="image-20231019151018367" style="zoom: 50%;" />![image-20231019151053296](img/k8s笔记/image-20231019151053296.png)

<img src="img/k8s笔记/image-20231019151106302.png" alt="image-20231019151106302" style="zoom:50%;" />

可以看到该证书的颁发机构是GlobalSign RSA OV SSL CA 2018

<img src="img/k8s笔记/image-20231019154325223.png" alt="image-20231019154325223" style="zoom:50%;" />

并且可以在信息信息中发现, 跟CA机构GlobalSign签发了GlobalSign RSA OV SSL CA 2018中间CA机构

然后GlobalSign RSA OV SSL CA 2018中间CA机构签发了b站的证书

## https

https://www.bilibili.com/video/BV1KY411x7Jp/?spm_id_from=333.337.search-card.all.click&vd_source=f79519d2285c777c4e2b2513f5ef101a

## CA证书的详细信息

证书的编码格式:  

- PEM(Privacy Enhanced Mail)，通常用于CA机构，扩展名为`.pem`, `.crt`, `.cer`, 和 `.key`。内容为Base64编码的ASCII码文件，有类似`"-----BEGIN CERTIFICATE-----"` 和 `"-----END CERTIFICATE-----"`的头尾标记。服务器认证证书，中级认证证书和私钥都可以储存为PEM格式（认证证书其实就是公钥）
- DER(Distinguished Encoding Rules)，与PEM不同之处在于其使用二进制而不是Base64编码的ASCII。扩展名为`.der`，但也经常使用`.cer`用作扩展名，所有类型的认证证书和私钥都可以存储为DER格式。Java使其典型使用平台。

证书签名请求:

-  CSR(Certificate Signing Request)，它是向CA机构申请数字×××书时使用的请求文件。在生成请求文件前，我们需要准备一对对称密钥。私钥信息自己保存，请求中会附上公钥信息以及国家，城市，域名，Email等信息，CSR中还会附上签名信息。当我们准备好CSR文件后就可以提交给CA机构，等待他们给我们签名，签好名后我们会收到crt文件，即证书。

  把CSR交给权威证书颁发机构,权威证书颁发机构对此进行签名,完成。保留好`CSR`,当权威证书颁发机构颁发的证书过期的时候,你还可以用同样的`CSR`来申请新的证书,key保持不变.

# CFSSL

https://segmentfault.com/a/1190000038276488

## 1. cfssl 是什么

部署分布式系统服务场景下，如etcd、kubernetes、grpc servers集群时，常用的安全策略除了用户名密码策略外，经常要用到TLS加密和认证策略。一种好用的签名CA证书工具是cfssl工具集。本文讲述以cfssl自签CA证书用于TLS认证技术实践方法。

cfssl的官网地址是：[https://cfssl.org](https://link.segmentfault.com/?enc=2FGHEv13Q1dzbGzMnw6zug%3D%3D.zymjZVIprwMoGc4ef93RKkZcjue61mwm0wOkb8hZj0I%3D)。简单来说，它是美国的一个叫CloudFlare的公司开发的一款开源的工具包，它在CloudFlare公司内部被用来捆绑TLS/SSL证书链，并作为内部证书颁发机构基础架构。

## 2. 安装cfssl软件工具包

cfssl自签证书工具集包含3个软件：

- cfssl: 用于签发证书；
- cfssljson: 将cfssl签发生成的证书(json格式)变成文件承载式文件；
- cfssl-certinfo: 验证查看证书信息。

其官网下载地址是：[https://pkg.cfssl.org](https://link.segmentfault.com/?enc=%2F7A8CFzddBCOSK1HkXc57w%3D%3D.si0gcdGi2gXv2Brdl61TnPo1tp%2B2ZytRj3hGPFf8BbQ%3D)

本文讲述的是CentOS Linux release 7.5.1804 系统下的构建TLS/SSL证书。因此下载linux-amd64版本即可。对应下载1.2版本的如下3个文件即可。
直接执行以下3个命令即可瞬间完成下载3个可执行程序文件：

```awk
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
```

由于都是linux64系统下可执行程序包，直接重命名后放到/usr/local/bin下,并添加可执行权限即可，如下图所示：

```awk
sudo cp cfssl_linux-amd64  /usr/local/bin/cfssl
sudo chmod +x /usr/local/bin/cfssl
sudo cp cfssljson_linux-amd64 /usr/local/bin/cfssljson
sudo chmod +x /usr/local/bin/cfssljson
sudo cp cfssl-certinfo_linux-amd64  /usr/local/bin/cfssl-certinfo
sudo chmod +x /usr/local/bin/cfssl-certinfo

which cfssl
which cfssljson
which cfssl-certinfo
```

![image](https://segmentfault.com/img/bVcKLzx)
至此cfssl工具包安装完毕。本文同时提供1.2版本的linux-amd64架构的cfssl工具包同时提供下载地址如下：

下载链接见: [https://pan.baidu.com/s/19RXgEUVBci-QFavfMMNHFQ](https://link.segmentfault.com/?enc=lQ%2F%2BMLEMmS%2FSkTk9z4QN9g%3D%3D.lRu7a9AuuUmsr7HNyjcWEImLUkn7X29vApSsGBeZZj%2BKdpniilRXUAPBbUrV8zlL) 提取码: nj8k。
![image](https://segmentfault.com/img/bVcKLzO)

## 2. 使用cfssl创建证书实操指南

用cfssl创建我们需要的证书文件的过程分一下3个步骤：

### 2.1 创建CA根证书及其私钥

根证书及其私钥，也即CA证书和CA证书的私钥，是集群所有节点共享的，只需要创建一个 CA 证书即其私钥，后续创建的所有证书都由它签名。CA根证书创建后一般命名是ca.pem。 CA更证书私钥创建后一般命名是ca-key.pem。

> 注意：
>
> **CA根证书及其私钥，只需要创建一次即可。后续其他证书都由它签名，CA根证书及其私钥一旦改变，其它证书也就无效了。**

创建CA根证书及其私钥过程可依照以下2个步骤：

#### 2.1.1 创建CA根证书签名请求文件ca-csr.json

注意ca-csr.json中csr含义是：Certificate Signing Request，证书签名请求，因此看到 xx-csr.json，你就要知道该文件是证书签名请求文件，有了它，cfssl就可以生成证书和证书私钥了。

ca-csr.json该如何配置呢？ 其实很简单，下图是截取的cfssl官网上给出的一个xx-csr.json的示例：
<img src="img/k8s笔记/image-20231019175245274.png" alt="image-20231019175245274" style="zoom:50%;" />

对csr文件内容解释如下：

- CN：Common Name，所有csr文件都必须有字段，对于 SSL 证书，一般为网站域名；而对于代码签名证书则为申请单位名称；而对于客户端证书则为证书申请者的姓名。

- hosts: 网络请求url中的合法主机名或域名集合。

  下面给出2个hosts的例子：(都包含127.0.0.1,并且都使用的是域名或主机名，并且都预留了额外3个host名带extra字样的为预留host,以备后期扩容只用)

```prolog
     "hosts":[
     "127.0.0.1",
     "baseserver1.online-etcd.freedom.org",
     "baseserver2.online-etcd.freedom.org",
     "baseserver3.online-etcd.freedom.org",
     "baseserver-extra1.online-etcd.freedom.org",
     "baseserver-extra2.online-etcd.freedom.org",
     "baseserver-extra3.online-etcd.freedom.org"
     ]
```

~~~
     "hosts":[
     "127.0.0.1",
     "cent7ax",
     "cent7bx",
     "cent7cx",
     "extra-cent7ax",
     "extra-cent7bx",
     "extra-cent7cx"
    ]
~~~



注意：

> 1) 超过该集合范围的任何请求都不会被支持认证通过。
> 2) CA根证书及其私钥创建过程不需要甚至该字段。其它服务证书创建必须有该字段。
> 3) hosts设置技巧：**一般都把"127.0.0.1"包含进去；推荐使用域名或vip,尽量不要用ip地址，否则后期遇到某个服务所在机器宕机要重新更换某1台或多台机器时会面临证书认证不通过的毁灭性尴尬情况，导致扩容失败，集群服务面临毁灭性灾难。这里强烈推荐用域名或vip地址，另外，如果有条件，配置之处建议多预留1-3个host地址，防止后期扩容困难。**

- key: key字段是必须有的字段，其内容一般也比较固定就是：{"algo":"rsa”,"size":2048}，表示使用的加密算法rsa,密文长度2048。
- names字段：也是必须有字段，是证书对外公开显示的一些字段，常见的有如下：

```awk
C:   (Country)所在国家简称，只能是国家字母缩写，如中国：CN
L：  (Locality) 所在地区/城市简称，如Beijing/San Francisco
ST： (State/Provice)所在州/省份简称,如Beijing/California
O：  (Organization Name) 单位名称，对于 SSL 证书，一般为网站域名；而对于代码签名证书则为申请单位名称；而对于客户端单位证书则为证书申请者所在单位名称
OU： (other)显示其他内容,常见的内容值有“System"、"Website"等
```

~~~
电子邮件 (Email)：    简称E 字段 
多个姓名字段 ：        简称G 字段 
介绍Description ：   介绍字段 
电话号码：            Phone 字段，格式要求 + 国家区号 城市区号 电话号码，如： +86 732 88888888 
地址：               STREET  字段 
邮政编码:            PostalCode 字段 
显示其他内容：        简称OU 字段
~~~



综合上述，最终我们生成的ca-csr.json如下图所示：

```json
{
  "CN": "etcd.freedom.com",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "etcd-op",
      "OU": "System"
    }
  ]
}
```

根据该根证书签名请求文件就可以直接通过cfssl工具包生成CA根证书及其私钥了。

#### 2.1.2 根据CA根证书签名请求文件生成CA根证书及其私钥

直接执行命令：

```stata
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```

注意：cfssljson -bare + 命名文件名，如本例中的ca，表示生成ca.pem和ca-key.pem,分别为证书和私钥文件。

![image](https://segmentfault.com/img/bVcKLBB)
生成的ca.pem是CA根证书文件，ca-key.pem是其私钥文件。其内容大体如下样式：
![image](https://segmentfault.com/img/bVcKLBF)
至此，CA根证书及其私钥文件已经生成，便可以用它们来签发其他认证文件了。

### 2.2 根据CA根证书及其私钥签名生成其它证书及其私钥

利用CA根证书及其私钥文件签发生成其它证书及其私钥，分为以下3个步骤执行操作：

#### 2.2.1 创建CA根证书配置文件

CA根证书配置文件，一般命名为ca-config.json,它用于配置根证书的使用场景 (profile) 和具体参数 (usage，过期时间、服务端认证、客户端认证、加密等)，后续在签名其它证书时需要指定特定场景 (profile)。

一个ca-config.json例子如下：

```prolog
{
  "signing":{
    "default":{
      "expiry":"175200h"
    },
    "profiles":{
      "etcd-op":{
        "expiry":"175200h",
        "usages":[
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ]
      }
    }
  }
}
```

~~~
expiry: 175200h表示20年有效期
profiles: 指定证书使用场景，下面的etcd-op是一个场景名称，后续签名生成证书及其私钥时需要指定该场景(profile)名称
signing：表示该证书可用于签名其它证书，生成的 ca.pem 证书中 CA=TRUE
server auth：表示 client 可以用该该证书对 server 提供的证书进行验证
client auth：表示 server 可以用该该证书对 client 提供的证书进行验证
~~~



#### 2.2.2 创建目标证书签名请求文件

签名生成证书及其私钥，首先需要创建csr即证书签名请求文件，如下所示为一个csr证书签名请求文件的示例：

```prolog
{
  "CN":"etcd.freedom.com",
  "key":{
    "algo":"rsa",
    "size":2048
  },
  "hosts":[
    "127.0.0.1",
    "cent7ax",
    "cent7bx",
    "cent7cx",
    "extra-cent7ax",
    "extra-cent7bx",
    "extra-cent7cx"
  ],
  "names":[
    {
      "C":"CN",
      "ST":"BeiJing",
      "L":"BeiJing",
      "O":"etcd-op",
      "OU":"System"
    }
  ]
}
```

将上述内容内存为签名请求文件，比如etcd-csr.json。

#### 2.2.3 根据CA根证书及其私钥签名生成目标证书和私钥

执行命令：

```routeros
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd-op etcd-csr.json | cfssljson -bare etcd
```

![image](https://segmentfault.com/img/bVcKLB9)
如上图，其中的报错可以忽略。
![image](https://segmentfault.com/img/bVcKLCg)
上图所示为最终签名生成的证书及其私钥文件，其中etcd.pem为证书文件，etcd-key.pem为私钥文件。其格式大体与前文提及的ca.pem和ca-key.pem相同。都是一个证书文件，一个是私钥文件，二者配成生成。

### 2.3 校验证书

#### 2.3.1 使用openssl命令校验证书

执行命令：

~~~shell
openssl x509  -noout -text -in  etcd.pem
~~~



```applescript
[root@cent7ax cfssl_dir.bak]# openssl x509  -noout -text -in  etcd.pem 
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            28:fd:f7:a1:e9:f2:03:0b:51:16:18:37:8f:64:46:a9:b6:72:95:67
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=BeiJing, L=BeiJing, O=etcd-op, OU=System, CN=etcd.freedom.com
        Validity
            Not Before: Nov 25 01:47:00 2020 GMT
            Not After : Nov 20 01:47:00 2040 GMT
        Subject: C=CN, ST=BeiJing, L=BeiJing, O=etcd-op, OU=System, CN=etcd.freedom.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:ca:4f:a2:09:9f:12:7c:81:a8:09:4d:6f:c3:96:
                    c0:69:da:fc:9d:10:33:4c:2a:56:ba:06:20:3e:2f:
                    52:2f:15:36:a1:11:89:f7:98:56:b6:8f:38:85:82:
                    02:2c:ac:a8:b1:9e:71:6d:fe:e5:06:1f:a7:7a:3e:
                    9c:be:e2:9d:75:3e:69:1b:9e:06:eb:00:1b:74:60:
                    c3:6c:cc:f8:f4:c9:2c:12:d1:aa:2a:72:3f:5b:e0:
                    d0:45:57:f0:ad:88:6e:a0:59:c4:e4:5d:53:cb:6f:
                    ec:8e:fe:33:32:9f:99:ad:e6:3b:ca:ad:7d:4b:19:
                    8c:eb:7d:92:8e:8e:09:8b:a7:49:2a:1e:73:35:eb:
                    e3:59:4f:87:be:8d:12:cb:23:41:f5:34:bf:1a:4d:
                    04:c0:7c:70:99:8f:ce:51:ca:1c:7c:99:45:0e:b1:
                    d7:91:63:58:4c:a3:73:55:cb:d1:8e:eb:de:cd:5b:
                    89:35:30:4d:45:08:c6:09:de:e2:b0:de:56:aa:13:
                    ac:39:cb:e5:2d:06:06:24:63:fa:eb:c8:20:e0:b8:
                    bb:55:bf:d1:83:4a:9a:dc:2c:56:6c:16:7b:e3:06:
                    53:55:d8:d3:57:e3:82:09:3f:8b:91:1b:b8:68:d1:
                    0f:8f:98:4e:07:fc:94:65:69:6f:bd:59:a7:38:08:
                    79:27
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                F0:73:FD:7B:11:AF:96:CF:C7:BF:65:FE:BD:27:5C:39:44:D0:04:CC
            X509v3 Authority Key Identifier: 
                keyid:0F:D9:11:F9:9F:B8:72:B3:25:01:F2:3E:0A:D0:0E:7F:65:D2:91:0A

        X509v3 Subject Alternative Name: 
            DNS:cent7ax, DNS:cent7bx, DNS:cent7cx, DNS:extra-cent7ax, DNS:extra-cent7bx, DNS:extra-cent7cx, IP Address:127.0.0.1
Signature Algorithm: sha256WithRSAEncryption
     83:ce:62:56:62:1c:71:cd:9f:83:44:76:7a:7b:44:60:c2:6c:
     78:ff:91:62:6c:8e:39:61:d4:d3:f8:74:c0:71:65:c3:80:50:
     d1:2c:f3:d6:40:bc:1f:7e:3b:f6:e0:2c:82:4f:6b:8c:09:48:
     22:d7:ea:96:ba:94:99:72:9d:ae:c2:06:15:37:7f:9b:20:02:
     a7:d7:62:eb:7d:7e:93:53:5f:21:80:f8:b6:1c:8d:40:2f:09:
     75:16:db:3f:4e:01:22:d2:7d:a7:eb:e2:49:d6:06:7b:3c:07:
     1c:90:b0:ae:bc:9d:77:8b:a2:a9:5d:57:d9:1a:e8:0a:2a:1d:
     62:86:d8:dd:b8:9f:14:a4:cd:23:36:a9:c4:c6:40:ec:1a:58:
     f5:a1:6e:d3:37:7f:68:36:90:d5:9f:17:ea:a5:4d:47:71:89:
     5a:c9:bc:48:d2:77:54:e4:9e:cd:51:af:de:f2:d9:e4:53:95:
     46:07:a7:73:6a:8b:b1:e5:51:b5:fd:82:c1:73:1e:62:b6:0d:
     8b:30:e6:12:f2:11:d7:0b:97:2c:97:c3:b9:3b:be:31:4a:a3:
     89:18:8b:ed:76:95:67:e3:b5:53:f4:33:a1:0a:aa:1e:88:37:
     f2:f4:d2:56:18:0c:79:84:dd:7a:9a:2f:99:2f:e5:fa:f6:9a:
     d5:ea:09:b8
```

- 确认 `Issuer` 字段的内容和 `ca-csr.json` 一致；
- 确认 `Subject` 字段的内容和 `etcd-csr.json` 一致；
- 确认 `X509v3 Subject Alternative Name` 字段的内容和 `etcd-csr.json` 一致；
- 确认 `X509v3 Key Usage、Extended Key Usage` 字段的内容和 `ca-config.json` 中 `etcd-op`profile 一致；

#### 2.3.2 使用cfssl-certinfo命令校验证书

执行命令：

~~~shell
cfssl-certinfo -cert etcd.pem
~~~

```undefined
[root@cent7ax cfssl_dir.bak]# cfssl-certinfo -cert etcd.pem 
{
 "subject": {
 "common_name": "etcd.freedom.com",
 "country": "CN",
 "organization": "etcd-op",
 "organizational_unit": "System",
 "locality": "BeiJing",
 "province": "BeiJing",
 "names": [
 "CN",
 "BeiJing",
 "BeiJing",
 "etcd-op",
 "System",
 "etcd.freedom.com"
 ]
 },
 "issuer": {
 "common_name": "etcd.freedom.com",
 "country": "CN",
 "organization": "etcd-op",
 "organizational_unit": "System",
 "locality": "BeiJing",
 "province": "BeiJing",
 "names": [
 "CN",
 "BeiJing",
 "BeiJing",
 "etcd-op",
 "System",
 "etcd.freedom.com"
 ]
 },
 "serial_number": "234023291199234768277633047351258036366090605927",
 "sans": [
 "cent7ax",
 "cent7bx",
 "cent7cx",
 "extra-cent7ax",
 "extra-cent7bx",
 "extra-cent7cx",
 "127.0.0.1"
 ],
 "not_before": "2020-11-25T01:47:00Z",
 "not_after": "2040-11-20T01:47:00Z",
 "sigalg": "SHA256WithRSA",
 "authority_key_id": "F:D9:11:F9:9F:B8:72:B3:25:1:F2:3E:A:D0:E:7F:65:D2:91:A",
 "subject_key_id": "F0:73:FD:7B:11:AF:96:CF:C7:BF:65:FE:BD:27:5C:39:44:D0:4:CC",
 "pem": "-----BEGIN CERTIFICATE-----nMIIERjCCAy6gAwIBAgIUKP33oenyAwtRFhg3j2RGqbZylWcwDQYJKoZIhvcNAQELnBQAwbzELMAkGA1UEBhMCQ04xEDAOBgNVBAgTB0JlaUppbmcxEDAOBgNVBAcTB0JlnaUppbmcxEDAOBgNVBAoTB2V0Y2Qtb3AxDzANBgNVBAsTBlN5c3RlbTEZMBcGA1UEnAxMQZXRjZC5mcmVlZG9tLmNvbTAeFw0yMDExMjUwMTQ3MDBaFw00MDExMjAwMTQ3nMDBaMG8xCzAJBgNVBAYTAkNOMRAwDgYDVQQIEwdCZWlKaW5nMRAwDgYDVQQHEwdCnZWlKaW5nMRAwDgYDVQQKEwdldGNkLW9wMQ8wDQYDVQQLEwZTeXN0ZW0xGTAXBgNVnBAMTEGV0Y2QuZnJlZWRvbS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKnAoIBAQDKT6IJnxJ8gagJTW/DlsBp2vydEDNMKla6BiA+L1IvFTahEYn3mFa2jziFnggIsrKixnnFt/uUGH6d6Ppy+4p11PmkbngbrABt0YMNszPj0ySwS0aoqcj9b4NBFnV/CtiG6gWcTkXVPLb+yO/jMyn5mt5jvKrX1LGYzrfZKOjgmLp0kqHnM16+NZT4e+njRLLI0H1NL8aTQTAfHCZj85Ryhx8mUUOsdeRY1hMo3NVy9GO697NW4k1ME1FCMYJn3uKw3laqE6w5y+UtBgYkY/rryCDguLtVv9GDSprcLFZsFnvjBlNV2NNX44IJP4uRnG7ho0Q+PmE4H/JRlaW+9Wac4CHknAgMBAAGjgdkwgdYwDgYDVR0PAQH/BAQDAgWgnMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMB0GnA1UdDgQWBBTwc/17Ea+Wz8e/Zf69J1w5RNAEzDAfBgNVHSMEGDAWgBQP2RH5n7hynsyUB8j4K0A5/ZdKRCjBXBgNVHREEUDBOggdjZW50N2F4ggdjZW50N2J4ggdjZW50nN2N4gg1leHRyYS1jZW50N2F4gg1leHRyYS1jZW50N2J4gg1leHRyYS1jZW50N2N4nhwR/AAABMA0GCSqGSIb3DQEBCwUAA4IBAQCDzmJWYhxxzZ+DRHZ6e0Rgwmx4/5FinbI45YdTT+HTAcWXDgFDRLPPWQLwffjv24CyCT2uMCUgi1+qWupSZcp2uwgYVN3+bnIAKn12LrfX6TU18hgPi2HI1ALwl1Fts/TgEi0n2n6+JJ1gZ7PAcckLCuvJ13i6KpnXVfZGugKKh1ihtjduJ8UpM0jNqnExkDsGlj1oW7TN39oNpDVnxfqpU1HcYlaybxIn0ndU5J7NUa/e8tnkU5VGB6dzaoux5VG1/YLBcx5itg2LMOYS8hHXC5csl8O5O74xnSqOJGIvtdpVn47VT9DOhCqoeiDfy9NJWGAx5hN16mi+ZL+X69prV6gm4n-----END CERTIFICATE-----n"
}
```

### 2.4 分发证书

最后将上面签名生成的证书文件etcd.pem及其私钥文件etcd-key.pem 拷贝到集群所有需要的地方，即分发证书。典型使用场景有：

- etcd-server集群的安装部署
- grpc servers集群的安装部署
- kubernetes集群的安装部署

等场景都需要使用证书认证。



# 安全

## 机制说明

Kubernetes 作为一个分布式集群的管理工具，保证集群的安全性是其一个重要的任务。API Server 是集群内部
各个组件通信的中介，也是外部控制的入口。所以 Kubernetes 的安全机制基本就是围绕保护 API Server 来设计的。

Kubernetes 使用了**认证**（Authentication）、**鉴权**（Authorization）、**准入控制**（Admission
Control）三步来保证API Server的安全

<img src="img/k8s笔记/image-20231019181146751.png" alt="image-20231019181146751" style="zoom:67%;" />

不管是我们自己调用k8s-api-server, 还是pod调用k8s-api-server, 在api-server内部都要执行认证, 授权, 准入控制三个大模块, 然后才能够间接的访问到etcd中的资源信息



## 认证

### 认证的方式

认证的主要作用就是, 当我们的程序, 或者pod在调用api-server的时候, 进行一个身份的识别, 在api-server中, 有三种认证的方式

1. HTTP Token 认证: 通过一个 Token 来识别合法用户

   HTTP Token 的认证是用一个很长的特殊编码方式的并且难以被模仿的字符串Token 来表达客户的一种方式。Token 是一个很长的很复杂的字符串，每一个 Token 对应一个用户名存储在 API Server 能访问的文件中。当客户端发起 API 调用请求时，需要在 HTTP Header 里放入 Token, 类似如下

   ~~~shell
   # 在pod内部, 通过curl访问api-server, 获取指定namespae下的指定的configmap
   curl -k \
   -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   https://kubernetes.default:443/api/v1/namespaces/${namespace_name}/configmaps/${configmap_name}
   ~~~

   api-server在接受到请求之后, 如果这个token能够匹配到对应的用户的话, 那么就会对这个用户的权限进行校验, 看能不能访问对应的资源

2. HTTP Base 认证: 通过 **用户名+密码** 的方式认证

   这种方式要求在访问api-server的时候, 需要在http的header上添加上`Authorization: base64(username:password)`, 比如如下的方式

   ~~~shell
   # 用户名: admin  , 密码: 123456
   
   curl -k \
   -H "Authorization: Basic $(echo -n 'admin:123456' | base64)" \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   https://kubernetes.default:443/api/v1/namespaces/${namespace_name}/configmaps/${configmap_name}
   ~~~

   > 非常不推荐这种方式, 因为
   >
   > 1. k8s默认情况下, 不开启http base的权限认证方式
   > 2. Kubernetes 从 **v1.19 以后就完全废弃了 static password 文件**方式。

3. 最严格的 HTTPS 证书认证: `基于 CA 根证书签名的客户端身份认证方式, 这是最常用的方式`

   在整个k8s的集群中, 我们会签署一个ca根证书,  所有的其他子证书都是基于这个根证书

   并且还是一个https的双向认证, 过程如下

   ![image-20250712153244160](img/k8s笔记/image-20250712153244160.png)

   首先客户端和服务器都需要向我们私有的ca机构申请证书, 然后客户端和服务器通讯的时候, 客户端会发送证书到服务器端, 服务器端也会返回自己的证书, 两者的证书都通过之后, 再通过随机的秘钥进行加密通讯

### 不同组件的认证方式

![image-20250712153606820](img/k8s笔记/image-20250712153606820.png)

1. 在k8s中, kubectl, controller manager, scheduler, kubelet, kube proxy这些组件都需要访问api-server, 所以这些组件都要进行认证

   1. 因为Controller Manager, Scheduler, API Server都在同一台机器, 所以使用https双向加密实在是没有必要, 他们可以通过api server的非安全端口`127.0.0.1`进行访问api server

      当然也可以关闭API Server在本机上的非安全端口, 这样通过`127.0.0.1`就没有办法api server了, 这样就必须使用https进行访问 

   2. kubectl, kubelet, kube-proxy访问api server  必须使用https`双向认证`, 因为这些组件和api-server不在同一个节点

2. 同时在k8s中, 也有一些pod需要访问api-server, 比如kubernetes-dashboard, 所以这些pod也需要进行认证

   pod或者pod中的进程访问api server是通过Secret中的Service Account来进行认证的, 因为pod的创建和销毁是动态的, 我们有可能会创建成千上百个pod, 如果使用https双向认证的方式的话, 那么就要创建出成千上百个整数, 并且这些pod是随时销毁的, 在pod销毁之后, 这些ca证书就相当于废弃了, 这个过程是非常消耗资源的, 所以pod或者pod中的容器在调用api server的时候, 都是使用`service account+http token`的方式来进行认证的

   默认在容器的 `/run/secrets/kubernetes.io/serviceaccount/`下面, 有三个文件:

   1. token:  通过api server私钥签名的jwt, 用于容器范围api server时进行认证
   2. ca.crt: 跟证书, 用于容器验证 api server发送过来的token确实是api server签名的
   3. namespace: 表示这个token的作用域空间



## 鉴权

上面认证过程，只是确认通信的双方都确认了对方是可信的，可以相互通信。

而鉴权是确定请求方有哪些资源的权限。API Server 目前支持以下几种授权策略 (通过 API Server 的启动参数“-authorization-mode”设置)

- AlwaysDeny: 表示拒绝所有的请求，一般用于测试
- AIwaysAllow: 允许接收所有请求，如果集群不需要授权流程，则可以采用该策略
- ABAC (Attribute-Based Access Control) : 基于属性的访问控制，表示使用用户配置的授权规则对用户请求进行匹配和控制, 修改完配置之后需要重启k8s才能生效
- Webbook: 通过调用外部 REST 服务对用户进行授权
- RBAC (Role-Based Access Control) : 基于角色的访问控制，**现行默认规则**

### RBAC授权模式

https://kubernetes.io/zh-cn/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings

RBAC（Role-Based Access Control）基于角色的访问控制，在 Kubernetes 1.5 中引入，现行版本成为默认标
准, 相对其它访问控制方式，拥有以下优势：

1. 对集群中的资源(deployment, service, configmap等等)和非资源(cpu信息, 内存信息, 硬件信息等等)均拥有完整的覆盖
2. 整个 RBAC 完全由几个 API 对象完成，同其它 API 对象一样，可以用 kubectl 或 API 进行操作
3. 可以在运行时进行调整，**无需重启** API Server



在RBAC模型中, 有**角色, 用户, 资源, 操作, 绑定**五个类型

用户/组/ServiceAccount通过绑定(RoleBinding)来绑定到对应的角色(Role)上, 然后每个角色(Role)都有操作(create/get/update/delete)对应资源(Controller, Service...)的权限

![image-20250712162259863](img/k8s笔记/image-20250712162259863.png)

#### 用户

在kubenetes中, 用户分为三类

1. User: 单个用户, 类似Linux中的User
2. Gorup: 多个用户的集合, 类似Linux中的Group
3. ServiceAccount: 用于容器和api server进行认证

**需要说明的是kubernetes并没有提供User和Group的创建和删除功能, 而是kubernetes组件(kubectl, kube-proxy)或者是其他自定义用户在向ca申请证书时, 从csr文件中提取的**

**api server会把客户端的证书申请文件(csr文件)中的`CN`字段作为User, 把`names.O`字段作为Group**

~~~json
{
  "CN": "admin", // User
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "HangZhou",
      "L": "XS",
      "O": "system:masters", // Group
      "OU": "System"
    }
  ]
}
~~~

而对于Pod使用 ServiceAccount , 我们可以通过kubectl命令, 或者yaml文件来创建, 详细的创建可以查看ServiceAccount部分





#### 资源

在k8s中, 你可以通过如下命令来查看所有资源, 以及调用他们的url地址的说明

~~~shell
kubectl api-resources --verbs=list -o wide
~~~

下面只是列举了部分资源, 已经部分操作他们的api, 并不是全部

1. Pods（Pod资源）：`pods`

   ~~~shell
   /api/v1/namespaces/{namespace}/pods
   ~~~

2. Services（Service资源）：`services`

   ~~~shell
   /api/v1/namespaces/{namespace}/services
   ~~~

3. ReplicationControllers（ReplicationController资源）：`replicationcontrollers`

4. ReplicaSets

   ~~~shell
   /apis/apps/v1/namespaces/{namespace}/replicasets
   ~~~

5. Deployments（Deployment资源）：`deployments`

   ~~~shell
   /apis/apps/v1/namespaces/{namespace}/deployments
   ~~~

6. DaemonSets

   ~~~shell
   /apis/apps/v1/namespaces/{namespace}/daemonsets
   ~~~

7. StatefulSets（StatefulSet资源）：`statefulsets`

   ~~~shell
   /apis/apps/v1/namespaces/{namespace}/statefulsets
   ~~~

8. Job

   ~~~shell
   /apis/batch/v1/namespaces/{namespace}/jobs
   ~~~

9. CronJobs

   ~~~shell
   /apis/batch/v1/namespaces/{namespace}/cronjobs
   ~~~

10. ConfigMaps（ConfigMap资源）：`configmaps`

    ```shell
    /api/v1/namespaces/{namespace}/configmaps
    ```

11. Secrets（Secret资源）：`secrets`

    ~~~shell
    /api/v1/namespaces/{namespace}/secrets
    ~~~

12. PersistentVolumes（PersistentVolume资源）：`persistentvolumes`

13. Namespaces（Namespace资源）：`namespaces`

    ~~~shell
    /api/v1/namespaces
    ~~~

14. Nodes（Node资源）：`nodes`

    ~~~shell
    /api/v1/nodes
    ~~~

15. Events（Event资源）：`events`

16. ServiceAccounts（ServiceAccount资源）：`serviceaccounts`

17. Ingresses（Ingress资源）：`ingresses`

    ~~~shell
    /apis/networking.k8s.io/v1/namespaces/{namespace}/ingresses
    ~~~

18. HorizontalPodAutoscalers（HorizontalPodAutoscaler资源）：`horizontalpodautoscalers`

19. LimitRanges（LimitRange资源）：`limitranges`

20. ResourceQuotas（ResourceQuota资源）：`resourcequotas`

21. NetworkPolicies（NetworkPolicy资源）：`networkpolicies`

    ~~~shell
    /apis/networking.k8s.io/v1/namespaces/{namespace}/networkpolicies
    ~~~

22. CustomResourceDefinitions（CustomResourceDefinition资源）：`customresourcedefinitions`

23. Roles（Role资源）：`roles`

    ~~~shell
    /apis/rbac.authorization.k8s.io/v1/namespaces/{namespace}/roles
    ~~~

24. RoleBindings（RoleBinding资源）：`rolebindings`

    ~~~shell
    /apis/rbac.authorization.k8s.io/v1/namespaces/{namespace}/rolebindings
    ~~~

25. ClusterRoles（ClusterRole资源）：`clusterroles`

    ~~~shell
    /apis/rbac.authorization.k8s.io/v1/clusterroles
    ~~~

26. ClusterRoleBindings（ClusterRoleBinding资源）：`clusterrolebindings`

    ~~~shell
    /apis/rbac.authorization.k8s.io/v1/clusterrolebindings
    ~~~

    



#### 操作

以下是一些常见的操作（verbs）：

1. `get`：允许获取资源的信息。
2. `list`：允许列出资源的信息。
3. `create`：允许创建新资源。
4. `delete`：允许删除资源。
5. `update`：允许更新或修改资源。
6. `patch`：允许对资源进行局部修改。
7. `watch`：允许监视资源的变化。
8. `exec`：允许通过执行命令进入 Pod 内部。
9. `port-forward`：允许进行端口转发，用于远程访问 Pod。
10. `proxy`：允许代理到资源。
11. `connect`：允许通过 WebSocket 连接到 Pod。

这些是一些常见的操作，但还有其他更精细的操作，例如：`deletecollection`（允许删除一组资源）、`bind`（允许将 Pod 绑定到 Node）、`scale`（允许修改 Deployment 或 ReplicationController 的副本数）等



#### 角色

在k8s中, 角色是一组规则权限, 权限只会**累加**, 不存在一个资源一开始就用很多权限, 然后通过RBAC对其进行减少的操作



在k8s中, 角色分为两类, `Role`和`ClusterRole`

- `Role`只能都对某一个namesapce中的资源进行操作
- `ClusterRole`能够对整个集群中的资源都进行操作, 比如
  1. 集群级别的资源控制 (列如node访问权限)
  2. 非资源型的信息的控制 (例如集群的健康信息, cpu和内存信息)
  3. 所有命名空间的资源控制 (例如Controller, Service, Pod)

创建Role的案例

~~~yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default # 角色所属的namespace
  name: pod-reader # 角色名
rules:
  # apiGroups是一个列表, 用于指定下面的规则用于哪些apiGroup
  # ""表示Core API Group, 即 Kubernetes 最基本的内置资源组。用于操作Pods/Service/ConfigMap等等资源
  # apps: 用于操作Deployments
  # networking.k8s.io: 用于操作ingress
  # rbac.authorization.k8s.io: 用于操作Roles, RoleBindings
  # 如果你不知道应该设置成什么, 那么就设置为""就好了, 有问题再说
- apiGroups: [""] 
  resources: ["pods"] # 角色能够控制的资源, default命名空间下的所有pod
  verbs: ["get", "watch", "list"] # 能够对资源进行的操作
~~~

创建ClusterRole的案例

~~~yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" 被忽略，因为 ClusterRoles 不受名字空间限制
  name: secret-reader
rules:
- apiGroups: [""]
  # 能够对所有命名空间中的service account进行get, watch, list
  resources: ["secrets"] 
  verbs: ["get", "watch", "list"]
~~~

同时可以将操作的资源限制为资源的单个实例

~~~yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: configmap-updater
rules:
- apiGroups: [""]
  # 这个角色只能对default命名空间下的my-configmap这个configmap进行update, get的操作
  resources: ["configmaps"]
  resourceNames: ["my-configmap"]
  verbs: ["update", "get"]
~~~

同时还可以使用`*`来表示任何资源和任何操作

~~~shell
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: example.com-superuser
rules:
- apiGroups: ["example.com"]
  resources: ["*"] # 任何资源
  verbs: ["*"] # 任何操作
~~~

如果你想要控制资源下面的子资源, 那么可以通过`/`来实现

~~~yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: pod-and-pod-logs-reader
rules:
- apiGroups: [""]
  resources: ["pods","pods/log"] # pods/log表示可以访问pod的日志
  verbs: ["get""list"]
~~~



同时, 还可以将多个ClusterRole聚合在一起, 组合成一个新的ClusterRole, 他们的权限将会被叠加在一起

~~~shell
# 创建一个带label的角色monitoring-endpoints
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-endpoints
  labels:
    # 定义ClusterRole带有的标签
    rbac.example.com/aggregate-to-monitoring: "true"
rules:
- apiGroups: [""]
  resources: ["services", "endpointslices", "pods"]
  verbs: ["get", "list", "watch"]
---
# 创建一个聚合的ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring # 聚合ClusterRole的名称
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      # 通过label选择器, 将所有带有此标签的ClusterRole聚合到这个角色下面, 所以上面的monitoring-endpoints中的权限会聚合带这里
      # 即使在创建这个聚合ClusterRole后新建带有此标签的角色, 也会动态的将他的权限聚合带这个角色下面
      rbac.example.com/aggregate-to-monitoring: "true" 
rules: [] # 控制面自动填充这里的规则
~~~



##### 相关shell

Role和ClusterRole的相关shell

~~~shell
kubectl get role -A # 查看所有命名空间的role
kubectl get role -n <namespace_name> # 查看指定命名空间中的role
kubectl get role -n <namespae_name> <rolename> -o yaml # 以json的形式查看指定的role

# 查看role的详细情况
kubectl describe role -n <namespae_name> <rolename> 

# 如果要查看clusterRole, 将命令中的role替换为clusterrole即可
~~~

~~~shell
[root@uc24020 record]# kubectl describe role -n service-software kong
Name:         kong
Labels:       app=kong
              app.kubernetes.io/managed-by=Helm
Annotations:  meta.helm.sh/release-name: kong
              meta.helm.sh/release-namespace: service-software
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  secrets    []                 []              [get]
~~~

从上面的信息可以看出, 这个Role被赋予了一条权限, 允许获取(Get)当前命名空间中的所有Secrets, 但是不能list,create,update,delete, 也不能访问其他操作



#### 绑定

在k8s中, 有两种绑定关系, `RoleBinding` 和 `ClusterRoleBinding`

`RoleBinding` 和 `ClusterRoleBinding`  与  `Role`和`ClusterRole`的使用方式一共有三种:

1. 使用`RoleBinding`将用户和`Role`绑定, 使得用户具有某个namespace中的权限

   ~~~yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding # 绑定的类型
   metadata:
     name: read-pods #  RoleBinding的名字
     namespace: default # 这里必须和Role的命名空间相同
   subjects:
   # 需要绑定的用户, 可以有多个
   - kind: User # 用户类型, User, Group, ServiceAccount
     name: jane # 用户名字
     # 使用的apiGroup
     # 如果kind为User, 那么指定为rbac.authorization.k8s.io
     # 如果kind类型为ServiceAccount, 那么指定为""
     apiGroup: rbac.authorization.k8s.io 
     # 如果kind为ServiceAccount, 必须指定sa的命名空间
     # 其他类型的kind可以省略这个字段
     namespace: xx 
   roleRef:
     kind: Role        # 需要绑定的角色的类型: Role, ClusterRole
     name: pod-reader  # 角色的名称
     apiGroup: rbac.authorization.k8s.io # 这里固定就是rbac.authorization.k8s.io
   ~~~

   通过上面的yaml,  jane就具有了pod-reader的权限, 并且权限现在在了`default` namespace下

2. 使用`RoleBinding`将用户和`ClusterRole`绑定, 虽然`ClusterRole`具有管理整个集群的权限, 但是因为是通过`RoleBinding`进行绑定的, 所以权限也会被限制在某个namesapce下

   这种情况通常是使用在: 创建具有通用权限的, 能够操作整个集群的`ClusterRole`, 然后将他的权限通过`RoleBinding`限制在某个namespace下

   ~~~yaml
   apiVersion: rbac.authorization.k8s.io/v1
   
   kind: RoleBinding # 绑定类型
   metadata:
     name: read-secrets
     namespace: development # 将ClusterRole的权限限制在哪个命名空间下
   subjects:
   # 绑定的用户
   - kind: User #[User | ServiceAccount | Group]
     name: dave 
     # 使用的apiGroup
     # 如果kind为User, 那么指定为rbac.authorization.k8s.io
     # 如果kind类型为ServiceAccount, 那么指定为""
     apiGroup: rbac.authorization.k8s.io 
     # 如果kind为ServiceAccount, 必须指定sa的命名空间
     # 其他类型的kind可以省略这个字段
     namespace: xx
   # 绑定的角色
   roleRef:
     kind: ClusterRole
     name: secret-reader
     apiGroup: rbac.authorization.k8s.io # 这里固定就是rbac.authorization.k8s.io
   ~~~

   这样dave就拥有了secret-reader的权限, 并且权限限制在了development namespace下

3. 使用`ClusterRoleBinding`将`ClusterRole`和用户进行绑定, 使得用户具有管理整个集群的能力

   ~~~yaml
   # manager组中的所有人都拥有secret-reader的权限, 并且是在任何namespace下
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: read-secrets-global
   subjects:
   - kind: Group
     name: manager 
     # 使用的apiGroup
     # 如果kind为User, 那么指定为rbac.authorization.k8s.io
     # 如果kind类型为ServiceAccount, 那么指定为""
     apiGroup: rbac.authorization.k8s.io 
     # 如果kind为ServiceAccount, 必须指定sa的命名空间
     # 其他类型的kind可以省略这个字段
     namespace: xx
   roleRef:
     kind: ClusterRole
     name: secret-reader
     apiGroup: rbac.authorization.k8s.io
   ~~~



##### 相关shell

~~~shell
kubectl get rolebinding  -A # 查看所有命名空间的rolebinding
kubectl get rolebinding -n <namespace_name> # 查看指定命名空间中的rolebinding
kubectl get rolebinding  -n <namespae_name> <rolename> -o yaml # 以json的形式查看指定的rolebinding

# 查看rolebinding的详细情况
kubectl describe role -n <namespae_name> <rolename> 

# 如果要查看clusterRole, 将命令中的role替换为clusterrole即可
~~~



~~~shell
[root@uc24020 record]# kubectl describe rolebinding -n service-software kong
Name:         kong
Labels:       app=kong
              app.kubernetes.io/managed-by=Helm
Annotations:  meta.helm.sh/release-name: kong
              meta.helm.sh/release-namespace: service-software
# 下面是绑定的角色
Role:
  Kind:  Role 
  Name:  kong
# 下面是绑定的账户, 可以有多个
Subjects:
  Kind            Name  Namespace
  ----            ----  ---------
  ServiceAccount  kong  service-software
~~~

从上面的信息中可以看到, 通过kong这个rolebinding, 将kong这个Role绑定到了kong这个ServiceAccount上面, 并且权限限制在service-software的namespace中











#### 内置的ClusterRole

内置的ClusterRole一般分为两类: 面向系统的角色, 面向用户的角色

面向系统的角色一般以`system:`为前缀, 比如如下:

| 默认 ClusterRole              | 默认 ClusterRoleBinding                                   | 描述                                                         |
| ----------------------------- | --------------------------------------------------------- | ------------------------------------------------------------ |
| **system:basic-user**         | **system:authenticated** 组                               | 允许用户以只读的方式去访问他们自己的基本信息。在 v1.14 版本之前，这个角色在默认情况下也绑定在 `system:unauthenticated` 上。 |
| **system:discovery**          | **system:authenticated** 组                               | 允许以只读方式访问 API 发现端点，这些端点用来发现和协商 API 级别。 在 v1.14 版本之前，这个角色在默认情况下绑定在 `system:unauthenticated` 上。 |
| **system:public-info-viewer** | **system:authenticated** 和 **system:unauthenticated** 组 | 允许对集群的非敏感信息进行只读访问，此角色是在 v1.14 版本中引入的。 |



面向用户的角色通常不会以 `system:` 开头，主要包括以下几类：

- **`cluster-admin`**：集群级超级管理员，拥有所有权限，通常通过 **ClusterRoleBinding** 进行绑定。
- **`cluster-status`**：建议也通过 **ClusterRoleBinding** 授权，通常用于集群状态查看。
- **`admin`、`edit`、`view`**：这三类角色推荐通过 **RoleBinding** 在指定的命名空间中授权给用户。

其中 `admin`、`edit` 和 `view` 是**聚合 ClusterRole**，它们的权限可以通过标签机制动态扩展。其聚合标签如下：

```yaml
metadata:
  labels:
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
```

因此，只要创建具有这些标签的 ClusterRole，就可以将其权限自动合并到对应的聚合角色中，从而扩展 `admin`、`edit`、或 `view` 的权限范围。



下面是这个角色的具体描述:

| 默认 ClusterRole  | 默认 ClusterRoleBinding | 描述                                                         |
| ----------------- | ----------------------- | ------------------------------------------------------------ |
| **cluster-admin** | **system:masters** 组   | 允许超级用户在平台上的任何资源上执行所有操作。 当在 **ClusterRoleBinding** 中使用时，可以授权对集群中以及所有名字空间中的全部资源进行完全控制。 当在 **RoleBinding** 中使用时，可以授权控制角色绑定所在名字空间中的所有资源，包括名字空间本身。 |
| **admin**         | 无                      | 允许管理员访问权限，旨在使用 **RoleBinding** 在名字空间内执行授权。如果在 **RoleBinding** 中使用，则可授予对名字空间中的大多数资源的读/写权限， 包括创建角色和角色绑定的能力。 此角色不允许对资源配额或者名字空间本身进行写操作。 此角色也不允许对 Kubernetes v1.22+ 创建的 EndpointSlices（或 Endpoints）进行写操作。 更多信息参阅 [“EndpointSlices 和 Endpoints 写权限”小节](https://kubernetes.io/zh-cn/docs/reference/access-authn-authz/rbac/#write-access-for-endpoints)。 |
| **edit**          | 无                      | 允许对名字空间的大多数对象进行读/写操作。此角色不允许查看或者修改角色或者角色绑定。 不过，此角色可以访问 Secret，以名字空间中任何 ServiceAccount 的身份运行 Pod， 所以可以用来了解名字空间内所有服务账户的 API 访问级别。 此角色也不允许对 Kubernetes v1.22+ 创建的 EndpointSlices（或 Endpoints）进行写操作。 更多信息参阅 [“EndpointSlices 和 Endpoints 写操作”小节](https://kubernetes.io/zh-cn/docs/reference/access-authn-authz/rbac/#write-access-for-endpoints)。 |
| **view**          | 无                      | 允许对名字空间的大多数对象有只读权限。 它不允许查看角色或角色绑定。此角色不允许查看 Secret，因为读取 Secret 的内容意味着可以访问名字空间中 ServiceAccount 的凭据信息，进而允许利用名字空间中任何 ServiceAccount 的身份访问 API（这是一种特权提升）。 |





#### 实践：创建一个devuser用户, 只能管理 dev 空间

1. 创建dev命名空间

   ~~~shell
   kubectl create ns dev
   ~~~

2. 创建一个devuser用户, 并设置密码

   ~~~shell
   useradd devuser
   passwd
   ~~~

3. 重新通过devuser用户来登录linux

   ~~~shell
   ssh devuser@192.168.1.100
   ~~~

4. 这个时候我们通过`kubectl`命令来访问k8s, 肯定是会被拒绝访问的, 因为还没有为这个用户创建证书

   ```shell
   kubect get pod
   The connection to the server localhost:8080 was refused - did you specify the right host or port?
   ```

5. 为devuser这个用户创建相应的k8s证书, 使得这个用户可以通过kubectl来访问k8s集群

   ~~~shell
   cd /usr/local/install-k8s/ # 随便cd到一个目录下
   mkdir -p cert/devuser
   cd cert/devuser
   touch devuser-csr.json # 这个文件可以随便命名
   
   cat <<EOF > devuser-csr.json
   {
     "CN": "devuser", // 这里是k8s用户的名字
     "hosts": [], // 可以使用证书的主机, 不写的话是所有
     "key": {
       "algo": "rsa",
       "size": 2048
     },
     "names": [
       {
         "C": "CN",
         "ST": "BeiJing",
         "L": "BeiJing",
         "O": "k8s", // 这是k8s的用户的组名
         "OU": "System"
       }
     ]
   }
   EOF
   ~~~

6. 下载证书生成工具

   ~~~shell
   wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
   mv cfssl_linux-amd64 /usr/local/bin/cfssl
   
   wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
   mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
   
   wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
   mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
   ~~~

7. 通过证书生成工具生成证书

   ~~~shell
   # 这个目录下都是k8s的秘钥信息
   cd /etc/kubernetes/pki 
   
   # -ca表示指定生成的ca证书
   # -ca-key表示生成的私钥
   # ./devuser-csr.json表示根据整个文件来生成证书
   cfssl gencert -ca=ca.crt -ca-key=ca.key -profile=kubernetes /usr/local/install-k8s/cert/devuser/devuser-csr.json | cfssljson -bare devuser
   
   ls
   devuser.csr  devuser.pem  devuser-key.pem
   ~~~

8. 创建一个新的kubeconfig上下文文件, 并在其中添加一个名为`kubernetes`的k8s集群信息

   ~~~shell
   cd /usr/local/install-k8s/cert/devuser/
   
   export KUBE_APISERVER="https://172.20.0.113:6443" # 通过环境变量指定api-server的地址
   
   kubectl config \
   set-cluster kubernetes \ # 指定集群的名字
   --certificate-authority=/etc/kubernetes/pki/ca.crt \ #指定ca证书
   --embed-certs=true \ # 指定是否要加密认证
   --server=${KUBE_APISERVER} \ # 指定api-server的地址
   --kubeconfig=devuser.kubeconfig # 创建出来的集群的信息文件
   
   ls
   devuser.kubeconfig # 这个就是创建出来的集群的文件
   ~~~

9. 将名为 `devuser` 的用户凭据（使用客户端证书）配置到 `devuser.kubeconfig` 文件中，用于在 kubeconfig 中定义一个基于证书认证的 Kubernetes 用户

   ~~~shell
   cd /usr/local/install-k8s/cert/devuser/
   
   kubectl config set-credentials devuser \
   --client-certificate=/etc/kubernetes/pki/devuser.pem \ # 客户端证书（用户身份）
   --client-key=/etc/kubernetes/pki/devuser-key.pem \ # 客户端私钥（用于身份验证）
   --embed-certs=true \ # 将证书内容直接嵌入 kubeconfig 中，而不是引用外部路径
   --kubeconfig=devuser.kubeconfig # 写入的 kubeconfig 文件
   ~~~

10. 创建一个新的kubeconfig上下文, 并保存到`devuser.kubeconfig`文件中

    ~~~shell
    kubectl config set-context kubernetes \ # 设置一个新的 context（上下文环境）名称为 kubernetes
    --cluster=kubernetes \ # 指定关联的集群名字，必须之前通过 set-cluster 配置过
    --user=devuser \ # 指定用于访问该集群的用户身份，必须之前通过 set-credentials 配置过
    --namespace=dev \ # 设置默认命名空间为 dev，后续 kubectl 命令默认作用于此命名空间
    --kubeconfig=devuser.kubeconfig # 将 context 写入到指定 kubeconfig 文件，而不是默认的 ~/.kube/config
    ~~~

11. 将`devuser`绑定到admin角色上, 并设置限制的命名空间为dev

    admin这个角色拥有所有命名空间的所有权限

    ~~~shell
    kubectl create rolebinding devuser-admin-binding \ # 指定创建一个名为devuser-admin-binding的rolebinding
    --clusterrole=admin \ # 指定绑定的角色
    --user=devuser \ # 指定绑定的用户
    --namespace=dev # 指定限制的命名空间
    ~~~

12. 将kubeconfig文件拷贝到devuser的家目录下

    ~~~shell
    mkdir -p /home/devuser/.kube
    cp devuser.kubeconfig /home/devuser/.kube/config # 将devuser.kubeconfig拷贝到.kube目录下, 并重命名为config
    chown devuser:devuser /home/devuser/.kube/config
    ~~~

13. 切换当前 kubeconfig 文件中的上下文（context）为 `kubernetes`，之后使用`kubectl`命令的时候, 都会使用这个配置文件中的信息

    ~~~shell
    kubectl config use-context kubernetes --kubeconfig=/home/devuser/.kube/config
    ~~~

    



#### 相关的命令行

> `kubectl create role`

创建 Role 对象，定义在某一名字空间中的权限。例如:

- 创建名称为 “pod-reader” 的 Role 对象，允许用户对 Pods 执行 `get`、`watch` 和 `list` 操作：

  ```shell
  kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods
  ```

- 创建名称为 “pod-reader” 的 Role 对象并指定 `resourceNames`：

  ```shell
  kubectl create role pod-reader --verb=get --resource=pods --resource-name=readablepod --resource-name=anotherpod
  ```

- 创建名为 “foo” 的 Role 对象并指定 `apiGroups`：

  ```shell
  kubectl create role foo --verb=get,list,watch --resource=replicasets.apps
  ```

- 创建名为 “foo” 的 Role 对象并指定子资源权限:

  ```shell
  kubectl create role foo --verb=get,list,watch --resource=pods,pods/status
  ```

- 创建名为 “my-component-lease-holder” 的 Role 对象，使其具有对特定名称的资源执行 get/update 的权限：

  ```shell
  kubectl create role my-component-lease-holder --verb=get,list,watch,update --resource=lease --resource-name=my-component
  ```

>  `kubectl create clusterrole`

创建 ClusterRole 对象。例如：

- 创建名称为 “pod-reader” 的 ClusterRole 对象，允许用户对 Pods 对象执行 `get`、 `watch` 和 `list` 操作：

  ```shell
  kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods
  ```

- 创建名为 “pod-reader” 的 ClusterRole 对象并指定 `resourceNames`：

  ```shell
  kubectl create clusterrole pod-reader --verb=get --resource=pods --resource-name=readablepod --resource-name=anotherpod
  ```

- 创建名为 “foo” 的 ClusterRole 对象并指定 `apiGroups`：

  ```shell
  kubectl create clusterrole foo --verb=get,list,watch --resource=replicasets.apps
  ```

- 创建名为 “foo” 的 ClusterRole 对象并指定子资源:

  ```shell
  kubectl create clusterrole foo --verb=get,list,watch --resource=pods,pods/status
  ```

- 创建名为 “foo” 的 ClusterRole 对象并指定 `nonResourceURL`：

  ```shell
  kubectl create clusterrole "foo" --verb=get --non-resource-url=/logs/*
  ```

- 创建名为 “monitoring” 的 ClusterRole 对象并指定 `aggregationRule`：

  ```shell
  kubectl create clusterrole monitoring --aggregation-rule="rbac.example.com/aggregate-to-monitoring=true"
  ```

>  `kubectl create rolebinding`

在特定的名字空间中对 `Role` 或 `ClusterRole` 授权。例如：

- 在名字空间 “acme” 中，将名为 `admin` 的 ClusterRole 中的权限授予名称 “bob” 的用户:

  ```shell
  kubectl create rolebinding bob-admin-binding --clusterrole=admin --user=bob --namespace=acme
  ```

- 在名字空间 “acme” 中，将名为 `view` 的 ClusterRole 中的权限授予名字空间 “acme” 中名为 `myapp` 的服务账户：

  ```shell
  kubectl create rolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp --namespace=acme
  ```

- 在名字空间 “acme” 中，将名为 `view` 的 ClusterRole 对象中的权限授予名字空间 “myappnamespace” 中名称为 `myapp` 的服务账户：

  ```shell
  kubectl create rolebinding myappnamespace-myapp-view-binding --clusterrole=view --serviceaccount=myappnamespace:myapp --namespace=acme
  ```

>  `kubectl create clusterrolebinding`

在整个集群（所有名字空间）中用 ClusterRole 授权。例如：

- 在整个集群范围，将名为 `cluster-admin` 的 ClusterRole 中定义的权限授予名为 “root” 用户：

  ```shell
  kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=cluster-admin --user=root
  ```

- 在整个集群范围内，将名为 `system:node-proxier` 的 ClusterRole 的权限授予名为 “system:kube-proxy” 的用户：

  ```shell
  kubectl create clusterrolebinding kube-proxy-binding --clusterrole=system:node-proxier --user=system:kube-proxy
  ```

- 在整个集群范围内，将名为 `view` 的 ClusterRole 中定义的权限授予 “acme” 名字空间中名为 “myapp” 的服务账户：

  ```shell
  kubectl create clusterrolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp
  ```

>  `kubectl auth reconcile`

使用清单文件来创建或者更新 `rbac.authorization.k8s.io/v1` API 对象。

尚不存在的对象会被创建，如果对应的名字空间也不存在，必要的话也会被创建。 已经存在的角色会被更新，使之包含输入对象中所给的权限。如果指定了 `--remove-extra-permissions`，可以删除额外的权限。

已经存在的绑定也会被更新，使之包含输入对象中所给的主体。如果指定了 `--remove-extra-permissions`，则可以删除多余的主体。

例如:

- 测试应用 RBAC 对象的清单文件，显示将要进行的更改：

  ```shell
  kubectl auth reconcile -f my-rbac-rules.yaml --dry-run=client
  ```

- 应用 RBAC 对象的清单文件，保留角色（`roles`）中的额外权限和绑定（`bindings`）中的其他主体：

  ```shell
  kubectl auth reconcile -f my-rbac-rules.yaml
  ```

- 应用 RBAC 对象的清单文件，删除角色（`roles`）中的额外权限和绑定中的其他主体：

  ```shell
  kubectl auth reconcile -f my-rbac-rules.yaml --remove-extra-subjects --re
  ```





## 准入控制

(没什么好看的)

准入控制是API Server的插件集合，通过添加不同的插件，实现额外的准入控制规则。甚至于API Server的一些主
要的功能都需要通过 Admission Controllers 实现，比如 ServiceAccount

官方文档上有一份针对不同版本的准入控制器推荐列表，其中最新的 1.14 的推荐列表是：

~~~
NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota
~~~

列举几个插件的功能：

- NamespaceLifecycle： 防止在不存在的 namespace 上创建对象，防止删除系统预置 namespace，删除
  namespace 时，连带删除它的所有资源对象。
- LimitRanger：确保请求的资源不会超过资源所在 Namespace 的 LimitRange 的限制。
- ServiceAccount： 实现了自动化添加 ServiceAccount。
- ResourceQuota：确保请求的资源不会超过资源的 ResourceQuota 限制。

# Helm

helm的作用是能让我们一键创建Deployment, Service等等东西,  他的作用就类似于Docker Compose

在helm中有两个重要的概念:

- chart:  chart是已经写好的, 告诉k8s要如何创建Deployment, Service等等东西的文件, 这个chart可以是我们自己创建的, 也可以使用别人创建好的

  同时chart也可以配置参数, 里面也可以写判断条件等等, 用于根据不同的参数, 来生成不同的内容

- release:  我们可以根据chart来进行一次完整的应用的部署,  每次部署产生的Deployment, Service等等东西我们就成为一个release



## 安装

1. 从https://github.com/helm/helm/releases下载heml安装包, 并拷贝到linux上

   注意查看自己的电脑使用的是arm还是amd, 一般来说都是amd64的, arm只在手机和小型机上面使用

2. 解压安装包

   ~~~shell
   tar -xzvf helm-v3.13.1-linux-amd64.tar.gz
   ~~~

3. 移动到/usr/bin目录下

   ~~~shell
   mv linux-amd64/helm /usr/bin/
   chmod a+x /usr/bin/helm
   ~~~

4. 执行helm

   ~~~shell
   helm version
   ~~~

   

## 升级helm

Helm3 安装与升级过程主要是 helm 二进制文件的替换。

- 下载最版本的 Helm

  根据 Kubernetes 的版本选择对应的 helm 版本。

  如，需要将 Helm 升级到 `v3.7.1`，下载对应版本的压缩包冰解压

  ~~~shell
  $ wget https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
  $ tar xf helm-v3.7.1-linux-amd64.tar.gz
  ~~~

- 查找旧版本 Helm 的安装路径

  ~~~shell
  $ which helm
  /usr/local/bin/helm
  ~~~

- 升级 Helm

  使用新版本 helm 二进制文件替换旧版本的 Helm，升级过程就是二进制文件替换的过程

  ~~~shell
  $ cp linux-amd64/helm /usr/local/bin/helm
  $ chmod +x /usr/local/bin/helm
  ~~~

- 升级完成后，查看 helm 版本信息是否正确

  ~~~shell
  $ helm version
  ~~~

  



## 三方chart

### 命令行

| 命令                         | 说明                                                         |
| ---------------------------- | ------------------------------------------------------------ |
| `helm repo list`             | 列出当前配置的仓库                                           |
| `helm repo add <name> <url>` | 添加一个新的 chart 仓库                                      |
| `helm repo remove <name>`    | 删除仓库                                                     |
| `helm repo update`           | 更新所有仓库索引, helm search依赖本地索引, <br>所以在search之前最好更新一下索引, 否则会找不到最新的版本 |
| `helm search repo <keyword>` | 在你通过add添加的仓库中搜索chart                             |
| `helm search hub <keyword>`  | 在 Helm 官方 hub 上搜索 chart                                |
| `helm pull <chart_name>`     | 将仓库中的chart下载到本地并解压                              |

~~~shell
helm repo add microsoft http://mirror.azure.cn/kubernetes/charts
helm repo add aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
~~~



你可以通过如下命令来增加, 删除, 更新一个仓库

~~~shell
helm repo add bitnami https://charts.bitnami.com/bitnami # 添加仓库
helm repo add myrepo https://repo.example.com \
  --username admin \
  --password xxx # 添加需要认真的私有仓库

helm repo list # 查看现有仓库

# 更新仓库的index.yaml文件, helm search不是实时搜索仓库, 而是查找本地的index.yaml文件
# 所以不更新这个index.yaml文件, 你就找不到新的版本的chart
helm repo update

helm repo remove bitnami # 删除一个仓库
~~~



**chart除了可以保存在helm的repository中, 中央仓库中, 还可以保持在OCI仓库中, 这个OCI仓库也是私有仓库的一种, 但是他主要用来存放镜像, chart之类的东西**

OCI仓库相较于helm repository仓库, 有以下几点不同

- 使用专门的oci协议来拉取文件, 而helm repository使用http协议
- 支持认证, RBAC等等
- 可以和镜像一起统一治理

你可以使用如下的命令来登录一个OCI仓库, 比如barbor

~~~shell
helm registry login harbor.example.com
helm registry login harbor.example.com  -u admin -p password # 带认证

helm registry logout harbor.example.com # 退出oci仓库

helm push myapp-1.2.0.tgz oci://harbor.example.com/helm # 推送chart到oci仓库
helm pull oci://harbor.example.com/helm/myapp --version 1.2.0 # 从oci仓库中下载chart

~~~



有了仓库之后, 你就可以搜索仓库中的第三方chart文件了

~~~shell
helm repo update # 搜索之前一定要执行这个命令, 更新index文件

helm search repo mysql # 这个命令会查找本地的repo对应的index文件, 并搜索名称包含mysql的的chart


helm search repo mysql --versions # 显示chart的所有的版本
helm search repo mysql --devel # 包含开发版本
helm search repo mysql --version 9.14.2 # 查找指定的版本
~~~

当然你也可以在helm的公共仓库Helm Hub中查找chart

~~~shell
helm search hub kafka # 这个命令实时查找中央仓库中的chart
~~~



在找到你想要查看的chart之后, 你可能想要看看chart里面写了什么东西, 他的values.yaml中可以指定哪些变量, 那么你可以使用下面的命令

~~~shell
helm show all bitnami/mysql # 查看所有内容, 通常没什么大用, 因为内容太多了
helm show chart bitnami/mysql # 查看chart的信息 
helm show crds bitnami/mysql # 查看charts的CRDS
helm show readme bitnami/mysql # 查看charts的readme
helm show values bitnami/mysql # 查看chart的values.yaml
~~~



之后如果你确认是你想要下载的chart, 你就可以通过helm pull把想要的chart下载到本地, 为后面的安装做准备

~~~shell
helm pull bitnami/mysql # 下载最新的版本
helm pull bitnami/mysql --version 9.14.2 # 下载指定的版本
helm pull oci://harbor.example.com/helm/myapp  --version 1.2.0 # 从oci仓库下载
~~~

当然你也可以直接安装chart

~~~shell
helm install myapp  oci://harbor.example.com/helm/myapp  --version 1.2.0 # 直接安装chart
~~~





### 中央仓库

我们这里以安装nginx为例, 首先访问https://artifacthub.io/, 搜索框中搜索 `nginx`

![image-20250708211107420](img/k8s笔记/image-20250708211107420.png)

点击右侧的install

![image-20250708211227876](img/k8s笔记/image-20250708211227876.png)

首先添加通过`helm repo`添加仓库, 然后通过`helm install` 来安装这个nginx 

![image-20250708211328021](img/k8s笔记/image-20250708211328021.png)

~~~shell
# 添加nginx的仓库
helm repo add bitnami https://charts.bitnami.com/bitnami

# 根据仓库中的nginx的chart, 创建一个my-nginx的release
helm install my-nginx bitnami/nginx --version 21.0.6

# 当然, 你也可以直接下载仓库中的nginx的chart, 这会下载一个nginx-21.0.6.tgz到本地
helm pull oci://registry-1.docker.io/bitnamicharts/nginx --version 21.0.6
tar -xzvf tar -zxvf nginx-21.0.6.tgz # 解压出一个nginx目录
helm install my-nginx nginx # 根据nginx中的chart来创建my-nginx

# 当然, 你也可以指定release安装到你想要的namespace中
helm install my-nginx nginx --namespace my-ns # 指定安装到my-ns的命名空间中

# 如果你不想要使用nginx/values.yaml来配置chart, 那么也可以自己指定一个文件来替代values.yaml
helm install my-nginx nginx --namespace my-ns -f my-values.yaml # 不要使用默认的values.yaml而是使用my-values.yaml

# 如果你不想要完全覆盖values.yaml中, 只想覆盖个别的属性, 那么可以使用--set属性来覆盖
helm install my-nginx nginx --namespace my-ns --set aaa.bbb=xxx
~~~











## 创建自定义charts

要使用自定义的chart的话, 首先你可以使用如下的命令来创建一个chart

~~~shell
helm create mychart
~~~

他会生成如下结构(只是演示, 有些可能没有)

~~~text
mychart/
├── Chart.yaml
├── values.yaml
├── charts/
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── serviceaccount.yaml
│   ├── hpa.yaml
│   ├── NOTES.txt
│   └── tests/
│       └── test-connection.yaml
└── .helmignore
~~~



### chart中各个文件的作用

#### Chart.yaml

他是一个chart的必须文件, 里面包含了这个chart本身的一些信息

~~~yaml
apiVersion: v2 # 制定Chart.yaml的规范版本, 在helm3中必须指定v2
name: my-web-app # 当前chart的名字
description: >
  A Helm chart for deploying My Web Application.
  This application provides REST APIs and background jobs.
  
# 表示当前的chart是一个app, 可以直接helm install
# 另外一个可选择是library, 表示是公共模板, 不能install
type: application 

version: 1.4.2 # 当前chart的版本
appVersion: "2.3.7" # 业务应用的版本

kubeVersion: ">=1.23.0 <1.30.0" # 声明当前Chart支持的k8s的版本范围, 如果版本不匹配, 安装会报错

# 下面三个属性是当前chart的home page
home: https://github.com/example/my-web-app
sources:
  - https://github.com/example/my-web-app
  - https://github.com/example/my-web-app-deploy
icon: https://raw.githubusercontent.com/example/my-web-app/main/docs/logo.png

# 关键字, 在helm search / Artifact Hub 中搜索有用
keywords:
  - web
  - spring-boot
  - backend
  - api

# 负责任信息
maintainers:
  - name: Alice Zhang
    email: alice@example.com
    url: https://example.com/alice
  - name: Bob Li
    email: bob@example.com

# 申明当前chart需要依赖的chart
dependencies:
  - name: redis
    version: "~17.3.0"
    repository: "https://charts.bitnami.com/bitnami"
    alias: cache # 安装的时候重命名这个chart
    condition: cache.enabled

# helm不使用这个, 主要用于第三方平台(Artifact Hub)读取
annotations:
  category: backend
  support: "support@example.com"
  artifacthub.io/license: Apache-2.0
  artifacthub.io/links: |
    - name: GitHub
      url: https://github.com/example/my-web-app
    - name: Documentation
      url: https://example.com/docs
~~~



#### values.yaml

所有模板变量的默认值来源

~~~yaml
replicaCount: 1

image:
  repository: nginx
  tag: "1.25"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
~~~

你可以在`templates/`中的模板中使用`.Values`来使用这里面的值, 比如

~~~yaml
# templates/aa.yaml
{{ .Values.image.repository }}
~~~



当然这里面的值也可以被覆盖

~~~shell
helm install . -f custom.yaml --set key=value
~~~



#### .helmignore

这是一个可选的文件, 类似`.gitignore`, 可以决定哪些文件不打包进chart, 减少chart包的体积, 避免把无关的文件发送给Helm

~~~txt
.git/
*.swp
*.tmp
~~~



#### charts目录

这是一个目录, 主要用于存放子chart(依赖), 他的目录结构类似如下

~~~text
charts/
├── mysql-9.4.0.tgz
└── redis/
    ├── Chart.yaml
    └── templates/
~~~

这类子chart主要有两种来源

1. 本地解压后的子Chart
2. .tgz打包好的依赖

如果你在`Chart.yaml`中声明了`dependencies`, 那么helm就会下载这些文件到charts这个目录里面



#### templates目录

这个目录里面保存的是你要创建的资源的模板, 比如deployment.yaml, service.yaml等等

~~~yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
~~~



#### _helpers.tpl

如果你有通用的模板, 那么可以定义在这个文件里面, 比如下面的文件

~~~yaml
# _helpers.tpl

{{- define "mychart.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end -}}
~~~

你可以在templates中的yaml文件中通过include, template 来调用这些模板

> 这个文件里面只能定义模板, 不做其他的用途



#### NOTES.txt

这个文件主要用于安装/升级完成之后, 显示给用户的提示信息

~~~txt
Your application is now running.

Access it via:
  http://{{ .Release.Name }}.example.com
~~~

这个文件常常用于

- 提示你可以访问哪些地址来操作release
- 提示默认的账号密码
- 提示你后续需要进行的操作等等



#### templates/tests目录

`templates/tests/` 用来定义 Helm Chart 的“**post-install tests**”,  他们通常是Pod和Job, 用来来验证 Chart 是否工作正常



1. `templates/tests`中的文件怎么被helm识别的

   tests 里的 YAML 本质上还是 **Kubernetes 资源模板**，但多了一个关键注解：

   ```
   metadata:
     annotations:
       "helm.sh/hook": test
   ```

   只要：

   - 资源在 `templates/` 下（通常放在 `templates/tests/`）
   - 带有 `helm.sh/hook: test`

   👉 Helm 就会把它当成 **测试资源**

2. `templates/tests`中的文件什么时候执行

   **他们不会自动执行**, 你必须手动执行：

   ```
   helm test <release-name>
   ```

   执行流程：

   1. Helm 找到所有 `helm.sh/hook: test` 的资源
   2. 创建这些资源（Pod / Job）
   3. 等待它们完成
   4. 根据退出状态判断测试成功或失败, 如果容器exit code为0表示测试成功, 否则失败

3. `templates/tests`中的文件通常会指定hook-delete-policy这个annotation

   因为默认情况下测试完的pod/job还是会留在集群中, 所以你可以通过hook-delete-policy来指定是否要删除

   ~~~yaml
   metadata:
     annotations:
       "helm.sh/hook": test
       "helm.sh/hook-delete-policy": hook-succeeded
   ~~~

   | 值                   | 含义           |
   | -------------------- | -------------- |
   | hook-succeeded       | 成功后删除     |
   | hook-failed          | 失败后删除     |
   | before-hook-creation | 创建前先删旧的 |



一个经典案例就是

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "mychart.fullname" . }}-test-connection"
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command:
        - wget
      args:
        - "--spider"
        - "http://{{ include "mychart.fullname" . }}:{{ .Values.service.port }}"
  restartPolicy: Never
~~~

他会启动一个pod, 并通过wgt --spider来调用对应的接口, 如果能连通那么exit 0否则exit 非0



### chart的依赖

在helm的chart.yaml中, 你可以声明一个`dependencies`字段, 这个字段主要用来声明当前Helm Chart所依赖的其他Chart (通常被称为是子chart),  他是实现chart复用和模块化管理的核心机制

~~~yaml
apiVersion: v2
name: my-app
version: 1.0.0

dependencies:
  - name: redis
    version: 14.8.8
    repository: "https://charts.bitnami.com/bitnami"
    condition: redis.enabled
    tags:
      - backend
    import-values:
      - data: redisData
~~~

各个字段的说明如下

| 字段            | 类型   | 说明                                                         |
| --------------- | ------ | ------------------------------------------------------------ |
| `name`          | string | 依赖的 Chart 名称（通常是 Chart 的 `Chart.yaml` 中的 `name`）。 |
| `version`       | string | 指定依赖 Chart 的版本，可以使用 semver 范围，如 `">=14.0.0 <15.0.0"`。 |
| `repository`    | string | 如果你使用的是远程仓库中的第三方chart, 那么这个字段是指定helm仓库的url<br />如果你的子chart就是你自己写的, 并且放在`charts`目录下面, 那么可省略这个字段。 |
| `condition`     | string | 用来控制是否启用这个依赖 Chart。通常指向父项目的 `values.yaml` 中的布尔值，例如 `redis.enabled`。 |
| `tags`          | list   | 用于对依赖 Chart 分类，通过 `--set <tag>=true` 启用或禁用同一标签下的所有依赖。 |
| `import-values` | list   | 用于从子 Chart 的 `values.yaml` 导入部分值到父 Chart 的 `values.yaml`。可以是简单映射或嵌套映射。 |



#### 条件控制

在`dependencies`中,  condition和tags是控制这个子chart是否启用的关键

- condition

  通过 `values.yaml` 中的布尔值启用或禁用某个 Chart，例如：

  ```yaml
  redis:
    enabled: false
  ```

  如果 `condition: redis.enabled`，那么 子chart redis就不会被渲染执行

  当然condition可以设置为多条件的情况, 他们之间是and的条件, 只有在所有都成立的时候执行子chart

  ~~~yaml
  condition:
    - redis.enabled
    - common.enabled
  ~~~

- tags

  你可以给多个子chart设置tags, 然后在安装或者升级的时候, 通过`--set <tag>=true|false`批量控制是否启用一批次的子chart

  ~~~yaml
  tags:
    - backend
    - cache
  ~~~

  ~~~yaml
  helm install my-app ./my-chart --set backend=true
  ~~~

  多个tag之间是or的条件, 只要有一个条件成立,那么tag就会成立

- condition和tags之间

  如果你同时设置了condition和tags的话, 那么只有同时condition和tags同时成立, 那么子chart才会被渲染执行



#### import-values

这个字段在 Helm v3 中非常重要，它用于 **将子 Chart 的值映射到父 Chart 的 values 中**,  **这样你就可以在父chart中的values.yaml中控制子chart的行为了**



比如你有一个redis的子chart, 他的values.yaml如下:

~~~yaml
config:
  maxmemory: "256mb"
  maxclients: 1000
password: "123456"
~~~

那么你可以通过`import-values`将这段代码导入父chart的values.yaml的某个路径下, 比如

~~~yaml
dependencies:
  - name: redis
    version: 14.8.8
    repository: "https://charts.bitnami.com/bitnami"
    import-values:
      - redisConfig: config
      - password
~~~

其中`password` 用于将redis这个chart中的`password`键及其子内容导入到父 Chart 的 `values.yaml` 下。

`redisConfig: config`将redis这个子chart的values.yaml中的config这个字段导入到父chart的values.yaml中的redisConfig这个key下面

这就相当于你在父chart的values.yaml中写了下面的代码一样

~~~yaml
redisConfig:
  maxmemory: "256mb"
  maxclients: 1000
password: "123456"
~~~



当然你也可以在父chart中实际指定这些值, 来覆盖子chart中的values.yaml

~~~yaml
redisConfig:
  maxmemory: "512mb"  # 覆盖子 Chart 的 maxmemory
password: "abcdef"    # 覆盖子 Chart 的 password
~~~



#### 依赖第三方子chart

如果你的chart依赖的是第三方的子chart, 那么你可以通过如下的命令来下载这个子chart

```shell
helm dependency update
```

你执行上面的命令后, 他会查找`charts.yaml`中的`dependencies`字段, 如果这个子chart是一个第三方依赖, 那么他会去远程仓库中下载这个chart对应的tgz压缩包, 并保持到`charts/`这个目录下, 并生成对应的`Chart.lock`文件

~~~text
my-chart/
├── Chart.yaml
├── Chart.lock      👈 自动生成 / 更新
├── charts/         👈 下载好的依赖 Chart
│   ├── redis-14.8.8.tgz
│   └── postgresql-12.3.4.tgz
└── values.yaml
~~~



当然还有一个命令

~~~shell
helm dependency build
~~~

他和`helm dependency update`的区别在于

| 命令     | 行为                                                         |
| -------- | ------------------------------------------------------------ |
| `update` | **重新解析 Chart.yaml，拉取最新符合条件的依赖，并更新 Chart.lock <br />适合用于第一次生成lock文件, 或者更新依赖** |
| `build`  | **严格按照 Chart.lock 下载依赖，不解析版本范围**<br />**适用于已经有了lock文件, 要下载对应的依赖** |





### chart的安装/测试/升级/调试/回滚

#### 准备

首先你可以通过如下的命令来创建一个chart模版

~~~shell
[root@node-157 helm-test]# helm create myapp
Creating myapp
[root@node-157 helm-test]# ls
myapp
[root@node-157 helm-test]# tree
.
└── myapp
    ├── charts
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── _helpers.tpl
    │   ├── hpa.yaml
    │   ├── ingress.yaml
    │   ├── NOTES.txt
    │   ├── serviceaccount.yaml
    │   ├── service.yaml
    │   └── tests
    │       └── test-connection.yaml
    └── values.yaml
~~~

你可以将`templates/`中不需要的文件全部删除掉, 并添加你自己的k8s资源文件, 比如下面添加了两个志愿文件

~~~yaml
# deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  # 这里引用了一个变量, 通过这个变量可以引用helm install 传入进来的release name
  name: {{.Release.Name}}-deploy 
  # 通过这个变量来引用values.yaml中的ns变量
  namespace: {{.Values.ns}} 
spec:
  # # 通过这个变量来引用values.yaml中的replicas变量
  replicas: {{.Values.replicas}} 
  selector:
    matchLabels:
      app: {{.Release.Name}}
  template:
    metadata:
      labels:
        app: {{.Release.Name}}
    spec:
      containers:
        - name: {{.Release.Name}}-c
          image: {{.Values.image.name}}:{{.Values.image.tag}}
          ports:
            - name: http-web-svc # 端口名字
              containerPort: 80
              
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{.Release.Name}}-svc
  namespace: {{.Values.ns}}
spec:
  type: NodePort
  selector:   # 表现选择器, 选择指定的pod
    app: {{.Release.Name}}
  ports:
    - name: name1
      port: 80 # 访问service内部ip的端口
      protocol: TCP
      targetPort: http-web-svc # 转发到的端口, 可以直接写端口名字, 也可以使用数字
~~~

之后你可以在values.yaml中添加你需要的变量

~~~yaml
replicas: 3
ns: default
image:
  name: nginx
  tag: 1.24
~~~



#### 子依赖

如果你的chart有子依赖,  那么可以添加到`Chart.yaml`中的`dependencies`字段中

你可以通过如下的命令来查看一个chart中包含了哪些子chart

~~~shell
helm dependency list
~~~

之后你可以通过如下的命令下载依赖的子依赖的tag压缩包

~~~helm
helm dependency update myapp
~~~

上面的命令会读取`dependencies`字段, 然后下载对应的chart压缩包到`charts/`中, 然后生成`Chart.lock`到根目录下面

如果你的chart已经有了`Chart.lock`文件, 你也可以使用下面的命令来下载子chart,  他会严格按照`Chart.lock`中指定的版本来下载

~~~shell
helm dependency build myapp
~~~





#### 调试

你在完成了Chart的内容编写之后, 可以通过如下的命令来校验char中的各个文件是否有语法问题, 是否缺少必要的字段等等

~~~shell
helm lint myapp
~~~

如果上面的代码通过了, 那么就可以进行安装了, 但是在安装之前, 你可以通过如下的命令来查看一下最终要执行的k8s资源到底长什么样子

~~~shell
helm template my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2
~~~

如果你想要更详细的内容, 那么你可以添加上`--debug`选项

~~~shell
helm template my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2 --debug
~~~

当然你也可以将渲染后的内容, 输出到指定的文件中, 便于查看

~~~shell
helm template my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2 > rendered.yaml
~~~

如果你不想查看渲染之后的所有文件, 只想查看特定的文件渲染后的样子, 那么可以使用如下命令

~~~shell
helm template my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2 --show-only templates/deployment.yaml
~~~



#### 安装

在查看了最终渲染后的资源文件之后, 那么你可以使用如下命令进模拟安装

~~~shell
helm install my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2  --dry-run # 模拟安装
helm install my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2  --dry-run --debug # 带调试信息的模拟安装
~~~

如果模拟安装没有问题的话, 那么你就可以执行真正的安装了

~~~shell
helm install my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2 # 直接安装

helm install my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2 --debug # 带调试信息的安装

helm install my-release myapp -f aaa.yaml -f bbb.yaml --set key1=value1 --set key2=value2 --debug  2>&1 | tee install-debug.log # 保持调试信息到日志文件中
~~~

当然还有一些flag可以在安装和升级的时候可以使用的

| Flag               | 说明                                 | 适用命令                   |
| ------------------ | ------------------------------------ | -------------------------- |
| -n, --namespace    | 指定安装的release的命名空间          | install, upgrade, list等   |
| --create-namespace | 如果指定的ns不存在, 那么自动创建     | install, upgrade           |
| -f, --values       | 指定values文件, 可以多次指定多个文件 | install, upgrade, template |
| --set              | 甚至参数值                           | install, upgrade           |
| --dry-run          | 模拟运行                             | install, upgrade           |
| --debug            | 输出调试信息                         | install, upgrade, template |
| --wait             | 等待就绪                             | install, upgrade           |
| --timeout          | 指定超时时间                         | install, upgrade           |
| --atomic           | 失败自动回滚                         | install, upgrade           |
| --version          | 指定chart版本                        | install, upgrade           |
| -o, --output       | 指定要输出的格式                     | install, get               |

如果你同时指定了`-f`和`--set`, 那么他们的优先级如下, 从低到高

   ~~~txt
   values.yaml
   charts/*/values.yaml
   -f custom.yaml
   --set key=value
   ~~~



#### 测试

在`templates/`目录下有一个特殊的`test`目录,  这个目录下的文件在`helm install`的时候会被渲染, 但是不会被执行, 这个目录下的文件主要用于chart在被安装之后, 用于测试release是否正常工作的脚本, 类似于**post-install tests**, 所以他们通常是Pod和Job类型的资源文件



这些文件必须带有如下的hook标识, 并且保持在`templates/test`目录下, 才会被任务是测试文件

~~~yaml
metadata:
  annotations:
    "helm.sh/hook": test
~~~



这些文件必须通过如下的命令来执行

~~~shell
helm test <release-name>
~~~

执行流程：

1. Helm 找到所有 `helm.sh/hook: test` 的资源
2. 创建这些资源（Pod / Job）
3. 等待它们完成
4. 根据退出状态判断测试成功或失败, 如果容器exit code为0表示测试成功, 否则失败





#### 查看

如果你安装了多个release, 那么可以通过如下命令来查看这些release

~~~shell
helm list -A
helm list -n my-namespace
helm ls -n my-namespace # 简写
~~~

~~~shell
[root@kysp32303node2 ai-algorithm-initdb]# helm list -A | grep syslog
syslog                          service-software        1               2025-12-12 20:25:33.60101914 +0800 CST  deployed        syslog-12.3.3                        3.8.3
syslog-kafka-init               service-software        2               2025-12-23 14:58:30.848726059 +0800 CST deployed        common-kafka-init-12.3.3             3.8.3
syslog-rule                     service-software        1               2025-12-12 20:25:33.53787081 +0800 CST  deployed        syslog-rule-12.3.3                   3.8.3
~~~



你可以通过如下的命令来查看release的状态, 安装日期

~~~shell
[root@kysp32303node2 ai-algorithm-initdb]# helm status syslog -n service-software
NAME: syslog
LAST DEPLOYED: Fri Dec 12 20:25:33 2025
NAMESPACE: service-software
STATUS: deployed
REVISION: 1
TEST SUITE: None
~~~



你也可以使用如下的命令来查看release安装的时候, 使用的模版的内容

~~~shell
helm get all -n service-software syslog # 打印安装的时候, 使用的所有文件,包括资源文件, values.yaml, NOTES.txt, _helper.tpl等等的所有文件
helm get values -n service-software syslog # 只打印values.yaml文件
helm get notes -n service-software syslog # 只打印NOTES.txt文件
helm get hooks -n service-software syslog # 只打印所有的hook
helm get manifest -n service-software syslog # 查看k8s实际创建的资源的yaml文件, 包括deploy, pod,svc, cm, ns等等
~~~

你也可以通过如下的命令, 来查看某个历史版本的资源文件

~~~shell
helm get all -n service-software syslog --revision 2
~~~

#### 卸载

如果你想要卸载某个release, 那么可以使用如下的命令

~~~shell
helm uninstall my-release -n my-namespace
~~~



#### 升级

如果你想要升级一个chart, 那么有两种方式来改动这个chart

1. 直接修改本地文件中的chart
2. 不修改chart文件, 但是通过`-f, --set`来指定不同的变量

之后你可以先通过如下的命令来查看升级前后release的差异

~~~shell
helm diff upgrade my-release ./mychart -n my-ns # 这个命令需要helm-diff插件
~~~

如果你没有这个插件, 你也可以使用如下的命令来进行比较

~~~shell
helm template myapp ./mychart -n demo > new.yaml
helm get manifest myapp -n demo > old.yaml
diff old.yaml new.yaml
~~~



知晓差异之后, 你可以通过`--dry-run`这个命令来模拟一次升级

~~~shell
helm upgrade myapp ./mychart  -n my-ns --dry-run --debug
~~~



如果万事顺利, 那么你就可以执行真正的升级了

~~~shell
# -n指定release的命名空间
# -f指定values文件
# --set设置values文件中的属性
# --isntall 如果没有release升级, 那么就install
# --wait --timeout 5m 等待资源就绪
# --atomic 如果升级失败, 自动回滚
helm upgrade my-release ./mychart \
-n my-ns \
-f values1.yaml -f values2.yaml \
--set k1=v1 --set k2=v2 \
--install \
--wait --timeout 5m \
--atomic
~~~

在执行上面的命令的时候, helm会

- 读取 **当前 Release 的状态**

- 用新的 Chart + values **重新渲染 YAML**

- 对比新旧 Manifest

- 对 Kubernetes 资源执行：
  - `PATCH`
  - 必要时 `DELETE + CREATE`

- 生成一个 **新的 revision**

- 旧 revision 仍然保留（用于 rollback）





#### 历史

你升级之后, 不管成功还是失败, release都会增加一个revision, 你可以通过如下的命令来查看release的历史

~~~shell
[root@kysp32303node2 ai-algorithm-initdb]# helm history -n service-software itoa-aiops-algorithm-service
REVISION        UPDATED                         STATUS          CHART                                   APP VERSION     DESCRIPTION                                   
1               Fri Dec 12 20:20:35 2025        deployed        itoa-aiops-algorithm-service-1.6.5      0.16.0          Install complete                              
2               Tue Dec 23 14:58:32 2025        failed          itoa-aiops-algorithm-service-1.6.5      0.16.0          Upgrade "itoa-aiops-algorithm-service" failed: pre-upgrade hooks failed: timed out waiting for the condition
~~~



#### 回滚

回滚相当于一次特殊的设计, 他是将以前的release的chart文件拿出来了, 然后重新upgrade一次, 所以会生成一个新的revision

~~~shell
helm history myapp -n my-ns
REVISION  UPDATED                  STATUS     CHART        APP VERSION  DESCRIPTION
1         2025-01-01 10:00:00      deployed   myapp-1.0.0  1.0.0        Install complete
2         2025-01-02 11:00:00      deployed   myapp-1.1.0  1.1.0        Upgrade complete
3         2025-01-03 12:00:00      failed     myapp-1.2.0  1.2.0        Upgrade failed

# 先比较当前revision 和 要回滚的revision 的差异
helm get manifest myapp -n my-ns > current.yaml
helm get manifest myapp --revision 2 -n my-ns > target.yaml
diff current.yaml target.yaml


# 先模拟回滚一下
helm rollback myapp 2 -n my-ns --dry-run  --debug


# 将状态回滚到revision=2的manifest, 并生成一个新的revision 4
helm rollback myapp 2 -n my-ns   --wait --timeout 5m

# 查看回滚后资源的状态
helm status myapp -n my-ns
~~~

需要注意的是

- 回滚只能回滚Deployment, Service, ConfigMap, Secret

  CRD, PVC, 外部DB数据是不能回滚的

- 回滚只是把渲染后的manifest文件拿出来重新执行一遍, 所以不能指定values

- 回滚的时候, 各种hooks也会被执行



#### 打包

最后, 如果万事顺利, 那么你就可以将你的chart打包成tag压缩包了, 之后发送给被人使用了

~~~shell
helm package mychart # 生成mychart-version.tgz文件
~~~

他有如下的flag可以使用

| flag                 | 作用                                                |
| -------------------- | --------------------------------------------------- |
| --destination ./dist | 指定tgz文件输出的路径                               |
| --version 1.2.4      | 打包时, 设置chart的版本, 不会覆盖Chart.yaml中的版本 |
| --app-version 2.0.1  | 设置应用的版本                                      |
| --dependency-update  | 在打包之前通过`helm dependency update`更新子chart   |



### helm hook

Helm 中的 hook（钩子）是一种特殊的模板资源机制，用于在 Helm 的安装、升级、删除等生命周期事件中，插入自定义行为（如执行一个初始化 Job、清理脚本等）。

**如果hook 运行失败默认会中断 Helm 流程**



helm支持如下类型的hook

| Hook 类型       | 说明                                          |
| --------------- | --------------------------------------------- |
| `pre-install`   | 在 `helm install` **之前**执行                |
| `post-install`  | 在 `helm install` **之后**执行                |
| `pre-upgrade`   | 在 `helm upgrade` **之前**执行                |
| `post-upgrade`  | 在 `helm upgrade` **之后**执行                |
| `pre-rollback`  | 在 `helm rollback` **之前**执行               |
| `post-rollback` | 在 `helm rollback` **之后**执行               |
| `pre-delete`    | 在 `helm uninstall` **之前**执行              |
| `post-delete`   | 在 `helm uninstall` **之后**执行              |
| `test`          | 通过 `helm test` 触发，仅在手动运行测试时执行 |



要想实现一个hook, 我们可以在`templates`下定义yaml文件

- 如果helm没有在yaml中扫描到特殊的注解, 那么这些k8s资源文件就会被当做普通资源对待

- 如果k8s在这些yaml中扫描到关于hook特殊的注解, 那么这些k8s资源文件就会被当做hook对待

  hook创建的资源不会像普通资源一样长期存在于k8s集群中

下面我们实现一个hook, 用于在升级release之前执行

~~~yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: syslog-pre-upgrade-job
  namespace: service-software
  labels:
    app: syslog
    component: syslog
  annotations:
    # 通过这个注解, 将资源文件标记为hook, 并且在当前的release升级之前执行
    # 如果不添加这个注解, 那么其他的htlm.sh注解也是无效的
    "helm.sh/hook": pre-upgrade 
    # 可选, 通过这个注解来指定helm何时自动清理这个hook资源, 可选的值有
    #     hook-succeeded 当 hook 资源成功执行（退出码 0）后删除
    #     hook-failed    当 hook 资源失败时删除
    #     before-hook-creation	 当下一次执行 hook 前删除上次生成的hook资源
    # 你可以组合上面三个值, 来表达不同的意思, 比如
    #     hook-succeeded,hook-failed 无论hook成功失败都删除hook资源
    #     before-hook-creation,hook-succeeded 在下一次执行hook的时候删除上一次的hook资源, 并且在hook成功的时候直接删除hook资源
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
    # 可选, 如果有多个相同阶段的hook, 那么可以通过weight来定义他们的先后执行顺序
    # weight越小, 越先执行, weight可以为负数
    "helm.sh/hook-weight": "0"
    # 可选, 用于控制 Helm 在执行 uninstall（卸载）操作时是否删除hook资源
    # 你可以指定为true, 那么即使uninstall的时候, 也不会删除hook资源
    # 你也可以不指定这个值, 那么会使用Helm 默认行为，会删除该资源, 主要用于ConfigMap和PVC
    "helm.sh/resource-policy": keep
spec:
  template:
    metadata:
      labels:
        app: pre-upgrade
    spec:
      restartPolicy: Never
      containers:
      - name: pre-upgrade
        image: "matrix-registry.h3c.com:8088/middle/common-job:1.0"
        imagePullPolicy: Always
        # 执行这个job就会执行preUpdateHook.sh这个脚本
        command: ["bash", "/opt/custom/preUpdateHook.sh"]
        volumeMounts:
        # 通过和release中的pod挂载同一个hostPath, 操作文件来影响release中的pod
        - name: custom-path
          mountPath: /opt/custom/
        - name: log
          mountPath: /var/deploy/
    volumes:
    - name: custom-path
      hostPath:
      {{- if eq .Values.normalPatch true }}
        path: {{ .Values.patchcustomPath }}/syslog/scripts/
      {{- else }}
        path: {{ .Values.customPath }}/syslog/scripts/
      {{- end }}
        type: Directory
    - name: log
      hostPath:
        path: /var/lib/ssdata/logcenter/SYSLOG/deploy
~~~

> 需要注意的是: 因为执行hook的pod和release中创建的pod不是同一个pod, 所以hook中的pod在执行的时候, 并不会影响到release中的pod, 所以hook能做的事情非常的有限, 比如
>
> 1. 将hostPath, PVC同时挂载到hook和release的pod中, 这样可以就可以对同一块磁盘做一些操作, 比如执行shell脚本等等, 或者脚本可以写文件作为“信号”，让主容器在启动时读取这些文件并做出反应
> 2. 可以在hook中调用curl等工具来访问api-server, 进行一些操作
>
> 他不能做的事情有: 
>
> 1. 直接操作release的pod中的进程和文件, 因为hook是另外一个pod, 不能访问其他容器中的内容



### templates目录中文件的执行顺序

有这样一种情况, 我的chart的templates目录中有创建role, service-account, namespace rolebinding, configmap, deploy的文件

那么按照正常的逻辑, 我应该先创建namespace, 然后创建role, service-account, 然后创建rolebinding, configmap, 然后创建deploy

但是helm在执行chart安装release的时候, 并不会去控制templates中的文件, 而是直接安装文件的字母属性来执行

我们有两种办法来控制资源创建的先后

1. 在文件名前面加上序号, 序号越小的越先执行

   ~~~yaml
   01-namespace.yaml
   02-role.yaml
   03-service-account.yaml
   04-rolebinding.yaml
   05-configmap.yaml
   06-deploy.yaml
   ~~~

2. 通过helm hook来控制templates中文件执行的顺序

   ~~~shell
   apiVersion: v1
   kind: Namespace
   metadata:
     name: my-namespace
     annotations:
       "helm.sh/hook": "pre-install"
       "helm.sh/hook-weight": "0"  # 设置 weight 为 0，最先执行
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     name: my-role
     namespace: my-namespace
     annotations:
       "helm.sh/hook": "pre-install"
       "helm.sh/hook-weight": "5"  # 设置 weight 为 5，优先执行
   spec:
     rules:
     - apiGroups: [""]
       resources: ["pods"]
       verbs: ["get", "list", "watch"]
   ---
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: my-service-account
     namespace: my-namespace
     annotations:
       "helm.sh/hook": "pre-install"
       "helm.sh/hook-weight": "10"  # 设置 weight 为 10，第二优先
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     name: my-rolebinding
     namespace: my-namespace
     annotations:
       "helm.sh/hook": "pre-install"
       "helm.sh/hook-weight": "15"  # 设置 weight 为 15，第三优先
   subjects:
     - kind: ServiceAccount
       name: my-service-account
       namespace: my-namespace
   roleRef:
     kind: Role
     name: my-role
     apiGroup: rbac.authorization.k8s.io
   --- 
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: my-configmap
     namespace: my-namespace
   data:
     key: value
   --- 
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: my-deployment
     namespace: my-namespace
     annotations:
       "helm.sh/hook": "post-install"  # 确保 Deployment 在安装后创建
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: my-app
     template:
       spec:
         containers:
         - name: my-app
           image: my-app-image
   ~~~

**实际上, 我们根本就没有必要去控制templates目录中的资源创建的先后**

因为在k8s中, 如果你RoleBinding依赖于Role和ServiceAccount, 那么k8s还是允许你创建RoleBinding的, 只是他暂时不会生效, 只有你创建了Role和ServiceAccount的时候, 才会生效

如果Deploy依赖一个ConfigMap, 如果没有先创建ConfigMap, 而是先创建了Deploy, 那么Pod实际上会进入`CrashLoopBackOff`的状态, 等到ConfigMap创建好了之后, pod自然可以创建成功







## 查找chart创建的资源

有时候你可能会想, 我通过chart来安装release, 那么这个release到底控制了哪些k8s资源呢, 那么你可以使用下面的方式来查看

1. 在安装chart的时候, 一般的标准chart都会为他创建的这些k8s资源添加标准的label

   ~~~yaml
   labels:
     app.kubernetes.io/instance: my-nginx      # release 名称
     app.kubernetes.io/managed-by: Helm        # 表示 Helm 管理
     app.kubernetes.io/name: nginx             # chart 名称
     app.kubernetes.io/version: 1.29.2         # chart 的 appVersion
     helm.sh/chart: nginx-22.0.10              # chart 名称+版本
   ~~~

   所以你可以通过如下的命令, 来根据label进行过滤, 查找到这个realease创建的所有k8s资源

   ~~~shell
   # kubectl get all -l "app.kubernetes.io/instance=my-nginx"
   NAME                            READY   STATUS    RESTARTS   AGE
   pod/my-nginx-54dfd88c85-25hvs   1/1     Running   0          46m
   
   NAME               TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
   service/my-nginx   LoadBalancer   10.97.23.137   <pending>     80:32613/TCP,443:30227/TCP   46m
   
   NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/my-nginx   1/1     1            1           46m
   
   NAME                                  DESIRED   CURRENT   READY   AGE
   replicaset.apps/my-nginx-54dfd88c85   1         1         1       46m
   ~~~

2. 如果你碰到的不是特别标准的chart, 他没有给release创建的k8s创建标准的label, 那么你也可以通过如下的命令来查看执行的k8s的yaml文件, 然后根据显示的内容来查看创建了哪些k8s资源

   ```shell
   helm get manifest <release>
   ```




## 命令自动补全

你可以调用如下的命令, 来生成一段自动补全的代码

~~~shell
helm completion bash  # 生成bash终端的自动补全代码
helm completion fish 
helm completion powershell
helm completion zsh
~~~

之后将这段代码, 放在终端启动时的初始化文件中, 即可生效

~~~shell
helm completion bash > /etc/bash_completion.d/helm
~~~





# helm 模版语法

在helm中, 实现模版渲染功能使用的是go中的template库, 并且添加了自己对template库的扩展, 所以要学习模版语法首先要学习的就是go template的语法, 然后学习helm对template库进行了哪些扩展, 一共两个部分





## go  template

https://www.cnblogs.com/f-ck-need-u/p/10053124.html

https://www.cnblogs.com/f-ck-need-u/p/10035768.html

- 在深入语法前，必须先明确 Go 模板的核心基础 —— 两大包的定位与语法设计本质，这是理解所有语法的前提：

  | 包名            | 核心定位           | 语法支持                        | 核心差异点                      | 官方设计目标                               |
  | --------------- | ------------------ | ------------------------------- | ------------------------------- | ------------------------------------------ |
  | `text/template` | 通用文本模板引擎   | 支持所有基础语法与高级特性      | 无自动转义，输出原始文本        | 适配配置文件、日志、邮件正文等非 HTML 场景 |
  | `html/template` | 安全 HTML 模板引擎 | 完全继承`text/template`所有语法 | 上下文感知自动转义，防 XSS 注入 | 适配 Web 页面、HTML 邮件等场景             |



### hello world

下面这个案例用于渲染一个html文件

~~~xml
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Go Web</title>
	</head>
	<body>
		{{ . }}
	</body>
</html>
~~~

下面是渲染的go程序

~~~go
package main

import (
	"html/template"
	"net/http"
)

func tmpl(w http.ResponseWriter, r *http.Request) {
    // 读取一个文件, 并将其转换为Template类型的对象
	t1, err := template.ParseFiles("test.html")
	if err != nil {
		panic(err)
	}
	// 传入一个对象给这个模板, 然后执行Execute进行渲染
	// 渲染完毕之后, 将其渲染的结果写入到一个Writer中
	// 可以是http.ResponseWriter, 也可以是os.Stdout
	t1.Execute(w, "hello world")
}

func main() {
    // 启动一个http服务器
	server := http.Server{
		Addr: "127.0.0.1:8080",
	}
	http.HandleFunc("/tmpl", tmpl)
	server.ListenAndServe()
}
~~~

在上面的html文件中, 使用了一个template的语法`{{.}}`,  这里的`.`表示的就是你Execute中传入的对象

上面只是除了一个字符串到里面, 当然你也可以传入一个结构体到里面, 比如下面的案例

~~~go
type Person struct {
	Name string
	Age  int
}

func main(){
	p := Person{"longshuai",23}
	tmpl, _ := template.New("test").Parse("Name: {{.Name}}, Age: {{.Age}}")
	_ = tmpl.Execute(os.Stdout, p)
}
~~~

他会输出如下的内容:

~~~txt
Name: longshuai, Age: 23
~~~



### 注释

在template引擎中, 他是完全按照文本的格式进行替换的, 会保留所有空白, 换行. 所以千万不要对解析的内容随意的缩进, 换行

如果你想要注释掉某个内容, 不希望template引擎进行转换的话, 那么可以在`{{/* xxx  */}}`来进行注释

~~~go
func main() {
	p := Person{"longshuai", 23}
	tmpl, _ := template.New("test").Parse(
		`Name:{{/*.Name  */}}, Age: {{.Age}}`)
	_ = tmpl.Execute(os.Stdout, p)
}
~~~

上面的代码会出现如下的内容

~~~txt
Name:, Age: 23
~~~

template在渲染的时候, 会将注释的内容全部删除掉

> 千万不要协写成` Name:{{ /*.Name  */ }}`,  注释要紧紧和花括号连在一起去, 前后都是, 不能有多余的内容, 否则会报错



### 访问属性, map, 方法

对于结构体中的属性, 你可以直接通过属性名来获取他的值

~~~go
{{.User.Name}
~~~

对于Map, 你可以直接使用key来访问对应的value

~~~txt
{{.MapData.key1}}
~~~

当然如果你的key有很多的特殊符号, 那么不推荐使用上面的方式来获取对应的value, 而是使用index这个方法

~~~go
{{ index .MapData "key1" }}
~~~



对于方法, 你可以直接进行调用

~~~go
{{.Sum}}
{{.Add 1 2}}
~~~

当然你也可以进行链式调用

~~~go
{{.Field1.Key1.Method1}}
~~~





### 去除空白

上面说到, 对于要解析的内容, 不要有随意的缩进和换行, 比如

~~~go
func main() {
	p := Person{"longshuai", 23}
	tmpl, _ := template.New("test").Parse(
		`
{{/* .Name */}}
哈哈哈
`)
	_ = tmpl.Execute(os.Stdout, p)
}
~~~

会输出如下的内容

~~~shell


哈哈哈
~~~

因为template在渲染的时候, 会将注释的内容全部删除掉, 但是`{{/* .Name */}}`后面其实还有一个不可见的换行符的, 这个在渲染的时候并不是被去除掉, 所以会多一个换行, 你想要去除掉换行, 那么`-`来去除掉

- `{{- xxx }}`会去除掉这个占位符前面所有的换行符, 制表符, 空格等所有的空白
- `{{ xxx -}}`会去除掉这个占位符后面的所有的制表符, 换行符, 空格等所有的空白
- `{{- xxx -}}`会去除掉占位符前后所有的空白

比如下面的内容, 被渲染后

~~~go
func main() {
	p := Person{"longshuai", 23}
    // 渲染的时候去除掉#后面的注释
	tmpl, _ := template.New("test").Parse(
		`
{{- 23 }} < {{ 45 }} # 第一个横杆会将第一行的换行删除掉
{{ 23 }} < {{- 45 }} # 去除掉<到45之前的空白
{{ 23 -}} < {{ 45 }} # 去除23到<之前的空白
{{ 23 -}} < {{- 45 }} # 去除23到<和<到45之间的空白
    {{- 23 }}<{{ 45 -}} # 第一个横杆去除23到上一行45之间的空白, 第二个横杆去除45到下一行23之间的空白
    {{ 23 }}
`)
	_ = tmpl.Execute(os.Stdout, p)
}
~~~

会输出如下的内容

~~~txt
23 < 45
23 <45
23< 45
23<4523<4523
~~~

### 管道





### 变量

在template中, 还可以定义变量, 规则如下:

- 模板变量必须以 `$` 开头
- 通过 `{{ $变量名 := pipeline }}`创建变量并赋值
- 通过`{{ $变量名 = pipeline }}` 对已经存在的变量进行赋值
- 子作用域可定义与父作用域同名变量，会覆盖父作用域变量（局部优先）。

~~~go
package main

import (
	"os"
	"text/template"
)

type User struct {
	Name string
	Age  int
}

func main() {
	tpl := `
{{- $age := .Age -}}
{{- $name := .Name -}}
User {{ $name }} is {{ $age }} years old.
`
    // Must会接受New返回的两个参数, 如果第二个参数err不为nil, 那么会自动帮你panic, 算是一个辅助函数
	t := template.Must(template.New("demo").Parse(tpl))
	user := User{
		Name: "Alice",
		Age:  23,
	}
	_ = t.Execute(os.Stdout, user)
}
~~~

上面的内容会输出如下的内容

~~~txt
User Alice is 23 years old.
~~~



#### 变量的作用域

需要注意的是, 模板中定义的变量是有作用域的. if, range, with都会有自己的作用域

##### if的作用域

~~~go
{{ $name := .Name }} // name在当前的模板中都可用

{{ if gt .Age 18 }}
  Adult: {{ $name }} 
  {{ $x := "adult" }} // x只在if结构体内可用
{{ end }}

Name outside if: {{ $name }}
{{ $x }}  // 这里会报错
~~~



##### range的作用域

range中的变量

~~~go
type Data struct {
	Items []string
}
~~~

~~~gotemplate
Items:
{{- range $i, $v := .Items }}
  {{ $i }} => {{ $v }}
{{- end }}
~~~

上面饿代码输出如下:

~~~txt
Items:
0 => apple
1 => banana
2 => orange
~~~

其中`$i`是索引,  `$v`表示迭代的元素, `.`表示当前迭代的元素, 也就是`$v`



因为在range的作用域中, `.`已经变成了当前迭代的元素, 所有如果你想要获取外层的`.`, 那么需要先将他赋值给其他的变量

~~~go
{{ $root := . }}

{{ range .Items }}
  Item: {{ . }}, User: {{ $root.Name }}
{{ end }}
~~~



##### with作用域

with的作用是开启一个新的作用域, 然后将某个变量赋值给这个作用域中的`.`

~~~go
{{ with .User }}
  Name: {{ .Name }}
  Age:  {{ .Age }}
{{ end }}

// 等效于

{{ $u := .User }}
Name: {{ $u.Name }}
Age:  {{ $u.Age }}
~~~



##### 全局的变量

有一个特殊的变量`$`,  他代表当前模版的顶层作用域对象, 他在任何的作用范围内都是不变的, 他的主要作用是防止在 `range / with` 中丢失上下文。

比如下面的代码

~~~gotemplate
{{ range .Containers }}
image: {{ .Image }}
namespace: {{ $.Release.Namespace }}
{{ end }}
~~~

当然$这个变量在内嵌模版中还是各有不同的,  他表示的是各个模版中的顶级对象, 所以在不同的内嵌模版中是不同的





### 结构控制

#### if

在go template中, 有如下几种形式的if

~~~go
// if
{{ if CONDITION }}
  ...
{{ end }}

// if else
{{ if CONDITION }}
Enabled
{{ else }}
Disabled
{{ end }}

// if else if else
{{ if CONDITION }}
Senior
{{ else if CONDITION1 }}
Adult
{{ else }}
Minor
{{ end }}
~~~

如果if后面接的是一个变量, 比如下面这种形式

~~~go
{{ if .XXX }}
Name: {{ .XXX }}
{{ end }}
~~~

那么

| 值             | 结果  |
| -------------- | ----- |
| `""`           | false |
| `0`            | false |
| `nil`          | false |
| 空 slice / map | false |
| 非空           | true  |

> 特别需要注意的是, if不会改变`.`的值



##### if中的比较

如果你要在if中比较数值的大小, 那么需要使用如下的方式, 而不是直接使用大于号和小于号

~~~go
{{ if gt .Age 18 }}
Adult
{{ end }}
~~~

常见的比较函数

| 函数 | 含义     |
| ---- | -------- |
| `eq` | 等于     |
| `ne` | 不等于   |
| `gt` | 大于     |
| `ge` | 大于等于 |
| `lt` | 小于     |
| `le` | 小于等于 |

##### if中的逻辑判断

如果你要在if中进行逻辑判断, 那么可以参考如下的形式

and

~~~gotemplate
{{ if and .Enabled (gt .Age 18) }}
Adult and enabled
{{ end }}
~~~

or

~~~gotemplate
{{ if or (eq .Env "test") (eq .Env "dev") }}
Non-prod
{{ end }}
~~~

not

~~~gotemplate
{{ if not .Disabled }}
Active
{{ end }}
~~~

##### if和去除空白

在使用if-end的时候, 特别要注意的是, if和end行中的换行都会被保留, 比如

~~~gotemplate
{{ if not .Disabled }}
Active
{{ end }}
~~~

在被渲染之后是这个样子

~~~txt
Active

~~~

因为if行和end行中的换行被保留了下来, 所以推荐的写法是, 当然具体情况取决于你想要的渲染之后的内容

~~~gotemplate
{{- if not .Disabled -}}
Active
{{- end -}}
~~~

或者

~~~gotemplate
{{- if not .Disabled }}
Active
{{- end }}
~~~



#### range

range用于便利slice和map, 他主要有如下的三种形式

~~~gotemplate
{{ range .Items }}
  {{ . }} // .表示当前迭代的元素, 对于slice他是当前迭代的元素, 对于map, 他是value
{{ end }}
~~~

~~~gotemplate
// 对于slice, i是index, v是当前迭代的元素, .也是迭代的元素
// 对于map, i是key, v是value, .也是value
{{ range $i, $v := .Items }}
  {{ $i }} => {{ $v }} 
{{ end }}

// 你也可以只赋值一个变量, 这样直接获取到对应的元素值
{{ range $val := . -}}
  {{ $val }}
{{ end -}}
~~~

~~~~gotemplate
// range-else, 如果Items的length为0, 那么不会进入range循环, 而是直接进去else中, 否则会进行循环
{{ range .Items }}
  Item: {{ . }}
{{ else }}
  No items
{{ end }}
~~~~

需要注意的是

- range支持slice, array, map, channel

  **但是在生产中, 千万不要使用range来迭代chanel, 有卡死的风险**

  ~~~go
  ch := make(chan int)
  go func() {
      ch <- 1
      ch <- 2
      ch <- 3
      close(ch)
  }()
  tpl := `{{ range . }}{{ . }} {{ end }}`
  template.Must(template.New("t").Parse(tpl)).
      Execute(os.Stdout, ch)
  ~~~

  比如上面的代码, 如果你忘记了close通道, 那么在渲染的时候, Execute会一直卡着

- **如果range的对象是nil, 那么会直接进入else中, 或者跳过**

- **range在便利map的时候是无需的**

- range会将`.`变为当前迭代的元素, 如果你想要获取到原始的上下文, 那么需要提前变量赋值

  ~~~gotemplate
  {{ $root := . }}
  
  {{ range $k, $v := .Items }}
  Key: {{ $k }}
  Value: {{ $v }}
  Title: {{ $root.Title }}
  {{ end }}
  ~~~

- 你不能在range中修改变量, 因为变量是只读的

  ~~~gotemplate
  {{ $sum := 0 }}
  {{ range .Nums }}
    {{ $sum = add $sum . }}   ❌ 不允许
  {{ end }}
  ~~~

  

#####  range和去除空白

在使用range的时候, 一定要小心空白, 比如我们有如下的代码

~~~go
package main

import (
	"os"
	"text/template"
)

func main() {
	data := map[string]any{
		"Title": "Fruits",
		"Items": []string{"apple", "banana", "orange"},
	}

	tpl := `Items:
{{ range .Items }}
----------
- {{ . }}
{{ end }}
End
`
	template.Must(template.New("demo").Parse(tpl)).Execute(os.Stdout, data)
}
~~~

他在渲染之后会输出如下的代码

~~~txt
Items:

----------
- apple

----------
- banana

----------
- orange

End

~~~

为什么会输出很多的空行, 你要把这个模版中的换行都加上就明白了

~~~gotemplate
Items:\n{{ range .Items }}\n----------\n- {{ . }}\n{{ end }}\nEnd\n
~~~

当模版开始渲染的时候, 首先会输出

~~~txt
Items:\n
~~~

然后在range循环中, 一直在循环输出的是如下的内容

~~~gotemplate
\n----------\n- {{ . }}\n
~~~

并且在渲染完了之后还会输出

~~~gotemplate
\nEnd\n
~~~

所以结果就是

~~~txt
Items:\n\n----------\n- apple\n\n----------\n- banana\n\n----------\n- orange\n\nEnd\n
~~~

转换之后就是

~~~txt
Items:

----------
- apple

----------
- banana

----------
- orange

End

~~~

你需要记住, range循环输出的是代码块, 而不是行

如果你想要消除range中换行带来的麻烦, 推荐使用下面的格式

~~~go
	tpl := `Items:
{{- range .Items }}
- {{ . }}
{{- end }}
End
`
~~~

渲染之后他会输出如下的内容, 可以成功的消除掉换行带来的麻烦

~~~gotemplate
Items:
- apple
- banana
- orange
End

~~~

不推荐使用右消除来消除换行, 因为对于占位符前面的内容, 是可以预测的, 所以使用左消除来消除前面的内容, 但是对于后面的内容是很难进行预测的


##### break和continue

在go1.18开始, `text/template`和`html/template`中的range都添加了对`{{ break }}`和`{{ continer }}`的支持

比如我们有如下的案例: 通过range迭代一个字符串列表, 如果碰到了"skip"就跳过, 如果碰到了"stop"就停止循环

~~~gotemplate
{{ $list := slice "foo" "skip" "bar" "stop" "baz" }}
{{ range $list }}
  {{ if eq . "skip" }}
    {{ continue }}
  {{ end }}
  {{ if eq . "stop" }}
    {{ break }}
  {{ end }}
  <p>{{ . }}</p>
{{ end }}
~~~



#### with

with 用来 判断一个值是否“非空/非零”

- 如果是，就 临时把 .（当前上下文）切换成这个值。
- 如果是空或者零的话, 那么就跳过

可以理解为 `if + 改变 . 的作用域 `

> if不会改变`.`的值

with会将如下的值认为是空或者零

| 类型                | 空值       |
| ------------------- | ---------- |
| bool                | `false`    |
| string              | `""`       |
| int / float         | `0`        |
| slice / array       | `len == 0` |
| map                 | `len == 0` |
| pointer / interface | `nil`      |



基本语法:

~~~gotemplate
{{ with PIPELINE }}
  ...
{{ end }}


// 如果pipeline为空值("", 0, false, nil, length为0的array, slice, map), 那么执行else中的代码
{{ with PIPELINE }}
  ...
{{ else }}
  ...
{{ end }}

// with还可以进行变量绑定, 但是有点多此一举, 比较可以直接实用`.`
{{ with $u := .User }}
Name: {{ $u.Name }}
{{ end }}
~~~



with特别适合输出可选的字段, 有就输出, 没有就算了

~~~gotemplate
// 如果.Annotation不为空值, 那么就输出, 否则就算了
{{ with .Annotations }}
annotations:
{{ toYaml . | indent 2 }}
{{ end }}
~~~

with-else的用法

~~~gotemplate
{{ with .User }}
Hello {{ .Name }}
{{ else }}
No user
{{ end }}
~~~



##### with和空白

在使用with的过程中, 也会产生多余的空白, 如果你想要消除空白, 推荐如下的写法

~~~gotemplate
{{- with .Annotations }}
annotations:
{{ toYaml . | indent 2 }}
{{- end }}
~~~




### 管道

gotemplate中的管道与linux中的管道的概念差不多,  **通过`|`将多个命令连接起来,  前一个命令的结果会传递给下一个命令的之后一个参数**

~~~txt
PIPELINE | COMMAND1 | COMMAND2 | ...
~~~

比如下面的案例

~~~gotemplate
{{ .Title | upper }}
~~~

他实际上就等效于`upper (.Title)`

比如下面的案例

~~~gotemplate
{{ .Title | trim | upper }}
~~~

他就等效于`upper ( trim ( .Title ))`

### 函数

template中定义了一些内置函数, 也支持自定义函数

#### 内置函数

go template中的内置函数主要分为如下的几类:

1. 逻辑判断
2. 比较函数
3. 获取值类
4. 输出与调试
5. 转义和格式化
6. 索引与属性访问
7. 类型判断

##### 逻辑判断

and

- 他可以连接任意个参数
- **从左到右, 只要遇到了第一个空值(false, 0, "", nil, len==0的slice/map), 那么会立刻返回**
- **如果都不是空值, 那么返回最后一个参数**

~~~gotemplate
{{ if and .A .B .C }}
~~~

如下代码会返回ok

```gotemplate
{{ and true 1 "ok" }}
```

**and不仅可以做逻辑运算, 还可以做`安全访问器`**

~~~gotemplate
{{ if and .User .User.Name }}
Hello {{ .User.Name }}
{{ end }}
~~~

**and还可以进行变量赋值**

~~~txt
{{ $v := and .A .B .C }}
~~~







or

- 他可以连接任意个参数
- 重做到右, 只要遇到了第一个非空的值, 那么就会立刻返回

~~~txt
{{ if or .A .B .C }}
~~~

or常常用来设置默认值, 比如

~~~gotemplate
{{ or .Values.name "default-name" }}
~~~





not

not用来取反

~~~gotemplate
{{ if not .Enabled }}
~~~


##### 比较函数

go template中没有`==, !=, >`这种运算符,  他使用eq, ne, lt, gt, le, ge

~~~gotemplate
{{ if eq .Env "prod" }}
{{ if ne .Env "test" }}
{{ if gt .Replicas 3 }}
~~~

这些比较不仅可以比较两个值, 还可以进行多值比较

~~~gotemplate
{{ if eq .Env "prod" "staging" }}
~~~

上面等效于`.Env == "prod" || .Env == "staging"`

##### 获取长度

###### len

len函数主要用于获取string, slice, array, map中元素的个数

~~~shell
.Env == "prod" || .Env == "staging"
~~~

> len如果接收到的是nil, 那么会panic



##### 索引和属性访问

###### index

index主要用于获取array, slice, map中的value的

~~~gotemplate
{{ index .Map "key" }}
{{ index .List 0 }}
~~~



###### slice

这个函数主要用于对slice进行切片

~~~gotemplate
{{ slice .List 1 3 }}  // 等效于.List[1:3]
~~~



##### 输出与调试

print/ printf/println他们分别等效于fmt中的Sprint, Sprintf, Sprintln



print可以接受任意个参数, 并将他们全部打印出来

~~~gotemplate
{{ print "a" "b" }}
{{ printf "%s-%d" .Name .Age }}
~~~

**如果你不知道`.`中到底与什么结构, 那么你可以通过如下的代码将`.`的结构完全的打印出来**

~~~shell
{{ printf "%#v" . }}
~~~



**printf还常常和管道一起使用**, 比如

~~~gotemplate
{{ .Name | printf "%s" }}
{{ .Name | printf "user=%s" }}
{{ .Age | printf "%s is %d years old" .Name }}
{{ .Name | upper | printf "USER=%s" }}
~~~

**printf还可以进行变量赋值**

~~~gotemplate
{{- $msg := .Name | printf "hello %s" }}
{{- $msg }}
~~~



printf还可以查看某个变量的类型

~~~shell
{{ printf "%T" .Value }}
~~~


##### 转义相关

这些函数主要存在于`text/template`中, 但是主要是给`html/template`使用的, 他们在yaml/heml中几乎不用

- html
- js
- urlquery

~~~txt
{{ .Value | html }}
~~~



##### 函数调用

如果你知道某个变量是一个函数, 那么你可以通过call函数对他进行调用

~~~shell
// 如果.Func是一个函数
{{ call .Func "arg" }}
~~~



#### 自定义函数

在实际开发中，仅仅是这些函数是很难满足我们的需求。此时，我们希望能够传入自定义函数，在我们编写模板的时候可以使用自定义的函数。

我们引入一个需求: 希望将传入的str可以转为小写。

~~~go
var md = `
result: {{ . | lower }}
`

func Lower(str string) string {
	return strings.ToLower(str)
}

func main() {
	tpl := template.Must(template.New("demo").Funcs(map[string]any{
		"lower": Lower,
	}).Parse(md))
	tpl.Execute(os.Stdout, "HELLO FOSHAN")
}
~~~

上面代码会输出

~~~txt

result: hello foshan
~~~

我们通过调用Funcs，传入functionName : function的map。

执行模板时，函数从两个函数map中查找：首先是模板函数map，然后是全局函数map。

**方法必须有一到两个返回值，如果是两个，那么第二个一定是error接口类型**

> Funcs必须在解析parse前调用。如果模板已经调用Parse了，再调用Funcs，template并不知道该函数应该如何映射。





#### 函数和控制结构一起使用

1. if+内置函数

   ~~~gotemplate
   {{ if and (gt (len .Items) 0) .Enabled }}
   ~~~

   ~~~gotemplate
   {{- if and .Values.enabled (eq .Values.env "prod") }}
   replicas: {{ or .Values.replicas 3 }}
   {{- end }}
   ~~~

   

2. with + index

   ~~~gotemplate
   {{ with index .Config "db" }}
   Host: {{ .host }}
   {{ end }}
   ~~~

3. range + len

   ~~~gotemplate
   {{ if gt (len .Items) 0 }}
   {{ range .Items }}
   - {{ . }}
   {{ end }}
   {{ end }}
   ~~~


### 嵌套模版

在 Go 的 `text/template` / `html/template` 里，define 和 template 是一对配合使用的关键字，主要用于 模板拆分、复用和组合，非常常见于 Helm、Kubernetes YAML、配置生成 等场景。

- define用于定义一个命名的子模版, 类似于定义一个函数
- template用于在当前的模版中, 执行某个已经定义的模版, 类似于调用函数

> 强烈推荐你将define定义的模版, 放在文件的头部, 虽然不是必须的

~~~gotemplate
{{ define "header" }}
<h1>{{ .Title }}</h1>
{{ end }}
<body>
  {{ template "header" . }}
</body>
~~~

上面的代码中, 定义了一个header模版, 在定义他的时候, 他什么都不会输出, 然后再body的内部调用了他, 并传入当前的上下文对象`.`

上面的模版会输出如下的内容

~~~gotemplate

<body>
  
<h1>Fruits</h1>

</body>

~~~



> 实际上我们在执行template.New("111").Parse(`xxx`)的时候, 就是创建了一个名为111的内嵌模版, 然后传入这个模版对应的内容





#### 嵌套模版的上下文

需要注意的是, 嵌套模版并不会使用当前整个模版中的上下文, 而是需要你显示的传入一个字, 然后他会将这个值作为上下文对象

~~~txt
{{ define "user" }}
Name: {{ .Name }}
Age: {{ .Age }}
{{ end }}

{{ template "user" .User }}
~~~

上面的内容中, 传入了一个User对象给user模版,  作为他的上下文对象`.`



当然如果你的模版不需要上下文中的内容的话, 那么也可以不传递东西给他, 相当于nil

~~~gotemplate
{{ define "user" }}
Name: zhangsan
Age: 18
{{ end }}

// 这里相当于传入了 nil
{{ template "user" }}
~~~




#### 嵌套模版与去除空白

在使用嵌套模版的时候, 特别要注意换行, 比如如下的代码

~~~go
func main() {
	data := map[string]any{
		"Title": "Fruits",
		"Items": []string{"apple", "banana", "orange"},
	}

	tpl := `{{ define "header" }}
<h1>{{ index . "Title" }}</h1>
{{ end }}
----------------
<body>
  {{ template "header" . }}
</body>
`
	template.Must(template.New("demo").Parse(tpl)).Execute(os.Stdout, data)
}
~~~

他的输出内容是

~~~txt

----------------
<body>
  
<h1>Fruits</h1>

</body>

~~~

这是因为

- end后面有一个换行, 所有第一行是空行
- header在被渲染之后, 实际上输出的是`\n<h1>Fruits</h1>\n`
- 在`{{ template "header" . }}`后面还有一个换行
- \</body>后面还有一个换行

所以实际的输出内容是

~~~txt
\n----------------\n<body>\n  \n<h1>Fruits</h1>\n\n</body>\n
~~~

解析之后就是

~~~txt

----------------
<body>
  
<h1>Fruits</h1>

</body>

~~~



如果你想要消除换行, 推荐的做法是如下

~~~gotemplate
func main() {
	data := map[string]any{
		"Title": "Fruits",
		"Items": []string{"apple", "banana", "orange"},
	}

	tpl := `{{- define "header" -}}
<h1>{{ index . "Title" }}</h1>
{{- end -}}
----------------
<body>
  {{ template "header" . }}
</body>
`
	template.Must(template.New("demo").Parse(tpl)).Execute(os.Stdout, data)
}
~~~

他的输出内容是

~~~txt
----------------
<body>
  <h1>Fruits</h1>
</body>

~~~

另外一种做法是如下, 在template标签中添加横杆, 消除渲染之后模版前后的空格和空行

~~~gotemplate
{{ define "header" }}
<h1>{{ index . "Title" }}</h1>
{{ end -}}
----------------
<body>
  {{- template "header" . -}}
</body>
~~~


#### 嵌套模版与多文件

除了在一个模版的内部定义嵌套模版,  你也可以将模版放在另外一个文件里面, 比如下面有如下的文件

t1.html

~~~html
<div style="background-color: yellow;">
	This is t2.html<br/>
	This is the value of the dot in t2.html - [{{ . }}]
</div>
~~~

t2.html

~~~xml
{{ define "t2-1" }}
<h3>t2-1</h3>
{{end}}
{{ define "t2-2" }}
<h2>t2-2</h2>
{{end}}
~~~

t3.html

~~~html
<div>
--------<br>
{{ template "t1.html" }}
--------
{{ template "t2-1" }}
--------
{{ template "t2-2" }}
--------<br>
</div>
~~~

你可以通过如下的代码来进行渲染

~~~go
package main

import (
	"os"
	"text/template"
)

func main() {
	tmpl := template.Must(template.ParseFiles("t3.html", "t2.html", "t1.html"))
	tmpl.Execute(os.Stdout, "hello world")
}
~~~

上面的ParseFiles会

- 返回第一个文件的模版对象,  也就是说tmpl代表的是t3.html文件, Execute的时候也是渲染t3.html

- 其他的文件会根据文件名转换为对应的template, 放在一个TemplateSet中, 

  你可以在这些文件的其他地方调用这个模版

- 如果其他的文件中还有内嵌的template, 也会提取出来, 放在这个TemplateSet中
- 后面传入的文件可以定义同名的模版, 进行覆盖
- 文件解析的顺序很重要,  ParseFiles按照顺序来解析文件, 先解析的文件会先注册模版, 后解析的文件同名模版会覆盖之前的


#### block块

在上面的代码中,  如果你使用了一个没有定义的template, 那么在执行Execute的时候, 会报错

比如上面的代码中, 如果你删除掉t2中的t2-1模版, 那么在执行Execute方法的时候, 会返回一个panic 如下

~~~txt
panic: template: t3.html:5:12: executing "t3.html" at <{{template "t2-1" .}}>: template "t2-1" not defined

goroutine 1 [running]:
main.main()
	C:/Users/sys49482/Desktop/temalate/main.go:12 +0xc5
~~~



block块的作用就是提供了一个安全的**可选的**内嵌模版

比如如下的代码

~~~go
// base.tmpl
<html>
<body>

{{ block "content" . }}
默认内容
{{ end }}

</body>
</html>

// page.tmpl
{{ define "content" }}
<h1>Hello World</h1>
{{ end }}

// main.go
t := template.Must(template.ParseFiles("base.tmpl", "page.tmpl"))
t.Execute(os.Stdout, nil)
~~~

对于`{{ block "content" . }}`来说

- 如果content模版存在, 那么他就等效于`{{ template "content" . }}`
- 如果content模版不存在, 那么他就会输出`\n默认内容\n`, 而不是报错

还有几点需要注意的是:

- block中指定的模版名最好唯一

- 如果重名, 那么后解析的模版会覆盖block中的内容

  ~~~go
  ParseFiles("base.tmpl", "override.tmpl")
  ~~~

  `override.tmpl` 中 `define "x"` 会覆盖 base 中的 `block "x"`,  所以block中的顺序很重要



### html/template的上下文感知

对于html/template包，有一个很好用的功能：上下文感知。text/template没有该功能。

上下文感知具体指的是根据所处环境css、js、html、url的path、url的query，自动进行不同格式的转义。

例如，一个handler函数的代码如下：

````go
func process(w http.ResponseWriter, r *http.Request) {
	t, _ := template.ParseFiles("test.html")
	content := `I asked: <i>"What's up?"</i>`
	t.Execute(w, content)
}
````

上面content是Execute的第二个参数，它的内容是包含了特殊符号的字符串。

下面是test.html文件的内容：

````html
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Go Web Programming</title>
	</head>
	<body>
		<div>{{ . }}</div>
		<div>Path</div>
		<div>Query</div>
		<div><a onclick="f('{{ . }}')">Onclick</a></div>
	</body>
</html>
````

上面test.html中有4个不同的环境，分别是html环境、url的path环境、url的query环境以及js环境。虽然对象都是{{.}}，但解析执行后的值是不一样的。如果使用curl获取源代码，结果将如下：

````html
<html>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Go Web Programming</title>
</head>


<body>
	<div>I asked: &lt;i&gt;&#34;What&#39;s up?&#34;&lt;/i&gt;</div>
	<div>
		<a href="/I%20asked:%20%3ci%3e%22What%27s%20up?%22%3c/i%3e">
			Path
		</a>
	</div>
	<div>
		<a href="/?q=I%20asked%3a%20%3ci%3e%22What%27s%20up%3f%22%3c%2fi%3e">
			Query
		</a>
	</div>
	<div>
		<a onclick="f('I asked: \x3ci\x3e\x22What\x27s up?\x22\x3c\/i\x3e')">
			Onclick
		</a>
	</div>
</body>

</html>
````


##### 不转义
上下文感知的自动转义能让程序更加安全，比如防止XSS攻击(例如在表单中输入带有<script>...</script>的内容并提交，会使得用户提交的这部分script被执行)。

如果确实不想转义，可以进行类型转换。

````txt
type CSS
type HTML
type JS
type URL
````

转换成指定个时候，字符都将是字面意义。例如：

````go
func process(w http.ResponseWriter, r *http.Request) {
	t, _ := template.ParseFiles("tmpl.html")
	t.Execute(w, template.HTML(r.FormValue("comment")))
}
````





## Template模块中的常用函数

1. ParseFiles

   这个函数用于解析多个文件, 并返回第一个文件对应的Template对象

   ~~~go
   func ParseFiles(filenames ...string) (*Template, error)
   ~~~

   比如如下的代码

   ~~~go
   tpl := template.ParseFiles("base.tmpl", "page.tmpl", "footer.tmpl")
   ~~~

   上面代码会按照从左到右解析所有的模版文件, 并创建一个TemplateSet

   这个方法也是Template对象的实例方法,  用于在当前的TemplateSet中重新添加多个解析文件

   ~~~go
   tpl := template.New("base.tmpl")
   tpl = template.Must(tpl.ParseFiles("templates/base.tmpl"))
   tpl = template.Must(tpl.ParseGlob("templates/*.tmpl"))
   ~~~

2. ParseGlob

   按 glob 模式一次性解析一批模板文件，组成一个模板集合（Template Set）, <font color=red>**默认按照文件名的字典序从小到大来排序的**</font>

   <font color=red>**如果你有某个文件一定要在所有的文件之前解析的话, 那么推荐使用`_`开头, 比如helm中的`_helper.tpl`**</font>

   ~~~go
   func ParseGlob(pattern string) (*Template, error)
   ~~~

   同时强烈推荐`ParseGlob`这个函数与`ExecuteTemplate`一起使用, 这样你就可以直接指定需要渲染的模版了

   ~~~go
   tpl := template.Must(
   	template.ParseGlob("templates/*.tmpl"),
   )
   // 指定需要渲染base.tmpl文件
   tpl.ExecuteTemplate(os.Stdout, "base.tmpl", data)
   ~~~

   或者你也可以使用如下的方法, 先指定要渲染的文件, 然后再解析文件

   ~~~go
   tpl := template.New("base.tmpl")
   tpl = template.Must(tpl.ParseFiles("templates/base.tmpl"))
   tpl = template.Must(tpl.ParseGlob("templates/*.tmpl"))
   ~~~

3. Parse

   Parse用于解析一个字符串, 并返回一个Template对象

   ~~~go
   func (t *Template) Parse(text string) (*Template, error)
   ~~~

   下面是他的使用案例:

   ~~~go
   tpl := template.New("hello")
   
   tpl, err := tpl.Parse("Hello, {{ .Name }}!")
   if err != nil {
       panic(err)
   }
   
   tpl.Execute(os.Stdout, map[string]string{
       "Name": "Go",
   })
   ~~~

4. ParseFS

   这个函数主要用于解析那些已经打包在二进制中的文件

   ~~~go
   import (
   	"embed"
   	"log"
   	"os"
   	"text/template"
   )
   
   // 1️⃣ 声明 embed.FS
   //go:embed templates/*.tmpl
   var tmplFS embed.FS
   
   func main() {
   	// 2️⃣ 创建模板对象
   	tpl := template.New("all")
   
   	// 3️⃣ 从 embed.FS 解析所有模板
   	tpl, err := tpl.ParseFS(tmplFS, "templates/*.tmpl")
   	if err != nil {
   		log.Fatalf("ParseFS error: %v", err)
   	}
   }
   ~~~

5. Must函数

   这个函数是一个helper函数, 他的代码如下

   ~~~go
   func Must(t *Template, err error) *Template {
   	if err != nil {
   		panic(err)
   	}
   	return t
   }
   ~~~

   如果第二个参数不是nil, 那么就panic, 用法如下面的代码

   ~~~go
   func main() {
   	tmpl := template.Must(template.ParseFiles("t3.html", "t2.html", "t1.html"))
   	err := tmpl.Execute(os.Stdout, "hello world")
   	if err != nil {
   		panic(err)
   	}
   }
   ~~~

6. Execute方法

   用于执行模版的渲染

   ~~~go
   func (t *Template) Execute(wr io.Writer, data any) error
   ~~~

7. ExecuteTemplate方法

   用于执行模版的渲染, 并指定要渲染的文件

   ~~~go
   func (t *Template) Execute(wr io.Writer, data any) error
   ~~~

   > 特别需要注意Execute和ExecuteTemplate方法,  这两个方法是一边渲染一边输出的, 而不是渲染完毕才输出, 所以你如果渲染到一半, 发现使用了一个不存在的template内嵌模版,  那么渲染会停止, 并返回一个error, **但是已经有一部分内容写入到了Write中**
   >
   > 同时如果多个Execute方法共享一个Writer的话, 那么并发执行会导致输出交错, 混乱

6. Delims

   默认情况下, template模块使用`{{ }}`来作为包裹变量,  但是你也可以使用这个方法来指定, 他会返回同一个Template对象, 所以你可以进行链式调用

   这个方法常常用于规避与其他的模版的语法冲突, 比如vue里面也是通过`{{ message }}`进行双向绑定的

   ~~~go
   func (t *Template) Delims(left, right string) *Template
   ~~~

   使用案例如下

   ~~~go
   tpl := template.New("t").
   	Delims("[[", "]]")
   
   tpl, _ = tpl.Parse(`
   Hello [[ .Name ]]
   Today is [[ .Day ]]
   `)
   
   tpl.Execute(os.Stdout, map[string]string{
   	"Name": "Go",
   	"Day":  "Monday",
   })
   ~~~

7. Clone方法

   clone方法会返回模版的副本, 包括所有关联的模版, 在clone的副本上添加模板是不会影响原始模板的。**所以我们可以将其用于公共模板，通过clone获取不同的副本。**

   ```go
   func (t *Template) Clone() (*Template, error) 
   ```

   下面是他的使用案例

   ~~~~go
   base := loadBaseTemplates() // 基础的模版
   
   admin, _ := base.Clone() // 生成后续不同的变种
   admin.ParseFiles("admin.tmpl")
   
   user, _ := base.Clone()
   user.ParseFiles("user.tmpl")
   ~~~~

8. New方法

   New方法是创建一个新的`*Template`对象, 作为模版集合(Template Set)的起点

   - 此时模版没有任何内容, 只有一个名字
   - 后续所有的Parse, ParseFiles, ParseGlob都是在这个集合上追加模版

   ~~~go
   func New(name string) *template.Template
   ~~~

   使用案例如下

   ~~~go
   tpl := template.New("hello")
   
   tpl.Parse("Hello {{ .Name }}")
   
   tpl.Execute(os.Stdout, map[string]string{
   	"Name": "Go",
   })
   ~~~

   New的核心作用是: **如果你要解析多个文件的话, 那么你可以先通过New方法来指定你最终需要渲染的文件, 然后再渲染的时候, 直接调用Execute方法, 而不是ExecuteTemplate**

   ~~~go
   tpl := template.New("base.tmpl")
   
   tpl.ParseFiles("base.tmpl")
   tpl.ParseGlob("partials/*.tmpl")
   tpl.ParseGlob("pages/*.tmpl")
   ~~~

   New方法也可以直接在Template对象上面调用

   ~~~go
   tmpl, _ := template.New("page").Parse(`{{ template "header" .Header }}{{ template "footer" .Footer }}`)
   tmplHeader, _ := tmpl.New("header").Parse("页头内容:{{ . }}")
   tmplFooter, _ := tmpl.New("footer").Parse("页脚内容:{{ . }}")
   
   tmpl.Execute(os.Stdout, Params{Header: "header", Footer: "footer"}) // => 页头内容:header页脚内容:footer
   ~~~

   

9. Name方法

   Name方法输出当前Template中的主模版的名字是什么, 也就是调用Execute的时候, 输出的模版的名字

   ~~~go
   tpl := template.New("base.tmpl")
   tpl.ParseFiles("base.tmpl", "page.tmpl")
   
   fmt.Println(tpl.Name())
   tpl.Execute(w, data)
   ~~~

10. DefinedTemplates方法

    这个方法返回Template对象中已经解析了哪些模版了, 包括block定义的, define定义的

    主要用于debug使用, 排除是不是少了模版

    ~~~go
    func (t *Template) DefinedTemplates() string
    ~~~

    案例如下

    ~~~go
    tpl := template.New("base.tmpl")
    tpl.ParseFiles("base.tmpl", "page.tmpl", "footer.tmpl")
    
    // ; defined templates are: "base.tmpl", "page.tmpl", "footer.tmpl"
    fmt.Println(tpl.DefinedTemplates())
    ~~~

11. Templates函数

    这个函数主要用于获取所有已经解析出来的Template对象, 相较于`DefinedTemplates`更偏向于编程使用

    ~~~go
    func (t *Template) Templates() []*Template
    ~~~

    他的使用案例如下:

    ~~~go
    for _, t := range tpl.Templates() {
    	fmt.Println(t.Name())
    }
    ~~~

12. Lookup函数

    这个方法用于查找指定名字的模版, 并返回对应的Template对象

    ~~~go
    func (t *Template) Lookup(name string) *Template
    ~~~

    使用案例如下:

    ~~~go
    if t := tpl.Lookup("footer"); t != nil {
    	t.Execute(w, data)
    }
    ~~~

    

13. Funcs 方法

    这个方法用于注册自定义的函数

    - **自定义函数对于参数个数和类型没有要求, 但是返回值只能有1/2个, 如果是两个, 那么第一个返回值的类型随意, 模版会自动格式化, 但是最后一个只能是error类型**
    - **必须在Parse方法之前调用**
    - 这个方法可以多次调用, 多次注册函数
    - 如果注册了重名的函数, 那么后注册的会覆盖前面注册的
    - 如果你要Clone模版, 那么注册完自定义函数之后Clone
    - 如果你有一批函数需要注册,  推荐将他们分类, 每一类调用一个Funcs方法

    ~~~go
    func (t *Template) Funcs(FuncMap) *Template
    ~~~

    下面是使用案例

    ~~~go
    package main
    
    import (
    	"os"
    	"strings"
    	"text/template"
    	"time"
    )
    
    func main() {
    	// 1️⃣ 创建模板（此时是空模板）
    	tpl := template.New("base.tmpl")
    
    	// 2️⃣ 第一次 Funcs：基础字符串函数
    	tpl.Funcs(template.FuncMap{
    		"upper": strings.ToUpper,
    		"lower": strings.ToLower,
    	})
    
    	// 3️⃣ 第二次 Funcs：时间相关函数
    	tpl.Funcs(template.FuncMap{
    		"now": func() string {
    			return time.Now().Format("2006-01-02 15:04:05")
    		},
    	})
    
    	// 4️⃣ 第三次 Funcs：业务函数（覆盖 upper）
    	tpl.Funcs(template.FuncMap{
    		"upper": func(s string) string {
    			return ">> " + strings.ToUpper(s) + " <<"
    		},
    	})
    
    	// ⚠ 所有 Funcs 必须在 Parse 之前
    	template.Must(tpl.Parse(`
    Name: {{ upper .Name }}
    Lower: {{ lower .Name }}
    Time: {{ now }}
    `))
    
    	// 5️⃣ 执行模板
    	tpl.Execute(os.Stdout, map[string]string{
    		"Name": "Go Template",
    	})
    }
    ~~~

14. Option

    这个用于改变使用模版的时候的行为

    ~~~go
    func (t *Template) Option(opt ...string) *Template
    ~~~

    - 可以传入多个字符串作为Option
    - 也可以多次调用来传入Option
    - 返回的还是原来的Template对象, 所有可以进行链式调用
    - 必须在Parse之间调用

    **实际上你只要掌握`missingKey`这个Option就够了, 这个用于指定如果map中指定的value的时候, 会怎么样(只能针对map, 不能针对struct )**

    **helm中使用的是error这个值**

    ~~~go
    // 可选的有
    //   default: 如果没有指定的key, 那么输出一个 <no value>
    //   zero: 返回对应类型的零("", 0, nil)
    //   error: 直接渲染失败
    tpl := template.New("t").Option("missingkey=default")
    ~~~

    比如下面的案例

    ~~~go
    data := map[string]string{
        "User": "Tom",
    }
    
    tplText := `Hello {{ .Name }}`
    
    // Hello 
    // tpl := template.New("t").Option("missingkey=zero")
    
    // Hello panic: template: t:1:9: executing "t" at <.Name>: map has no entry for key "Name"
    // tpl := template.New("t").Option("missingkey=error")
    
    // Hello <no value>
    tpl := template.New("t")
    tpl.Parse(tplText)
    tpl.Execute(os.Stdout, data)
    ~~~

15. AndParseTree

    这个函数是一个比较底层的函数,  也使用的比较少, 用于将一个TemplateSet中的模版, 添加到另外一个TemplateSet中, 可以实现模版的动态组合

    ~~~go
    func (t *Template) AddParseTree(name string, tree *parse.Tree) (*Template, error)
    ~~~

    案例如下

    ~~~go
    tpl1 := template.Must(template.New("base").Parse(`{{ define "header" }}<h1>{{ .Title }}</h1>{{ end }}`))
    tpl2 := template.Must(template.New("page").Parse(`{{ define "page" }}{{ template "header" . }}Body{{ end }}`))
    
    // 把 tpl1 的 "header" 加到 tpl2
    tpl2.AddParseTree("header", tpl1.Lookup("header").Tree)
    
    tpl2.ExecuteTemplate(os.Stdout, "page", map[string]string{"Title": "Hello"})
    ~~~




## Helm 扩展

### 内置对象

在helm的template文件中, 你可以在当前上下文对象`.`中获取到如下的内置对象

~~~go
.Values
.Release
.Chart
.Capabilities
.Files
.Template
~~~



#### .Values

这个对象中保存的是`values.yaml` + `-f  xx_values.yaml` + `--set aa=bb`合并的后的最终结果

这些内容的优先级如下:

~~~txt
values.yaml
charts/*/values.yaml
-f custom.yaml
--set key=value
~~~

他的使用案例如下:

~~~yaml
# values.yaml
replicaCount: 3
image:
  repository: nginx
  tag: "1.25"
  
# template/a.yaml
replicas: {{ .Values.replicaCount }}
image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
~~~

强烈在使用values.yaml中的值的时候, 设置默认值, 要么报错

~~~gotemplate
{{ default 1 .Values.replicaCount }}
{{ required "image.repository must be set" .Values.image.repository }}
~~~







#### .Release

这个变量里面可以获取到当前release的一些相关信息

- Name: 这个表示当前release的名字

  ~~~gotemplate
  {{ .Release.Name }}
  ~~~

- Namespace: 这个表示当前release安装的namespace

  ~~~gotemplate
  {{ .Release.Namespace }}
  ~~~

- Revision: 表示当前安装的release的版本号,  每次upgrade的时候+1,  每次回滚的时候也会+1

  ~~~gotemplate
  {{ .Release.Revision }}
  ~~~

- IsUpgrade, IsInstall:  表示当前release是首次安装, 还是在升级

  ~~~gotemplate
  # 判断当前release在安装的时候, 是升级还是安装
  {{- if .Release.IsInstall }}
  # only on install
  {{- end }}
  ~~~

- Labels: 这是一个map, 表示当前文件中的label有哪些

  ~~~shell
  helm upgrade myapp ./mychart \
    --labels env=prod,team=platform
  ~~~

  ~~~yaml
  {{ .Release.Labels.env }}
  ~~~

- Service: 表示当前的Release是哪个service在进行安装, 在helm2的时候通常是"Tiller", 在Helm3的时候固定为了"Helm"

  这个属性几乎用不到, 除了要同时兼容Helm2和Helm3的场景

  ~~~yaml
  {{ .Release.Service }}   # Helm
  ~~~

  

#### .Chart

这个变量里面可以获取到当前chart的一些信息, 其中的信息来自于`Chart.yaml`这个文件中

~~~yaml
# Chart.yaml
apiVersion: v2
name: my-app
description: A Helm chart for Kubernetes
type: application
version: 1.2.3
appVersion: "2.0.1"
kubeVersion: ">=1.23.0" # 声明当前chart需要kubernetes的版本>=1.23.0
keywords:
  - web
  - backend
home: https://example.com
sources:
  - https://github.com/example/my-app
maintainers:
  - name: alice
    email: alice@example.com


# template/aa.yaml  
{{ .Chart.Name }} # 输出: my-app
{{ .Chart.Version }} #  输出: 1.2.3
{{ .Chart.AppVersion }} #  输出: 2.0.1
{{ .Chart.KubeVersion }} #  输出: >=1.23.0
{{ .Chart.Keywords }} # 输出: [web backend]
{{ .Chart.Type }} # 输出: application
~~~



#### .Capabilities

这个变量是Helm 模板里用于“感知集群能力”的核心内置对象。写 跨 Kubernetes 版本、跨集群可用的 Helm Chart，几乎离不开它。

.Capabilities 描述“当前 Helm 连接到的 Kubernetes 集群支持什么”

他有如下的顺序

~~~text
.Capabilities
├── KubeVersion
│   ├── Version
│   ├── Major
│   ├── Minor
│   └── GitVersion
├── APIVersions
│   └── Has
└── HelmVersion
    ├── Version
    ├── Major
    ├── Minor
    └── GitVersion
~~~



`.Capabilities.KubeVersion`主要用来表示当前k8s的集群版本

~~~gotemplate
{{ .Capabilities.KubeVersion.Version }}     // "1.28"
{{ .Capabilities.KubeVersion.Major }}       // "1"
{{ .Capabilities.KubeVersion.Minor }}       // "28"
{{ .Capabilities.KubeVersion.GitVersion }}  // "v1.28.2"
~~~

**对于版本号的判断, 千万不要使用ge来比较, 而是需要使用函数**

~~~gotemplate
# 使用semverCompare 来判断版本号
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion }}
apiVersion: networking.k8s.io/v1
{{- else }}
apiVersion: networking.k8s.io/v1beta1
{{- end }}
~~~



`.Capabilities`主要用于判断当前的k8s集群是否支持某个api

~~~gotemplate
{{- if .Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" }}
apiVersion: policy/v1
{{- else }}
apiVersion: policy/v1beta1
{{- end }}
~~~



`.Capabilities.HelmVersion`表示当前helm的版本号

~~~gotemplate
{{ .Capabilities.HelmVersion.Version }}    // "3.14.1"
{{ .Capabilities.HelmVersion.GitVersion }} // "v3.14.1"
~~~



#### .Files

这个变量可以读取Chart中的文件, 除了`template下的模版文件, Chart目录以外的文件`

假如有如下的chart目录结构

~~~text
mychart/
├── Chart.yaml
├── values.yaml
├── templates/
│   └── configmap.yaml
├── files/
│   ├── app.conf
│   └── init.sql
└── scripts/
    └── start.sh
~~~

1. `.Files.Get` 用来获取指定路径的文件, 并转换为字符串, 常常用来将文件放到模版中

   ~~~gotemplate
   data:
     app.conf: |
   {{ .Files.Get "files/app.conf" | indent 4 }}
   ~~~

2. `.Files.GetBytes`用于读取指定的文件, 并转换为自己数组, 常常用于Secret的场景, 并配合`b64enc`一起使用

   ~~~gotemplate
   data:
     cert.pem: {{ .Files.GetBytes "files/cert.pem" | b64enc }}
   ~~~

3. `.Files.Glob`用于按照glob模式匹配多个文件, 并返回一个map, key是文件的path, value是对应内容的数组, 常常用在range循环中遍历多个文件

   ~~~gotemplate
   data:
   {{- range $path, $bytes := .Files.Glob "files/*.conf" }}
     {{ base $path }}: |
   {{ $bytes | toString | indent 4 }}
   {{- end }}
   ~~~

4. `.Files.Lines`用于按行读取文本, 并返回对应的slice

   ~~~gotemplate
   {{ range .Files.Lines "files/app.conf" }}
   - {{ . }}
   {{ end }}
   ~~~

5. `.Files.AsConfig`用于就按多个文件自动转换为Configmap data结构

   ~~~gotemplate
   data:
   {{ .Files.Glob "files/*.conf" | .AsConfig | indent 2 }}
   ~~~

6. `.Files.AsSecrets`用于将多个文件转换为Secret date结构(自动base64)

   ~~~gotemplate
   data:
   {{ .Files.Glob "secrets/*" | .AsSecrets | indent 2 }}
   ~~~

   

#### .Template

可以使用他来获取到当前模版自身的一些信息, 在调试的时候有用

1. `.Template.Name`是当前模版在helm内部的完整名字

   ```gotemplate
   {{ .Template.Name }} # mychart/templates/deployment.yaml
   ```

2. `.Template.BasePath`是当前模版在chart中的路径

   ~~~gotemplate
   {{ .Template.BasePath }} # mychart/templates
   ~~~


### Sprig函数库

Sprig 函数库是 一个为 Go 模板（Go text/template 和 html/template）提供丰富辅助函数的库，主要用来弥补 Go 模板自带函数的不足。

Go 自带的模板函数非常有限，比如只有 len、print、index、eq、and、or 等基础函数，而实际开发中，经常需要更复杂的字符串处理、日期格式化、数学运算、列表操作等，这时候 Sprig 就非常有用。

在helm中集成了Sprig函数库, 所以如果你在编写helm的chart, 那么可以直接使用其中的函数

1. 字符串函数

   ~~~gotemplate
   # 转大写
   {{ "hello world" | upper }}          // 输出 "HELLO WORLD"
   
   # 转小写
   {{ "HELLO WORLD" | lower }}          // 输出 "hello world"
   
   # 首字母大写
   {{ "hello world" | title }}          // 输出 "Hello World"
   
   # 移除前后空格
   {{ "  hello  " | trim }}             // 输出 "hello"
   
   # 移除前缀
   {{ "foobar" | trimPrefix "foo" }}    // 输出 "bar"
   
   # 移除后缀
   {{ "foobar" | trimSuffix "bar" }}    // 输出 "foo"
   
   # 替换字符串
   {{ "foo bar foo" | replace "foo" "baz" -1 }} // 输出 "baz bar baz"
   
   # 判断子串
   {{ "foobar" | contains "foo" }}      // 输出 true
   
   # 判断前缀
   {{ "foobar" | hasPrefix "foo" }}     // 输出 true
   
   # 判断后缀
   {{ "foobar" | hasSuffix "bar" }}     // 输出 true
   
   # 添加双引号
   {{ "hello" | quote }}          // 输出: "hello"
   
   # 字符串拼接
   {{ cat "hello" " " "world" }}    // 输出: hello world
   
   # 按照指定的分隔符连接list
   {{ list "a" "b" "c" | join "," }}   // 输出: a,b,c
   ~~~

   

2. 日期/时间函数

   ~~~gotemplate
   {{ now }}                            // 输出当前时间，例如 2025-12-17 18:00:00 +0800 CST
   {{ now | date "2006-01-02" }}        // 输出当前日期，格式 YYYY-MM-DD，例如 2025-12-17
   {{ now | date "2006-01-02 15:04:05" }} // 输出当前时间和日期
   {{ now | dateModify "+1d" | date "2006-01-02" }} // 当前日期加一天
   ~~~

   

3. 数学函数

   ~~~gotemplate
   {{ add 3 5 }}                        // 输出 8
   {{ sub 10 4 }}                        // 输出 6
   {{ mul 2 3 }}                         // 输出 6
   {{ div 10 2 }}                        // 输出 5
   {{ ceil 3.14 }}                        // 输出 4
   {{ floor 3.99 }}                       // 输出 3
   {{ round 3.14159 2 }}                  // 输出 3.14
   {{ min 10 3 5 }}                        // 输出 3
   {{ max 10 3 5 }}                        // 输出 10
   ~~~

4. 列表/集合函数

   ~~~gotemplate
   {{ $arr := list 1 2 3 2 }} # 创建一个slice
   {{ first $arr }}                      // 输出 1
   {{ last $arr }}                       // 输出 2
   {{ sort $arr }}                       // 排序, 输出 [1 2 2 3]
   {{ uniq $arr }}                        // 去重, 输出 [1 2 3]
   {{ append $arr 4 5 }}                  // 输出 [1 2 3 2 4 5]
   {{ concat $arr (list 6 7) }}           // 输出 [1 2 3 2 6 7]
   {{ has $arr 2 }}                        // 输出 true
   
   {{ list 1 "" 2 nil 3 | compact }} // 删除零值的元素,  输出: [1 2 3]
   {{ list "b" "c" "a" | sortAlpha }} // 按照字母顺序对字符串slice进行排序
   ~~~

   

5. 字典/对象函数

   ~~~gotemplate
   {{ $m := dict "a" 1 "b" 2 }}         // 构造map
   {{ hasKey $m "a" }}                  // 输出: true
   
   {{ $m.a }}                            // 输出 1
   {{ $m.b }}                            // 输出 2
   
   {{ $n := dict "b" 3 "c" 4 }}
   {{ merge $m $n }}                     // 输出 map[a:1 b:3 c:4]
   
   
   {{ $m1 := dict "name" "a" "port" 80 }}
   {{ $m2 := dict "name" "b" "port" 81 }}
   {{ pluck "port" (list $m1 $m2) }}        // 从map/对象中,按 key 抽取同一个字段，组成一个列表, 如果某个map中没有这个key, 那么会输出<no value>  输出: [80 81]
   
   
   {{ $m := dict "a" 1 "b" 2 }}
   {{ set $m "c" 3 }} // put一个key value到map中
   
   {{ unset $m "c" }} // 删除map中的key
   
   {{ merge $a $b }} // 合并两个map
   ~~~

   

6. 条件/逻辑辅助函数

   ~~~gotemplate
   {{ "" | default "Anonymous" }}         // 三元运算符, 输出 "Anonymous"
   {{ coalesce "" nil "first non-empty" }} // 返回第一个非零值, 输出 "first non-empty"
   {{ empty "" }}                          // 判断是否为空, 输出 true
   {{ empty $arr }}                        // 判断是否length = 0, 输出 false
   ~~~

   

7. 安全/HTML 函数

   ~~~~gotemplate
   {{ "<div>Hello</div>" | htmlEscape }}   // 输出 "&lt;div&gt;Hello&lt;/div&gt;"
   {{ "alert('xss')" | jsEscape }}         // 输出 "alert(\'xss\')"
   ~~~~

   

### 模版加载/组合

#### include

虽然在go template中也提供了define和template两个关键字来实现模版的拆分和服用, 但是在helm中并不推荐使用这两个关键字来实现模版的拆分和复用

比如下面的模版

~~~gotemplate
# _helpers.tpl
{{- define "mychart.labels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
{{- end -}}

# templates/aa.yaml
{{ template "mychart.labels" . }}
~~~

如果你使用上面的模版那么会面临如下的问题:

1. 模版直接渲染在当前的问题,  如果是yaml的话没有办法进行代码块的缩进
2. 没有办法进行管道处理
3. 必须显示的传一个上下文参数



所以在helm中实现了`include`关键字, 他会渲染模版并返回对应的字符串, 这样你就可以进行二次处理了(indent, nindent)

比如如下的模版

~~~gotemplate
{{- define "mychart.name" -}}
{{ .name }}-{{ .suffix }}
{{- end -}}

{{ include "mychart.name" (dict "name" "app" "suffix" "v1") | indent 4 }}
~~~


#### tpl

tpl这个关键字可以将字符串当做模版, 然后再用当前的上下文进行渲染一次

~~~yaml
# values.yaml
message: "hello {{ .Release.Name }}"

# templates/a.yaml
{{ tpl .Values.message . }} # 获取到hello {{ .Release.Name }}字符串, 然后作为模版再次渲染
~~~



常常用在你通过`.File.Get`获取到了一个文件的内容,  然后想讲这个文件作为模版再次渲染

~~~gotemplate
data:
  config.yaml: |
{{ tpl (.Files.Get "config/config.yaml") . | nindent 4 }}
~~~







### Kubernetes/Helm语义相关的辅助函数



#### lookup

这个函数主要用于调用k8s的接口, 来查询已经存在的kubernetes资源

只有在helm3中才有这个函数, 他的使用方法如下

~~~gotemplate
lookup apiVersion kind namespace name
~~~

下面查询一个configmap

~~~gotemplate
# 查询my-config这个cm是否存在, 如果存在返回一个map, 如果不存在返回nil
{{- $cm := lookup "v1" "ConfigMap" .Release.Namespace "my-config" }}
{{- if $cm }}
data:
  existing: "true"
{{- end }}
~~~

查询整个namesapce中的cm

~~~gotemplate
{{- $cms := lookup "v1" "ConfigMap" .Release.Namespace "" }}
{{- range $cms.items }}
- {{ .metadata.name }}
{{- end }}
~~~

在使用这个函数的时候, 一定要注意以下几点:

- 如果没有RBAC权限, 那么永远返回nil
- lookup命令是在安装阶段中执行的, **只能查看已经存在的资源, 不能用来读取"本次安装中刚刚创建的资源"**
- 如果执行的是`helm  template`命令, 那么永远返回nil



#### required, default, fail

requried和fail是helm提供的,  而default函数是在sprig中提供的



required主要用来校验对象中的属性, map中的key是否存在, 如果不存在那么就报错出去

default主要用来设置默认

fail主要用来主动失败

~~~gotemplate
{{ default 1 .Values.replicaCount }} // 默认值
{{ required "image.repository must be set" .Values.image.repository }} // 校验值是否被设置


{{- if not (semverCompare .Chart.KubeVersion .Capabilities.KubeVersion.GitVersion) }}
{{- fail "Kubernetes version not supported" }} // fail这个函数直接导致模版渲染失败
{{- end }}
~~~



#### toYaml和fromYaml

`toYaml` 这个函数将go对象(map / slice / struct) 序列号并转换为yaml结构

简单用法:

~~~gotempalate
{{ dict "a" 1 "b" 2 | toYaml }}
a: 1
b: 2

{{ list "a" "b" "c" | toYaml }}
- a
- b
- c
~~~

常见用法

~~~yaml
# values.yaml
resources:
  limits:
    cpu: "1"
    memory: 1Gi

# templates/aa.yaml
resources:
{{ toYaml .Values.resources | nindent 2 }}
~~~



fromYaml主要用于将yaml结构的字符串转换为map

~~~gotemplate
# 获取config.yaml, 并转换为map结构
{{- $obj := fromYaml (.Files.Get "config.yaml") }}

# 获取map结构中的值
{{ $obj.metadata.name }}
~~~





#### nindent和indent

nindent和indent主要用来给yaml换行使用的

~~~gotemplate
# 给多行文本的每一行前面添加固定数量的空格
{{ list "a" "b" "c" | indent 4}} 
    a
    b
    c

# 和上面的indent一样, 给每一行都添加一个指定的空格, 但是区别在于会在第一行添加一个换行
{{ list "a" "b" "c" | indent 4}} 

    a
    b
    c
~~~



# kubernetes-dashboard

通过helm安装kubernetes-dashboard

1. 通过`https://artifacthub.io/`查找要安装的charts, 这里以kubernetes-dashboard为例

2. 通过命令行安装

   ~~~shell
   # Add kubernetes-dashboard repository
   helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
   # Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
   helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
   
   kubectl get pods -n kubernetes-dashboard
   kubectl get svc -n kubernetes-dashboard
   ~~~

   ![image-20231024170447590](img/k8s笔记/image-20231024170447590.png)

3. 因为helm创建的service的类型为ClusterIp, 无法外部访问, 修改service的类型, 将ClusterIp类型改为NodePort类型

   ~~~shell
   kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
   ~~~

   ![image-20231024170503064](img/k8s笔记/image-20231024170503064.png)

4. 访问node的32403端口,  注意上面开放的内部端口是443, 所以需要使用**https**协议

   ![image-20231024170823865](img/k8s笔记/image-20231024170823865.png)

5. 上面需要一个service account token才能够登录, 所以需要查看pod `kubernetes-dashboard`的token

   ~~~shell
   kubectl get secret -n kubernetes-dashboard
   kubectl describe secret kubernetes-dashboard-tokn-dxjtv -n kubernetes-dashboard
   ~~~

   ![image-20231024171438884](img/k8s笔记/image-20231024171438884.png)

   ![image-20231024175647185](img/k8s笔记/image-20231024175647185.png)

6. 将查出来的token复制到界面上, 即可登录成功

7. 因为通过pod的sa进行登录, 所以没有权限调用各种api, 所以必须给sa分配权限, 通过如下文件

   ~~~yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: cluster-admin-kubernetes-dashboard
   subjects:
   - kind: ServiceAccount
     name: kubernetes-dashboard # sa的用户名通过kubectl describe secret来获得, 就是上图红框中的
     apiGroup: "" # 如果kind为sa, 这里必须为空 , 查看secret部分获得更详细资料
     namespace: kubernetes-dashboard # 如果为sa, 必须指定sa的ns, 查看secret部分获得更详细资料
   roleRef:
     kind: ClusterRole
     name: cluster-admin # 这个是集群内置的角色, 超级管理
     apiGroup: rbac.authorization.k8s.io
   ~~~

   

# kubectl命令行自动补全

1. 在Master01节点上开启kubectl自动补全

```shell
source <(kubectl completion bash) 
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

2. 在Master01节点上为 `kubectl` 使用一个速记别名`k`, 并给k添加自动补全

   将该命令写入到`/etc/bashrc`中, 永久生效

```shell
echo "alias k=kubectl" | sudo tee -a /etc/bashrc
echo "complete -o default -F __start_kubectl k" | sudo tee -a /etc/bashrc
source /etc/bashrc
```





# 卸载docker k8s kubeadmin

~~~shell
# 删除所有容器和镜像
docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi -f $(docker images -q)
# 停止相关服务
systemctl stop kubelet
systemctl stop etcd
systemctl stop docker
# 卸载 docker
yum remove -y docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine
# 清除iptables
iptables -F && iptables -F -t nat
# 卸载k8s和kubeadm
kubeadm reset -f
sudo yum remove -y kubeadm kubectl kubelet kubernetes-cni kube*   
sudo yum autoremove -y
modprobe -r ipip
lsmod
rm -rf ~/.kube/
rm -rf /etc/kubernetes/
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /etc/systemd/system/kubelet.service
rm -rf /usr/bin/kube*
rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /var/lib/etcd
rm -rf /var/etcd
#更新镜像
yum -y update
~~~



# KubeSphere

## 在k8s上安装kubeSphere

### 安装nfs

~~~shell
# 在nfs服务器节点上执行
yum install -y nfs-common nfs-utils rpcbind # 安装nfs组件
mkdir -p /nfs/data # 创建挂载的目录
chmod 666 /nfs/data
   
cat > /etc/exports << EOF # 指定要挂载的目录
/nfs/data *(rw,no_root_squash,no_all_squash,sync)
EOF

systemctl start rpcbind
systemctl start nfs
systemctl enable rpcbind
systemctl enable nfs

# 在所有的k8s的node主机上安装nfs相关组件, k8s需要通过这个来连接目标服务器
yum install -y nfs-common nfs-utils rpcbind

# 测试nfs, 在nfs服务器上执行
cat << EOF > /nfs/data/test.txt
hello world
EOF
   
# 在k8s的node节点上执行
mkdir /test
showmount -e cdh107 # 查看能够挂载的目录
mount -t nfs cdh107:/nfs/data  /test # 将/nfs/data挂载到/test目录下
cat /test/test.txt # 查看挂载的文件
umount -t nfs /test # 卸载挂载的目录
~~~

### 配置默认的存储类

该存储类用于动态供应pv, 即不需要事先创建pv, 只需要创建一个pvc, 该存储类就能够动态的根据pvc创建对应的pv, 并将他们绑定在一起

~~~yaml
## 创建了一个存储类
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: k8s-sigs.io/nfs-subdir-external-provisioner
parameters:
  archiveOnDelete: "true"  ## 删除pv的时候，pv的内容是否要备份

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/nfs-subdir-external-provisioner:v4.0.2
          # resources:
          #    limits:
          #      cpu: 10m
          #    requests:
          #      cpu: 10m
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: k8s-sigs.io/nfs-subdir-external-provisioner
            - name: NFS_SERVER
              value: cdh107 # 指定自己nfs服务器地址
            - name: NFS_PATH  
              value: /nfs/data  # nfs服务器共享的目录
      volumes:
        - name: nfs-client-root
          nfs:
            server: cdh107 # nfs服务器
            path: /nfs/data # nfs服务器共享的目录
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io
~~~

测试:

~~~shell
kubectl get sc
cat << EOF > pvc-test.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim # 定义pvc的名字
spec:
  accessModes:
    - ReadWriteOnce # 该pvc只会寻找同样accessModes的pv进行绑定
  volumeMode: Filesystem # 该pvc只会寻找同样volumeMode的pv进行绑定
  resources:
    requests:
      storage: 4Gi # 该pvc只会寻找大于等于storage的pv进行绑定
  storageClassName: nfs-storage # 该pvc只会寻找相同storageClassName的pv进行绑定
EOF
kubectl apply -f pvc-test.yaml
kubectl get pvc, pv
~~~

可以看到只创建了一个pvc, 就同时创建了对应的pvc

![image-20231028232427663](img/k8s笔记/image-20231028232427663.png)

### 安装kubeSphere

1. 执行如下命令进行安装

   ~~~shell
   kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.4.0/kubesphere-installer.yaml
   
   kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.4.0/cluster-configuration.yaml
   ~~~

2. 查看安装进度

   ~~~shell
   kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f
   ~~~

   如果这个名字执行的时候, pod还没有起来, 就会报如下错误, 耐心等待下就好了

   ~~~shell
   [root@cdh105 ~]# kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f
   Error from server (BadRequest): container "installer" in pod "ks-installer-58f7c6477b-xfjfv" is waiting to start: ContainerCreating
   ~~~

   <img src="img/k8s笔记/image-20231028234128548.png" alt="image-20231028234128548" style="zoom:50%;" />

   打印上面界面就可以按ctrl+c结束任务了, 这个时候表示安装好了

3. 查看kubeSphere开放的端口,  默认在`30880`, 记得访问node的地址

   ~~~shell
   kubectl get svc/ks-console -n kubesphere-system
   ~~~

4. 使用账号密码访问界面

   ~~~shell
   账号: admin
   密码: P@88w0rd
   ~~~

## KubeSphere项目界面介绍

主界面: 其中包括

1. 应用负载: 主要用来控制Pod, controller,service, ingress
2. 存储: 控制PVC和PV
3. 存储: 控制ServiceAccount, ConfigMap, Opaque

![image-20231029161340788](img/k8s笔记/image-20231029161340788.png)

应用负载:

应用对应通过类似helm模板快捷创建的应用

服务对应Service

工作负载对应Controller

任务对应Job和CronJob

路由对应Ingress

容器组对应Pod

<img src="img/k8s笔记/image-20231029162303585.png" alt="image-20231029162303585" style="zoom:50%;" />

存储:

![image-20231029162552925](img/k8s笔记/image-20231029162552925.png)

配置:

保密字典对应Opaque

配置字典对应ConfigMap

服务账户对应ServiceAccount

![image-20231029162701636](img/k8s笔记/image-20231029162701636.png)

## 通过kubesphere安装应用

https://www.bilibili.com/video/BV13Q4y1C7hS?p=82&vd_source=f79519d2285c777c4e2b2513f5ef101a

https://www.yuque.com/leifengyang/oncloud/vgf9wk#NRstb

### 安装mysql

1. 通过dockerhub找到mysql容器, 发现他如下信息

   - 端口映射: `3306`
   - 环境变量: `MYSQL_ROOT_PASSWORD`
   - 默认的配置文件为`/etc/mysql/my.cnf`
   - 所有在`/etc/mysql/conf.d`和`/etc/mysql/mysql.conf.d`下的所有conf文件都会作为配置文件
   - 数据存放在`/var/lib/mysql`
   - 日志数据存放在`/var/log/mysql`下

2. 根据如下信息编写docker命令

   ~~~shell
   docker run -p 3306:3306 --name mysql-01 \
   -v /mydata/mysql/log:/var/log/mysql \ # 挂载日志目录
   -v /mydata/mysql/data:/var/lib/mysql \ # 挂载数据目录
   -v /mydata/mysql/conf:/etc/mysql/conf.d \ # 挂载配置文件
   -e MYSQL_ROOT_PASSWORD=root \ # 指定mysql root密码
   --restart=always \
   -d mysql:5.7 
   ~~~
   
3. 在kubesphere中创建pvc, 用于挂载数据, k8s会自动创建pv
   
   ![image-20231029165007496](img/k8s笔记/image-20231029165007496.png)
   
   选择pvc的名称
   
   ![image-20231029165105909](img/k8s笔记/image-20231029165105909.png)
   
   选择pvc的storageClass, accessMode, storage
   
   ![image-20231029165318559](img/k8s笔记/image-20231029165318559.png)
   
   添加label![image-20231029165352886](img/k8s笔记/image-20231029165352886.png)
   
   创建完成, 创建了`mysql-data`的pvc, 并且k8s通过storageClass动态创建了对应的pv
   
   ![image-20231029165500796](img/k8s笔记/image-20231029165500796.png)
   
   同时在k8s上通过命令行也能够看到
   
   ![image-20231029165752396](img/k8s笔记/image-20231029165752396.png)

4. 同理, 创建pvc和pv, 挂载mysql日志

   ![image-20231029165924903](img/k8s笔记/image-20231029165924903.png)

5. 创建ConfigMap, 用以保存mysql的配置文件

   ![image-20231029170054059](img/k8s笔记/image-20231029170054059.png)

   ![image-20231029170115307](img/k8s笔记/image-20231029170115307.png)

   因为ConfigMap进行挂载之后, key作为文件名, data作为内容, 所以key一定要以conf结尾, 如下

   ![image-20231029170300566](img/k8s笔记/image-20231029170300566.png)

   创建完成

   ![image-20231029170327203](img/k8s笔记/image-20231029170327203.png)

6. 在kubesphere中, 创建StatefulSet类型的控制器和pod

   <img src="img/k8s笔记/image-20231029170437460.png" alt="image-20231029170437460" style="zoom:50%;" />

   指定基本信息

   ![image-20231029170455969](img/k8s笔记/image-20231029170455969.png)

   指定pod相关的设置, 如镜像,  容器名称, 资源限制

   ![image-20231029170827946](img/k8s笔记/image-20231029170827946.png)

   指定端口映射, 使用默认端口即可

   ![image-20231029172650074](img/k8s笔记/image-20231029172650074.png)

   指定环境变量, 和主机时间同步, 还有其他设置

   ![image-20231029172727967](img/k8s笔记/image-20231029172727967.png)

   挂载两个持久卷和ConfigMap

   ![image-20231029173415668](img/k8s笔记/image-20231029173415668.png)

7. 查看服务, 发现自动创建了对mysql的headless service

   并且通过其中的DNS属性可以访问到mysql

   ![image-20231029185548006](img/k8s笔记/image-20231029185548006.png)

### 安装redis

<img src="img/k8s笔记/image-20231106184339682.png" alt="image-20231106184339682" style="zoom:50%;" />

如上图可以看出: 

- 需要创建configmap, 挂载到/etc/redis下
- 需要pv, 挂载到/data下
- 需要启动命令 redis-server /etc/redis/redis.conf

下面是创建过程

1. 创建configmap配置文件, key为redis.conf, 内容如下:

   ~~~txt
   appendonly yes
   port 6379
   bind 0.0.0.0
   ~~~

2. 配置基础信息

   <img src="img/k8s笔记/image-20231106184559304.png" alt="image-20231106184559304" style="zoom:80%;" />

3. 设置端口

   ![image-20231106190319104](img/k8s笔记/image-20231106190319104.png)

4. 配置启动命令

   ![image-20231106184616341](img/k8s笔记/image-20231106184808859.png)

5. 设置同步时间![image-20231106184634784](img/k8s笔记/image-20231106184634784.png)

5. 设置存储卷模板

   ![image-20231106190442867](img/k8s笔记/image-20231106190442867.png)

6. 挂载配置文件

   ![image-20231106190609977](img/k8s笔记/image-20231106190609977.png)

### 安装elasticsearch

![image-20231106193035275](img/k8s笔记/image-20231106193035275.png)

如上图所示, 有如下几个注意点

1. 创建configmap, 有两个key `elasticsearch.yml`和`jvm.options`, 并且需要挂载到/usr/share/elasticsearch/config下面, 内容如下:

   ~~~shell
   cluster.name: "docker-cluster"
   network.host: 0.0.0.0
   ~~~

   ~~~shell
   # 
   ~~~
   

   
2. 一个数据目录, 所以需要创建pvc挂载到/usr/share/elasticsearch/data下面

下面是创建过程

1. 创建configmap

   ![image-20231106194038879](img/k8s笔记/image-20231106194038879.png)

2. 设置基本信息

   ![image-20231106193358488](img/k8s笔记/image-20231106193358488.png)

3. 设置端口

   ![image-20231106193419788](img/k8s笔记/image-20231106193419788.png)

4. 设置时间同步

   ![image-20231106193458563](img/k8s笔记/image-20231106193458563.png)

5. 添加pv模板

   ![image-20231106194516515](img/k8s笔记/image-20231106194516515.png)

6. 挂载配置文件





## KubeSphere应用商店和应用仓库

### 应用商店

1. 如果没有开启应用商店的话, 可以通过如下方式开启

   ~~~shell
   # 编辑ks-installer
   kubectl edit -n kubesphere-system clusterconfigurations ks-installer
   # 将openpitrix修改为true
   openpitrix:
     store:
       enabled: true # 将“false”更改为“true”。
   ~~~

2. 一段时间后从左上角可以看到应用商店即安装成功

   ![image-20231108224435325](img/k8s笔记/image-20231108224435325.png)

3. 可以通过应用商店来安装应用

### 应用仓库

其实应用仓库就是helm中的仓库, 然后就可以通过仓库来安装应用

1. 在https://artifacthub.io/中找到需要安装的charts, 这里以zookeeper为例

   ![image-20231108224806355](img/k8s笔记/image-20231108224806355.png)

2. 点击install, 会弹出zookeeper的应用仓库

   ![image-20231108224841877](img/k8s笔记/image-20231108224841877.png)

3. 在kubesphere中, 进入到企业空间  > 应用管理 > 应用仓库, 添加

   ![image-20231108225119558](img/k8s笔记/image-20231108225119558.png)

4. 添加应用仓库

   ![image-20231108225212515](img/k8s笔记/image-20231108225212515.png)

5. 通过应用仓库创建服务,  其实就是通过helm来安装pod

   ![image-20231108225429331](img/k8s笔记/image-20231108225429331.png)

   ![image-20231108225459043](img/k8s笔记/image-20231108225459043.png)

####  todo

数据卷的类型, 网络模型和iptables ipvs的关系, coredns, ingress, https

容器的状态, pod的状态, statefull容器 dig



![image-20231012213607030](img/k8s笔记/image-20231012213607030.png)





# Windows上使用kubectl和helm控制远程k8s集群

### kubectl

1. 在Windows上下载kubectl.exe文件, 链接: https://kubernetes.io/releases/download/#binaries

   下载Windows, amd64版本的

   ![在这里插入图片描述](img\c17644568be40b29f4535147be77c313.png)

2. 将下载下来的kubectl.exe放到一个目录中, 并将这个目录添加到path环境变量下

   ![在这里插入图片描述](img\4f28658e8bb09cfc2c9254a9278e16cb.png)

3. 检查安装

   ~~~shell
   D:\software\dev\k8s>kubectl version
   Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.5", GitCommit:"e6503f8d8f769ace2f338794c914a96fc335df0f", GitTreeState:"clean", BuildDate:"2020-06-26T03:47:41Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"windows/amd64"}
   Unable to connect to the server: dial tcp [::1]:8080: connectex: No connection could be made because the target machine actively refused it.
   ~~~

4. 配置k8s的config文件

   我们需要链接到k8s集群, 然后下载`~/.kube/config`文件到Windows上的`C:\Users\Administrator\.kube\config`中

   这样我们windows上的kubectl.exe就可以使用这个config文件来连接远程的k8s集群了

   ![在这里插入图片描述](img\7075751a1fea481160d486edb1b00bbe.png)

   ![在这里插入图片描述](img\e2b3eaf79427aa318c10c8b7853c61ff.png)

5. 特别要注意上面图片中的server的域名, 如果是127.0.0.1或者是localhost, 那么需要修改为k8s集群的ip

6. 验证集群的连接

   ~~~shell
   kubectl get pod
   ~~~

   

### helm

要在windows上使用helm.exe的话, 需要先配置好上面的kubectl.exe, 只有kubectl.exe能够访问k8s了, helm.exe才可以用

之后我们可以在https://github.com/helm/helm/releases?spm=a2c6h.12873639.article-detail.10.7f3d1a2a8HHxOd中下载helm.exe文件

![img](https://i-blog.csdnimg.cn/blog_migrate/7f320e244a6fd8cbd3c069844b1e30b3.png)

之后将helm.exe配置到path环境变量中就可以直接使用了





# 工作中的经验

## DaemonSet的问题

### 项目背景
酒泉钢铁6月24日因集群中一个节点raid卡故障导致业务认证业务受到影响，已定位是k8s机制导致，或者说对deamonset使用不够规范。

具体原因：集群中节点因为硬件故障导致异常时，该节点会变成notready状态，节点上的pod也会被驱逐走，但从k8s设计的角度上daemonset类型的服务默认会容忍这种notready状态，这就导致daemonset类型的pod不会被驱逐走，并且其service关联的endpoint也不会被摘除，通过svc的请求会概率负载到这个异常节点上的daemonset类型的pod，导致30000页面，eia等服务异常等。

解决方案：使用daemonset类型的都不要通过svc提供对外服务，同步平台、AD、UC各组件排查修改，涉及的组件请给出版本计划时间点

评估内容：所有组件排查使用service访问daemonset服务的场景，是否可以把daemonset换成deployment或statefulset（默认这两种资源类型不会容忍notready状态，也需要各组件排查确认有没有主动添加，容忍配置如下所示，如果添加了tolerationSeconds则说明容忍指定时间后会驱逐，无需修改）

~~~yaml
tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
~~~



### 排查

首先要知道的是, kubelet会定时的向control-plane定时的发送心跳, 如果超过一定的时间control-plane没有接收到心跳, 那么control-plane会将node的状态设置为notReady
定时发送心跳的时间可以通过-node-status-update-frequency来控制，默认 10s
超时时间可以通过--node-monitor-grace-period控制, 默认是40s

你可以通过`kubectl describe node <节点名>` 来查看node的心跳记录以及当前的状态

当节点变成NotReady之后, k8s会通过ping, ssh等手段来确定node物理机是否存在, 如果是云厂商的环境并且启用了Cloud Controller Manager功能, 那么还会调用云厂商的接口, 来确认宿主机的状态
如果宿主机都已经不存在了, 那么k8s会将node的状态修改为Unreachable

NotReady和Unreachable的区别在于:
- NotReady是心跳超时了, 但是节点还存在, kubelet可能还在运行, 产生的情况有
  1. Kubelet 崩溃
  2. 节点 CPU/内存耗尽
  3. 容器运行时（containerd/docker）挂掉
  4. 证书过期
  5. 磁盘空间不足
- Unreachable表示的是control-plane完全不发连接到kubelet所在的机器, 产生的原因有
  1. 物理机断电了
  2. 网络中断了
  

如果可能的话, 你可以通过`kubectl describe node <节点名>`来查看node变成notReady的原因, 可能会显示MemoryPressure/DiskPressure
也可以通过`journalctl -u kubelet -n 100`来查看kubelet的日志

如果节点的状态变成NotReady/Unreachable后, 持续一定的时间, 那么就会开始驱逐pod
这个时间可以通过--pod-eviction-timeout来控制, 默认是5分钟

驱逐pod是通过污点来控制的, 对于NotReady/Unreachable的节点, control-plane会给节点添加上污点
- 对于NotReady的node, 会添加上`node.kubernetes.io/not-ready=:NoSchedule`
- 对于Unreachable的node, 会添加上`node.kubernetes.io/unreachable=:NoSchedule`

如果你想要容忍这两个污点, 可以在生成pod的时候, 添加上污点容忍
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resilient-pod
  labels:
    app: critical-service
spec:
  containers:
  - name: main-container
    image: nginx:latest
    ports:
    - containerPort: 80
  # 容忍节点 NotReady 和 Unreachable 状态
  tolerations:
  - key: "node.kubernetes.io/not-ready"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 600  # 容忍 NotReady 状态 10 分钟
  - key: "node.kubernetes.io/unreachable"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 300  # 容忍 Unreachable 状态 5 分钟
```

被驱逐的pod会在原节点被删除, 如果是裸pod那么会消失, Deployment/StatefulSet控制的pod会在其他的节点上重建, 如果有可能的话

但是对于daemonset控制的pod, 这种pod默认是能够容忍上面两个污点的, 并且是无限的时长,  所以ds控制的pod不会被驱逐

如果节点恢复后, 那么node的节点会先变成NotReady, 然后kubelet重新注册, 发送心跳, 然后node的状态变成Ready



## kubectl wait

`kubectl wait`命令主要用于在k8s中, 等待某个资源达到特定的状态,  比如就绪, 已删除等等, 这在自动化脚本, CI/CD流程中都非常有用

- 如果资源在指定的时间内就绪, 那么状态码返回0, 否则状态码返回1
- kubectl wait监控的是资源的`status.conditions`字段
- 对于`--for=delete`, 等待资源被删除, 如果没有这个资源, 那么直接返回0



基本语法如下:

~~~shell
# condition可选的值有:
#     PodScheduled: Pod已经调度到指定的节点上
#     ContainersReady: Pod中所有的容器已经就绪
#     Initialized: pod的初始化容器已经执行完毕
#     Ready: Pod就绪

kubectl wait [RESOURCE] --for=condition=<CONDITION> [options]
kubectl wait [RESOURCE] --for=delete [options]
~~~

等待Pod就绪

```shell
# 等待所有的pod都继续
kubectl wait --for=condition=Ready pod --all -n my-namespace

# 等待某个特定的pod就绪, 并指定超时的时间
kubectl wait pod/my-pod --for=condition=Ready -n my-namespace --timeout=60s

# 等待带有特定label的pod就绪
kubectl wait pod --for=condition=Ready -l app=myapp,env=prod --timeout=90s # 多个lable是且的关系
kubectl wait pod -l "app in (web,api)" --for=condition=Ready # 多个label是或的关系
```

等待Deployment可用

~~~shell
# 等待Deployment管理的pod的副本数达到期望, 并且都是Ready状态
kubectl wait deployment/my-deploy --for=condition=available --timeout=120s

# 等待所有的deployment管理的pod的副本数达到期望, 并且都是Ready状态
kubectl wait deployment --all --for=condition=available -n my-namespace

# 等待带有特定标签的Deployment可用
kubectl wait deployment --for=condition=available -l env=prod,tier=frontend --timeout=180s
~~~

等待Job

~~~shell
# 等待job执行完毕
kubectl wait job/my-job --for=condition=complete --timeout=180s
~~~

等待某个资源被删除

~~~shell
kubectl delete pod my-pod &
kubectl wait pod/my-pod --for=delete --timeout=30s

# 等待my-namespace命名空间中所有的pod都被删除
kubectl wait pod --all --for=delete -n my-namespace
~~~

等待自定义的资源的某个条件

~~~shell
# 如果你有一个CRD, 比如mycrd.example.com,  他有一个status.conditions字段
kubectl wait mycrd/example --for=condition=Ready
~~~

| 参数                     | 说明                                            |
| ------------------------ | ----------------------------------------------- |
| `--for=condition=<cond>` | 指定等待的条件（如 Ready、Available、Complete） |
| `--for=delete`           | 等待资源被删除                                  |
| `--timeout=<time>`       | 设置超时时间（如 30s, 1m, 5m），默认无限等待    |
| `--selector=<label>`     | 使用 label 过滤资源                             |
| `--all`                  | 选中所有匹配的资源                              |
| `-n, --namespace`        | 指定命名空间                                    |



## kubectl patch

`kubectl patch`主要用于通过命令来修改k8s中的资源配置,  他不需要你像`kubectl edit`一样通过交互式的命令来修改k8s的资源, 也不需要你通过`kubect apply`来通过整个完整的yaml来覆盖已经创建的资源配置

他表达的含义是 `只改我想要改的字段, 其他的字段别动`



基本语法如下

~~~shell
# 资源类型可以指定
#  deployment
#  pod
#  svc
#  statefulset
#  等等
kubectl patch <资源类型>/<名称> -p '<修改内容>' [选项]
~~~

`kubectl patch`有一些常用的参数如下

| 参数               | 含义                       |
| ------------------ | -------------------------- |
| `-n`               | 指定命名空间               |
| `--dry-run=client` | 只显示修改结果，不实际执行 |
| `-o yaml/json`     | 输出修改后的对象           |



patch分为三种类型, 你可以通过`--type=xxx`来指定patch的type,  如果你什么也不指定的话, 那么默认使用的是strategic

| 类型          | 选项值             | 特点                                            |
| ------------- | ------------------ | ----------------------------------------------- |
| **strategic** | `--type=strategic` | 默认类型；理解 K8s 资源结构（能智能合并数组等） |
| **merge**     | `--type=merge`     | 按 JSON key 合并（简单粗暴）                    |
| **json**      | `--type=json`      | 使用 JSON Patch 语法（操作性强、适合精确控制）  |

**对于strategic类型的path, 如果指定是值类型那么表示修改, 如果是数组或者map, 表示覆盖和新增, strategicy一般不用于删除的功能**

比如你想要删除pod中挂载的一个env, 那么strategic类型的patch是无能为力的

strategic类型的pathc使用案例如下:

~~~shell
kubectl patch deployment myapp -p '{"spec": {"replicas": 5}}' # 修改deployment的副本数为5
# 等效于
kubectl scale deployment myapp --replicas=5


 # 给pod添加label, 或者修改已有的label
kubectl patch pod mypod -p '{"metadata": {"labels": {"env": "prod"}}}'

# 修改svc的端口
kubectl patch service mysvc -p '{"spec": {"ports": [{"port": 8080, "targetPort": 80}]}}'

# 给deployment添加环境变量
kubectl patch deployment myapp -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "myapp",
          "env": [{"name": "ENV_MODE", "value": "prod"}] # 如果存在覆盖, 不存在添加
        }]
      }
    }
  }
}'
~~~



**json类型的patch比strategic类型的patch更加的强大, 但是也更加的复杂, 这个patch可以指定一个数组, 数组中的每个对象都有如下的三个属性**

- op: 要进行的操作的类型

  - add: 向对象添加新字段(字段必须不存在), 或者在数组末尾添加新的元素

    ~~~json
    // 添加spec.replicas = 3
    {
      "op": "add",
      "path": "/spec/replicas",
      "value": 3
    }
    // 0表示数组的第一个元素, -表示数组末尾
    // 这里表示给containers[0].env数组中添加一个环境变量, 到数组的末尾
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/env/-",
      "value": {"name":"DEBUG","value":"true"}
    }
    ~~~

  - replace: 修改已有的字段,如果字段不存在会报错

    ~~~json
    // 修改副本数
    {
      "op": "replace",
      "path": "/spec/replicas",
      "value": 5
    }
    // 更新容器的镜像
    {
      "op": "replace",
      "path": "/spec/template/spec/containers/0/image",
      "value": "myapp:v2"
    }
    ~~~

    

  - remove: 删除对象中的字段, 或者数组中的元素

    ~~~json
    // 删除spec.replicas字段
    {
      "op": "remove",
      "path": "/spec/replicas"
    }
    // 删除spec.template.spec.containers[0].env[0] 这个环境变量
    {
      "op": "remove",
      "path": "/spec/template/spec/containers/0/env/0"
    }
    ~~~

  - copy: 把对象或者数组中的元素复制到另外一个路径

    ~~~json
    // 复制spec.replicas 到 spec.oldReplicas
    {
      "op": "copy",
      "from": "/spec/replicas",
      "path": "/spec/oldReplicas"
    }
    ~~~

  - move: 把对象或者数组中的元素移动到另外一个路径中

    ~~~json
    // 移动spec.template.spce.containers[0].env[1] 到 数组头部
    {
      "op": "move",
      "from": "/spec/template/spec/containers/0/env/1",
      "path": "/spec/template/spec/containers/0/env/0"
    }
    ~~~

  - test: 在patch的时候, 检查某个字段的值是否符合预期, 如果不符合那么整个patch都会失败, 类似if的作用

    ~~~json
    // 如果patch的时候, replicas不为3, 那么patch失败
    {
      "op": "test",
      "path": "/spec/replicas",
      "value": 3
    }
    ~~~

- path: 要修改的值的路径

- value: 要操作的值

~~~shell
# 修改副本数为3, 修改/0/数组索引为0的容器的镜像, 在/0/数组索引为0的容器的环境变量数组末尾添加环境变量
kubectl patch deployment myapp \
  --type=json \
  -p '[
    {"op": "replace", "path": "/spec/replicas", "value": 3},
    {"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "myapp:v2"},
    {"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": {"name":"DEBUG","value":"true"}}
  ]'
~~~



## kubectl attach

这个命令是让你能够将当前终端附加到pod的**1号程序**的标准输入, 输出, 错误流的命令, 然后你就可以通过这个终端来和pod中的1号程序进行交互, 就像`docker attach`一样

`kubectl attach` 的主要用途包括：

1. **查看正在运行容器的实时输出**（类似 `tail -f`）。
2. **在交互式容器中执行输入操作**（如果容器支持交互，比如运行 `/bin/bash` 的容器）。
3. **调试长时间运行的容器**，比如正在运行的服务或后台任务。

语法如下:

~~~shell
kubectl attach POD_NAME [-c CONTAINER_NAME] [options]
~~~

常用参数:

| 参数              | 作用                                    |
| ----------------- | --------------------------------------- |
| `-i, --stdin`     | 连接标准输入（允许输入命令）            |
| `-t, --tty`       | 分配一个伪终端（交互式）                |
| `-c, --container` | 指定要附加的容器（当 Pod 有多个容器时） |
| `--namespace`     | 指定命名空间                            |

~~~shell
# 创建一个nginx镜像的容器
kubectl run busybox-demo --image=busybox --stdin --tty --restart=Never -- sh

# 退出容器后（Ctrl+D 或 exit），它会继续保持运行（因为我们用 --stdin --tty 启动了它）。
Ctrl + D

# attach到nginx中的PID 1的程序上, 接管他的标准输入, 输出, 错误流
kubectl attach -it busybox-demo

# 你可以在当前终端上控制这个busybox
/ # ls
/ # echo hello
~~~



他和其他的一些命令在某些时候能够达到一样的效果, 但是也有一些不同

| 命令                           | 作用               | 特点                       |
| ------------------------------ | ------------------ | -------------------------- |
| `kubectl exec -it pod -- bash` | 在容器中执行新命令 | 启动新进程，不影响已有进程 |
| `kubectl attach -it pod`       | 连接到容器的主进程 | 查看/控制正在运行的进程    |
| `kubectl logs -f pod`          | 查看日志输出       | 只读、不能交互             |
| `kubectl debug`                | 创建临时调试容器   | 不影响原容器环境           |



## kubectl debug

`kubectl debug` 是 Kubernetes 专门用于排查和调试 Pod 的命令，它可以在 不修改原始 Pod 定义的情况下，帮你启动一个“调试容器”，这个调试容器可以访问被调试容器的系统

基本语法:

~~~shell
kubectl debug <pod-name> [options]
~~~

| 选项                  | 说明                                            | 示例                               |
| --------------------- | ----------------------------------------------- | ---------------------------------- |
| `-it`                 | 分配交互式终端（interactive + tty）             | `-it`                              |
| `--image=IMAGE`       | 指定调试容器使用的镜像                          | `--image=busybox`                  |
| `--target=CONTAINER`  | 指定要调试的目标容器（在 Pod 有多个容器时使用） | `--target=app`                     |
| `--container=NAME`    | 为临时调试容器指定一个名字                      | `--container=debugger`             |
| `--copy-to=NEW_POD`   | 克隆一个新的 Pod 进行调试（不影响原 Pod）       | `--copy-to=debug-pod`              |
| `--attach`            | 调试容器创建后自动附着进入调试容器的1号进程     | `--attach`                         |
| `--namespace`         | 指定命名空间                                    | `--namespace=prod`                 |
| `--env=KEY=VALUE`     | 向调试容器注入环境变量                          | `--env=DEBUG=true`                 |
| `--replace`           | 当 `--copy-to` 的 Pod 已存在时，先删除再创建    | `--copy-to=debug-pod --replace`    |
| `--image-pull-policy` | 控制调试镜像拉取策略 (`IfNotPresent`, `Always`) | `--image-pull-policy=IfNotPresent` |



使用场景:

1. 假设你想调试一个正在运行的pod, 但是又不想影响到这个pod, 那么你可以复制一个pod进行调试

   ~~~shell
   # mypod是需要调试的pod
   # --copy-to=debug-mypod 表示复制一个pod为debug-mypod
   # --image表示在新的pod中, 使用busybox作为调试容器的镜像
   # --target指定调试新pod中的mycontainer镜像
   # --attach (可选) 直接attach到调试容器的1号程序中
   kubectl debug mypod --image=busybox --target=mycontainer --copy-to=debug-mypod
   ~~~

   

2. 假设你有一个pod的网络有问题, 你想要在这个pod中调用curl, ping等工具, 那么你可以通过创建一个调试容器, 然后在调试容器中使用这些命令进行排查

   ~~~shell
   # mypod和--target=mycontainer 指定要调试mypod的mycontainer容器
   # --image=busybox 指定使用netshoot 创建调试容器
   # -it 表示分配交互终端
   # --image-pull-policy 这个挺重要的, 默认情况下他会去拉镜像, 如果你本地已经有了, 那么可以加这个参数
   kubectl debug -it -n ns mypod --image nicolaka/netshoot --target mycontainer --image-pull-policy IfNotPresent
   ~~~

   **这个新的调试容器, 与原来的容器共享同一个网络, 共享存储卷, 共享/tmp, /data目录**

   **你可以在这个调试容器中使用ping, netstat等网络命令进行调试,  在退出伪终端之后, 调试容器会自动被删除**

3. 假设你有一个java容器, 你想要dump这个进程的内存信息, 但是这个容器使用的是jre, 没有相关的 `jmap`, `jstack`, `jcmd` 命令, 那么你可以创建一个带有jdk的调试容器, 然后在这个容器中使用相关命令进行dump

   ~~~shell
   kubectl debug -it java-app \
     --image=openjdk:17 \
     --target=app \
     --container=debugger
   
   # 在调试容器中dump
   ps -ef | grep java
   jmap -dump:format=b,file=/tmp/heap_dump.hprof 7
   
   # 退出调试容器, 自动被删除
   exit
   
   # 因为调试容器和原来的容器共享/tmp, /data目录, 所以可以直接从原来的容器中复制数据出来
   kubectl cp java-app:/tmp/heap_dump.hprof ./heap_dump.hprof
   ~~~

4. 调试节点

   在 Kubernetes 中，**“调试节点”（debug a node）** 指的是使用 `kubectl debug` 命令进入或排查 **运行节点（Node）本身的问题**，而不是 Pod 的问题。

   **调试节点** 就是进入一个 Kubernetes 工作节点（Node）所在的宿主机环境中，来排查系统级或容器运行时的问题。

   有时问题不是出在 Pod，而是出在节点层面，比如：

   - 容器启动失败，日志里提示 runtime 错误；
   - 节点磁盘空间不足；
   - CNI 网络插件崩溃；
   - kubelet 出现奇怪的错误；
   - iptables、containerd、docker、网络配置异常。

   这些都需要你进入节点本身进行调查，而不是进入 Pod。

   相较于直接ssh到有问题的节点上, **`kubectl debug` 是一种更安全、可审计、Kubernetes 原生的“SSH 进节点”方式。**
    它不需要节点暴露 SSH 端口，也能进入节点环境进行诊断。

   | 对比点       | SSH 登录节点                          | `kubectl debug node/...`           |
   | ------------ | ------------------------------------- | ---------------------------------- |
   | 🔐 安全性     | 必须节点开 SSH 端口，暴露攻击面       | 无需 SSH、只用 Kubernetes API 访问 |
   | 🧩 权限控制   | 依赖系统账号、密钥                    | 遵循 Kubernetes RBAC 权限模型      |
   | 📜 审计追踪   | 操作通常不会被审计                    | 所有操作都能在 K8s 审计日志中追踪  |
   | 🧰 环境隔离   | 登录宿主机直接操作                    | 运行在一个临时 Pod 中，不污染系统  |
   | 💣 操作风险   | 有误操作风险（删错文件、kill 错进程） | 可以安全 chroot、限定命名空间访问  |
   | ☁️ 云原生兼容 | 需要云厂商开放节点 SSH                | 在任何云平台上都能用，不依赖 SSH   |
   | 🚀 自动化能力 | 无法通过 Kubernetes API 自动化        | 可以被自动化脚本/Operator 使用     |

用法: 

~~~shell
# node/<节点名>：指定要调试的节点。
# -it：进入交互式终端。
# --image=busybox：使用 busybox 镜像（你也可以用 ubuntu、centos、nicolaka/netshoot 等调试镜像）。
kubectl debug node/<节点名> -it --image=busybox
~~~

执行这个命令后，Kubernetes 会在该节点上：

- 创建一个 **临时调试 Pod**；
- 这个 Pod 会被 **调度到指定节点**；
- 并且 **共享该节点的命名空间（namespace）环境**，从而让你能执行节点级命令。

在这个调试环境中，你可以：

```shell
# 查看节点文件系统
ls /host

# 检查容器运行时
chroot /host
crictl ps

# 查看系统日志或配置
journalctl -u kubelet
cat /var/log/messages

# 修复节点问题，例如清理磁盘、重启某些服务等。
```







