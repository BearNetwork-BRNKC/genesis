#!/bin/sh

# 1. 創建目錄並設置權限
echo "創建目錄並設置權限..."
sudo mkdir -p /home/backup-node && sudo chmod -R 777 /home/brnkc

# 2. 下載 genesis.json 和 config.toml
echo "下載 genesis.json 和 config.toml..."
wget -q https://raw.githubusercontent.com/BearNetwork-BRNKC/genesis/main/genesis.json -O /home/backup-node/genesis.json
wget -q https://raw.githubusercontent.com/BearNetwork-BRNKC/genesis/main/config.toml -O /home/backup-node/config.toml

# 3. 確保下載成功
if [ ! -f "/home/backup-node/genesis.json" ] || [ ! -f "/home/backup-node/config.toml" ]; then
  echo "下載 genesis.json 或 config.toml 失敗！"
  exit 1
fi

# 4. 設置防火牆端口
echo "設置防火牆端口..."
sudo ufw allow 8545/tcp
sudo ufw allow 30303/tcp
sudo ufw allow 55555/tcp
sudo ufw --force enable

# 5. 創建 Docker 網路（如果已存在則忽略錯誤）
echo "創建 Docker 網路..."
sudo docker network create -d bridge --subnet=172.20.0.0/16 brnkc || true

# 6. 啟動 Docker 容器
echo "啟動 Docker 容器..."
sudo docker run -d -it --restart unless-stopped --name backup-node --network brnkc --ip 172.20.0.5 -v /home/backup-node:/node -p 8545:8545 -p 30303:30303 -p 55555:55555 --entrypoint /bin/sh bearnetworkchain/brnkc-node:v1.13.15


echo "自動流程部份完成，請繼續手動使用佈署創世文件及啟動指令！"
