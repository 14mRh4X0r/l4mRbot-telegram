require 'hashie'
require 'telegram/bot/types/message'

def subst_forward re
  match re do |bot, msg, match|
    new_msg = Telegram::Bot::Types::Message.new msg.attributes
    new_msg.instance_variable_set :@chat, msg.chat
    new_msg.text = msg.text.sub re, '/'

    process bot, new_msg
  end
end

subst_forward /^!/
subst_forward /^@#{$me.username}[:,]?\s+/
