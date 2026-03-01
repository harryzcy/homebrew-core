class Ldc < Formula
  desc "Portable D programming language compiler"
  homepage "https://wiki.dlang.org/LDC"
  url "https://github.com/ldc-developers/ldc/releases/download/v1.42.0/ldc-1.42.0-src.tar.gz"
  sha256 "9bb0f628f869f7fc7b53c381a79742d29c17552c6f1a56b0a02aa289e65a0e3b"
  license "BSD-3-Clause"
  head "https://github.com/ldc-developers/ldc.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256                               arm64_tahoe:   "96c0f02aeb8b0fce7754eb723fdaa3d6cc09e12b5f58bccc242ae5b8c10eaa30"
    sha256                               arm64_sequoia: "f0c2dbbdcae4b980065505ff72a20a0a29dae7dfe8afdeb7a94711d8e6dd46fc"
    sha256                               arm64_sonoma:  "547c3c670bf11396c3efdb637133fdfcc75b392b6ea0b191060e4fbfac44cd36"
    sha256                               arm64_ventura: "741d5a458d0b7eba1166852d930a2f5ed2b0c6d473693b715ac8cafc412b6805"
    sha256                               sonoma:        "b289f81361bd6543932310bd415a083b8591ba9cf63c5d2a7b8fa601cb17d678"
    sha256                               ventura:       "a7b1ee1863969e05c904f83ae66a796b19b10ac3518e0c7522735876bf6cf80e"
    sha256                               arm64_linux:   "c9538d69c75aeb7b4c4f79272159b8cb441d9758a8d1f08e7e91ba65f10dc838"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f6cfe190526020bdb7f2d6d6e2f1b633f330317d747262e71b5a493eef733d43"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "lld@21" => :test
  depends_on "llvm@21"

  resource "ldc-bootstrap" do
    on_macos do
      on_arm do
        url "https://github.com/ldc-developers/ldc/releases/download/v1.41.0/ldc2-1.41.0-osx-arm64.tar.xz"
        sha256 "157267042f10b047210619314aa719b4f0bf887601e93b1c634aa1ecb3c546e4"
      end
      on_intel do
        url "https://github.com/ldc-developers/ldc/releases/download/v1.41.0/ldc2-1.41.0-osx-x86_64.tar.xz"
        sha256 "5bcff48b63c56a45dbaacdb0c5bddc8ea6be86d4a0c7b2c7c8318e047f721181"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/ldc-developers/ldc/releases/download/v1.41.0/ldc2-1.41.0-linux-aarch64.tar.xz"
        sha256 "1c4b950a13d53379ed4f564366c27ec56d6261e21686880d70c7486b3e8c7ba8"
      end
      on_intel do
        url "https://github.com/ldc-developers/ldc/releases/download/v1.41.0/ldc2-1.41.0-linux-x86_64.tar.xz"
        sha256 "4a439457f0fe59e69d02fd6b57549fc3c87ad0f55ad9fb9e42507b6f8e327c8f"
      end
    end
  end

  def llvm
    deps.reject { |d| d.build? || d.test? }
        .map(&:to_formula)
        .find { |f| f.name.match?(/^llvm(@\d+)?$/) }
  end

  def install
    (buildpath/"ldc-bootstrap").install resource("ldc-bootstrap")

    args = %W[
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DD_COMPILER=#{buildpath}/ldc-bootstrap/bin/ldmd2
      -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
      -DLLVM_ROOT_DIR=#{llvm.opt_prefix}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.d").write <<~D
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    D
    system bin/"ldc2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    lld = deps.map(&:to_formula).find { |f| f.name.match?(/^lld(@\d+(\.\d+)*)?$/) }
    with_env(PATH: "#{lld.opt_bin}:#{ENV["PATH"]}") do
      system bin/"ldc2", "-flto=thin", "--linker=lld", "test.d"
      assert_match "Hello, world!", shell_output("./test")
      system bin/"ldc2", "-flto=full", "--linker=lld", "test.d"
      assert_match "Hello, world!", shell_output("./test")
    end
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
