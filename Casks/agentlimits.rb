cask 'agentlimits' do
  version '0.9.9'
  sha256 'baaa3bd0c16489c0423ca85e94bb8591ece9fde437093c82dae39d182551e92b'

  url "https://github.com/Nihondo/AgentLimits/releases/download/v#{version}/AgentLimits.zip"
  name 'AgentLimits'
  desc 'macOS menu bar app and widgets for Codex/Claude Code usage limits and ccusage'
  homepage 'https://github.com/Nihondo/AgentLimits'

  depends_on macos: '>= :sonoma'

  app 'AgentLimits.app'

  zap trash: [
    '~/Library/Group Containers/group.com.dmng.agentlimit',
    '~/Library/LaunchAgents/com.dmng.agentlimit.wakeup-*.plist'
  ]
end
