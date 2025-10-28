---
title: アドレスの作成
---

# アドレスの作成

## プール運営で使用するアドレスを作成する

### 支払いアドレスキーの作成

=== "エアギャップマシン"

    ```bash
    cd $NODE_HOME
    cardano-cli conway address key-gen \
        --verification-key-file payment.vkey \
        --signing-key-file payment.skey
    ```

### ステークアドレスキーの作成

=== "エアギャップマシン"

    ```bash
    cardano-cli conway stake-address key-gen \
        --verification-key-file stake.vkey \
        --signing-key-file stake.skey
    ```


### ステークアドレスの作成

=== "エアギャップマシン"

    ```bash
    cardano-cli conway stake-address build \
        --stake-verification-key-file stake.vkey \
        --out-file stake.addr \
        $NODE_NETWORK
    ```


### 支払いアドレスの作成

=== "エアギャップマシン"

    ```bash
    cardano-cli conway address build \
        --payment-verification-key-file payment.vkey \
        --stake-verification-key-file stake.vkey \
        --out-file payment.addr \
        $NODE_NETWORK
    ```


### パーミッションを設定

=== "エアギャップマシン"

    ```bash
    chmod 400 payment.vkey payment.skey stake.vkey stake.skey stake.addr payment.addr
    ```


## 支払い用アドレスに入金

### アドレスファイルを転送

!!! info "ファイル転送"
    エアギャップマシンの`payment.addr`と`stake.addr`をBPの`cnode`ディレクトリにコピーします。


### tADAを請求

支払い用アドレスを表示します
```bash
echo "$(cat $NODE_HOME/payment.addr)"
```

表示されたアドレスを[テストネット用faucet](https://docs.cardano.org/cardano-testnets/tools/faucet)
ページに貼り付けてtADAを請求します。


### tADAの残高確認

=== "ブロックプロデューサーノード"

    ```bash
    cardano-cli conway query utxo \
        --address $(cat $NODE_HOME/payment.addr) \
        $NODE_NETWORK \
        --output-text
    ```

次のような戻りがあれば着金完了です
```txt
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
9358d225224197089ac7cd05f6b4e771b053e6be969cde7a97693b71344ffb83     0        10000000000 lovelace + TxOutDatumNone
```
