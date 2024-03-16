const cargarmodelo = require('./routes_cargarmodelo');
const script = require('./crear_modelo');
const fs = require('fs');
const oracledb = require('oracledb');
const consultas = require('./routes_consultas');
const eliminar = require('./routes_eliminar')

module.exports = function(app){

  app.get('/', (req, res) => {
      res.send('¡Bases de Datos 1!');
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
  app.get('/cargarmodelo/clientes', async (req, res) => {
    const csvFilePath = '/home/usuario/Escritorio/bases1/ProyectosBD1_202004807/clientes.csv';
    const columnas = ['ID_CLIENTE', 'NOMBRE', 'APELLIDO', 'DIRECCION', 'TELEFONO', 'TARJETA', 'EDAD', 'SALARIO', 'GENERO', 'ID_PAIS'];
    await cargarmodelo.insertarDatosDesdeCSV(req, res, 'CLIENTES', csvFilePath, columnas);
  });
app.get('/cargarmodelo/ordenes', async (req, res) => {
  try {
    const csvFilePath = '/home/usuario/Escritorio/bases1/ProyectosBD1_202004807/ordenes2.csv';
    const columnas1 = ['ID_ORDEN', 'FECHA_ORDEN', 'ID_CLIENTE'];
    const columnas2 = ['ID_ORDEN', 'LINEA_ORDEN', 'ID_VENDEDOR', 'ID_PRODUCTO', 'CANTIDAD'];

    // Insertar datos de la tabla ORDENES
    await cargarmodelo.insertarDatosDesdeCSV2(req, res, 'ORDENES', csvFilePath, columnas1);

    // Insertar datos de la tabla DETALLES_ORDENES
    await cargarmodelo.insertarDatosDesdeCSV2(req, res, 'DETALLES_ORDENES', csvFilePath, columnas2);


    res.send('¡Datos insertados exitosamente!');
} catch (error) {
    console.error('Error al cargar los datos:', error);
    res.status(500).send('Error al cargar los datos.');
}
  });
  app.get('/cargarmodelo/ordenes2', async (req, res) => {
    try {
      
      //asignaciones de llaves a las tablas
      await cargarmodelo.modificaciones_tablas();
      res.send('¡Datos modificados exitosamente!');
  } catch (error) {
      console.error('Error al modificar datos:', error);
      res.status(500).send('Error al modificar datos.');
  }
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

app.get('/eliminarmodelo', async (req, res) => {
  await eliminar.todo(req, res);
});

app.get('/borrarinfodb', async (req, res) => {
  await eliminar.informacion(req, res);
});


app.get('/consulta1', async (req, res) => {
  await consultas.consulta1(req, res);
});

app.get('/consulta2', async (req, res) => {
  await consultas.consulta2(req, res);
});

app.get('/consulta3', async (req, res) => {
  await consultas.consulta3(req, res);
});

app.get('/consulta4', async (req, res) => {
  await consultas.consulta4(req, res);
});

app.get('/consulta5', async (req, res) => {
  await consultas.consulta5(req, res);
});

app.get('/consulta6', async (req, res) => {
  await consultas.consulta6(req, res);
});

app.get('/consulta7', async (req, res) => {
  await consultas.consulta7(req, res);
});

app.get('/consulta8', async (req, res) => {
  await consultas.consulta8(req, res);
});

app.get('/consulta9', async (req, res) => {
  await consultas.consulta9(req, res);
});

app.get('/consulta10', async (req, res) => {
  await consultas.consulta10(req, res);
});


};