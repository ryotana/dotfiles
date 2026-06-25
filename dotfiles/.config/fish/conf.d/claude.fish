set -Ux ANTHROPIC_MODEL "claude-opus-4-7[1m]"

alias c='claude --model claude-opus-4-7[1m] --enable-auto-mode --mcp-config ~/.claude/mcp.json'
alias cl='claude --model Haiku --mcp-config ~/.claude/no-mcp.json --tools Read,Glob,Grep,Search,WebFetch,WebSearch'
