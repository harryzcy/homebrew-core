class ApacheOpennlp < Formula
  desc "Machine learning toolkit for processing natural language text"
  homepage "https://opennlp.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=opennlp/opennlp-2.5.4/apache-opennlp-2.5.4-bin.tar.gz"
  mirror "https://archive.apache.org/dist/opennlp/opennlp-2.5.4/apache-opennlp-2.5.4-bin.tar.gz"
  sha256 "54452c85a38b74b1a04ba51531be6f221b825630288c05d1c76ba974afc5279a"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "2467e569da60704b6dcb841eb6ad9c9d78a21b6fb58c005664a0dd0f7283f2dd"
  end

  depends_on "openjdk"

  def install
    # Remove Windows scripts
    rm(Dir["bin/*.bat"])

    libexec.install Dir["*"]
    (bin/"opennlp").write_env_script libexec/"bin/opennlp", JAVA_HOME:    Formula["openjdk"].opt_prefix,
                                                            OPENNLP_HOME: libexec
  end

  test do
    output = pipe_output("#{bin}/opennlp SimpleTokenizer", "Hello, friends", 0)
    assert_equal "Hello , friends", output.lines.first.chomp
  end
end
