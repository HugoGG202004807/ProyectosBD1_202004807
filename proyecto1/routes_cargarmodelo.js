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

        fs.createReadStream(csvFilePath)
            .pipe(csv({
                separator: ';'
            }))
            .on('data', async (row) => {
                const insertQuery = `INSERT INTO ${tabla} (${columnas.join(', ')}) VALUES (${columnas.map((col) => `:${col}`).join(', ')})`;

                const bindParams = {};
                columnas.forEach(col => {
                    bindParams[col] = row[col.toLowerCase()];
                });

                await connection.execute(insertQuery, bindParams);
            })
            .on('end', async () => {
                await connection.commit();
                await connection.close(); 
                res.send('¡Datos insertados exitosamente!');
            })
            .on('error', (error) => {
                console.error('Error al leer el archivo CSV:', error);
                res.status(500).send('Error al insertar los datos.');
            });
    } catch (error) {
        console.error('Error al insertar los datos en la base de datos:', error);
        res.status(500).send('Error al insertar los datos en la base de datos.');
    }
}

module.exports = {
    insertarDatosDesdeCSV
};
