-- -- -- -- -- -- --
-- DATA EXTRACCION --
-- -- -- -- -- -- --

-- Crear base de datos

CREATE DATABASE BDBECA18;
GO

USE BDBECA18;
GO

---------------------------------
-- CARGA TABLAS
---------------------------------

-- APTOS - Crear Tabla Postulantes Aptos

CREATE TABLE aptos (
    N INT,
    MODALIDAD VARCHAR(100),
    DNI VARCHAR(8) PRIMARY KEY,
    NOMBRES VARCHAR(150),
    RESULTADO VARCHAR(20)
);

BULK INSERT aptos
FROM 'G:\SQL\Proyecto Beca 18\aptos.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

SELECT*FROM aptos

-- Validación de que no haya DUplicados

SELECT DNI, COUNT(*)
FROM aptos
GROUP BY DNI
HAVING COUNT(*) > 1;

/*
No hay duplicados, se han extraido correctamente los datos.
*/

-- PRESELECCIONADOS - Crear Tabla Postulantes Preseleccionados

CREATE TABLE preseleccionados_tmp (
	N INT,
	MODALIDAD VARCHAR(100),
    DNI VARCHAR(20),
    NOMBRES VARCHAR(250),
    REGION VARCHAR(250),
    PUNTAJE_ENP VARCHAR(50),
    CONDICIONES VARCHAR(50),
    PUNTAJE_FINAL VARCHAR(50),
    RESULTADO VARCHAR(30)
);

BULK INSERT preseleccionados_tmp
FROM 'G:\SQL\Proyecto Beca 18\preseleccionados.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

CREATE TABLE preseleccionados (
    N INT,
	MODALIDAD VARCHAR(100),
	DNI VARCHAR(8) PRIMARY KEY,
    NOMBRES VARCHAR(150),
    REGION VARCHAR(100),
    PUNTAJE_ENP INT,
    CONDICIONES INT,
    PUNTAJE_FINAL INT,
    RESULTADO VARCHAR(30)
);


INSERT INTO preseleccionados
SELECT
    N,
	MODALIDAD,
	DNI,
    NOMBRES,
    REGION,
    TRY_CAST(PUNTAJE_ENP AS INT),
    TRY_CAST(CONDICIONES AS INT),
    TRY_CAST(PUNTAJE_FINAL AS INT),
    RESULTADO
FROM preseleccionados_tmp;

-- Validación de que no haya DUplicados

SELECT DNI, COUNT(*)
FROM preseleccionados
GROUP BY DNI
HAVING COUNT(*) > 1;

/*
No hay duplicados, se han extraido correctamente los datos.
*/

-- SELECCIONADOS - Crear tabla Selecionados final, donde se consolida los dos momentos de postulación

CREATE TABLE seleccionados (
    DNI VARCHAR(8),
    NOMBRES VARCHAR(150),
    MODALIDAD VARCHAR(100),
    IES VARCHAR(150),
    SEDE VARCHAR(100),
    CARRERA VARCHAR(150),
    CONCEPTO_A FLOAT,
    CONCEPTO_B FLOAT,
    PUNTAJE_FINAL FLOAT,
    CONDICION VARCHAR(30),
    MOMENTO VARCHAR(20)
);

INSERT INTO seleccionados
SELECT 
    CAST(CAST(DNI AS BIGINT) AS VARCHAR(8)) AS DNI,
    NOMBRES,
    MODALIDAD,
    IES,
    SEDE,
    CARRERA,
    CONCEPTO_A,
    CONCEPTO_B,
    PUNTAJE_FINAL,
    CONDICION,
    'PRIMER_MOMENTO'
FROM seleccionados_1

UNION ALL

SELECT 
    CAST(CAST(DNI AS BIGINT) AS VARCHAR(8)),
    NOMBRES,
    MODALIDAD,
    IES,
    SEDE,
    CARRERA,
    CONCEPTO_A,
    CONCEPTO_B,
    PUNTAJE_FINAL,
    CONDICION,
    'SEGUNDO_MOMENTO'
FROM seleccionados_2;

-- Validación de que no haya DUplicados

SELECT DNI, COUNT(*)
FROM seleccionados
GROUP BY DNI
HAVING COUNT(*) > 1;

/*
Se evidencian duplicados, lo que demustra que hay postulantes que han cambiado de carrea o universidad de un moemto a otro.
*/


-- Tabla de postulantes selcionados final - despues de quitar el registro anterior de los que cambiaron de carrera, universidad.

CREATE TABLE seleccionados_final (
    DNI VARCHAR(8),
    NOMBRES VARCHAR(150),
    MODALIDAD VARCHAR(100),
    IES VARCHAR(150),
    SEDE VARCHAR(100),
    CARRERA VARCHAR(150),
    CONCEPTO_A FLOAT,
    CONCEPTO_B FLOAT,
    PUNTAJE_FINAL FLOAT,
    CONDICION VARCHAR(30),
    MOMENTO VARCHAR(20)
);

SELECT *
INTO seleccionados_final
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY DNI 
               ORDER BY 
                   CASE 
                       WHEN MOMENTO = 'SEGUNDO_MOMENTO' THEN 2
                       ELSE 1
                   END DESC
           ) AS rn
    FROM seleccionados

) t
WHERE rn = 1;

-- Validación de que no haya DUplicados

SELECT DNI, COUNT(*)
FROM seleccionados_final
GROUP BY DNI
HAVING COUNT(*) > 1;

/*
No hay duplicados, lo cual es correcto
*/


-- BECARIOS - Crear Tabla Becarios final

CREATE TABLE becarios (
    DNI VARCHAR(8),
    NOMBRES VARCHAR(150),
    MODALIDAD VARCHAR(100),
    INSTITUCION VARCHAR(150),
    SEDE VARCHAR(100),
    CARRERA VARCHAR(150),
    CONDICION VARCHAR(20),
    MOMENTO VARCHAR(20),
    FUENTE VARCHAR(20)
);

INSERT INTO becarios
SELECT 
    CAST(CAST(DNI AS BIGINT) AS VARCHAR(8)),
    NOMBRES,
    MODALIDAD,
    INSTITUCION,
    SEDE,
    CARRERA,
    CONDICION,
    'PRIMER_MOMENTO',
    'ANEXO_1'
FROM becarios_1_1

UNION ALL

SELECT 
    CAST(CAST(DNI AS BIGINT) AS VARCHAR(8)),
    NOMBRES,
    MODALIDAD,
    INSTITUCION,
    SEDE,
    CARRERA,
    CONDICION,
    'PRIMER_MOMENTO',
    'ANEXO_2'
FROM becarios_2_1

UNION ALL

SELECT 
    CAST(CAST(DNI AS BIGINT) AS VARCHAR(8)),
    NOMBRES,
    MODALIDAD,
    INSTITUCION,
    SEDE,
    CARRERA,
    CONDICION,
    'PRIMER_MOMENTO',
    'ANEXO_3'
FROM becarios_3_1

UNION ALL

SELECT 
    CAST(CAST(DNI AS BIGINT) AS VARCHAR(8)),
    NOMBRES,
    MODALIDAD,
    INSTITUCION,
    SEDE,
    CARRERA,
    CONDICION,
    'PRIMER_MOMENTO',
    'ANEXO_4'
FROM becarios_4_1

UNION ALL

SELECT 
    CAST(CAST(DNI AS BIGINT) AS VARCHAR(8)),
    NOMBRES,
    MODALIDAD,
    INSTITUCION,
    SEDE,
    CARRERA,
    CONDICION,
    'SEGUNDO_MOMENTO',
    'ANEXO_1'
FROM becarios_1_2;

Select*from becarios


SELECT*FROM preseleccionados
DROP TABLE preseleccionados


-- Validación de que no haya DUplicados

SELECT DNI, COUNT(*)
FROM aptos
GROUP BY DNI
HAVING COUNT(*) > 1;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- EXPLORATORY DATA ANALYSIS AND INSIGHTS --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--Pregunta #1: ¿Cuántos postulantes hay en cada etapa?

SELECT 'APTOS' AS etapa,  COUNT(*) as Postulantes FROM aptos
UNION ALL
SELECT 'PRESELECCIONADOS', COUNT(*) FROM preseleccionados
UNION ALL
SELECT 'SELECCIONADOS', COUNT(*) FROM seleccionados_final
UNION ALL
SELECT 'BECARIOS', COUNT(*) FROM becarios;

--Pregunta #2: Distribución de postulantes por modalidad

SELECT 
    a.MODALIDAD,
    
    COUNT(DISTINCT a.DNI) AS aptos,
    COUNT(DISTINCT p.DNI) AS pre,
    COUNT(DISTINCT s.DNI) AS sel,
    COUNT(DISTINCT b.DNI) AS becarios,

    CAST(COUNT(DISTINCT p.DNI) * 1.0 / COUNT(DISTINCT a.DNI) AS DECIMAL(5,2)) AS tasa_pre,
    CAST(COUNT(DISTINCT s.DNI) * 1.0 / COUNT(DISTINCT a.DNI) AS DECIMAL(5,2)) AS tasa_sel,
    CAST(COUNT(DISTINCT b.DNI) * 1.0 / COUNT(DISTINCT a.DNI) AS DECIMAL(5,2)) AS tasa_becarios

FROM aptos a

LEFT JOIN preseleccionados p ON a.DNI = p.DNI
LEFT JOIN seleccionados_final s ON a.DNI = s.DNI
LEFT JOIN becarios b ON a.DNI = b.DNI

GROUP BY a.MODALIDAD
ORDER BY tasa_becarios DESC;

--Pregunta #3: Regiones por etapas en el concurso

SELECT 
    p.REGION,

    COUNT(DISTINCT a.DNI) AS aptos,
    COUNT(DISTINCT p.DNI) AS pre,
    COUNT(DISTINCT s.DNI) AS sel,
    COUNT(DISTINCT b.DNI) AS becarios,

    CAST(COUNT(DISTINCT s.DNI) * 1.0 / COUNT(DISTINCT p.DNI) AS DECIMAL(5,2)) AS tasa_sel,
    CAST(COUNT(DISTINCT b.DNI) * 1.0 / COUNT(DISTINCT p.DNI) AS DECIMAL(5,2)) AS tasa_becarios

FROM preseleccionados p

LEFT JOIN aptos a ON p.DNI = a.DNI
LEFT JOIN seleccionados_final s ON p.DNI = s.DNI
LEFT JOIN becarios b ON p.DNI = b.DNI

GROUP BY p.REGION
ORDER BY tasa_becarios DESC;

--Pregunta #4: Top instituciones con más becarios

SELECT TOP 10 INSTITUCION, COUNT(*) AS total
FROM becarios
GROUP BY INSTITUCION
ORDER BY total DESC;

--Pregunta #5: Top Regiones con más becarios

SELECT 
    p.REGION,
    COUNT(DISTINCT b.DNI) AS becarios,
    COUNT(DISTINCT a.DNI) AS aptos,
    CAST(COUNT(DISTINCT b.DNI) * 1.0 / COUNT(DISTINCT a.DNI) AS DECIMAL(5,2)) AS eficiencia
FROM aptos a
LEFT JOIN preseleccionados p ON a.DNI = p.DNI
LEFT JOIN becarios b ON a.DNI = b.DNI
GROUP BY p.REGION
ORDER BY eficiencia DESC;

--Pregunta #6: Carrera más peleada.

SELECT 
    s.CARRERA,
    COUNT(DISTINCT p.DNI) AS preseleccionados,
    AVG(p.PUNTAJE_FINAL) AS promedio_pre,

    COUNT(DISTINCT s.DNI) AS seleccionados,
    AVG(s.PUNTAJE_FINAL) AS promedio_sel,

    COUNT(DISTINCT b.DNI) AS becarios,

    CAST(
        COUNT(DISTINCT b.DNI) * 1.0 / COUNT(DISTINCT s.DNI)
    AS DECIMAL(5,2)) AS tasa_becarios

FROM seleccionados_final s

LEFT JOIN preseleccionados p 
    ON s.DNI = p.DNI

LEFT JOIN becarios b 
    ON s.DNI = b.DNI

GROUP BY s.CARRERA

HAVING COUNT(DISTINCT s.DNI) > 30

ORDER BY promedio_sel DESC;

-- Pregunta #7 - Funel de pustulantes por universidad

SELECT 
    COALESCE(p_ies.IES, s.IES, b.INSTITUCION) AS universidad,

    COUNT(DISTINCT p_ies.DNI) AS preseleccionados,
    COUNT(DISTINCT s.DNI) AS seleccionados,
    COUNT(DISTINCT b.DNI) AS becarios

FROM (

    -- PRESELECCIONADOS (con info de selección)
    SELECT 
        p.DNI,
        s.IES
    FROM preseleccionados p
    LEFT JOIN seleccionados_final s 
        ON p.DNI = s.DNI

) p_ies

LEFT JOIN seleccionados_final s 
    ON p_ies.DNI = s.DNI

LEFT JOIN becarios b 
    ON p_ies.DNI = b.DNI

GROUP BY COALESCE(p_ies.IES, s.IES, b.INSTITUCION)

ORDER BY becarios DESC;

--Pregunta #8: ¿Cuántos postulantes a pesar de haber optenido un buen puntaje en el examen de preselección, no rindieronn por diversos motivos a la Beca.

WITH ranking_pre AS (
    SELECT 
        DNI,
        MODALIDAD,
        PUNTAJE_FINAL AS puntaje_pre,
        ROW_NUMBER() OVER (
            PARTITION BY MODALIDAD 
            ORDER BY PUNTAJE_FINAL DESC
        ) AS ranking
    FROM preseleccionados
)

SELECT 
    r.DNI,
    r.MODALIDAD,
    r.ranking,
    r.puntaje_pre,

    s.IES,
    s.CARRERA,
    s.PUNTAJE_FINAL AS puntaje_seleccion,

    CASE 
        WHEN b.DNI IS NOT NULL THEN 'SI'
        ELSE 'NO'
    END AS es_becario

FROM ranking_pre r

LEFT JOIN seleccionados_final s 
    ON r.DNI = s.DNI

LEFT JOIN becarios b 
    ON r.DNI = b.DNI

ORDER BY r.MODALIDAD, r.ranking;

--Pregunta #9: Cantidad de Alumnos que cambiaron de carrera y los que no lograron la beca después de cambiar.

WITH cambios AS (
    SELECT 
        DNI,
        CARRERA,
        MOMENTO,
        ROW_NUMBER() OVER (
            PARTITION BY DNI 
            ORDER BY 
                CASE 
                    WHEN MOMENTO = 'PRIMER_MOMENTO' THEN 1
                    ELSE 2
                END
        ) AS orden
    FROM seleccionados
),

pivot_cambios AS (
    SELECT 
        c1.DNI
    FROM cambios c1
    JOIN cambios c2 
        ON c1.DNI = c2.DNI
    WHERE c1.orden = 1
      AND c2.orden = 2
      AND c1.CARRERA <> c2.CARRERA
)

SELECT 
    COUNT(*) AS total,

    SUM(CASE WHEN b.DNI IS NULL THEN 1 ELSE 0 END) AS no_becarios,

    CAST(
        SUM(CASE WHEN b.DNI IS NULL THEN 1 ELSE 0 END) * 1.0 
        / COUNT(*) 
    AS DECIMAL(5,2)) AS tasa_no_beca

FROM pivot_cambios pc
LEFT JOIN becarios b 
    ON pc.DNI = b.DNI;

--Pregunta #10: Lista de Alumnos que cambiaron de carrera

WITH cambios AS (
    SELECT 
        DNI,
		MODALIDAD,
        CARRERA,
        IES,
		PUNTAJE_FINAL,
        MOMENTO,
        ROW_NUMBER() OVER (
            PARTITION BY DNI 
            ORDER BY 
                CASE 
                    WHEN MOMENTO = 'PRIMER_MOMENTO' THEN 1
                    ELSE 2
                END
        ) AS orden
    FROM seleccionados
),

pivot_cambios AS (
    SELECT 
        c1.DNI,
		c1.IES AS ies_inicial,
        c1.CARRERA AS carrera_inicial,
		c2.IES AS ies_final,
        c2.CARRERA AS carrera_final,
		c2.PUNTAJE_FINAL AS puntaje_final
        
    FROM cambios c1
    JOIN cambios c2 
        ON c1.DNI = c2.DNI
    WHERE c1.orden = 1
      AND c2.orden = 2
      AND c1.CARRERA <> c2.CARRERA
)

SELECT 
    pc.DNI,
	pc.ies_inicial,
    pc.carrera_inicial,
	pc.ies_final,
    pc.carrera_final,
	pc.puntaje_final,

    CASE 
        WHEN b.DNI IS NOT NULL THEN 'SI'
        ELSE 'NO'
    END AS es_becario

FROM pivot_cambios pc

LEFT JOIN becarios b 
    ON pc.DNI = b.DNI

ORDER BY pc.puntaje_final DESC;
