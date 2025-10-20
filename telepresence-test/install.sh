#!/bin/bash

# 获取当前文件的路径
current_dir=$(dirname "$0")
# 切换到当前目录
cd "$current_dir" || exit 1


./build.sh

docker save telepresence-client:latest -o /tmp/telepresence-client.tar
docker save telepresence-server:latest -o /tmp/telepresence-server.tar

scp /tmp/telepresence-client.tar cdh112:/tmp/
scp /tmp/telepresence-client.tar cdh113:/tmp/

# 同理 server 镜像
scp /tmp/telepresence-server.tar cdh112:/tmp/
scp /tmp/telepresence-server.tar cdh113:/tmp/

sudo ctr -n k8s.io images import /tmp/telepresence-client.tar
sudo ctr -n k8s.io images import /tmp/telepresence-server.tar

# ssh到cdh106和cdh107, 执行上面的命令
ssh cdh112 "sudo ctr -n k8s.io images import /tmp/telepresence-client.tar"
ssh cdh113 "sudo ctr -n k8s.io images import /tmp/telepresence-client.tar"

ssh cdh112 "sudo ctr -n k8s.io images import /tmp/telepresence-server.tar"
ssh cdh113 "sudo ctr -n k8s.io images import /tmp/telepresence-server.tar"


sudo ctr -n k8s.io images list | grep telepresence


helm uninstall telepresence-test

helm install telepresence-test ./charts/telepresence-test/

kubectl get pod,svc

