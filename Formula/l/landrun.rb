class Landrun < Formula
  desc "Lightweight, secure sandbox for running Linux processes using Landlock LSM"
  homepage "https://github.com/Zouuup/landrun"
  url "https://github.com/Zouuup/landrun/archive/refs/tags/v0.1.15.tar.gz"
  sha256 "61bc92e1b808e1d4443b69a62498b74d5730a997703a70e6879486d95ea53aad"
  license "MIT"

  depends_on "go" => :build
  depends_on :linux

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/landrun"
  end

  test do
    lib_paths = %w[/lib /usr/lib /lib64 /usr/lib64].select { |dir| File.directory? dir }
    output = shell_output("#{bin}/landrun --rox /usr --ro #{lib_paths.join(",")} --best-effort -- pwd")
    assert_equal output.chomp, testpath.to_s
  end
end
