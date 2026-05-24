# async-comparison

クラウド環境における非同期処理基盤の設計手法とその性能・コスト効率の定量評価

## 概要

同一の非同期処理タスクをEC2・Lambda・ECS Fargateの3つの実行環境で実装し、
性能・コスト・運用面を定量的に比較する。

## 構成

```
async-comparison/
  ec2/        EC2 + SQSポーリング
  lambda/     Lambda + SQSトリガー
  ecs/        ECS Fargate + SQSポーリング
  results/    計測結果・グラフ
```

## 比較指標

| 指標 | 内容 |
|---|---|
| コスト | 1000件処理あたりのAWS料金 |
| レイテンシ | メッセージ到着〜処理完了までの時間 |
| コールドスタート | 初回起動にかかる時間 |
| スループット | 単位時間あたりの処理件数 |

## 実行環境

| 環境 | 実装方式 |
|---|---|
| EC2 | t3.micro + SQSポーリング |
| Lambda | SQSトリガー（イベント駆動） |
| ECS Fargate | Fargate + SQSポーリング |
