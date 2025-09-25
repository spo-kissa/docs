---
title: エアギャップの作成
---

# エアギャップの作成

!!! summary "エアギャップとは？"
    プール運営で使用する秘密鍵などをオフライン上で管理し、トランザクションに署名する際などに使用します。

!!! warning "構築先について"
    秘密鍵などをオンライン上に保管すると、ハッキングなどによる資金盗難のリスクがあります。
    エアギャップを構築するマシンは普段使用しない専用のマシンを用意し、構築後はオンラインにしないようにしましょう。

## 構築の種類

| 構築環境                | 必要メモリ | 必要ディスク| 外部USBメモリ | 
|------------------------|:---------:|:----------:|:------------:|
| Docker-airgap          | 1 GB      | 512 MB     | 対応         |
| VirtualBox with ctool  | 8 GB      | 30 GB      | 未検証       |
| VirtualBox             | 8 GB      | 30 GB      | 非対応       |
| Ubuntu 24.4 Native     | 


## インストール手順

### Windowsの場合

#### Docker-airgap

- [WindowsでDocker-airgapの構築](01-windows-docker-airgap.md)

#### VirtualBox with ctool

- [WindowsでVirtualBox with ctoolの構築](02-windows-virtualbox-with-ctool.md)

#### VirtualBox


### macの場合

#### Docker-airgap

#### VirtualBox with ctool

#### VirtualBox

