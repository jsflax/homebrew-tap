class Claudecodeirc < Formula
  desc "IRC-style multi-user chat for Claude Code sessions"
  homepage "https://github.com/jsflax/ClaudeCodeIRC"
  version "0.0.1"
  url "https://github.com/jsflax/ClaudeCodeIRC/releases/download/v#{version}/claudecodeirc-darwin-arm64.tar.gz"
  sha256 "02ef1dcf6a57f4f6c73e9ac075165f073b4d7a95f3fde175952bb58f4472b41c"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64
  # Required for hosting Public/Group rooms — Private (LAN-only) rooms
  # don't need it. Brew auto-installs it; runtime resolution is via
  # `which cloudflared` (with /opt/homebrew/bin and /usr/local/bin
  # fallbacks) inside `TunnelManager.resolveCloudflared`.
  depends_on "cloudflared"

  def install
    bin.install "claudecodeirc"
  end

  # Auto-install the `claude` CLI for users who already have Node on
  # PATH. Skipped if `claude` is already present, or if `npm` isn't on
  # PATH (Node-less users — see caveats). The runtime first-run doctor
  # in `claudecodeirc` (Doctor.swift) catches the no-Node case with a
  # clear install hint, so this is best-effort, not load-bearing.
  def post_install
    return if which("claude")
    return unless which("npm")
    system "npm", "install", "-g", "@anthropic-ai/claude-code"
  end

  def caveats
    <<~EOS
      ClaudeCodeIRC needs the `claude` CLI (Anthropic), distributed via npm.
      If `npm` was on PATH at install time, brew installed it for you.

      If not, install Node and rerun:
        brew install node
        brew reinstall jsflax/tap/claudecodeirc

      Or install `claude` directly:
        npm install -g @anthropic-ai/claude-code

      `cloudflared` was installed automatically and is used only when
      hosting Public/Group rooms. Private (LAN-only) rooms work without it.
    EOS
  end

  test do
    # Doctor exits 1 when `claude` is missing from PATH; assert the
    # binary at least starts up enough to print the install hint.
    output = shell_output("PATH=/usr/bin:/bin #{bin}/claudecodeirc 2>&1", 1)
    assert_match "needs `claude`", output
  end
end
