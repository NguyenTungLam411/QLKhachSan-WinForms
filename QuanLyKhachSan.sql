



CREATE DATABASE QLKhachSan
GO
USE QLKhachSan
GO

CREATE TABLE tblKhach (
    CMND VARCHAR(15) PRIMARY KEY,
    HoTen NVARCHAR(100),
    NgaySinh DATE,
    DienThoai VARCHAR(15),
    DiaChi NVARCHAR(200)
);

CREATE TABLE tblNhanvien (
    MaNV VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100)
);

CREATE TABLE tblPhong (
    SoPhong VARCHAR(10) PRIMARY KEY,
    SucChua INT,
    DonGia DECIMAL(18,2),
    TinhTrang NVARCHAR(20)
);

CREATE TABLE tblDangky (
    MaDK INT IDENTITY PRIMARY KEY,
    CMND VARCHAR(15),
    MaNV VARCHAR(10),
    SoPhong VARCHAR(10),
    NgayDK DATE,
    NgayNhan DATE,
    NgayTra DATE,
    TrangThai NVARCHAR(20),

    FOREIGN KEY (CMND) REFERENCES tblKhach(CMND),
    FOREIGN KEY (MaNV) REFERENCES tblNhanvien(MaNV),
    FOREIGN KEY (SoPhong) REFERENCES tblPhong(SoPhong)
);

CREATE TABLE tblDichvu (
    MaDV VARCHAR(10) PRIMARY KEY,
    TenDV NVARCHAR(100),
    Gia DECIMAL(18,2)
);

CREATE TABLE tblCTDichvu (
    MaCT INT IDENTITY PRIMARY KEY,
    MaDK INT,
    MaDV VARCHAR(10),
    NgaySuDung DATE,
    SoLuong INT,

    FOREIGN KEY (MaDK) REFERENCES tblDangky(MaDK),
    FOREIGN KEY (MaDV) REFERENCES tblDichvu(MaDV)
);



-- 2. STORED PROCEDURES (BẮT BUỘC)
-- Thêm khách
CREATE PROC sp_ThemKhach
@CMND VARCHAR(15), @HoTen NVARCHAR(100), @NgaySinh DATE, @DT VARCHAR(15), @DC NVARCHAR(200)
AS
INSERT INTO tblKhach VALUES(@CMND,@HoTen,@NgaySinh,@DT,@DC)

-- Đặt phòng
CREATE PROC sp_DatPhong
@CMND VARCHAR(15), @MaNV VARCHAR(10), @SoPhong VARCHAR(10),
@NgayDK DATE, @NgayNhan DATE, @NgayTra DATE
AS
BEGIN
    INSERT INTO tblDangky VALUES
    (@CMND,@MaNV,@SoPhong,@NgayDK,@NgayNhan,@NgayTra,N'Đang thuê')

    UPDATE tblPhong SET TinhTrang=N'Đã thuê'
    WHERE SoPhong=@SoPhong
END

--Xóa đăng ký
CREATE PROC sp_XoaDK
@MaDK INT
AS
DELETE FROM tblDangky WHERE MaDK=@MaDK

--Thêm dịch vụ
CREATE PROC sp_ThemDV
@MaDK INT, @MaDV VARCHAR(10), @Ngay DATE, @SL INT
AS
INSERT INTO tblCTDichvu VALUES(@MaDK,@MaDV,@Ngay,@SL)


-- Store this in your SQL database

CREATE PROC sp_GenerateInvoiceReport
    @MaDK INT
AS
BEGIN
    -- First Result Set: Invoice Header/Summary
    SELECT
        k.HoTen AS TenKhachHang,
        k.CMND,
        k.DienThoai AS SoDienThoaiKhach,
        k.DiaChi AS DiaChiKhach,
        dk.MaDK,
        dk.NgayDK,
        dk.NgayNhan,
        dk.NgayTra,
        p.SoPhong,
        p.SucChua,
        p.DonGia AS DonGiaPhong,
        DATEDIFF(DAY, dk.NgayNhan, dk.NgayTra) AS SoNgayThue,
        (p.DonGia * DATEDIFF(DAY, dk.NgayNhan, dk.NgayTra)) AS TongTienPhong,
        ISNULL(SUM(ct.SoLuong * dv.Gia), 0) AS TongTienDichVu,
        (p.DonGia * DATEDIFF(DAY, dk.NgayNhan, dk.NgayTra)) + ISNULL(SUM(ct.SoLuong * dv.Gia), 0) AS TongThanhToan
    FROM tblDangky dk
    JOIN tblKhach k ON dk.CMND = k.CMND
    JOIN tblPhong p ON dk.SoPhong = p.SoPhong
    LEFT JOIN tblCTDichvu ct ON dk.MaDK = ct.MaDK
    LEFT JOIN tblDichvu dv ON ct.MaDV = dv.MaDV
    WHERE dk.MaDK = @MaDK
    GROUP BY
        k.HoTen, k.CMND, k.DienThoai, k.DiaChi,
        dk.MaDK, dk.NgayDK, dk.NgayNhan, dk.NgayTra,
        p.SoPhong, p.SucChua, p.DonGia;

    -- Second Result Set: Service Line Items
    SELECT
        dv.TenDV,
        ct.SoLuong,
        dv.Gia AS DonGiaDichVu,
        (ct.SoLuong * dv.Gia) AS ThanhTienDichVu,
        ct.NgaySuDung
    FROM tblCTDichvu ct
    JOIN tblDichvu dv ON ct.MaDV = dv.MaDV
    WHERE ct.MaDK = @MaDK;
END;

