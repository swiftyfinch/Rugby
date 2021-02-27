class Rugby < Formula
  desc "🏈 Shake up pods project, build and throw away part of them."
  homepage "https://github.com/swiftyfinch/Rugby"
  version "0.1.1"
  url "https://github.com/swiftyfinch/Rugby/releases/download/#{version}/rugby.zip"

  def install
    bin.install Dir["bin/*"]
  end
end