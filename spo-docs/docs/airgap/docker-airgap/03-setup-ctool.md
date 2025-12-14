---
title: ctool のセットアップ
---

# ctool のセットアップ

## ctool の初期設定

### ctool の起動方法

1. Docker Airgap のコンソール内で以下のコマンドを実行します (実行場所はどこでも構いません)。

```bash
ctool
```

### ctool の初回設定

1. ctool を初めて起動すると下記のように、使用するネットワークを選択する画面が表示されます。
上下キーを使って使用するネットワークを選択し、Enterキーを押して確定します。

**特に理由がなければ `メインネット` を選択してください**

![Network Selection](../../assets/airgap/docker-airgap/ctool/select-network.png)

2. 選択されたネットワークで良いかどうかの確認メッセージが表示されます。
左右またはy/nキーを使って `はい` か `いいえ` を選択してください。

![Network Selection Confirm](../../assets/airgap/docker-airgap/ctool/select-network-confirm.png)

3. 初期化メニューが表示されます

    1. 既存プールのエアギャップを移行する場合は `コールドキーをインポートする` を選択します
    1. 新しいプールを立ち上げる場合は `新規ノードを立ち上げる` を選択します

![Setup Menu](../../assets/airgap/docker-airgap/ctool/initial-setup-menu.png)

4. `airgap-ticker/share` ディレクトリ内に全てのコールドキーファイルを貼り付けます

![Copy Keys](../../assets/airgap/docker-airgap/ctool/copy-key-files.png)

5. Enterキーを押下するとファイルチェックがおこなわれます

キーファイルの一部に問題があれば、以下のような画面になります

![Check Failed](../../assets/airgap/docker-airgap/ctool/check-key-files-failed.png)

6. ファイルチェックに問題がなければインポートを開始できます

![Check Success](../../assets/airgap/docker-airgap/ctool/check-key-files-success.png)

7. キーファイルがエアギャップ内にインポートされます

同時にコールドキーの暗号化をおこなうかどうかを選択できます<br>
※ コールドキーの暗号化については後述します

ここでは `いいえ` を選択します

![Import Success](../../assets/airgap/docker-airgap/ctool/import-key-files-success.png)

8. ctool のメインメニューが表示されます

これで `ctool` の初期化が完了しました

![Main Menu](../../assets/airgap/docker-airgap/ctool/main-menu.png)

### ctool のヘッダーの見方

- Network
  - ネットワークを表します
    - mainnet
    - preprod
    - preview
- CLI
  - cardano-cli のバージョンを表します
- Disk残容量
  - エアギャップが使用出来るディスク残容量
- Calidus Keys
  - Calidus 鍵が保管されているかを表します
- Cold Keys
  - コールド 鍵が保管されているかを表します
    - ENCRYPTED🔒 - 暗号化されている状態
    - YES🔓 - 暗号化されていない状態

### メニューの構成

- ウォレット操作
    - プール報酬(stake.addr)を任意のアドレス(ADAHandle)へ出金
    - プール報酬(stake.addr)をpayment.addrへ出金
    - プール資金(payent.addr)を任意のアドレス(ADAHandle)へ出金
    - ホームへ戻る
    - 終了
- KES更新
- ガバナンス(登録・投票)
    - SPO投票
    - ホームへ戻る
    - 終了
- Calidusキーの発行
- ファイル転送
    - shareディレクトリにコピー
    - shareディレクトリからコピー
    - ホームへ戻る
    - 終了
- 各種設定
    - キーをインポート
    - cardano-cliバージョンアップ
    - ctoolバージョンアップ
    - キー暗号化
    - キー復号化
    - キーハッシュ生成
    - キーハッシュ検証
    - ホームへ戻る
    - 終了
- 終了
