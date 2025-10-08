---
title: Midnight - Cardano Preview Node 構築手順
---

# Midnight - Cardano Preview Node 構築手順

## Cardano Preview Node 構築手順

### 1-1. ユーザーアカウントの作成

現在のユーザーを確認する
```bash
ME=$(whoami)
echo "現在のユーザーは ${ME} です。"
```

ユーザー名を設定する
```bash
NAME=cardano
```

=== "rootユーザーの場合"
    ```bash
    adduser $NAME
    ```
=== "それ以外の場合"
    ```bash
    sudo adduser $NAME
    ```

> New Password:        # ユーザーのパスワードを入力<br />
> Retype new password: # パスワードの確認再入力<br />
> <br /> 
> Enter the new value, or press ENTER for the default<br />
>         Full Name []:<br />
>         Room Number []:<br />
>         Work Phone []:<br />
>         Home Phone []:<br />
>         Other []:<br />
> Is the information correct? [Y/n]:y<br />

ユーザーをsudoグループに追加する
=== "rootユーザーの場合"
    ```bash
    usermod -G sudo $NAME
    ```
=== "それ以外の場合"
    ```bash
    sudo usermod -G sudo $NAME
    ```

ログアウトする
```bash
exit
```

ターミナルのユーザーとパスワードを先ほど作成したユーザーとパスワードに書き換えて再接続します。

ブランケットペーストモードをOFFに設定します。
```bash
echo "set enable-bracketed-paste off" >> ~/.inputrc
```

再度ログアウトして、再接続します


1-2. SSH鍵認証方式へ切り替え

ペアキーの作成
```bash
ssh-keygen -t ed25519 -N '' -C ssh_connect -f ~/.ssh/ssh_ed25519
```

```bash
cd ~/.ssh
ls
```

```bash
cd ~/.ssh/
cat ssh_ed25519.pub >> authorized_keys
chmod 600 authorized_keys
chmod 700 ~/.ssh
```


```bash
sudo vi /etc/ssh/sshd_config
```
