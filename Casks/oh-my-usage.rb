cask "oh-my-usage" do
  version "0.1.0"
  sha256 "aec0802ed925d24bf448c4114cd1417ce947bba8482edcbe485698892d19e831"

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
