require 'minecraft-query'
require 'hashie'

command 'list' do |bot, msg|
  bot.api.send_chat_action chat_id: msg.chat.id,
                           action: 'typing'

  begin
    old_stdout = STDOUT.dup
    STDOUT.reopen('/dev/null')

    data = Hashie::Mash.new Query::fullQuery('minecraftonline.com')
  ensure
    STDOUT.reopen(old_stdout)
    old_stdout.close
  end

  text = if data.players.empty?
    "No players online"
  else
    "#{data.players.size} player#{"s" if data.players.size != 1} online: #{data.players.join ', '}"
  end

  bot.api.send_message chat_id: msg.chat.id,
                       text: text
end
