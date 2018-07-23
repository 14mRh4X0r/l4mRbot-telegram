command 'hidekeyboard' do |bot, msg|
  bot.api.send_message(
    chat_id: msg.chat.id,
    text: "There you go.",
    reply_to_message_id: msg.message_id,
    reply_markup: Telegram::Bot::Types::ReplyKeyboardHide.new(
      hide_keyboard: true,
      selective: true
    )
  )
end
