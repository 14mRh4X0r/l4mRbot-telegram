command 'slap' do |bot, msg|
  bot.api.send_message chat_id: msg.chat.id,
                       text: "#{msg.from.first_name} slaps #{msg.text.split[1..-1].join(" ").strip} " \
                             "around a bit with a large trout"
end
