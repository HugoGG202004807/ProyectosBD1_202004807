const oracledb = require('oracledb');

async function todo(req, res){
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const queries = `
            DROP TABLE DETALLES_ORDENES;
            DROP TABLE ORDENES_UNICOS;
            DROP TABLE CLIENTES;
            DROP TABLE VENDEDORES;
            DROP TABLE PAISES;
            DROP TABLE PRODUCTOS;
            DROP TABLE CATEGORIAS;
            DROP TABLE ORDENES;
            
        `;
        const queryList = queries.split(';');

        for (const query of queryList) {
            if (query.trim() !== '') {
                await connection.execute(query);
            }
        }
        
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Error al eliminar los modelos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
                res.send('¡Tablas eliminadas!');
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
                res.status(500).send('Error en la eliminacion de tablas');
            }
        }
    }
}

async function informacion(req, res){
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });

        const queries = `
        TRUNCATE TABLE DETALLES_ORDENES;
        TRUNCATE TABLE ORDENES_UNICOS;
        TRUNCATE TABLE CLIENTES;
        TRUNCATE TABLE VENDEDORES;
        TRUNCATE TABLE PAISES;
        TRUNCATE TABLE PRODUCTOS;
        TRUNCATE TABLE CATEGORIAS;
            
        `;
        const queryList = queries.split(';');

        for (const query of queryList) {
            if (query.trim() !== '') {
                await connection.execute(query);
            }
        }
        
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Error al eliminar los datos.');
    } finally {
        if (connection) {
            try {
                await connection.close();
                res.send('¡Tablas eliminadas!');
            } catch (error) {
                console.error('Error al cerrar la conexión:', error);
                res.status(500).send('Error en la eliminacion de informacion');
            }
        }
    }
}

module.exports = {
    todo,
    informacion
}