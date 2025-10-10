---
title: Midnight - Partner-Chain-Node 構築手順
---

# Midnight - Partner-Chain-Node 構築手順


!!! warning "まずはじめに"
    [Ubuntu Server の設定](../cardano-node/01-ubuntu-server-setup.md) を先におこなってからこの手順を実行してください！


## 1. Docker 環境をインストール

### aptリポジトリをアップデート
```bash
sudo apt-get update
```

### aptパッケージをインストール
```bash
sudo apt-get install ca-certificates curl
```

### keyringsディレクトリをセットアップ
```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

### Docker公式のGPGキーをインポート
```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
```

### パーミッションを設定
```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### aptソースにリポジトリを追加
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### aptリポジトリをアップデート
```bash
sudo apt-get update
```

### Dockerの最新版をインストール
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```


## 2. Docker を rootless モードで動作させる

### 2-1. システムサービスを無効化する
```bash
sudo systemctl disable --now docker.service docker.socket
```

### 2-2. ソケットファイルを削除
```bash
sudo rm /var/run/docker.sock
```

### 2-3. uidmapパッケージをインストール
```bash
sudo apt install uidmap -y
```

### 2-4. セットアップスクリプトを起動
```bash
dockerd-rootless-setuptool.sh install
```

### 2-5. Dockerの設定ファイルを作成する
```bash
sudo tee /etc/docker/daemon.json <<EOF
{
  "iptables": false
}
EOF
```


## 3. direnvをインストールする

### 3-1. direnvパッケージをインストール
```bash
sudo apt install direnv
```

## GitHubからクローンする

### クローンする

```bash
cd $HOME
rm -rf midnight-node-docker
git clone https://github.com/midnightntwrk/midnight-node-docker.git
cd midnight-node-docker
```

```bash
direnv allow
```


## 4. Partner-Chainを立ち上げる

### 4-1. dockerを立ち上げる
```bash
docker compose -f compose-partner-chains.yml up -d
```


### 4-2. ステータスをチェックする
```bash
curl -s localhost:1337/health | jq '.'
```


### 4-3. DBのステータスをチェックする
```bash
docker exec -it db-sync-postgres psql -U postgres -d cexplorer
```


### 4-4. DBでSQLを実行する
```bash
SELECT 100 * (
    EXTRACT(EPOCH FROM (MAX(time) AT TIME ZONE 'UTC')) -
    EXTRACT(EPOCH FROM (MIN(time) AT TIME ZONE 'UTC'))
) / (
    EXTRACT(EPOCH FROM (NOW() AT TIME ZONE 'UTC')) -
    EXTRACT(EPOCH FROM (MIN(time) AT TIME ZONE 'UTC'))
) AS sync_percent
FROM block;
```

