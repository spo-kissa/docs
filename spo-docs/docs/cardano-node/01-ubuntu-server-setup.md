---
title: Ubuntu Server の構築手順
---

# Ubuntu Server の構築手順

## 1. 作業用ユーザーアカウントを作成

### 1-1. 現在のユーザーを確認する

```bash
ME=$(whoami)
echo "現在のユーザーは ${ME} です。"
```

### 1-2. 新しいユーザー名を設定する
```bash
NAME=cardano
```


### 1-3. 新しいユーザーを作成する
=== "現在のユーザーがrootの場合"
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

### 1-4. ユーザーをsudoグループに追加する
=== "現在のユーザーがrootの場合"
    ```bash
    usermod -G sudo $NAME
    ```
=== "それ以外の場合"
    ```bash
    sudo usermod -G sudo $NAME
    ```

### 1-5. ログアウトする
```bash
exit
```

### 1-6. 新しいユーザーでログインする
ターミナルのユーザーとパスワードを先ほど作成したユーザーとパスワードに書き換えて再接続します。


## 2. ユーザーの設定をする

### 2-1. ブランケットペーストモードをOFFに設定します。
```bash
echo "set enable-bracketed-paste off" >> ~/.inputrc
```

### 2-2. 再度ログアウトして、再接続する
```bash
exit
```


## 3. SSH鍵認証方式へ切り替え

### 3-1. ペアキーの作成
```bash
ssh-keygen -t ed25519 -N '' -C ssh_connect -f ~/.ssh/ssh_ed25519
```

### 3-2. ペアキーの確認
```bash
cd ~/.ssh
ls
```

### 3-3. 公開鍵を利用出来るようにする
```bash
cd ~/.ssh/
cat ssh_ed25519.pub >> authorized_keys
```

### 3-4. 鍵ファイルの権限を設定する
```bash
chmod 600 authorized_keys
chmod 700 ~/.ssh
```

### 3-5. テキストエディタnanoをインストールする
```bash
sudo apt install nano -y
```

### 3-6. sshd_configを書き換える
```bash
sudo sed -i.bak -E '/^[[:space:]]*#/!{
  /^([[:space:]]*)KbdInteractiveAuthentication\b/{ s/^/#/; a\
KbdInteractiveAuthentication no
  }
  /^([[:space:]]*)PasswordAuthentication\b/{ s/^/#/; a\
PasswordAuthentication no
  }
  /^([[:space:]]*)PermitRootLogin\b/{ s/^/#/; a\
PermitRootLogin no
  }
  /^([[:space:]]*)PermitEmptyPasswords\b/{ s/^/#/; a\
PermitEmptyPasswords no
  }
}' /etc/ssh/sshd_config
```

### 3-7. SSHポートを設定する
!!! info
    ポート番号は49513～65535までの数値で設定してください
xxxxxをポート番号に変更して実行する
```bash
SSH_PORT=xxxxx
```

### 3-8. 設定ファイルを書き換える
```bash
sudo sed -i.port -E "s/^#Port[[:space:]]*22([[:space:]].*)?$/Port ${SSH_PORT}/" /etc/ssh/sshd_config
```

### 3-9. 設定ファイルの構文をチェックする
```bash
sudo sshd -t
```

### 3-10. 設定ファイルを再読み込みする
```bash
sudo service sshd reload
```

## 4. ファイアーウォールを有効化する

### 4-1. SSHのポートを確認する
```bash
echo "SSHのポート番号は {$SSH_PORT} です"
```

### 4-2. SSHのポートを開放する
```bash
sudo ufw allow ${SSH_PORT}/tcp
```

### 4-3. ファイアーウォールを有効化
```bash
sudo ufw enable
```

### 4-4. ファイアーウォールの状態を確認する
```bash
sudo ufw status numbered
```

### 4-5. IPv6が有効な場合は(v6)の項目を削除する
```bash
sudo ufw delete 2
```

## 5. システムの自動更新を有効にする

### 5-1. パッケージのインストール
```bash
sudo apt install unattended-upgrades -y
```

### 5-2. 自動更新を有効にする
```bash
sudo dpkg-reconfigure --priority=low unattended-upgrades
```


## 6. Fail2banをインストールする

### 6-1. fail2banをインストールする
```bash
sudo apt install fail2ban -y
```

### 6-2. 設定ファイルを作成する
```bash
sudo tee /etc/fail2ban/jail.local <<EOF >/dev/null
[sshd]
enabled = true
port = {$SSH_PORT}
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF
```

### 6-3. fail2banを再起動する
```bash
sudo systemctl restart fail2ban
```


### 7. Chrony

## 7-1. chronyをインストールする
```bash
sudo apt install chrony -y
```

### 7-2. 設定ファイルを更新する
```bash
sudo tee /etc/chrony/chrony.conf <<EOF >/dev/null
pool time.google.com       iburst minpoll 2 maxpoll 2 maxsources 3 maxdelay 0.3
pool time.facebook.com     iburst minpoll 2 maxpoll 2 maxsources 3 maxdelay 0.3
pool time.euro.apple.com   iburst minpoll 2 maxpoll 2 maxsources 3 maxdelay 0.3
pool time.apple.com        iburst minpoll 2 maxpoll 2 maxsources 3 maxdelay 0.3
pool ntp.ubuntu.com        iburst minpoll 2 maxpoll 2 maxsources 3 maxdelay 0.3

# This directive specify the location of the file containing ID/key pairs for
# NTP authentication.
keyfile /etc/chrony/chrony.keys

# This directive specify the file into which chronyd will store the rate
# information.
driftfile /var/lib/chrony/chrony.drift

# Uncomment the following line to turn logging on.
#log tracking measurements statistics

# Log files location.
logdir /var/log/chrony

# Stop bad estimates upsetting machine clock.
maxupdateskew 5.0

# This directive enables kernel synchronisation (every 11 minutes) of the
# real-time clock. Note that it can’t be used along with the 'rtcfile' directive.
rtcsync

# Step the system clock instead of slewing it if the adjustment is larger than
# one second, but only in the first three clock updates.
makestep 0.1 -1

# Get TAI-UTC offset and leap seconds from the system tz database
leapsectz right/UTC

# Serve time even if not synchronized to a time source.
local stratum 10
EOF
```


### 7-3. ファイアーウォールを開放する
```bash
sudo ufw allow 123/udp
```


### 7-4. 設定を有効にする
```bash
sudo systemctl restart chronyd
```

