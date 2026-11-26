cask "oh-my-usage" do
  version "0.3.0"
  sha256 "ede2625718371524bd4dfe6ec9b6f20165bca7e143de0699d50df8fc3b725e4a"

  url "https://github.com/ymkthr/oh-my-usage/releases/download/v#{version}/oh-my-usage.zip"
  name "oh-my-usage"
  desc "Menu bar app showing LLM usage limits from omp usage"
  homepage "https://github.com/ymkthr/oh-my-usage"

  depends_on macos: :sonoma

  app "oh-my-usage.app"

  # Ad-hoc signed and not notarized (no Developer ID), so Gatekeeper would
  # refuse the quarantined app on first launch.
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/oh-my-usage.app"],
        writable_paths: ["{{appdir}}/oh-my-usage.app"]
  end

  uninstall quit: "io.github.ymkthr.oh-my-usage"

  zap trash: "~/Library/Preferences/io.github.ymkthr.oh-my-usage.plist"
end
