def user_str user
  "#{user.first_name} #{user.last_name} (#{user.username} - #{user.id})"
end

def chat_str chat
  "#{chat.title} (#{chat.id})"
end

def prefix msg
  fwd = " forwarded a message: #{Time.at msg.forward_date} #{user_str msg.forward_from}" if msg.forward_from

  if msg.chat.id == msg.from.id
    "#{Time.at msg.date} #{user_str msg.from}#{fwd}"
  else
    "#{Time.at msg.date} #{chat_str msg.chat} - #{user_str msg.from}#{fwd}"
  end
end

def print_attrs virtus_obj
  virtus_obj.attributes.map {|attr, value| "#{attr}=#{value.inspect}"}.join ", "
end

always do |bot, msg|
  if msg.text
    $log.info('log') { "#{prefix(msg)}: #{msg.text}" }
  elsif msg.audio
    $log.info('log') { "#{prefix(msg)} sent audio: #{print_attrs msg.audio}" }
  elsif msg.document
    $log.info('log') { "#{prefix(msg)} sent a file: #{print_attrs msg.document}" }
  elsif msg.photo and not msg.photo.empty?
    $log.info('log') { "#{prefix(msg)} sent a photo: #{msg.photo.map {|ps| print_attrs ps}}" }
  elsif msg.sticker
    $log.info('log') { "#{prefix(msg)} sent a sticker: #{print_attrs msg.sticker}" }
  elsif msg.video
    $log.info('log') { "#{prefix(msg)} sent a video: #{print_attrs msg.video}" }
  elsif msg.voice
    $log.info('log') { "#{prefix(msg)} sent a voice message: #{print_attrs msg.voice}" }
  elsif msg.contact
    $log.info('log') { "#{prefix(msg)} sent a contact: #{print_attrs msg.contact}" }
  elsif msg.location
    $log.info('log') { "#{prefix(msg)} sent a location: #{print_attrs msg.location}" }
  elsif msg.new_chat_participant
    $log.info('log') { "#{prefix(msg)} joined the group" }
  elsif msg.left_chat_participant
    $log.info('log') { "#{prefix(msg)} left the group" }
  elsif msg.new_chat_title
    $log.info('log') { "#{prefix(msg)} changed the group title to #{msg.new_chat_title}" }
  elsif msg.new_chat_photo
    $log.info('log') { "#{prefix(msg)} changed the group photo: #{msg.new_chat_photo.map {|ps| print_attrs ps}}" }
  elsif msg.delete_chat_photo
    $log.info('log') { "#{prefix(msg)} deleted the group photo" }
  elsif msg.group_chat_created
    $log.info('log') { "#{prefix(msg)} created the group" }
  else
    $log.unknown('log') { "#{prefix(msg)} - Unknown message type: #{print_attrs msg}" }
  end
end
