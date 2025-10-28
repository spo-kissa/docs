---
title: トポロジーファイルの変更
---

# プレビューノードのトポロジー変更

## リレーノードの場合

### ファイアーウォールを開放

```bash
sudo ufw allow 6000/tcp
```
```bash
sudo ufw reload
```

### トポロジーファイル変更

BPのIPとポート番号を設定します

```bash
BP_IP=XXX.XXX.XXX.XXX
BP_PORT=XXXXX
```


```bash
cat > $NODE_HOME/topology.json << EOF
{
  "bootstrapPeers": [
    {
      "address": "preview-node.play.dev.cardano.org",
      "port": 3001
    }
  ],
  "localRoots": [
    {
      "accessPoints": [
        {
          "address": "$BP_IP",
          "port": $BP_PORT
        }
      ],
      "advertise": false,
      "trustable": true,
      "valency": 1
    }
  ],
  "peerSnapshotFile": "peer-snapshot.json",
  "publicRoots": [
    {
      "accessPoints": [],
      "advertise": false
    }
  ],
  "useLedgerAfterSlot": 83116868
}
EOF
```

### cardano-nodeを再起動する

```bash
sudo systemctl restart cardano-node
```


## BPの場合


### トポロジーファイル変更


リレーのIPとポート番号を設定します
```bash
R1_IP=XXX.XXX.XXX.XXX
R1_PORT=6000
```


```bash
cat > $NODE_HOME/topology.json << EOF
{
  "bootstrapPeers": null,
  "localRoots": [
    {
      "accessPoints": [
        {
          "address": "$R1_IP",
          "port": $R1_PORT
        }
      ],
      "advertise": false,
      "trustable": true,
      "valency": 1
    }
  ],
  "publicRoots": [],
  "useLedgerAfterSlot": -1
}
EOF
```

### cardano-nodeを再起動する

```bash
sudo systemctl restart cardano-node
```
