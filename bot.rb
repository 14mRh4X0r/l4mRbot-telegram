#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'telegram/bot'
require 'logger'
require 'hashie'

require_relative 'token'

$log = Logger.new STDOUT
$log.level = Logger::INFO
$log.datetime_format = "%Y-%m-%d %H:%M:%S"

$commands = Hash.new
$matches = Hash.new
$replies = Hash.new
$always = Array.new

def command cmd, &block
  $log.debug "Adding command: #{cmd}"
  $commands[cmd] = block
end

def match regex, &block
  $log.debug "Adding match: #{regex}"
  $matches[regex] = block
end

def always &block
  $log.debug "Adding always"
  $always << block
end

def reply id, &block
  $log.debug "Adding reply: #{id}"
  $replies[id] = block
end

require_relative 'plugins'

Telegram::Bot::Client.run(TOKEN) do |bot|
  begin
    me = Hashie::Mash.new(bot.api.get_me).result
    $log.debug "I am #{me.username}"
    bot.listen do |msg|
      $log.debug "Got a msg: #{msg.inspect}"
      if msg.text and msg.text[0] == '/'
        cmd = msg.text.split[0][1..-1]
        cmd, who = cmd.split '@' if cmd.include? '@'
        $log.debug "Parsing command: #{msg.text.inspect}, #{cmd.inspect}, #{who.inspect}"
        $commands[cmd].call(bot, msg) if $commands.has_key? cmd and (who.nil? or who.eql? me.username)
      end

      $matches.each do |regex, block|
        regex.match(msg.text) do |match|
          block.call(bot, msg, match)
        end if msg.text
      end

      $replies.each do |id, block|
        if id == msg.reply_to_message.message_id
          block.call(bot, msg)
          $replies.delete id
        end
      end if msg.reply_to_message

      $always.each {|block| block.call(bot,msg)}
    end
  rescue Interrupt
    $log.warn "Caught interrupt -- quitting"
  end
end
