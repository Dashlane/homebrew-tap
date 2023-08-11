require "language/node"

class DashlaneCli < Formula
  desc "Command-line interface for Dashlane"
  homepage "https://dashlane.com"
  url "https://github.com/Dashlane/dashlane-cli/archive/refs/tags/v1.12.0.tar.gz"
  sha256 "81894f9aae4dc0a13896f48a04e3546c8f4b64e829798bde93889dc8cde07f8d"
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
