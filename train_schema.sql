CREATE DATABASE IF NOT EXISTS `train_db`;
USE `train_db`;

DROP TABLE IF EXISTS `CUSTOMER_QUESTION`;
DROP TABLE IF EXISTS `RESERVATION`;
DROP TABLE IF EXISTS `STOPS_AT`;
DROP TABLE IF EXISTS `TRAIN_SCHEDULE`;
DROP TABLE IF EXISTS `TRANSIT_LINE`;
DROP TABLE IF EXISTS `STATION`;
DROP TABLE IF EXISTS `TRAIN`;
DROP TABLE IF EXISTS `EMPLOYEE`;
DROP TABLE IF EXISTS `CUSTOMER`;

CREATE TABLE `CUSTOMER` (
  `cid` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  PRIMARY KEY (`cid`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `EMPLOYEE` (
  `ssn` char(9) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` varchar(30) NOT NULL,
  PRIMARY KEY (`ssn`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `TRAIN` (
  `train_id` char(5) NOT NULL,
  PRIMARY KEY (`train_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `STATION` (
  `station_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` char(2) NOT NULL,
  PRIMARY KEY (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `TRANSIT_LINE` (
  `line_name` varchar(100) NOT NULL,
  `origin_station_id` int NOT NULL,
  `destination_station_id` int NOT NULL,
  `base_fare` int NOT NULL,
  PRIMARY KEY (`line_name`),
  FOREIGN KEY (`origin_station_id`) REFERENCES `STATION` (`station_id`),
  FOREIGN KEY (`destination_station_id`) REFERENCES `STATION` (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `TRAIN_SCHEDULE` (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `train_id` char(5) NOT NULL,
  `line_name` varchar(100) NOT NULL,
  `departure_datetime` datetime NOT NULL,
  `arrival_datetime` datetime NOT NULL,
  PRIMARY KEY (`schedule_id`),
  FOREIGN KEY (`train_id`) REFERENCES `TRAIN` (`train_id`),
  FOREIGN KEY (`line_name`) REFERENCES `TRANSIT_LINE` (`line_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `STOPS_AT` (
  `schedule_id` int NOT NULL,
  `station_id` int NOT NULL,
  `stop_sequence` int NOT NULL,
  `arrival_datetime` datetime,
  `departure_datetime` datetime,
  PRIMARY KEY (`schedule_id`, `stop_sequence`),
  FOREIGN KEY (`schedule_id`) REFERENCES `TRAIN_SCHEDULE` (`schedule_id`) ON DELETE CASCADE,
  FOREIGN KEY (`station_id`) REFERENCES `STATION` (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `RESERVATION` (
  `reservation_number` int NOT NULL AUTO_INCREMENT,
  `cid` int NOT NULL,
  `schedule_id` int NOT NULL,
  `origin_station_id` int NOT NULL,
  `destination_station_id` int NOT NULL,
  `reservation_date` date NOT NULL,
  `trip_type` varchar(20) NOT NULL,
  `passenger_type` varchar(20) NOT NULL,
  `total_fare` int NOT NULL,
  `status` varchar(20) NOT NULL,
  PRIMARY KEY (`reservation_number`),
  FOREIGN KEY (`cid`) REFERENCES `CUSTOMER` (`cid`),
  FOREIGN KEY (`schedule_id`) REFERENCES `TRAIN_SCHEDULE` (`schedule_id`),
  FOREIGN KEY (`origin_station_id`) REFERENCES `STATION` (`station_id`),
  FOREIGN KEY (`destination_station_id`) REFERENCES `STATION` (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `CUSTOMER_QUESTION` (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `cid` int NOT NULL,
  `employee_ssn` char(9),
  `question_text` text NOT NULL,
  `answer_text` text,
  `question_datetime` datetime NOT NULL,
  `answer_datetime` datetime,
  PRIMARY KEY (`question_id`),
  FOREIGN KEY (`cid`) REFERENCES `CUSTOMER` (`cid`),
  FOREIGN KEY (`employee_ssn`) REFERENCES `EMPLOYEE` (`ssn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample Data Inserts

-- Insert Admin and Customer Reps
INSERT INTO `EMPLOYEE` (`ssn`, `first_name`, `last_name`, `username`, `password`, `role`) VALUES
('111223333', 'Admin', 'User', 'admin', 'adminpassword', 'admin'),
('444556666', 'Rep', 'One', 'rep1', 'reppassword', 'customer_rep');

-- Insert Customers
INSERT INTO `CUSTOMER` (`first_name`, `last_name`, `email`, `username`, `password`) VALUES
('John', 'Doe', 'john@example.com', 'customer1', 'customerpassword'),
('Jane', 'Smith', 'jane@example.com', 'customer2', 'customerpassword');

-- Insert Stations
INSERT INTO `STATION` (`name`, `city`, `state`) VALUES
('New York Penn Station', 'New York', 'NY'),
('Newark Penn Station', 'Newark', 'NJ'),
('Metropark', 'Iselin', 'NJ'),
('New Brunswick', 'New Brunswick', 'NJ'),
('Princeton Junction', 'Iselin', 'NJ'),
('Trenton Transit Center', 'Trenton', 'NJ'),
('Philadelphia 30th St', 'Philadelphia', 'PA');

-- Insert Trains
INSERT INTO `TRAIN` (`train_id`) VALUES
('T0001'), ('T0002'), ('T0003'), ('T0004');

-- Insert Transit Lines
INSERT INTO `TRANSIT_LINE` (`line_name`, `origin_station_id`, `destination_station_id`, `base_fare`) VALUES
('Northeast Corridor', 1, 7, 50),
('NJ Coast Line', 1, 4, 30);

-- Insert Train Schedules
INSERT INTO `TRAIN_SCHEDULE` (`train_id`, `line_name`, `departure_datetime`, `arrival_datetime`) VALUES
('T0001', 'Northeast Corridor', '2026-08-01 08:00:00', '2026-08-01 09:30:00'),
('T0002', 'Northeast Corridor', '2026-08-01 12:00:00', '2026-08-01 13:30:00');

-- Insert Stops
INSERT INTO `STOPS_AT` (`schedule_id`, `station_id`, `stop_sequence`, `arrival_datetime`, `departure_datetime`) VALUES
(1, 1, 1, NULL, '2026-08-01 08:00:00'),
(1, 2, 2, '2026-08-01 08:20:00', '2026-08-01 08:25:00'),
(1, 4, 3, '2026-08-01 08:45:00', '2026-08-01 08:50:00'),
(1, 6, 4, '2026-08-01 09:10:00', '2026-08-01 09:15:00'),
(1, 7, 5, '2026-08-01 09:30:00', NULL);

-- Insert Reservations
INSERT INTO `RESERVATION` (`cid`, `schedule_id`, `origin_station_id`, `destination_station_id`, `reservation_date`, `trip_type`, `passenger_type`, `total_fare`, `status`) VALUES
(1, 1, 1, 7, '2026-07-20', 'one-way', 'adult', 50, 'confirmed');

-- Insert Questions
INSERT INTO `CUSTOMER_QUESTION` (`cid`, `question_text`, `question_datetime`) VALUES
(1, 'Is there a dining car on the Northeast Corridor?', '2026-07-20 10:00:00');
