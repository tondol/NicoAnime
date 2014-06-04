#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'mysql'
require 'yaml'

require_relative 'base'

class NicovideoCleaner
  def initialize
    Model::connect
    @config = Model::config
    @logs = Model::Logs.new
    @videos = Model::Videos.new
    @channels = Model::Channels.new
  end

  def clean_files(video)
    filename = video["filename"]
    filepath = "#{@config["contents"]}#{filename}"
    return unless filename
    if File.exist?(filepath)
      File.delete(filepath)
      @logs.d("cleaner", "delete: #{filepath}");
    end

    filename = "#{video["nicoVideoId"]}.xml"
    filepath = "#{@config["contents"]}#{filename}"
    if File.exist?(filepath)
      File.delete(filepath)
      @logs.d("cleaner", "delete: #{filepath}");
    end

    filename = "#{video["nicoVideoId"]}.jpg"
    filepath = "#{@config["contents"]}#{filename}"
    if File.exist?(filepath)
      File.delete(filepath)
      @logs.d("cleaner", "delete: #{filepath}");
    end
  end
  def clean(channel_id)
    begin
      videos = @videos.select_with_channel_id(channel_id)
      videos.each_hash {|video|
        clean_files(video)
      }
      @videos.delete_with_channel_id(channel_id)
      @channels.delete(channel_id)
      @logs.d("cleaner", "clean: #{channel_id}")
    rescue StandardError => e
      @logs.e("cleaner", e.message)
      $stderr.puts(e.backtrace)
    end
  end
  def main
    begin
      ARGV.each {|channel_id|
        clean(channel_id)
      }
    rescue Exception => e
      @logs.e("cleaner", "an unexpected error has occurred")
      @logs.e("cleaner", e.message)
      $stderr.puts(e.backtrace)
    ensure
      Model::close
    end
  end
end

NicovideoCleaner.new.main
