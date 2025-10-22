---
title: ipfsサーバーの構築方法
---

# ipfsサーバーの構築方法

## 1. Kubo をインストールする

### 1-1. 必要なツールを準備する
```bash
sudo apt update -y
```
```bash
sudo apt install wget tar -y
```


### 1-2. 最新バージョンを確認
```bash
export IPFS_VERSION=$(curl -s https://dist.ipfs.tech/kubo/versions | tail -n 1)
echo $IPFS_VERSION
```


### 1-3. バイナリをダウンロード
```bash
cd $HOME
wget https://dist.ipfs.tech/kubo/${IPFS_VERSION}/kubo_${IPFS_VERSION}_linux-amd64.tar.gz
```


### 1-4. バイナリを解凍
```bash
tar xvf kubo_${IPFS_VERSION}_linux-amd64.tar.gz
```


### 1-5. システムにインストール
```bash
sudo install -m 0755 kubo/ipfs /usr/local/bin/ipfs
```


### 1-6. インストールしたバージョンを確認
```bash
ipfs version
```


### 1-7. ダウンロードファイルを削除
```bash
rm kubo_${IPFS_VERSION}_linux-amd64.tar.gz
rm -r kubo
```



## 2. 動作確認

### 2-1. リポジトリを作成
```bash
ipfs init --profile=server
```


### 2-2. ノード起動(デーモン)
```bash
ipfs daemon
```
!!! info "ログを確認"
    `Daemon is ready` と表示されていればOK。


### ピアIPを表示する

新しいターミナルで接続し以下のコマンドを実行する

```bash
ipfs id
```
!!! info "戻り値を確認"
    ピアIDが表示されれば稼働中です！


### ファイルをアップしてみる
```bash
echo "Hello IPFS" > test.txt
ipfs add test.txt
```
> CIDが表示される

curl http://127.0.0.1:8080/ipfs/CID
> "Hello IPFS" が表示されればOK！



## 3. systemdで常駐化する

### 3-1. 専用のユーザーを作成する
```bash
sudo useradd -r -m -d /var/ipfs -s /usr/sbin/nologin ipfs
```


### 3-2. 専用のユーザーでリポジトリを初期化する
```bash
sudo -u ipfs ipfs init --profile=server
```


### 3-3. serviceファイルを作成する
```bash
sudo tee /etc/systemd/system/ipfs.service > /dev/null <<'EOF'
[Unit]
Description=IPFS daemon
After=network-online.target
Wants=network-online.target

[Service]
User=ipfs
Group=ipfs
ExecStart=/usr/local/bin/ipfs daemon --migrate=true
Restart=always
LimitNOFILE=102400
WorkingDirectory=/var/ipfs

[Install]
WantedBy=multi-user.target
EOF
```


### 3-4. サービスを有効化する
```bash
sudo systemctl daemon-reload
```
```bash
sudo systemctl enable --now ipfs
```


### 3-5. ファイアーウォールを開放する
```bash
sudo ufw allow 4001/tcp
```
```bash
sudo ufw allow 4001/udp
```
```bash
sudo ufw allow 8080/tcp
```
