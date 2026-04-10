# Claude Rule (AWS)

## 認証情報の読み込み
### direnv
`.envrc` が存在する場合、direnvを用いてAWSプロファイルを読み取ること。

- 各ディレクトリに `.envrc` が存在する場合、`direnv exec .` 経由でコマンドを実行する
    - これにより環境ごとのAWSプロファイルが自動的に適用される

```bash
# Terraform
direnv exec . terraform plan

# AWS CLI
direnv exec . aws sts get-caller-identity
```

### aws-vault
`.envrc` が存在しない場合、aws-vaultを用いてAWSプロファイルを読み取ること。
（AWSプロファイル名をコンテキストから推測できない場合、ユーザに確認を行うこと）

```bash
# Terraform
aws-vault exec $profile -- terraform plan

# AWS CLI
aws-vault exec $profile --  aws sts get-caller-identity
```

## 破壊的操作の制限
リソースの削除・停止・変更を伴う CLI コマンド（例: `terminate-instances`, `delete-*`, `stop-*`, `modify-*`, `update-*`）は、実行前にコマンド全文を提示して承認を待つ。読み取り専用コマンド（`describe-*`, `list-*`, `get-*`）は即時実行してよい。

## 本番環境の操作チェックリスト
本番環境への変更を提案する際は以下を確認:
1. ロールバック手順が明確か
2. ダウンタイムの有無と見積もり
3. 影響範囲（依存サービス）
4. 監視アラートへの影響
5. バックアップが取得済みか
6. デプロイ後の検証方法（ヘルスチェック、smoke test）が明確か

## KMS暗号化・復号
可能な限り `~/bin/aws-kms` コマンドを使用する。

```
aws-kms --help
Usage: aws-kms <command> [options]

Commands:
  encrypt, e    Encrypt plaintext using AWS KMS
  decrypt, d    Decrypt ciphertext using AWS KMS

Options:
  -k, --key-id KEY_ID   KMS key ID (encrypt only, required)
  -t, --text TEXT        Input text directly
  -f, --file FILE        Input from file
  -r, --region REGION    AWS region (default: ap-northeast-1)
```
