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
sudo apt-get install ca-certificates curl jq
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
cd $HOME/midnight-node-docker
docker compose -f compose-partner-chains.yml up -d
```


### 4-2. 同期の進捗をチェックする
```bash
curl -s localhost:1337/health | jq '.'
```

!!! info "戻り値について"
    以下の戻り値の例の `"networkSynchronization": 1,` の行の `1` が 100%を表します。
    
    この値が `0.01` だった場合は 1% の進捗率です。

    例)
    ```json
    {
      "startTime": "2025-10-16T04:15:35.560800405Z",
      "lastKnownTip": {
        "slot": 93950347,
        "id": "af11ea0773230dc562b5cbb6702896737039bb0d558e04173e683c3c0e481500",
        "height": 3693002
      },
      "lastTipUpdate": "2025-10-16T09:19:07.137082421Z",
      "networkSynchronization": 1,
      "currentEra": "conway",
      "metrics": {
        "activeConnections": 0,
        "runtimeStats": {
          "cpuTime": 53945188690,
          "currentHeapSize": 804,
          "gcCpuTime": 46822759954,
          "maxHeapSize": 885
        },
        "sessionDurations": {
          "max": 0,
          "mean": 0,
          "min": 0
        },
        "totalConnections": 0,
        "totalMessages": 0,
        "totalUnrouted": 0
      },
      "connectionStatus": "connected",
      "currentEpoch": 1087,
      "slotInEpoch": 33547,
      "version": "v6.11.0 (6356ede9)",
      "network": "preview"
    }
    ```


### 4-3. DBのステータスをチェックする

PostgreSQLに接続します

```bash
docker exec -it db-sync-postgres psql -U postgres -d cexplorer
```

!!! alert "エラーが出る場合"
    dockerコンテナが止まっている可能性があります！
    以下のコマンドでdokcerコンテナを立ち上げてから再度実行してください。

    ```bash
    cd $HOME/midnight-node-docker
    docker compose -f compose-partner-chains.yml up -d
    ```


SQL文を実行します

```sql
SELECT 100 * (
    EXTRACT(EPOCH FROM (MAX(time) AT TIME ZONE 'UTC')) -
    EXTRACT(EPOCH FROM (MIN(time) AT TIME ZONE 'UTC'))
) / (
    EXTRACT(EPOCH FROM (NOW() AT TIME ZONE 'UTC')) -
    EXTRACT(EPOCH FROM (MIN(time) AT TIME ZONE 'UTC'))
) AS sync_percent
FROM block;
```

!!! info "戻り値について"
    以下の例では、99.9999...%同期が完了しています。
    おおよそこの程度同期が完了していればOKです。

    例)
    ```txt
        sync_percent     
    ---------------------
     99.9999016400555159
    (1 row)
    ```

PostgreSQLからログアウトします

```sql
exit
```


### 4-4. 同期が完了するのを待つ

4-2. と 4-3. の両方の同期が完了するまでお待ちください。

両方の同期が完了したら、[Midnight-Nodeの構築](./12-midnight-node.md) に進みます。

