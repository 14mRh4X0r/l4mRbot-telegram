require "hashie"

sed_regex = /^s(?<sep>[^[:alnum:]\(\[<[:space:]])(?<regex>.*?)(?<!(?:[^\\]\\)*)\k<sep>(?<replace>.*?)(?<!(?:[^\\]\\)*)\k<sep>(?<flags>.*)/

line_hist = Hash.new {|hash, key| hash[key] = Array.new}

always do |bot, msg|
  $log.debug('sed') { "Such message: #{msg.text}\n" }
  broken = false
  if m = sed_regex.match(msg.text)
    $log.debug('sed') { "They don't think it match, but it do\n" }
    global = m[:flags].include? 'g'
    flags  = Regexp::IGNORECASE if m[:flags].include? 'i'
    flags |= Regexp::EXTENDED   if m[:flags].include? 'x'
    flags |= Regexp::MULTILINE  if m[:flags].include? 'm'

    begin
      regex = Regexp.new m[:regex], flags
    rescue RegexpError => e
      bot.api.send_message chat_id:             msg.chat.id,
                           text:                "What's this I don't even (#{e})",
                           reply_to_message_id: msg.message_id
    end

    replace = m[:replace].gsub /(?<!(?:[^\\]\\)*)\\#{m[:sep]}/, m[:sep]

    line_hist[msg.chat.id].each do |entry|
      if regex.match entry.msg
        if global
          res = entry.msg.gsub(regex, replace)
        else
          res = entry.msg.sub(regex, replace)
        end

        if res != entry.msg
          bot.api.send_message chat_id: msg.chat.id,
                               text:    "<#{entry.user}> #{res}"
          broken = true
          break
        end
      end
    end if regex
  end

  if not broken
    user_name = msg.from.first_name
    user_name += " " + msg.from.last_name unless msg.from.last_name.nil?
    line_hist[msg.chat.id].unshift Hashie::Mash.new user: user_name, msg: msg.text
  end
end
