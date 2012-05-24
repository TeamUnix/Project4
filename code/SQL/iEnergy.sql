-- phpMyAdmin SQL Dump
-- version 2.11.11.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: May 24, 2012 at 02:12 PM
-- Server version: 5.0.95
-- PHP Version: 5.1.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `iEnergy`
--

-- --------------------------------------------------------

--
-- Table structure for table `DEVICE`
--

CREATE TABLE IF NOT EXISTS `DEVICE` (
  `ID_DEVICE` int(11) NOT NULL auto_increment,
  `IP` varchar(16) NOT NULL,
  PRIMARY KEY  (`ID_DEVICE`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `DEVICE`
--

INSERT INTO `DEVICE` (`ID_DEVICE`, `IP`) VALUES
(1, 'localhost'),
(2, '127.0.0.1');

-- --------------------------------------------------------

--
-- Table structure for table `ERRORS`
--

CREATE TABLE IF NOT EXISTS `ERRORS` (
  `ID_ERROR` int(11) NOT NULL auto_increment,
  `NAME` varchar(20) NOT NULL,
  PRIMARY KEY  (`ID_ERROR`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `ERRORS`
--

INSERT INTO `ERRORS` (`ID_ERROR`, `NAME`) VALUES
(1, 'NONE');

-- --------------------------------------------------------

--
-- Table structure for table `LOGS`
--

CREATE TABLE IF NOT EXISTS `LOGS` (
  `ID_LOG` int(11) NOT NULL auto_increment,
  `ID_MODULE` int(11) NOT NULL,
  `DATE_TIME` datetime NOT NULL,
  `ID_STATUS` int(11) NOT NULL,
  `ID_USER` int(11) NOT NULL,
  `ID_ERROR` int(11) NOT NULL,
  PRIMARY KEY  (`ID_LOG`),
  KEY `ID_MODULE` (`ID_MODULE`,`ID_STATUS`,`ID_USER`,`ID_ERROR`),
  KEY `ID_STATUS` (`ID_STATUS`),
  KEY `ID_USER` (`ID_USER`,`ID_ERROR`),
  KEY `ID_ERROR` (`ID_ERROR`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=77 ;

--
-- Dumping data for table `LOGS`
--

INSERT INTO `LOGS` (`ID_LOG`, `ID_MODULE`, `DATE_TIME`, `ID_STATUS`, `ID_USER`, `ID_ERROR`) VALUES
(4, 0, '2012-05-21 09:16:31', 3, 3, 1),
(5, 1, '2012-05-21 09:28:45', 1, 3, 1),
(6, 1, '2012-05-21 09:28:55', 3, 3, 1),
(7, 2, '2012-05-21 09:29:19', 1, 3, 1),
(8, 2, '2012-05-21 09:29:24', 3, 3, 1),
(9, 2, '2012-05-21 09:29:32', 4, 3, 1),
(10, 1, '2012-05-21 09:29:33', 4, 3, 1),
(11, 0, '2012-05-21 09:31:10', 4, 3, 1),
(12, 0, '2012-05-21 09:32:51', 3, 3, 1),
(13, 2, '2012-05-21 09:33:00', 3, 3, 1),
(14, 1, '2012-05-21 09:33:01', 3, 3, 1),
(15, 0, '2012-05-21 09:33:04', 4, 3, 1),
(16, 0, '2012-05-21 09:33:05', 3, 3, 1),
(17, 2, '2012-05-21 09:33:10', 4, 3, 1),
(18, 1, '2012-05-21 09:33:13', 4, 3, 1),
(19, 0, '2012-05-21 09:33:17', 4, 3, 1),
(20, 0, '2012-05-21 09:33:23', 3, 3, 1),
(21, 2, '2012-05-21 09:34:03', 3, 3, 1),
(22, 2, '2012-05-21 09:34:06', 4, 3, 1),
(23, 2, '2012-05-21 09:34:08', 3, 3, 1),
(24, 2, '2012-05-21 09:34:10', 4, 3, 1),
(25, 2, '2012-05-21 09:34:26', 3, 3, 1),
(26, 2, '2012-05-21 09:34:30', 4, 3, 1),
(27, 0, '2012-05-21 09:34:31', 4, 3, 1),
(28, 0, '2012-05-21 09:34:32', 3, 3, 1),
(29, 1, '2012-05-21 09:34:41', 3, 3, 1),
(30, 1, '2012-05-21 09:34:42', 4, 3, 1),
(31, 1, '2012-05-21 09:34:43', 3, 3, 1),
(32, 1, '2012-05-21 09:34:44', 4, 3, 1),
(33, 0, '2012-05-21 09:35:00', 4, 3, 1),
(34, 0, '2012-05-21 09:35:01', 3, 3, 1),
(35, 2, '2012-05-21 09:35:04', 3, 3, 1),
(36, 2, '2012-05-21 09:35:04', 4, 3, 1),
(37, 2, '2012-05-21 09:35:05', 4, 3, 1),
(38, 2, '2012-05-21 09:35:14', 3, 3, 1),
(39, 2, '2012-05-21 09:35:15', 4, 3, 1),
(40, 1, '2012-05-21 09:35:17', 3, 3, 1),
(41, 1, '2012-05-21 09:35:18', 4, 3, 1),
(42, 2, '2012-05-21 13:39:03', 3, 3, 1),
(43, 1, '2012-05-21 13:39:06', 3, 3, 1),
(44, 2, '2012-05-22 13:47:56', 4, 3, 1),
(45, 0, '2012-05-22 13:48:00', 4, 3, 1),
(46, 0, '2012-05-22 13:48:02', 3, 3, 1),
(47, 1, '2012-05-22 13:48:04', 4, 3, 1),
(48, 1, '2012-05-22 14:06:48', 3, 3, 1),
(49, 2, '2012-05-22 14:06:51', 3, 3, 1),
(50, 0, '2012-05-22 14:07:16', 4, 3, 1),
(51, 0, '2012-05-22 14:10:31', 3, 3, 1),
(52, 2, '2012-05-22 14:10:37', 4, 3, 1),
(53, 1, '2012-05-22 14:10:39', 4, 3, 1),
(54, 2, '2012-05-22 14:10:54', 3, 3, 1),
(55, 2, '2012-05-22 14:15:54', 4, 3, 1),
(56, 2, '2012-05-22 14:15:56', 3, 3, 1),
(57, 0, '2012-05-22 14:15:57', 4, 3, 1),
(58, 0, '2012-05-22 14:15:58', 3, 3, 1),
(59, 0, '2012-05-22 14:15:59', 4, 3, 1),
(60, 0, '2012-05-22 14:16:00', 3, 3, 1),
(61, 0, '2012-05-22 14:16:02', 4, 3, 1),
(62, 0, '2012-05-22 14:16:02', 3, 3, 1),
(63, 1, '2012-05-22 14:16:04', 3, 3, 1),
(64, 0, '2012-05-22 14:16:06', 4, 3, 1),
(65, 0, '2012-05-22 14:16:12', 3, 3, 1),
(66, 2, '2012-05-22 14:16:15', 4, 3, 1),
(67, 2, '2012-05-22 14:16:18', 3, 3, 1),
(68, 2, '2012-05-22 14:16:26', 4, 3, 1),
(69, 2, '2012-05-23 09:10:50', 3, 3, 1),
(70, 2, '2012-05-23 09:10:51', 4, 3, 1),
(71, 0, '2012-05-23 09:10:54', 4, 3, 1),
(72, 0, '2012-05-23 09:10:56', 3, 3, 1),
(73, 0, '2012-05-23 09:10:58', 4, 3, 1),
(74, 0, '2012-05-23 09:11:00', 3, 3, 1),
(75, 0, '2012-05-23 09:21:30', 4, 3, 1),
(76, 0, '2012-05-23 09:21:32', 3, 3, 1);

-- --------------------------------------------------------

--
-- Table structure for table `MEASUREMENTS`
--

CREATE TABLE IF NOT EXISTS `MEASUREMENTS` (
  `ID_MEASURE` int(11) NOT NULL auto_increment,
  `ID_SENSOR` int(11) NOT NULL,
  `DATE_TIME` datetime NOT NULL,
  `HUB_PORT` int(11) NOT NULL,
  `VALUE` float NOT NULL,
  PRIMARY KEY  (`ID_MEASURE`),
  KEY `ID_SENSOR` (`ID_SENSOR`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `MEASUREMENTS`
--

INSERT INTO `MEASUREMENTS` (`ID_MEASURE`, `ID_SENSOR`, `DATE_TIME`, `HUB_PORT`, `VALUE`) VALUES
(1, 0, '2012-05-21 08:45:20', 1, 10),
(2, 0, '2012-05-21 08:45:59', 1, 10),
(3, 0, '2012-05-21 08:45:59', 1, 10),
(4, 0, '2012-05-21 08:46:40', 1, -20),
(5, 0, '2012-05-21 08:55:36', 1, 6),
(6, 0, '2012-05-23 09:09:17', 0, -3.1),
(7, 0, '2012-05-23 09:15:10', 0, -3.2),
(8, 0, '2012-05-23 09:15:31', 0, 9),
(9, 0, '2012-05-23 09:21:13', 0, -1);

-- --------------------------------------------------------

--
-- Table structure for table `MERGES`
--

CREATE TABLE IF NOT EXISTS `MERGES` (
  `ID_MERGE` int(11) NOT NULL auto_increment,
  `DATE_FROM` datetime NOT NULL,
  `DATE_TO` datetime NOT NULL,
  `ID_SENSOR` int(11) NOT NULL,
  `VALUE` float NOT NULL,
  PRIMARY KEY  (`ID_MERGE`),
  UNIQUE KEY `ID_SENSOR` (`ID_SENSOR`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `MERGES`
--


-- --------------------------------------------------------

--
-- Table structure for table `MODULES`
--

CREATE TABLE IF NOT EXISTS `MODULES` (
  `UNIQUE_ID` int(11) NOT NULL,
  `ID_TYPE` int(11) NOT NULL,
  `ID_STATUS` int(11) NOT NULL,
  `NAME` varchar(50) NOT NULL,
  `HUB_PORT` int(11) NOT NULL,
  PRIMARY KEY  (`UNIQUE_ID`),
  KEY `ID_TYPE` (`ID_TYPE`),
  KEY `ID_STATUS` (`ID_STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `MODULES`
--

INSERT INTO `MODULES` (`UNIQUE_ID`, `ID_TYPE`, `ID_STATUS`, `NAME`, `HUB_PORT`) VALUES
(0, 1, 1, 'Energy Hub', 0),
(1, 5, 1, 'Battery', 2),
(2, 4, 1, 'Photovoltaics', 1);

-- --------------------------------------------------------

--
-- Table structure for table `PRIVILEDGES`
--

CREATE TABLE IF NOT EXISTS `PRIVILEDGES` (
  `ID_PRIV` int(11) NOT NULL auto_increment,
  `NAME` varchar(50) NOT NULL,
  PRIMARY KEY  (`ID_PRIV`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `PRIVILEDGES`
--

INSERT INTO `PRIVILEDGES` (`ID_PRIV`, `NAME`) VALUES
(1, 'Root'),
(2, 'Wind Turbine'),
(3, 'Solar Panel'),
(4, 'Caes'),
(5, 'Battery');

-- --------------------------------------------------------

--
-- Table structure for table `SENSORS`
--

CREATE TABLE IF NOT EXISTS `SENSORS` (
  `ID_MODULE` int(11) NOT NULL,
  `ID_SENSOR` int(11) NOT NULL,
  `ID_UNITS` int(11) NOT NULL,
  PRIMARY KEY  (`ID_SENSOR`),
  KEY `ID_MODULE` (`ID_MODULE`),
  KEY `ID_UNITS` (`ID_UNITS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `SENSORS`
--

INSERT INTO `SENSORS` (`ID_MODULE`, `ID_SENSOR`, `ID_UNITS`) VALUES
(0, 0, 2),
(1, 1, 2),
(2, 2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `STATUS`
--

CREATE TABLE IF NOT EXISTS `STATUS` (
  `ID_STATUS` int(11) NOT NULL auto_increment,
  `NAME` varchar(20) NOT NULL,
  PRIMARY KEY  (`ID_STATUS`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `STATUS`
--

INSERT INTO `STATUS` (`ID_STATUS`, `NAME`) VALUES
(1, 'Connected'),
(2, 'Disconnected'),
(3, 'Running'),
(4, 'Stopped'),
(5, 'Warning');

-- --------------------------------------------------------

--
-- Table structure for table `TYPES`
--

CREATE TABLE IF NOT EXISTS `TYPES` (
  `ID_TYPE` int(11) NOT NULL auto_increment,
  `NAME` varchar(50) NOT NULL,
  PRIMARY KEY  (`ID_TYPE`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `TYPES`
--

INSERT INTO `TYPES` (`ID_TYPE`, `NAME`) VALUES
(1, 'Hub'),
(2, 'Hub'),
(3, 'Output'),
(4, 'Input'),
(5, 'Bidirectional');

-- --------------------------------------------------------

--
-- Table structure for table `UNITS`
--

CREATE TABLE IF NOT EXISTS `UNITS` (
  `ID_UNIT` int(11) NOT NULL auto_increment,
  `NAME` varchar(20) NOT NULL,
  PRIMARY KEY  (`ID_UNIT`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `UNITS`
--

INSERT INTO `UNITS` (`ID_UNIT`, `NAME`) VALUES
(1, 'V'),
(2, 'A'),
(3, 'V'),
(4, 'A'),
(5, 'deg'),
(6, 'm/s'),
(7, 'km/h');

-- --------------------------------------------------------

--
-- Table structure for table `USERS`
--

CREATE TABLE IF NOT EXISTS `USERS` (
  `ID_USER` int(11) NOT NULL auto_increment,
  `NAME` varchar(50) NOT NULL,
  `PASS` varchar(20) NOT NULL,
  `EMAIL` varchar(50) NOT NULL,
  `ID_PRIV` int(11) NOT NULL,
  PRIMARY KEY  (`ID_USER`),
  KEY `ID_PRIV` (`ID_PRIV`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `USERS`
--

INSERT INTO `USERS` (`ID_USER`, `NAME`, `PASS`, `EMAIL`, `ID_PRIV`) VALUES
(3, 'root', 'root', '10484@hih.au.dk', 1),
(4, 'wind', 'wind', '', 2),
(5, 'photo', 'photo', '', 3),
(6, 'caes', 'caes', '', 4),
(7, 'bat', 'bat', '', 5);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `LOGS`
--
ALTER TABLE `LOGS`
  ADD CONSTRAINT `LOGS_ibfk_1` FOREIGN KEY (`ID_MODULE`) REFERENCES `MODULES` (`UNIQUE_ID`),
  ADD CONSTRAINT `LOGS_ibfk_2` FOREIGN KEY (`ID_STATUS`) REFERENCES `STATUS` (`ID_STATUS`),
  ADD CONSTRAINT `LOGS_ibfk_3` FOREIGN KEY (`ID_USER`) REFERENCES `USERS` (`ID_USER`),
  ADD CONSTRAINT `LOGS_ibfk_4` FOREIGN KEY (`ID_ERROR`) REFERENCES `ERRORS` (`ID_ERROR`);

--
-- Constraints for table `MEASUREMENTS`
--
ALTER TABLE `MEASUREMENTS`
  ADD CONSTRAINT `MEASUREMENTS_ibfk_1` FOREIGN KEY (`ID_SENSOR`) REFERENCES `SENSORS` (`ID_SENSOR`);

--
-- Constraints for table `MERGES`
--
ALTER TABLE `MERGES`
  ADD CONSTRAINT `MERGES_ibfk_1` FOREIGN KEY (`ID_SENSOR`) REFERENCES `SENSORS` (`ID_SENSOR`);

--
-- Constraints for table `MODULES`
--
ALTER TABLE `MODULES`
  ADD CONSTRAINT `MODULES_ibfk_1` FOREIGN KEY (`ID_TYPE`) REFERENCES `TYPES` (`ID_TYPE`),
  ADD CONSTRAINT `MODULES_ibfk_2` FOREIGN KEY (`ID_STATUS`) REFERENCES `STATUS` (`ID_STATUS`);

--
-- Constraints for table `SENSORS`
--
ALTER TABLE `SENSORS`
  ADD CONSTRAINT `SENSORS_ibfk_1` FOREIGN KEY (`ID_MODULE`) REFERENCES `MODULES` (`UNIQUE_ID`),
  ADD CONSTRAINT `SENSORS_ibfk_2` FOREIGN KEY (`ID_UNITS`) REFERENCES `UNITS` (`ID_UNIT`);

--
-- Constraints for table `USERS`
--
ALTER TABLE `USERS`
  ADD CONSTRAINT `USERS_ibfk_1` FOREIGN KEY (`ID_PRIV`) REFERENCES `PRIVILEDGES` (`ID_PRIV`);
