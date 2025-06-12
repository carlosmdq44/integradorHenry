--                       EJERCICIO 2

-- Paso 1: Total de ventas por producto, con su categoría

with ventas_por_producto as (
select
	s.ProductID,
	p.ProductName,
	p.CategoryID,
	c.CategoryName,
	SUM(s.Quantity) as unidades_producto
from
	sales s
join products p on
	s.ProductID = p.ProductID
join categories c on
	p.CategoryID = c.CategoryID
group by
	s.ProductID,
	p.ProductName,
	p.CategoryID,
	c.CategoryName
),
-- Paso 2: Agrego total por categoría y ranking global
ventas_con_porcentaje as (
select
	ProductID,
	ProductName,
	CategoryID,
	CategoryName,
	unidades_producto,
	SUM(unidades_producto) over (partition by CategoryID) as total_categoria,
	rank() over (
	order by unidades_producto desc) as ranking_global
from
	ventas_por_producto
)
-- Paso 3: Selecciono solo los 5 más vendidos y calculo proporción dentro de su categoría
select
	ProductID,
	ProductName,
	CategoryName,
	unidades_producto,
	total_categoria,
	ROUND(unidades_producto * 100.0 / total_categoria, 2) as porcentaje_categoria
from
	ventas_con_porcentaje
where
	ranking_global <= 5
order by
	porcentaje_categoria desc;
-- 11segundos
-- 6.8segundos

/* ------------------------------------------------------------------
   TOP-10 productos del catálogo y su ranking dentro de la categoría
   ------------------------------------------------------------------*/

with unidades_por_producto as (
select
	s.ProductID,
	p.ProductName,
	p.CategoryID,
	c.CategoryName,
	SUM(s.Quantity) as unidades_vendidas
from
	sales s
join products p on
	p.ProductID = s.ProductID
join categories c on
	c.CategoryID = p.CategoryID
group by
	s.ProductID,
	p.ProductName,
	p.CategoryID,
	c.CategoryName
),
-- Le asignamos ranking DENTRO de cada categoría
ranking_en_categoria as (
select
	*,
	rank() over (partition by CategoryID
order by
	unidades_vendidas desc) as rank_categoria
from
	unidades_por_producto
)
-- Resultado final: los 10 más vendidos del catálogo
select
	ProductID,
	ProductName,
	CategoryName,
	unidades_vendidas,
	rank_categoria
from
	ranking_en_categoria
order by
	unidades_vendidas desc
limit 10;
-- 12 seg
-- 8 seg optimizado

    /* ------------------------------------------------------------------
                 OPTIMIZACIÓN DATOS Parte 2
   ------------------------------------------------------------------*/
create table monitoreo_productos (
 ID INT auto_increment primary key,
 productId INT,
 ProductName VARCHAR(50),
 TotalVendido INT,
 FechaRegistro DATETIME default CURRENT_TIMESTAMP
);
DELIMITER

create trigger log_productos
after
insert
	on
	sales
for each row
begin
    declare total INT;
-- Calculamos el total de ventas acumuladas del producto
    select
	SUM(quantity)
    into
	total
from
	sales
where
	ProductID = NEW.ProductID;
-- Si supera 200.000 unidades y no está ya registrado, insertamos en monitoreo
    if total > 200000
and not exists (
select
	1
from
	monitoreo_productos
where
	ProductID = NEW.ProductID
    ) then
        insert
	into
	monitoreo_productos (ProductID,
	ProductName,
	TotalVendido)
        select
	p.ProductID,
	p.ProductName,
	total
from
	products p
where
	p.ProductID = NEW.ProductID;
end if;
end;
DELIMITER ;

insert
	into
	sales (
SalesID,
	SalesPersonID,
	CustomerID,
	ProductID,
	Quantity,
	Discount,
	TotalPrice,
	SalesDate,
	TransactionNumber
)
values (
99999999,
9,
84,
103,
300000,
0.00,
1200.00,
NOW(),
'TX302010'
);


CREATE INDEX idx_sales_product_vendedor_qty ON sales(ProductID, SalesPersonID, Quantity);

CREATE INDEX idx_sales_product_cliente ON sales(ProductID, CustomerID);