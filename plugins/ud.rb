require 'ud'

command 'ud' do |bot, msg|
  begin
    if msg.text.split.length < 2
      ret = Hashie::Mash.new bot.api.send_message(chat_id: msg.chat.id,
                                                  text: "What word would you like me to look up?",
                                                  reply_to_message_id: msg.message_id,
                                                  reply_markup: Telegram::Bot::Types::ForceReply.new(force_reply: true,
                                                                                                     selective: true))
      reply(ret.result.message_id)  {|bot, msg| do_query bot, msg}
    else
      do_query bot, msg
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    $log.error('ud') { "Failed to ask the word to look up: #{e}. Backtrace:" }
    $log.error('ud') { e.backtrace.join "\n" }
  end
end

def escape md
  md.gsub /(?=[_*\[])/, '\\'
end

def do_query bot, msg
  q = msg.text
  q = q[/(?<=\s).*/] if q.start_with? '/ud'
  text = begin
    UD.query(q).map do |r|
      "*#{r[:word]}* (#{r[:upvotes]}/#{r[:downvotes]}):\n" \
      "#{escape r[:definition]}\n\n" \
      "_Example:_\n" \
      "#{escape r[:example]}"
    end.join
  rescue
    "Something went horribly wrong."
  end.force_encoding "utf-8"
  text = "_No results._" if text.nil? || text.empty?

  bot.api.send_message chat_id: msg.chat.id,
                       text: text,
                       parse_mode: "Markdown",
                       reply_to_message_id: msg.message_id
rescue Telegram::Bot::Exceptions::ResponseError => e
    $log.error('ud') { "Failed to execute query: #{e}. Backtrace:" }
    $log.error('ud') { e.backtrace.join "\n" }
end
