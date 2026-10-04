-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 04 Okt 2026 pada 18.30
-- Versi server: 10.4.22-MariaDB
-- Versi PHP: 7.4.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `presensi`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_status` (IN `PEGAWAI` INT, IN `TIPE` INT, IN `WAKTU` TIMESTAMP)  BEGIN
	UPDATE presensi 
	SET presensi.`STATUS` = cek_status_keterlambatan(TIPE, WAKTU) 
	WHERE presensi.PEGAWAI = PEGAWAI;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `cek_status_keterlambatan` (`TIPE_PRESENSI` INT, `WAKTU` TIMESTAMP) RETURNS INT(11) BEGIN
	DECLARE B_AWAL TIMESTAMP;
	DECLARE B_AKHIR TIMESTAMP;
	DECLARE sts INT DEFAULT 0;
	
	SELECT 
		BATAS_AWAL,
		BATAS_AKHIR INTO B_AWAL, B_AKHIR
	FROM tipe_presensi 
	WHERE tipe_presensi.ID = TIPE_PRESENSI 
	LIMIT 1;
	
	IF(WAKTU >= B_AWAL && WAKTU < B_AKHIR) THEN 
		SET sts = 2;
	ELSEIF (WAKTU <= B_AWAL) THEN
		SET sts = 1;
	ELSE 
		SET sts = 3;
	END IF;
	
	RETURN sts;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pegawai`
--

CREATE TABLE `pegawai` (
  `ID` int(11) NOT NULL,
  `NIP` char(100) NOT NULL DEFAULT '',
  `NAMA` varchar(50) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL,
  `NOTELP` varchar(50) DEFAULT NULL,
  `PASSWORD` varchar(200) DEFAULT NULL,
  `TGL_BUAT` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `STATUS` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `pegawai`
--

INSERT INTO `pegawai` (`ID`, `NIP`, `NAMA`, `EMAIL`, `NOTELP`, `PASSWORD`, `TGL_BUAT`, `STATUS`) VALUES
(1, '2002121220270101001', 'RIDHO ARIF WICAKSONO', 'ridhoarif40@gmail.com', '083192962102', '202cb962ac59075b964b07152d234b70', '2026-10-04 14:45:10', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `presensi`
--

CREATE TABLE `presensi` (
  `ID` int(11) NOT NULL,
  `PEGAWAI` int(11) DEFAULT NULL,
  `TIPE` int(11) DEFAULT NULL,
  `WAKTU` timestamp NULL DEFAULT curtime(1),
  `STATUS` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `presensi`
--

INSERT INTO `presensi` (`ID`, `PEGAWAI`, `TIPE`, `WAKTU`, `STATUS`) VALUES
(7, 1, 1, '2026-10-04 00:00:00', 3),
(8, 1, 1, '2026-10-04 00:30:00', 3),
(9, 1, 1, '2026-10-04 00:00:00', 2),
(10, 1, 3, '2026-10-04 13:00:00', 2);

--
-- Trigger `presensi`
--
DELIMITER $$
CREATE TRIGGER `presensi_before_insert` BEFORE INSERT ON `presensi` FOR EACH ROW BEGIN
	/*UPDATE presensi 
	SET tipe_presensi = cek_status_keterlambatan(NEW.TIPE, NEW.WAKTU) 
	WHERE ID = NEW.ID;*/
	SET NEW.`STATUS` = cek_status_keterlambatan(NEW.TIPE, NEW.WAKTU);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `presensi_before_update` BEFORE UPDATE ON `presensi` FOR EACH ROW BEGIN
	/*IF OLD.WAKTU != NEW.WAKTU THEN 
		SET NEW.`STATUS` = cek_status_keterlambatan(NEW.TIPE, NEW.WAKTU);
	ELSE 
		SET NEW.`STATUS` = cek_status_keterlambatan(NEW.TIPE, NEW.WAKTU);
	END IF;*/
	SET NEW.`STATUS` = cek_status_keterlambatan(NEW.TIPE, NEW.WAKTU);
	-- CALL set_status(NEW.PEGAWAI, NEW.TIPE, NEW.WAKTU);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tipe_presensi`
--

CREATE TABLE `tipe_presensi` (
  `ID` int(11) NOT NULL,
  `TIPE_PRESENSI` varchar(50) NOT NULL DEFAULT '0',
  `BATAS_AWAL` datetime NOT NULL,
  `BATAS_AKHIR` datetime NOT NULL,
  `STATUS` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `tipe_presensi`
--

INSERT INTO `tipe_presensi` (`ID`, `TIPE_PRESENSI`, `BATAS_AWAL`, `BATAS_AKHIR`, `STATUS`) VALUES
(1, 'PRESENSI DATANG', '2026-10-04 06:00:00', '2026-10-04 08:00:00', 1),
(3, 'PRESENSI PULANG', '2026-10-04 16:00:00', '2026-10-04 21:00:00', 1);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `pegawai`
--
ALTER TABLE `pegawai`
  ADD PRIMARY KEY (`ID`);

--
-- Indeks untuk tabel `presensi`
--
ALTER TABLE `presensi`
  ADD PRIMARY KEY (`ID`);

--
-- Indeks untuk tabel `tipe_presensi`
--
ALTER TABLE `tipe_presensi`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `pegawai`
--
ALTER TABLE `pegawai`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `presensi`
--
ALTER TABLE `presensi`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `tipe_presensi`
--
ALTER TABLE `tipe_presensi`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
