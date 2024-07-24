-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 24, 2024 at 08:20 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `toko_komputer`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllSuppliers` ()   BEGIN
    DECLARE total_suppliers INT;

    -- Menghitung jumlah total supplier
    SELECT COUNT(*) INTO total_suppliers FROM supplier;

    -- Control flow menggunakan IF statement
    IF total_suppliers > 0 THEN
        -- Menampilkan semua supplier jika ada supplier yang tersedia
        SELECT * FROM supplier;
    ELSE
        -- Menampilkan pesan jika tidak ada supplier yang tersedia
        SELECT 'Tidak ada supplier yang tersedia' AS message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateProductPrice` (`product_id` INT, `new_price` DECIMAL(10,2))   BEGIN
    IF EXISTS (SELECT * FROM produk WHERE id_produk = product_id) THEN
        UPDATE Produk SET harga = new_price WHERE id_produk = product_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produk tidak ditemukan';
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `GetProductPrice` (`product_id` INT, `qty` INT) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total_price DECIMAL(10,2);
    SELECT harga * qty INTO total_price FROM produk WHERE id_produk = product_id;
    RETURN total_price;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetTotalProducts` () RETURNS INT(11)  BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM Produk;
    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `detailproduk`
--

CREATE TABLE `detailproduk` (
  `id_produk` int(11) NOT NULL,
  `deskripsi_produk` varchar(255) DEFAULT NULL,
  `asal_produk` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detailproduk`
--

INSERT INTO `detailproduk` (`id_produk`, `deskripsi_produk`, `asal_produk`) VALUES
(1, 'Laptop mahal', 'Taiwan'),
(2, 'Laptop kantor', 'Cina'),
(3, 'Laptop gaming', 'Taiwan'),
(4, 'Laptop kantor', 'Amerika'),
(5, 'Laptop gaming', 'Amerika');

-- --------------------------------------------------------

--
-- Table structure for table `detail_transaksi`
--

CREATE TABLE `detail_transaksi` (
  `id_transaksi` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `jumlah` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_transaksi`
--

INSERT INTO `detail_transaksi` (`id_transaksi`, `id_produk`, `jumlah`) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 1),
(4, 4, 2),
(5, 5, 3);

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `id_pelanggan` int(11) NOT NULL,
  `nama_pelanggan` varchar(50) DEFAULT NULL,
  `email_pelanggan` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`id_pelanggan`, `nama_pelanggan`, `email_pelanggan`) VALUES
(1, 'Asep', 'Asep@mail.com'),
(2, 'Budi santoso', 'Budi@mail.com'),
(3, 'Cristiano ronaldo', 'Ronaldo@mail.com'),
(4, 'Dewi', 'Dewi@mail.com'),
(5, 'Eka faturrahman', 'Eka@mail.com');

-- --------------------------------------------------------

--
-- Table structure for table `produk`
--

CREATE TABLE `produk` (
  `id_produk` int(11) NOT NULL,
  `nama_produk` varchar(50) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `produk`
--

INSERT INTO `produk` (`id_produk`, `nama_produk`, `harga`) VALUES
(1, 'ASUS ROG', 12000.00),
(2, 'LENOVO YOGA', 15000.00),
(3, 'ACER NITRO', 20000.00),
(4, 'DELL LATITUDE', 25000.00),
(5, 'HP PAVILION', 30000.00);

--
-- Triggers `produk`
--
DELIMITER $$
CREATE TRIGGER `after_delete_product` AFTER DELETE ON `produk` FOR EACH ROW BEGIN
    INSERT INTO system_log (log_action, table_name, record_id, log_message)
    VALUES ('DELETE', 'Produk', OLD.id_produk, CONCAT('Produk ', OLD.nama_produk, ' telah dihapus.'));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_product` AFTER INSERT ON `produk` FOR EACH ROW BEGIN
    INSERT INTO system_log (log_action, table_name, record_id, log_message)
    VALUES (
        'INSERT', 
        'produk', 
        NEW.id_produk, 
        CONCAT('Produk baru ditambahkan: id_produk=', NEW.id_produk, ', nama_produk=', NEW.nama_produk, ', harga=', NEW.harga)
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_product` AFTER UPDATE ON `produk` FOR EACH ROW BEGIN
    INSERT INTO system_log (log_action, table_name, record_id, log_message)
    VALUES ('UPDATE', 'produk', OLD.id_produk, CONCAT('Data harga produk \r\ndiupdate: dari=', OLD.harga, ', menjadi=', NEW.harga));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_produk` BEFORE DELETE ON `produk` FOR EACH ROW BEGIN
    DECLARE count_details INT;
    SELECT COUNT(*) INTO count_details FROM DetailProduk WHERE id_produk = OLD.id_produk;
    IF count_details > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produk tidak dapat dihapus karena masih memiliki detail produk terkait.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_product` BEFORE INSERT ON `produk` FOR EACH ROW BEGIN
     IF NEW.harga < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Harga tidak boleh kurang dari 0';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_product_price` BEFORE UPDATE ON `produk` FOR EACH ROW BEGIN
    IF NEW.harga < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Harga tidak boleh kurang dari 0';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `produkindex`
--

CREATE TABLE `produkindex` (
  `id_produk` int(11) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stok`
--

CREATE TABLE `stok` (
  `id_produk` int(11) NOT NULL,
  `id_supplier` int(11) NOT NULL,
  `jumlah` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stok`
--

INSERT INTO `stok` (`id_produk`, `id_supplier`, `jumlah`) VALUES
(1, 1, 12),
(2, 2, 20),
(3, 3, 15),
(4, 4, 12),
(5, 5, 13);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `id_supplier` int(11) NOT NULL,
  `nama_supplier` varchar(50) DEFAULT NULL,
  `kontak_supplier` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`id_supplier`, `nama_supplier`, `kontak_supplier`) VALUES
(3, 'Supplier Acer', '083456789012'),
(1, 'Supplier Asus', '081234567890'),
(4, 'Supplier Dell', '084567890123'),
(5, 'Supplier HP', '085678901234'),
(2, 'Supplier Lenovo', '082345678901');

-- --------------------------------------------------------

--
-- Table structure for table `system_log`
--

CREATE TABLE `system_log` (
  `id_log` int(11) NOT NULL,
  `log_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `log_action` varchar(50) DEFAULT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `log_message` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `system_log`
--

INSERT INTO `system_log` (`id_log`, `log_timestamp`, `log_action`, `table_name`, `record_id`, `log_message`) VALUES
(4, '2024-07-24 13:51:57', 'INSERT', 'produk', 6, 'Produk baru ditambahkan: id_produk=6, nama_produk=Xinmeng, harga=20000.00'),
(5, '2024-07-24 13:56:40', 'UPDATE', 'produk', 6, 'Data harga produk \r\ndiupdate: dari=20000.00, menjadi=15000.00'),
(6, '2024-07-24 13:59:21', 'DELETE', 'Produk', 6, 'Produk Xinmeng telah dihapus.');

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `id_transaksi` int(11) NOT NULL,
  `id_pelanggan` int(11) DEFAULT NULL,
  `tanggal_transaksi` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`id_transaksi`, `id_pelanggan`, `tanggal_transaksi`) VALUES
(1, 1, '2023-07-01'),
(2, 2, '2023-07-02'),
(3, 3, '2023-07-03'),
(4, 4, '2023-07-04'),
(5, 5, '2023-07-05');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_horizontal`
-- (See below for the actual view)
--
CREATE TABLE `view_horizontal` (
`id_produk` int(11)
,`nama_produk` varchar(50)
,`harga` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_inside`
-- (See below for the actual view)
--
CREATE TABLE `view_inside` (
`id_produk` int(11)
,`nama_produk` varchar(50)
,`harga` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_vertical`
-- (See below for the actual view)
--
CREATE TABLE `view_vertical` (
`id_produk` int(11)
,`nama_produk` varchar(50)
);

-- --------------------------------------------------------

--
-- Structure for view `view_horizontal`
--
DROP TABLE IF EXISTS `view_horizontal`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_horizontal`  AS SELECT `produk`.`id_produk` AS `id_produk`, `produk`.`nama_produk` AS `nama_produk`, `produk`.`harga` AS `harga` FROM `produk` ;

-- --------------------------------------------------------

--
-- Structure for view `view_inside`
--
DROP TABLE IF EXISTS `view_inside`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_inside`  AS SELECT `view_horizontal`.`id_produk` AS `id_produk`, `view_horizontal`.`nama_produk` AS `nama_produk`, `view_horizontal`.`harga` AS `harga` FROM `view_horizontal`WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `view_vertical`
--
DROP TABLE IF EXISTS `view_vertical`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_vertical`  AS SELECT `produk`.`id_produk` AS `id_produk`, `produk`.`nama_produk` AS `nama_produk` FROM `produk` WHERE `produk`.`harga` > 20000.00 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `detailproduk`
--
ALTER TABLE `detailproduk`
  ADD PRIMARY KEY (`id_produk`);

--
-- Indexes for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD PRIMARY KEY (`id_transaksi`,`id_produk`),
  ADD KEY `id_produk` (`id_produk`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`),
  ADD KEY `idx_pelanggan_email` (`nama_pelanggan`,`email_pelanggan`);

--
-- Indexes for table `produk`
--
ALTER TABLE `produk`
  ADD PRIMARY KEY (`id_produk`);

--
-- Indexes for table `produkindex`
--
ALTER TABLE `produkindex`
  ADD KEY `id_produk` (`id_produk`,`harga`);

--
-- Indexes for table `stok`
--
ALTER TABLE `stok`
  ADD PRIMARY KEY (`id_produk`,`id_supplier`),
  ADD KEY `id_supplier` (`id_supplier`),
  ADD KEY `idx_stok_produk_supplier` (`id_produk`,`id_supplier`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`id_supplier`),
  ADD KEY `idx_supplier_kontak` (`nama_supplier`,`kontak_supplier`);

--
-- Indexes for table `system_log`
--
ALTER TABLE `system_log`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD KEY `id_pelanggan` (`id_pelanggan`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `produk`
--
ALTER TABLE `produk`
  MODIFY `id_produk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `system_log`
--
ALTER TABLE `system_log`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `detailproduk`
--
ALTER TABLE `detailproduk`
  ADD CONSTRAINT `detailproduk_ibfk_1` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`);

--
-- Constraints for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD CONSTRAINT `detail_transaksi_ibfk_1` FOREIGN KEY (`id_transaksi`) REFERENCES `transaksi` (`id_transaksi`),
  ADD CONSTRAINT `detail_transaksi_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`);

--
-- Constraints for table `stok`
--
ALTER TABLE `stok`
  ADD CONSTRAINT `stok_ibfk_1` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`),
  ADD CONSTRAINT `stok_ibfk_2` FOREIGN KEY (`id_supplier`) REFERENCES `supplier` (`id_supplier`);

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
