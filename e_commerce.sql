-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 17, 2021 at 06:04 PM
-- Server version: 10.4.14-MariaDB
-- PHP Version: 7.4.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `e_commerce`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `INFORMATION` ()  BEGIN
	DECLARE FIRST_NAME VARCHAR(10);
	DECLARE LAST_NAME VARCHAR(10);
	DECLARE TTL_AMT DECIMAL(11,2) ;
	DECLARE FINISHED INT(2);
    
	DECLARE INFOR CURSOR FOR SELECT U.FIRST_NAME,U.LAST_NAME,P.TTL_AMT
	FROM USER_INFO U, CUSTOMER C, ORDERS O, PAYMENT P
	WHERE U.USER_ID=C.USER_ID 
	AND C.CUST_ID=O.CUST_ID 
	AND P.ORD_ID=O.ORD_ID;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET FINISHED=1;
    
	OPEN INFOR;
    
	EXITS: LOOP
		FETCH INFOR INTO FIRST_NAME,LAST_NAME,TTL_AMT;
		IF FINISHED=1 THEN
			LEAVE EXITS;
		END IF;
		SELECT FIRST_NAME,LAST_NAME,TTL_AMT AS 'TOTAL_AMOUNT';
	END LOOP EXITS;
    
	CLOSE INFOR;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `NEW_USER_INFO` (IN `USER_ID` INT, IN `FIRST_NAME` VARCHAR(10), IN `LAST_NAME` VARCHAR(10), IN `EMAIL_ID` VARCHAR(30), IN `DOB` DATE, IN `PHN_NO1` DECIMAL(10), IN `PHN_NO2` DECIMAL(10), IN `ADDRESS` VARCHAR(100), IN `PINCODE` DECIMAL(6), IN `CITY` VARCHAR(30), IN `STATE` VARCHAR(30))  BEGIN 
	DECLARE ID INT;
	IF EMAIL_ID LIKE '%@gmail.com' THEN
		INSERT INTO USER_INFO VALUES (USER_ID, FIRST_NAME, LAST_NAME, EMAIL_ID, DOB, PHN_NO1,PHN_NO2,ADDRESS,PINCODE,CITY,STATE);
        SELECT MAX(CUST_ID) INTO ID FROM CUSTOMER;
        SET ID=ID+1;
        INSERT INTO CUSTOMER VALUES(ID,USER_ID);
        SELECT 'YOUR DATA IS INSERTED' AS MESSAGE;
    ELSE 
    	SELECT 'YOUR EMAIL ID IS NOT VALID' AS ERROR;
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `REMAINING` (`PROD_ID` INT) RETURNS INT(11) BEGIN
        DECLARE STOCK INT;
        DECLARE SELL INT;
        DECLARE REMAIN INT;
        SELECT P.QUANTITY INTO STOCK FROM PRODUCT P WHERE P.PROD_ID=PROD_ID;
        SELECT SUM(C.QTY) INTO SELL FROM CARTPRODUCT C WHERE C.PROD_ID=PROD_ID;
        SET REMAIN=STOCK-SELL;
        RETURN REMAIN;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `CART_ID` int(11) NOT NULL,
  `TTL_AMT` decimal(11,2) NOT NULL,
  `TTL_QTY` decimal(3,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`CART_ID`, `TTL_AMT`, `TTL_QTY`) VALUES
(1, '240998.00', '7'),
(2, '180000.00', '4'),
(3, '67000.00', '1'),
(4, '90000.00', '3'),
(5, '1699.00', '1');

-- --------------------------------------------------------

--
-- Table structure for table `cartproduct`
--

CREATE TABLE `cartproduct` (
  `CART_ID` int(11) NOT NULL,
  `PROD_ID` int(11) NOT NULL,
  `QTY` decimal(2,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `cartproduct`
--

INSERT INTO `cartproduct` (`CART_ID`, `PROD_ID`, `QTY`) VALUES
(1, 2, '1'),
(1, 9, '1'),
(1, 14, '1'),
(1, 15, '2'),
(1, 17, '2'),
(2, 5, '1'),
(2, 10, '2'),
(2, 22, '1'),
(3, 1, '1'),
(4, 9, '1'),
(4, 16, '2'),
(5, 26, '1');

--
-- Triggers `cartproduct`
--
DELIMITER $$
CREATE TRIGGER `INS_CP` AFTER INSERT ON `cartproduct` FOR EACH ROW BEGIN
		DECLARE SELL INT;

		SELECT QUANTITY INTO SELL FROM PRODUCT WHERE PROD_ID=NEW.PROD_ID;
    		SET SELL = SELL - NEW.QTY;

    		UPDATE PRODUCT SET QUANTITY = SELL WHERE PROD_ID=NEW.PROD_ID;

    		UPDATE CART SET TTL_AMT = TTL_AMT+(NEW.QTY*(SELECT PRICE FROM PRODUCT 
		WHERE PROD_ID=NEW.PROD_ID)) WHERE CART_ID=NEW.CART_ID;

    		UPDATE CART SET TTL_QTY=TTL_QTY+NEW.QTY WHERE CART_ID=NEW.CART_ID;
	END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `CAT_ID` int(11) NOT NULL,
  `CAT_NAME` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`CAT_ID`, `CAT_NAME`) VALUES
(1, 'Computer'),
(2, 'Earphone'),
(3, 'Mobile Phone'),
(4, 'Accessories');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `CUST_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`CUST_ID`, `USER_ID`) VALUES
(1, 6),
(2, 7),
(3, 8),
(4, 9),
(5, 10),
(6, 11),
(7, 12),
(8, 13),
(9, 14),
(10, 15),
(11, 15);

-- --------------------------------------------------------

--
-- Table structure for table `log`
--

CREATE TABLE `log` (
  `LOG_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `ACTION` varchar(10) NOT NULL,
  `CUR_DATE` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `log`
--

INSERT INTO `log` (`LOG_ID`, `USER_ID`, `ACTION`, `CUR_DATE`) VALUES
(1, 16, 'Inserted', '2020-10-31 12:09:29'),
(2, 16, 'Updated', '2020-10-31 12:11:42'),
(3, 16, 'Deleted', '2020-10-31 12:14:23'),
(5, 2, 'Updated', '2021-01-08 11:06:18'),
(6, 16, 'Inserted', '2021-01-08 11:08:54'),
(7, 2, 'Updated', '2021-01-08 11:09:57'),
(8, 2, 'Updated', '2021-01-08 11:10:18'),
(9, 16, 'Deleted', '2021-01-08 11:10:45');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `ORD_ID` int(11) NOT NULL,
  `CUST_ID` int(11) NOT NULL,
  `CART_ID` int(11) NOT NULL,
  `ORD_DATE` date NOT NULL,
  `DEL_DATE` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`ORD_ID`, `CUST_ID`, `CART_ID`, `ORD_DATE`, `DEL_DATE`) VALUES
(1, 2, 1, '2020-10-01', '2020-10-10'),
(2, 9, 2, '2020-10-04', '2020-10-13'),
(3, 5, 3, '2020-09-02', '2020-09-11'),
(4, 6, 4, '2020-10-06', '2020-10-15'),
(5, 3, 5, '2020-09-01', '2020-09-10');

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `PAY_ID` int(11) NOT NULL,
  `ORD_ID` int(11) NOT NULL,
  `PAY_TYPE` varchar(15) NOT NULL,
  `TTL_AMT` decimal(11,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`PAY_ID`, `ORD_ID`, `PAY_TYPE`, `TTL_AMT`) VALUES
(1, 1, 'UPI', '193000.00'),
(2, 2, 'Net Banking', '180000.00'),
(3, 3, 'Credit Card', '67000.00'),
(4, 4, 'Debit Card', '90000.00'),
(5, 5, 'COD', '1699.00');

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `PROD_ID` int(11) NOT NULL,
  `SUP_ID` int(11) NOT NULL,
  `SCAT_ID` int(11) NOT NULL,
  `PROD_NAME` varchar(30) NOT NULL,
  `QUANTITY` decimal(6,0) NOT NULL,
  `PRICE` decimal(10,2) NOT NULL,
  `DISCOUNT` decimal(4,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`PROD_ID`, `SUP_ID`, `SCAT_ID`, `PROD_NAME`, `QUANTITY`, `PRICE`, `DISCOUNT`) VALUES
(1, 1, 1, 'Dell G3', '5', '67000.00', '0.00'),
(2, 1, 1, 'Dell G5', '3', '80000.00', '10.00'),
(3, 1, 1, 'Dell G7', '6', '111000.00', '12.00'),
(4, 4, 1, 'MacBook Air', '6', '60000.00', '0.00'),
(5, 4, 1, 'MacBook Pro', '9', '90000.00', '15.00'),
(6, 1, 1, 'HP Pavillion', '10', '62000.00', '0.00'),
(7, 1, 2, 'Acer Home', '4', '40000.00', '5.00'),
(8, 4, 2, 'Lenovo PC', '2', '45000.00', '0.00'),
(9, 4, 3, 'HP Mini', '3', '50000.00', '10.00'),
(10, 2, 4, 'Nirvana', '20', '1500.00', '10.00'),
(11, 3, 4, 'Nirvana', '30', '1499.00', '0.00'),
(12, 2, 5, 'Airbuds', '8', '2000.00', '10.00'),
(13, 2, 6, 'Basshead', '30', '2500.00', '10.00'),
(14, 3, 6, 'Earbuds', '10', '3000.00', '20.00'),
(15, 1, 7, 'Reno', '9', '30000.00', '5.00'),
(16, 4, 7, 'A23', '3', '20000.00', '0.00'),
(17, 2, 7, 'Narzo', '19', '23999.00', '20.00'),
(18, 2, 8, 'V5', '12', '19999.00', '0.00'),
(19, 2, 8, 'V9', '4', '26000.00', '25.00'),
(20, 4, 9, 'Note 9', '12', '60000.00', '12.00'),
(21, 1, 10, 'iphone XE', '2', '88200.00', '12.00'),
(22, 2, 10, 'iphone XR', '1', '87000.00', '5.00'),
(23, 1, 10, 'iphone XR', '5', '86500.00', '0.00'),
(24, 5, 11, 'Sandisk-64GB', '32', '649.00', '0.00'),
(25, 1, 11, 'Samsung 128GB', '12', '1130.00', '5.00'),
(26, 1, 12, 'MI 20000mah', '5', '1699.00', '10.00'),
(27, 5, 12, 'Syska 20000mah', '2', '1800.00', '5.00'),
(28, 5, 12, 'Ambrame 1000mah', '6', '799.00', '11.00');

-- --------------------------------------------------------

--
-- Table structure for table `review`
--

CREATE TABLE `review` (
  `PROD_ID` int(11) NOT NULL,
  `CUST_ID` int(11) NOT NULL,
  `REV_DESC` varchar(700) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `review`
--

INSERT INTO `review` (`PROD_ID`, `CUST_ID`, `REV_DESC`) VALUES
(2, 2, 'Good Laptop. Value for money.'),
(9, 2, 'Portable, good battery'),
(15, 2, 'Fabulous Phone'),
(9, 6, 'Worst Product'),
(5, 9, 'Great Speed'),
(10, 9, 'Loud Voice, extra basss'),
(20, 9, 'good battery, camera');

-- --------------------------------------------------------

--
-- Table structure for table `shipper`
--

CREATE TABLE `shipper` (
  `SHIP_ID` int(11) NOT NULL,
  `ORD_ID` int(11) NOT NULL,
  `PHN_NO` decimal(10,0) NOT NULL,
  `S_NAME` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `shipper`
--

INSERT INTO `shipper` (`SHIP_ID`, `ORD_ID`, `PHN_NO`, `S_NAME`) VALUES
(1, 1, '9876549876', 'Dixit Patel'),
(2, 2, '9873219873', 'Ajay Verma'),
(3, 3, '9877899878', 'Harsh Patel'),
(4, 4, '9876543210', 'Pritesh Vaja'),
(5, 5, '7894561230', 'Mitesh Parmar');

-- --------------------------------------------------------

--
-- Table structure for table `subcategory`
--

CREATE TABLE `subcategory` (
  `SCAT_ID` int(11) NOT NULL,
  `CAT_ID` int(11) NOT NULL,
  `SCAT_NAME` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `subcategory`
--

INSERT INTO `subcategory` (`SCAT_ID`, `CAT_ID`, `SCAT_NAME`) VALUES
(1, 1, 'Laptops'),
(2, 1, 'Desktop'),
(3, 1, 'Mini Laptop'),
(4, 2, 'Boat'),
(5, 2, 'JBL'),
(6, 2, 'Sony'),
(7, 3, 'Oppo'),
(8, 3, 'Vivo'),
(9, 3, 'Samsung'),
(10, 3, 'Apple'),
(11, 4, 'Memory Card'),
(12, 4, 'Power Bank');

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `SUP_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `COMP_NAME` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`SUP_ID`, `USER_ID`, `COMP_NAME`) VALUES
(1, 1, 'Mahadev Enterprise'),
(2, 2, 'Flowkem Pvt Ltd'),
(3, 3, 'Mihir & sons'),
(4, 4, 'Pragti Sales'),
(5, 5, 'DC Brothers');

-- --------------------------------------------------------

--
-- Table structure for table `user_info`
--

CREATE TABLE `user_info` (
  `USER_ID` int(11) NOT NULL,
  `FIRST_NAME` varchar(10) NOT NULL,
  `LAST_NAME` varchar(10) NOT NULL,
  `EMAIL_ID` varchar(30) NOT NULL,
  `DOB` date DEFAULT NULL,
  `PHN_NO1` decimal(10,0) NOT NULL,
  `PHN_NO2` decimal(10,0) DEFAULT NULL,
  `ADDRESS` varchar(100) NOT NULL,
  `PINCODE` decimal(6,0) NOT NULL,
  `CITY` varchar(30) NOT NULL,
  `STATE` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user_info`
--

INSERT INTO `user_info` (`USER_ID`, `FIRST_NAME`, `LAST_NAME`, `EMAIL_ID`, `DOB`, `PHN_NO1`, `PHN_NO2`, `ADDRESS`, `PINCODE`, `CITY`, `STATE`) VALUES
(1, 'Mahesh', 'Vegada', 'mahesh@gmail.com', '1999-10-15', '9638650152', '9638650153', 'S/1,Kailash society', '362265', 'Gir-Somnath', 'Gujarat'),
(2, 'Shyamm', 'Makwana', 'shyam@gmail.com', '2000-05-27', '9638300760', NULL, 'S/2,Amrut society', '320008', 'Ahmedabad', 'Gujarat'),
(3, 'Mihir', 'Gediya', 'mihir@gmail.com', NULL, '9998300760', '9998300761', 'H/9,Geeta nagar', '335009', 'Surat', 'Gujarat'),
(4, 'Pragti', 'Barad', 'pragti@gmail.com', '2000-10-30', '6598300760', '6598300761', 'H/16,M S marg', '300018', 'Baroda', 'Gujarat'),
(5, 'Dhruvil', 'Chodvadiya', 'dhruvil@gmail.com', '1999-01-07', '9756300760', NULL, 'S/4,M G road', '335009', 'Surat', 'Gujarat'),
(6, 'Pranay', 'Makwana', 'pranay@gmail.com', '1999-05-27', '9638312340', '9638312341', 'S/22,Blue Apartment', '320008', 'Ahmedabad', 'Gujarat'),
(7, 'Akash', 'Mistry', 'akash@gmail.com', NULL, '8228300760', '8228300761', 'A/1,Lal nagar', '335009', 'Surat', 'Gujarat'),
(8, 'Ronak', 'Agnani', 'ronak@gmail.com', '2000-01-21', '7383300760', '7383300761', 'B/12,Blue Apartment', '300018', 'Baroda', 'Gujarat'),
(9, 'Twinkle', 'Arora', 'twinkle@gmail.com', '1999-09-13', '6126300760', NULL, 'S/6,M G road', '335009', 'Surat', 'Gujarat'),
(10, 'Kavish', 'Khatri', 'khatri@gmail.com', '1998-05-29', '9878312340', '9878312341', 'S/1,S G Highway', '320008', 'Ahmedabad', 'Gujarat'),
(11, 'Dhruv', 'Kumar', 'dhruv@gmail.com', NULL, '9787300760', NULL, 'S/45,J G road', '335009', 'Surat', 'Gujarat'),
(12, 'Raj', 'Makwana', 'raj@gmail.com', '1999-05-27', '9638312340', NULL, 'A/2,A Apartment', '320008', 'Ahmedabad', 'Gujarat'),
(13, 'Ajay', 'Mistry', 'ajay@gmail.com', '2001-01-01', '6928300760', '6928300761', 'C/3,Navratna nagar', '335009', 'Surat', 'Gujarat'),
(14, 'Ronak', 'Patel', 'ronakp@gmail.com', '2000-11-30', '7383478760', '7383478761', 'H/12,Red Apartment', '300018', 'Baroda', 'Gujarat'),
(15, 'Jinal', 'Parmar', 'jinal@gmail.com', NULL, '9996300760', NULL, 'B/15,Dharmabhumi', '335009', 'Surat', 'Gujarat');

--
-- Triggers `user_info`
--
DELIMITER $$
CREATE TRIGGER `DEL_LOG` BEFORE DELETE ON `user_info` FOR EACH ROW BEGIN
	INSERT INTO LOG VALUES(NULL,OLD.USER_ID,'Deleted',NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `INS_LOG` AFTER INSERT ON `user_info` FOR EACH ROW BEGIN
	INSERT INTO LOG VALUES(NULL,NEW.USER_ID,'Inserted',NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `UPD_LOG` AFTER UPDATE ON `user_info` FOR EACH ROW BEGIN
	INSERT INTO LOG VALUES(NULL,NEW.USER_ID,'Updated',NOW());
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`CART_ID`);

--
-- Indexes for table `cartproduct`
--
ALTER TABLE `cartproduct`
  ADD PRIMARY KEY (`CART_ID`,`PROD_ID`),
  ADD KEY `PROD_ID` (`PROD_ID`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`CAT_ID`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`CUST_ID`),
  ADD KEY `USER_ID` (`USER_ID`);

--
-- Indexes for table `log`
--
ALTER TABLE `log`
  ADD PRIMARY KEY (`LOG_ID`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`ORD_ID`),
  ADD KEY `CUST_ID` (`CUST_ID`),
  ADD KEY `CART_ID` (`CART_ID`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`PAY_ID`,`ORD_ID`),
  ADD KEY `ORD_ID` (`ORD_ID`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`PROD_ID`),
  ADD KEY `SUP_ID` (`SUP_ID`),
  ADD KEY `SCAT_ID` (`SCAT_ID`);

--
-- Indexes for table `review`
--
ALTER TABLE `review`
  ADD PRIMARY KEY (`CUST_ID`,`PROD_ID`),
  ADD KEY `PROD_ID` (`PROD_ID`);

--
-- Indexes for table `shipper`
--
ALTER TABLE `shipper`
  ADD PRIMARY KEY (`SHIP_ID`,`ORD_ID`),
  ADD KEY `ORD_ID` (`ORD_ID`);

--
-- Indexes for table `subcategory`
--
ALTER TABLE `subcategory`
  ADD PRIMARY KEY (`SCAT_ID`),
  ADD KEY `CAT_ID` (`CAT_ID`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`SUP_ID`),
  ADD KEY `USER_ID` (`USER_ID`);

--
-- Indexes for table `user_info`
--
ALTER TABLE `user_info`
  ADD PRIMARY KEY (`USER_ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `CART_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `CAT_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `CUST_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `log`
--
ALTER TABLE `log`
  MODIFY `LOG_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `ORD_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `PAY_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `PROD_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `shipper`
--
ALTER TABLE `shipper`
  MODIFY `SHIP_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `subcategory`
--
ALTER TABLE `subcategory`
  MODIFY `SCAT_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `SUP_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_info`
--
ALTER TABLE `user_info`
  MODIFY `USER_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cartproduct`
--
ALTER TABLE `cartproduct`
  ADD CONSTRAINT `cartproduct_ibfk_1` FOREIGN KEY (`CART_ID`) REFERENCES `cart` (`CART_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `cartproduct_ibfk_2` FOREIGN KEY (`PROD_ID`) REFERENCES `product` (`PROD_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`USER_ID`) REFERENCES `user_info` (`USER_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CUST_ID`) REFERENCES `customer` (`CUST_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`CART_ID`) REFERENCES `cart` (`CART_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`ORD_ID`) REFERENCES `orders` (`ORD_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`SUP_ID`) REFERENCES `supplier` (`SUP_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `product_ibfk_2` FOREIGN KEY (`SCAT_ID`) REFERENCES `subcategory` (`SCAT_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `review`
--
ALTER TABLE `review`
  ADD CONSTRAINT `review_ibfk_1` FOREIGN KEY (`CUST_ID`) REFERENCES `customer` (`CUST_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `review_ibfk_2` FOREIGN KEY (`PROD_ID`) REFERENCES `product` (`PROD_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `shipper`
--
ALTER TABLE `shipper`
  ADD CONSTRAINT `shipper_ibfk_1` FOREIGN KEY (`ORD_ID`) REFERENCES `orders` (`ORD_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `subcategory`
--
ALTER TABLE `subcategory`
  ADD CONSTRAINT `subcategory_ibfk_1` FOREIGN KEY (`CAT_ID`) REFERENCES `category` (`CAT_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `supplier`
--
ALTER TABLE `supplier`
  ADD CONSTRAINT `supplier_ibfk_1` FOREIGN KEY (`USER_ID`) REFERENCES `user_info` (`USER_ID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
