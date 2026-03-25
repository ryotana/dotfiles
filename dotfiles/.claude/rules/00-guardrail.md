# Claude Rule (Guardrail)

IMPORTANT: The rules in this file MUST be strictly followed.
重要: このファイルのルールは最優先で遵守すること。

## 破壊的操作の制限
以下のコマンド・操作は絶対に自動実行せず、必ず確認を求める:
- データベースの DROP / TRUNCATE / ALTER
- Security Groupのingressルール変更

関連ルール:
- Terraform: terraform.md
- Kubernetes: kubernetes.md
- AWS: aws.md

## Google Cloud の破壊的操作
リソースの削除・停止・変更を伴う CLI コマンド（例: `delete-*`, `stop-*`, `update-*`）は、実行前にコマンド全文を提示して承認を待つ。読み取り専用コマンド（`describe-*`, `list-*`, `get-*`）は即時実行してよい。
