#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require_relative 'NicoVideo/nico'
require_relative 'base'

class NicovideoCollector
  def initialize
    Model::connect
    @channels = Model::Channels.new
    @videos = Model::Videos.new
    @logs = Model::Logs.new
    @config = Model::load_config
  end

  def main
    begin
      db_filenames = []
      @videos.select_all_downloaded.each_hash {|video|
        next if video["deletedAt"]
        db_filenames << video["filename"]
      }
      fs_filenames = []
      Dir.entries(@config["contents_dir"]).each {|entry|
        next if entry == "." || entry == ".."
        next unless entry.end_with?(".mp4") || entry.end_with?(".flv")
        fs_filenames << entry
      }
      puts "exist only in database"
      (db_filenames - fs_filenames).each {|filename|
        puts filename
        #@videos.delete_by_filename(filename)
      }
      puts "exist only in directory"
      (fs_filenames - db_filenames).each {|filename|
        puts filename
        filepath = @config["contents_dir"] + "/" + filename
        #File.delete(filepath)
      }
    rescue Exception => e
      $stderr.puts(e.message)
      $stderr.puts(e.backtrace)
    ensure
      Model::close
    end
  end
end

NicovideoCollector.new.main
