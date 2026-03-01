class Arkade < Formula
  desc "Open Source Kubernetes Marketplace"
  homepage "https://blog.alexellis.io/kubernetes-marketplace-two-year-update/"
  url "https://github.com/alexellis/arkade/archive/refs/tags/0.11.83.tar.gz"
  sha256 "ad79f170bd78442264c3fb8801189118752083b981214b3e877b8ed0dbc75b60"
  license "MIT"
  head "https://github.com/alexellis/arkade.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2a73d0d9a0ab17f5aee0cda4b7150231ea00e3e4f9fb638de5a69c45f9a12662"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2a73d0d9a0ab17f5aee0cda4b7150231ea00e3e4f9fb638de5a69c45f9a12662"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2a73d0d9a0ab17f5aee0cda4b7150231ea00e3e4f9fb638de5a69c45f9a12662"
    sha256 cellar: :any_skip_relocation, sonoma:        "bd84a164e17d13a28daa300c2a161fabb991ed094136142b53a98b721da648f8"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7fda88c6a4e3075b7aee364b90738bc487ea83f7926e61bdedc5e084151858a6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "bff4c3285e43990da8421cb7bf8b89b7efc7fc882214e64db6b3bcc0b182944d"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/alexellis/arkade/pkg.Version=#{version}
      -X github.com/alexellis/arkade/pkg.GitCommit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:)

    bin.install_symlink "arkade" => "ark"

    generate_completions_from_executable(bin/"arkade", shell_parameter_format: :cobra)
    # make zsh completion also work for `ark` symlink
    inreplace zsh_completion/"_arkade", "#compdef arkade", "#compdef arkade ark=arkade"
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/arkade version")
    assert_match "Info for app: openfaas", shell_output("#{bin}/arkade info openfaas")
  end
end
