#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'mysql'
require 'yaml'

require_relative 'NicoVideo/nico'
require_relative 'base'

class NicovideoDownloader
  def initialize
    Model::connect
    @logs = Model::Logs.new
    @videos = Model::Videos.new
    @config = Model::load_config
  end

  def download_via_http(nv_video)
    binary = nv_video.video
    filename = "#{nv_video.video_id}.#{nv_video.type}"
    filepath = @config["contents_dir"] + filename
    filesize = binary.bytesize

    File.open(filepath, "wb") {|f|
      f.write(binary)
    }

    return filename, filesize
  end
  def download_via_rtmp(nv_video)
    params = nv_video.send(:get_params)
    url = URI.parse(URI.decode(params['url']))
    fmst = URI.decode(params['fmst']).split(":")
    playpath = url.query.sub("m=", "")

    tc_url = "#{url.scheme}://#{url.host}#{url.path}"
    page_url = "http://www.nicovideo.jp/watch/#{nv_video.video_id}"
    swf_url = "http://res.nimg.jp/swf/player/secure_nccreator.swf?t=201111091500"
    flash_ver = %q{"WIN 11,6,602,180"}

    resume = ""
    filename = "#{nv_video.video_id}.flv"
    filepath = @config["contents_dir"] + filename

    50.times {|i|
      system("rtmpdump" +
        " -l 2" +
        " -a smile" +
        " -n #{url.host}" +
        " -t #{tc_url}" +
        " -p #{page_url}" +
        " -s #{swf_url}" +
        " -f #{flash_ver}" +
        " -y #{playpath}" +
        " -C S:#{fmst.last}" +
        " -C S:#{fmst.first}" +
        " -C S:#{playpath}" +
        " -o #{filepath}" +
        " #{resume}")
      resume = "-e"
      break if $?.exitstatus != 2
      sleep 1
    }

    if $?.exitstatus == 0
      filesize = File.size(filepath)
      return filename, filesize
    else
      raise Nicovideo::UnavailableVideoError.new
    end
  end
  def download_comments(nv_video)
    filename = "#{nv_video.video_id}.xml"
    filepath = @config["contents_dir"] + filename

    File.open(filepath, "wb") {|f|
      f.write(nv_video.comments(500))
    }
  end
  def download_thumbnail(nv_video)
    filename = "#{nv_video.video_id}.jpg"
    filepath = @config["contents_dir"] + filename

    File.open(filepath, "wb") {|f|
      f.write(nv_video.thumbnail)
    }
  end
  def download(video)
    begin
      @nicovideo.watch(video["nicoVideoId"]) {|nv_video|
        filename = filesize = nil
        params = nv_video.send(:get_params)
        url = URI.parse(URI.decode(params["url"]))

        if url.scheme == "http"
          @logs.d("downloader", "download/video: #{video["title"]} (http)")
          filename, filesize = download_via_http(nv_video)
        elsif url.scheme == "rtmpe"
          @logs.d("downloader", "download/video: #{video["title"]} (rtmp)")
          filename, filesize = download_via_rtmp(nv_video)
        else
          raise Nicovideo::UnavailableVideoError.new
        end

        @logs.d("downloader", "download/comments: #{video["title"]}")
        download_comments(nv_video)

        @logs.d("downloader", "download/thumbnail: #{video["title"]}")
        download_thumbnail(nv_video)

        @logs.d("downloader", "download: #{video["title"]}")
        @videos.update_with_success(video["id"], filename, filesize)
        sleep 30
      }
    rescue StandardError => e
      @logs.e("downloader", "download/unavailable: #{video["title"]}")
      @logs.e("downloader", "download/unavailable: #{e.message}")
      $stderr.puts(e.backtrace)
      @videos.update_with_failure(video["id"])
    end
  end
  def main
    # logs.d("downloader", ">> run: #{Time.now}")
    @nicovideo = Nicovideo.login(@config["nv"]["mail"], @config["nv"]["password"], @config["nv"]["session"])
    @session = @nicovideo.instance_variable_get(:@session)
    @config["nv"]["session"] = @session

    begin
      @videos.select_all_not_downloaded.each_hash {|video|
        download(video)
      }
    rescue Exception => e
      @logs.e("downloader", "error: #{e.message}")
      @logs.e("downloader", "trace: #{e.backtrace}")
      $stderr.puts(e.backtrace)
    ensure
      Model::save_config(@config)
      Model::close
    end
  end
end

NicovideoDownloader.new.main
