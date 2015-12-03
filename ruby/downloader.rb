#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require_relative 'NicoVideo/nico'
require_relative 'base'

class NicovideoDownloader
  def initialize
    Model::connect
    @logs = Model::Logs.new
    @videos = Model::Videos.new
    @config = Model::load_config
  end

  def download_nico_via_http(nv_video)
    filename = "#{nv_video.video_id}.#{nv_video.type}"
    filepath = @config["contents_dir"] + "/" + filename

    File.open(filepath, "wb") {|f|
      nv_video.video_with_block {|data|
        f.write(data)
      }
    }

    return filename, File.size(filepath)
  end
  def download_nico_via_rtmp(nv_video)
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
    filepath = @config["contents_dir"] + "/" + filename

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
  def download_nico_thumbnail(nv_video)
    filename = "#{nv_video.video_id}.jpg"
    filepath = @config["contents_dir"] + "/" + filename

    File.open(filepath, "wb") {|f|
      f.write(nv_video.thumbnail)
    }
  end
  def download_nico_comments(nv_video)
    filename = "#{nv_video.video_id}.xml"
    filepath = @config["contents_dir"] + "/" + filename

    File.open(filepath, "wb") {|f|
      f.write(nv_video.comments(500))
    }
  end
  def download_nico(video)
    begin
      @nicovideo.watch(video["serviceVideoId"]) {|nv_video|
        filename = filesize = nil
        params = nv_video.send(:get_params)
        url = URI.parse(URI.decode(params["url"]))

        if url.scheme == "http"
          @logs.d("downloader", "download/video: #{video["title"]} (http)")
          filename, filesize = download_nico_via_http(nv_video)
        elsif url.scheme == "rtmpe"
          @logs.d("downloader", "download/video: #{video["title"]} (rtmp)")
          filename, filesize = download_nico_via_rtmp(nv_video)
        else
          raise Nicovideo::UnavailableVideoError.new
        end

        @logs.d("downloader", "download/thumbnail: #{video["title"]}")
        download_nico_thumbnail(nv_video)

        @logs.d("downloader", "download/comments: #{video["title"]}")
        download_nico_comments(nv_video)

        @logs.d("downloader", "download: #{video["title"]}")
        @videos.update_with_success(video["id"], filename, filesize)
        sleep 10
      }
    rescue StandardError => e
      @logs.e("downloader", "download/unavailable: #{video["title"]}")
      @logs.e("downloader", "download/unavailable: #{e.message}")
      $stderr.puts(e.backtrace)
      @videos.update_with_failure(video["id"])
    end
  end

  def download_gyao_video(video)
    filename = filepath = nil

    https = Net::HTTP.new("gw.gyao.yahoo.co.jp", 443)
    https.use_ssl = true
    https.start {
      response = https.get("/v1/hls/" + video["serviceVideoId"].gsub('/', ':') + "/variant.m3u8?" +
          "device_type=1100&delivery_type=2&appkey=52hd8q-XnozawaXc727tmojaFD.SD1yc&" +
          "appid=ff_rbJCxg67.bRk_lk7CbWFjhorGVKjvFsRgiLDHW4PE.vN6zxDW6KyRr1Zw3rI-")
      lines = response.body.force_encoding('utf-8').split("\n")

      urls = []
      (0 ... lines.size).to_a.each_cons(2) {|k1, k2|
        if lines[k1] =~ /BANDWIDTH=(\d+)/
          urls << [$1.to_i, "https://gw.gyao.yahoo.co.jp" + lines[k2]]
        end
      }
 
      url = urls.sort {|v1, v2| v2[0] <=> v1[0] }[0][1]
      filename = video["serviceVideoId"].gsub('/', '_') + ".mp4"
      filepath = @config["contents_dir"] + "/" + filename
      system("ffmpeg -bsf:a aac_adtstoasc -codec copy -movflags faststart #{filepath} -i #{url}")
    }

    if $?.exitstatus == 0
      filesize = File.size(filepath)
      return filename, filesize
    else
      raise Gyao::UnavailableVideoError.new
    end
  end
  def download_gyao_thumbnail(video)
    filename = video["serviceVideoId"].gsub('/', '_') + ".jpg"
    filepath = @config["contents_dir"] + "/" + filename

    File.open(filepath, "wb") {|f|
      Net::HTTP.start("gyao.yahoo.co.jp") {|http|
        response = http.get("/player/" + video["serviceVideoId"] + "/")
        url = $1 if response.body =~ %r!<meta itemprop="thumbnailUrl" content="(.*?)" />!
        f.write(Net::HTTP.get_response(URI.parse(url)).body)
      }
    }
  end
  def download_gyao(video)
    begin
      @logs.d("downloader", "download/video: #{video["title"]} (http)")
      filename, filesize = download_gyao_video(video)

      @logs.d("downloader", "download/thumbnail: #{video["title"]}")
      download_gyao_thumbnail(video)

      @logs.d("downloader", "download: #{video["title"]}")
      @videos.update_with_success(video["id"], filename, filesize)
      sleep 10
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
        if video["service"] == "nico"
          download_nico(video)
        elsif video["service"] == "gyao"
          download_gyao(video)
        end
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
