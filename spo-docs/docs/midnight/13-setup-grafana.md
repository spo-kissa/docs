---
title: Midnight - Grafana の設定
---

# Midnight - Grafana の設定

## 1. Grafana のインストール

### 1-1. prometheusのインストール

=== "リレーノード1"

    ```bash
    sudo apt install -y prometheus
    ```

### 1-2. Grafanaのインストール

=== "リレーノード1"

    ```bash
    sudo apt install -y apt-transport-https software-properties-common
    ```

    ```bash
    sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
    ```

    ```bash
    echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" > grafana.list
    sudo mv grafana.list /etc/apt/sources.list.d/grafana.list
    ```

    ```bash
    sudo apt update && sudo apt install -y grafana
    ```


=== "リレーノード1"

    ```bash
    sudo systemctl enable grafana-server.service
    ```

    ```bash
    sudo systemctl enable prometheus.service
    ```
