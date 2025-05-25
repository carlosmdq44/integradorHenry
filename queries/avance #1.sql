#📊Análisis de Ventas - Proyecto Integrador

###🎯 Preguntas Parte 1:
>¿Cuáles fueron los 5 productos más vendidos (por cantidad total)?

create procedure top_n_productos_vendidos(in n INT)
begin
select ProductID,
       SUM(Quantity) as total_vendido
from sales
group by ProductID
order by total_vendido desc limit n;
end

call top_n_productos_vendidos(5);

>¿Cuál fue el vendedor que más unidades vendió de cada uno?

create procedure vendedor_top_por_producto()
begin
select product_id,
       salesperson_id,
       total_vendido
from (select ProductID     as product_id,
             SalespersonID as salesperson_id,
             SUM(Quantity) as total_vendido,
             rank()           over (partition by ProductID
	order by
		SUM(Quantity) desc) as pos
      from sales
      group by ProductID,
               SalespersonID) as ranked
where pos = 1;
end;

call vendedor_top_por_producto();

###📈Análisis
>¿Hay algún vendedor que aparece más de una vez como el que más vendió un producto?

SELECT salesperson_id,
       COUNT(*) AS veces_top
FROM (SELECT ProductID     AS product_id,
             SalespersonID AS salesperson_id,
             SUM(Quantity) AS total_vendido,
             RANK()           OVER (PARTITION BY ProductID ORDER BY SUM(Quantity) DESC) AS pos
      FROM sales
      GROUP BY ProductID, SalespersonID) AS ranked
WHERE pos = 1
GROUP BY salesperson_id
HAVING COUNT(*) > 1;

>¿Algunos de estos vendedores representan más del 10% de la ventas de este producto?

SELECT top.product_id,
       top.salesperson_id,
       top.total_vendido,
       tot.total_producto,
       (top.total_vendido / tot.total_producto) AS porcentaje
FROM (
         SELECT ProductID     AS product_id,
                SalespersonID AS salesperson_id,
                SUM(Quantity) AS total_vendido,
                RANK()           OVER (
      PARTITION BY ProductID
      ORDER BY SUM(Quantity) DESC
    ) AS pos
         FROM sales
         GROUP BY ProductID, SalespersonID) AS top
         JOIN (
    SELECT ProductID,
           SUM(Quantity) AS total_producto
    FROM sales
    GROUP BY ProductID) AS tot
              ON top.product_id = tot.ProductID
WHERE top.pos = 1
  AND (top.total_vendido / tot.total_producto) > 0.10;
