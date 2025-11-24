---
title: Midnight - Midnight-Node 構築手順
---

# Midnight - Midnight-Node 構築手順

## 1. Docker 環境をインストール

!!! warning "注意！"
    Partner-Chains-Node と Midnight-Node を同じサーバーにインストールする場合は、
    手順 5. から実施してください。


### 1-1. aptリポジトリをアップデート
```bash
sudo apt update
```

### aptパッケージをインストール
```bash
sudo apt install ca-certificates curl
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
sudo apt update
```

### Dockerの最新版をインストール
```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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

### 2-6. ログアウトしてもコンテナが起動し続けるようにする
```bash
loginctl enable-linger "$USER"
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
```


## 5. cardano-nodeの鍵を用意する

### 5-1. ディレクトリの作成

```bash
mkdir -p $HOME/midnight-node-docker/cardano-keys
```


### 5-2. 鍵の転送

!!! info "ファイル転送"
    エアギャップマシンの`node.skey`と`payment.vkey`と`payment.skey`をMidnight-Nodeの`cardano-keys`ディレクトリにコピーします。


### 5-3. 鍵ファイル名の変更

Midnightのマニュアル通りに進めるため`node.skey`を`cold.skey`にファイル名を変更します(オプション)

```bash
mv $HOME/midnight-node-docker/cardano-keys/node.skey $HOME/midnight-node-docker/cardano-keys/cold.skey
```


## 6. 環境変数の変更

### 6-1. .envrc ファイルを修正する(1/2)

!!! info "IPアドレスの確認"
    ```bash
    ip -o -4 addr show scope global \
| awk '{print $4}' | cut -d/ -f1 \
| grep -vE '^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.|169\.254\.|127\.)'
    ```


xxx.xxx.xxx.xxx を Partner-Chains-Node の IPアドレスに置き換えて実行する
```
POSTGRES_IP=xxx.xxx.xxx.xxx
```

```bash
sed -i "/^export POSTGRES_HOST=/{ s/^/#/; a\
export POSTGRES_HOST=\"${POSTGRES_IP}\"
}" $HOME/midnight-node-docker/.envrc
```

### 6-2. .envrc ファイルを修正する(2/2)

midnight-nodeコンテナがバリデーターモードで起動するようにフラグを変更する

```bash
sed -i '/^export APPEND_ARGS=/{ s/^/#/; a\
export APPEND_ARGS="--validator --allow-private-ip --pool-limit 10 --trie-cache-size 0 --prometheus-external --unsafe-rpc-external --rpc-methods=Unsafe --rpc-cors all --rpc-port 9944 --keystore-path=/data/chains/partner_chains_template/keystore/"
}' $HOME/midnight-node-docker/.envrc
```


### 6-3. ディレクトリを移動する
```bash
cd $HOME/midnight-node-docker
```
!!! info "エラーが表示されます"
    以下のエラーが表示されますが正常です！
    ```txt
    direnv: error /home/cardano/midnight-node-docker/.envrc is blocked. Run `direnv allow` to approve its content
    ```


### 6-4. 環境変数を反映する

direnvを許可する

```
direnv allow
```


### 6-5. PostgreSQLの接続文字列を確認する
戻り値をメモ帳などにコピーしておいてください
```bash
echo postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_IP}:${POSTGRES_PORT}/${POSTGRES_DB}
```

例) 
> postgresql://postgres:askljdlfkjasdjf@192.168.131.102:5432/cexplorer


## 7. 各種鍵の生成

### 7-1. midnight-nodeシェルの起動

midnight-nodeコンテナが起動します

```bash
$HOME/midnight-node-docker/midnight-shell.sh
```


### 7-2. midnight-nodeシェルから抜ける

cardano-keysディレクトリをmidnight-nodeコンテナにコピーするため、
一度シェルから抜けます

```bash
exit
```


### 7-3. cardano-keysをmidnightコンテナにコピーする

cardano-nodeの鍵をmidnight-nodeコンテナにコピーします

```bash
docker cp cardano-keys/ midnight:cardano-keys
```

> Successfully copied 4.61kB to midnight:cardano-keys


### 7-4. midnight-nodeシェルにログイン

再度シェルにログインします。

```bash
$HOME/midnight-node-docker/midnight-shell.sh
```


### 7-5. 鍵の生成
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


### 7-6. 生成した鍵を移動する



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

### 7-7. chain-spec.jsonを生成する
```bash
/midnight-node wizards create-chain-spec
```

> This wizard will create a chain spec JSON file according to the provided configuration, using WASM runtime code from the compiled node binary.
> Chain parameters:
> - Genesis UTXO: 46876a2250ec0e523eccc30b0fc6d6fa55c61dd200b83140acaab291edeb0b11#0
> SessionValidatorManagement Main Chain Configuration:
> - committee_candidate_address: addr_test1wrdcz9xr2qmywev3rhegnyt0jvud45l2xk2lpkt29wwch2g9vngtm
> - d_parameter_policy_id: 83424b65e444e98e9659f68484ed4c5a97f7cbe1936a8b301fc1b6dd
> - permissioned_candidates_policy_id: 2f459d50b96ac59957d20b36ae967cda64a2174e37c5cdac93af597c
> Native Token Management Configuration (unused if empty):
> - asset name: 0x
> - asset policy ID: 0x00000000000000000000000000000000000000000000000000000000
> - illiquid supply address: addr_test1wq8pepl8k3u0qu073v09fxhlueh8u3c7g42s7r5nfsm5lqqpgghck
> Initial permissioned candidates:
> - Partner Chains Key: 0x03e552997989315bba2e43f827deb2c33d6aad8604ac7c6c19e0aefb7d9209fdfe, AURA: 0xa26b632cfd1302f5565380fd774534563d8cfd1c07b5d8c2d843062231e3e55a, GRANDPA: 0x532ea2b7b59feb933900fff4375a794520a939e811f2c6eee5d55d0b27a33222
> - Partner Chains Key: 0x02fa800af0438c81cb3f5839dbc494a7cfc8fe5bb8f4e2bc8bfa5197c018ed9b1b, AURA: 0x7cb831d9807c6040842d97eaa6fbd19dcf323e143d2d73964ec9319622164009, GRANDPA: 0x5223407a2442f3cc1f1ea6643b6e95785ad243e4530631874c1676e2efd698b5
> - Partner Chains Key: 0x039a13d61bf5489cfc06385799a7c1a7439db2df52b5327e0fc824e2cf4fad46f9, AURA: 0xa87a0186f8219027263713d85d3f90aba4f19dfc0aa2f5f04812e39d73376260, GRANDPA: 0xd3bb8a5a8a68c87fd28605ebb18f8669af8e145b646c91a0633368c0adaf62bc
> - Partner Chains Key: 0x02984d7f7b8d2e87e7677a16e9dfbe22d3eb8aaae779aee63595d92b8d59e9bc85, AURA: 0x7470a459550f7fbffc0e1208242dc4987f1309acda410631b036ee9aa9d3167f, GRANDPA: 0xddd045b0b1cc55c794c985f26faf17b549abdf7741e73f247ada5757a1e80cf7
> - Partner Chains Key: 0x024a9a0bf1891899cfe52d79c6747dfd3d889f36b9ecb72bc59891c63d9595366b, AURA: 0xf86dc65328209de522fba056ed5351f5a80f2b26aef4b5db06fbd161b8c6f66c, GRANDPA: 0x4951bd888beabd69e37119bf2e1a7476372cfd3d800e16025ee899e8eaa144d0
> - Partner Chains Key: 0x0363c535b9bd0147e7f27f80eaa316489d8351d0fe3516f3f12fab84131c9348ad, AURA: 0x7ac79f9fa1aaea57bb2984f4b5c37c8fba7f46a8bbfcabc12ec02a821ce88554, GRANDPA: 0x1bf29e9b4d59220489f1dc02e9c0db4d7881c8bcd4375d4f364226d6a5969fe9
> - Partner Chains Key: 0x033aca8ea193db92e5a36211dad657950d16f08675aa37f4ec617e2e472214e39d, AURA: 0x4400f582064e77fc98a324662e0278306ab269f7f1e1638f43e22d6164b5cc4a, GRANDPA: 0x864128a0050bc7e2ac082a419e4cb2329b8235894bb5dbfc298f37b2f3f51a48
> - Partner Chains Key: 0x021ab62d1f50b8c85f3b1e0960ec6c0a4ff941dc6bd14038153c4c7ea09fe0b131, AURA: 0x1a275e91c23cdbed5b711f194b39e57320f794d92d42ca52743c36edd9b90247, GRANDPA: 0xd3e9efefa9cb73194ca7ffc6d1848506a2cdf01b7cd001596a4831b94a5d3290
> - Partner Chains Key: 0x02682e2bf6153e686e051f02c5d653e24e56a5e9a5c3d28f78ecd9264cc3f35c00, AURA: 0xaa08dc1036dab64115612b7ada1fa0ca9d98cd0bd86744659ec99e95976b5b2e, GRANDPA: 0x701aacad9ed534365b349ea9feae13d3ee24b6d344992b15ea75255c1fb91bde
> - Partner Chains Key: 0x026c8f7b4379aa3737b7bedba87c593561c794dc5b81984ac9e95c837f3b46f0b8, AURA: 0xd6871144cf37573b4ae99d7dfda549750be5463b26cc80ca44195b25a27e1750, GRANDPA: 0x77ecab5385322b96385895da48ae27a7c8933552381206325e6cb8fbcdc8760c
> - Partner Chains Key: 0x03e3153ce92bff084d3fbe876e5d5909bd2036a3ad06ca5a8ade23af5f63373464, AURA: 0xc4d8f3109b6fcf20f63cbe6e28817cab06802a2cd1c6aca52531b41be7b7ff0f, GRANDPA: 0xb843cf064afc532a9bc9889f80735124b59e0fe5f900c97c2bde99051fb56b76
> - Partner Chains Key: 0x03845d8be4649301dd02a2f5388ca7e76b8224eb806e146a321f37b27b711a5b36, AURA: 0x786cb34b6f40b9f2405b12dc078338aa663313257f8d021b22ba9908df91ae71, GRANDPA: 0x90e2e83c2d556ba65fe75a876e953559ee9d218accf683739badce624ba2553f
> ? Do you want to continue? (Y/n)


> Do you want to continue? Yes
running external command: /midnight-node build-spec --disable-default-bootnode > chain-spec.json
command output: 2025-10-30 08:17:29 Building chain spec
chain-spec.json file has been created.
If you are the governance authority, you can distribute it to the validators.
Run 'setup-main-chain-state' command to set D-parameter and permissioned candidates on Cardano.



### 7-8. 
```bash
/midnight-node wizards setup-main-chain-state
```

> This wizard will set or update D-Parameter and Permissioned Candidates on the main chain. Setting either of these costs ADA!
> Will read the current D-Parameter and Permissioned Candidates from the main chain, using 'partner-chains-node ariadne-parameters' command.
> ? DB-Sync Postgres connection string (postgresql://postgres-user:postgres-password@localhost:5432/cexplorer) 

> running external command: /midnight-node ariadne-parameters --base-path /tmp/.tmpCW1quP --chain chain-spec.json --mc-epoch-number 1103
> command output: 2025-10-30 08:20:40 Creating idx_tx_out_address index. This may take a while.

> command output: 2025-10-30 08:30:19 slow statement: execution time exceeded alert threshold summary="CREATE INDEX IF NOT …" db.statement="\n\nCREATE INDEX IF NOT EXISTS idx_tx_out_address ON tx_out USING hash (address)\n" rows_affected=0 rows_returned=0 elapsed=579.276468314s elapsed_secs=579.276468314 slow_threshold=1s
> command output: 2025-10-30 08:30:19 Executing 'CREATE INDEX IF NOT EXISTS idx_ma_tx_out_ident ON ma_tx_out(ident)', this might take a while    
> command output: 2025-10-30 08:30:32 slow statement: execution time exceeded alert threshold summary="CREATE INDEX IF NOT …" db.statement="\n\nCREATE INDEX IF NOT EXISTS idx_ma_tx_out_ident ON ma_tx_out(ident)\n" rows_affected=0 rows_returned=0 elapsed=12.456547337s elapsed_secs=12.456547337 slow_threshold=1s
> command output: 2025-10-30 08:30:32 Index 'idx_ma_tx_out_ident' is created    
> command output: 2025-10-30 08:30:32 Ignoring negative imbalance; this is a value preservation bug if occurring outside testing tt=TokenType(0000000000000000000000000000000000000000000000000000000000000000) val=-200000000000000000
> command output: 2025-10-30 08:30:32 Ignoring negative imbalance; this is a value preservation bug if occurring outside testing tt=TokenType(0000000000000000000000000000000000000000000000000000000000000001) val=-40000000000000000
> command output: 2025-10-30 08:30:32 Ignoring negative imbalance; this is a value preservation bug if occurring outside testing tt=TokenType(0000000000000000000000000000000000000000000000000000000000000002) val=-40000000000000000
> command output: 2025-10-30 08:30:32 Start session 0, epoch 0    
> command output: 2025-10-30 08:30:33 🔨 Initializing Genesis block/state (state: 0xb638…03c9, header-hash: 0x58aa…331a)    
> command output: 2025-10-30 08:30:33 👴 Loading GRANDPA authority set from genesis on what appears to be first startup.    
> command output: 2025-10-30 08:30:33 Essential task `transaction-pool-task-1` failed. Shutting down service.    
> command output: 2025-10-30 08:30:33 Essential task `transaction-pool-task-0` failed. Shutting down service.    
> command output: 2025-10-30 08:30:33 Essential task `txpool-background` failed. Shutting down service.    
> command output: 2025-10-30 08:30:33 Essential task `basic-block-import-worker` failed. Shutting down service.



### 7-9. Midnight-Nodeを登録する step-1/3
```bash
/midnight-node wizards register1
```

> ⚙️ Registering as a committee candidate (step 1/3)
> This wizard will query your UTXOs using address derived from the payment verification key and Ogmios service
> ? Ogmios protocol (http/https)
> http
> https
> [↑↓ to move, enter to select, type to filter]

http を選択する

> ? Ogmis hostname (localhost)

Partner Chains Node の IP アドレスを入力する

> ? Ogmis port (1337)

そのまま Enter。

> ? path to the payment verification file (payment.vkey)

`cardano-keys/payment.vkey` を入力する

> ? Select an UTXO to use as the genesis UTXO:

#0 で終わるUTXOを選択する

![](../assets/midnight/wizards-register1.png)



!!! warning "エラーが出た場合"
    以下のエラーの場合、1行目に表示されている `addr_test1` から始まるアドレスにtADAを送金するとUTXOが作成され次に進めるようになります。
    ```
    ⚙️ Querying UTXOs of addr_test1vqr6945df00pdlcn8rjac6pkfc6elzgdd8qt6te2qmwactqkmweer from Ogmios at http://151.32.151.234:1337...
    ⚠️ No UTXOs found for the given address
    The registering transaction requires at least one UTXO to be present at the address.
    Error: Application(No UTXOs found

    Stack backtrace:
    0: anyhow::error::<impl anyhow::Error>::msg
    1: <partner_chains_cli::register::register1::Register1Cmd as partner_chains_cli::CmdRun>::run
    2: midnight_node::command::run
    3: midnight_node::main
    4: std::sys::backtrace::__rust_begin_short_backtrace
    5: std::rt::lang_start::{{closure}}
    6: core::ops::function::impls::<impl core::ops::function::FnOnce<A> for &F>::call_once
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ops/function.rs:284:13
    7: std::panicking::try::do_call
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/panicking.rs:587:40
    8: std::panicking::try
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/panicking.rs:550:19
    9: std::panic::catch_unwind
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/panic.rs:358:14
    10: std::rt::lang_start_internal::{{closure}}
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/rt.rs:168:24
    11: std::panicking::try::do_call
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/panicking.rs:587:40
    12: std::panicking::try
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/panicking.rs:550:19
    13: std::panic::catch_unwind
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/panic.rs:358:14
    14: std::rt::lang_start_internal
                at ./rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/rt.rs:164:5
    15: main
    16: __libc_start_call_main
                at ./csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    17: __libc_start_main_impl
                at ./csu/../csu/libc-start.c:360:3
    18: _start)
    ```



### 7-10. Midnight-Nodeを登録する step-2/3
```bash
/midnight-node wizards register2 ....
```

![](../assets/midnight/wizards-register2.png)


### 7-11. Midnight-Nodeを登録する step-3/3
```bash
/midnight-node wizards register3 ....
```

![](../assets/midnight/wizards-register3.png)



> Partner Chains Smart Contracts require access to Ogmios. Please provide its configuration.
> Ogmios protocol (http/https) http
> Ogmios hostname 152.53.150.23
> Ogmios port 1337
> 2025-10-30T08:49:59.870623523+00:00 INFO partner_chains_cardano_offchain::register - ✅ Transaction submitted. ID: 9df3fd3d0d9a9cd8fe6bca66f53d46758d9aff1191cd14f1e4b0dd6b9433569d
> 2025-10-30T08:49:59.870644235+00:00 INFO partner_chains_cardano_offchain::await_tx - Probing for transaction output '9df3fd3d0d9a9cd8fe6bca66f53d46758d9aff1191cd14f1e4b0dd6b9433569d#0'
> 2025-10-30T08:50:04.876191105+00:00 INFO partner_chains_cardano_offchain::await_tx - Probing for transaction output '9df3fd3d0d9a9cd8fe6bca66f53d46758d9aff1191cd14f1e4b0dd6b9433569d#0'
> 2025-10-30T08:51:09.971902401+00:00 INFO partner_chains_cardano_offchain::await_tx - Probing for transaction output '9df3fd3d0d9a9cd8fe6bca66f53d46758d9aff1191cd14f1e4b0dd6b9433569d#0'
> 2025-10-30T08:51:14.977857650+00:00 INFO partner_chains_cardano_offchain::await_tx - Probing for transaction output '9df3fd3d0d9a9cd8fe6bca66f53d46758d9aff1191cd14f1e4b0dd6b9433569d#0'
> 2025-10-30T08:51:19.984366002+00:00 INFO partner_chains_cardano_offchain::await_tx - Probing for transaction output '9df3fd3d0d9a9cd8fe6bca66f53d46758d9aff1191cd14f1e4b0dd6b9433569d#0'
> 2025-10-30T08:51:19.989579424+00:00 INFO partner_chains_cardano_offchain::await_tx - Transaction output '9df3fd3d0d9a9cd8fe6bca66f53d46758d9aff1191cd14f1e4b0dd6b9433569d'
> ? Show registration status? (Y/n)

そのまま Enter を押下する




登録ステータスを確認する

![](../assets/midnight/wizards-register-status.png)


### 7-12. midnightコンテナーから抜ける

```bash
exit
```


### 7-13. Midnight-Node を起動する

```bash
cd $HOME/midnight-node-docker
docker compose up -d
```


### 7-14. cardano-keys を削除する

```bash
docker exec midnight rm -r cardano-keys/
```

```bash
rm -r $HOME/midnight-node-docker/cardano-keys
```


## 8. LiveView をインストールする

### 8-1. .envrc に追記する

```bash
echo "export CONTAINER_NAME=\"midnight-node\"" >> .envrc
```
!!! info "エラーが表示されます"
    以下のエラーが表示されますが正常です！
    ```txt
    direnv: error /home/cardano/midnight-node-docker/.envrc is blocked. Run `direnv allow` to approve its content
    ```


### 8-2. 環境変数を反映する
```bash
direnv allow
```


### 8-3. GitHubからLiveView.shをダウンロードする

```bash
cd $HOME/midnight-node-docker
wget https://raw.githubusercontent.com/Midnight-Scripts/Midnight-Live-View/refs/heads/main/LiveView.sh -O LiveView.sh
```


### 8-4. パーミッションを設定する
```bash
chmod +x LiveView.sh
```


### 8-5. パートナー公開鍵をコピーする
```bash
docker cp midnight:partner-chains-public-keys.json ./
```


### 8-6. LiveView を起動する
```bash
./LiveView.sh
```

以下のように表示されれば成功です！

Not Registeredの表記が Registered に変わればブロックを生成し始めます！

![](../assets/midnight/liveview.png)


### 8-7. ショートカットを登録する

`mlive`で起動出来るようにする
```bash
echo alias mlive="'direnv exec "$HOME/midnight-node-docker" $HOME/midnight-node-docker/LiveView.sh'" >> $HOME/.bashrc
source $HOME/.bashrc
```

```bash
mlive
```


## 9. 登録状態を確認する

### 9-1. スクリプトをダウンロードする

```bash
cd $HOME/midnight-node-docker
wget https://raw.githubusercontent.com/Midnight-Scripts/Check_Registration/refs/heads/main/check_registration.sh
```


### 9-2. パーミッションを設定する
```bash
chmod +x check_registration.sh
```


### 9-3. スクリプトを実行する
```bash
./check_registration.sh
```


例)
```
--- Validator Public Keys ---
Sidechain Pub Key: 0x0283155aaddf7691f666f801d52ed9a651de1a39a0eb4292c2029603bb7380ced1
Aura Pub Key: 0xca01c0cee006f9cd0d1a0dc9e078dfe2878360ba7bc30e041d08cc338e4e8d60
Grandpa Pub Key: 0xd1bbf1995f0ed6e76a1bb13075d35879952f8dc26d6eaee3b1cac906d4654522

Fetching current epoch...
Sidechain Epoch: 244696
Mainchain Epoch: 1101

Fetching Ariadne parameters for Mainchain Epoch 1101...

Checking if the Sidechain Public Key is registered in epoch 1101...
❌ Sidechain Public Key (0x0283155aaddf7691f666f801d52ed9a651de1a39a0eb4292c2029603bb7380ced1) is NOT registered in epoch 1101.

Checking future epoch 1103 for registration...
🕒 Your validator will be registered in epoch 1103.
```
