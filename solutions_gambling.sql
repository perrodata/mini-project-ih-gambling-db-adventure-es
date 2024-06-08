USE gambling;

-- Pregunta 01: 
-- Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre Título, Nombre y Apellido y Fecha de Nacimiento para cada uno de los clientes. 
-- No necesitarás hacer nada en Excel para esta.

SELECT 
    Title 'Título',
    FirstName Nombre,
    LastName Apellido,
    DateOfBirth 'Fecha de nacimiento'
FROM
    customer;
    
 -- Pregunta 02: 
 -- Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre el número de clientes en cada grupo de clientes (Bronce, Plata y Oro). 
 -- Puedo ver visualmente que hay 4 Bronce, 3 Plata y 3 Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?   
 
SELECT 
    CASE
        WHEN LOWER(CustomerGroup) LIKE 'bronze' THEN 'Bronce'
        WHEN LOWER(CustomerGroup) LIKE 'silver' THEN 'Plata'
        WHEN LOWER(CustomerGroup) LIKE 'gold' THEN 'Oro'
    END AS Grupo_de_cliente,
    COUNT(*) 'Total Clientes'
FROM
    customer
GROUP BY Grupo_de_cliente;

-- Pregunta 03: 
-- El gerente de CRM me ha pedido que proporcione una lista completa de todos los datos para esos clientes en la tabla de clientes
-- pero necesito añadir el código de moneda de cada jugador para que pueda enviar la oferta correcta en la moneda correcta. 
-- Nota que el código de moneda no existe en la tabla de clientes sino en la tabla de cuentas.
-- Por favor, escribe el SQL que facilitaría esto. ¿Cómo lo haría en Excel si tuviera un conjunto de datos mucho más grande?
 
SELECT 
    T1.*, T2.CurrencyCode
FROM
    customer AS T1
        JOIN
    account T2 ON T1.CustId = T2.CustId;

-- Pregunta 04: 
-- Ahora necesito proporcionar a un gerente de producto un informe resumen que muestre, por producto y por día, cuánto dinero se ha apostado en un producto particular. 
-- TEN EN CUENTA que las transacciones están almacenadas en la tabla de apuestas 
-- y hay un código de producto en esa tabla que se requiere buscar (classid & categoryid) 
-- para determinar a qué familia de productos pertenece esto.
-- Por favor, escribe el SQL que proporcionaría el informe. 
-- Si imaginas que esto fue un conjunto de datos mucho más grande en Excel, ¿cómo proporcionarías este informe en Excel?

SELECT 
    T2.product AS Producto,
    DATE(T1.betdate) Fecha,
    SUM(T1.Bet_amt) AS 'Total Apostado'
FROM
    betting AS T1
        JOIN
    product AS T2 ON (T1.ClassId = T2.CLASSID
        AND T1.CATEGORYID = T2.CategoryId)
GROUP BY T2.product , T1.betdate
ORDER BY T1.betdate , T2.product;


-- Pregunta 05:
-- Acabas de proporcionar el informe de la pregunta 4 al gerente de producto, ahora él me ha enviado un correo electrónico y quiere que se cambie. 
-- ¿Puedes por favor modificar el informe resumen para que solo resuma las transacciones que ocurrieron el 1 de noviembre o después y solo quiere ver transacciones de Sportsbook. 
-- Nuevamente, por favor escribe el SQL abajo que hará esto. 
-- Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?

SELECT 
    T2.product AS Producto,
    DATE(T1.betdate) Fecha,
    SUM(T1.Bet_amt) AS 'Total Apostado'
FROM
    betting AS T1
        JOIN
    product AS T2 ON (T1.ClassId = T2.CLASSID
        AND T1.CATEGORYID = T2.CategoryId)
WHERE
    LOWER(T2.product) LIKE 'sportsbook'
        AND DATE(T1.betdate) >= '2012-11-01'
GROUP BY T2.product , T1.betdate
ORDER BY T1.betdate , T2.product;


-- Pregunta 06: 
-- Como suele suceder, el gerente de producto ha mostrado su nuevo informe a su director y ahora él también quiere una versión diferente de este informe. 
-- Esta vez, quiere todos los productos pero divididos por el código de moneda y el grupo de clientes del cliente, en lugar de por día y producto. 
-- También le gustaría solo transacciones que ocurrieron después del 1 de diciembre. Por favor, escribe el código SQL que hará esto.

SELECT 
    T1.product AS Producto,
    T2.CurrencyCode AS Moneda,
    T3.CustomerGroup AS Grupo,
    SUM(T1.Bet_amt) AS 'Total Apostado'
FROM
    betting AS T1
        JOIN
    account AS T2 ON T1.AccountNo = T2.AccountNo
        JOIN
    customer AS T3 ON T2.CustId = T3.CustId
WHERE
    DATE(T1.betdate) >= '2012-12-01'
GROUP BY T1.product , T2.CurrencyCode , t3.CustomerGroup
ORDER BY T1.product;

-- Pregunta 07: 
-- Nuestro equipo VIP ha pedido ver un informe de todos los jugadores independientemente de si han hecho algo en el marco de tiempo completo o no. 
-- En nuestro ejemplo, es posible que no todos los jugadores hayan estado activos. 
-- Por favor, escribe una consulta SQL que muestre a todos los jugadores Título, Nombre y Apellido y un resumen de su cantidad de apuesta para el período completo de noviembre.

SELECT 
    T3.Title AS Titulo,
    T3.FirstName AS Nombre,
    T3.LastName AS Apellido,
    SUM(T1.Bet_amt) AS Total_Apostado
FROM
    betting AS T1
        left JOIN
    account AS T2 ON T1.AccountNo = T2.AccountNo
        left JOIN
    customer AS T3 ON T2.CustId = T3.CustId
WHERE
    DATE(T1.betdate) BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY T3.Title , T3.FirstName , T3.LastName
ORDER BY Total_Apostado;

-- Pregunta 08: Nuestros equipos de marketing y CRM quieren medir el número de jugadores que juegan más de un producto. 
-- ¿Puedes por favor escribir 2 consultas, una que muestre el número de productos por jugador y otra que muestre jugadores que juegan tanto en Sportsbook como en Vegas?

-- Consulta 1:
SELECT	T3.FirstName,
		T3.LastName,
        sub.Total_Productos
FROM Customer as T3
    JOIN ( SELECT T2.CustId,
			count(distinct T1.Product) as Total_Productos
    FROM Betting as T1
    JOIN Account as T2
    ON T1.AccountNo = T2.AccountNo
    WHERE T1.Product <>  '0'
    GROUP BY  T2.CustId 
    HAVING count(distinct T1.Product)>1
    ) sub
    ON T3.CustId = sub.CustId
ORDER BY Total_Productos;


-- Consulta 02:

SELECT
    T3.FirstName,
    T3.LastName,
    sub.Total_Productos
FROM Customer as T3
JOIN (
    SELECT 
        T2.CustId,
        COUNT(DISTINCT T1.Product) as Total_Productos
    FROM Betting as T1
    JOIN Account as T2
    ON T1.AccountNo = T2.AccountNo
    WHERE T1.Product IN ('Sportsbook', 'Vegas')
    GROUP BY T2.CustId
    HAVING count(distinct T1.Product)>1
) sub
ON T3.CustId = sub.CustId
ORDER BY sub.Total_Productos;

-- Pregunta 09: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo juegan un producto, por favor escribe código SQL que muestre a los jugadores que solo juegan en sportsbook, usa bet_amt > 0 como la clave. Muestra cada jugador y la suma de sus apuestas para ambos productos.
SELECT 
    T3.Title, 
    T3.FirstName, 
    T3.LastName, 
    sub.Monto_apostado
FROM
    Customer AS T3
        JOIN
    (SELECT 
        T2.CustId,
            COUNT(DISTINCT T1.Product) AS Monto_producto,
            MAX(T1.Product) AS Producto,
            SUM(T1.Bet_amt) AS Monto_apostado
    FROM
        Betting AS T1
    JOIN Account AS T2 ON T1.AccountNo = T2.AccountNo
    WHERE
        T1.Product <> '0'
    GROUP BY T2.CustId
    HAVING COUNT(DISTINCT T1.Product) = 1) sub ON T3.CustId = sub.CustId
WHERE
    sub.Producto = 'Sportsbook'
ORDER BY sub.Monto_producto DESC;

-- Pregunta 10: 
-- La última pregunta requiere que calculemos y determinemos el producto favorito de un jugador. 
-- Esto se puede determinar por la mayor cantidad de dinero apostado. 
-- Por favor, escribe una consulta que muestre el producto favorito de cada jugador

WITH ranked AS (
    SELECT
        T2.CustId,
        T3.Title,
        T3.FirstName,
        T3.LastName,
        T1.Product,
        SUM(T1.Bet_amt) AS Total_Apostado,
        ROW_NUMBER() OVER (PARTITION BY T2.CustId ORDER BY SUM(T1.Bet_amt) DESC) AS rn
    FROM Betting AS T1
    JOIN Account AS T2 ON T1.AccountNo = T2.AccountNo
    JOIN Customer AS T3 ON T2.CustId = T3.CustId
    GROUP BY T2.CustId, T3.Title, T3.FirstName, T3.LastName, T1.Product
)
SELECT
    Title,
    FirstName,
    LastName,
    Product,
    Total_Apostado
FROM ranked
WHERE rn = 1; 