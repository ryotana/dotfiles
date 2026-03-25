# Claude Rule (Kubernetes)

## 規約
- `kubectl delete` / `kubectl drain` / `kubectl cordon` は原則実行せず、実行が必要な際には必ず許可を求める
- `kubectl apply` / `kubectl patch` / `kubectl scale` は本番環境では必ず確認を求める
- `kubectl exec` でのコンテナ内操作は読み取り専用を基本とし、書き込みが必要な場合は許可を求める
- マニフェスト変更後は `kubectl diff` で差分を確認してから適用を提案する

## マニフェスト作成
- `kubectl run` や `kubectl create` の `--dry-run=client -o yaml` でベースを生成し、マニフェストとして管理する
- リソースリクエスト/リミットを必ず設定する
- liveness/readiness probe を設定する
- セキュリティコンテキスト（runAsNonRoot, readOnlyRootFilesystem 等）を意識する

## 調査時
`kubectl` で調査する際は以下の順で確認する:
1. `kubectl get events --sort-by=.lastTimestamp` で直近のイベント
2. `kubectl describe` で対象リソースの状態
3. `kubectl logs` でコンテナログ（`--previous` で前回クラッシュ分も確認）
4. `kubectl top` でリソース使用状況

## 破壊的操作の実行前チェック
`kubectl delete` / `kubectl drain` を提案する際は以下を確認:
1. 対象リソースの依存関係（Service, Ingress, PDB 等）
2. レプリカ数と可用性への影響
3. PodDisruptionBudget の設定状況
4. ロールバック手順（`kubectl rollout undo` またはマニフェスト再適用）
