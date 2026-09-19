/* ==========================================================================
   PROYECTO INTEGRADOR: RetailPro / Ventas_Tech_DB
   MÓDULO 5: Consultas con JOINs y UNION
   Archivo: m5_consultas_joins.sql
   ========================================================================== */

USE Ventas_Tech_DB;
GO

-- --------------------------------------------------------------------------
-- 0. DATOS DE CONTROL: Asegurar registros para validar los LEFT JOINs
-- (Inserta 1 cliente y 1 producto calculando el próximo ID numérico manual)
-- --------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM clientes WHERE email = 'cliente.nuevo@test.com')
BEGIN
    DECLARE @nuevo_id_cliente INT = (SELECT ISNULL(MAX(id_cliente), 0) + 1 FROM clientes);
    INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
    VALUES (@nuevo_id_cliente, 'Lucas Benítez', 'cliente.nuevo@test.com', 'CABA', '2024-03-20');
END;

IF NOT EXISTS (SELECT 1 FROM productos WHERE nombre_producto = 'Soporte Monitor Ergonómico')
BEGIN
    DECLARE @nuevo_id_producto INT = (SELECT ISNULL(MAX(id_producto), 0) + 1 FROM productos);
    INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
    VALUES (@nuevo_id_producto, 'Soporte Monitor Ergonómico', 3, 28000.00, 15, 1);
END;
GO


-- ==========================================================================
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Cruza ventas con clientes, productos y categorías en una sola fila.
-- ==========================================================================
SELECT 
    v.id_venta,
    v.fecha_venta,
    c.nombre AS cliente,
    c.ciudad AS region_cliente,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c 
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p 
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat 
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta ASC, v.id_venta ASC;
GO


-- ==========================================================================
-- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
-- Detecta clientes registrados que nunca realizaron una compra.
-- ==========================================================================
SELECT 
    c.id_cliente,
    c.nombre AS cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v 
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro DESC;
GO


-- ==========================================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN)
-- Detecta artículos del catálogo que no tienen movimiento comercial.
-- ==========================================================================
SELECT 
    p.id_producto,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    p.precio,
    p.stock
FROM productos AS p
INNER JOIN categorias AS cat 
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v 
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto ASC;
GO


-- ==========================================================================
-- CONSULTA 4: Consolidado por canal (UNION ALL + GROUP BY)
-- Clasifica ventas en 'Presencial' (>= $500) y 'Online' (< $500),
-- apila ambos orígenes y consolida métricas totales por canal.
-- ==========================================================================
WITH VentasPorCanal AS (
    -- Subconjunto 1: Ventas asignadas a canal Presencial
    SELECT 
        id_venta,
        fecha_venta,
        (cantidad * precio_unitario) AS total_venta,
        'Presencial' AS canal
    FROM ventas
    WHERE (cantidad * precio_unitario) >= 500.00

    UNION ALL

    -- Subconjunto 2: Ventas asignadas a canal Online
    SELECT 
        id_venta,
        fecha_venta,
        (cantidad * precio_unitario) AS total_venta,
        'Online' AS canal
    FROM ventas
    WHERE (cantidad * precio_unitario) < 500.00
)
SELECT 
    canal,
    COUNT(*) AS cantidad_operaciones,
    SUM(total_venta) AS facturacion_total,
    AVG(total_venta) AS ticket_promedio
FROM VentasPorCanal
GROUP BY canal
ORDER BY facturacion_total DESC;
GO