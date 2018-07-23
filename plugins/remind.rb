require 'chronic'
require 'rufus-scheduler'

RPL_OWN = { /\b[Ii] am\b/ => "you are",
            /\b[Ii]'m\b/  => "you're",
            /\b[Ii]'d\b/  => "you'd",
            /\b[Ii]\b/    => "you",
            /\bmy\b/      => "your",
            /\bmine\b/    => "yours"
}

RPL_OTHER = { /\bhe is\b/    => "you are",
              /\bshe is\b/   => "you are",
              /\bthey are\b/ => "you are",
              /\bhe's\b/     => "you're",
              /\bshe's\b/    => "you're",
              /\bthey're\b/  => "you're",
              /\bhe'd\b/     => "you'd",
              /\bshe'd\b/    => "you'd",
              /\bthey'd\b/   => "you'd",
              /\bhe\b/       => "you",
              /\bshe\b/      => "you",
              /\bthey\b/     => "you",
              /\bhis\b/      => "your",
              /\bher\b/      => "your",
              /\btheir\b/    => "your",
              /\btheirs\b/   => "yours",
              /\b[Ii] am\b/  => "they are",
              /\b[Ii]'m\b/   => "they're",
              /\b[Ii]'d\b/   => "they'd",
              /\b[Ii]\b/     => "they",
              /\bmy\b/       => "their",
              /\bmine\b/     => "theirs"
}

msg_re = /^(?<who>@?\w+|me)\s+(?<at>.*?)(?<what>(?:(?:not\s+)?to|that|about)\b.+)$/

def remind bot, msg, who, at, what, by_whom = nil
  Rufus::Scheduler.s.at at do
    if by_whom.nil?
      RPL_OWN.each {|k, v| what.gsub!(k, v)}
    else
      RPL_OTHER.each {|k, v| what.gsub!(k, v)}
    end
    bot.api.send_message chat_id: msg.chat.id,
                         text: "#{who}: #{by_whom || "you"} asked me to remind you #{what}"
  end
end

command 'remind' do |bot, msg|
  m = msg_re.match(msg.text[/(?<= ).+/])
  unless m
    begin
      bot.api.send_message chat_id: msg.chat.id,
			   text: "Uhh, what?",
			   reply_to_message_id: msg.message_id
    rescue
      # whatever
    end
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
