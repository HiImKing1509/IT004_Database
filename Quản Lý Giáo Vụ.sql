----------------------------------------------------------------------------------------------
---------------------------- CƠ SỞ DỮ LIỆU: QUẢN LÝ GIÁO VỤ ----------------------------------
----------------------------------------------------------------------------------------------
create database QuanLyGiaoVu
go
--
use QuanLyGiaoVu
go

----------------------------------------------------------------------------------------------
----------------- Ngôn ngữ định nghĩa dữ liệu (Data Definition Language) ---------------------
----------------------------------------------------------------------------------------------

-- Câu 1: Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại

-- Quan hệ: KHOA
create table KHOA
(
	MAKHOA varchar(4),
	TENKHOA varchar(40),
	NGTLAP smalldatetime,
	TRGKHOA char(4) -- Ma giao vien
	constraint PK_KHOA primary key (MAKHOA)
)
go

-- Quan hệ: MONHOC
create table MONHOC
(
	MAMH varchar(10),
	TENMH varchar(40),
	TCLT tinyint,
	TCTH tinyint,
	MAKHOA varchar(4)
	constraint PK_MONHOC primary key (MAMH)
)
go

-- Quan hệ: DIEUKIEN
create table DIEUKIEN
(
	MAMH varchar(10), -- Thuoc tinh khoa
	MAMH_TRUOC varchar(10) -- Thuoc tinh khoa
	constraint PK_DIEUKIEN primary key (MAMH, MAMH_TRUOC)
)
go

-- Quan hệ: GIAOVIEN
create table GIAOVIEN
(
	MAGV char(4),
	HOTEN varchar(40),
	HOCVI varchar(10),
	HOCHAM varchar(10),
	GIOITINH varchar(3),
	NGSINH smalldatetime,
	NGVL smalldatetime,
	HESO numeric(4,2),
	MUCLUonG money,
	MAKHOA varchar(4)
	constraint PK_GIAOVIEN primary key (MAGV)
)
go

-- Quan hệ: LOP
create table LOP
(
	MALOP char(3),
	TENLOP varchar(40),
	TRGLOP char(5), -- Ma hoc vien
	SISO tinyint,
	MAGVCN char(4) -- Ma giao vien
	constraint PK_LOP primary key (MALOP)
)
go

-- Quan hệ: HOCVIEN
create table HOCVIEN
(
	MAHV char(5),
	HO varchar(40),
	TEN varchar(10),
	NGSINH smalldatetime,
	GIOITINH varchar(3),
	NOISINH varchar(40),
	MALOP char(3)
	constraint PK_HOCVIEN primary key (MAHV)
)
go

-- Quan hệ: GIANGDAY
create table GIANGDAY
(
	MALOP char(3), -- Thuoc tinh khoa
	MAMH varchar(10), -- Thuoc tinh khoa
	MAGV char(4),
	HOCKY tinyint,
	NAM smallint,
	TUNGAY smalldatetime,
	DENNGAY smalldatetime
	constraint PK_GIANGDAY primary key (MALOP, MAMH)
)
go

-- Quan hệ: KETQUATHI
create table KETQUATHI
(
	MAHV char(5), -- Thuoc tinh khoa
	MAMH varchar(10), -- Thuoc tinh khoa
	LANTHI tinyint, -- Thuoc tinh khoa
	NGTHI smalldatetime,
	DIEM numeric(4,2),
	KQUA varchar(10)
	constraint PK_KETQUATHI primary key (MAHV, MAMH, LANTHI)
)
go

-- Khóa ngoại
alter table LOP add constraint FK_TRGLOP foreign key (TRGLOP) references HOCVIEN(MAHV)
alter table LOP add constraint FK_MAGVCN foreign key (MAGVCN) references GIAOVIEN(MAGV)
alter table HOCVIEN add constraint FK_MALOP foreign key (MALOP) references LOP(MALOP)
alter table GIAOVIEN add constraint FK_MAKHOA foreign key (MAKHOA) references KHOA(MAKHOA)
alter table GIANGDAY add constraint FK_MAMH foreign key (MAMH) references MONHOC(MAMH)
alter table MONHOC add constraint FK_MAKHOA2 foreign key (MAKHOA) references KHOA(MAKHOA)
alter table KHOA add constraint FK_TRGKHOA foreign key (TRGKHOA) references GIAOVIEN(MAGV)
alter table DIEUKIEN add constraint FK_MAMH2 foreign key (MAMH) references MONHOC(MAMH)
alter table DIEUKIEN add constraint FK_MAMH_TRUOC foreign key (MAMH_TRUOC) references MONHOC(MAMH)
alter table KETQUATHI add constraint FK_MAHV foreign key (MAHV) references HOCVIEN(MAHV)
go

-- Thêm vào 3 thuộc tính GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN
alter table HOCVIEN add GHICHU varchar(100), DIEMTB numeric(4,2), XEPLOAI varchar(10)
go

-- Câu 2: Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp
alter table HOCVIEN add constraint CK_MAHV check (len(MAHV) = 5 and left(MAHV, 3) = MALOP and isnumeric(right(MAHV,2)) = 1)
go

-- Câu 3:Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”
alter table HOCVIEN add constraint CK_GIOITINHHV check (GIOITINH in ('Nam', 'Nu'))
alter table GIAOVIEN add constraint CK_GIOITINHGV check (GIOITINH in ('Nam', 'Nu'))
go

-- Câu 4: Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẻ (VD: 6.22)
alter table KETQUATHI add constraint CK_DIEM check 
(
	DIEM between 0 and 10
	and right (cast(DIEM as varchar), 3) like '.__' -- Tham khao tren mang
)
go

-- Câu 5: Kết quả thi là “Dat” nếu điểm từ 5 đến 10 và “Khong dat” nếu điểm nhỏ hơn 5
alter table KETQUATHI add constraint CK_KETQUA check
(
	(DIEM < 5 and KQUA = 'Khong dat') or (DIEM between 5 and 10 and KQUA = 'Dat')
)
go

-- Câu 6: Học viên thi một môn tối đa 3 lần
alter table KETQUATHI add constraint CK_LANTHI check (LANTHI <= 3) 
go

-- Câu 7: Học kỳ chỉ có giá trị từ 1 đến 3
alter table GIANGDAY add constraint CK_HOCKY check (HOCKY in ('1', '2', '3'))
go

-- Câu 8: Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”
alter table GIAOVIEN add constraint CK_HOCVI check (HOCVI in ('CN', 'KS', 'Ths', 'TS', 'PTS'))
go

-- Câu 9: Lớp trưởng của một lớp phải là học viên của lớp đó. 
create trigger TRGLOP_1 on LOP for insert, update
as
begin
	if (select count(*) from inserted, HOCVIEN
		where inserted.TRGLOP = HOCVIEN.MAHV and HOCVIEN.MALOP != inserted.MALOP) > 0
	begin
		rollback tran
		print 'Lớp trưởng của một lớp phải là học viên của lớp đó'
	end
	else
		print 'Cập nhật thành công'
end
go

create trigger TRGHOCVIEN_1 on HOCVIEN for update
as
begin
	if (select count(*) from inserted, LOP
		where inserted.MAHV = LOP.TRGLOP and inserted.MALOP != LOP.MALOP) > 0
	begin
		rollback tran
		print 'Lớp trưởng của một lớp phải là học viên của lớp đó'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 10: Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”
create trigger TRGKHOA_1 on KHOA for update
as
begin
	if (select count(*) from inserted, GIAOVIEN
		where inserted.TRGKHOA = GIAOVIEN.MAGV and (GIAOVIEN.HOCVI not in ('TS', 'PTS')
			or GIAOVIEN.MAKHOA != inserted.MAKHOA)) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

create trigger TRGGIAOVIEN_1 on GIAOVIEN for update
as
begin
	if (select count(*) from inserted, KHOA
		where inserted.MAGV = KHOA.TRGKHOA and (inserted.HOCVI not in ('TS', 'PTS')
			or inserted.MAKHOA != KHOA.MAKHOA)) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 11: Học viên ít nhất là 18 tuổi
alter table HOCVIEN add constraint CK_TUOI check (year(getdate()) - year(NGSINH) >= 18)
go 

-- Câu 12: Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY)
alter table GIANGDAY add constraint CK_GIANGDAY check (TUNGAY < DENNGAY)
go

-- Câu 13: Giáo viên khi vào làm ít nhất là 22 tuổi
alter table GIAOVIEN add constraint CK_NGVL check (year(NGVL) - year(NGSINH) >= 22)
go

-- Câu 14: Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3
alter table MONHOC add constraint CK_TINCHI check (abs(TCLT - TCTH) <= 3)
go

-- Câu 15: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này 
create trigger TRGHOCVIEN_2 on HOCVIEN for insert, update
as
begin
	if (select count(*) from inserted, KETQUATHI, GIANGDAY GD1
		where inserted.MAHV = KETQUATHI.MAHV
			and (KETQUATHI.MAMH not in (
		select MAMH from GIANGDAY GD2
		where inserted.MALOP = GD2.MALOP)
			or (inserted.MALOP = GD1.MALOP and KETQUATHI.MAMH = GD1.MAMH and KETQUATHI.NGTHI > GD1.DENNGAY))
		) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 16: Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn
create trigger TRGGIANGDAY_1 on GIANGDAY for insert, update
as
begin
	if (select top 1 count(MAMH)
		from GIANGDAY
		group by HOCKY, NAM, MALOP) > 3
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 17: Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó
create trigger TRGHOCVIEN_3 on HOCVIEN for insert, update, delete
as
begin
	update LOP set SISO = (
						select count(*) from HOCVIEN
						where HOCVIEN.MALOP = LOP.MALOP)
end
go

-- Câu 18: Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”)
create trigger TRGDIEUKIEN_1 on DIEUKIEN for insert, update
as
begin
	if (select count(*) from DIEUKIEN DK1, DIEUKIEN DK2
		where DK1.MAMH = DK1.MAMH_TRUOC
			or (DK1.MAMH = DK2.MAMH_TRUOC and DK1.MAMH_TRUOC = DK2.MAMH)) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 19: Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau
create trigger TRGGIAOVIEN_3 on GIAOVIEN for insert, update
as
begin
	if (select count(*) from GIAOVIEN GV1, GIAOVIEN GV2
		where GV1.HOCVI = GV2.HOCVI
			and GV1.HOCHAM = GV2.HOCHAM
			and GV1.HESO = GV2.HESO
			and GV1.MUCLUONG != GV2.MUCLUONG) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 20: Học viên chỉ được thi lại (lần thi > 1) khi điểm của lần thi trước đó dưới 5
create trigger TRGKETQUATHI_1 on KETQUATHI for insert, update
as
begin
	if (select count(*) from KETQUATHI KQ1, KETQUATHI KQ2
		where KQ1.MAHV = KQ2.MAHV
			and KQ1.MAMH = KQ2.MAMH
			and KQ1.LANTHI + 1 = KQ2.LANTHI
			and KQ1.LANTHI > 5) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 21: Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học). 
create trigger TRGKETQUATHI_2 on KETQUATHI for insert, update
as
begin
	if (select count(*) from KETQUATHI KQ1, KETQUATHI KQ2
		where KQ1.MAHV = KQ2.MAHV
			and KQ1.MAMH = KQ2.MAMH
			and KQ1.LANTHI < KQ2.LANTHI
			and KQ1.NGTHI >= KQ2.NGTHI) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 22: Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong
create trigger TRGHOCVIEN_4 on HOCVIEN for insert, update
as
begin
	if (select count(*) from inserted, KETQUATHI, GIANGDAY GD1
		where inserted.MAHV = KETQUATHI.MAHV
			and (KETQUATHI.MAMH not in (
				select MAMH from GIANGDAY GD2
				where inserted.MALOP = GD2.MALOP)
					or (inserted.MALOP = GD1.MALOP and KETQUATHI.MAMH = GD1.MAMH and KETQUATHI.NGTHI > GD1.DENNGAY))
		) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 23: Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học xong những môn học phải học trước mới được học những môn liền sau)
create trigger TRGGIANGDAY_2 on GIANGDAY for insert, update
as
begin
	if (select count(*) from GIANGDAY GD1, GIANGDAY GD2, DIEUKIEN
		where GD1.MALOP = GD2.MALOP
			and GD1.MAMH = DIEUKIEN.MAMH
			and GD2.MAMH = DIEUKIEN.MAMH_TRUOC
			and GD1.TUNGAY < GD2.DENNGAY) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

-- Câu 24: Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách
create trigger TRGGIANGDAY_3 on GIANGDAY for insert, update
as
begin
	if (select count(*) from GIANGDAY, GIAOVIEN, MONHOC
		where GIANGDAY.MAGV = GIAOVIEN.MAGV
			and GIANGDAY.MAMH = MONHOC.MAMH
			and GIAOVIEN.MAKHOA != MONHOC.MAKHOA) > 0
	begin
		rollback tran
		print 'Cập nhật không thành công'
	end
	else
		print 'Cập nhật thành công'
end
go

----------------------------------------------------------------------------------------------
----------------- Ngôn ngữ thao tác dữ liệu (Data Manipulation Language) ---------------------
----------------------------------------------------------------------------------------------

-- No check để thêm dữ liệu
alter table KHOA nocheck constraint FK_TRGKHOA
alter table LOP nocheck constraint FK_TRGLOP
alter table LOP nocheck constraint FK_MAGVCN
alter table HOCVIEN nocheck constraint FK_MALOP
alter table GIAOVIEN nocheck constraint FK_MAKHOA
alter table GIANGDAY nocheck constraint FK_MAMH
alter table MONHOC nocheck constraint FK_MAKHOA2
alter table DIEUKIEN nocheck constraint FK_MAMH2
alter table DIEUKIEN nocheck constraint FK_MAMH_TRUOC
alter table KETQUATHI nocheck constraint FK_MAHV
go

-- Nhập dữ liệu cho bảng KHOA
insert into KHOA values('KHMT','Khoa hoc may tinh','7/6/2005','GV01')
insert into KHOA values('HTTT','He thong thong tin','7/6/2005','GV02')
insert into KHOA values('CNPM','Cong nghe phan mem','7/6/2005','GV04')
insert into KHOA values('MTT','Mang va truyen thong','20/10/2005','GV03')
insert into KHOA values('KTMT','Ky thuat may tinh','20/12/2005', null)

-- Nhập dữ liệu cho bảng LOP
insert into LOP values('K11','Lop 1 khoa 1','K1108',11,'GV07')
insert into LOP values('K12','Lop 2 khoa 1','K1205',12,'GV09')
insert into LOP values('K13','Lop 3 khoa 1','K1305',12,'GV14')

-- Nhập dữ liệu cho bảng MONHOC
insert into MONHOC values('THDC','Tin hoc dai cuong',4,1,'KHMT')
insert into MONHOC values('CTRR','Cau truc roi rac',5,0,'KHMT')
insert into MONHOC values('CSDL','Co so du lieu',3,1,'HTTT')
insert into MONHOC values('CTDLGT','Cau truc du lieu va giai thuat',3,1,'KHMT')
insert into MONHOC values('PTTKTT','Phan tich thiet ke thuat toan',3,0,'KHMT')
insert into MONHOC values('DHMT','Do hoa may tinh',3,1,'KHMT')
insert into MONHOC values('KTMT','Kien truc may tinh',3,0,'KTMT')
insert into MONHOC values('TKCSDL','Thiet ke co so du lieu',3,1,'HTTT')
insert into MONHOC values('PTTKHTTT','Phan tich thiet ke he thong thong tin',4,1,'HTTT')
insert into MONHOC values('HDH','He dieu hanh',4,0,'KTMT')
insert into MONHOC values('NMCNPM','Nhap mon cong nghe phan mem',3,0,'CNPM')
insert into MONHOC values('LTCFW','Lap trinh C for win',3,1,'CNPM')
insert into MONHOC values('LTHDT','Lap trinh huong doi tuong',3,1,'CNPM')

-- Nhập dữ liệu cho bảng DIEUKIEN
insert into DIEUKIEN values('CSDL','CTRR')
insert into DIEUKIEN values('CSDL','CTDLGT')
insert into DIEUKIEN values('CTDLGT','THDC')
insert into DIEUKIEN values('PTTKTT','THDC')
insert into DIEUKIEN values('PTTKTT','CTDLGT')
insert into DIEUKIEN values('DHMT','THDC')
insert into DIEUKIEN values('LTHDT','THDC')
insert into DIEUKIEN values('PTTKHTTT','CSDL')

-- Nhập dữ liệu cho bảng GIANGDAY
insert into GIANGDAY values('K11','THDC','GV07',1,2006,'01/02/2006','05/12/2006')
insert into GIANGDAY values('K12','THDC','GV06',1,2006,'01/02/2006','05/12/2006')
insert into GIANGDAY values('K13','THDC','GV15',1,2006,'01/02/2006','05/12/2006')
insert into GIANGDAY values('K11','CTRR','GV02',1,2006,'01/09/2006','17/5/2006')
insert into GIANGDAY values('K12','CTRR','GV02',1,2006,'01/09/2006','17/5/2006')
insert into GIANGDAY values('K13','CTRR','GV08',1,2006,'01/09/2006','17/5/2006')
insert into GIANGDAY values('K11','CSDL','GV05',2,2006,'06/01/2006','15/7/2006')
insert into GIANGDAY values('K12','CSDL','GV09',2,2006,'06/01/2006','15/7/2006')
insert into GIANGDAY values('K13','CTDLGT','GV15',2,2006,'06/01/2006','15/7/2006')
insert into GIANGDAY values('K13','CSDL','GV05',3,2006,'08/01/2006','15/12/2006')
insert into GIANGDAY values('K13','DHMT','GV07',3,2006,'08/01/2006','15/12/2006')
insert into GIANGDAY values('K11','CTDLGT','GV15',3,2006,'08/01/2006','15/12/2006')
insert into GIANGDAY values('K12','CTDLGT','GV15',3,2006,'08/01/2006','15/12/2006')
insert into GIANGDAY values('K11','HDH','GV04',1,2007,'01/02/2007','18/2/2007')
insert into GIANGDAY values('K12','HDH','GV04',1,2007,'01/02/2007','20/3/2007')
insert into GIANGDAY values('K11','DHMT','GV07',1,2007,'18/2/2007','20/3/2007')

-- Nhập dữ liệu cho bảng GIAOVIEN
insert into GIAOVIEN values('GV01','Ho Thanh Son','PTS','GS','Nam','05/02/1950','01/11/2004',5,2250000,'KHMT')
insert into GIAOVIEN values('GV02','Tran Tam Thanh','TS','PGS','Nam','17/12/1965','20/4/2004',4.5,2025000,'HTTT')
insert into GIAOVIEN values('GV03','Do Nghiem Phung','TS','GS','Nu','08/01/1950','23/9/2004',4,1800000,'CNPM')
insert into GIAOVIEN values('GV04','Tran Nam Son','TS','PGS','Nam','22/2/1961','01/12/2005',4.5,2025000,'KTMT')
insert into GIAOVIEN values('GV05','Mai Thanh Danh','ThS','GV','Nam','03/12/1958','01/12/2005',3,1350000,'HTTT')
insert into GIAOVIEN values('GV06','Tran Doan Hung','TS','GV','Nam','03/11/1953','01/12/2005',4.5,2025000,'KHMT')
insert into GIAOVIEN values('GV07','Nguyen Minh Tien','ThS','GV','Nam','23/11/1971','03/01/2005',4,1800000,'KHMT')
insert into GIAOVIEN values('GV08','Le Thi Tran','KS',NULL,'Nu','26/3/1974','03/01/2005',1.69,760500,'KHMT')
insert into GIAOVIEN values('GV09','Nguyen To Lan','ThS','GV','Nu','31/12/1966','03/01/2005',4,1800000,'HTTT')
insert into GIAOVIEN values('GV10','Le Tran Anh Loan','KS',NULL,'Nu','17/7/1972','03/01/2005',1.86,837000,'CNPM')
insert into GIAOVIEN values('GV11','Ho Thanh Tung','CN','GV','Nam','01/12/1980','15/5/2005',2.67,1201500,'MTT')
insert into GIAOVIEN values('GV12','Tran Van Anh','CN',NULL,'Nu','29/3/1981','15/5/2005',1.69,760500,'CNPM')
insert into GIAOVIEN values('GV13','Nguyen Linh Dan','CN',NULL,'Nu','23/5/1980','15/5/2005',1.69,760500,'KTMT')
insert into GIAOVIEN values('GV14','Truong Minh Chau','ThS','GV','Nu','30/11/1976','15/5/2005',3,1350000,'MTT')
insert into GIAOVIEN values('GV15','Le Ha Thanh','ThS','GV','Nam','05/04/1978','15/5/2005',3,1350000,'KHMT')

-- Nhập dữ liệu cho bảng HOCVIEN
insert into HOCVIEN values('K1101','Nguyen Van','A','27/1/1986','Nam','TpHCM','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1102','Tran Ngoc','Han','14/3/1986','Nu','Kien Giang','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1103','Ha Duy','Lap','18/4/1986','Nam','Nghe An','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1104','Tran Ngoc','Linh','30/3/1986','Nu','Tay Ninh','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1105','Tran Minh','Long','27/2/1986','Nam','TpHCM','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1106','Le Nhat','Minh','24/1/1986','Nam','TpHCM','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1107','Nguyen Nhu','Nhut','27/1/1986','Nam','Ha Noi','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1108','Nguyen Manh','Tam','27/2/1986','Nam','Kien Giang','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1109','Phan Thi Thanh','Tam','27/1/1986','Nu','Vinh Long','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1110','Le Hoai','Thuong','02/05/1986','Nu','Can Tho','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1111','Le Ha','Vinh','25/12/1986','Nam','Vinh Long','K11', NULL, NULL, NULL)
insert into HOCVIEN values('K1201','Nguyen Van','B','02/11/1986','Nam','TpHCM','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1202','Nguyen Thi Kim','Duyen','18/1/1986','Nu','TpHCM','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1203','Tran Thi Kim','Duyen','17/9/1986','Nu','TpHCM','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1204','Truong My','Hanh','19/5/1986','Nu','Dong Nai','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1205','Nguyen Thanh','Nam','17/4/1986','Nam','TpHCM','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1206','Nguyen Thi Truc','Thanh','03/04/1986','Nu','Kien Giang','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1207','Tran Thi Bich','Thuy','02/08/1986','Nu','Nghe An','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1208','Huynh Thi Kim','Trieu','04/08/1986','Nu','Tay Ninh','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1209','Pham Thanh','Trieu','23/2/1986','Nam','TpHCM','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1210','Ngo Thanh','Tuan','14/2/1986','Nam','TpHCM','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1211','Do Thi','Xuan','03/09/1986','Nu','Ha Noi','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1212','Le Thi Phi','Yen','03/12/1986','Nu','TpHCM','K12', NULL, NULL, NULL)
insert into HOCVIEN values('K1301','Nguyen Thi Kim','Cuc','06/09/1986','Nu','Kien Giang','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1302','Truong Thi My','Hien','18/3/1986','Nu','Nghe An','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1303','Le Duc','Hien','21/3/1986','Nam','Tay Ninh','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1304','Le Quang','Hien','18/4/1986','Nam','TpHCM','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1305','Le Thi','Huong','27/3/1986','Nu','TpHCM','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1306','Nguyen Thai','Huu','30/3/1986','Nam','Ha Noi','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1307','Tran Minh','Man','28/5/1986','Nam','TpHCM','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1308','Nguyen Hieu','Nghia','04/08/1986','Nam','Kien Giang','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1309','Nguyen Trung','Nghia','18/1/1987','Nam','Nghe An','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1310','Tran Thi Hong','Tham','22/4/1986','Nu','Tay Ninh','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1311','Tran Minh','Thuc','04/04/1986','Nam','TpHCM','K13', NULL, NULL, NULL)
insert into HOCVIEN values('K1312','Nguyen Thi Kim','Yen','09/07/1986','Nu','TpHCM','K13', NULL, NULL, NULL)

-- Nhập dữ liệu cho bảng KETQUATHI
insert into KETQUATHI values('K1101','CSDL',1,'20/7/2006',10,'Dat')
insert into KETQUATHI values('K1101','CTDLGT',1,'28/12/2006',9,'Dat')
insert into KETQUATHI values('K1101','THDC',1,'20/5/2006',9,'Dat')
insert into KETQUATHI values('K1101','CTRR',1,'13/5/2006',9.5,'Dat')
insert into KETQUATHI values('K1102','CSDL',1,'20/7/2006',4,'Khong Dat')
insert into KETQUATHI values('K1102','CSDL',2,'27/7/2006',4.25,'Khong Dat')
insert into KETQUATHI values('K1102','CSDL',3,'08/10/2006',4.5,'Khong Dat')
insert into KETQUATHI values('K1102','CTDLGT',1,'28/12/2006',4.5,'Khong Dat')
insert into KETQUATHI values('K1102','CTDLGT',2,'01/05/2007',4,'Khong Dat')
insert into KETQUATHI values('K1102','CTDLGT',3,'15/1/2007',6,'Dat')
insert into KETQUATHI values('K1102','THDC',1,'20/5/2006',5,'Dat')
insert into KETQUATHI values('K1102','CTRR',1,'13/5/2006',7,'Dat')
insert into KETQUATHI values('K1103','CSDL',1,'20/7/2006',3.5,'Khong Dat')
insert into KETQUATHI values('K1103','CSDL',2,'27/7/2006',8.25,'Dat')
insert into KETQUATHI values('K1103','CTDLGT',1,'28/12/2006',7,'Dat')
insert into KETQUATHI values('K1103','THDC',1,'20/5/2006',8,'Dat')
insert into KETQUATHI values('K1103','CTRR',1,'13/5/2006',6.5,'Dat')
insert into KETQUATHI values('K1104','CSDL',1,'20/7/2006',3.75,'Khong Dat')
insert into KETQUATHI values('K1104','CTDLGT',1,'28/12/2006',4,'Khong Dat')
insert into KETQUATHI values('K1104','THDC',1,'20/5/2006',4,'Khong Dat')
insert into KETQUATHI values('K1104','CTRR',1,'13/5/2006',4,'Khong Dat')
insert into KETQUATHI values('K1104','CTRR',2,'20/5/2006',3.5,'Khong Dat')
insert into KETQUATHI values('K1104','CTRR',3,'30/6/2006',4,'Khong Dat')
insert into KETQUATHI values('K1201','CSDL',1,'20/7/2006',6,'Dat')
insert into KETQUATHI values('K1201','CTDLGT',1,'28/12/2006',5,'Dat')
insert into KETQUATHI values('K1201','THDC',1,'20/5/2006',8.5,'Dat')
insert into KETQUATHI values('K1201','CTRR',1,'13/5/2006',9,'Dat')
insert into KETQUATHI values('K1202','CSDL',1,'20/7/2006',8,'Dat')
insert into KETQUATHI values('K1202','CTDLGT',1,'28/12/2006',4,'Khong Dat')
insert into KETQUATHI values('K1202','CTDLGT',2,'01/05/2007',5,'Dat')
insert into KETQUATHI values('K1202','THDC',1,'20/5/2006',4,'Khong Dat')
insert into KETQUATHI values('K1202','THDC',2,'27/5/2006',4,'Khong Dat')
insert into KETQUATHI values('K1202','CTRR',1,'13/5/2006',3,'Khong Dat')
insert into KETQUATHI values('K1202','CTRR',2,'20/5/2006',4,'Khong Dat')
insert into KETQUATHI values('K1202','CTRR',3,'30/6/2006',6.25,'Dat')
insert into KETQUATHI values('K1203','CSDL',1,'20/7/2006',9.25,'Dat')
insert into KETQUATHI values('K1203','CTDLGT',1,'28/12/2006',9.5,'Dat')
insert into KETQUATHI values('K1203','THDC',1,'20/5/2006',10,'Dat')
insert into KETQUATHI values('K1203','CTRR',1,'13/5/2006',10,'Dat')
insert into KETQUATHI values('K1204','CSDL',1,'20/7/2006',8.5,'Dat')
insert into KETQUATHI values('K1204','CTDLGT',1,'28/12/2006',6.75,'Dat')
insert into KETQUATHI values('K1204','THDC',1,'20/5/2006',4,'Khong Dat')
insert into KETQUATHI values('K1204','CTRR',1,'13/5/2006',6,'Dat')
insert into KETQUATHI values('K1301','CSDL',1,'20/12/2006',4.25,'Khong Dat')
insert into KETQUATHI values('K1301','CTDLGT',1,'25/7/2006',8,'Dat')
insert into KETQUATHI values('K1301','THDC',1,'20/5/2006',7.75,'Dat')
insert into KETQUATHI values('K1301','CTRR',1,'13/5/2006',8,'Dat')
insert into KETQUATHI values('K1302','CSDL',1,'20/12/2006',6.75,'Dat')
insert into KETQUATHI values('K1302','CTDLGT',1,'25/7/2006',5,'Dat')
insert into KETQUATHI values('K1302','THDC',1,'20/5/2006',8,'Dat')
insert into KETQUATHI values('K1302','CTRR',1,'13/5/2006',8.5,'Dat')
insert into KETQUATHI values('K1303','CSDL',1,'20/12/2006',4,'Khong Dat')
insert into KETQUATHI values('K1303','CTDLGT',1,'25/7/2006',4.5,'Khong Dat')
insert into KETQUATHI values('K1303','CTDLGT',2,'08/07/2006',4,'Khong Dat')
insert into KETQUATHI values('K1303','CTDLGT',3,'15/8/2006',4.25,'Khong Dat')
insert into KETQUATHI values('K1303','THDC',1,'20/5/2006',4.5,'Khong Dat')
insert into KETQUATHI values('K1303','CTRR',1,'13/5/2006',3.25,'Khong Dat')
insert into KETQUATHI values('K1303','CTRR',2,'20/5/2006',5,'Dat')
insert into KETQUATHI values('K1304','CSDL',1,'20/12/2006',7.75,'Dat')
insert into KETQUATHI values('K1304','CTDLGT',1,'25/7/2006',9.75,'Dat')
insert into KETQUATHI values('K1304','THDC',1,'20/5/2006',5.5,'Dat')
insert into KETQUATHI values('K1304','CTRR',1,'13/5/2006',5,'Dat')
insert into KETQUATHI values('K1305','CSDL',1,'20/12/2006',9.25,'Dat')
insert into KETQUATHI values('K1305','CTDLGT',1,'25/7/2006',10,'Dat')
insert into KETQUATHI values('K1305','THDC',1,'20/5/2006',8,'Dat')
insert into KETQUATHI values('K1305','CTRR',1,'13/5/2006',10,'Dat')

-- Check constraint
alter table KHOA check constraint FK_TRGKHOA
alter table LOP check constraint FK_TRGLOP
alter table LOP check constraint FK_MAGVCN
alter table HOCVIEN check constraint FK_MALOP
alter table GIAOVIEN check constraint FK_MAKHOA
alter table GIANGDAY check constraint FK_MAMH
alter table MONHOC check constraint FK_MAKHOA2
alter table DIEUKIEN check constraint FK_MAMH2
alter table DIEUKIEN check constraint FK_MAMH_TRUOC
alter table KETQUATHI check constraint FK_MAHV
go

-- Câu 1: Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa
update GIAOVIEN
set HESO = HESO * 1.2 where MAGV in (select TRGKHOA from KHOA)
go

-- Câu 2: Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên (tất cả các môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng)
update HOCVIEN set DIEMTB = DTB_HOCVIEN.DTB from HOCVIEN left join
(
	select MAHV, avg(DIEM) DTB
	from KETQUATHI KQ1 where not exists
	(
		select * from KETQUATHI KQ2
		where KQ1.MAHV = KQ2.MAHV and KQ1.MAMH = KQ2.MAMH and KQ1.LANTHI < KQ2.LANTHI
	)
	group by MAHV
) DTB_HOCVIEN
on HOCVIEN.MAHV = DTB_HOCVIEN.MAHV
go

-- Câu 3: Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi lần thứ 3 dưới 5 điểm
update HOCVIEN set GHICHU = 'Cam thi' where MAHV in (select MAHV from KETQUATHI where LANTHI = 3 and DIEM < 5)
go

-- Câu 4: Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
	-- a. Nếu DIEMTB >= 9 thì XEPLOAI = "XS"
	-- b. Nếu 8 <= DIEMTB < 9 thì XEPLOAI = "G"
	-- c. Nếu 6.5 <= DIEMTB < 8 thì XEPLOAI = "K"
	-- d. Nếu 5 <= DIEMTB < 6.5 thì XEPLOAI = "TB"
	-- e. Nếu DIEMTB < 5 thì XEPLOAI = "Y"

update HOCVIEN set XEPLOAI = case
	when DIEMTB >= 9 then 'XS'
	when DIEMTB >= 8 then 'G'
	when DIEMTB >= 6.5 then 'K'
	when DIEMTB >= 5 then 'TB'
	else 'Y'
	end
go

----------------------------------------------------------------------------------------------
---------------------------------- Ngôn ngữ truy vấn dữ liệu ---------------------------------
----------------------------------------------------------------------------------------------

-- Câu 1: In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp
select HOCVIEN.MAHV, (HO + ' ' + TEN) as HOTEN, NGSINH, HOCVIEN.MALOP 
from HOCVIEN, LOP where HOCVIEN.MAHV = LOP.TRGLOP
go

-- Câu 2: In ra bảng điểm khi thi (mã học viên, họ tên , lần thi, điểm số) môn CTRR của lớp “K12”, sắp xếp theo tên, họ học viên
select HOCVIEN.MAHV, (HO + ' ' + TEN) as HOTEN, LANTHI, DIEM
from HOCVIEN, KETQUATHI where KETQUATHI.MAHV = HOCVIEN.MAHV AND MAMH = 'CTRR' AND MALOP = 'K12' order by TEN, HO
go

-- Câu 3: In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi lần thứ nhất đã đạt
select HOCVIEN.MAHV, (HO + ' ' + TEN) as HOTEN, TENMH from KETQUATHI, MONHOC, HOCVIEN
where KETQUATHI.MAMH = MONHOC.MAMH and KETQUATHI.MAHV = HOCVIEN.MAHV and LANTHI = 1 and KQUA = 'Dat'
go

-- Câu 4: In ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở lần thi 1)
select HOCVIEN.MAHV, (HO + ' ' + TEN) as HOTEN from KETQUATHI, HOCVIEN
where KETQUATHI.MAHV = HOCVIEN.MAHV and LANTHI = 1 and KQUA = 'Khong Dat' and MALOP = 'K11' and MAMH = 'CTRR'
go

-- Câu 5: Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần thi)
select distinct HOCVIEN.MAHV, (HO + ' ' + TEN) as HOTEN from KETQUATHI, HOCVIEN
where
(
	KETQUATHI.MAHV = HOCVIEN.MAHV 
	and MAMH = 'CTRR'
	and MALOP like 'K%'
	and not exists (select * from KETQUATHI where KQUA = 'Dat' AND MAMH = 'CTRR' AND MAHV = HOCVIEN.MAHV)
)
go

-- Câu 6: Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006
select distinct MONHOC.MAMH, MONHOC.TENMH from MONHOC, GIANGDAY, GIAOVIEN
where MONHOC.MAMH = GIANGDAY.MAMH and HOCKY = 1 and HOTEN = 'Tran Thanh Tam' and NAM = 2006
go


-- Câu 7: Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006
select MAMH, TENMH from MONHOC where MAMH in
(
	select distinct MAMH from GIANGDAY where HOCKY = 1 and NAM = 2006 and MAGV in
	(
		select MAGVCN from LOP where MALOP = 'K11'
	)
)
go

-- Câu 8: Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”
select HO + ' ' + TEN HOTEN from HOCVIEN where MAHV in
(
	select TRGLOP from LOP where MALOP in
	(
		select MALOP from GIANGDAY where MAGV in
		(
			select MAGV from GIAOVIEN where MAGV in
			(
				select MAGV from GIAOVIEN where HOTEN = 'Nguyen To Lan'
				and  MAMH in 
				(
					select MAMH from MONHOC where TENMH = 'Co So Du Lieu'
				)
			)
		)
	)
)
go

-- Câu 9: In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
select MAMH, TENMH from MONHOC where MAMH in
(
	select MAMH_TRUOC from DIEUKIEN where MAMH in 
	(	
		select MAMH from MONHOC where TENMH = 'Co So Du Lieu'
	)
)
go

-- Câu 10: Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào.
select MAMH, TENMH from MONHOC where MAMH in
(
	select MAMH_TRUOC from DIEUKIEN where MAMH_TRUOC in
	(	
		select MAMH from MONHOC where TENMH = 'Cau Truc Roi Rac' 
	)
)
go

-- Câu 11: Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
select HOTEN from GIAOVIEN where MAGV in
(
	select MAGV from GIANGDAY where MAMH = 'CTRR' and MALOP in ('K11', 'K12')
	and HOCKY = 1 and NAM = 2006 group by MAGV having count(distinct MALOP) = 2
)
go

-- Câu 12: Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này.
select HO + ' ' + TEN HOTEN from HOCVIEN where MAHV in
(
	select MAHV from KETQUATHI KQ1 where not exists
	(
		select * from KETQUATHI KQ2 where KQ1.MAHV = KQ2.MAHV and KQ1.MAMH = KQ2.MAMH and KQ1.LANTHI < KQ2.LANTHI
	)
	and MAMH = 'CSDL' and LANTHI = 1 and KQUA = 'Khong Dat'
)
go

-- Câu 13: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
select MAGV, HOTEN from GIAOVIEN where MAGV not in
(
	select distinct MAGV from GIANGDAY 
)
go

-- Câu 14: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.
select MAGV, HOTEN from GIAOVIEN where MAGV not in
(
	select GIANGDAY.MAGV from GIANGDAY, GIAOVIEN, MONHOC where
	(
		GIANGDAY.MAGV = GIAOVIEN.MAGV and GIANGDAY.MAMH = MONHOC.MAMH and GIAOVIEN.MAKHOA = MONHOC.MAKHOA
	)
)
go

-- Câu 15: Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm.
select HO + ' ' + TEN HOTEN from HOCVIEN where MAHV in
(
	select MAHV from KETQUATHI KQ1
	where left(MAHV, 3) = 'K11' and
	(
		(
			not exists
			(
				select * from KETQUATHI KQ2
				where KQ1.MAHV = KQ2.MAHV and KQ1.MAMH = KQ2.MAMH and KQ1.LANTHI < KQ2.LANTHI
			)
			and LANTHI = 3 and KQUA = 'Khong Dat'
		)
		or MAMH = 'CTRR' and LANTHI = 2 and DIEM = 5
	)
)
go

-- Câu 16: Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.
select HOTEN from GIAOVIEN where MAGV in
(
	select MAGV from GIANGDAY where MAMH = 'CTRR' 
	group by MAGV, HOCKY, NAM having count(MALOP) >= 2
)
go

-- Câu 17: Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
select HOCVIEN.MAHV, HO + ' ' + TEN HOTEN, DIEM from HOCVIEN inner join
(
	select MAHV, DIEM from KETQUATHI KQ1 where not exists
	(
		select * from KETQUATHI KQ2
		where KQ1.MAHV = KQ2.MAHV and KQ1.MAMH = KQ2.MAMH and KQ1.LANTHI < KQ2.LANTHI
	)
	and MAMH = 'CSDL'
) DIEM_CSDL
on HOCVIEN.MAHV = DIEM_CSDL.MAHV
go

-- Câu 18: Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
select HOCVIEN.MAHV, HO + ' ' + TEN HOTEN, DIEM from HOCVIEN inner join
(
	select MAHV, max(DIEM) DIEM from KETQUATHI where MAMH in 
	(
		select MAMH from MONHOC
		where TENMH = 'Co So Du Lieu'
	)
	group by MAHV, MAMH
) DIEM_CSDL
on HOCVIEN.MAHV = DIEM_CSDL.MAHV
go

-- Câu 19: Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất
select MAKHOA, TENKHOA from (
	select MAKHOA, TENKHOA , rank() over (order by NGTLAP) RANK_NGTLAP from KHOA
) A
where RANK_NGTLAP = 1
go

-- Câu 20: Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”
select HOCHAM, count(HOCHAM) SO_LUonG from GIAOVIEN
where HOCHAM in ('GS', 'PGS')
group by HOCHAM
go

-- Câu 21: Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa
select MAKHOA, HOCVI, count(HOCVI) SO_LUonG from GIAOVIEN
group by MAKHOA, HOCVI order by MAKHOA
go

-- Câu 22: Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt)
select MAMH, KQUA, count(MAHV) SO_LUonG from KETQUATHI KQ1
where not exists (
	select * from KETQUATHI KQ2
	where KQ1.MAHV = KQ2.MAHV and KQ1.MAMH = KQ2.MAHV and KQ1.LANTHI < KQ2.LANTHI
)
group by MAMH, KQUA order by MAMH
go

-- Câu 23: Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học
select MAGV, HOTEN from GIAOVIEN where MAGV in (
	select distinct MAGV from LOP, GIANGDAY where MAGV = MAGVCN and LOP.MALOP = GIANGDAY.MALOP
)
go

-- Câu 24: Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất
select HO + ' ' + TEN HOTEN from HOCVIEN, LOP
where LOP.TRGLOP = MAHV and SISO = (
	select max(SISO) from LOP
)
go

-- Câu 25*: Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi)
select HO + ' ' + TEN HOTEN from HOCVIEN, LOP, KETQUATHI
where HOCVIEN.MAHV = LOP.TRGLOP and HOCVIEN.MAHV = KETQUATHI.MAHV and KQUA = 'Khong Dat'
group by TRGLOP, HO, TEN
having count(*) > 3
go

-- Câu 26: Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất
select top 1 with ties HOCVIEN.MAHV, HO + ' ' + TEN HOTEN from HOCVIEN, KETQUATHI
where HOCVIEN.MAHV = KETQUATHI.MAHV and DIEM >= 9
group by HOCVIEN.MAHV, HO, TEN
order by count(*) desc
go

-- Câu 27: Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
select left(A.MAHV, 3) MALOP, A.MAHV, HO + ' ' + TEN HOTEN from (
	select MAHV, rank() over (order by count(MAMH) desc) RANK_MH from KETQUATHI
	where DIEM between 9 and 10
	group by KETQUATHI.MAHV
) A, HOCVIEN where A.MAHV = HOCVIEN.MAHV and RANK_MH = 1
group by left(A.MAHV, 3), A.MAHV, HO, TEN
go

-- Câu 28: Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp
select HOCKY, NAM ,MAGV, count(MAMH) 'SO LUonG Mon HOC', count(MALOP) 'SO LOP' from GIANGDAY
group by HOCKY, NAM, MAGV
go

-- Câu 29: Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất
select HOCKY, NAM, A.MAGV, HOTEN from (
	select HOCKY, NAM, MAGV, rank() over (partition by HOCKY, NAM order by count(MAMH) desc) RANK_SOMH from GIANGDAY
	group by HOCKY, NAM, MAGV
) A, GIAOVIEN where GIAOVIEN.MAGV = A.MAGV and RANK_SOMH = 1 
go

-- Câu 30: Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt ở lần thi thứ 1
select A.MAMH, TENMH from (
	select MAMH, rank() over (order by count(MAHV) desc) RANK_SOHV from KETQUATHI
	where LANTHI = 1 and KQUA = 'Khong Dat'
	group by MAMH
) A, MONHOC where A.MAMH = MONHOC.MAMH and RANK_SOHV = 1
go

-- Câu 31: Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1)
select distinct HOCVIEN.MAHV, HO + ' ' + TEN HOTEN from HOCVIEN, KETQUATHI
where HOCVIEN.MAHV = KETQUATHI.MAHV and not exists (
	select * from KETQUATHI
	where LANTHI = 1 and KQUA = 'Khong Dat' and MAHV = HOCVIEN.MAHV
)
go

-- Câu 32*: Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng)
select distinct HOCVIEN.MAHV, HO + ' ' + TEN HOTEN from HOCVIEN, KETQUATHI
where HOCVIEN.MAHV = KETQUATHI.MAHV and not exists (
	select * from KETQUATHI
	where LANTHI = (select max(LANTHI) from KETQUATHI where MAHV = HOCVIEN.MAHV group by MAHV)
	and KQUA = 'Khong Dat' and MAHV = HOCVIEN.MAHV
)
go

-- Câu 33: Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1)
select A.MAHV, HO + ' ' + TEN HOTEN from (
	select MAHV, count(KQUA) SODAT from KETQUATHI 
	where LANTHI = 1 AND KQUA = 'Dat' group by MAHV
	intersect
	select MAHV, count(MAMH) SOMH from KETQUATHI 
	where LANTHI = 1 group by MAHV
) A, HOCVIEN where A.MAHV = HOCVIEN.MAHV
go

-- Câu 34*: Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt  (chỉ xét lần thi sau cùng)
select C.MAHV, HO + ' ' + TEN HOTEN from (
	select MAHV, count(KQUA) SODAT from KETQUATHI KQ1
	where not exists (
		select * from KETQUATHI KQ2
		where KQ1.MAHV = KQ2.MAHV AND KQ1.MAMH = KQ2.MAMH AND KQ1.LANTHI < KQ2.LANTHI
	) and KQUA = 'Dat' group by MAHV
	intersect
	select MAHV, count(MAMH) SOMH from KETQUATHI where LANTHI = 1 group by MAHV
) C, HOCVIEN where C.MAHV = HOCVIEN.MAHV
go

-- Câu 35**: Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng)
select MAMH, MAHV, HOTEN from (
	select MAMH, HOCVIEN.MAHV, HO + ' ' + TEN HOTEN, rank() over (partition by MAMH order by max(DIEM) desc) RANK_HV
	from HOCVIEN, KETQUATHI
	where HOCVIEN.MAHV = KETQUATHI.MAHV and LANTHI = (select max(LANTHI) from KETQUATHI where MAHV = HOCVIEN.MAHV group by MAHV)
	group by MAMH, HOCVIEN.MAHV, HO, TEN
) A where RANK_HV = 1
go