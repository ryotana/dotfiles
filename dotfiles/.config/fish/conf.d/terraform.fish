set -x TF_PLUGIN_CACHE_DIR "/var/tmp/terraform"
set -x TF_CLI_ARGS_plan "--parallelism=30"
set -x TF_CLI_ARGS_apply "--parallelism=30"

alias t='terraform'
alias tf='tanaform'
