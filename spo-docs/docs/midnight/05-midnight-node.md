---
title: Midnight - Midnight-Node 構築手順
---

# Midnight - Midnight-Node 構築手順

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

### 3-2. .bashrc に追記する
```bash
cat <<EOF >> ~/.bashrc
eval "\$(direnv hook bash)"
EOF
```

### 3-3. .bashrc を再読み込み
```bash
source ~/.bashrc
```

## 4. midnight-node-docker リポジトリをクローン

### 4-1. リポジトリをクローンする
```bash
cd $HOME
git clone https://github.com/midnightntwrk/midnight-node-docker.git
cd midnight-node-docker
```

### 4-2. .envrc ファイルを修正する
```bash
sed -i '/^export APPEND_ARGS=/{ s/^/#/; a\
export APPEND_ARGS="--validator --allow-private-ip --pool-limit 10 --trie-cache-size 0 --prometheus-external --unsafe-rpc-external --rpc-methods=Unsafe --rpc-cors all --rpc-port 9944 --keystore-path=/data/chains/partner_chains_template/keystore/"
}' $HOME/midnight-node-docker/.envrc
```


### 4-3. direnv を許可する
```bash
direnv allow
```

### 4-4. PostgreSQLのパスワードを確認する
戻り値をメモしておいてください
```bash
echo $(cat postgres.password)
```


## 5. 各種鍵の生成

### 5-1. midnightシェルの起動
```bash
$HOME/midnight-node-docker/midnight-shell.sh
```

### 5-2. midnightシェルからぬける
```bash
exit
```

### 5-3. cardano-keysをmidnightコンテナにコピーする
```bash
docker cp cardano-keys/ midnight:cardano-keys
```

### 5-3. 鍵の生成
```bash
/midnight-node wizards generate-keys
```

そのままEnterキーを押す
> ? node base path (./data)


> 🔑 The following public keys were generated and saved to the partner-chains-public-keys.json file:
> {
>  "sidechain_pub_key": "0x0394730e25efc3eb55db02c1862fbfe8f68fd76c2ca0a2dbd85878ca68526f21fc",
>  "aura_pub_key": "0x52eace6cc1dfd7c64c523c7d735d7165e83bc3a4f6e65048753f6061e4058d08",
>  "grandpa_pub_key": "0xb31475612dcd0342a684172b14f4899a57745f3fd1b7758aa6eab34013a466b4"
> }
> You may share them with your chain governance authority
> if you wish to be included as a permissioned candidate.
> 
> ⚙️ Generating network key
> running external command: /midnight-node key generate-node-key --base-path ./data
> command output: Generating key in "./data/chains/undeployed/network/secret_ed25519"
> command output: 12D3KooWRLCiFd99Ts7VA8XBG2XxbV8izq6BgyRtD1G2gJtgcURA
> 
> 🚀 All done!


### 5-4. 生成した鍵を移動する
```bash
mv ./data/chains/undeployed ./data/chains/partner_chains_template
```

### 5-5. 事前設定を実行する
```bash
/midnight-node wizards prepare-configuration
```


### 5-6. chain-spec.jsonを生成する
```bash
/midnight-node wizards create-chain-spec
```


### 5-7. 
```bash
/midnight-node wizards setup-main-chain-state
```


```bash
/midnight-node wizards register1
```


postgresql://postgres:3335cf03a37649c1@152.53.154.72:5432/cexplorer

