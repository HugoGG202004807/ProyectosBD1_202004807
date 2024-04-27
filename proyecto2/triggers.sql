-- ************************************* TRIGGERS *******************************************

CREATE OR REPLACE TRIGGER trg_tipo_cliente
AFTER INSERT OR DELETE OR UPDATE ON TIPO_CLIENTE
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla TIPO_CLIENTE', v_tipo_operacion);
END;

CREATE OR REPLACE TRIGGER trg_clientes
AFTER INSERT OR DELETE OR UPDATE ON CLIENTES
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla CLIENTES', v_tipo_operacion);
END;


CREATE OR REPLACE TRIGGER trg_cuenta
AFTER INSERT OR DELETE OR UPDATE ON CUENTA
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla CUENTA', v_tipo_operacion);
END;

CREATE OR REPLACE TRIGGER trg_tipo_cuenta
AFTER INSERT OR DELETE OR UPDATE ON TIPO_CUENTA
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla TIPO_CUETAS', v_tipo_operacion);
END;


CREATE OR REPLACE TRIGGER trg_productos_servicios
AFTER INSERT OR DELETE OR UPDATE ON PRODUCTOS_SERVICIOS
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla PRODUCTOS_SERVICIOS', v_tipo_operacion);
END;

CREATE OR REPLACE TRIGGER trg_compras
AFTER INSERT OR DELETE OR UPDATE ON COMPRAS
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla COMPRAS', v_tipo_operacion);
END;

CREATE OR REPLACE TRIGGER trg_deposito
AFTER INSERT OR DELETE OR UPDATE ON DEPOSITO
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla DEPOSITO', v_tipo_operacion);
END;

CREATE OR REPLACE TRIGGER trg_debito
AFTER INSERT OR DELETE OR UPDATE ON DEBITO
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla DEBITO', v_tipo_operacion);
END;

CREATE OR REPLACE TRIGGER trg_transaccion
AFTER INSERT OR DELETE OR UPDATE ON TRANSACCION
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla TRANSACCION', v_tipo_operacion);
END;

CREATE OR REPLACE TRIGGER trg_tipo_transaccion
AFTER INSERT OR DELETE OR UPDATE ON TIPO_TRANSACCION
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_tipo_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_tipo_operacion := 'UPDATE';
    ELSIF DELETING THEN
        v_tipo_operacion := 'DELETE';
    END IF;

    INSERT INTO HISTORIAL (descripcion, tipo)
    VALUES ('Se ha realizado una acción en la tabla TIPO_TRANSACCION', v_tipo_operacion);
END;