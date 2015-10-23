require 'chronic'
require 'rufus-scheduler'

msg_re = /^(?<who>@?\w+|me) (?<at>.*?)(?<what>(?:to|that|about).+)$/

def remind bot, msg, who, at, what, by_whom = nil
  Rufus::Scheduler.s.at at do
    bot.api.send_message chat_id: msg.chat.id,
                         text: "#{who}: #{by_whom || "you"} asked me to remind you #{what}"
  end
end

command 'remind' do |bot, msg|
  m = msg_re.match(msg.text[/(?<= ).+/])
  unless m
    bot.api.send_message chat_id: msg.chat.id,
                         text: "Uhh, what?",
                         reply_to_message_id: msg.message_id
    next
  end

  $log.debug("remind") { m.inspect }
  at = Chronic.parse(m[:at].empty?? "in 5 minutes" : m[:at])
  if not at
    bot.api.send_message chat_id: msg.chat.id,
                         text: "I didn't understand that time.",
                         reply_to_message_id: msg.message_id
    next
  end

  remind bot, msg,
         m[:who] == "me" ? "@#{msg.from.username}" : m[:who],
         at, m[:what],
         (msg.from.first_name unless m[:who] == "me")

  bot.api.send_message chat_id: msg.chat.id,
                       text: "Will do.",
                       reply_to_message_id: msg.message_id
end
