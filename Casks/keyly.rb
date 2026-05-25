cask "keyly" do
  version "1.7.3"
  sha256 "6ae2284066d9e1319fcbfd9c9a22035b299254501261f7f41ae19f5699f410e3"

  url "https://github.com/hoaiphongdev/keyly/releases/download/keyly-#{version}/Keyly.dmg"
  name "Keyly"
  desc "Lightweight macOS menu bar app that reveals keyboard shortcuts on demand"
  homepage "https://github.com/hoaiphongdev/keyly"

  depends_on macos: :monterey

  app "Keyly.app"

  zap trash: "~/.config/keyly"
end
