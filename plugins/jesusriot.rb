match /^jesusriot\.png$/ do |bot, msg, match|
  bot.api.send_photo chat_id: msg.chat.id,
                     photo:   "AgADAQAD3acxG3bFqQXHm5KYj5WEWPYz3ikABI6Ckqc6wp7fNYkAAgI",
                     reply_to_message_id: msg.message_id
end

match /^dogeriot\.png$/ do |bot, msg, match|
  bot.api.send_photo chat_id: msg.chat.id,
                     photo:   "AgADBAADQ6gxG8FkhAAB6w-omzXwv2_-qmkwAARRrzzpD8M4vWZXAQABAg",
                     reply_to_message_id: msg.message_id
end
