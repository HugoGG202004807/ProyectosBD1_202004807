# ProyectosBD1_202004807
# Manual Tecnico
#### Estudiante: Hugo Daniel Giron Garcia
#### Carnet:202004807

# Archivo app.js
- Contiene el servidor web realizado con Node.js y Express. Esto crea una instancia de la aplicación Express, y se define el número de puerto en el que el servidor estará escuchando las solicitudes entrantes. En este caso, el puerto 3000.

```sh
const express = require('express');
const app = express();
const port = 3000;
```
- Aquí se importan las rutas de la aplicación desde un archivo llamado "routes.js" 
```sh
require("./routes")(app);
app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
```
# Archivo routes.js
## Importaciones de los modulos
- cargarmodelo: Archivo destinado para la carga de los datos de las tablas.
- script: Archivo con el contenido para la creacion de las tablas y la asignacion de llaves foraneas y primarias en el modelo
- fs: Este módulo proporciona funciones para trabajar con el sistema de archivos.
- oracledb: Este módulo es una librería para interactuar con bases de datos Oracle.
- consultas: Archivo diseñado para la realizacion de las consultas.
- eliminar: Archivo destinado para la eliminación de datos de la base de datos.
## /crearmodelo
- Cuando un cliente realiza una solicitud GET a esta ruta, se ejecuta una función asincrónica que realiza varias tareas:
```sh
app.get('/crearmodelo', async (req, res) => {
    try {
        const queries = script.replace(/(--.*)/g, ''); // Eliminar comentarios del script SQL
        const connection = await oracledb.getConnection({ // Establecer conexión a la base de datos Oracle
            user: 'system',
            password: 'Ora1234',
            connectString: 'localhost:1521/free'
          ......
          // logica del codigo
        });
```
- Eliminación de comentarios del script SQL: Se elimina cualquier comentario del script SQL para evitar problemas al ejecutar las consultas.

- Establecimiento de la conexión a la base de datos Oracle: Se establece una conexión a la base de datos Oracle utilizando las credenciales proporcionadas (usuario, contraseña y cadena de conexión).

- División de las consultas SQL: El script SQL se divide en una lista de consultas individuales utilizando el carácter punto y coma como delimitador.

- Ejecución de las consultas SQL: Se ejecuta cada consulta SQL en la base de datos Oracle una por una.

- Cierre de la conexión a la base de datos: Una vez que todas las consultas se han ejecutado, se cierra la conexión a la base de datos.

- Respuesta al cliente: Si todas las operaciones se realizan correctamente, se envía una respuesta al cliente indicando que el modelo ha sido creado exitosamente. En caso de error, se maneja el error y se envía una respuesta de error al cliente con un código de estado 500 (Error del servidor).


# cargar modelo
- Para la carga de contendio de todo el modelo se fue dividido en diferentes sub-rutas para especificar que contenido seria cargado para la tabla.
- En estas rutas se manejan solicitudes de tipo GET y esta recibe una solicitud de carga de datos de los archivos .csv. - 
- Dependiendo de que tabla se quiere cargar se especifica la ruta del archivo, las columnas de la tabla y por ultimo se manda a llamar a la función insertarDatosDesdeCSV del módulo cargarmodelo, pasando el nombre de la tabla, la ruta del archivo CSV y las columnas correspondientes.

![image](https://github.com/HugoGG202004807/ProyectosBD1_202004807/assets/81279833/5601b533-4a74-4f32-9c52-109554e6f2b3)

## /cargarmodelo/ordenes2
- Esta ruta es importante ya que en la tabla de ordenes hubieron valores repetidos y para evitar problemas esta ruta crea una nueva tabla llamada ordenes_unicos para almacenar ciertos valores de la tabla ordenes y la otra parte sera cargada a otra tabla llamada detalles_ordenes, posterior a esta carga se definen las llaves primarias y foraneas de las dos tablas para un mejor manejo de la informacion.
  
![image](https://github.com/HugoGG202004807/ProyectosBD1_202004807/assets/81279833/4e2ce86f-407c-4c35-90ef-464eb97dfd79)














