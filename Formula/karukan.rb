# typed: false
# frozen_string_literal: true

# Karukan Japanese IME for macOS (togatoga/karukan, karukan-macos frontend).
#
# Upstream's v0.1.0 tag predates the karukan-macos frontend, so `stable`
# pins a commit on main with a `0.1.0.YYYYMMDD` version (commit date).
# When upstream tags a release containing karukan-macos, switch `url` to the
# tag tarball; `0.2.0 > 0.1.0.20260624` so upgrades keep working.
#
# Bump procedure:
#   1. Pick a commit: gh api repos/togatoga/karukan/commits/main --jq .sha
#   2. url に貼り、version をコミット日付 (0.1.0.YYYYMMDD) に更新
#   3. brew fetch --build-from-source ymkthr/tap/karukan  # sha256 が表示される
#   4. sha256 を更新して commit & push
class Karukan < Formula
  desc "Japanese IME with neural kana-kanji conversion (macOS InputMethodKit)"
  homepage "https://github.com/togatoga/karukan"
  url "https://github.com/togatoga/karukan/archive/6746900de5ae44f1cf3b28784235e9b2f22326ee.tar.gz"
  version "0.1.0.20260624"
  sha256 "6bac2e03e5f01c048520d7fc3544b25e37fd6bf0d3df52bd7a1b528d14f1bf41"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/togatoga/karukan.git", branch: "main"

  livecheck do
    url :head
    strategy :github_latest
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on xcode: ["15.0", :build]
  depends_on :macos

  def install
    # Homebrew's sandbox denies writes to the real $HOME (~/.cargo).
    ENV["CARGO_HOME"] = "#{buildpath}/cargo_home"

    cd "karukan-macos" do
      # SwiftPM sandboxes the Package.swift compile with sandbox-exec, and
      # macOS forbids nesting that inside Homebrew's build sandbox
      # ("sandbox_apply: Operation not permitted"). Disable SwiftPM's own
      # sandbox; Homebrew's stays active.
      inreplace "Makefile", /^\tswift build -c release$/,
                "\tswift build -c release --disable-sandbox"

      # swift+cargo build → .app assembly → ad-hoc codesign (no user-dir writes)
      system "make", "bundle"
      prefix.install "out/Karukan.app"
    end

    # The sandbox forbids writing to ~/Library during install/post_install,
    # so the placement half of upstream's `make install` ships as a command.
    (bin/"karukan-install").write <<~SCRIPT
      #!/bin/bash
      set -euo pipefail

      app_src="#{opt_prefix}/Karukan.app"
      dest_dir="$HOME/Library/Input Methods"
      data_dir="$HOME/Library/Application Support/com.karukan.karukan-im"
      dict_url="https://github.com/togatoga/karukan/releases/latest/download/dict.tgz"

      mkdir -p "$dest_dir"
      rm -rf "$dest_dir/Karukan.app"
      cp -a "$app_src" "$dest_dir/"
      echo "Installed: $dest_dir/Karukan.app"

      if [ -f "$data_dir/dict.bin" ]; then
        echo "System dictionary already installed: $data_dir/dict.bin (skipping)"
      else
        echo "Downloading system dictionary ..."
        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        if curl -fL --progress-bar -o "$tmp/dict.tgz" "$dict_url" &&
           tar xzf "$tmp/dict.tgz" -C "$tmp"; then
          mkdir -p "$data_dir"
          cp "$tmp/dict.bin" "$data_dir/"
          echo "Installed system dictionary: $data_dir/dict.bin"
        else
          echo "WARNING: dictionary install failed; the IME runs model-only without it" >&2
        fi
      fi

      echo "Prefetching conversion models (Hugging Face cache) ..."
      "$dest_dir/Karukan.app/Contents/MacOS/karukan-imserver" --prefetch-models ||
        echo "WARNING: model prefetch failed; models download on first launch" >&2

      killall KarukanIME 2>/dev/null || true

      cat <<'MSG'

      Done. First install only:
        1. Log out of macOS and log back in
        2. System Settings > Keyboard > Input Sources > + > Japanese > Karukan
      After upgrades, rerun `karukan-install` (no logout needed).
      MSG
    SCRIPT
    chmod 0755, bin/"karukan-install"
  end

  def caveats
    <<~EOS
      The .app is staged in #{opt_prefix}/Karukan.app. To activate it, run:

        karukan-install

      which copies it into ~/Library/Input Methods, downloads the system
      dictionary, and prefetches the conversion models. Rerun it after
      every upgrade.
    EOS
  end

  test do
    assert_path_exists prefix/"Karukan.app/Contents/MacOS/KarukanIME"
    assert_path_exists prefix/"Karukan.app/Contents/MacOS/karukan-imserver"
    assert_path_exists prefix/"Karukan.app/Contents/Info.plist"
  end
end
