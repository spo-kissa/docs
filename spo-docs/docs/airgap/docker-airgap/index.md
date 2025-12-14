---
title: docker-airgap とは？
---

# docker-airgap とは？

## 概要

Docker を使用して軽量な Ubuntu 環境を全自動で構築します。

同時に `cardano-cli` や `cardano-signer` といった、
コマンドも Ubuntu 環境内に同梱します。

また、Ubuntu 環境内に `ctool` というツールを同梱しており、
このツールを使用することで各種作業が簡単に操作できます。

## ctool の概要

SJGTool (gtool) と組み合わせて使用するように最適化されたツールです。

共有フォルダから `cnode` フォルダにファイルをコピーをしたり、
`cnode` フォルダから共有フォルダにファイルをコピーをする作業を自動化するなど、
一手間、二手間を省く事で作業効率をアップさせます。

## 動作環境

- Windows
- Mac (Intel / Apple Silicon)
- Linux

## GitHub レポジトリ

[https://github.com/spo-kissa/cardano-airgap](https://github.com/spo-kissa/cardano-airgap)
