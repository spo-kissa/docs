---
title: ノードインストール
---

# 1. Ubuntu の初期設定

まず [Ubuntu Server の構築手順](../cardano-node/01-ubuntu-server-setup.md) をおこなってください。


# 2. プレビューノードインストール

!!! info "インストールバージョン"
    | Node   | CLI       | GHC   | Cabal    | CNCLI |
    |--------|-----------|-------|----------|-------|
    | 10.5.3 | 10.11.0.0 | 9.6.7 | 3.12.1.0 | 6.6.0 |


## 2-1. 依存関係インストール

パッケージ情報の更新とアップデート
```bash
sudo apt update -y && sudo apt upgrade -y
```

依存するパッケージをインストール
```bash
sudo apt install git jq bc automake tmux rsync htop curl -y
```
<!--
```bash
sudo apt install git jq bc automake tmux rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf liblmdb-dev -y
```

### Libsodiumをインストール

```bash
mkdir $HOME/git
cd $HOME/git
git clone https://github.com/IntersectMBO/libsodium
cd libsodium
git checkout dbb48cc
./autogen.sh
./configure
make
make check
```

!!! info "戻り値の確認"
    ```txt
    Testsuite summary for libsodium 1.0.18
    ============================================================================
    # TOTAL: 82
    # PASS:  82
    # SKIP:  0
    # XFAIL: 0
    # FAIL:  0
    # XPASS: 0
    # ERROR: 0
    ============================================================================
    ```

インストール
```bash
sudo make install
```

### Spec256k1ライブラリをインストール
```bash
cd $HOME/git
git clone https://github.com/bitcoin-core/secp256k1.git
```

```bash
cd secp256k1/
git checkout acf5c55
./autogen.sh
./configure --prefix=/usr --enable-module-schnorrsig --enable-experimental
make
make check
```

!!! info "戻り値の確認"
    ```txt
    Testsuite summary for libsecp256k1 0.3.2
    ============================================================================
    # TOTAL: 3
    # PASS:  3
    # SKIP:  0
    # XFAIL: 0
    # FAIL:  0
    # XPASS: 0
    # ERROR: 0
    ============================================================================
    ```

インストール
```bash
sudo make install
```


### blstをインストール
1. ダウンロード

```bash
cd $HOME/git
git clone https://github.com/supranational/blst
cd blst
git checkout v0.3.14
./build.sh
```

2. 設定ファイル

```bash
cat > libblst.pc << EOF
prefix=/usr/local
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libblst
Description: Multilingual BLS12-381 signature library
URL: https://github.com/supranational/blst
Version: 0.3.14
Cflags: -I\${includedir}
Libs: -L\${libdir} -lblst
EOF
```

```bash
sudo cp libblst.pc /usr/local/lib/pkgconfig/
```
```bash
sudo cp bindings/blst_aux.h bindings/blst.h bindings/blst.hpp  /usr/local/include/
```
```bash
sudo cp libblst.a /usr/local/lib
```
```bash
sudo chmod u=rw,go=r /usr/local/{lib/{libblst.a,pkgconfig/libblst.pc},include/{blst.{h,hpp},blst_aux.h}}
```

バージョン確認
```bash
cat /usr/local/lib/pkgconfig/libblst.pc | grep Version
```
> Version 0.3.14


### GHCUPインストール

インストール用環境変数設定
```bash
cd $HOME
BOOTSTRAP_HASKELL_NONINTERACTIVE=1
BOOTSTRAP_HASKELL_NO_UPGRADE=1
BOOTSTRAP_HASKELL_INSTALL_NO_STACK=yes
BOOTSTRAP_HASKELL_ADJUST_BASHRC=1
unset BOOTSTRAP_HASKELL_INSTALL_HLS
export BOOTSTRAP_HASKELL_NONINTERACTIVE BOOTSTRAP_HASKELL_INSTALL_STACK BOOTSTRAP_HASKELL_ADJUST_BASHRC
```

インストール
```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | bash
```

cabalをインストール
```bash
source ~/.bashrc
ghcup upgrade
ghcup install cabal 3.12.1.0
ghcup set cabal 3.12.1.0
```

GHCインストール
```bash
ghcup install ghc 9.6.7
ghcup set ghc 9.6.7
```

バージョン確認
```bash
cabal update
cabal --version
ghc --version
```
!!! info バージョン確認
    Cabalバージョン「3.12.1.0」
    GHCバージョン「9.6.7」
-->

## 3-1. バイナリをダウンロード

バイナリをダウンロード
```bash
mkdir -p $HOME/git/cardano-node2
cd $HOME/git/cardano-node2
wget -q https://github.com/IntersectMBO/cardano-node/releases/download/10.5.3/cardano-node-10.5.3-linux.tar.gz
```

解凍する
```bash
tar zxvf cardano-node-10.5.3-linux.tar.gz ./bin/cardano-node ./bin/cardano-cli
```

バージョン確認
```bash
$(find $HOME/git/cardano-node2 -type f -name "cardano-cli") version  
$(find $HOME/git/cardano-node2 -type f -name "cardano-node") version
```

> cardano-cli 10.11.0.0 - linux-x86_64 - ghc-9.6<br />
> git rev 6c034ec038d8d276a3595e10e2d38643f09bd1f2<br />

> cardano-node 10.5.3 - linux-x86_64 - ghc-9.6<br />
> git rev 6c034ec038d8d276a3595e10e2d38643f09bd1f2<br />


バイナリファイルをインストールする
```bash
sudo cp $(find $HOME/git/cardano-node2 -type f -name "cardano-cli") /usr/local/bin/cardano-cli
```
```bash
sudo cp $(find $HOME/git/cardano-node2 -type f -name "cardano-node") /usr/local/bin/cardano-node
```

インストールされたノードバージョンを確認する
```bash
cardano-cli version
cardano-node version
```

> cardano-cli 10.11.0.0 - linux-x86_64 - ghc-9.6<br />
> git rev 6c034ec038d8d276a3595e10e2d38643f09bd1f2<br />

> cardano-node 10.5.3 - linux-x86_64 - ghc-9.6<br />
> git rev 6c034ec038d8d276a3595e10e2d38643f09bd1f2<br />




環境変数を設定しパスを通します
```bash
echo PATH="$HOME/.local/bin:$PATH" >> $HOME/.bashrc
echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> $HOME/.bashrc
echo export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" >> $HOME/.bashrc
echo export NODE_HOME=$HOME/cnode >> $HOME/.bashrc
```

環境変数にネットワークを指定する
```bash
echo export NODE_CONFIG=preview >> $HOME/.bashrc
echo export NODE_NETWORK='"--testnet-magic 2"' >> $HOME/.bashrc
echo export CARDANO_NODE_NETWORK_ID=2 >> $HOME/.bashrc
```

.bashrcを再読み込みする
```bash
source $HOME/.bashrc
```


ノード構成ファイルを取得する

```bash
mkdir $NODE_HOME
cd $NODE_HOME
wget -q https://book.play.dev.cardano.org/environments/preview/byron-genesis.json -O byron-genesis.json
wget -q https://book.play.dev.cardano.org/environments/preview/topology.json -O topology.json
wget -q https://book.play.dev.cardano.org/environments/preview/shelley-genesis.json -O shelley-genesis.json
wget -q https://book.play.dev.cardano.org/environments/preview/alonzo-genesis.json -O alonzo-genesis.json
wget -q https://book.play.dev.cardano.org/environments/preview/conway-genesis.json -O conway-genesis.json
wget -q https://book.play.dev.cardano.org/environments/preview/peer-snapshot.json -O peer-snapshot.json
```

=== "リレーノードの場合"
    ```bash
    wget --no-use-server-timestamps -q https://book.play.dev.cardano.org/environments/preview/config.json -O ${NODE_CONFIG}-config.json
    ```
=== "BPノードの場合"
    ```bash
    wget --no-use-server-timestamps -q https://book.play.dev.cardano.org/environments/preview/config-bp.json -O ${NODE_CONFIG}-config.json
    ```


環境変数を追加し、.bashrcファイルを再読み込みする
```bash
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> $HOME/.bashrc
source $HOME/.bashrc
```

=== "リレーノードの場合"
    リレーノードが使用するポート番号を指定して実行する
    ```bash
    PORT=6000
    ```

    起動スクリプトファイルを作成する
    ```bash
    cat > $NODE_HOME/startRelayNode1.sh << EOF 
    #!/bin/bash
    DIRECTORY=$NODE_HOME
    PORT=${PORT}
    HOSTADDR=0.0.0.0
    TOPOLOGY=\${DIRECTORY}/topology.json
    DB_PATH=\${DIRECTORY}/db
    SOCKET_PATH=\${DIRECTORY}/db/socket
    CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
    /usr/local/bin/cardano-node +RTS -N --disable-delayed-os-memory-return -I0.1 -Iw300 -A16m -F1.5 -H2500M -RTS run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
    EOF
    ```

=== "BPノードの場合"
    BPノードが使用するポート番号を指定して実行する
    ```bash
    PORT=XXXX
    ```

    起動スクリプトファイルを作成する
    ```bash
    cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
    #!/bin/bash
    DIRECTORY=$NODE_HOME
    PORT=${PORT}
    HOSTADDR=0.0.0.0
    TOPOLOGY=\${DIRECTORY}/topology.json
    DB_PATH=\${DIRECTORY}/db
    SOCKET_PATH=\${DIRECTORY}/db/socket
    CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
    /usr/local/bin/cardano-node +RTS -N --disable-delayed-os-memory-return -I0.1 -Iw300 -A16m -F1.5 -H2500M -RTS run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
    EOF
    ```



起動スクリプトに実行権限を付与し、ブロックチェーンとの同期を開始する

=== "リレーノードの場合"
    ```bash
    cd $NODE_HOME
    chmod +x startRelayNode1.sh
    ./startRelayNode1.sh
    ```

=== "BPノードの場合"
    ```bash
    cd $NODE_HOME
    chmod +x startBlockProducingNode.sh
    ./startBlockProducingNode.sh
    ```




サービスユニットファイルを作成する
=== "リレーノードの場合"
    ```bash
    cat > $NODE_HOME/cardano-node.service << EOF 
    # The Cardano node service (part of systemd)
    # file: /etc/systemd/system/cardano-node.service 

    [Unit]
    Description     = Cardano node service
    Wants           = network-online.target
    After           = network-online.target 

    [Service]
    User            = ${USER}
    Type            = simple
    WorkingDirectory= ${NODE_HOME}
    ExecStart       = /bin/bash -c '${NODE_HOME}/startRelayNode1.sh'
    KillSignal=SIGINT
    RestartKillSignal=SIGINT
    TimeoutStopSec=300
    LimitNOFILE=32768
    Restart=always
    RestartSec=5
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=cardano-node

    [Install]
    WantedBy    = multi-user.target
    EOF
    ```

=== "BPノードの場合"
    ```bash
    cat > $NODE_HOME/cardano-node.service << EOF 
    # The Cardano node service (part of systemd)
    # file: /etc/systemd/system/cardano-node.service 

    [Unit]
    Description     = Cardano node service
    Wants           = network-online.target
    After           = network-online.target 

    [Service]
    User            = ${USER}
    Type            = simple
    WorkingDirectory= ${NODE_HOME}
    ExecStart       = /bin/bash -c '${NODE_HOME}/startBlockProducingNode.sh'
    KillSignal=SIGINT
    RestartKillSignal=SIGINT
    TimeoutStopSec=300
    LimitNOFILE=32768
    Restart=always
    RestartSec=5
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=cardano-node

    [Install]
    WantedBy    = multi-user.target
    EOF
    ```

systemdにユニットファイルをコピーする
```bash
sudo cp $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
```
権限を付与する
```bash
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

OS起動時にサービスの自動起動を有効にする
```bash
sudo systemctl daemon-reload
```
```bash
sudo systemctl enable cardano-node
```
```bash
sudo systemctl start cardano-node
```

ログを確認する
```bash
journalctl --unit=cardano-node --follow
```
```bash
sudo systemctl stop cardano-node
```


## Mithrilによる同期

### mithril-clientをダウンロード
```bash
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/input-output-hk/mithril/refs/heads/main/mithril-install.sh | sh -s -- -c mithril-client -d latest -p $HOME/git/
```

### mithril-clientをインストール
```bash
sudo mv $HOME/git/mithril-client /usr/local/bin/mithril-client
```

### バージョン確認
```bash
mithril-client -V
```


### 環境変数を設定
```bash
export AGGREGATOR_ENDPOINT=https://aggregator.testing-preview.api.mithril.network/aggregator
export GENESIS_VERIFICATION_KEY=$(curl -fsSL https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/testing-preview/genesis.vkey)
export ANCILLARY_VERIFICATION_KEY=$(curl -fsSL https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/testing-preview/ancillary.vkey)
```

### 既存DBフォルダを削除
```bash
rm -rf $NODE_HOME/db
```


### 最新スナップショットのダウンロード
```bash
mithril-client cardano-db download \
  --backend v2 \
  --run-mode testing-preview \
  --download-dir "$NODE_HOME" \
  --include-ancillary \
  latest
```


### cardano-node を起動する
```bash
sudo systemctl start cardano-node
```


### journalctl でログを確認する
```bash
journalctl --unit cardano-node -f
```


### glive で起動を確認する
```bash
glive
```


## Guild LiveView

### 
```bash
mkdir $NODE_HOME/scripts
cd $NODE_HOME/scripts
sudo apt install bc tcptraceroute -y
```

```bash
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh
```

=== "リレーノードの場合"
    ```bash
    PORT=`grep "PORT=" $NODE_HOME/startRelayNode1.sh`
    b_PORT=${PORT#"PORT="}
    echo "リレーポートは${b_PORT}です"
    ```

=== "BPノードの場合"
    ```bash
    PORT=`grep "PORT=" $NODE_HOME/startBlockProducingNode.sh`
    b_PORT=${PORT#"PORT="}
    echo "BPポートは${b_PORT}です"
    ```

```bash
sed -i $NODE_HOME/scripts/env \
    -e '1,73s!#CNODE_HOME="/opt/cardano/cnode"!CNODE_HOME=${NODE_HOME}!' \
    -e '1,73s!#CNODE_PORT=6000!CNODE_PORT='${b_PORT}'!' \
    -e '1,73s!#UPDATE_CHECK="Y"!UPDATE_CHECK="N"!' \
    -e '1,73s!#CONFIG="${CNODE_HOME}/files/config.json"!CONFIG="${CNODE_HOME}/'${NODE_CONFIG}'-config.json"!' \
    -e '1,73s!#SOCKET="${CNODE_HOME}/sockets/node.socket"!SOCKET="${CNODE_HOME}/db/socket"!'
```

```bash
echo alias glive="'cd $NODE_HOME/scripts; ./gLiveView.sh'" >> $HOME/.bashrc
source $HOME/.bashrc
```
