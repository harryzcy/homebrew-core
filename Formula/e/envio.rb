class Envio < Formula
  desc "Modern And Secure CLI Tool For Managing Environment Variables"
  homepage "https://github.com/envio-cli/envio"
  url "https://github.com/envio-cli/envio/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "729a02ac8a5e129fa5129de6ee62f7e2c408502dafc25924d65d02558caa5a08"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/envio-cli/envio.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "871f4fba1afd7a74d4b1096eb8a223d4c60f1c4fe9ecb765b044a83b6cf6842c"
    sha256 cellar: :any,                 arm64_sequoia: "454759fecf6e0d2ecde551706f07b9cd4ad8f11ab1ae681aca16d7d249c13cf0"
    sha256 cellar: :any,                 arm64_sonoma:  "17205a327d38a19e5416b56a1d3b2f3bc88959a1cb83b66531c6361c0a2d578e"
    sha256 cellar: :any,                 arm64_ventura: "fd2ac58208ea285ee0b5ae4099665ef24bf9b4a4ad496080da17609c5bfdb6fe"
    sha256 cellar: :any,                 sonoma:        "917fcd18cd9de2da9f27bee0ef5a774f93c8b9721d1ae772ac662b391b59995a"
    sha256 cellar: :any,                 ventura:       "a87c2879250f2444401ac9b9358b4da1fd5cfabb0440000e429338e359c5d9af"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "b4fcdb5e0c07562ee87503600e5cae91ba7ad1f115f87131b1ad1c743e3de436"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "21f6d742413ed743140d37ce169c763263fcd49f0873a82a5dba5b61c498bb7a"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "gpgme"
  depends_on "libgpg-error"

  on_linux do
    depends_on "dbus"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    # Setup envio config path
    mkdir testpath/".envio"
    mkdir testpath/".envio/profiles"
    touch testpath/".envio/setenv.sh"

    (testpath/"batch.gpg").write <<~EOS
      Key-Type: RSA
      Key-Length: 2048
      Subkey-Type: RSA
      Subkey-Length: 2048
      Name-Real: Testing
      Name-Email: testing@foo.bar
      Expire-Date: 1d
      %no-protection
      %commit
    EOS

    system Formula["gnupg"].opt_bin/"gpg", "--batch", "--gen-key", "batch.gpg"
    gpg = Formula["gnupg"].opt_bin/"gpg"
    fingerprint_output = shell_output("#{gpg} --with-colons --list-secret-keys --fingerprint")
    fingerprint_line = fingerprint_output.lines.find { |line| line.start_with?("fpr:") }.to_s
    fingerprint = fingerprint_line.split(":").fetch(9, "").strip
    assert_match(/\A\h{40}\z/, fingerprint)

    begin
      with_env(ENVIO_KEY: fingerprint) do
        output = shell_output("#{bin}/envio create brewtest --cipher-kind gpg")
        assert_match "Profile created", output
      end
      assert_path_exists testpath/".envio/profiles/brewtest.envio"

      output = shell_output("#{bin}/envio list")
      assert_match "brewtest", output

      assert_match version.to_s, shell_output("#{bin}/envio version")
    ensure
      system Formula["gnupg"].opt_bin/"gpgconf", "--kill", "gpg-agent"
    end
  end
end
