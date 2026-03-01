class DomainCheck < Formula
  desc "CLI tool for checking domain availability using RDAP and WHOIS protocols"
  homepage "https://github.com/saidutt46/domain-check"
  url "https://github.com/saidutt46/domain-check/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "6257c1e09bf9e291bb27c4f0cfe0461e49b77792b749d58ce4bbd87f246b12df"
  license "Apache-2.0"
  head "https://github.com/saidutt46/domain-check.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "baa57da46e98cee7cac9fff1944d5f16beefc63267bccc27c5c51599ce6d5861"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f1097965f722375546abae1361ae60c567c5f5b61f437d980636ba67380ebc13"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e568040d40c84351f80f450b3321a319e977f756bf3b9dc6ad22463a65e8da84"
    sha256 cellar: :any_skip_relocation, sonoma:        "b49fe47fdb1883d283f7abe4ef185d29837516ee37a3beeccbe095140c85d1fa"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "887c4c2c3c6d25f7a19a498e40842cbaa012d66f3a8db4802ce8ee3781ff75e1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9dd17ff2ae4b8ca49781d53383c50805ebcfd6fbadced7b3edfeca7ae5f12f38"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "domain-check")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/domain-check --version")

    output = shell_output("#{bin}/domain-check example.com")
    assert_match "example.com TAKEN", output

    output = shell_output("#{bin}/domain-check invalid_domain 2>&1", 1)
    assert_match "Error: No valid domains found to check", output
  end
end
