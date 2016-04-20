#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'open3'
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

  def sync_acd()
    system("ACD_CLI_CACHE_PATH=#{@config["acd_cli_cache_path"]} " +
        "/usr/local/bin/acdcli sync")
  end
  def content_exist?(basename)
    File.exist?(@config["contents_dir"] + "/" + basename)
  end
  def content_filesize(basename)
    File.size(@config["contents_dir"] + "/" + basename)
  end

  def main
    begin
      sync_acd()
      @videos.select_all.each_hash {|v|
        if content_exist?(v["serviceVideoId"] + ".jpg")
          basename = v["serviceVideoId"]
        elsif content_exist?(v["serviceVideoId"].gsub("/", "_") + ".jpg")
          basename = v["serviceVideoId"].gsub("/", "_")
        end
        if basename
          if content_exist?(basename + ".mp4")
            @videos.update_with_filename(v["id"], basename + ".mp4", content_filesize(basename + ".mp4"))
          elsif content_exist?(basename + ".flv")
            @videos.update_with_filename(v["id"], basename + ".flv", content_filesize(basename + ".flv"))
          end
        else
          @videos.update_without_filename(v["id"])
        end
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
