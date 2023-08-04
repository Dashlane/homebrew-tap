require "language/node"

class DashlaneCli < Formula
  desc "Command-line interface for Dashlane"
  homepage "https://dashlane.com"
  url "https://github.com/Dashlane/dashlane-cli/archive/refs/tags/v1.10.0.tar.gz"
  sha256 "d750387025b14d84ec0f83db06b9f91f7f6d9c63e11bab059b4fdcd9a49f01e8"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "node@16" => :build
  depends_on "yarn" => :build

  on_macos do
    # macos requires binaries to do codesign
    depends_on xcode: :build
    # macos 12+ only
    depends_on macos: :monterey
  end

  def install
    Language::Node.setup_npm_environment
    platform = OS.linux? ? "linux" : "macos"
    system "yarn", "set", "version", "berry"
    system "yarn"
    system "yarn", "run", "build"
    system "yarn", "workspaces", "focus", "--production"
    system "yarn", "dlx", "pkg", ".",
      "-t", "node16-#{platform}-#{Hardware::CPU.arch}", "-o", "bin/dcli",
      "--no-bytecode", "--public", "--public-packages", "tslib,thirty-two"
    bin.install "bin/dcli"
  end

  test do
    # Test cli version
    assert_equal version.to_s, shell_output("#{bin}/dcli --version").chomp
  end
end
