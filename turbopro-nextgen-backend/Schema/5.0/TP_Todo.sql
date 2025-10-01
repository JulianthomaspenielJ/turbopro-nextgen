DROP table IF EXISTS `TODO`;

CREATE TABLE `TODO` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(25) DEFAULT NULL,
  `detail` varchar(255) DEFAULT NULL,
  `color` varchar(25) DEFAULT NULL,
  `type1` varchar(4) DEFAULT NULL,
  `done` tinyint DEFAULT 0,
  created timestamp default now(),
  updated timestamp default now() on update now(),
  PRIMARY KEY (`id`),
  INDEX `itype1` (`type1`)
);

DROP table IF EXISTS `TODO_ASSIGNMENT`;

CREATE TABLE `TODO_ASSIGNMENT` (
  TODO_id int,
  UserLogin int,
  INDEX `todo_id` (`TODO_id`),
  INDEX `userlogin` (`UserLogin`)
);
