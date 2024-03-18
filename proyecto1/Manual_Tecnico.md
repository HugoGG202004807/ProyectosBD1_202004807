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

## consulta1
Mostrar el cliente que más ha comprado. Ya que se espera el cliente que mas ha comprado se ordenaron los datos por el numero de compras realizadas y no por el monto total.
```sh
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
```
## consulta2
- Mostrar el producto más y menos comprado.
```sh
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
```

## consulta3
Mostrar a la persona que más ha vendido.
```sh
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
```

## consulta4
Mostrar el país que más y menos ha vendido.
```sh
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
```

## consulta5
Top 5 de países que más han comprado en orden ascendente.
```sh
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
```

## consulta6
Mostrar la categoría que más y menos se ha comprado en una sola consulta.
```sh
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

```

## consulta7
Mostrar la categoría más comprada por cada país.
```sh
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
```

## consulta8
Mostrar las ventas por mes de Inglaterra.
```sh
SELECT TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM') AS numero_mes,
TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'Month') AS nombre_mes,
SUM(det.CANTIDAD * prod.PRECIO) AS monto
FROM VENDEDORES vend
JOIN PAISES pais ON vend.ID_PAIS = pais.ID_PAIS
JOIN DETALLES_ORDENES det ON vend.ID_VENDEDOR=det.ID_VENDEDOR
JOIN PRODUCTOS prod ON det.ID_PRODUCTO=prod.ID_PRODUCTO
JOIN ORDENES_UNICOS ord ON det.ID_ORDEN= ord.ID_ORDEN

WHERE pais.NOMBRE = 'Inglaterra'
GROUP BY TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM'),
        TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'Month')
ORDER BY TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM')
```

## consulta9
Mostrar el mes con más y menos ventas.
```sh
SELECT numero_mes, monto
FROM (
    SELECT TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM') AS numero_mes,
           SUM(det.CANTIDAD * prod.PRECIO) AS monto
    FROM ORDENES_UNICOS ord
    JOIN DETALLES_ORDENES det ON ord.ID_ORDEN = det.ID_ORDEN
    JOIN PRODUCTOS prod ON det.ID_PRODUCTO = prod.ID_PRODUCTO
    GROUP BY TO_CHAR(TO_DATE(FECHA_ORDEN, 'DD-MM-YYYY'), 'MM')
    ORDER BY SUM(det.CANTIDAD) DESC
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
    ORDER BY SUM(det.CANTIDAD) ASC
)
WHERE ROWNUM = 1
```

## consulta10
Mostrar las ventas de cada producto de la categoría deportes.
```sh
SELECT det.ID_PRODUCTO, prod.NOMBRE AS nombre_producto, SUM(det.CANTIDAD * prod.PRECIO) AS monto
FROM DETALLES_ORDENES det
JOIN PRODUCTOS prod ON det.ID_PRODUCTO = prod.ID_PRODUCTO
JOIN CATEGORIAS cat ON prod.ID_CATEGORIA = cat.ID_CATEGORIA
WHERE cat.NOMBRE = 'Deportes'
GROUP BY det.ID_PRODUCTO, prod.NOMBRE
```






