require 'teamspeak-ruby'
require_relative 'tslist_password'

command 'tslist' do |bot, msg|
  bot.api.send_chat_action chat_id: msg.chat.id,
                           action: 'typing'

  ts = Teamspeak::Client.new 'minecraftonline.com'
  ts.login 'serveradmin', TSLIST_PASSWORD
  ts.command 'use', sid: 1

  users = ts.command('clientlist').map do |client|
    client['client_nickname'] unless client['client_database_id'] == 1
  end.compact

  text = if users.empty?
    "No people in TeamSpeak"
  else
    "#{users.size} #{users.size == 1 ? "person" : "people"} in TeamSpeak: #{users.join ", "}"
  end

  bot.api.send_message chat_id: msg.chat.id,
                       text: text
end
