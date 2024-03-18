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

# Archivo routes_cargarmodelo.js
## Modulos utilizados
- oracledb: Este módulo proporciona una API para interactuar con bases de datos Oracle desde Node.js.
- csv-parser: Este módulo facilita el análisis de archivos CSV en Node.js.
- fs: Este módulo proporciona funciones para trabajar con el sistema de archivos en Node.js.
## function insertarDatosDesdeCSV(req, res, tabla, csvFilePath, columnas)
- req: La solicitud HTTP entrante.
- res: La respuesta HTTP que se enviará al cliente.
- tabla: El nombre de la tabla en la base de datos Oracle donde se insertarán los datos.
- csvFilePath: La ruta al archivo CSV desde donde se leerán los datos.
- columnas: Un array que contiene los nombres de las columnas en la tabla de la base de datos a las que se insertarán los datos.
* Luego de establecer una conexion con la base de datos, se procede a recolectar la informacion del archivo .csv separando los valores por el simbolo de punto y coma para posterior insertarlos en su respectiva columna en la base de datos. finalmente se ejecuta la consulta de inserción utilizando connection.executeMany() para insertar los datos en la tabla de la base de datos.
Si ocurre algún error durante el proceso de lectura del archivo CSV o la inserción de datos en la base de datos, se maneja en los eventos 'error' y se envía una respuesta de error al cliente. En este archivo hay 2 funciones insertarDatosDesdeCSV e insertarDatosDesdeCSV2  y la diferencia es que en la primera luego de insertar los datos envia una respuesta inmediatamente desde la funcion y la segunda retorna al endpoint para que posterior se pueda cargar otra tabla o enviar los datos al terminar, eso se implemento ya que en la carga de ordenes fue necesario llenar la tabla ordenes y luego la de detalles_ordenes desde el mismo endpoint.
## function modificaciones_tablas()
- Se conecta a la base de datos y ejecuta varios queries con el proposito de crear la nueva tabla llamada ordenes_unicos e insertar los valores pero agrupandolos para evitar valores repetidos, y finalmente ya se pueden enlazar las demas tablas asignandoles las llaves foraneas a la tabla ordenes_unicos y detalles_ordenes.

```sh
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
```

# Eliminar datos y tablas 
- La primer ruta elimina todas las tablas que se encuentren y la segunda unicamente borra los datos de las tablas sin eliminar el modelo.
  
```sh
app.get('/eliminarmodelo', async (req, res) => {
  await eliminar.todo(req, res);
});

app.get('/borrarinfodb', async (req, res) => {
  await eliminar.informacion(req, res);
});
```
# Archivo routes_eliminar.js
## function todo(req, res)
- Se conecta a la base de datos y por medio de una variables con un string con varios queries se ejecutan los queries uno por uno eliminando cada una de las tablas y especificante en ese orden ya que asi se evitan los conflictos con las asignaciones de llaves foraneas.
  
```sh
DROP TABLE DETALLES_ORDENES;
DROP TABLE ORDENES_UNICOS;
DROP TABLE CLIENTES;
DROP TABLE VENDEDORES;
DROP TABLE PAISES;
DROP TABLE PRODUCTOS;
DROP TABLE CATEGORIAS;
DROP TABLE ORDENES;
```

## function informacion(req, res)

-Se utiliza el mismo procedimiento asi como en la funcion anterior solo que los comandos cambian y ya que solo se trata de los valores de las columnas entonces no importaria el orden de eliminacion.

```sh
TRUNCATE TABLE DETALLES_ORDENES;
TRUNCATE TABLE ORDENES_UNICOS;
TRUNCATE TABLE CLIENTES;
TRUNCATE TABLE VENDEDORES;
TRUNCATE TABLE PAISES;
TRUNCATE TABLE PRODUCTOS;
TRUNCATE TABLE CATEGORIAS;
```
# Consultas
- Todas las consultas se ejecutan de la misma forma, se establece una conexion en la base de datos de oracle, luego se le asigna a una variable el string con los queries necesarios para la consulta y se ejecutan para posterior retornar un json con el resultado de cada consulta.
  
![image](https://github.com/HugoGG202004807/ProyectosBD1_202004807/assets/81279833/04dfd766-4333-4d71-96b5-1d676cb017ef)










