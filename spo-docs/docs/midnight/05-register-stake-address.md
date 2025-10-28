---
title: ステークアドレスの登録
---

# ステークアドレスの登録

## ステークアドレスの登録

### ステーク証明書の作成

=== "エアギャップマシン"

    ```bash
    cd $NODE_HOME
    cardano-cli conway stake-address registration-certificate \
        --stake-verification-key-file stake.vkey \
        --key-reg-deposit-amt 2000000 \
        --out-file stake.cert
    ```

!!! info "ファイル転送"
    エアギャップマシンの`stake.cert`をBPの`cnode`ディレクトリにコピーします。


### ステークアドレスの登録

プロトコルパラメータの取得

=== "ブロックプロデューサーノード"

    ```bash
    cd $NODE_HOME
    cardano-cli conway query protocol-parameters \
        $NODE_NETWORK \
        --out-file params.json
    ```


ステーク証明書を作成

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


keyDepositの値を出力

=== "ブロックプロデューサーノード"

    ```bash
    keyDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakeAddressDeposit')
    echo keyDeposit: $keyDeposit
    ```


トランザクション仮ファイルを作成

=== "ブロックプロデューサーノード"

    ```bash
    cardano-cli conway transaction build-raw \
        ${tx_in} \
        --tx-out $(cat payment.addr)+$(( ${total_balance} - ${keyDeposit} )) \
        --invalid-hereafter $(( ${currentSlot} + 10000)) \
        --fee 200000 \
        --out-file tx.tmp \
        --certificate stake.cert
    ```


現在の最低手数料を計算

=== "ブロックプロデューサーノード"

    ```bash
    fee=$(cardano-cli conway transaction calculate-min-fee \
        --tx-body-file tx.tmp \
        --witness-count 2 \
        --output-text \
        --protocol-params-file params.json | awk '{ print $1 }')
    echo fee: $fee
    ```


計算結果を出力

=== "ブロックプロデューサーノード"

    ```bash
    txOut=$((${total_balance}-${keyDeposit}-${fee}))
    echo Change Output: ${txOut}
    ```


ステークアドレスを登録するトランザクションファイルを作成

=== "ブロックプロデューサーノード"

    ```bash
    cardano-cli conway transaction build-raw \
        ${tx_in} \
        --tx-out $(cat payment.addr)+${txOut} \
        --invalid-hereafter $(( ${currentSlot} + 10000)) \
        --fee ${fee} \
        --certificate-file stake.cert \
        --out-file tx.raw
    ```


!!! info "ファイル転送"
    BPの`tx.raw`をエアギャップマシンの`cnode`ディレクトリにコピーします。


=== "エアギャップマシン"

    ```bash
    cd $NODE_HOME
    cardano-cli conway transaction sign \
        --tx-body-file tx.raw \
        --signing-key-file payment.skey \
        --signing-key-file stake.skey \
        $NODE_NETWORK \
        --out-file tx.signed
    ```


!!! info "ファイル転送"
    エアギャップマシンの`tx.signed`をBPの`cnode`ディレクトリにコピーします。

=== "ブロックプロデューサーノード"

    ```bash
    cardano-cli conway transaction submit \
        --tx-file tx.signed \
        $NODE_NETWORK
    ```


