require "language/node"

class DashlaneCli < Formula
  desc "Command-line interface for Dashlane"
  homepage "https://dashlane.com"
  url "https://github.com/Dashlane/dashlane-cli/archive/refs/tags/v6.2416.0.tar.gz"
  sha256 "595026a52f8c8021078d0ab166fb50c920ef5fbe35cd539844c387621fe7c91c"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "node@18" => :build
  depends_on "yarn" => :build

  on_macos do
    # macos 12+ only
    depends_on macos: :monterey
  end

  def install
    Language::Node.setup_npm_environment
    platform = OS.linux? ? "linux" : "macos"
    system "yarn", "set", "version", "4.0.2"
    system "yarn", "install", "--frozen-lockfile"
    system "yarn", "run", "build"
    system "yarn", "workspaces", "focus", "--production"
    system "yarn", "dlx", "@yao-pkg/pkg@5.11.1", ".",
      "-t", "node18-#{platform}-#{Hardware::CPU.arch}", "-o", "bin/dcli",
      "--no-bytecode", "--public", "--public-packages", "tslib,thirty-two"
    bin.install "bin/dcli"
  end

  test do
    # Test cli version
    assert_equal version.to_s, shell_output("#{bin}/dcli --version").chomp
  end
end
