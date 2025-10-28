---
title: ステークプールの登録
---

# ステークプールの登録

## メタデータの用意

### メタデータの作成

メタデータはmainnetと同じものを利用可能です。


### メタデータのダウンロード

=== "ブロックプロデューサーノード"

    ```bash
    cd $NODE_HOME
    wget https://www.publickey.co.jp/files/pool-ex.json -O poolMetaData.json
    ```


### メタデータJSONをチェック

=== "ブロックプロデューサーノード"

    ```bash
    cat $NODE_HOME/poolMetaData.json | jq .
    ```


### メタデータのハッシュ値を計算

=== "ブロックプロデューサーノード"

    ```bash
    cd $NODE_HOME
    cardano-cli conway stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
    ```


## プール登録証明書の作成

### ファイルの転送

!!! info "ファイル転送"
    BPの`vrf.vkey`と`poolMetaDataHash.txt`をエアギャップマシンの`cnode`ディレクトリにコピーします。


### プール登録証明書を作成

以下は、誓約100ADA、固定手数料170ADA、変動手数料5%の場合の例です。

=== "エアギャップマシン"

    ```bash
    cd $NODE_HOME
    cardano-cli conway stake-pool registration-certificate \
        --cold-verification-key-file $HOME/cold-keys/node.vkey \
        --vrf-verification-key-file vrf.vkey \
        --pool-pledge 100000000 \
        --pool-cost 170000000 \
        --pool-margin 0.05 \
        --pool-reward-account-verification-key-file stake.vkey \
        --pool-owner-stake-verification-key-file stake.vkey \
        $NODE_NETWORK \
        --pool-relay-ipv4 xxx.xxx.xxx.xxx \
        --pool-relay-port 6000 \
        --metadata-url https://www.publickey.co.jp/files/pool-ex.json \
        --metadata-hash $(cat poolMetaDataHash.txt) \
        --out-file pool.cert
    ```


### 委任証明書を作成

自身のステークプールに委任する証明書を作成します

=== "エアギャップマシン"

    ```bash
    cardano-cli conway stake-address stake-delegation-certificate \
        --stake-verification-key-file stake.vkey \
        --cold-verification-key-file $HOME/cold-keys/node.vkey \
        --out-file deleg.cert
    ```

!!! info "ファイル転送"
    エアギャップマシンの`pool.cert`と`deleg.cert`をBPの`cnode`ディレクトリにコピーします。


## プール登録

プール登録トランザクションを送信します。

=== "ブロックプロデューサーノード"

    ```bash
    cd $NODE_HOME
    currentSlot=$(cardano-cli conway query tip $NODE_NETWORK | jq -r '.slot')
    echo Current Slot: $currentSlot
    ```


payment.addrの残高を出力

=== "ブロックプロデューサーノード"

    ```bash
    cardano-cli conway query utxo \
        --address $(cat payment.addr) \
        $NODE_NETWORK \
        --output-text \
        --out-file fullUtxo.out

    tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out
    cat balance.out
    ```


UTXOを算出

=== "ブロックプロデューサーノード"

    ```bash
    tx_in=""
    total_balance=0
    while read -r utxo; do
        in_addr=$(awk '{ print $1 }' <<< "${utxo}")
        idx=$(awk '{ print $2 }' <<< "${utxo}")
        utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
        total_balance=$((${total_balance}+${utxo_balance}))
        echo TxHash: ${in_addr}#${idx}
        echo ADA: ${utxo_balance}
        tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
    done < balance.out
    txcnt=$(cat balance.out | wc -l)
    echo Total ADA balance: ${total_balance}
    echo Number of UTXOs: ${txcnt}
    ```


デポジットを出力

=== "ブロックプロデューサーノード"

    ```bash
    poolDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakePoolDeposit')
    echo poolDeposit: $poolDeposit
    ```


トランザクション仮ファイルを作成

=== "ブロックプロデューサーノード"

    ```bash
    cardano-cli conway transaction build-raw \
        ${tx_in} \
        --tx-out $(cat payment.addr)+$(( ${total_balance} - ${poolDeposit})) \
        --invalid-hereafter $(( ${currentSlot} + 10000)) \
        --fee 200000 \
        --certificate-file pool.cert \
        --certificate-file deleg.cert \
        --out-file tx.tmp
    ```


最低手数料を計算

=== "ブロックプロデューサーノード"

    ```bash
    fee=$(cardano-cli conway transaction calculate-min-fee \
        --tx-body-file tx.tmp \
        --witness-count 3 \
        --output-text \
        --protocol-params-file params.json | awk '{ print $1 }')
    echo fee: $fee
    ```


計算結果を出力

=== "ブロックプロデューサーノード"

    ```bash
    txOut=$((${total_balance}-${poolDeposit}-${fee}))
    echo txOut: ${txOut}
    ```


トランザクションファイルを作成

=== "ブロックプロデューサーノード"

    ```bash
    cardano-cli conway transaction build-raw \
        ${tx_in} \
        --tx-out $(cat payment.addr)+${txOut} \
        --invalid-hereafter $(( ${currentSlot} + 10000)) \
        --fee ${fee} \
        --certificate-file pool.cert \
        --certificate-file deleg.cert \
        --out-file tx.raw
    ```

!!! info "ファイル転送"
    BPの`tx.raw`をエアギャップマシンの`cnode`ディレクトリにコピーします。


### トランザクションに署名

=== "エアギャップマシン"

    ```bash
    cd $NODE_HOME
    cardano-cli conway transaction sign \
        --tx-body-file tx.raw \
        --signing-key-file payment.skey \
        --signing-key-file $HOME/cold-keys/node.skey \
        --signing-key-file stake.skey \
        $NODE_NETWORK \
        --out-file tx.signed
    ```


!!! info "ファイル転送"
    エアギャップマシンの`tx.signed`をBPの`cnode`ディレクトリにコピーします。


### トランザクションを送信

=== "ブロックプロデューサーノード"

    ```bash
    cardano-cli conway transaction submit \
        --tx-file tx.signed \
        $NODE_NETWORK
    ```


## プール登録確認

### ステークプールIDを出力

=== "エアギャップマシン"

    ```bash
    chmod u+rwx $HOME/cold-keys
    cardano-cli conway stake-pool id --cold-verification-key-file $HOME/cold-keys/node.vkey --output-format bech32 --out-file pool.id-bech32
    cardano-cli conway stake-pool id --cold-verification-key-file $HOME/cold-keys/node.vkey --output-format hex --out-file pool.id
    chmod a-rwx $HOME/cold-keys
    ```

!!! info "ファイル転送"
    エアギャップマシンの`pool.id-bech32`と`pool.id`をBPの`cnode`ディレクトリにコピーします。


### Koios APIで登録確認

=== "ブロックプロデューサーノード"

    ```bash
    curl -s -X POST "https://preview.koios.rest/api/v1/pool_info" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d '{"_pool_bech32_ids":["'$(cat $NODE_HOME/pool.id-bech32)'"]}' | jq .
    ```


### Cardanoscanで登録確認

=== "ブロックプロデューサーノード"

    ```bash
    cd $NODE_HOME
    echo $(cat pool.id-bech32)
    ```

表示されたプールIDで次のサイトで確認してください。

[Cardanoscan](https://preview.cardanoscan.io/)
