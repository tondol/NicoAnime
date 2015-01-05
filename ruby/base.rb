#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'mysql'
require 'yaml'

require_relative 'NicoVideo/nico'

module Model
  def self.connect
    config = load_config
    @@db = Mysql::new(config["db"]["host"],
      config["db"]["user"],
      config["db"]["password"],
      config["db"]["database"])
    @@db.charset = "utf8"
  end
  def self.close
    @@db.close
  end
  def self.load_config
    config_dir = File.dirname(File.dirname(__FILE__))
    YAML.load_file(config_dir + '/config.yml')
  end
  def self.save_config(config)
    config_dir = File.dirname(File.dirname(__FILE__))
    File.write(config_dir + '/config.yml', config.to_yaml)
  end
  def self.db
    @@db
  end
  def self.db_time_to_time(t)
    return nil unless t
    Time.local(t.year, t.mon, t.day, t.hour, t.min, t.sec)
  end

  class Channels
    def initialize
      @db = Model::db
    end
    def select_all
      statement = @db.prepare("SELECT * FROM `channels`" +
        " WHERE `crawledAt` IS NULL OR `crawledAt` < NOW() - INTERVAL ? HOUR" +
        " ORDER BY `crawledAt` ASC")
      statement.execute(6)
    end
    def update_with_modification(id)
      # 新しい動画が見つかったとき
      statement = @db.prepare("UPDATE `channels`" +
        " SET `crawledAt` = ?, `modifiedAt` = ?" +
        " WHERE `id` = ?")
      statement.execute(Time.now, Time.now, id)
    end
    def update_without_modification(id)
      # 新しい動画が見つからなかったとき
      statement = @db.prepare("UPDATE `channels`" +
        " SET `crawledAt` = ?" +
        " WHERE `id` = ?")
      statement.execute(Time.now, id)
    end
    def delete(id)
      statement = @db.prepare("DELETE FROM `channels`" +
        " WHERE `id` = ?")
      statement.execute(id)
    end
  end

  class Videos
    def initialize
      @db = Model::db
    end
    def select_all_downloaded
      statement = @db.prepare("SELECT * FROM `videos`" +
        " WHERE `downloadedAt` IS NOT NULL AND `deletedAt` IS NULL")
      statement.execute
    end
    def select_all_not_downloaded
      # 論理削除されたものをダウンロード対象から除く
      statement = @db.prepare("SELECT * FROM `videos`" +
        " WHERE `downloadedAt` IS NULL AND `deletedAt` IS NULL" +
        " ORDER BY `createdAt` ASC")
      statement.execute
    end
    def select_all_by_channel_id(channel_id)
      # 論理削除されたものを衝突検査の対象に含める
      statement = @db.prepare("SELECT * FROM `videos`" +
        " WHERE `channelId` = ?")
      statement.execute(channel_id)
    end
    def insert_into(channel_id, video_id, title, description)
      statement = @db.prepare("INSERT INTO `videos`" +
        " (`channelId`, `nicoVideoId`, `title`, `description`, `createdAt`)" +
        " VALUES (?, ?, ?, ?, ?)")
      statement.execute(channel_id, video_id, title, description, Time.now)
    end
    def update_with_success(id, filename, filesize)
      # 動画のダウンロードに成功したとき
      statement = @db.prepare("UPDATE `videos`" +
        " SET `filename` = ?, `filesize` = ?, `downloadedAt` = ?" +
        " WHERE `id` = ?")
      statement.execute(filename, filesize, Time.now, id)
    end
    def update_with_failure(id)
      # 動画のダウンロードに失敗したとき
      statement = @db.prepare("UPDATE `videos`" +
        " SET `retryCount` = `retryCount` + 1" +
        " WHERE `id` = ?")
      statement.execute(id)
      statement = @db.prepare("UPDATE `videos`" +
        " SET `deletedAt` = ?" +
        " WHERE `id` = ? AND `retryCount` >= 3")
      statement.execute(Time.now, id)
    end
    def delete_by_filename(filename)
      statement = @db.prepare("DELETE FROM `videos`" +
        " WHERE `filename` = ?")
      statement.execute(filename)
    end
  end

  class Logs
    def initialize
      @db = Model::db
    end
    def d(name, message)
      $stderr.puts "Logs.d | #{name} | #{message}"
      statement = @db.prepare("INSERT INTO `logs`" +
        " (`kind`, `name`, `message`, `createdAt`)" +
        " VALUES (?, ?, ?, ?)")
      statement.execute("d", name, message, Time.now)
    end
    def e(name, message)
      $stderr.puts "Logs.e | #{name} | #{message}"
      statement = @db.prepare("INSERT INTO `logs`" +
        " (`kind`, `name`, `message`, `createdAt`)" +
        " VALUES (?, ?, ?, ?)")
      statement.execute("e", name, message, Time.now)
    end
  end
end

