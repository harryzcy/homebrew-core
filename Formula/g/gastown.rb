class Gastown < Formula
  desc "Multi-agent workspace manager"
  homepage "https://github.com/steveyegge/gastown"
  url "https://github.com/steveyegge/gastown/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "7e542737f784ac1247cb62eb828bc4267c5d5cab547696253623d4a717c57d3e"
  license "MIT"
  revision 1
  head "https://github.com/steveyegge/gastown.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "cae63c74704cb6d314ab8a3b97a3a64aefae0b7e1e8ab1146cdc96371b1213de"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cae63c74704cb6d314ab8a3b97a3a64aefae0b7e1e8ab1146cdc96371b1213de"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "cae63c74704cb6d314ab8a3b97a3a64aefae0b7e1e8ab1146cdc96371b1213de"
    sha256 cellar: :any_skip_relocation, sonoma:        "f8c8b7f99ffc951ec79f5ae89566db21d5bce236c8cf02277703a0a9ff6aeef7"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "2983ee55f362df98032ad4b23be29cdfcfa2638ec26eb228012438abf3f26d3c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "75346b546ee9943d155c61df1aa29de626278d30a7b4bdd1ce283ad808e9e383"
  end

  depends_on "go" => :build
  depends_on "beads"
  depends_on "icu4c@78"

  conflicts_with "genometools", "libslax", because: "both install `gt` binaries"

  def install
    ldflags = %W[
      -s -w
      -X github.com/steveyegge/gastown/internal/cmd.Version=#{version}
      -X github.com/steveyegge/gastown/internal/cmd.Build=#{tap.user}
      -X github.com/steveyegge/gastown/internal/cmd.Commit=#{tap.user}
      -X github.com/steveyegge/gastown/internal/cmd.Branch=v#{version}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/gt"
    bin.install_symlink "gastown" => "gt"

    generate_completions_from_executable(bin/"gt", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gt version")

    system "dolt", "config", "--global", "--add", "user.name", "BrewTestBot"
    system "dolt", "config", "--global", "--add", "user.email", "BrewTestBot@test.com"

    system bin/"gt", "install"
    assert_path_exists testpath/"mayor"
  end
end
