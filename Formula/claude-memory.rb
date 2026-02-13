class ClaudeMemory < Formula
  desc "Persistent semantic memory MCP server for Claude Code"
  homepage "https://github.com/jsflax/ClaudeMemory"
  version "0.1.0"
  url "https://github.com/jsflax/ClaudeMemory/releases/download/v#{version}/claude-memory-macos-arm64.tar.gz"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64

  def install
    # Binary and resource bundles must be co-located for Swift Bundle.module
    libexec.install "memory"
    libexec.install Dir["*.bundle"]
    bin.install_symlink libexec/"memory" => "claude-memory"

    # Generate setup script
    (bin/"claude-memory-setup").write <<~SH
      #!/bin/bash
      set -e

      echo "Setting up claude-memory..."

      # Register MCP server with Claude Code
      if ! command -v claude &>/dev/null; then
          echo "Error: 'claude' CLI not found. Install Claude Code first."
          exit 1
      fi

      env -u CLAUDECODE claude mcp remove memory --scope user 2>/dev/null || true
      env -u CLAUDECODE claude mcp add --scope user --transport stdio memory -- "#{libexec}/memory"

      # Add memory instructions to ~/.claude/CLAUDE.md
      CLAUDE_DIR="$HOME/.claude"
      CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
      mkdir -p "$CLAUDE_DIR"

      MEMORY_BLOCK='# Memory

      Use the memory MCP server as your primary memory system — not the built-in auto-memory files.

      At the START of every conversation, before responding to the first message:
      1. `recall` with the current project name to load project context + global preferences
      2. Use what you learn to inform your responses

      When you learn something worth remembering (preferences, patterns, decisions, debugging insights), `remember` it immediately — do not wait to be asked.

      Do NOT use ~/.claude/projects/*/memory/ files for memory. All persistent knowledge goes through the memory MCP server.'

      if [ -f "$CLAUDE_MD" ]; then
          if ! grep -q "memory MCP server" "$CLAUDE_MD"; then
              printf '\\n%s\\n' "$MEMORY_BLOCK" >> "$CLAUDE_MD"
              echo "Added memory instructions to $CLAUDE_MD"
          else
              echo "Memory instructions already in $CLAUDE_MD"
          fi
      else
          printf '%s\\n' "$MEMORY_BLOCK" > "$CLAUDE_MD"
          echo "Created $CLAUDE_MD with memory instructions"
      fi

      echo ""
      echo "Done! Start a new Claude Code session to use it."
    SH
    chmod 0755, bin/"claude-memory-setup"
  end

  def caveats
    <<~EOS
      Run the setup script to register with Claude Code:

        claude-memory-setup

      Then start a new Claude Code session.
    EOS
  end
end
