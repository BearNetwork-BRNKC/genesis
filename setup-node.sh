#!/bin/sh

# 2.. 下載 genesis.json 和 config.toml
echo "下載 genesis.json 和 config.toml..."
wget -q https://raw.githubusercontent.com/BearNetwork-BRNKC/genesis/main/genesis.json
wget -q https://raw.githubusercontent.com/BearNetwork-BRNKC/genesis/main/config.toml

# 2. 設置防火牆端口
echo "設置防火牆端口..."
sudo ufw allow 8545/tcp
sudo ufw allow 30303/tcp
sudo ufw allow 55555/tcp
sudo ufw --force enable

# 3. 創建 Docker 網路（如果已存在則忽略錯誤）
echo "創建 Docker 網路..."
sudo docker network create -d bridge --subnet=172.20.0.0/16 brnkc || true
