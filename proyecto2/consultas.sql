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
