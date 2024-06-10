require "language/node"

class DashlaneCli < Formula
  desc "Command-line interface for Dashlane"
  homepage "https://dashlane.com"
  url "https://github.com/Dashlane/dashlane-cli/archive/refs/tags/v6.2424.0.tar.gz"
  sha256 "914bf949416521a3823a70847731d16edcc2b37fecf654dc073c0164d5267ba5"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  option "with-corepack", "Use yarn from corepack instead of installing it"

  depends_on "node@18" => :build

  # Needed for node-gyp packages
  depends_on "python" => :build
  depends_on "python-setuptools" => :build

  depends_on "yarn" if !build.with?("corepack")
  depends_on "corepack" if  build.with?("corepack")

  on_macos do
    # macos 12+ only
    depends_on macos: :monterey
  end

  def install
    ENV["COMMIT_HASH"] = "c377153edeacd7a328204fd73cad8a825f228cc3"
    Language::Node.setup_npm_environment
    platform = OS.linux? ? "linux" : "macos"
    system "yarn", "set", "version", "4.2.2"
    system "yarn", "install", "--frozen-lockfile"
    system "yarn", "run", "build"
    system "yarn", "workspaces", "focus", "--production"
    system "yarn", "dlx", "@yao-pkg/pkg@5.12.0", ".",
      "-t", "node18-#{platform}-#{Hardware::CPU.arch}", "-o", "bin/dcli",
      "--no-bytecode", "--public", "--public-packages", "tslib,thirty-two,node-hkdf-sync,vows"
    bin.install "bin/dcli"
  end

  test do
    # Test cli version
    assert_equal version.to_s, shell_output("#{bin}/dcli --version").chomp
  end
end
