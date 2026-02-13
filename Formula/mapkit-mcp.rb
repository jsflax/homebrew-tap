class MapkitMcp < Formula
  desc "MCP server exposing Apple MapKit to LLMs"
  homepage "https://github.com/jsflax/MapKitMCP"
  version "1.0.0"
  url "https://github.com/jsflax/MapKitMCP/releases/download/v#{version}/mapkit-mcp-darwin-arm64.tar.gz"
  sha256 "d86a31c67c134a397d5e6afb6afc987d6df79618db0cab87528b45d63000d589"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64

  def install
    bin.install "MapKitMCP" => "mapkit-mcp"
  end

  def post_install
    claude = which("claude")
    return unless claude

    system claude, "mcp", "add", "--scope", "user", "mapkit", bin/"mapkit-mcp"
  end

  def caveats
    <<~EOS
      To register with Claude Code manually:
        claude mcp add mapkit #{bin}/mapkit-mcp
    EOS
  end
end
