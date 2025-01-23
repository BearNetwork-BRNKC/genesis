#!/bin/sh

# 1. 創建目錄並設置權限
sudo mkdir -p /home/backup-node/brnkc01 && sudo chmod -R 777 /home/backup-node

# 2. 下載 genesis.json 和 config.toml
wget -q https://raw.githubusercontent.com/BearNetwork-BRNKC/genesis/main/genesis.json -O /home/backup-node/genesis.json
wget -q https://raw.githubusercontent.com/BearNetwork-BRNKC/genesis/main/config.toml -O /home/backup-node/config.toml

# 3. 設置防火牆端口
sudo ufw allow 8545/tcp
sudo ufw allow 30303/tcp
sudo ufw allow 55555/tcp
sudo ufw --force enable

# 4. 創建 Docker 網路（如果已存在則忽略錯誤）
sudo docker network create -d bridge --subnet=172.20.0.0/16 brnkc || true

# 5. 拉取映像並創建容器，並初始化 Geth
sudo docker run -dit --restart unless-stopped \
  --name backup-node \
  --network brnkc \
  --ip 172.20.0.5 \
  -v /home/backup-node:/node \
  -p 8545:8545 \
  -p 30303:30303 \
  -p 55555:55555 \
  --workdir /node \
  --entrypoint geth \
  bearnetworkchain/brnkc-node:v1.13.15 \
  --datadir /node/brnkc01 init /node/genesis.json

# 6. 重新啟動容器以啟動 Geth
sudo docker stop backup-node
sudo docker rm backup-node

sudo docker run -dit --restart unless-stopped \
  --name backup-node \
  --network brnkc \
  --ip 172.20.0.5 \
  -v /home/backup-node:/node \
  -p 8545:8545 \
  -p 30303:30303 \
  -p 55555:55555 \
  --workdir /node \
  --entrypoint geth \
  bearnetworkchain/brnkc-node:v1.13.15 \
  --config /node/config.toml \
  --identity "bearnetwork" \
  --datadir /node/brnkc01 \
  --http --http.addr 172.20.0.5 --port 30303 --http.corsdomain "*" --http.port 8545 \
  --networkid 641230 --nat any --http.api debug,web3,eth,txpool,personal,clique,miner,net \
  --ws --ws.port 55555 --ws.addr 172.20.0.5 --ws.origins "*" --ws.api web3,eth \
  --syncmode full --gcmode=archive --nodiscover --http.vhosts=* --allow-insecure-unlock console
