class Edbrowse < Formula
  desc "Command-line editor and web browser"
  homepage "https://edbrowse.org"
  url "https://github.com/edbrowse/edbrowse/archive/refs/tags/v3.8.16.tar.gz"
  sha256 "7593e7ebd4ab0cff05c8d1a6cfb72c667a62aaffa2d84e0d4d29b8ab68459d0e"
  license "GPL-2.0-or-later"
  head "https://github.com/edbrowse/edbrowse.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "1f283ccbdfc824f65026829fafcdea0489ba67d1bd814e1efa63188028469e62"
    sha256 cellar: :any,                 arm64_sequoia: "3bab6f02f68660fbc7ef7d8d10bc5beab31c9037a8e4e93338794ffc4eb3e450"
    sha256 cellar: :any,                 arm64_sonoma:  "f3d60bbe8c842555381664a2a4341a1b47a1f970e0b61fa2cc2932d99a2d3ba7"
    sha256 cellar: :any,                 sonoma:        "66d4cbf1ebe89017c5e6d34f43e2ed762f44f9fa09ac37873027cd745bc401a3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "93d8f4080bf66e3e9d517fde6abece60a888c39bd01c341b3da18c55ba171695"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e312149ee61414e925b221f95fdfab83758c6d6ddcedb404bf0713b5f1320fae"
  end

  depends_on "pkgconf" => :build
  depends_on "quickjs" => :build
  depends_on "curl"
  depends_on "openssl@3"
  depends_on "pcre2"
  depends_on "readline"
  depends_on "unixodbc"

  # guard JS_GetVersion for Q_NG builds, upstream pr ref, https://github.com/edbrowse/edbrowse/pull/121
  patch do
    url "https://github.com/edbrowse/edbrowse/commit/fd684cc8bc25376b97ee5ea688ca733ab5ac3564.patch?full_index=1"
    sha256 "3fde047573230d924ca6271c89bed6a1aca3071900bbd53e76e5c8df69aeaded"
  end
  # make install portability fix, upstream pr ref, https://github.com/edbrowse/edbrowse/pull/122
  patch do
    url "https://github.com/edbrowse/edbrowse/commit/e6389a12504d386f97493b91c5f920fafa00c627.patch?full_index=1"
    sha256 "cc30cfe785f138fcc741c3184cbae17a44a7be564442c28ea6821f34687c41fc"
  end

  def install
    ENV.append_to_cflags "-DQ_NG=0"

    cd "src" do
      make_args = [
        "QUICKJS_INCLUDE=#{Formula["quickjs"].opt_include}/quickjs",
        "QUICKJS_LIB=#{Formula["quickjs"].opt_lib}/quickjs",
        "QUICKJS_LIB_NAME=quickjs",
      ]

      system "make", *make_args
      system "make", "install", "PREFIX=#{prefix}"
    end
  end

  test do
    (testpath/".ebrc").write("")
    (testpath/"test.txt").write("Hello from ed\n")

    system "printf %s\\\\n 's/ed/edbrowse/' 'w' 'q' | #{bin}/edbrowse -c .ebrc test.txt"
    assert_equal "Hello from edbrowse", (testpath/"test.txt").read.chomp
  end
end
