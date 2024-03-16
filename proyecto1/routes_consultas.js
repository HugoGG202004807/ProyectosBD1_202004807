const oracledb = require('oracledb');

async function consulta1(req, res){
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `
            SELECT c.ID_CLIENTE, c.NOMBRE AS NOMBRE_CLIENTE, c.APELLIDO, p.NOMBRE AS NOMBRE_PAIS, 
            SUM(pr.PRECIO * d.CANTIDAD) AS MONTO, COUNT(c.ID_CLIENTE) AS CANTIDAD_COMPRAS
            FROM CLIENTES c
            INNER JOIN PAISES p ON c.ID_PAIS = p.ID_PAIS
            INNER JOIN ORDENES_UNICOS o ON c.ID_CLIENTE = o.ID_CLIENTE
            INNER JOIN DETALLES_ORDENES d ON o.ID_ORDEN = d.ID_ORDEN
            INNER JOIN PRODUCTOS pr ON d.ID_PRODUCTO = pr.ID_PRODUCTO
            GROUP BY c.ID_CLIENTE, c.NOMBRE, c.APELLIDO, p.NOMBRE
            ORDER BY CANTIDAD_COMPRAS DESC
            FETCH FIRST 1 ROWS ONLY
        `;

        const result = await connection.execute(query);

        // Procesa el resultado de la consulta
        const rows = result.rows;
        const rowData = rows[0];
        const cliente = {
            id: rowData[0],
            nombre: rowData[1],
            apellido: rowData[2],
            pais: rowData[3]
        };
        const montoTotal = rowData[4];
        const cantidadCompras = rowData[5];

        // Construye el objeto JSON de respuesta
        const response = {
            cliente: cliente,
            monto_total: montoTotal,
            cantidad_compras: cantidadCompras
        };

        // Envía el resultado como respuesta al cliente
        res.json(response);

    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta2(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const masCompradoQuery = `
            SELECT
                p.ID_PRODUCTO,
                p.NOMBRE AS NOMBRE_PRODUCTO,
                c.NOMBRE AS CATEGORIA,
                SUM(d.CANTIDAD) AS CANTIDAD_UNIDADES,
                SUM(d.CANTIDAD * pr.PRECIO) AS MONTO_VENDIDO
            FROM
                PRODUCTOS p
            JOIN
                CATEGORIAS c ON p.ID_CATEGORIA = c.ID_CATEGORIA
            JOIN
                DETALLES_ORDENES d ON p.ID_PRODUCTO = d.ID_PRODUCTO
            JOIN
                ORDENES_UNICOS o ON d.ID_ORDEN = o.ID_ORDEN
            JOIN
                PRODUCTOS pr ON d.ID_PRODUCTO = pr.ID_PRODUCTO
            GROUP BY
                p.ID_PRODUCTO,
                p.NOMBRE,
                c.NOMBRE
            ORDER BY
                SUM(d.CANTIDAD) DESC
            FETCH FIRST 1 ROW ONLY
        `;
        
        const menosCompradoQuery = `
            SELECT
                p.ID_PRODUCTO,
                p.NOMBRE AS NOMBRE_PRODUCTO,
                c.NOMBRE AS CATEGORIA,
                SUM(d.CANTIDAD) AS CANTIDAD_UNIDADES,
                SUM(d.CANTIDAD * pr.PRECIO) AS MONTO_VENDIDO
            FROM
                PRODUCTOS p
            JOIN
                CATEGORIAS c ON p.ID_CATEGORIA = c.ID_CATEGORIA
            JOIN
                DETALLES_ORDENES d ON p.ID_PRODUCTO = d.ID_PRODUCTO
            JOIN
                ORDENES_UNICOS o ON d.ID_ORDEN = o.ID_ORDEN
            JOIN
                PRODUCTOS pr ON d.ID_PRODUCTO = pr.ID_PRODUCTO
            GROUP BY
                p.ID_PRODUCTO,
                p.NOMBRE,
                c.NOMBRE
            ORDER BY
                SUM(d.CANTIDAD) ASC
            FETCH FIRST 1 ROW ONLY
        `;

        const resultMasComprado = await connection.execute(masCompradoQuery);
        const resultMenosComprado = await connection.execute(menosCompradoQuery);
        
        const masCompradoData = resultMasComprado.rows[0];
        const menosCompradoData = resultMenosComprado.rows[0];

        const response = { 
            masComprado: {
                idProducto: masCompradoData[0],
                nombreProducto: masCompradoData[1],
                categoria: masCompradoData[2],
                cantidadUnidades: masCompradoData[3],
                montoVendido: masCompradoData[4]
            },
            menosComprado: {
                idProducto: menosCompradoData[0],
                nombreProducto: menosCompradoData[1],
                categoria: menosCompradoData[2],
                cantidadUnidades: menosCompradoData[3],
                montoVendido: menosCompradoData[4]
            }
        };
        
        res.json(response);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta3(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `
            SELECT
                v.ID_VENDEDOR,
                v.NOMBRE AS NOMBRE_VENDEDOR,
                SUM(d.CANTIDAD * pr.PRECIO) AS MONTO_TOTAL_VENDIDO
            FROM
                VENDEDORES v
            JOIN
                DETALLES_ORDENES d ON v.ID_VENDEDOR = d.ID_VENDEDOR
            JOIN
                PRODUCTOS pr ON d.ID_PRODUCTO = pr.ID_PRODUCTO
            GROUP BY
                v.ID_VENDEDOR,
                v.NOMBRE
            ORDER BY
                SUM(d.CANTIDAD) DESC
            FETCH FIRST 1 ROW ONLY
        `;

        const result = await connection.execute(query);
        const data = result.rows[0];

        const response = { 
            idVendedor: data[0],
            nombreVendedor: data[1],
            montoTotalVendido: data[2]
        };

        res.json(response);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta4(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `
        SELECT nombre_pais, monto_total
        FROM (
            SELECT p.nombre AS nombre_pais,
                SUM(prd.precio * dto.cantidad) AS monto_total
            FROM paises p
            INNER JOIN vendedores v ON p.id_pais = v.id_pais
            INNER JOIN DETALLES_ORDENES dto ON v.id_vendedor = dto.id_vendedor
            INNER JOIN productos prd ON dto.id_producto = prd.id_producto
            GROUP BY p.nombre
            ORDER BY SUM(dto.cantidad) DESC
        )
        WHERE ROWNUM <= 1

        UNION ALL

        SELECT nombre_pais, monto_total
        FROM (
            SELECT p.nombre AS nombre_pais,
                SUM(prd.precio * dto.cantidad) AS monto_total
            FROM paises p
            INNER JOIN vendedores v ON p.id_pais = v.id_pais
            INNER JOIN DETALLES_ORDENES dto ON v.id_vendedor = dto.id_vendedor
            INNER JOIN productos prd ON dto.id_producto = prd.id_producto
            GROUP BY p.nombre
            ORDER BY SUM(dto.cantidad) ASC
        )
        WHERE ROWNUM <= 1
        `;

        const result = await connection.execute(query);
        const data = result.rows;

        const response = { 
            paisMasVendido: {
                nombrePais: data[0][0],
                montoTotalVendido: data[0][1]
            },
            paisMenosVendido: {
                nombrePais: data[1][0],
                montoTotalVendido: data[1][1]
            }
        };

        res.json(response);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta5(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `

            SELECT id_pais, nombre_pais, monto_total
FROM (
    SELECT
        pais.ID_PAIS AS id_pais,
        pais.NOMBRE AS nombre_pais,
        SUM(d.CANTIDAD * pr.PRECIO) AS monto_total
    FROM
        PAISES pais
    JOIN
        CLIENTES cli ON pais.ID_PAIS = cli.ID_PAIS
    JOIN
        ORDENES_UNICOS ord ON cli.ID_CLIENTE = ord.ID_CLIENTE
    JOIN
        DETALLES_ORDENES d ON ord.ID_ORDEN = d.ID_ORDEN
    JOIN
        PRODUCTOS pr ON d.ID_PRODUCTO = pr.ID_PRODUCTO
    GROUP BY
        pais.ID_PAIS, pais.NOMBRE
    ORDER BY
        SUM(d.CANTIDAD) DESC
    FETCH FIRST 5 ROW ONLY
)
ORDER BY
    monto_total ASC

        `;

        const result = await connection.execute(query);
        const data = result.rows;

        const response = data.map(row => ({
            idPais: row[0],
            nombrePais: row[1],
            montoTotal: row[2]
        }));

        res.json(response);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta6(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `
        SELECT nombre_categoria, cantidad_unidades
        FROM (
            SELECT
                cat.NOMBRE AS nombre_categoria,
                SUM(det.CANTIDAD) AS cantidad_unidades
            FROM
                CATEGORIAS cat
            JOIN
                PRODUCTOS prod ON cat.ID_CATEGORIA = prod.ID_CATEGORIA
            JOIN
                DETALLES_ORDENES det ON prod.ID_PRODUCTO = det.ID_PRODUCTO
            GROUP BY
                cat.NOMBRE
            ORDER BY
                SUM(det.CANTIDAD) DESC
            FETCH FIRST 1 ROW ONLY
        ) max_compra
        UNION ALL
        SELECT nombre_categoria, cantidad_unidades
        FROM (
            SELECT
                cat.NOMBRE AS nombre_categoria,
                SUM(det.CANTIDAD) AS cantidad_unidades
            FROM
                CATEGORIAS cat
            JOIN
                PRODUCTOS prod ON cat.ID_CATEGORIA = prod.ID_CATEGORIA
            JOIN
                DETALLES_ORDENES det ON prod.ID_PRODUCTO = det.ID_PRODUCTO
            GROUP BY
                cat.NOMBRE
            ORDER BY
                SUM(det.CANTIDAD) ASC
            FETCH FIRST 1 ROW ONLY
        ) min_compra

        `;

        const result = await connection.execute(query);
        const data = result.rows;

        const response = { 
            masComprado: {
                categoria: data[0][0],
                cantidad: data[0][1]
            },
            menosComprado: {
                categoria: data[1][0],
                cantidad: data[1][1]
            }
        };

        res.json(response);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta7(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `
        SELECT nombre_pais, nombre_categoria, cantidad_unidades
        FROM (
            SELECT
                pais.NOMBRE AS nombre_pais,
                cat.NOMBRE AS nombre_categoria,
                SUM(det.CANTIDAD) AS cantidad_unidades,
                ROW_NUMBER() OVER(PARTITION BY pais.ID_PAIS ORDER BY SUM(det.CANTIDAD) DESC) AS ranking
            FROM
                PAISES pais
            JOIN
                CLIENTES cli ON pais.ID_PAIS = cli.ID_PAIS
            JOIN
                ORDENES_UNICOS ord ON cli.ID_CLIENTE = ord.ID_CLIENTE
            JOIN
                DETALLES_ORDENES det ON ord.ID_ORDEN = det.ID_ORDEN
            JOIN
                PRODUCTOS prod ON det.ID_PRODUCTO = prod.ID_PRODUCTO
            JOIN
                CATEGORIAS cat ON prod.ID_CATEGORIA = cat.ID_CATEGORIA
            GROUP BY
                pais.ID_PAIS, pais.NOMBRE, cat.NOMBRE
        )
        WHERE ranking = 1
        `;

        const result = await connection.execute(query);
        const data = result.rows;

        const response = data.map(row => ({
            nombrePais: row[0],
            categoria: row[1],
            unidades: row[2]
        }));

        res.json(response);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta8(req, res) {
    let connection;

    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `
            SELECT TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM') AS numero_mes, 
                   TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'Month') AS nombre_mes,
                   SUM(det.CANTIDAD * prod.PRECIO) AS monto
            FROM ORDENES_UNICOS ord
            JOIN DETALLES_ORDENES det ON ord.ID_ORDEN = det.ID_ORDEN
            JOIN CLIENTES cli ON ord.ID_CLIENTE = cli.ID_CLIENTE
            JOIN PAISES pais ON cli.ID_PAIS = pais.ID_PAIS
            JOIN PRODUCTOS prod ON det.ID_PRODUCTO = prod.ID_PRODUCTO
            WHERE pais.NOMBRE = 'Inglaterra'
            GROUP BY TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM'), 
                     TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'Month')
            ORDER BY TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM')
        `;

        const result = await connection.execute(query);
        const data = result.rows.map(row => ({
            numeroMes: row[0],
            nombreMes: row[1],
            monto: row[2]
        }));

        res.json(data);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta9(req, res) {
    let connection;

    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `
        SELECT numero_mes, monto
        FROM (
            SELECT TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM') AS numero_mes,
                   SUM(det.CANTIDAD * prod.PRECIO) AS monto
            FROM ORDENES_UNICOS ord
            JOIN DETALLES_ORDENES det ON ord.ID_ORDEN = det.ID_ORDEN
            JOIN PRODUCTOS prod ON det.ID_PRODUCTO = prod.ID_PRODUCTO
            GROUP BY TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM')
            ORDER BY SUM(det.CANTIDAD * prod.PRECIO) DESC
        )
        WHERE ROWNUM = 1
        
        UNION ALL
        
        SELECT numero_mes, monto
        FROM (
            SELECT TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM') AS numero_mes,
                   SUM(det.CANTIDAD * prod.PRECIO) AS monto
            FROM ORDENES_UNICOS ord
            JOIN DETALLES_ORDENES det ON ord.ID_ORDEN = det.ID_ORDEN
            JOIN PRODUCTOS prod ON det.ID_PRODUCTO = prod.ID_PRODUCTO
            GROUP BY TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM')
            ORDER BY SUM(det.CANTIDAD * prod.PRECIO) ASC
        )
        WHERE ROWNUM = 1
        
        `;

        const result = await connection.execute(query);
        const data = result.rows.map(row => ({
            numeroMes: row[0],
            monto: row[1]
        }));

        res.json(data);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}

async function consulta10(req, res) {
    let connection;

    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const query = `
        SELECT det.ID_PRODUCTO, prod.NOMBRE AS nombre_producto, SUM(det.CANTIDAD * prod.PRECIO) AS monto
        FROM DETALLES_ORDENES det
        JOIN PRODUCTOS prod ON det.ID_PRODUCTO = prod.ID_PRODUCTO
        JOIN CATEGORIAS cat ON prod.ID_CATEGORIA = cat.ID_CATEGORIA
        WHERE cat.NOMBRE = 'Deportes'
        GROUP BY det.ID_PRODUCTO, prod.NOMBRE
        `;

        const result = await connection.execute(query);
        const data = result.rows.map(row => ({
            idProducto: row[0],
            nombreProducto: row[1],
            monto: row[2]
        }));

        res.json(data);
    } catch (error) {
        console.error('Error al realizar la consulta:', error);
        res.status(500).send('Error al obtener datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
            }
        }
    }
}



module.exports = {
    consulta1,
    consulta2,
    consulta3,
    consulta4,
    consulta5,
    consulta6,
    consulta7,
    consulta8,
    consulta9,
    consulta10
}
