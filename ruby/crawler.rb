#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

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

  def crawl_nico(channel)
    num_inserted = 0
    hash = {}

    @videos.select_all_by_channel_id(channel["id"]).each_hash {|video|
      hash[video["serviceVideoId"]] = true
    }

    @nicovideo.channel(channel["serviceChannelId"]) {|nv_channel|
      @logs.d("crawler", "crawl: #{channel["title"]}")
      nv_channel.items.reverse_each {|item|
        begin
          next if hash.key?(item.video_id)
          hash[item.video_id] = true
          @nicovideo.watch(item.video_id) {|nv_video|
            @logs.d("crawler", "crawl/insert: #{nv_video.title}")
            @videos.insert_into(channel["id"], nv_video.video_id, nv_video.title, nv_video.description)
          }
          num_inserted += 1
        rescue Exception => e
          @logs.e("crawler", "crawl/unavailable: #{item.title}")
          @logs.e("crawler", "crawl/unavailable: #{e.message}")
          $stderr.puts(e.backtrace)
        end
      }
    }

    @logs.d("crawler", "crawl/insert: #{channel["title"]} (#{num_inserted})")
    if num_inserted == 0
      @channels.update_without_modification(channel["id"])
      sleep 1
    else
      @channels.update_with_modification(channel["id"])
      sleep 1
    end
  end
  def crawl_gyao(channel)
    num_inserted = 0
    hash = {}
    video_ids = []

    @videos.select_all_by_channel_id(channel["id"]).each_hash {|video|
      hash[video["serviceVideoId"]] = true
    }

    @logs.d("crawler", "crawl: #{channel["title"]}")
    Net::HTTP.start('gyao.yahoo.co.jp') {|http|
      response = http.get('/p/' + channel["serviceChannelId"] + '/')
      video_ids = response.body.scan(%r!/player/(\d+/v\d+/v\d+)/!).flatten
      video_ids = video_ids.select {|video_id|
        video_id.force_encoding("utf-8").include?(channel["serviceChannelId"])
      }.uniq
    }
 
    video_ids.each {|video_id|
      begin
        next if hash.key?(video_id)
        hash[video_id] = true
        Net::HTTP.start('gyao.yahoo.co.jp') {|http|
          response = http.get('/player/' + video_id + '/')
          title = $1 if response.body =~ %r!<meta itemprop="name" content="(.*?)" />!
          description = $1 if response.body =~ %r!<meta itemprop="description" content="(.*?)" />!
          @logs.d("crawler", "crawl/insert: #{title}")
          @videos.insert_into(channel["id"], video_id, title, description)
          num_inserted += 1
        }
        sleep 1
      rescue Exception => e
        @logs.e("crawler", "crawl/unavailable: #{video_id}")
        @logs.e("crawler", "crawl/unavailable: #{e.message}")
        $stderr.puts(e.backtrace)
        sleep 1
      end
    }

    @logs.d("crawler", "crawl/insert: #{channel["title"]} (#{num_inserted})")
    if num_inserted == 0
      @channels.update_without_modification(channel["id"])
      sleep 1
    else
      @channels.update_with_modification(channel["id"])
      sleep 1
    end
  end

  def main
    # logs.d("crawler", ">> run: #{Time.now}")
    @nicovideo = Nicovideo.login(@config["nv"]["mail"], @config["nv"]["password"], @config["nv"]["session"])
    @session = @nicovideo.instance_variable_get(:@session)
    @config["nv"]["session"] = @session

    begin
      @channels.select_all.each_hash {|video|
        video["modifiedAt"] = Model::db_time_to_time(video["modifiedAt"])
	if video["service"] == "nico"
          crawl_nico(video)
        elsif video["service"] == "gyao"
          crawl_gyao(video)
        end
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
