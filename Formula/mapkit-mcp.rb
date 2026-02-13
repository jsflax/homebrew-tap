class MapkitMcp < Formula
  desc "MCP server exposing Apple MapKit to LLMs"
  homepage "https://github.com/jsflax/MapKitMCP"
  version "1.0.0"
  url "https://github.com/jsflax/MapKitMCP/releases/download/v#{version}/mapkit-mcp-darwin-arm64.tar.gz"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64

  def install
    bin.install "MapKitMCP" => "mapkit-mcp"
  end
end
