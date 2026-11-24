# Proyectos de Bases de Datos 1 - USAC (2024)

Repositorio que reúne dos proyectos académicos desarrollados para el curso de Bases de Datos 1 en la Universidad de San Carlos de Guatemala durante el primer semestre de 2024. Los proyectos abarcan desde el modelado relacional, la carga masiva y normalización de datos mediante una API REST en Node.js, hasta la implementación de lógica transaccional bancaria y auditoría automatizada con PL/SQL en Oracle Database.

---

## Contenido del Repositorio

- [Proyecto 1: Sistema de Carga Masiva y Analítica de Ventas](#proyecto-1-sistema-de-carga-masiva-y-analítica-de-ventas)
- [Proyecto 2: Sistema Transaccional Bancario y Auditoría](#proyecto-2-sistema-transaccional-bancario-y-auditoría)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Instrucciones de Ejecución](#instrucciones-de-ejecución)

---

## Proyecto 1: Sistema de Carga Masiva y Analítica de Ventas

### Objetivo
Diseñar e implementar un almacén de datos relacional en Oracle Database alimentado desde múltiples fuentes CSV, resolver problemas de inconsistencia y redundancia en órdenes de compra mediante técnicas de desduplicación en base de datos, y exponer consultas de reportería analítica a través de una API en Node.js.

### Modelo de Datos
El modelo se compone de **8 tablas** en Oracle Database:
1. `PAISES`: Catálogo de países (`ID_PAIS`, `NOMBRE`).
2. `CATEGORIAS`: Catálogo de categorías de productos (`ID_CATEGORIA`, `NOMBRE`).
3. `PRODUCTOS`: Catálogo de artículos (`ID_PRODUCTO`, `NOMBRE`, `PRECIO`, `ID_CATEGORIA`).
4. `CLIENTES`: Registro de clientes (`ID_CLIENTE`, `NOMBRE`, `APELLIDO`, `DIRECCION`, `TELEFONO`, `TARJETA`, `EDAD`, `SALARIO`, `GENERO`, `ID_PAIS`).
5. `VENDEDORES`: Empleados encargados de las ventas (`ID_VENDEDOR`, `NOMBRE`, `ID_PAIS`).
6. `ORDENES`: Tabla intermedia de carga para órdenes de compra (`ID_ORDEN`, `FECHA_ORDEN`, `ID_CLIENTE`).
7. `DETALLES_ORDENES`: Detalle de productos asociados a cada orden (`LINEA_ORDEN`, `ID_VENDEDOR`, `ID_PRODUCTO`, `CANTIDAD`, `ID_ORDEN`).
8. `ORDENES_UNICOS`: Tabla normalizada y definitiva creada tras la desduplicación de órdenes (`ID_ORDEN`, `FECHA_ORDEN`, `ID_CLIENTE`).

**Relaciones principales:**
- `CLIENTES` y `VENDEDORES` se relacionan con `PAISES` mediante `ID_PAIS`.
- `PRODUCTOS` se relaciona con `CATEGORIAS` mediante `ID_CATEGORIA`.
- `ORDENES_UNICOS` tiene clave foránea hacia `CLIENTES` (`ID_CLIENTE`).
- `DETALLES_ORDENES` enlaza con `ORDENES_UNICOS` (`ID_ORDEN`), `VENDEDORES` (`ID_VENDEDOR`) y `PRODUCTOS` (`ID_PRODUCTO`).

### Componentes y Funcionalidades
- **Carga Masiva de Datos:** Se implementó en Node.js utilizando lectura en flujo (`fs.createReadStream`) y el analizador `csv-parser` con delimitador `;`. La inserción a Oracle se realiza en bloques optimizados mediante `connection.executeMany()`.
- **API REST (Express.js):** Consta de **21 endpoints** (todos HTTP GET) organizados en controladores modulares:
  - `1` endpoint de verificación general (`/`).
  - `1` endpoint para crear el esquema inicial (`/crearmodelo`).
  - `6` endpoints de carga de archivos CSV (`/cargarmodelo/paises`, `/cargarmodelo/categorias`, `/cargarmodelo/productos`, `/cargarmodelo/vendedores`, `/cargarmodelo/clientes`, `/cargarmodelo/ordenes`).
  - `1` endpoint de transformación y normalización (`/cargarmodelo/ordenes2`).
  - `2` endpoints de mantenimiento (`/borrarinfodb` para truncar datos y `/eliminarmodelo` para eliminar tablas).
  - `10` endpoints de consultas analíticas (`/consulta1` a `/consulta10`).
- **Consultas Analíticas (10 consultas):**
  1. *Cliente con más compras:* Identifica al cliente con mayor frecuencia de compras usando `COUNT` y agregaciones.
  2. *Producto más y menos comprado:* Retorna el producto líder y el menos vendido en unidades e ingresos.
  3. *Vendedor con mayor volumen de ventas:* Identifica al vendedor con mayor facturación monetaria.
  4. *País con mayor y menor venta:* Utiliza `UNION ALL` y subconsultas para identificar extremos geográficos de venta.
  5. *Top 5 países compradores:* Calcula las ventas totales por país en orden ascendente limitado con `FETCH FIRST 5 ROWS ONLY`.
  6. *Categoría más y menos vendida:* Consulta unificada con `UNION ALL` evaluando cantidades totales por categoría.
  7. *Categoría más vendida por país:* Utiliza funciones de ventana (`ROW_NUMBER() OVER (PARTITION BY pais.ID_PAIS ORDER BY SUM(det.CANTIDAD) DESC)`) para extraer el ranking #1 de cada país.
  8. *Ventas mensuales en Inglaterra:* Agrupación temporal con conversión `TO_DATE` y extracción de mes en texto y número (`TO_CHAR`).
  9. *Mes con mayor y menor venta:* Comparación de extremos temporales de ventas mediante `UNION ALL`.
  10. *Ventas de categoría Deportes:* Agregación de unidades e ingresos filtrada específicamente para artículos deportivos.

### Decisiones de Diseño
- **Estrategia Staging y Post-Normalización:** Debido a duplicados e inconsistencias en el conjunto de órdenes original, los datos de órdenes se cargan inicialmente en una tabla intermedia sin restricciones estrictas (`ORDENES`). Posteriormente, el endpoint `/cargarmodelo/ordenes2` extrae los registros únicos mediante `GROUP BY`, genera la tabla `ORDENES_UNICOS`, aplica las restricciones de clave primaria y claves foráneas, y finalmente trunca la tabla intermedia.
- **Inserción por Lotes en Node.js:** En lugar de ejecutar inserciones individuales (fila por fila), utilicé `executeMany` con `autoCommit` y manejo explícito de transacciones, reduciendo drásticamente la latencia de red contra el motor de base de datos.

---

## Proyecto 2: Sistema Transaccional Bancario y Auditoría

### Objetivo
Diseñar la arquitectura de base de datos y la lógica de negocio para una entidad bancaria, asegurando la integridad de las transacciones (aperturas de cuenta, depósitos, retiros y compras), validando entradas mediante reglas estrictas en PL/SQL y manteniendo una traza de auditoría transparente y automatizada mediante triggers.

### Modelo de Datos
El modelo consta de **13 tablas** en Oracle Database:
1. `CLIENTES`: Datos maestros del cliente y credenciales de acceso.
2. `TELEFONOS`: Almacena múltiples números telefónicos por cliente (1:N).
3. `CORREOS`: Almacena múltiples direcciones de correo por cliente (1:N).
4. `TIPO_CLIENTE`: Clasificación de clientes (Individual Nacional, Extranjero, PyMe, etc.).
5. `CUENTA`: Cuentas monetarias o de ahorro asociadas a clientes.
6. `TIPO_CUENTA`: Clasificación de cuentas bancarias (Cheques, Ahorros, Nómina, etc.).
7. `PRODUCTOS_SERVICIOS`: Catálogo de servicios bancarios (costo fijo) y productos/pagos (costo variable).
8. `COMPRAS`: Registro de pagos de servicios o consumos de productos.
9. `DEPOSITO`: Registro de depósitos monetarios en cuentas.
10. `DEBITO`: Registro de retiros o débitos monetarios.
11. `TRANSACCION`: Libro mayor que centraliza y clasifica los movimientos financieros.
12. `TIPO_TRANSACCION`: Catálogo de operaciones (Compra, Depósito, Débito).
13. `HISTORIAL`: Tabla centralizada de auditoría para registro de eventos DML.

### Componentes y Funcionalidades
- **Procedimientos Almacenados de Gestión y Transacciones (10 procedimientos en `procedimientos.sql`):**
  1. `registrarCliente`: Valida formato alfabético en nombres, valida teléfonos y correos múltiples, verifica unicidad de usuario y parsea cadenas concatenadas para poblar `CLIENTES`, `TELEFONOS` y `CORREOS`.
  2. `registrarTipoCliente`: Valida enteros positivos y descripciones alfabéticas antes de registrar.
  3. `registrarCuenta`: Valida montos de apertura positivos, saldos coherentes, existencia de llaves foráneas y soporte de formatos de fecha alternativos.
  4. `registrarTipoCuenta`: Maneja autoincremento manual si no se proporciona ID y valida límites de caracteres.
  5. `crearProductoServicio`: Diferencia reglas de negocio entre servicios (tipo 1, costo obligatorio mayor a cero) y productos (tipo 2, precio inicial cero/variable).
  6. `realizarCompra`: Verifica existencia de cliente y servicio/producto, asegurando coherencia en el importe según el tipo de servicio.
  7. `realizarDeposito`: Valida importes positivos y existencia de cliente.
  8. `realizarDebito`: Valida montos de retiro mayores a cero y persistencia de operaciones.
  9. `asignarTransaccion`: Valida y asocia la transacción financiera con su correspondiente registro de compra, débito o depósito y con la cuenta afectada.
  10. `registrarTipoTransaccion`: Valida que los identificadores sigan un orden correlativo e incremental.
- **Triggers de Auditoría (10 triggers en `triggers.sql`):**
  - Triggers a nivel de fila (`AFTER INSERT OR DELETE OR UPDATE FOR EACH ROW`) sobre las 10 tablas transaccionales y de catálogo: `TIPO_CLIENTE`, `CLIENTES`, `CUENTA`, `TIPO_CUENTA`, `PRODUCTOS_SERVICIOS`, `COMPRAS`, `DEPOSITO`, `DEBITO`, `TRANSACCION` y `TIPO_TRANSACCION`.
  - Cada trigger detecta la operación ejecutada (`INSERTING`, `UPDATING`, `DELETING`) e inserta automáticamente un registro en la tabla `HISTORIAL` con la descripción del evento y la estampa de tiempo (`CURRENT_TIMESTAMP`).
- **Procedimientos Almacenados de Consulta (6 procedimientos en `consultas.sql`):**
  1. `consultarSaldoCliente`: Consulta saldos actuales y datos de cuenta mediante salidas `DBMS_OUTPUT`.
  2. `consultarCliente`: Muestra el perfil completo de un cliente utilizando `LISTAGG` para agrupar múltiples teléfonos, correos y tipos de cuentas asociadas.
  3. `consultarMovsCliente`: Itera mediante un cursor los movimientos históricos detallando tipo de servicio y montos.
  4. `consultarTipoCuentas`: Resume la cantidad de clientes que poseen un tipo de cuenta determinado.
  5. `consultarMovsGenFech`: Filtra transacciones dentro de un intervalo de fechas.
  6. `consultarProductoServicio`: Retorna un cursor de referencia (`SYS_REFCURSOR`) con el catálogo completo de productos y servicios.

### Decisiones de Diseño
- **Normalización de Atributos Multivaluados:** Los números de teléfono y correos electrónicos se envían al procedimiento en cadenas delimitadas (por guiones o plecas `|`) y se distribuyen en tablas hijas independientes (`TELEFONOS` y `CORREOS`) mediante consultas jerárquicas con expresiones regulares (`REGEXP_SUBSTR` y `CONNECT BY LEVEL`).
- **Validaciones Rigurosas en el Servidor de BD:** Toda la integridad lógica (formato de correo, validación de caracteres en nombres, coherencia en importes de servicios) fue implementada dentro de los procedimientos almacenados mediante `REGEXP_LIKE` y excepciones personalizadas (`RAISE_APPLICATION_ERROR`).
- **Desacoplamiento de Auditoría:** En lugar de saturar la lógica procedimental con inserciones de bitácora, la auditoría se delegó por completo a triggers DML que reaccionan automáticamente a cualquier cambio en las tablas monitoreadas.

---

## Estructura del Proyecto

```text
ProyectosBD1/
├── categorias.csv                # Datos fuente: 16 categorías
├── clientes.csv                  # Datos fuente: 20 000 clientes
├── ordenes.csv                   # Datos fuente: 60 350 registros de órdenes
├── ordenes2.csv                  # Datos fuente utilizados por la API: 60 350 registros
├── paises.csv                    # Datos fuente: 11 países
├── productos.csv                 # Datos fuente: 10 000 productos
├── vendedores.csv                # Datos fuente: 100 vendedores
├── README.md                     # Documentación principal del repositorio
│
├── proyecto1/                    # Proyecto 1: API REST y Analítica
│   ├── app.js                    # Punto de entrada de la aplicación Express (puerto 3000)
│   ├── package.json              # Manifiesto y dependencias del proyecto Node.js
│   ├── package-lock.json         # Árbol de dependencias bloqueadas
│   ├── crear_modelo.js           # Script de definición DDL de tablas iniciales en Node.js
│   ├── routes.js                 # Definición de los 21 endpoints HTTP
│   ├── routes_cargarmodelo.js    # Lógica de carga masiva CSV y desduplicación de órdenes
│   ├── routes_consultas.js       # Controladores de las 10 consultas analíticas
│   ├── routes_eliminar.js        # Controladores para truncado y eliminación de tablas
│   ├── script.sql                # Resumen SQL de DDL, DML y consultas del proyecto 1
│   ├── Manual_Tecnico.md         # Manual técnico detallado del proyecto 1
│   ├── Diseño Logico.pdf         # Diagrama de diseño lógico de datos
│   └── Diseño Relacional.pdf     # Diagrama de modelo relacional
│
└── proyecto2/                    # Proyecto 2: Lógica Transaccional PL/SQL
    ├── script.sql                # Definición DDL de 13 tablas y claves foráneas
    ├── procedimientos.sql        # 10 procedimientos almacenados de gestión y transacciones
    ├── triggers.sql              # 10 triggers DML de auditoría sobre tablas operativas
    ├── consultas.sql             # 6 procedimientos almacenados de reportería y consultas
    ├── datos_iniciales.sql       # Script de inserción de catálogos y datos iniciales
    ├── entradaEjemplo.sql        # Casos de prueba de transacciones y validaciones
    ├── modelo conceptual.svg     # Diagrama conceptual del sistema bancario
    ├── Modelo Logicol.pdf        # Diagrama lógico de la base de datos
    └── Modelo Relacional.pdf     # Diagrama relacional de la base de datos
```

---

## Tecnologías Utilizadas

- **Sistemas Gestores de Bases de Datos:**
  - Oracle Database (conectado mediante servicio local `localhost:1521/free`).
  - Lenguajes: SQL y PL/SQL (Procedural Language/Structured Query Language).
- **Backend y Entorno de Ejecución:**
  - Node.js
  - Express.js (`^4.18.3`)
- **Controladores y Librerías (Node.js):**
  - `oracledb` (`^6.3.0`): Driver oficial para conectividad y operaciones por lotes en Oracle.
  - `csv-parser` (`^3.0.0`): Procesamiento en flujo (streams) de archivos CSV delimitados.
  - `fs`: Módulo nativo del sistema de archivos.

---

## Instrucciones de Ejecución

### Requisitos Previos
1. Instancia activa de **Oracle Database** con un usuario configurado con privilegios DDL y DML.
2. **Node.js** (versión 18 o superior recomendada) y gestor de paquetes `npm`.
3. Cliente SQL para Oracle (SQL Developer, SQL*Plus, DBeaver o similar).

---

### Ejecución del Proyecto 1 (API y Carga Masiva)

1. **Configurar el entorno:**
   Navegar al directorio del proyecto e instalar dependencias:
   ```bash
   cd proyecto1
   npm install
   ```

2. **Ajustar variables de conexión y rutas de archivos:**
   - En `proyecto1/routes.js`, `proyecto1/routes_cargarmodelo.js`, `proyecto1/routes_consultas.js` y `proyecto1/routes_eliminar.js`, configurar las credenciales de Oracle Database (`user`, `password`, `connectString`).
   - En `proyecto1/routes.js`, actualizar las rutas absolutas donde se encuentran los archivos `.csv` en su sistema de archivos local.

3. **Iniciar la API:**
   ```bash
   node app.js
   ```
   El servidor iniciará en `http://localhost:3000`.

4. **Secuencia recomendada de llamadas HTTP:**
   - **Paso 1 (Creación de tablas):** `GET http://localhost:3000/crearmodelo`
   - **Paso 2 (Carga de catálogos y maestros):**
     - `GET http://localhost:3000/cargarmodelo/paises`
     - `GET http://localhost:3000/cargarmodelo/categorias`
     - `GET http://localhost:3000/cargarmodelo/productos`
     - `GET http://localhost:3000/cargarmodelo/vendedores`
     - `GET http://localhost:3000/cargarmodelo/clientes`
   - **Paso 3 (Carga de transacciones crudas):**
     - `GET http://localhost:3000/cargarmodelo/ordenes`
   - **Paso 4 (Normalización y desduplicación):**
     - `GET http://localhost:3000/cargarmodelo/ordenes2`
   - **Paso 5 (Consultas analíticas):**
     - Realizar peticiones `GET` a las rutas `/consulta1` hasta `/consulta10`.
   - **Limpieza (Opcional):**
     - `GET http://localhost:3000/borrarinfodb` (vacía los datos con `TRUNCATE`).
     - `GET http://localhost:3000/eliminarmodelo` (elimina el esquema con `DROP TABLE`).

---

### Ejecución del Proyecto 2 (Base de Datos Transaccional PL/SQL)

Abrir una sesión SQL en Oracle Database con permisos adecuados y ejecutar los scripts en el siguiente orden secuencial estricto:

1. **Creación del esquema relacional (13 tablas y restricciones FK):**
   ```sql
   @proyecto2/script.sql
   ```

2. **Compilación de triggers de auditoría (10 triggers DML):**
   ```sql
   @proyecto2/triggers.sql
   ```

3. **Compilación de procedimientos almacenados transaccionales (10 procedimientos):**
   ```sql
   @proyecto2/procedimientos.sql
   ```

4. **Compilación de procedimientos de consulta (6 procedimientos):**
   ```sql
   @proyecto2/consultas.sql
   ```

5. **Poblado inicial de catálogos y tipos:**
   ```sql
   @proyecto2/datos_iniciales.sql
   ```

6. **Pruebas transaccionales y validación de reglas:**
   Activar la salida por consola y ejecutar el script de pruebas:
   ```sql
   SET SERVEROUTPUT ON;
   @proyecto2/entradaEjemplo.sql
   ```
