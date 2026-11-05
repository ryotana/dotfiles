set -Ux ANTHROPIC_MODEL "opus"

alias c='claude --model opus --fallback-model sonnet --enable-auto-mode --mcp-config ~/.claude/mcp.json'
alias cl='claude --model haiku --mcp-config ~/.claude/no-mcp.json --tools Read,Glob,Grep,Search,WebFetch,WebSearch'
alias ca='claude agents'
