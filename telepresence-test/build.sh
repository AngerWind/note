#!/bin/bash

# 获取当前文件的路径
current_dir=$(dirname "$0")
# 切换到当前目录
cd "$current_dir" || exit 1

docker build -t telepresence-client -f ./telepresence-client/Dockerfile .
docker build -t telepresence-server -f ./telepresence-server/Dockerfile .
