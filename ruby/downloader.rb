#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'mysql'
require 'yaml'

require_relative 'NicoVideo/nico'
require_relative 'base'

class NicovideoDownloader
  def initialize
    Model::connect
    @config = Model::config
    @logs = Model::Logs.new
    @videos = Model::Videos.new
  end

  def download_via_http(video, id)
    binary = video.video
    filename = "#{video.video_id}.#{video.type}"
    filepath = "#{@config["contents"]}#{filename}"
    filesize = binary.bytesize

    File.open(filepath, "wb") {|f|
      f.write(binary)
    }

    return filename, filesize
  end
  def download_via_rtmp(video, id)
    params = video.send(:get_params)
    url = URI.parse(URI.decode(params['url']))
    fmst = URI.decode(params['fmst']).split(":")
    playpath = url.query.sub("m=", "")

    tc_url = "#{url.scheme}://#{url.host}#{url.path}"
    page_url = "http://www.nicovideo.jp/watch/#{video.video_id}"
    swf_url = "http://res.nimg.jp/swf/player/secure_nccreator.swf?t=201111091500"
    flash_ver = %q{"WIN 11,6,602,180"}

    resume = ""
    filename = "#{video.video_id}.flv"
    filepath = "#{@config["contents"]}#{filename}"

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
  def download(video, id)
    filename = filesize = nil
    params = video.send(:get_params)
    url = URI.parse(URI.decode(params["url"]))

    # download video
    if url.scheme == "http"
      @logs.d("downloader", "download video via http: #{video.title}")
      filename, filesize = download_via_http(video, id)
    elsif url.scheme == "rtmpe"
      @logs.d("downloader", "download video via rtmp: #{video.title}")
      filename, filesize = download_via_rtmp(video, id)
    end

    binary = video.thumbnail
    thumbname = "#{video.video_id}.jpg"
    thumbpath = "#{@config["contents"]}#{thumbname}"

    # download thumbnail
    @logs.d("downloader", "download thumbnail: #{video.title}")
    File.open(thumbpath, "wb") {|f|
      f.write(binary)
    }

    # update meta properties in the table
    @logs.d("downloader", "modified: #{video.title}")
    @videos.update_with_success(filename, filesize, id)
  end
  def main
    # logs.d("downloader", ">> run: #{Time.now}")
    @nicovideo = Nicovideo.login(@config["nv"]["mail"], @config["nv"]["password"])

    begin
      @videos.select.each_hash {|row|
        id = row["id"]
        video_id = row["nicoVideoId"]

        @nicovideo.watch(video_id) {|video|
          begin
            download(video, id)
            sleep 30
          rescue Exception => e
            @logs.e("downloader", "unavailable: #{title}")
            @logs.e("downloader", e.message)
            @videos.update_with_failure(id)
          end
        }
      }
    rescue Exception => e
      @logs.e("downloader", "an unexpected error has occurred")
      @logs.e("downloader", e.message)
    ensure
      Model::close
    end
  end
end

NicovideoDownloader.new.main
