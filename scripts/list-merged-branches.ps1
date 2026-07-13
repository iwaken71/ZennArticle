# マージ済みローカルブランチの一覧を表示するスクリプト(表示のみ・削除は行わない)

$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Host "現在のブランチ: $currentBranch"
Write-Host ""
Write-Host "マージ済みローカルブランチ一覧(現在のブランチと HEAD を除く):"

git branch --merged |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and ($_ -notmatch '^\*') -and ($_ -ne $currentBranch) } |
    ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "このスクリプトは一覧表示のみを行います。ブランチの削除は行いません。"

# 削除する場合は git branch -d <名前> を1件ずつ実行
