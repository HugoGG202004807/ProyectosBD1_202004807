const oracledb = require('oracledb');
const csv = require('csv-parser');
const fs = require('fs');

async function insertarDatosDesdeCSV(req, res, tabla, csvFilePath, columnas) {
    try {
        const connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        let rows = [];
        fs.createReadStream(csvFilePath)
            .pipe(csv({
                separator: ';'
            }))
            .on('data', (row) => {
                const bindParams = [];
                columnas.forEach(col => {
                    bindParams.push(row[col.toLowerCase()]);
                });
                rows.push(bindParams);
            })
            .on('end', async () => {
                try {
                    const insertQuery = `INSERT INTO ${tabla} (${columnas.join(', ')}) VALUES (${columnas.map((col, i) => `:${i + 1}`).join(', ')})`;
                    await connection.executeMany(insertQuery, rows, { autoCommit: true });
                    console.log(`Datos insertados exitosamente en ${tabla}`);
                } catch (error) {
                    console.error('Error al insertar los datos en la base de datos:', error);
                    res.status(500).send('Error al insertar los datos en la base de datos.');
                    return; // Importante: Terminar la función después de enviar una respuesta
                } finally {
                    await connection.commit();
                    await connection.close();
                }
            })
            .on('error', (error) => {
                console.error('Error al leer el archivo CSV:', error);
                res.status(500).send('Error al insertar los datos.');
                return; // Importante: Terminar la función después de enviar una respuesta
            });

        // Enviar la respuesta después de que todas las inserciones hayan sido completadas
        res.send('¡Datos insertados exitosamente!');
    } catch (error) {
        console.error('Error al insertar los datos en la base de datos:', error);
        res.status(500).send('Error al insertar los datos en la base de datos.');
    }
}

async function insertarDatosDesdeCSV2(req, res, tabla, csvFilePath, columnas) {
    try {
        const connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        let rows = [];
        fs.createReadStream(csvFilePath)
            .pipe(csv({
                separator: ';'
            }))
            .on('data', (row) => {
                const bindParams = [];
                columnas.forEach(col => {
                    bindParams.push(row[col.toLowerCase()]);
                });
                rows.push(bindParams);
            })
            .on('end', async () => {
                try {
                    const insertQuery = `INSERT INTO ${tabla} (${columnas.join(', ')}) VALUES (${columnas.map((col, i) => `:${i + 1}`).join(', ')})`;
                    await connection.executeMany(insertQuery, rows, { autoCommit: true });
                    console.log(`Datos insertados exitosamente en ${tabla}`);
                } catch (error) {
                    console.error('Error al insertar los datos en la base de datos:', error);
                    return; // Importante: Terminar la función después de enviar una respuesta
                } finally {
                    await connection.commit();
                    await connection.close();
                }
            })
            .on('error', (error) => {
                console.error('Error al leer el archivo CSV:', error);
                return; // Importante: Terminar la función después de enviar una respuesta
            });
    } catch (error) {
        console.error('Error al insertar los datos en la base de datos:', error);
        res.status(500).send('Error al insertar los datos en la base de datos.');
    }
}

async function modificaciones_tablas() {
    // Establecer la conexión con la base de datos
    const connection = await oracledb.getConnection({
        user: 'system',
        password: 'Ora1234',
        connectString: 'localhost:1521/free'
    });
    try {
        
        // Crear una nueva tabla ORDENES_UNICOS
        const queries = `
            CREATE TABLE ORDENES_UNICOS (
                ID_ORDEN NUMBER,
                FECHA_ORDEN VARCHAR2(20),
                ID_CLIENTE NUMBER
            );
            INSERT INTO ORDENES_UNICOS (ID_ORDEN, FECHA_ORDEN, ID_CLIENTE)
            SELECT ID_ORDEN, FECHA_ORDEN, ID_CLIENTE
            FROM ORDENES
            GROUP BY ID_ORDEN, FECHA_ORDEN, ID_CLIENTE;
            ALTER TABLE ORDENES_UNICOS
            ADD CONSTRAINT pk_orden PRIMARY KEY (ID_ORDEN);
            ALTER TABLE DETALLES_ORDENES
            ADD CONSTRAINT DETALLES_ORDENES_ORDENES_UNICOS_FK FOREIGN KEY (ID_ORDEN)
            REFERENCES ORDENES_UNICOS(ID_ORDEN);
            ALTER TABLE ORDENES_UNICOS
            ADD CONSTRAINT ORDENES_UNICOS_CLIENTES_FK
            FOREIGN KEY (ID_CLIENTE)
            REFERENCES CLIENTES(ID_CLIENTE);
            ALTER TABLE DETALLES_ORDENES
            ADD CONSTRAINT DETALLES_ORDENES_VENDEDORES_FK
            FOREIGN KEY (ID_VENDEDOR)
            REFERENCES VENDEDORES(ID_VENDEDOR);
            ALTER TABLE DETALLES_ORDENES
            ADD CONSTRAINT DETALLES_ORDENES_PRODUCTOS_FK
            FOREIGN KEY (ID_PRODUCTO)
            REFERENCES PRODUCTOS(ID_PRODUCTO);
            TRUNCATE TABLE ORDENES;
        `;
        
        const queryList = queries.split(';');

        // Ejecutar cada consulta en el archivo SQL
        for (const query of queryList) {
            if (query.trim() !== '') {
                await connection.execute(query);
            }
        }

    } catch (error) {
        console.error('Error al realizar modificaciones en las tablas:', error);
        return;
    } finally {
        console.log('Modificaciones en las tablas completadas con éxito');
        // Cerrar la conexión
        await connection.commit();
        await connection.close();
    }
}

module.exports = {
    insertarDatosDesdeCSV,
    insertarDatosDesdeCSV2,
    modificaciones_tablas
};
