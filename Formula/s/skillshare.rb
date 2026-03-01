class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.16.7.tar.gz"
  sha256 "8a8e2268c13f449bd9c50d0cb4913e908541f67070db5433901138aa0f1aba69"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b74f8d9414533f9d91a48ebe27c105496e8710c15107a4788906dc3d99f2b2b0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b74f8d9414533f9d91a48ebe27c105496e8710c15107a4788906dc3d99f2b2b0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b74f8d9414533f9d91a48ebe27c105496e8710c15107a4788906dc3d99f2b2b0"
    sha256 cellar: :any_skip_relocation, sonoma:        "01285428234db9a7923fff8bee98faab695e7fb89b40faa4b21d9409e07a9160"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "084940229e021196645151af4e333fcf924c3878dadbee338025010ab7c55379"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ef9bc4cc8a2fc75473f7491d8d60a6ea932b01fea0d6ca795e2effa056a50ffe"
  end

  depends_on "go" => :build

  def install
    # Avoid building web UI
    ui_path = "internal/server/dist"
    mkdir_p ui_path
    (buildpath/"#{ui_path}/index.html").write "<!DOCTYPE html><html><body><h1>UI not built</h1></body></html>"

    ldflags = %W[
      -s -w
      -X main.version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/skillshare"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/skillshare version")

    assert_match "config not found", shell_output("#{bin}/skillshare sync 2>&1", 1)
  end
end
