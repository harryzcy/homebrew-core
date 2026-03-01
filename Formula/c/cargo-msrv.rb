class CargoMsrv < Formula
  desc "Find the minimum supported Rust version (MSRV) for your project"
  homepage "https://foresterre.github.io/cargo-msrv"
  url "https://github.com/foresterre/cargo-msrv/archive/refs/tags/v0.19.0.tar.gz"
  sha256 "5ff071db3b15ae511a6b062623b60ba3b29c07918d3acdbd903d4b02decfe1fe"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/foresterre/cargo-msrv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "4b2d8f796a65098fb15ad014480c3d9d63c3a27bf8855e3ca9255f9b1a78dcd6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "db80421cf4dc7e651d93a9d40ba9d0663e3f632d952016a1a57222c91687b2dd"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "10634d333d74b448bab6507c259b0d54e7f130a24db37b76325c33a3f137b47a"
    sha256 cellar: :any_skip_relocation, sonoma:        "db66912aef1ab8a2e904eff8f2f5ad595890e7313817ad8310546d59218c55e1"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "359a7b7119bc57ed1e6dc208c28e0b11d7b056728637b652d6f2ee830c8b6c44"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "02c83c4b526fbd17db4605a07c2430d2b87bebcd5035ad97dee6f01f32c7f26a"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    ENV["NO_COLOR"] = "1"

    # Show that we can use a different toolchain than the one provided by the `rust` formula.
    # https://github.com/Homebrew/homebrew-core/pull/134074#pullrequestreview-1484979359
    ENV.prepend_path "PATH", Formula["rustup"].bin
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "beta"

    assert_match version.to_s, shell_output("#{bin}/cargo-msrv --version")

    # Now proceed with creating your crate and calling cargo-msrv
    (testpath/"demo-crate/src").mkpath
    (testpath/"demo-crate/src/main.rs").write "fn main() {}"
    (testpath/"demo-crate/Cargo.toml").write <<~EOS
      [package]
      name = "demo-crate"
      version = "0.1.0"
      edition = "2021"
      rust-version = "1.78"
    EOS

    cd "demo-crate" do
      output = shell_output("#{bin}/cargo-msrv msrv show --output-format human --log-target stdout 2>&1")
      assert_match "name: \"demo-crate\"", output
    end
  end
end
