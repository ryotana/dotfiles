set -Ux ANTHROPIC_MODEL "opus"
set -Ux CLAUDE_CODE_DISABLE_MOUSE "1"

alias c='claude --model opus --enable-auto-mode --mcp-config ~/.claude/mcp.json'
alias cl='claude --model Haiku --mcp-config ~/.claude/no-mcp.json --tools Read,Glob,Grep,Search,WebFetch,WebSearch'
