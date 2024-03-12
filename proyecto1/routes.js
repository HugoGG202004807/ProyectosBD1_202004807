const cargarmodelo = require('./routes_cargarmodelo');
const script = require('./crear_modelo');
const fs = require('fs');
const oracledb = require('oracledb');


module.exports = function(app){

  app.get('/', (req, res) => {
      res.send('¡Hola, mundo!');
    }); 
  
    app.get('/cargarmodelo/paises', async (req, res) => {
      const csvFilePath = '/home/usuario/Escritorio/bases1/ProyectosBD1_202004807/paises.csv';
      const columnas = ['ID_PAIS', 'NOMBRE'];
      await cargarmodelo.insertarDatosDesdeCSV(req, res, 'PAISES', csvFilePath, columnas);
  });
  app.get('/cargarmodelo/categorias', async (req, res) => {
    const csvFilePath = '/home/usuario/Escritorio/bases1/ProyectosBD1_202004807/categorias.csv';
    const columnas = ['ID_CATEGORIA', 'NOMBRE'];
    await cargarmodelo.insertarDatosDesdeCSV(req, res, 'CATEGORIAS', csvFilePath, columnas);
  });
  app.get('/cargarmodelo/productos', async (req, res) => {
    const csvFilePath = '/home/usuario/Escritorio/bases1/ProyectosBD1_202004807/productos.csv';
    const columnas = ['ID_PRODUCTO', 'NOMBRE', 'PRECIO', 'ID_CATEGORIA'];
    await cargarmodelo.insertarDatosDesdeCSV(req, res, 'PRODUCTOS', csvFilePath, columnas);
  }); 
  app.get('/cargarmodelo/vendedores', async (req, res) => {
      const csvFilePath = '/home/usuario/Escritorio/bases1/ProyectosBD1_202004807/vendedores.csv';
      const columnas = ['ID_VENDEDOR', 'NOMBRE', 'ID_PAIS'];
      await cargarmodelo.insertarDatosDesdeCSV(req, res, 'VENDEDORES', csvFilePath, columnas);
  });
// aun no funciona
  app.get('/cargarmodelo/clientes', async (req, res) => {
    const csvFilePath = '/home/usuario/Escritorio/bases1/ProyectosBD1_202004807/clientes.csv';
    const columnas = ['ID_CLIENTE', 'NOMBRE', 'APELLIDO', 'DIRECCION', 'TELEFONO', 'TARJETA', 'EDAD', 'SALARIO', 'GENERO', 'ID_PAIS'];
    await cargarmodelo.insertarDatosDesdeCSV(req, res, 'CLIENTES', csvFilePath, columnas);
});


app.get('/crearmodelo', async (req, res) => {
    try {
        // Eliminar los comentarios del script SQL
        const queries = script.replace(/(--.*)/g, '');

        // Establecer la conexión a la base de datos Oracle
        const connection = await oracledb.getConnection({
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
        });
      
        // Dividir las consultas por punto y coma para ejecutarlas individualmente
        const queryList = queries.split(';');

        // Ejecutar cada consulta en el archivo SQL
        for (const query of queryList) {
            if (query.trim() !== '') {
                await connection.execute(query);
            }
        }

        // Cerrar la conexión a la base de datos
        await connection.close();

        // Respuesta exitosa
        res.send('¡Modelo creado exitosamente!');
    } catch (error) {
        // Manejar cualquier error que ocurra durante la ejecución de las consultas SQL
        console.error('Error al ejecutar las consultas SQL:', error);
        res.status(500).send('Error al crear el modelo.');
    }
});


};