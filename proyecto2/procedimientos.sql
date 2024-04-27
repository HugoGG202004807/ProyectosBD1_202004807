-- REGISTRAR CLIENTES
CREATE OR REPLACE PROCEDURE registrarCliente(
    p_ID_CLIENTE  IN INTEGER,
    p_NOMBRE IN VARCHAR2,
    p_APELLIDO IN VARCHAR2,
    p_TELEFONO IN VARCHAR2,
    p_CORREO IN VARCHAR2,
    p_USUARIO IN VARCHAR2,
    p_CONTRASEÑA IN VARCHAR2,
    p_TIPO_CLIENTE IN INTEGER
)
AS
    v_Count INTEGER;
BEGIN
    -- Validación de letras para Nombre y Apellidos
    IF NOT REGEXP_LIKE(p_NOMBRE, '^[A-Za-zñÑ ]+$') THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre solo puede contener letras y espacios.');
    END IF;

    IF NOT REGEXP_LIKE(p_APELLIDO, '^[A-Za-zñÑ ]+$') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Los apellidos solo pueden contener letras y espacios.');
    END IF;

    -- Validación del formato del teléfono
    IF NOT REGEXP_LIKE(p_TELEFONO, '^[0-9]{8}(-[0-9]{8})*$') THEN
        RAISE_APPLICATION_ERROR(-20003, 'El formato del teléfono no es válido.');
    END IF;

    -- Validación del formato del correo electrónico
    IF NOT REGEXP_LIKE(p_CORREO, '^([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4})(\|([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}))*$') THEN
    RAISE_APPLICATION_ERROR(-20004, 'El formato del correo electrónico no es válido.');
    END IF;

    -- Validar disponibilidad del usuario
    SELECT COUNT(*)
    INTO v_Count
    FROM CLIENTES
    WHERE USUARIO = p_USUARIO;

    IF v_Count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'El usuario ya está en uso.');
    END IF;

    -- Validar que exista el tipo de cliente
    SELECT COUNT(*)
    INTO v_Count
    FROM TIPO_CLIENTE
    WHERE ID_TIPO_CLIENTE = p_TIPO_CLIENTE;

    IF v_Count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'El tipo de cliente especificado no existe.');
    END IF;

    -- Almacenar el cliente en la base de datos
    INSERT INTO CLIENTES (ID_CLIENTE, NOMBRE, APELLIDO, USUARIO, CONTRASEÑA, ID_TIPO_CLIENTE)
    VALUES (p_ID_CLIENTE, p_NOMBRE, p_APELLIDO, p_USUARIO, p_CONTRASEÑA, p_TIPO_CLIENTE);

    -- Almacenar los correos electrónicos en la tabla correos
    FOR x_correo IN (SELECT TRIM(REGEXP_SUBSTR(p_CORREO, '[^|]+', 1, LEVEL)) AS correo FROM DUAL CONNECT BY LEVEL <= REGEXP_COUNT(p_CORREO, '\|') + 1)
    LOOP
        INSERT INTO CORREOS (ID_CLIENTE, CORREO) VALUES (p_ID_CLIENTE, x_correo.correo);
    END LOOP;

    -- Almacenar los números de teléfono en la tabla telefonos
    FOR x_telefono IN (SELECT TRIM(REGEXP_SUBSTR(p_TELEFONO, '[^-]+', 1, LEVEL)) AS telefono FROM DUAL CONNECT BY LEVEL <= REGEXP_COUNT(p_TELEFONO, '-') + 1)
    LOOP
        INSERT INTO TELEFONOS (ID_CLIENTE, TELEFONO) VALUES (p_ID_CLIENTE, x_telefono.telefono);
    END LOOP;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20007, 'Error al registrar el cliente: ' || SQLERRM);
END;


-- REGISTRAR EL TIPO DE CLIENTE
CREATE OR REPLACE PROCEDURE registrarTipoCliente(
    p_id_tipo IN INTEGER,
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2
) AS
    v_max_id INTEGER;
BEGIN
    -- Obtener el máximo ID actualmente en la tabla
    SELECT NVL(MAX(ID_TIPO_CLIENTE), 0) INTO v_max_id FROM TIPO_CLIENTE;

    -- Verificar si el ID proporcionado sigue la secuencia
    IF p_id_tipo <= v_max_id THEN
        RAISE_APPLICATION_ERROR(-20002, 'El ID proporcionado no sigue la secuencia');
    END IF;

    -- Validar que la descripción sólo contenga letras
    IF NOT REGEXP_LIKE(p_descripcion, '^[A-ZÁÉÍÓÚÑa-záéíóúñ ]+$') THEN
        RAISE_APPLICATION_ERROR(-20001, 'La descripción sólo debe contener letras');
    END IF;

    -- Insertar el nuevo tipo de cliente
    INSERT INTO TIPO_CLIENTE (ID_TIPO_CLIENTE, NOMBRE, DESCRIPCION)
    VALUES (p_id_tipo, p_nombre, p_descripcion);

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error al registrar el tipo de cliente');
END registrarTipoCliente;

-- REGISTRAR CUENTA
CREATE OR REPLACE PROCEDURE registrarCuenta (
    p_ID_CUENTA IN INTEGER,
    p_MONTO_APERTURA IN NUMBER,
    p_SALDO_CUENTA IN NUMBER,
    p_DESCRIPCION IN VARCHAR2,
    p_FECHA_APERTURA IN VARCHAR2,
    p_OTROS_DETALLES IN VARCHAR2,
    p_TIPO_CUENTA IN INTEGER,
    p_ID_CLIENTE IN INTEGER
)
AS
    v_Count INTEGER;
    v_FECHA_APERTURA DATE;
BEGIN
    -- Validar que el monto de apertura sea positivo
    IF p_MONTO_APERTURA <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El monto de apertura debe ser positivo.');
    END IF;

    -- Validar que el saldo de la cuenta sea mayor o igual a 0
    IF p_SALDO_CUENTA < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El saldo de la cuenta debe ser mayor o igual a 0.');
    END IF;

    -- Validar que exista el tipo de cuenta
    SELECT COUNT(*)
    INTO v_Count
    FROM TIPO_CUENTA
    WHERE ID_TIPO_CUENTA = p_TIPO_CUENTA;

    IF v_Count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El tipo de cuenta especificado no existe.');
    END IF;

    -- Validar que exista el cliente
    SELECT COUNT(*)
    INTO v_Count
    FROM CLIENTES
    WHERE ID_CLIENTE = p_ID_CLIENTE;

    IF v_Count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'El cliente especificado no existe.');
    END IF;

    IF p_FECHA_APERTURA IS NULL THEN
    v_FECHA_APERTURA := SYSDATE; -- Si p_FECHA_APERTURA es nulo, asignamos SYSDATE
ELSE
    -- Intentar convertir la cadena de fecha con el formato esperado 'DD/MM/YYYY HH24:MI:SS'
    BEGIN
        v_FECHA_APERTURA := TO_DATE(p_FECHA_APERTURA, 'DD/MM/YYYY HH24:MI:SS');
    EXCEPTION
        -- En caso de error de conversión, intentar con otro formato 'MM/DD/YYYY HH24:MI:SS'
        WHEN OTHERS THEN
            BEGIN
                v_FECHA_APERTURA := TO_DATE(p_FECHA_APERTURA, 'MM/DD/YYYY HH24:MI:SS');
            EXCEPTION
                -- Si el segundo intento también falla, lanzar un error
                WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20007, 'Formato de fecha no válido.');
            END;
    END;
END IF;
    -- Insertar la cuenta en la base de datos
    INSERT INTO CUENTA (ID_CUENTA, MONTO_APERTURA, SALDO_CUENTA, DESCRIPCION, FECHA_APERTURA, OTROS_DETALLES, ID_TIPO_CUENTA, ID_CLIENTE)
    VALUES (p_ID_CUENTA, p_MONTO_APERTURA, p_SALDO_CUENTA, p_DESCRIPCION,v_FECHA_APERTURA, p_OTROS_DETALLES, p_TIPO_CUENTA, p_ID_CLIENTE);

    COMMIT;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20006, 'Se exedio el tamaño permitido para registrar los datos');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'Error al insertar: ' || SQLCODE || ' - ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE registrarTipoCuenta(
    p_codigo IN INTEGER DEFAULT NULL,
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2
) AS
    v_codigo INTEGER;
BEGIN
    -- Si se proporciona un código, usarlo, de lo contrario obtener el próximo código autoincrementable
    IF p_codigo IS NOT NULL THEN
        v_codigo := p_codigo;
    ELSE
        SELECT COALESCE(MAX(ID_TIPO_CUENTA), 0) + 1 INTO v_codigo FROM Tipo_Cuenta;
    END IF;

    -- Validar el nombre y la descripción
    IF LENGTH(p_nombre) > 50 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre no debe exceder los 50 caracteres.');
    END IF;

    IF LENGTH(p_descripcion) > 200 THEN
        RAISE_APPLICATION_ERROR(-20002, 'La descripción no debe exceder los 200 caracteres.');
    END IF;

    -- Insertar el nuevo tipo de cuenta
    INSERT INTO Tipo_Cuenta (ID_TIPO_CUENTA, NOMBRE, DESCRIPCION)
    VALUES (v_codigo, p_nombre, p_descripcion);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Error al registrar el tipo de cuenta: ' || SQLERRM);
END registrarTipoCuenta;

CREATE OR REPLACE PROCEDURE crearProductoServicio (
    p_codigo_producto_servicio IN INTEGER,
    p_tipo IN NUMBER,
    p_costo IN NUMBER,
    p_descripcion IN VARCHAR2
)
AS
BEGIN
    -- Validar que el código del producto/servicio sea positivo
    IF p_codigo_producto_servicio <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El código del producto/servicio debe ser un valor positivo.');
    END IF;

    -- Validar que el tipo sea 1 (servicio) o 2 (producto)
    IF p_tipo NOT IN (1, 2) THEN
        RAISE_APPLICATION_ERROR(-20002, 'El tipo de producto/servicio debe ser 1 (servicio) o 2 (producto).');
    END IF;

    -- Validar que el costo sea obligatorio si el tipo es servicio
    IF p_tipo = 1 AND p_costo IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'El costo es obligatorio para un servicio.');
    END IF;

    -- Validar que la descripción no esté vacía
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RAISE_APPLICATION_ERROR(-20004, 'La descripción del producto/servicio no puede estar vacía.');
    END IF;

    -- Si todo está bien, insertar el producto/servicio en la base de datos
    INSERT INTO PRODUCTOS_SERVICIOS (ID_PRODUCTO_SERVICIO, tipo, costo, descripcion)
    VALUES (p_codigo_producto_servicio, p_tipo, p_costo, p_descripcion);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'Error al crear el producto/servicio: ' || SQLCODE || ' - ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE realizarCompra (
    p_id_compra IN INTEGER,
    p_fecha IN VARCHAR2,
    p_importe_compra IN NUMBER,
    p_otros_detalles IN VARCHAR2,
    p_codigo_producto_servicio IN INTEGER,
    p_id_cliente IN INTEGER
)
AS
    v_tipo_producto_servicio INTEGER;
    v_fecha DATE;
BEGIN
    -- Validar que el id_compra sea positivo
    IF p_id_compra <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El ID de la compra debe ser un valor positivo.');
    END IF;

    -- Si la fecha es nula, autocompletar con la fecha de hoy

    IF p_FECHA IS NULL THEN
        v_FECHA := SYSDATE;
    ELSE
        v_FECHA := TO_DATE(p_FECHA, 'DD/MM/YYYY');
    END IF;

    -- Validar que exista el cliente
    SELECT COUNT(*) INTO v_tipo_producto_servicio
    FROM CLIENTES
    WHERE ID_CLIENTE = p_id_cliente;

    IF v_tipo_producto_servicio = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El cliente especificado no existe.');
    END IF;

    -- Validar que exista el producto/servicio
    SELECT tipo INTO v_tipo_producto_servicio
    FROM PRODUCTOS_SERVICIOS
    WHERE ID_PRODUCTO_SERVICIO = p_codigo_producto_servicio;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'El producto/servicio especificado no existe.');
    END IF;

     -- Validar el importe de la compra según el tipo de producto/servicio
    IF v_tipo_producto_servicio = 1 THEN -- Si es un servicio
        IF p_importe_compra IS NOT NULL AND p_importe_compra != 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'El monto debería ser cero porque ya tiene un precio preestablecido por ser un servicio.');
        END IF;
    ELSIF v_tipo_producto_servicio = 2 THEN -- Si es un producto
        IF p_importe_compra <= 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'El monto debería ser mayor a cero ya que es un producto y no tiene un precio preestablecido.');
        END IF;
    END IF;

    BEGIN
        -- Insertar la compra en la base de datos
        INSERT INTO COMPRAS (ID_COMPRA, FECHA_COMPRA, IMPORTE, OTROS_DETALLES, ID_PRODUCTO_SERVICIO, ID_CLIENTE)
        VALUES (p_id_compra, v_fecha, p_importe_compra, p_otros_detalles, p_codigo_producto_servicio, p_id_cliente);

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20007, 'Error al realizar la compra: ' || SQLCODE || ' - ' || SQLERRM);
    END;
END;

CREATE OR REPLACE PROCEDURE realizarDeposito (
    p_id_deposito IN INTEGER,
    p_fecha IN VARCHAR2,
    p_monto IN NUMBER,
    p_otros_detalles IN VARCHAR2,
    p_id_cliente IN INTEGER
)
AS
    v_count INTEGER;
    v_fecha DATE;
BEGIN
    -- Validar que el id_deposito sea positivo
    IF p_id_deposito <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El ID del depósito debe ser un valor positivo.');
    END IF;

    -- Si la fecha es nula, autocompletar con la fecha de hoy
    IF p_FECHA IS NULL THEN
        v_FECHA := SYSDATE;
    ELSE
        v_FECHA := TO_DATE(p_FECHA, 'DD/MM/YYYY');
    END IF;

    -- Validar que exista el cliente
    SELECT COUNT(*)
    INTO v_Count
    FROM CLIENTES
    WHERE ID_CLIENTE = p_ID_CLIENTE;

    IF v_Count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El cliente especificado no existe.');
    END IF;

    -- Validar que el monto del depósito sea mayor que cero
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El monto del depósito debe ser mayor que cero.');
    END IF;

    -- Insertar el depósito en la base de datos
    INSERT INTO DEPOSITO (ID_DEPOSITO, FECHA_DEPOSITO, MONTO, OTROS_DETALLES, ID_CLIENTE)
    VALUES (p_id_deposito, v_fecha, p_monto, p_otros_detalles, p_id_cliente);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Error al realizar el depósito: ' || SQLCODE || ' - ' || SQLERRM);
END;


CREATE OR REPLACE PROCEDURE realizarDebito (
    p_id_debito IN INTEGER,
    p_fecha IN VARCHAR2,
    p_monto IN NUMBER,
    p_otros_detalles IN VARCHAR2,
    p_id_cliente IN INTEGER
)
AS
    v_count INTEGER;
    v_fecha DATE;
BEGIN
    -- Validar que el id_deposito sea positivo
    IF p_id_debito <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El ID del debito debe ser un valor positivo.');
    END IF;

    -- Si la fecha es nula, autocompletar con la fecha de hoy
    IF p_FECHA IS NULL THEN
        v_FECHA := SYSDATE;
    ELSE
        v_FECHA := TO_DATE(p_FECHA, 'DD/MM/YYYY');
    END IF;

    -- Validar que exista el cliente
    SELECT COUNT(*)
    INTO v_Count
    FROM CLIENTES
    WHERE ID_CLIENTE = p_ID_CLIENTE;

    IF v_Count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El cliente especificado no existe.');
    END IF;

    -- Validar que el monto del depósito sea mayor que cero
    IF p_monto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El monto del depósito debe ser mayor que cero.');
    END IF;

    -- Insertar el depósito en la base de datos
    INSERT INTO DEBITO (ID_DEBITO, FECHA_DEBITO, MONTO, OTROS_DETALLES, ID_CLIENTE)
    VALUES (p_id_debito, v_fecha, p_monto, p_otros_detalles, p_id_cliente);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Error al realizar el debito: ' || SQLCODE || ' - ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE asignarTransaccion (
    p_id_transaccion IN INTEGER,
    p_fecha IN VARCHAR2,
    p_otros_detalles IN VARCHAR2,
    p_id_tipo_transaccion IN INTEGER,
    p_id_servicio IN INTEGER,
    p_no_cuenta IN NUMBER
)
AS
    v_count INTEGER;
    v_saldo_cuenta NUMBER;
    v_FECHA DATE;
    v_count_compras INTEGER;
    v_count_deposito INTEGER;
    v_count_debito INTEGER;
BEGIN
    -- Convertir la fecha si se proporciona
    IF p_fecha IS NULL THEN
        v_FECHA := SYSDATE;
    ELSE
        BEGIN
            v_FECHA := TO_DATE(p_fecha, 'DD/MM/YYYY HH24:MI:SS');
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20009, 'Formato de fecha no válido.');
        END;
    END IF;

    -- Validar que el ID de la transacción sea un número continuo
    IF p_id_transaccion IS NULL OR p_id_transaccion <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El ID de la transacción debe ser un número positivo.');
    END IF;

   -- Validar que exista el tipo de transacción
    SELECT COUNT(*)
    INTO v_count
    FROM TIPO_TRANSACCION
    WHERE ID_TIPO_TRANSACCION = p_id_tipo_transaccion;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El tipo de transacción especificado no existe.');
    END IF;

    -- Validar que exista el registro correspondiente a la transacción
    IF p_id_servicio IS NOT NULL THEN
        -- Verificar si el p_id_servicio existe en la tabla COMPRAS
        SELECT COUNT(*)
        INTO v_count_compras
        FROM COMPRAS
        WHERE ID_COMPRA = p_id_servicio;

        -- Verificar si el p_id_servicio existe en la tabla DEPOSITO
        SELECT COUNT(*)
        INTO v_count_deposito
        FROM DEPOSITO
        WHERE ID_DEPOSITO = p_id_servicio;

        -- Verificar si el p_id_servicio existe en la tabla DEBITO
        SELECT COUNT(*)
        INTO v_count_debito
        FROM DEBITO
        WHERE ID_DEBITO = p_id_servicio;

        -- Si ninguna tabla contiene el p_id_servicio, lanzar un error
        IF v_count_compras = 0 AND v_count_deposito = 0 AND v_count_debito = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La compra/deposito/servicio especificada no existe.');
        END IF;
    END IF;

    -- Validar que la cuenta corresponda al cliente
    SELECT COUNT(*)
    INTO v_count
    FROM CUENTA
    WHERE ID_CUENTA = p_no_cuenta;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'La cuenta especificada no corresponde a ningún cliente.');
    END IF;

    -- Verificar el saldo suficiente solo si se especifica un servicio y el tipo de transacción es compra o débito
    IF p_id_servicio IS NOT NULL AND (p_id_tipo_transaccion = 1 OR p_id_tipo_transaccion = 3) THEN
        SELECT SALDO_CUENTA INTO v_saldo_cuenta FROM CUENTA WHERE ID_CUENTA = p_no_cuenta;
        IF v_saldo_cuenta < 0 THEN
            RAISE_APPLICATION_ERROR(-20008, 'La cuenta tiene saldo negativo.');
        END IF;

        SELECT IMPORTE INTO v_count FROM COMPRAS WHERE ID_COMPRA = p_id_servicio;

        IF v_saldo_cuenta < v_count THEN
            RAISE_APPLICATION_ERROR(-20008, 'La cuenta no tiene saldo suficiente para realizar esta transacción.');
        END IF;
    END IF;

    -- Insertar la transacción en la base de datos
    INSERT INTO TRANSACCION (ID_TRANSACCION, FECHA_TRANSACCION,OTROS_DETALLES,ID_TIPO_TRANSACCION, ID_SERVICIO, ID_CUENTA)
    VALUES (p_id_transaccion, v_FECHA, p_otros_detalles, p_id_tipo_transaccion, p_id_servicio, p_no_cuenta);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'Error al asignar la transacción: ' || SQLCODE || ' - ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE registrarTipoTransaccion (
    p_codigo_transaccion IN INTEGER,
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2
)
AS
    v_max_id INTEGER;
BEGIN
    -- Validar que el código de transacción sea un número positivo
    IF p_codigo_transaccion <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El código de transacción debe ser un número positivo.');
    END IF;

    -- Obtener el máximo ID actualmente en la tabla
    SELECT NVL(MAX(ID_TIPO_TRANSACCION), 0) INTO v_max_id FROM TIPO_TRANSACCION;

    -- Validar que el código de transacción sea único y consecutivo
    IF p_codigo_transaccion <= v_max_id THEN
        RAISE_APPLICATION_ERROR(-20002, 'El código de transacción no sigue un orden incremental.');
    END IF;

    -- Insertar el tipo de transacción en la base de datos
    INSERT INTO TIPO_TRANSACCION (ID_TIPO_TRANSACCION, NOMBRE, DESCRIPCION)
    VALUES (p_codigo_transaccion, p_nombre, p_descripcion);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Error al registrar el tipo de transacción: ' || SQLCODE || ' - ' || SQLERRM);
END;

