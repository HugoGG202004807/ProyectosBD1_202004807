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



module.exports = {
    consulta1,
    consulta2
}