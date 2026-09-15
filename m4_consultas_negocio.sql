SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);
SELECT TOP 5 
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1;
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    CASE 
        WHEN SUM(cantidad * precio_unitario) >= (
            SELECT AVG(total_mes)
            FROM (
                SELECT SUM(cantidad * precio_unitario) AS total_mes
                FROM ventas
                GROUP BY MONTH(fecha_venta)
            ) AS subconsulta
        ) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparativa_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);

HALLAZGO 1: Alta concentración de ingresos en un único producto.
El id_producto 1 lidera ampliamente la recaudación con $3.600,00, concentrando
el 55,86% de la facturación total del mes ($6.444,00) con solo 3 unidades vendidas.

HALLAZGO 2: Divergencia entre volumen físico e impacto monetario.
El id_producto 2 es el de mayor rotación operativa con 13 unidades vendidas
(44,8% del total de unidades del negocio), pero al tener un ticket unitario bajo,
aporta únicamente el 5,64% de la recaudación ($364,00).

HALLAZGO 3: Cartera 100% recurrente con concentración tipo Pareto.
Todos los clientes registrados (5 de 5) presentan recurrencia con exactamente 
2 pedidos cada uno. Además, los clientes 1 ($2.640,00) y 5 ($2.100,00) generan
en conjunto el 73,55% de los ingresos totales de la empresa.