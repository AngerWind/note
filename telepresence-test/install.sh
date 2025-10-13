#!/bin/bash

# 获取当前文件的路径
current_dir=$(dirname "$0")
# 切换到当前目录
cd "$current_dir" || exit 1


./build.sh

docker save telepresence-client:latest -o telepresence-client.tar
docker save telepresence-server:latest -o telepresence-server.tar

scp telepresence-client.tar cdh106:/tmp/
scp telepresence-client.tar cdh107:/tmp/

# 同理 server 镜像
scp telepresence-server.tar cdh106:/tmp/
scp telepresence-server.tar cdh107:/tmp/

sudo ctr -n k8s.io images import /tmp/telepresence-client.tar
sudo ctr -n k8s.io images import /tmp/telepresence-server.tar

# ssh到cdh106和cdh107, 执行上面的命令
ssh cdh106 "sudo ctr -n k8s.io images import /tmp/telepresence-client.tar"
ssh cdh107 "sudo ctr -n k8s.io images import /tmp/telepresence-client.tar"

ssh cdh106 "sudo ctr -n k8s.io images import /tmp/telepresence-server.tar"
ssh cdh107 "sudo ctr -n k8s.io images import /tmp/telepresence-server.tar"


sudo ctr -n k8s.io images list | grep telepresence


helm uninstall telepresence-test

helm install telepresence-test ./charts/telepresence-test/

kubectl get pod,svc

