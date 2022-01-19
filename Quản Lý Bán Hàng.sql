----------------------------------------------------------------------------------------------
--------------------------- CƠ SỞ DỮ LIỆU: QUẢN LÝ BÁN HÀNG ----------------------------------
----------------------------------------------------------------------------------------------
create database QuanLyBanHang
go
--
use QuanLyBanHang
go

----------------------------------------------------------------------------------------------
----------------- Ngôn ngữ định nghĩa dữ liệu (Data Definition Language) ---------------------
----------------------------------------------------------------------------------------------

-- Câu 1: Tạo các quan hệ và khai báo các khóa chính, khóa ngoại của quan hệ.

-- Quan hệ: KHACHHANG
create table KHACHHANG
(
	MAKH char(4),
	HOTEN varchar(40),
	DIACHI varchar(50),
	SDT varchar(20),
	NGAYSINH smalldatetime,
	DOANHSO money,
	NGAYDK smalldatetime
	constraint PK_KHACHHANG primary key (MAKH)
)
go
-- Quan hệ: NHANVIEN
create table NHANVIEN
(
	MANV char(4),
	HOTEN varchar(40),
	SDT varchar(20),
	NGAYVL smalldatetime,
	constraint PK_NHANVIEN primary key (MANV)
)
go
-- Quan hệ: SANPHAM 
create table SANPHAM
(
	MASP char(4),
	TENSP varchar(40),
	DVT varchar(20),
	NUOCSX varchar(40),
	GIA money
	constraint PK_SANPHAM primary key (MASP)
)
go
-- Quan hệ: HOADON
create table HOADON
(
	SOHD int,
	NGHD smalldatetime,
	MAKH char(4),
	MANV char(4),
	TRIGIA money
	constraint PK_HOADON primary key (SOHD)
)
go
-- Quan hệ: CTHD
create table CTHD
(
	SOHD int,
	MASP char(4),
	SL int
	constraint PK_CTHD primary key (SOHD, MASP)
)
go

-- Khóa ngoại
alter table HOADON add constraint FK_MAKH foreign key (MAKH) references KHACHHANG(MAKH)
alter table HOADON add constraint FK_MANV foreign key (MANV) references NHANVIEN(MANV)
alter table CTHD add constraint FK_MASP foreign key (MASP) references SANPHAM(MASP)
alter table CTHD add constraint FK_SOHD foreign key (SOHD) references HOADON(SOHD)
go

-- Câu 2: Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM.
alter table SANPHAM add GHICHU varchar(20)
go

-- Câu 3: Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG.
alter table KHACHHANG add LOAIKH tinyint
go

-- Câu 4: Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100).
alter table SANPHAM alter column GHICHU varchar(100)
go

-- Câu 5: Xóa thuộc tính GHICHU trong quan hệ SANPHAM.
alter table SANPHAM drop column GHICHU
go

-- Câu 6: Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang lai”, “Thuong xuyen”, “Vip”, …
alter table KHACHHANG alter column LOAIKH varchar(50)
go

-- Câu 7: Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”)
alter table SANPHAM add constraint CK_DVT check (DVT in ('cay','hop','cai','quyen','chuc'))
go

-- Câu 8: Giá bán của sản phẩm từ 500 đồng trở lên.
alter table SANPHAM add constraint CK_GIA check (GIA >= 500)
go

-- Câu 9: Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.
alter table HOADON add constraint CK_MUA check (TRIGIA > 0)
go

-- Câu 10: Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó.
alter table KHACHHANG add constraint CK_NGAYDK check (NGAYDK > NGAYSINH)
go

-- Câu 11: Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK)
create trigger tg_NGHD on HOADON for insert, update
as
begin
	if (select count(*) from inserted, KHACHHANG where inserted.MAKH = KHACHHANG.MAKH and inserted.NGHD < KHACHHANG.NGAYDK) > 0
	begin
		print 'Không hợp lệ: Ngày mua hàng phải lớn hơn hoặc bằng ngày đăng kí'
		rollback transaction
	end
	else
	begin
		print 'Thêm hóa đơn thành công'
	end
end
go

-- Câu 12: Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm
create trigger tg_NGHD_2 on HOADON for insert, update
as
begin
	if (select count(*) from inserted, NHANVIEN where inserted.MANV = NHANVIEN.MANV and inserted.NGHD < NHANVIEN.NGAYVL) > 0
	begin
		print 'Không hợp lệ: Ngày bán hàng của nhân viên phải lớn hơn hoặc bằng ngày vào làm'
		rollback transaction
	end
end
go

-- Câu 13: Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn
create trigger tg_CTHD on CTHD for insert
as
begin
	if ((select count(*) from inserted where SOHD = inserted.SOHD) = (select count(*) from inserted, HOADON where HOADON.SOHD = inserted.SOHD))
	begin
		print 'Mỗi hóa đơn phải có ít nhất một chi tiết hóa đơn'
	end
end
go

-- Câu 14: Trị giá của một hóa đơn là tổng thành tiền (số lượng * đơn giá) của các chi tiết thuộc hóa đơn đó
create trigger tg_CTHD1 on CTHD for insert, update, delete
as
begin
	update HOADON set TRIGIA = 
	(
		select sum(SL*GIA)
		from SANPHAM, CTHD
		where SANPHAM.MASP = CTHD.MASP and CTHD.SOHD = HOADON.SOHD
	) where HOADON.SOHD in (select SOHD from inserted)
end
go

----------------------------------------------------------------------------------------------
----------------- Ngôn ngữ thao tác dữ liệu (Data Manipulation Language) ---------------------
----------------------------------------------------------------------------------------------

set dateformat DMY
go
-- Câu 1: Nhập dữ liệu cho các quan hệ trên.

-- Nhập dữ liệu cho bảng KHACHHANG
insert into KHACHHANG values('KH01','Nguyen Van A','731 Tran Hung Dao, Q5, TpHCM','08823451','22/10/1960',13060000,'22/07/2006')
insert into KHACHHANG values('KH02','Tran Ngoc Han','23/5 Nguyen Trai, Q5, TpHCM','908256478','03/04/1974',280000,'30/07/2006')
insert into KHACHHANG values('KH03','Tran Ngoc Linh','45 Nguyen Canh Chan, Q1, TpHCM','938776266','12/06/1980',3860000,'08/05/2006')
insert into KHACHHANG values('KH04','Tran Minh Long','50/34 Le Dai Hanh, Q10, TpHCM','917325476','09/03/1965',250000,'10/02/2006')
insert into KHACHHANG values('KH05','Le Nhat Minh','34 Truong Dinh, Q3, TpHCM','8246108','10/03/1950',21000,'28/10/2006')
insert into KHACHHANG values('KH06','Le Hoai Thuong','227 Nguyen Van Cu, Q5, TpHCM','8631738','31/12/1981',915000,'24/11/2006')
insert into KHACHHANG values('KH07','Nguyen Van Tam','32/3 Tran Binh Trong, Q5, TpHCM','916783565','06/04/1971',12500,'12/01/2006')
insert into KHACHHANG values('KH08','Phan Thi Thanh','45/2 An Duong Vuong, Q5, TpHCM','938435756','10/01/1971',365000,'13/12/2006')
insert into KHACHHANG values('KH09','Le Ha Vinh','873 Le Hong Phong, Q5, TpHCM','8654763','03/09/1979',70000,'14/01/2007')
insert into KHACHHANG values('KH10','Ha Duy Lap','34/34B Nguyen Trai, Q1, TpHCM','8768904','02/05/1983',67500,'16/01/2007')

-- Nhập dữ liệu cho bảng NHANVIEN
insert into NHANVIEN values('NV01','Nguyen Nhu Nhut','927345678','13/04/2006')
insert into NHANVIEN values('NV02','Le Thi Phi Yen','987567390','21/04/2006')
insert into NHANVIEN values('NV03','Nguyen Van B','997047382','27/04/2006')
insert into NHANVIEN values('NV04','Ngo Thanh Tuan','913758498','24/06/2006')
insert into NHANVIEN values('NV05','Nguyen Thi Truc Thanh','918590387','20/07/2006')

-- Nhập dữ liệu cho bảng SANPHAM
insert into SANPHAM values('BC01','But chi','cay','Singapore',3000)
insert into SANPHAM values('BC02','But chi','cay','Singapore',5000)
insert into SANPHAM values('BC03','But chi','cay','Viet Nam',3500)
insert into SANPHAM values('BC04','But chi','hop','Viet Nam',30000)
insert into SANPHAM values('BB01','But bi','cay','Viet Nam',5000)
insert into SANPHAM values('BB02','But bi','cay','Trung Quoc',7000)
insert into SANPHAM values('BB03','But bi','hop','Thai Lan',100000)
insert into SANPHAM values('TV01','Tap 100 giay mong','quyen','Trung Quoc',2500)
insert into SANPHAM values('TV02','Tap 200 giay mong','quyen','Trung Quoc',4500)
insert into SANPHAM values('TV03','Tap 100 giay tot','quyen','Viet Nam',3000)
insert into SANPHAM values('TV04','Tap 200 giay tot','quyen','Viet Nam',5500)
insert into SANPHAM values('TV05','Tap 100 trang','chuc','Viet Nam',23000)
insert into SANPHAM values('TV06','Tap 200 trang','chuc','Viet Nam',53000)
insert into SANPHAM values('TV07','Tap 100 trang','chuc','Trung Quoc',34000)
insert into SANPHAM values('ST01','So tay 500 trang','quyen','Trung Quoc',40000)
insert into SANPHAM values('ST02','So tay loai 1','quyen','Viet Nam',55000)
insert into SANPHAM values('ST03','So tay loai 2','quyen','Viet Nam',51000)
insert into SANPHAM values('ST04','So tay','quyen','Thai Lan',55000)
insert into SANPHAM values('ST05','So tay mong','quyen','Thai Lan',20000)
insert into SANPHAM values('ST06','Phan viet bang','hop','Viet Nam',5000)
insert into SANPHAM values('ST07','Phan khong bui','hop','Viet Nam',7000)
insert into SANPHAM values('ST08','Bong bang','cai','Viet Nam',1000)
insert into SANPHAM values('ST09','But long','cay','Viet Nam',5000)
insert into SANPHAM values('ST10','But long','cay','Trung Quoc',7000)

-- Nhập dữ liệu cho bảng hoa don
insert into HOADON values(1001,'23/07/2006','KH01','NV01',320000)
insert into HOADON values(1002,'12/08/2006','KH01','NV02',840000)
insert into HOADON values(1003,'23/08/2006','KH02','NV01',100000)
insert into HOADON values(1004,'01/09/2006','KH02','NV01',180000)
insert into HOADON values(1005,'20/10/2006','KH01','NV02',3800000)
insert into HOADON values(1006,'16/10/2006','KH01','NV03',2430000)
insert into HOADON values(1007,'28/10/2006','KH03','NV03',510000)
insert into HOADON values(1008,'28/10/2006','KH01','NV03',440000)
insert into HOADON values(1009,'28/10/2006','KH03','NV04',200000)
insert into HOADON values(1010,'01/11/2006','KH01','NV01',5200000)
insert into HOADON values(1011,'04/11/2006','KH04','NV03',250000)
insert into HOADON values(1012,'30/11/2006','KH05','NV03',21000)
insert into HOADON values(1013,'12/12/2006','KH06','NV01',5000)
insert into HOADON values(1014,'31/12/2006','KH03','NV02',3150000)
insert into HOADON values(1015,'01/01/2007','KH06','NV01',910000)
insert into HOADON values(1016,'01/01/2007','KH07','NV02',12500)
insert into HOADON values(1017,'02/01/2007','KH08','NV03',35000)
insert into HOADON values(1018,'13/01/2007','KH08','NV03',330000)
insert into HOADON values(1019,'13/01/2007','KH01','NV03',30000)
insert into HOADON values(1020,'14/01/2007','KH09','NV04',70000)
insert into HOADON values(1021,'16/01/2007','KH10','NV03',67500)
insert into HOADON values(1022,'16/01/2007',Null,'NV03',7000)
insert into HOADON values(1023,'17/01/2007',Null,'NV01',330000)

-- Nhập dữ liệu cho bảng CTHD
insert into CTHD values(1001,'TV02',10)
insert into CTHD values(1001,'ST01',5)
insert into CTHD values(1001,'BC01',5)
insert into CTHD values(1001,'BC02',10)
insert into CTHD values(1001,'ST08',10)
insert into CTHD values(1002,'BC04',20)
insert into CTHD values(1002,'BB01',20)
insert into CTHD values(1002,'BB02',20)
insert into CTHD values(1003,'BB03',10)
insert into CTHD values(1004,'TV01',20)
insert into CTHD values(1004,'TV02',10)
insert into CTHD values(1004,'TV03',10)
insert into CTHD values(1004,'TV04',10)
insert into CTHD values(1005,'TV05',50)
insert into CTHD values(1005,'TV06',50)
insert into CTHD values(1006,'TV07',20)
insert into CTHD values(1006,'ST01',30)
insert into CTHD values(1006,'ST02',10)
insert into CTHD values(1007,'ST03',10)
insert into CTHD values(1008,'ST04',8)
insert into CTHD values(1009,'ST05',10)
insert into CTHD values(1010,'TV07',50)
insert into CTHD values(1010,'ST07',50)
insert into CTHD values(1010,'ST08',100)
insert into CTHD values(1010,'ST04',50)
insert into CTHD values(1010,'TV03',100)
insert into CTHD values(1011,'ST06',50)
insert into CTHD values(1012,'ST07',3)
insert into CTHD values(1013,'ST08',5)
insert into CTHD values(1014,'BC02',80)
insert into CTHD values(1014,'BB02',100)
insert into CTHD values(1014,'BC04',60)
insert into CTHD values(1014,'BB01',50)
insert into CTHD values(1015,'BB02',30)
insert into CTHD values(1015,'BB03',7)
insert into CTHD values(1016,'TV01',5)
insert into CTHD values(1017,'TV02',1)
insert into CTHD values(1017,'TV03',1)
insert into CTHD values(1017,'TV04',5)
insert into CTHD values(1018,'ST04',6)
insert into CTHD values(1019,'ST05',1)
insert into CTHD values(1019,'ST06',2)
insert into CTHD values(1020,'ST07',10)
insert into CTHD values(1021,'ST08',5)
insert into CTHD values(1021,'TV01',7)
insert into CTHD values(1021,'TV02',10)
insert into CTHD values(1022,'ST07',1)
insert into CTHD values(1023,'ST04',6)

-- Câu 2: Tạo quan hệ SANPHAM1 chứa toàn bộ dữ liệu của quan hệ SANPHAM. Tạo quan hệ KHACHHANG1 chứa toàn bộ dữ liệu của quan hệ KHACHHANG.
select * into SANPHAM1 from SANPHAM
select * from SANPHAM1
select *into KHACHHANG1 from KHACHHANG
select * from KHACHHANG1
go

-- Câu 3: Cập nhật giá tăng 5% đối với những sản phẩm do “Thai Lan” sản xuất (cho quan hệ SANPHAM1)
update SANPHAM1 set GIA = GIA * 1.05 where NUOCSX = 'Thai Lan'
go

-- Câu 4: Cập nhật giá giảm 5% đối với những sản phẩm do “Trung Quoc” sản xuất có giá từ 10.000 trở xuống (cho quan hệ SANPHAM1).
update SANPHAM1 set GIA = GIA * 0.95 where NUOCSX = 'Trung Quoc' and GIA <= 10000
select * from SANPHAM1
go

-- Câu 5: Cập nhật giá trị LOAIKH là “Vip” đối với những khách hàng đăng ký thành viên trước ngày 1/1/2007 có doanh số từ 10.000.000 trở lên hoặc khách hàng đăng ký thành viên từ 1/1/2007 trở về sau có doanh số từ 2.000.000 trở lên (cho quan hệ KHACHHANG1).
update KHACHHANG1 set LOAIKH = 'Vip' where (NGAYDK < '1/1/2007' and DOANHSO >= 10000000) or (NGAYDK > '1/1/2007' and DOANHSO >= 20000000) 
select * from KHACHHANG1
go

----------------------------------------------------------------------------------------------
---------------------------------- Ngôn ngữ truy vấn dữ liệu ---------------------------------
----------------------------------------------------------------------------------------------

-- Câu 1: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất
select MASP, TENSP from SANPHAM where NUOCSX = 'Trung Quoc'
go

-- Câu 2: In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”
select MASP, TENSP from SANPHAM where DVT = 'cay' or DVT = 'quyen'
go

-- Câu 3: In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”
select MASP, TENSP from SANPHAM where MASP like 'B%01'
go

-- Câu 4: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 đến 40.000
select MASP, TENSP from SANPHAM where (NUOCSX = 'Trung Quoc') and (GIA between 30000 and 40000)
go

-- Câu 5: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản xuất có giá từ 30.000 đến 40.000
select MASP, TENSP from SANPHAM where NUOCSX in ('Trung Quoc', 'Thai Lan') and (GIA between 30000 and 40000)
go

-- Câu 6: In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007
select SOHD, TRIGIA from HOADON where NGHD in ('1/1/2007', '2/1/2007')
go

-- Câu 7: In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007 sắp xếp theo ngày (tăng dần) và trị giá của hóa đơn (giảm dần)
select SOHD, TRIGIA from HOADON where month(NGHD) = 1 and year(NGHD) = 2007 order by NGHD ASC, TRIGIA DESC
go

-- Câu 8: In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007
select HOADON.MAKH, HOTEN from HOADON inner join KHACHHANG on HOADON.MAKH = KHACHHANG.MAKH where NGHD = '1/1/2007'
go

-- Câu 9: In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 28/10/2006
select SOHD, TRIGIA from HOADON, NHANVIEN where NHANVIEN.MANV = HOADON.MANV and HOTEN = 'Nguyen Van B' and NGHD = '28/10/2006'
go

-- Câu 10: In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” mua trong tháng 10/2006
select CTHD.MASP, TENSP from CTHD INNER JOIN SANPHAM  on CTHD.MASP = SANPHAM.MASP
where SOHD in
(
	select SOHD from HOADON INNER JOIN KHACHHANG on HOADON.MAKH = KHACHHANG.MAKH
	where KHACHHANG.HOTEN = 'Nguyen Van A' and year(NGHD) = 2006 and month(NGHD) = 10 
)
go

-- Câu 11: Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”.
select SOHD from CTHD where CTHD.MASP in ('BB01','BB02')
go

-- Câu 12: Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20
(select SOHD from CTHD where (MASP = 'BB01' and (SL between 10 and 20)))
union
(select SOHD from CTHD where (MASP = 'BB02' and (SL between 10 and 20)))
go

-- Câu 13: Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20
(select SOHD from CTHD where (MASP = 'BB01' and (SL between 10 and 20)))
intersect
(select SOHD from CTHD where (MASP = 'BB02' and (SL between 10 and 20)))
go

-- Câu 14: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được bán ra trong ngày 1/1/2007
(select MASP, TENSP from SANPHAM where NUOCSX = 'Trung Quoc')
union 
(select SANPHAM.MASP, TENSP from SANPHAM, HOADON, CTHD where CTHD.SOHD = HOADON.SOHD and CTHD.MASP = SANPHAM.MASP and NGHD = '1/1/2007')
go

-- Câu 15: In ra danh sách các sản phẩm (MASP,TENSP) không bán được
select MASP, TENSP from SANPHAM where MASP not in (select distinct MASP from CTHD)
go

-- Câu 16: In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006
select MASP, TENSP from SANPHAM where MASP not in (select MASP from CTHD, HOADON where (CTHD.SOHD = HOADON.SOHD and year(NGHD) = 2006 ))
go

-- Câu 17: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006
select MASP, TENSP from SANPHAM where NUOCSX = 'Trung Quoc' and MASP not in (select MASP from CTHD, HOADON where (CTHD.SOHD = HOADON.SOHD and year(NGHD) = 2006))
go

-- Câu 18: Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất
select CTHD.SOHD from CTHD, SANPHAM
where CTHD.MASP = SANPHAM.MASP and NUOCSX = 'Singapore'
group by CTHD.SOHD having count(distinct CTHD.MASP) = (select count(MASP) from SANPHAM where NUOCSX = 'Singapore')
go

-- Câu 19: Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất
select SOHD
from HOADON
where YEAR(NGHD) = 2006 
and not exists
(
	select *
	from SANPHAM
	where NUOCSX = 'Singapore'
	and not exists
	(
		select *
		from CTHD
		where CTHD.SOHD = HOADON.SOHD
		and CTHD.MASP = SANPHAM.MASP
	)
)
go

-- Câu 20: Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
select count(*) SO_LUonG from HOADON where MAKH not in (
	select MAKH from KHACHHANG where HOADON.MAKH = KHACHHANG.MAKH
)
go

-- Câu 21: Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006
select count(distinct MASP) SO_LUonG from CTHD inner join HOADON on CTHD.SOHD = HOADON.SOHD where year(NGHD) = '2006'
go

-- Câu 22: Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?
select max(TRIGIA) GIA_MAX, max(TRIGIA) GIA_MIN from HOADON
go

-- Câu 23: Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
select avg(TRIGIA) GIA_TB from HOADON where year(NGHD) = '2006'
go

-- Câu 24: Tính doanh thu bán hàng trong năm 2006
select sum(TRIGIA) DOANH_THU from HOADON where year(NGHD) = '2006'
go

-- Câu 25: Tìm số hóa đơn có trị giá cao nhất trong năm 2006
select SOHD from HOADON where year(NGHD) = '2006' and TRIGIA = (select max(TRIGIA) from HOADON)
go

-- Câu 26: Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006
select HOTEN from KHACHHANG inner join HOADON on KHACHHANG.MAKH = HOADON.MAKH 
where year(NGHD) = '2006' and TRIGIA = (select max(TRIGIA) from HOADON)
go

-- Câu 27: In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất
select top 3 MAKH, HOTEN from KHACHHANG  order by DOANHSO desc
go

-- Câu 28: In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất
select MASP, TENSP from SANPHAM where GIA in 
(
	select distinct top 3 GIA from SANPHAM order by GIA desc
)
go 

-- Câu 29: In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm)
select MASP, TENSP from SANPHAM where NUOCSX = 'Thai Lan' and GIA in 
(
	select distinct top 3 GIA from SANPHAM order by GIA desc
)
go 

-- Câu 30: In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất)
select MASP, TENSP from SANPHAM where NUOCSX = 'Trung Quoc' and GIA in 
(
	select distinct top 3 GIA from SANPHAM where NUOCSX = 'Trung Quoc' order by GIA desc
)
go

-- Câu 31*: In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng)
select top 3 MAKH, HOTEN, rank() over (order by DOANHSO desc) RANK_DOANHSO from KHACHHANG
go

-- Câu 32: Tính tổng số sản phẩm do “Trung Quoc” sản xuất
select count(MASP) from SANPHAM where NUOCSX = 'Trung Quoc'
go

-- Câu 33: Tính tổng số sản phẩm của từng nước sản xuất
select NUOCSX QUOCGIA, count(MASP) SO_SP from SANPHAM group by NUOCSX
go

-- Câu 34: Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm
select NUOCSX QUOCGIA, max(GIA) GIA_LonNHAT, min(GIA) GIA_NHonHAT, avg(GIA) GIA_TRUNGBINH from SANPHAM group by NUOCSX
go

-- Câu 35: Tính doanh thu bán hàng mỗi ngày
select NGHD, sum(TRIGIA) DOANHTHU from HOADON group by NGHD
go

-- Câu 36: Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006
select CTHD.MASP, SANPHAM.TENSP, sum(SL) SOLUonG from SANPHAM, CTHD inner join HOADON on CTHD.SOHD = HOADON.SOHD
where ( month(NGHD) = '10' and year(NGHD) = '2006' and CTHD.MASP = SANPHAM.MASP) group by SANPHAM.TENSP, CTHD.MASP
go

-- Câu 37: Tính doanh thu bán hàng của từng tháng trong năm 2006
select month(NGHD) THANG, sum(TRIGIA) DOANHTHU from HOADON where year(NGHD) = '2006' group by month(NGHD)
go

-- Câu 38: Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau
select CTHD.SOHD from CTHD group by CTHD.SOHD having count(distinct MASP) >= 4
go

-- Câu 39: Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
select CTHD.SOHD from CTHD inner join SANPHAM on CTHD.MASP = SANPHAM.MASP where NUOCSX = 'Viet Nam'
group by CTHD.SOHD having count(distinct CTHD.MASP) = 3
go

-- Câu 40: Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất
select MAKH, HOTEN from
(
	select HOADON.MAKH, HOTEN, rank() over (order by count(HOADON.MAKH) desc) SOLAN_MUAHANG
	from HOADON inner join KHACHHANG on HOADON.MAKH = KHACHHANG.MAKH
	group by HOADON.MAKH, HOTEN
) A
where SOLAN_MUAHANG = 1
go

-- Câu 41: Tháng mấy trong năm 2006, doanh số bán hàng cao nhất?
select THANG from
(
	select month(NGHD) THANG, rank() over (order by sum(TRIGIA) desc) DOANHSO_MAX
	from HOADON where year(NGHD) = '2006'
	group by month(NGHD)
) A
where DOANHSO_MAX = 1
go

-- Câu 42: Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
select A.MASP, TENSP from
(
	select CTHD.MASP, rank() over (order by sum(SL)) SO_LUonG_BAN
	from CTHD inner join HOADON on CTHD.SOHD = HOADON.SOHD
	where year(NGHD) = '2006'
	group by CTHD.MASP
) A inner join SANPHAM on A.MASP = SANPHAM.MASP
where SO_LUonG_BAN = 1
go

-- Câu 43*: Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất
select NUOCSX QUOCGIA, MASP, TENSP from 
(
	select NUOCSX, MASP, TENSP, GIA, rank() over (partition by NUOCSX order by GIA desc) GIA_BAN
	from SANPHAM
) A
where GIA_BAN = 1
go

-- Câu 44: Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau
select NUOCSX QUOCGIA from SANPHAM group by NUOCSX having count(GIA) >= 3
go

-- Câu 45*: Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất
select MAKH, HOTEN from
(
	select top 10 HOADON.MAKH, HOTEN, DOANHSO, rank() over (order by count(HOADON.MAKH) desc) SO_LAN_MUA
	from HOADON inner join KHACHHANG on HOADON.MAKH = KHACHHANG.MAKH
	group by HOADON.MAKH, HOTEN, DOANHSO order by DOANHSO desc
) A
where SO_LAN_MUA = 1
go