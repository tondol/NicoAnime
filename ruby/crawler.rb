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

  def crawl(channel, id, crawled_at)
    num_inserted = 0

    # process each video
    @logs.d("crawler", "crawl: #{channel.creator}")
    channel.items.reverse_each {|item|
      next if crawled_at && item.first_retrieve <= crawled_at

      @nicovideo.watch(item.video_id) {|video|
        @logs.d("crawler", "create: #{video.title}")
        @videos.insert_into(id, video.video_id, video.title, video.description)
        num_inserted += 1
      }
    }

    # update meta properties in the table
    @logs.d("crawler", "#{num_inserted} videos created: #{channel.creator}")
    if num_inserted == 0
      @channels.update_without_modification(id)
    else
      @channels.update_with_modification(id)
    end
  end
  def main
    # logs.d("crawler", ">> run: #{Time.now}")
    @nicovideo = Nicovideo.login(@config["nv"]["mail"], @config["nv"]["password"])

    begin
      @channels.select.each_hash {|row|
        id = row["id"]
        channel_id = row["nicoChannelId"]
        crawled_at = Model::db_time_to_time(row["crawledAt"])

        @nicovideo.channel(channel_id) {|channel|
          crawl(channel, id, crawled_at)
          sleep(1)
        }
      }
    rescue Exception => e
      @logs.e("crawler", "an unexpected error has occurred")
      @logs.e("crawler", e.message)
    ensure
      Model::close
    end
  end
end

NicovideoCrawler.new.main
