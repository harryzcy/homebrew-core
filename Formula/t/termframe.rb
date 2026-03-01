class Termframe < Formula
  desc "Terminal output SVG screenshot tool"
  homepage "https://github.com/pamburus/termframe"
  url "https://github.com/pamburus/termframe/archive/refs/tags/v0.8.1.tar.gz"
  sha256 "a355a4919974fa80c088adde8ecf56464bfdc8392cdf9f7ad9121f79f3350136"
  license "MIT"
  head "https://github.com/pamburus/termframe.git", branch: "main"

  depends_on "rust" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    system bin/"termframe", "-o", "hello.svg", "--", "echo", "Hello, World"
    assert_path_exists testpath/"hello.svg"
  end
end
