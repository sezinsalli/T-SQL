--2)Firmamýzda iki çalýþan iþe baþlamýþtýr. Çalýþanlarýn bilgileri aþaðýdaki gibi olup kayýtlarýnýn 
--yapýlmasý gerekmektedir. 

Insert Into Employees(FirstName,LastName,Title,TitleOfCourtesy,BirthDate,HireDate,City,Country)
Values('Brown','James','Sales Representative','Mr.','1970-01-01','1999-01-01','London','UK'),
('Dark','Annie','Sales Manager','Mrs.','1966-01-27','1999-01-01','Seattle','USA')

--3)Annie bir süre sonra oturduðu þehirden taþýnýp New York’a yerleþti. Annie Dark 
--çalýþanýmýzýn bilgilerini güncelleyiniz. 

Update Employees
Set City=('New York')
where EmployeeID=13

select * from Employees

--4)Çalýþanlarýmdan Nancy, bugün, Alfreds Futterkiste þirketine Chai ve Chang ürününden 
--beþer adet satmýþtýr. Bu ürünlerin Federal Shipping kargo þirketi ile üç gün sonra 
--gönderilmesi gerekmektedir. Bu sipariþin kaydýný oluþturunuz.

Insert Into Orders(CustomerID,EmployeeID,OrderDate,RequiredDate,ShipVia)
Values('ALFKI',1,GETDATE(),DATEADD(day, 3, GETDATE()),3)

Insert Into [Order Details](OrderID,ProductID,UnitPrice,Quantity)
Values(11084,1,14.40,5),(11084,2,15.20,5)

select * from Orders
select * from [Order Details]


--5)Speedy Express veya United Package ile taþýnan, Steven Buchanan adlý çalýþanýn rapor verdiði 
--çalýþanlarýn ilgilendiði ve Amerika'ya gönderilen sipariþlerimin ürünlerinden, tedarik süresinde
--pazarlama müdürleriyle iletiþim kurulanlarýn kategorileri nelerdir?

Select p.ProductName,c.CategoryName,s.CompanyName ShipCompany,e.FirstName+' '+e.LastName as EmployeeFullName,o.ShipCountry Country,sp.ContactTitle SupplierTittle
From Employees e    join Orders o
					on e.EmployeeID=o.EmployeeID
					join Shippers s
					on o.ShipVia=s.ShipperID
					join [Order Details] od
					on o.OrderID=od.OrderID
					join Products p
					on p.ProductID=od.ProductID
					join Suppliers sp
					on sp.SupplierID=p.SupplierID
					join Categories c
					on c.CategoryID=p.CategoryID
where s.CompanyName in('Speedy Express','United Package') 
and e.EmployeeID=(select ReportsTo from Employees where FirstName='Steven' and LastName='Buchanan')
and o.ShipCountry='USA'
and sp.ContactTitle='Marketing Manager'

--6)Doðu bölgesinden sorumlu çalýþanlar tarafýndan onaylanan sipariþlerdeki Þirket adý “F” ile 
--baþlayan kargo þirketi ile taþýnan ürünleri, sipariþi veren müþteri adýyla birlikte kategorilerine göre 
--sýralayarak raporlayýný

Select e.EmployeeID,ProductName,c.CompanyName,CategoryName
From Territories t join EmployeeTerritories et
					on et.TerritoryID=t.TerritoryID
					join Employees e
					on e.EmployeeID=et.EmployeeID
					join Orders o
					on o.EmployeeID=o.EmployeeID
					join Shippers s
					on s.ShipperID=o.ShipVia
					join [Order Details] od
					on od.OrderID=o.OrderID
					join Products p
					on p.ProductID=od.ProductID
					join Customers c
					on c.CustomerID=o.CustomerID
					join Categories ct
					on ct.CategoryID=p.CategoryID
where RegionID=1
and s.CompanyName like 'F%'
order by c.CompanyName,ct.CategoryName


--7)Her bir sipariþ kaleminde ürünün kategorisi, hangi kargo þirketi ile gönderildiði, müþteri bilgisi, 
--tedarikçi bilgisi ve hangi çalýþan tarafýndan onaylandýðýný tek bir kolonda bir cümle ile ifade ediniz.
--(10248 id’li sipariþ Dairy Products kategorisindedir. Federal Shipping isimli kargo firmasýyla Vins et alcools 
--Chevalier isimli müþteriye gönderilmiþtir. Cooperativa de Quesos 'Las Cabras' ürünün tedarik edildiði 
--firmadýr.)

select Concat(o.OrderID ,' IDli sipariþ ',ct.CategoryName,' Kategorisindedir.',s.CompanyName, ' isimli kargo firmasýyla ', c.CompanyName,' isimli müþteriye gönderilmiþtir.', sp.CompanyName,', ',p.ProductName , ' ürünün tedarik edildiði firmadýr.')
From Orders o join Shippers s
					on s.ShipperID=o.ShipVia
					join [Order Details] od
					on od.OrderID=o.OrderID
					join Products p
					on p.ProductID=od.ProductID
					join Customers c
					on c.CustomerID=o.CustomerID
					join Categories ct
					on ct.CategoryID=p.CategoryID
					join Suppliers sp
					on sp.SupplierID=p.SupplierID

--8)Çalýþanlarým kaç bölgeden sorumludur? Sorumlu olduðu bölge sayýsý en çok olan çalýþaným 
--kimdir? (2 sorgu)

select et.EmployeeID,e.FirstName+' '+e.LastName FullName,Count(TerritoryID)TerritoryCount
from EmployeeTerritories et join Employees e
							on et.EmployeeID=e.EmployeeID
Group by et.EmployeeID,e.FirstName+' '+e.LastName

select top 1 et.EmployeeID,e.FirstName+' '+e.LastName FullName,Count(TerritoryID)TerritoryCount
from EmployeeTerritories et join Employees e
							on et.EmployeeID=e.EmployeeID
Group by et.EmployeeID,e.FirstName+' '+e.LastName
order by TerritoryCount desc

--9)01-01-1996 ile 01.01.1997 tarihleri arasýnda en fazla(adet anlamýnda) hangi ürün satýlmýþtýr
Select top 1 p.ProductName,sum(Quantity)TotalSales
From Orders o join [Order Details] od
				on o.OrderID=od.OrderID
				join Products p
				on p.ProductID=od.ProductID
where OrderDate between '01-01-1996' and '01-01-1997'
Group by p.ProductName
Order by TotalSales desc

--10)En çok hangi kargo þirketi ile gönderilen sipariþlerde gecikme olmuþtur? Þirketin adý ve 
--geciken sipariþ sayýsýný listeleyiniz.

Select top 1 s.CompanyName,Count(OrderID)DelayOrderCount
From Orders o join Shippers s
				on o.ShipVia=s.ShipperID
Where DATEDIFF(day,ShippedDate,RequiredDate)<0
Group by s.CompanyName
Order by DelayOrderCount desc


--11)Steven adlý personelim hangi tedarikçimin ürünlerini satýyor

select s.CompanyName
from Suppliers s
where s.SupplierID in(select p.SupplierID
					From Products p
					where p.ProductID in(select od.ProductID
										from [Order Details] od
										where od.OrderID in(select o.OrderID
															from Orders o
															where o.EmployeeID =(Select e.EmployeeID
																				From Employees e
																				where e.FirstName='Steven'))))


--12) Çalýþanlarýmýn ad soyad bilgileri ile ilgilendikleri bölge adlarýný listeleyini

Select et.TerritoryID,(Select t.TerritoryDescription
					from Territories t
					where t.TerritoryID=et.TerritoryID)TerritoryName,
					(select e.FirstName+' '+e.LastName FullName
					from Employees e
					where et.EmployeeID=e.EmployeeID)EmployeName			
from EmployeeTerritories et
order by TerritoryID

--13)Almanya’ya Federal Shipping ile kargolanmýþ sipariþleri onaylayan çalýþanlarý ve bu çalýþanlarýn 
--hangi bölgede olduklarýný listeleyiniz.

select e.FirstName+' '+e.LastName as FullName,e.Region
from Employees e
where e.EmployeeID in(Select o.EmployeeID
					from Orders o
					where o.ShipCountry='Germany' and o.ShipVia=(select s.ShipperID
																from Shippers s
																Where s.CompanyName='Federal Shipping'))

--14)Seafood ürünlerinden sipariþ gönderilen müþteriler kimlerdir

Select c.CompanyName
from Customers c
where c.CustomerID in(select o.CustomerID
						from Orders o
						where o.OrderID in(select od.OrderID 
											from [Order Details] od
											where od.ProductID in((select p.ProductID
																From Products p
																where p.CategoryID in(Select c.CategoryID
																					from CateGorieS C
																					where c.CategoryName='Seafood')))))


--15)1996 yýlýnda sipariþ vermemiþ müþteriler hangileridir?

select *
from Customers c
where c.CustomerID not in(select o.CustomerID
						from Orders o
						where year(o.OrderDate)='1996')



--16)6. En çok hangi kargo þirketi ile gönderilen sipariþlerde gecikme olmuþtur? Þirketin adý ve geciken 
--sipariþ sayýsýný listeleyen view’ý oluþturunuz.

Go
Create View vw_OrderDelay as
Select top 1 s.CompanyName,Count(OrderID)DelayOrderCount
From Orders o join Shippers s
				on o.ShipVia=s.ShipperID
Where DATEDIFF(day,ShippedDate,RequiredDate)<0
Group by s.CompanyName
Order by DelayOrderCount desc

select *
from vw_OrderDelay
					
--17)	 Tüm personelin sattýðý ürünlerin toplam satýþ adetinin, her bir çalýþanýn kendi toplam satýþ adetine 
--oranýný çalýþan adý soyadýyla birlikte listeleyen view’ý oluþturunuz.
Go
Create view vw_SalesRate as
Select e.FirstName+' '+e.LastName as FullName,
(convert(Decimal(7,2),sum(od.Quantity))/convert(Decimal(7,2),  (Select sum(od.Quantity) from [Order Details] od) ))as SalesRate
from Employees e join Orders o
				on e.EmployeeID=o.EmployeeID
				join [Order Details] od
				on od.OrderID=o.OrderID
Group by e.EmployeeID,e.FirstName+' '+e.LastName 

select * from vw_SalesRate

--18)Çalýþanlarý ve onlarýn yöneticilerini listeleyen view’ý oluþturunuz

Go
Create view vw_EmployeeAndManager as
select e.FirstName+' '+e.LastName as Employee,(Select e2.FirstName+' '+e2.LastName 
												from Employees e2 
												where e.ReportsTo=e2.EmployeeID)as Manager 
from Employees e

select * from vw_EmployeeAndManager

--19)Batý bölgesinden sorumlu olan çalýþanlarýmýn onayladýðý sipariþlerimi view olarak kaydediniz. 
--Ürünlerimin tedarikçilerini listeleyen bir view oluþturunuz. Bu viewleri kullanarak 
--batý bölgesinden sorumlu olan çalýþanlarýmýn onayladýðý sipariþlerimin tedarikçi bilgilerini 
--listeleyiniz.
----------------19.1----------------------
Go
Alter view vw_EmployeeWestern as
Select e.FirstName+' '+e.LastName as Employee,o.OrderID,ProductID
From Territories t join EmployeeTerritories et
					on et.TerritoryID=t.TerritoryID
					join Employees e
					on e.EmployeeID=et.EmployeeID
					join Orders o
					on o.EmployeeID=o.EmployeeID
					join [Order Details] od
					on od.OrderID=o.OrderID
where RegionID=2

select * from vw_EmployeeWestern

 -------------------19.2-------------------

Go
alter view vw_ProductAndSuppliers as
select p.ProductID,p.ProductName,S.CompanyName,ProductID
from Products p join Suppliers s
				on p.SupplierID=s.SupplierID

select * from vw_ProductAndSuppliers

-------------------19.3-------------------

select Employee,OrderID,ProductName,CompanyName
from vw_EmployeeWestern ew join vw_ProductAndSuppliers ps
							on ew.ProductID=ps.ProductID
Group by Employee,OrderID,ProductName,CompanyName




--20)Tedarikçi id’sini parametre alan ve o tedarikçinin saðladýðý 
--ürünlerin yer aldýðý sipariþleri listeleyen stored procedure yapýsýný oluþturunuz.
Go
Create Procedure sp_SuppliersProducts(@SuppId int) as
select od.OrderID,p.ProductName,s.CompanyName
from Suppliers s join Products p
					on s.SupplierID=p.SupplierID
					join [Order Details] od
					on od.ProductID=p.ProductID
where s.SupplierID=@SuppId

exec sp_SuppliersProducts 4
exec sp_SuppliersProducts 17


--21)Girilen iki tarih arasýndaki günler için günlük ciromu veren bir stored procedure oluþturunu
go
Create Procedure sp_DailyCiro(@FirstDate date,@LastDate date) as
select convert(date,o.OrderDate),sum(Quantity*UnitPrice*(1-Discount))Ciro
from Orders o join [Order Details] od
				on o.OrderID=od.OrderID
Group by o.OrderDate
having o.OrderDate between @FirstDate and @LastDate
order by o.OrderDate

exec sp_DailyCiro '1997-07-18','1997-07-23'

--22)Girilen ülke adýna göre hangi tedarikçi firmadan kaç adet ürün alýndýðýný listeleyen stored 
--procedure yapýsýný oluþturunuz.
Go
Alter Procedure sp_SupplierCountryProducts(@Country varchar(100)) as
select s.CompanyName,sum(od.Quantity)TotalAmount
from Suppliers s join Products p
				on s.SupplierID=p.SupplierID
				join [Order Details] od
				on od.ProductID=p.ProductID
Group by s.CompanyName,s.Country
having s.Country=@Country

exec sp_SupplierCountryProducts 'USA'
exec sp_SupplierCountryProducts 'Japan'

--23) Müþterinin en çok sipariþ ettiði 3 ürünü listeleyen stored procedure yapýsýný oluþturun. Parametre 
--olarak müþteri numarasýný alýnýz
Go
Create Procedure sp_CustomerTop3Order(@Customer varchar(100)) as
Select top 3 p.ProductName,sum(Quantity)TotalOrderAmount
from Customers c join Orders o
				on c.CustomerID=o.CustomerID
				join [Order Details] od
				on od.OrderID=o.OrderID
				join Products p
				on p.ProductID=od.ProductID
where c.CompanyName=@Customer
Group by p.ProductName
order by TotalOrderAmount desc

exec sp_CustomerTop3Order 'Ernst Handel'

--24)Parametre olarak ad soyad ve doðum tarihi bilgisini alýp çalýþanlara mail adresi 
--oluþturacak fonksiyonu oluþturunuz.

Create Function Email(@Name varchar(40),@Surname varchar(40),@Birthday date)
returns varchar(100)
as
begin
	declare @CreatedMail varchar(100)
	set @CreatedMail=@Name+'.'+@Surname+convert(varchar(20),@Birthday)+'@northwind.com'
	return @CreatedMail 
end

select dbo.Email('enes','sagban','05-11-1995')

--25)Parametre olarak alýnan müþteri numarasýna göre müþterinin toplam vermiþ olduðu 
--sipariþ sayýsýný geri döndüren fonksiyonu yazýnýz. 

Create Function OrderCounter(@CustID varchar(5))
returns int
as
begin
declare @OrderCount int
select @OrderCount=count(o.OrderID)
from Customers c join Orders o
				on c.CustomerID=o.CustomerID
where c.CustomerID=@CustID
Group by c.CustomerID
return @OrderCount
end

select dbo.OrderCounter('ALFKI')
select dbo.OrderCounter('ANATR')

create function awsd(@id nchar(5))
returns int 
as
begin
declare @siparýssayýsý int
select  @siparýssayýsý= count(o.OrderID) from orders o where o.CustomerID=@id group by CustomerID 
return @siparýssayýsý
end 
select dbo.awsd('ALFKI')

--26)Girdi olarak sipariþ numarasý alýp sipariþin hangi müþteriye, hangi kargo þirketiyle, hangi 
--çalýþan tarafýndan gönderildiðini ve gönderilen ürünlerin kaçar adet olduðunu ürünlerin 
--adý ile birlikte listeleyen fonksiyonu yazýnýz.

Create Function OrderProductQuantity(@OrderID int)
returns table
as
return
select c.CompanyName as CustomerCompany,s.CompanyName as ShipperCompany,e.FirstName+' '+e.LastName as Employee,p.ProductName,od.Quantity
From Orders o join Shippers s
					on s.ShipperID=o.ShipVia
					join [Order Details] od
					on od.OrderID=o.OrderID
					join Products p
					on p.ProductID=od.ProductID
					join Customers c
					on c.CustomerID=o.CustomerID
					join Categories ct
					on ct.CategoryID=p.CategoryID
					join Suppliers sp
					on sp.SupplierID=p.SupplierID
					join Employees e
					on e.EmployeeID=O.EmployeeID
where o.OrderID=@OrderID

Select * from OrderProductQuantity(10248)

--27)0 ile 100 arasýndaki asal sayýlarý print eden sql sorgusunu yazýnýz.

Declare @AsalKontrol int=2
Declare @Bolen int=1
Declare @counter int=0
while (@AsalKontrol < 100)
begin 
		while(@Bolen<=@AsalKontrol)
		begin
			if(@AsalKontrol % @Bolen=0)
			begin
				set @counter+=1
			end
			set @Bolen+=1
		end
		if(@counter<=2)
		begin
			print (@AsalKontrol)
		end
		set @Bolen =1
		set @counter =0
		set @AsalKontrol+=1
end

