CREATE DATABASE CustomerAnalytics;
GO

USE CustomerAnalytics;
GO

CREATE TABLE dbo.CustomerChurn (
    customer_id        BIGINT        NOT NULL PRIMARY KEY,
    credit_score       INT           NOT NULL,
    country            VARCHAR(50)   NOT NULL,
    gender             VARCHAR(10)   NOT NULL,
    age                INT           NOT NULL,
    tenure             INT           NOT NULL,
    balance            DECIMAL(15,2) NOT NULL,
    products_number    INT           NOT NULL,
    credit_card        BIT           NOT NULL,
    active_member      BIT           NOT NULL,
    estimated_salary   DECIMAL(15,2) NOT NULL,
    churn              BIT           NOT NULL
);


SELECT * FROM dbo.CustomerChurn;


-- Distribución de churn por país 
SELECT 
    country,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN churn = 0 THEN 1 ELSE 0 END) AS active_customers
FROM dbo.CustomerChurn
GROUP BY country
ORDER BY churned_customers DESC;


SELECT 
    geo.GEO_NOMBRE AS Pais,
    COUNT(*) AS TotalClientes,
    SUM(CASE WHEN c.ABANDONO = 1 THEN 1 ELSE 0 END) AS ClientesChurn,
    SUM(CASE WHEN c.ABANDONO = 0 THEN 1 ELSE 0 END) AS ClientesRetenidos
FROM CLIENTE c
INNER JOIN GEOGRAFIA geo ON c.GEOGRAFIA_ID = geo.GEOGRAFIA_ID
GROUP BY geo.GEO_NOMBRE
ORDER BY ClientesChurn DESC;

-- Análisis de churn por generación (Baby Boomers, X, Millennials y Z) 
SELECT
    CASE
        WHEN age >= 60 THEN 'Baby Boomers'
        WHEN age BETWEEN 44 AND 59 THEN 'Generación X'
        WHEN age BETWEEN 28 AND 43 THEN 'Millennials'
        ELSE 'Generación Z'
    END AS generation,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers
FROM dbo.CustomerChurn
GROUP BY
    CASE
        WHEN age >= 60 THEN 'Baby Boomers'
        WHEN age BETWEEN 44 AND 59 THEN 'Generación X'
        WHEN age BETWEEN 28 AND 43 THEN 'Millennials'
        ELSE 'Generación Z'
    END
ORDER BY total_customers DESC;


SELECT
    CASE
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) >= 60 THEN 'Baby Boomers'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 44 AND 59 THEN 'Generación X'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 28 AND 43 THEN 'Millennials'
        ELSE 'Generación Z'
    END AS generacion,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN c.ABANDONO = 1 THEN 1 ELSE 0 END) AS clientes_churn
FROM CLIENTE c
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) >= 60 THEN 'Baby Boomers'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 44 AND 59 THEN 'Generación X'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 28 AND 43 THEN 'Millennials'
        ELSE 'Generación Z'
    END
ORDER BY total_clientes DESC;



-- Historial de productos por cliente
SELECT customer_id, products_number
FROM dbo.CustomerChurn
ORDER BY products_number DESC;

SELECT CLIENTE_ID, PRODUCTOS
FROM CLIENTE
ORDER BY PRODUCTOS DESC;



-- Conteo de clientes totales, activos, por año de tenure (antigüedad en con el banco)
SELECT
    tenure AS years_with_bank,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 0 THEN 1 ELSE 0 END) AS active_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers
FROM dbo.CustomerChurn
GROUP BY tenure
ORDER BY tenure;


SELECT
    DATEDIFF(YEAR, FECHA_DE_REGISTRO, GETDATE()) AS años_antigüedad,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN ABANDONO = 0 THEN 1 ELSE 0 END) AS clientes_activos,
    SUM(CASE WHEN ABANDONO = 1 THEN 1 ELSE 0 END) AS clientes_churn
FROM CLIENTE
GROUP BY DATEDIFF(YEAR, FECHA_DE_REGISTRO, GETDATE())
ORDER BY años_antigüedad;



-- Cuántos clientes inactivos tenían tarjeta de crédito
SELECT
    country,
    gender,
    COUNT(*) AS inactive_with_credit_card
FROM dbo.CustomerChurn
WHERE active_member = 0
  AND credit_card = 1
GROUP BY country, gender
ORDER BY inactive_with_credit_card DESC;

SELECT
    COUNT(*) AS inactive_with_credit_card
FROM dbo.CustomerChurn
WHERE active_member = 0
    AND credit_card = 1;


SELECT
    COUNT(*) AS clientes_inactivos_con_tarjeta
FROM CLIENTE
WHERE MIEMBRO_ACTIVO = 0
  AND TARJETA_DE_CREDITO = 1;


-- Total, de clientes activos e inactivos por país, género y rango de edad 
SELECT
    country,
    gender,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_range,
    SUM(CASE WHEN active_member = 1 THEN 1 ELSE 0 END) AS active_customers,
    SUM(CASE WHEN active_member = 0 THEN 1 ELSE 0 END) AS inactive_customers
FROM dbo.CustomerChurn
GROUP BY
    country,
    gender,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END
ORDER BY country, gender, age_range;



SELECT
    g.GEO_NOMBRE AS pais,
    ge.GEN_NOMBRE AS genero,
    CASE
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 18 AND 25 THEN '18-25'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 26 AND 35 THEN '26-35'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS rango_edad,
    SUM(CASE WHEN c.MIEMBRO_ACTIVO = 1 THEN 1 ELSE 0 END) AS clientes_activos,
    SUM(CASE WHEN c.MIEMBRO_ACTIVO = 0 THEN 1 ELSE 0 END) AS clientes_inactivos
FROM CLIENTE c
INNER JOIN GEOGRAFIA g ON c.GEOGRAFIA_ID = g.GEOGRAFIA_ID
INNER JOIN GENERO ge ON c.GENERO_ID = ge.GENERO_ID
GROUP BY
    g.GEO_NOMBRE,
    ge.GEN_NOMBRE,
    CASE
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 18 AND 25 THEN '18-25'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 26 AND 35 THEN '26-35'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
        WHEN DATEDIFF(YEAR, c.FECHA_NACIMIENTO, GETDATE()) BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END
ORDER BY pais, genero, rango_edad;



