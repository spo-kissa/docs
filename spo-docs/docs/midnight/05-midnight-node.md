---
title: Midnight - Midnight-Node 構築手順
---

# Midnight - Midnight-Node 構築手順

## 1. Docker 環境をインストール

!!! warning "注意！"
    Partner-Chains-Node と Midnight-Node を同じサーバーにインストールする場合は、
    手順 4-2. から実施してください。


### 1-1. aptリポジトリをアップデート
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
sudo tee /etc/docker/daemon.json <<EOF > /dev/null
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

xxx.xxx.xxx.xxx を Partner-Chains-Node の IPアドレスに置き換えて実行する
```
POSTGRES_IP=xxx.xxx.xxx.xxx
```


```bash
sed -i "/^export POSTGRES_HOST=/{ s/^/#/; a\
export POSTGRES_HOST=\"${POSTGRES_IP}\"
}" $HOME/midnight-node-docker/.envrc
```


```bash
sed -i '/^export APPEND_ARGS=/{ s/^/#/; a\
export APPEND_ARGS="--validator --allow-private-ip --pool-limit 10 --trie-cache-size 0 --prometheus-external --unsafe-rpc-external --rpc-methods=Unsafe --rpc-cors all --rpc-port 9944 --keystore-path=/data/chains/partner_chains_template/keystore/"
}' $HOME/midnight-node-docker/.envrc
```


### 4-3. 
```bash
cd midnight-node-docker
```
!!! info "エラーが表示されます"
    以下のエラーが表示されますが正常です！
    ```txt
    direnv: error /home/cardano/midnight-node-docker/.envrc is blocked. Run `direnv allow` to approve its content
    ```


### 4-4. direnv を許可する
```
direnv allow
```


### 4-5. PostgreSQLのパスワードを確認する
戻り値をメモしておいてください
```bash
echo postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_IP}:${POSTGRES_PORT}/${POSTGRES_DB}
```


## 5. 各種鍵の生成

### 5-1. midnight-nodeシェルの起動
```bash
$HOME/midnight-node-docker/midnight-shell.sh
```


### 5-2. midnight-nodeシェルから抜ける
```bash
exit
```


### 5-3. cardano-keysをmidnight-nodeコンテナにコピーする
```bash
docker cp cardano-keys/ midnight:cardano-keys
```


### 5-1. midnight-nodeシェルの起動
```bash
$HOME/midnight-node-docker/midnight-shell.sh
```


### 5-3. 鍵の生成
```bash
/midnight-node wizards generate-keys
```

そのままEnterキーを押す
> ? node base path (./data)<br />

> 🔑 The following public keys were generated and saved to the partner-chains-public-keys.json file:<br />
> {<br />
>  "sidechain_pub_key": "0x0394730e25efc3eb55db02c1862fbfe8f68fd76c2ca0a2dbd85878ca68526f21fc",<br />
>  "aura_pub_key": "0x52eace6cc1dfd7c64c523c7d735d7165e83bc3a4f6e65048753f6061e4058d08",<br />
>  "grandpa_pub_key": "0xb31475612dcd0342a684172b14f4899a57745f3fd1b7758aa6eab34013a466b4"<br />
> }<br />
> You may share them with your chain governance authority<br />
> if you wish to be included as a permissioned candidate.<br />
> <br />
> ⚙️ Generating network key<br />
> running external command: /midnight-node key generate-node-key --base-path ./data<br />
> command output: Generating key in "./data/chains/undeployed/network/secret_ed25519"<br />
> command output: 12D3KooWRLCiFd99Ts7VA8XBG2XxbV8izq6BgyRtD1G2gJtgcURA<br />
> <br />
> 🚀 All done!<br />


### 5-4. 生成した鍵を移動する
```bash
mv ./data/chains/undeployed ./data/chains/partner_chains_template
```


<!--
### 5-5. 事前設定を実行する
```bash
/midnight-node wizards prepare-configuration
```

> node base path: **`./data`**

> Your bootnode should be accessible via: **`IP address`**

> Enter bootnode TCP port: **`3033`**

> Enter bootnode IP address: **`127.0.0.1`**

> Ogmios protocol (http/https) **`http`**

> Ogmios hostname: **`Partner Chains Node の IP アドレス`**

> Ogmios port: **`1337`**

> path to the payment verification file: **`cardano-keys/payment.vkey`**

> Select an UTXO to use as the genesis UTXO: **`#0 で終わるUTXOを選択する`**

> path to the payment signing key file: **`cardano-keys/payment.skey`**

> Do you want to configure a native token for you Partner Chain?: **`No`**

![](../assets/midnight/wizards-prepare-configuration.png)
-->

### 5-5. chain-spec.jsonを生成する
```bash
/midnight-node wizards create-chain-spec
```


### 5-6. 
```bash
/midnight-node wizards setup-main-chain-state
```


### 5-7. Midnight-Nodeを登録する step-1/3
```bash
/midnight-node wizards register1
```

> Ogmios protocol (http/https): **`http`**

> Ogmios hostname: **`Partner Chains Node の IP アドレス`**

> Ogmios port: **`1337`**

> path to the payment verification file: **`cardano-keys/payment.vkey`**

> Select an UTXO to use as the genesis UTXO: **`#0 で終わるUTXOを選択する`**

![](../assets/midnight/wizards-register1.png)



### 5-8. Midnight-Nodeを登録する step-2/3
```bash
/midnight-node wizards register2 ....
```

![](../assets/midnight/wizards-register2.png)


### 5-9. Midnight-Nodeを登録する step-3/3
```bash
/midnight-node wizards register3 ....
```

![](../assets/midnight/wizards-register3.png)


登録ステータスを確認する

![](../assets/midnight/wizards-register-status.png)



### 5-10. docker-node を起動する
```bash
cd $HOME/midnight-node-docker
docker compose up -d
```


### 5-11. LiveView をインストールする

.envrc に追記する
```bash
echo "export CONTAINER_NAME=\"midnight-node\"" >> .envrc
```
!!! info "エラーが表示されます"
    以下のエラーが表示されますが正常です！
    ```txt
    direnv: error /home/cardano/midnight-node-docker/.envrc is blocked. Run `direnv allow` to approve its content
    ```


direnv を許可する
```bash
direnv allow
```


GitHubからLiveView.shをダウンロードする

```bash
cd $HOME/midnight-node-docker
wget https://raw.githubusercontent.com/Midnight-Scripts/Midnight-Live-View/refs/heads/main/LiveView.sh
```


パーミッションを設定する
```bash
chmod +x LiveView.sh
```


LiveView を起動する
```bash
./LiveView.sh
```

以下のように表示されれば成功です！

![](../assets/midnight/liveview.png)


### 5-12. 登録状態を確認する

スクリプトをダウンロードする

```bash
wget https://raw.githubusercontent.com/Midnight-Scripts/Check_Registration/refs/heads/main/check_registration.sh
```


パーミッションを設定する
```bash
chmod +x check_registration.sh
```


スクリプトを実行する
```bash
./check_registration.sh
```
