# Claude Rule (Terraform)

## 規約
- `terraform apply` / `terraform destroy` / `terraform state *` は原則実行せず、実行が必要な際には必ず許可を求める
- リソース変更後は `terraform validate` をチェックした上で `terraform fmt` を適用する
- Reconciliation Loop: 一通りコード編集が完了したら `terraform plan` を実行して確認を行う

## コーディングルール
- プロバイダバージョンは既存の制約に従う
- `terraform fmt` に準拠したフォーマットを使用する
- `count` より `for_each` を優先する
- 共通利用可能なリソースは dynamic ブロックを使用する
- 新規IAMリソースは最小権限原則に従い、必要最小限の権限にする

## ステート管理
- ステートファイルを手動で操作しない
    - `terraform state` コマンドの実行前に必ず確認を求める
- リモートバックエンドを基本とする
    - S3 / Google Storage を使用する

## plan出力
`terraform plan` の結果を提示する際は以下を要約する:
1. 差分の概要
2. 追加/変更/削除されるリソース数
3. 不可逆・破壊的変更（destroy → create）の有無
4. ダウンタイムの有無
5. セキュリティに影響する変更の有無

## apply提案時
`terraform apply` の実行を提案する際は、デプロイ後の検証コマンドも併せて提示する。
例: `aws ecs describe-services`, `curl -s https://...`, `kubectl get pods`

## コードスタイル
### 基本ルール

| 項目 | 規則 |
|------|------|
| インデント | スペース2つ |
| フォーマッタ | `terraform fmt` |
| リソース命名 | スネークケース (`aws_vpc.prj_vpc`) |
| 文字コード | UTF-8 |
| 改行コード | LF |
| 末尾改行 | 必須 |
| 末尾空白 | 削除 |

### モジュール作成時のルール
- `main.tf` 先頭にドキュメントコメント (terraform-docsで自動生成)
- すべての変数に `type` と `description` を指定
- オプション変数には `default` を指定
- すべての出力に `description` を指定

### Map参照
可能な限りドット記法を使用する。

```hcl
# 正しい
var.ec2.type
local.ami_id.al2023

# 間違い: ブラケット記法
var.ec2["type"]
local.ami_id["al2023"]
```

### トレイリングカンマ
Mapでは禁止、リストでは必須とする。

```hcl
# Map
locals {
  tags = {
    Name    = "example"
    Project = "test"     # ← カンマなし
  }
}

# リスト
resource "aws_instance" "example" {
  vpc_security_group_ids = [
    aws_security_group.sg1.id,
    aws_security_group.sg2.id,  # ← カンマあり
  ]
}
```

### IAMリソース
IAMリソースでは可能な限り `data.aws_iam_policy_document` リソースを使用し、JSONでの直接記述を避けること。
また、 `aws_iam_role_policy_attachments_exclusive` を用いて意図しないポリシーアタッチを防止すること。
