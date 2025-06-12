-- AVANCE PRACTICA PARTE 1
use sales_company;
--                       EJERCICIO 1 a

/* ------------------------------------------------------------------
                 Identificar los 5 productos más vendidos
   ------------------------------------------------------------------*/

with productos_top5 as (
select
	ProductID,
	SUM(Quantity) as cantidad_total
from
	sales
group by
	ProductID
order by
	cantidad_total desc
limit 5
),
-- Paso 2: Obtener ventas por producto y vendedor
ventas_detalle as (
select
	s.ProductID,
	s.SalesPersonID,
	SUM(s.Quantity) as total_vendido
from
	sales s
inner join productos_top5 p on
	s.ProductID = p.ProductID
group by
	s.ProductID,
	s.SalesPersonID
),
-- Paso 3: Ranquear vendedor top por producto
vendedores_top as (
select
	ProductID,
	SalesPersonID,
	total_vendido,
	rank() over (partition by ProductID
order by
	total_vendido desc) as pos
from
	ventas_detalle
)

-- Resultado final con nombre del vendedor
select
	vt.ProductID,
	pr.ProductName,
	vt.SalesPersonID,
	CONCAT(e.FirstName, ' ', e.LastName) as Vendedor,
	vt.total_vendido,
	pt.cantidad_total,
	ROUND(vt.total_vendido * 100.0 / pt.cantidad_total, 2) as porcentaje_venta
from
	vendedores_top vt
join productos_top5 pt on
	vt.ProductID = pt.ProductID
join products pr on
	pr.ProductID = vt.ProductID
join employees e on
	e.EmployeeID = vt.SalesPersonID
where
	vt.pos = 1;
-- 9.751s
-- 5.6 Optimización

--                       EJERCICIO 1 B

    /* ------------------------------------------------------------------
                 Top-5 productos por unidades
   ------------------------------------------------------------------*/

with productos_top5 as (
select
	ProductID,
	SUM(Quantity) as total_unidades
from
	sales
group by
	ProductID
order by
	total_unidades desc
limit 5
),

/* Paso 2: clientes únicos que compraron cada producto del Top-5 */

clientes_por_producto as (
select
	s.ProductID,
	COUNT(distinct s.CustomerID) as clientes_unicos
from
	sales s
where
	s.ProductID in (
	select
		ProductID
	from
		productos_top5)
group by
	s.ProductID
),

/* Paso 3: total de clientes que hicieron al menos una compra */

total_clientes as (
select
	COUNT(distinct CustomerID) as total
from
	sales
)

/* Resultado final */
select
	pr.ProductID,
	pr.ProductName,
	cpp.clientes_unicos,
	tc.total,
	ROUND(cpp.clientes_unicos * 100.0 / tc.total, 2) as porcentaje_clientes
from
	clientes_por_producto cpp
join products pr on
	pr.ProductID = cpp.ProductID
cross join total_clientes tc
order by
	porcentaje_clientes desc;

-- 10seg
-- 5.7 optimizado