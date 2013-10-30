CREATE TABLE IF NOT EXISTS `channels` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`nicoChannelId` varchar(255) NOT NULL,
	`title` varchar(255) NOT NULL,
	`description` text NOT NULL,
	`keywords` text NOT NULL,
	`createdAt` datetime NOT NULL,
	`modifiedAt` datetime DEFAULT NULL,
	`crawledAt` datetime DEFAULT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY `nicoChannelId` (`nicoChannelId`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

CREATE TABLE IF NOT EXISTS `logs` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`kind` varchar(255) NOT NULL,
	`name` varchar(255) NOT NULL,
	`message` text NOT NULL,
	`createdAt` datetime NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1228 ;

CREATE TABLE IF NOT EXISTS `videos` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `channelId` int(11) NOT NULL,
	  `nicoVideoId` varchar(255) NOT NULL,
	  `title` varchar(255) NOT NULL,
	  `description` text NOT NULL,
	  `filename` varchar(255) DEFAULT NULL,
	  `filesize` int(11) DEFAULT NULL,
	  `retryCount` int(11) NOT NULL,
	  `createdAt` datetime NOT NULL,
	  `downloadedAt` datetime DEFAULT NULL,
	  `deletedAt` datetime DEFAULT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `nicoVideoId` (`nicoVideoId`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=46 ;
