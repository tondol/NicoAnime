#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'mysql'
require 'yaml'

require_relative 'NicoVideo/nico'
require_relative 'base'

class NicovideoCrawler
  def initialize
    Model::connect
    @channels = Model::Channels.new
    @videos = Model::Videos.new
    @logs = Model::Logs.new
    @config = Model::load_config
  end

  def crawl_sub(channel, item)
    @nicovideo.watch(item.video_id) {|nv_video|
      @logs.d("crawler", "crawl/insert: #{nv_video.title}")
      @videos.insert_into(channel["id"], nv_video.video_id, nv_video.title, nv_video.description)
    }
  end
  def crawl(channel)
    num_inserted = 0
    hash = {}

    @videos.select_all_by_channel_id(channel["id"]).each_hash {|video|
      hash[video["nicoVideoId"]] = true
    }

    @nicovideo.channel(channel["nicoChannelId"]) {|nv_channel|
      @logs.d("crawler", "crawl: #{nv_channel.creator}")
      nv_channel.items.reverse_each {|item|
        begin
          next if hash.key?(item.video_id)
          hash[item.video_id] = true
          crawl_sub(channel, item)
          num_inserted += 1
        rescue Exception => e
          @logs.e("crawler", "crawl/unavailable: #{item.title}")
          @logs.e("crawler", "crawl/unavailable: #{e.message}")
          $stderr.puts(e.backtrace)
        end
      }
  
      @logs.d("crawler", "crawl/insert: #{nv_channel.creator} (#{num_inserted})")
      if num_inserted == 0
        @channels.update_without_modification(channel["id"])
        sleep 1
      else
        @channels.update_with_modification(channel["id"])
        sleep 1
      end
    }
  end
  def main
    # logs.d("crawler", ">> run: #{Time.now}")
    @nicovideo = Nicovideo.login(@config["nv"]["mail"], @config["nv"]["password"], @config["nv"]["session"])
    @session = @nicovideo.instance_variable_get(:@session)
    @config["nv"]["session"] = @session

    begin
      @channels.select_all.each_hash {|video|
        video["modifiedAt"] = Model::db_time_to_time(video["modifiedAt"])
        crawl(video)
      }
    rescue Exception => e
      @logs.e("crawler", "error: #{e.message}")
      @logs.e("crawler", "trace: #{e.backtrace}")
      $stderr.puts(e.backtrace)
    ensure
      Model::save_config(@config)
      Model::close
    end
  end
end

NicovideoCrawler.new.main
