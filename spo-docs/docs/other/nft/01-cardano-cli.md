---
title: cardano-cliでNFTを発行する
---

# CLIでNFTを発行する


!!! warning "注意"
    現時点でNFTの発行まで確認が取れていません。
    
    参考資料としてご参照ください。


## 1. ポリシー鍵の作成

### 1-1. ポリシー鍵を作成する

```bash
mkdir -p $NODE_HOME/nft/policy
```

```bash
cd $NODE_HOME/nft
cardano-cli address key-gen \
  --verification-key-file policy/policy.vkey \
  --signing-key-file policy/policy.skey
```


## 2. ポリシースクリプトを作成する

### 2-1. キーハッシュを取得する

```bash
KEYHASH=$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)
echo $KEYHASH
```


### 2-2. 現在のスロットを取得する

```bash
TIP=$(cardano-cli query tip --mainnet | jq -r .slot)
```

### 2-3. 締め切りを設定 (例：+600000スロット)

```bash
SLOT_BEFORE=$((TIP + 600000))
```


### 2-4. ポリシーファイルを作成する

```bash
cat > policy/policy.script <<EOF
{
  "type": "all",
  "scripts": [
    { "type": "before", "slot": ${SLOT_BEFORE} },
    { "type": "sig", "keyHash": "${KEYHASH}" }
  ]
}
EOF
```


### 2-5. ポリシーIDを生成する

```bash
cardano-cli conway transaction policyid --script-file policy/policy.script > policy/policy.id
```

### 2-6. ポリシーIDを確認

```bash
POLICY_ID=$(cat policy/policy.id)
echo "POLICY_ID=${POLICY_ID}"
```


## 3. メタデータを作成

### 3-1. トークン名を設定する

（32バイト以内）。日本語など非ASCIIはHEX化が安全

```bash
TOKEN_NAME_TEXT="MyFirstNFT"
TOKEN_NAME_HEX=$(echo -n "${TOKEN_NAME_TEXT}" | xxd -ps -c 200)
```


### 3-2. CIDを設定する

```bash
CID="<あなたのIPFS_CID>"
```


### 3-3. メタデータを作成する

```bash
cat > metadata.json <<EOF
{
  "721": {
    "${POLICY_ID}": {
      "${TOKEN_NAME_TEXT}": {
        "name": "${TOKEN_NAME_TEXT}",
        "image": "ipfs://${CID}",
        "mediaType": "image/png",
        "description": "Hello Cardano Mainnet NFT!"
      }
    },
    "version": "1.0"
  }
}
EOF
```


## 4. ミント

### 4-1. 送信元アドレスを設定する

```bash
FROM_ADDR=$(cat $NODE_HOME/payment.addr)
```

### 4-2. 送信先アドレスを設定する

```bash
TO_ADDR="${FROM_ADDR}"
```

### 4-2. 残高UTxOを確認
```bash
cardano-cli query utxo --address ${FROM_ADDR} --mainnet
```


### 4-3. 使用するTxInを選択
```bash
TX_IN="<TxHash>#<Index>"
```


### 1点ものNFT
```bash
ASSET_UNIT="${POLICY_ID}.${TOKEN_NAME_HEX}"
MINT_QTY="1 ${ASSET_UNIT}"
```


### トランザクションをビルド

```bash
cardano-cli conway transaction build \
  --mainnet \
  --tx-in ${TX_IN} \
  --tx-out "$TXOUT" \
  --mint "1 ${ASSET_UNIT}" \
  --minting-script-file policy/policy.script \
  --required-signer-hash "${POLICY_KEYHASH}" \
  --metadata-json-file metadata.json \
  --change-address "${FROM_ADDR}" \
  --out-file tx.raw
```


### 署名

```bash
cardano-cli conway transaction sign \
  --mainnet \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --signing-key-file policy.skey \
  --out-file tx.signed
```


### 送信

```bash
cardano-cli conway transaction submit --mainnet --tx-file tx.signed
```
