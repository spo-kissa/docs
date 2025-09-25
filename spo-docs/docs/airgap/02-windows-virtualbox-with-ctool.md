---
title: WindowsでVirtualBox with ctoolの環境構築
---

# WindowsでVirtualBox with ctoolの環境構築

## 1. Ubuntu の入手

- [Ubuntu 22.04.5 LTS の入手](https://releases.ubuntu.com/22.04/)

1-1. 以下の画像の赤く囲ったところを押下してダウンロードします。

![](../assets/airgap/download-ubuntu-22.04.png)

| ファイル名 |
|-----------|
| ubuntu-22.04.5-desktop-amd64.iso |



## 2. VirtualBox の入手

- [Oracle VirtualBox 7.1.10 の入手](https://www.oracle.com/jp/virtualization/technologies/vm/downloads/virtualbox-downloads.html)

1-1. 以下の画像の赤く囲ったところを押下してダウンロードします。

![](../assets/airgap/download-virtualbox-for-windows.png)


| ファイル名 |
|-----------|
| VirtualBox-7.1.10-169112-Win.exe |


## 3. VirtualBox のインストール

3-1. ダウンロードしたVirtualBoxのインストーラーをダブルクリックし起動します。

![](../assets/airgap/virtualbox-installer.png)

3-2. 以下の画面が表示されたら、「Next >」を押下します。

![](../assets/airgap/virtualbox-installer-wizard-01.png)

3-3. 以下の画面では、「I accept the term in the License Agreement」にチェックをし、「Next >」を押下します。
![](../assets/airgap/virtualbox-installer-wizard-02.png)

3-4. 以下の画面では、「Next >」を押下します。
![](../assets/airgap/virtualbox-installer-wizard-03.png)

3-5. 以下の画面では、「Yes」を押下します。
![](../assets/airgap/virtualbox-installer-wizard-04.png)

3-6. 以下の画面では、「Yes」を押下します。
![](../assets/airgap/virtualbox-installer-wizard-05.png)

3-7. 以下の画面では、「Next >」を押下します。
![](../assets/airgap/virtualbox-installer-wizard-06.png)

3-8. 以下の画面では、「Install」を押下します。
![](../assets/airgap/virtualbox-installer-wizard-07.png)

3-9. 以下の画面では、次の画面に切り替わるまで待ちます。
![](../assets/airgap/virtualbox-installer-wizard-08.png)

3-10. 以下の画面では、「Finish」を押下します。
![](../assets/airgap/virtualbox-installer-wizard-09.png)

3-11. VirtualBox の管理画面が起動すれば、インストール完了です。
![](../assets/airgap/virtualbox-window.png)


## 4. VirtualBox仮想マシンの作成

4-1. 以下の画像の赤く囲った「新規(N)」ボタンを押下し、仮想マシンの作成を開始します。

![](../assets/airgap/virtualbox-windows-new-machine.png)


4-2. 仮想マシンの名前とOS

「仮想マシンの名前とOS」設定画面で、以下の表のように設定し「次へ(N)」を押下します。

| 項目                    | 指定値                                      |
|-------------------------|--------------------------------------------|
| 名前                    | 任意の仮想マシン名                           |
| ISO イメージ             | 1でダウンロードした Ubuntu ISO ファイルを指定 |
| 自動インストールをスキップ | チェックをする                             |

![](../assets/airgap/virtualbox-windows-new-machine-wizard-01.png)


4-3. 仮想マシンのハードウェア

「ハードウェア」設定画面で、以下の表を参考に設定し「次へ(N)」を押下します。

| 項目          | 指定値       |
|---------------|-------------|
| メインメモリー | 4096 MB 以上 |
| プロセッサー数 | 2 CPU 以上   |

以下の画像では、PCに余裕があったため、各値を2倍に設定しています。

![](../assets/airgap/virtualbox-windows-new-machine-wizard-02.png)


4-4. 仮想マシンの仮想ハードディスク

「仮想ハードディスク」設定画面で、ディスクサイズを50GBに設定し「次へ(N)」を押下します。

![](../assets/airgap/virtualbox-windows-new-machine-wizard-03.png)


4-5. 仮想マシンの概要

「概要」画面で、仮想マシンの概要を確認し、「完了(F)」を押下します。

![](../assets/airgap/virtualbox-windows-new-machine-wizard-04.png)


## 5. VirtualBox仮想マシンの環境設定

5-1. 作成した仮想マシン(今回は Airgap)を選択し、「設定」を押下します。

![](../assets/airgap/virtualbox-windows-edit-machine.png)


5-2. 

![](../assets/airgap/virtualbox-windows-edit-machine-general.png)


5-3.

![](../assets/airgap/virtualbox-windows-edit-machine-system.png)


5-4.

![](../assets/airgap/virtualbox-windows-edit-machine-share.png)


5-5.

![](../assets/airgap/virtualbox-windows-edit-machine-share-new.png)


## 6. Ubuntu のインストール

6-1.

![](../assets/airgap/virtualbox-windows-boot.png)



6-2.

![](../assets/airgap/virtualbox-ubuntu-install-01.png)


6-3.

![](../assets/airgap/virtualbox-ubuntu-install-02.png)


6-4.

![](../assets/airgap/virtualbox-ubuntu-install-03.png)


6-5.

![](../assets/airgap/virtualbox-ubuntu-install-04.png)


6-6.

![](../assets/airgap/virtualbox-ubuntu-install-05.png)


6-7.

![](../assets/airgap/virtualbox-ubuntu-install-06.png)


6-8.
![](../assets/airgap/virtualbox-ubuntu-install-07.png)


6-9.
![](../assets/airgap/virtualbox-ubuntu-install-08.png)


6-10.

![](../assets/airgap/virtualbox-ubuntu-install-09.png)


6-11.

![](../assets/airgap/virtualbox-ubuntu-install-10.png)


6-12.

![](../assets/airgap/virtualbox-ubuntu-install-11.png)


6-13.

![](../assets/airgap/virtualbox-ubuntu-install-12.png)


6-14.

![](../assets/airgap/virtualbox-ubuntu-install-13.png)


6-15.

![](../assets/airgap/virtualbox-ubuntu-install-14.png)


6-16.

![](../assets/airgap/virtualbox-ubuntu-install-15.png)


6-17.

![](../assets/airgap/virtualbox-ubuntu-install-16.png)


6-18.

![](../assets/airgap/virtualbox-ubuntu-install-17.png)


6-19.

![](../assets/airgap/virtualbox-ubuntu-install-18.png)


6-20.

![](../assets/airgap/virtualbox-ubuntu-install-19.png)


6-21.

![](../assets/airgap/virtualbox-ubuntu-install-20.png)


## 7. Guest Addtions のインストール & 設定

7-1.

![](../assets/airgap/virtualbox-ubuntu-guest-additions-01.png)


7-2.

![](../assets/airgap/virtualbox-ubuntu-guest-additions-02.png)


7-3.

![](../assets/airgap/virtualbox-ubuntu-guest-additions-03.png)


7-4.

![](../assets/airgap/virtualbox-ubuntu-guest-additions-04.png)

