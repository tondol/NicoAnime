#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'mysql'
require 'yaml'

require_relative 'NicoVideo/nico'
require_relative 'base'

class NicovideoCrawler
  def initialize
    Model::connect
    @config = Model::config
    @channels = Model::Channels.new
    @videos = Model::Videos.new
    @logs = Model::Logs.new
  end

  def crawl_sub(id, modified_at, item)
    @nicovideo.watch(item.video_id) {|video|
      @logs.d("crawler", "create: #{video.title}")
      @videos.insert_into(id, video.video_id, video.title, video.description)
    }
  end
  def crawl(id, channel_id, modified_at)
    num_inserted = 0
    hash = {}

    @videos.select_with_channel_id(id).each_hash {|video|
      hash[video["nicoVideoId"]] = true
    }

    @nicovideo.channel(channel_id) {|channel|
      @logs.d("crawler", "crawl: #{channel.creator}")
      channel.items.reverse_each {|item|
        begin
          next if hash.key?(item.video_id)
          hash[item.video_id] = true
          crawl_sub(id, modified_at, item)
          num_inserted += 1
        rescue Exception => e
          @logs.e("crawler", "unavailable: #{item.title}")
          @logs.e("crawler", e.message)
          $stderr.puts(e.backtrace)
        end
      }
  
      @logs.d("crawler", "#{num_inserted} videos created: #{channel.creator}")
      if num_inserted == 0
        @channels.update_without_modification(id)
        sleep 1
      else
        @channels.update_with_modification(id)
        sleep 1
      end
    }
  end
  def main
    # logs.d("crawler", ">> run: #{Time.now}")
    @nicovideo = Nicovideo.login(@config["nv"]["mail"], @config["nv"]["password"])

    begin
      @channels.select.each_hash {|row|
        crawl(row["id"], row["nicoChannelId"], Model::db_time_to_time(row["modifiedAt"]))
      }
    rescue Exception => e
      @logs.e("crawler", "an unexpected error has occurred")
      @logs.e("crawler", e.message)
      $stderr.puts(e.backtrace)
    ensure
      Model::close
    end
  end
end

NicovideoCrawler.new.main
