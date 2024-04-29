
CREATE PROCEDURE consultarSaldoCliente (
    p_no_cuenta IN NUMBER
)
AS
    v_nombre_cliente CLIENTES.NOMBRE%TYPE;
    v_tipo_cliente TIPO_CLIENTE.NOMBRE%TYPE;
    v_tipo_cuenta TIPO_CUENTA.NOMBRE%TYPE;
    v_saldo_cuenta CUENTA.SALDO_CUENTA%TYPE;
    v_saldo_apertura CUENTA.MONTO_APERTURA%TYPE;
    v_count NUMBER;
BEGIN
    -- Verificar si el número de cuenta existe
    SELECT COUNT(*)
    INTO v_count
    FROM CUENTA
    WHERE ID_CUENTA = p_no_cuenta;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('El número de cuenta no existe.');
        RETURN;
    END IF;

    -- Obtener los datos del cliente y la cuenta
    SELECT c.NOMBRE, tc.NOMBRE, tcu.NOMBRE, cu.SALDO_CUENTA, cu.MONTO_APERTURA
    INTO v_nombre_cliente, v_tipo_cliente, v_tipo_cuenta, v_saldo_cuenta, v_saldo_apertura
    FROM CLIENTES c
    INNER JOIN CUENTA cu ON c.ID_CLIENTE = cu.ID_CLIENTE
    INNER JOIN TIPO_CLIENTE tc ON c.ID_TIPO_CLIENTE = tc.ID_TIPO_CLIENTE
    INNER JOIN TIPO_CUENTA tcu ON cu.ID_TIPO_CUENTA = tcu.ID_TIPO_CUENTA
    WHERE cu.ID_CUENTA = p_no_cuenta;

    -- Mostrar los resultados
    DBMS_OUTPUT.PUT_LINE('Nombre Cliente: ' || v_nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('Tipo de Cliente: ' || v_tipo_cliente);
    DBMS_OUTPUT.PUT_LINE('Tipo de Cuenta: ' || v_tipo_cuenta);
    DBMS_OUTPUT.PUT_LINE('Saldo Cuenta: ' || v_saldo_cuenta);
    DBMS_OUTPUT.PUT_LINE('Saldo Apertura: ' || v_saldo_apertura);
END;

CREATE OR REPLACE PROCEDURE consultarCliente (
    p_id_cliente IN NUMBER
)
AS
    v_nombre_completo CLIENTES.NOMBRE%TYPE;
    v_usuario CLIENTES.USUARIO%TYPE;
    v_telefonos VARCHAR2(200); -- Pueden ser múltiples
    v_correos VARCHAR2(200); -- Pueden ser múltiples
    v_cantidad_cuentas NUMBER;
    v_tipos_cuentas VARCHAR2(200); -- Pueden ser múltiples
BEGIN
    -- Verificar si el cliente existe
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM CLIENTES
        WHERE ID_CLIENTE = p_id_cliente;

        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Error: El cliente con el ID proporcionado no existe.');
            RETURN;
        END IF;
    END;

    -- Obtener los datos del cliente
    SELECT c.NOMBRE, c.USUARIO,
           LISTAGG(DISTINCT t.TELEFONO, ', ') WITHIN GROUP (ORDER BY t.ID_TELEFONO),
           LISTAGG(DISTINCT cor.CORREO, ', ') WITHIN GROUP (ORDER BY cor.ID_CORREO),
           COUNT(ct.ID_CUENTA),
           LISTAGG(DISTINCT tc.NOMBRE, ', ') WITHIN GROUP (ORDER BY tc.ID_TIPO_CUENTA)
    INTO v_nombre_completo, v_usuario, v_telefonos, v_correos, v_cantidad_cuentas, v_tipos_cuentas
    FROM CLIENTES c
    LEFT JOIN TELEFONOS t ON c.ID_CLIENTE = t.ID_CLIENTE
    LEFT JOIN CORREOS cor ON c.ID_CLIENTE = cor.ID_CLIENTE
    LEFT JOIN CUENTA ct ON c.ID_CLIENTE = ct.ID_CLIENTE
    LEFT JOIN TIPO_CUENTA tc ON ct.ID_TIPO_CUENTA = tc.ID_TIPO_CUENTA
    WHERE c.ID_CLIENTE = p_id_cliente
    GROUP BY c.NOMBRE,c.USUARIO;

    -- Mostrar los resultados
    DBMS_OUTPUT.PUT_LINE('✓ Id cliente: ' || p_id_cliente);
    DBMS_OUTPUT.PUT_LINE('✓ Nombre completo: ' || v_nombre_completo);
    DBMS_OUTPUT.PUT_LINE('✓ Usuario: ' || v_usuario);
    DBMS_OUTPUT.PUT_LINE('✓ Teléfono(s): ' || v_telefonos);
    DBMS_OUTPUT.PUT_LINE('✓ Correo(s): ' || v_correos);
    DBMS_OUTPUT.PUT_LINE('✓ No de cuenta(s) que posee: ' || v_cantidad_cuentas);
    DBMS_OUTPUT.PUT_LINE('✓ Tipo(s) de cuenta que posee: ' || v_tipos_cuentas);
END;



CREATE OR REPLACE PROCEDURE consultarMovsCliente (
    p_id_cliente IN NUMBER
)
AS
BEGIN
    -- Verificar si el cliente existe
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM CLIENTES
        WHERE ID_CLIENTE = p_id_cliente;

        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Error: El cliente con el ID proporcionado no existe.');
            RETURN;
        END IF;
    END;

    -- Mostrar el resultado esperado
    FOR mov IN (SELECT t.ID_TRANSACCION,
                        CASE tt.NOMBRE
                            WHEN 'Compra' THEN 'Compra'
                            WHEN 'Deposito' THEN 'Depósito'
                            WHEN 'Debito' THEN 'Debito'
                            ELSE 'Otro'
                        END AS TIPO_TRANSACCION,
                        CASE tt.NOMBRE
                            WHEN 'Compra' THEN c.IMPORTE
                            WHEN 'Deposito' THEN dep.MONTO
                            WHEN 'Debito' THEN deb.MONTO
                        END AS MONTO,
                        tt.NOMBRE AS TIPO_SERVICIO,
                        t.ID_CUENTA, tc.NOMBRE AS TIPO_CUENTA
                 FROM TRANSACCION t
                 INNER JOIN TIPO_TRANSACCION tt ON t.ID_TIPO_TRANSACCION = tt.ID_TIPO_TRANSACCION
                 LEFT JOIN COMPRAS c ON t.ID_SERVICIO_COMPRA = c.ID_COMPRA AND tt.ID_TIPO_TRANSACCION = 1
                 LEFT JOIN DEPOSITO dep ON t.ID_SERVICIO_DEPOSITO = dep.ID_DEPOSITO AND tt.ID_TIPO_TRANSACCION = 2
                 LEFT JOIN DEBITO deb ON t.ID_SERVICIO_DEBITO = deb.ID_DEBITO AND tt.ID_TIPO_TRANSACCION = 3
                 INNER JOIN CUENTA cu ON t.ID_CUENTA = cu.ID_CUENTA
                 INNER JOIN TIPO_CUENTA tc ON cu.ID_TIPO_CUENTA = tc.ID_TIPO_CUENTA
                 WHERE cu.ID_CLIENTE = p_id_cliente)
    LOOP
        DBMS_OUTPUT.PUT_LINE('✓ Id transacción: ' || mov.ID_TRANSACCION);
        DBMS_OUTPUT.PUT_LINE('✓ Tipo transacción: ' || mov.TIPO_TRANSACCION);
        DBMS_OUTPUT.PUT_LINE('✓ Monto: ' || mov.MONTO);
        DBMS_OUTPUT.PUT_LINE('✓ Tipo de servicio: ' || mov.TIPO_SERVICIO);
        DBMS_OUTPUT.PUT_LINE('✓ No. cuenta: ' || mov.ID_CUENTA);
        DBMS_OUTPUT.PUT_LINE('✓ Tipo cuenta: ' || mov.TIPO_CUENTA);
    END LOOP;
END;



CREATE OR REPLACE PROCEDURE consultarTipoCuentas (
    p_id_tipo_cuenta IN NUMBER
)
AS
    v_count NUMBER;
BEGIN
    -- Verificar si el tipo de cuenta existe
    SELECT COUNT(*)
    INTO v_count
    FROM TIPO_CUENTA
    WHERE ID_TIPO_CUENTA = p_id_tipo_cuenta;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: El tipo de cuenta con el ID proporcionado no existe.');
        RETURN;
    END IF;

    -- Mostrar el resultado esperado
    FOR tipo_cuenta IN (SELECT tc.ID_TIPO_CUENTA, tc.NOMBRE, COUNT(c.ID_CLIENTE) AS CANTIDAD_CLIENTES
                        FROM TIPO_CUENTA tc
                        LEFT JOIN CUENTA c ON tc.ID_TIPO_CUENTA = c.ID_TIPO_CUENTA
                        WHERE tc.ID_TIPO_CUENTA = p_id_tipo_cuenta
                        GROUP BY tc.ID_TIPO_CUENTA, tc.NOMBRE)
    LOOP
        DBMS_OUTPUT.PUT_LINE('✓ Código de tipo de cuenta: ' || tipo_cuenta.ID_TIPO_CUENTA);
        DBMS_OUTPUT.PUT_LINE('✓ Nombre cuenta: ' || tipo_cuenta.NOMBRE);
        DBMS_OUTPUT.PUT_LINE('✓ Cantidad de clientes que poseen ese tipo de cuenta: ' || tipo_cuenta.CANTIDAD_CLIENTES);
    END LOOP;
END;

-- *************************************************este tiene un error
CREATE OR REPLACE PROCEDURE consultarMovsGenFech (
    fechaInicio VARCHAR2,
    fechaFin VARCHAR2
)
AS
BEGIN
    -- Validar formato de fecha
    BEGIN
        fechaInicio := TO_DATE(fechaInicio, 'DD/MM/YY');
        fechaFin := TO_DATE(fechaFin, 'DD/MM/YY');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: El formato de fecha no es válido. Utilice el formato DD/MM/YY.');
            RETURN;
    END;

    -- Consulta de movimientos generales por rango de fechas
    FOR movs IN (
        SELECT
            t.ID_TRANSACCION AS id_transaccion,
            tt.nombre AS tipo_transaccion,
            CASE
                WHEN d.ID_DEBITO IS NOT NULL THEN 'Débito'
                WHEN c.ID_COMPRA IS NOT NULL THEN 'Compra'
                WHEN dep.ID_DEPOSITO IS NOT NULL THEN 'Depósito'
            END AS tipo_servicio,
            cl.NOMBRE || ' ' || cl.APELLIDO AS nombre_cliente,
            cb.ID_CUENTA AS no_cuenta,
            tc.NOMBRE AS tipo_cuenta,
            t.FECHA_TRANSACCION AS fecha,
            CASE
                WHEN d.ID_DEBITO IS NOT NULL THEN d.MONTO
                WHEN c.ID_COMPRA IS NOT NULL THEN c.IMPORTE
                WHEN dep.ID_DEPOSITO IS NOT NULL THEN dep.MONTO
            END AS monto,
            t.OTROS_DETALLES AS otros_detalles
        FROM
            TRANSACCION t
        LEFT JOIN
            DEBITO d ON t.ID_SERVICIO_DEBITO = d.ID_DEBITO
        LEFT JOIN
            COMPRAS c ON t.ID_SERVICIO_COMPRA = c.ID_COMPRA
        LEFT JOIN
            DEPOSITO dep ON t.ID_SERVICIO_DEPOSITO = dep.ID_DEPOSITO
        JOIN
            TIPO_TRANSACCION tt ON t.ID_TIPO_TRANSACCION = tt.ID_TIPO_TRANSACCION
        JOIN
            CUENTA cb ON t.ID_CUENTA = cb.ID_CUENTA
        JOIN
            CLIENTES cl ON cb.ID_CLIENTE = cl.ID_CLIENTE
        JOIN
            TIPO_CUENTA tc ON cb.ID_TIPO_CUENTA = tc.ID_TIPO_CUENTA
        WHERE
            t.FECHA_TRANSACCION BETWEEN fechaInicio AND fechaFin
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('✓ Id transacción: ' || movs.id_transaccion);
        DBMS_OUTPUT.PUT_LINE('✓ Tipo transacción: ' || movs.tipo_transaccion);
        DBMS_OUTPUT.PUT_LINE('✓ Tipo de servicio: ' || movs.tipo_servicio);
        DBMS_OUTPUT.PUT_LINE('✓ Nombre Cliente: ' || movs.nombre_cliente);
        DBMS_OUTPUT.PUT_LINE('✓ No. cuenta: ' || movs.no_cuenta);
        DBMS_OUTPUT.PUT_LINE('✓ Tipo de cuenta: ' || movs.tipo_cuenta);
        DBMS_OUTPUT.PUT_LINE('✓ Fecha: ' || TO_CHAR(movs.fecha, 'DD/MM/YYYY HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('✓ Monto: ' || movs.monto);
        DBMS_OUTPUT.PUT_LINE('✓ Otros detalles: ' || movs.otros_detalles);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    END LOOP;
END;


CREATE OR REPLACE PROCEDURE consultarProductoServicio (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT ID_PRODUCTO_SERVICIO AS "Código de servicio / producto",
               COSTO AS "Costo",
               DESCRIPCION AS "Descripción",
               CASE
                   WHEN TIPO = 1 THEN 'Servicio'
                   WHEN TIPO = 2 THEN 'Producto'
               END AS "Tipo"
        FROM PRODUCTOS_SERVICIOS;
END consultarProductoServicio;