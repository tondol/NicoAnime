#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'mysql'
require 'yaml'

require_relative 'NicoVideo/nico'

module Model
  def self.connect
    @@db = Mysql::new(config["db"]["host"],
      config["db"]["user"],
      config["db"]["password"],
      config["db"]["name"])
  end
  def self.close
    @@db.close
  end
  def self.config
    YAML.load_file(File.dirname(__FILE__) + '/config.yml')
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
    def select
      statement = @db.prepare("SELECT * FROM `channels`" +
        " WHERE `crawledAt` IS NULL OR `crawledAt` < NOW() - INTERVAL ? HOUR" +
        " ORDER BY `crawledAt` ASC")
      statement.execute(6)
    end
    def update_with_modification(id)
      statement = @db.prepare("UPDATE `channels`" +
        " SET `crawledAt` = ?, `modifiedAt` = ?" +
        " WHERE `id` = ?")
      statement.execute(Time.now, Time.now, id)
    end
    def update_without_modification(id)
      statement = @db.prepare("UPDATE `channels`" +
        " SET `crawledAt` = ?" +
        " WHERE `id` = ?")
      statement.execute(Time.now, id)
    end
  end

  class Videos
    def initialize
      @db = Model::db
    end
    def select
      statement = @db.prepare("SELECT * FROM `videos`" +
        " WHERE `downloadedAt` IS NULL AND `deletedAt` IS NULL" +
        " ORDER BY `createdAt` ASC")
      statement.execute
    end
    def insert_into(channel_id, video_id, title, description)
      statement = @db.prepare("INSERT INTO `videos`" +
        " (`channelId`, `nicoVideoId`, `title`, `description`, `createdAt`)" +
        " VALUES (?, ?, ?, ?, ?)")
      statement.execute(channel_id, video_id, title, description, Time.now)
    end
    def update_with_success(filename, filesize, id)
      statement = @db.prepare("UPDATE `videos`" +
        " SET `filename` = ?, `filesize` = ?, `downloadedAt` = ?" +
        " WHERE `id` = ?")
      statement.execute(filename, filesize, Time.now, id)
    end
    def update_with_failure(id)
      statement = @db.prepare("UPDATE `videos`" +
        " SET `retryCount` = `retryCount` + 1" +
        " WHERE `id` = ?")
      statement.execute(id)
      statement = @db.prepare("UPDATE `videos`" +
        " SET `deletedAt` = ?" +
        " WHERE `id` = ? AND `retryCount` >= 3")
      statement.execute(Time.now, id)
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

