set -x KUBECTL_EXTERNAL_DIFF 'colordiff -u'
set -x USE_GKE_GCLOUD_AUTH_PLUGIN True

alias k="kubectl"
alias kb="kubie"

fish_add_path $HOME/.krew/bin
