-- registroTipoCliuente
--                  idtipo,     nombre,                         descripcion
BEGIN
	registrarTipoCliente(1,'Individual Nacional','Este tipo de cliente es una persona individual de nacionalidad guatemalteca');
    registrarTipoCliente(2,'Individual Extranjero','Este tipo de cliente es una persona individual de nacionalidad extranjera');
    registrarTipoCliente(3,'Empresa PyMe','Este tipo de cliente es una empresa de tipo pequeña o mediana');
    registrarTipoCliente(4,'Empresa S.C','Este tipo de cliente corresponde a las empresa grandes que tienen una sociedad colectiva');
END;

-- registroTipoCuenta
--                  idtipo,     nombre,                         descripcion
BEGIN
    registrarTipoCuenta(1,'Cuenta de Cheques','Este tipo de cuenta ofrece la facilidad de emitir cheques para realizar transacciones monetarias.');
    registrarTipoCuenta(2,'Cuenta de Ahorros','Esta cuenta genera un interés anual del 2%, lo que la hace ideal para guardar fondos a largo plazo.');
    registrarTipoCuenta(3,'Cuenta de Ahorro Plus','Con una tasa de interés anual del 10%, esta cuenta de ahorros ofrece mayores rendimientos.');
    registrarTipoCuenta(4,'Pequeña Cuenta','Una cuenta de ahorros con un interés semestral del 0.5%, ideal para pequeños ahorros y movimientos.');
    registrarTipoCuenta(5,'Cuenta de Nomina','Diseñada para recibir depósitos de sueldo y realizar pagos, con acceso a servicios bancarios básicos.');
    registrarTipoCuenta(6,'Cuenta de Inversion','Orientada a inversionistas, ofrece opciones de inversión y rendimientos más altos que una cuenta de ahorros estándar.');
END;

BEGIN
    crearProductoServicio(1, 1, 10.00, 'Servicio de tarjeta de debito'); --servicio
    crearProductoServicio(2, 1, 10.00, 'Servicio de chequera'); --servicio
    crearProductoServicio(3, 1, 400.00, 'Servicio de asesoramiento financiero'); --servicio
    crearProductoServicio(4, 1, 5.00, 'Servicio de banca personal'); --servicio
    crearProductoServicio(5, 1, 30.00, 'Seguro de vida'); --servicio
    crearProductoServicio(6, 1, 100.00, 'Seguro de vida plus'); --servicio
    crearProductoServicio(7, 1, 300.00, 'Seguro de automóvil'); --servicio
    crearProductoServicio(8, 1, 500.00, 'Seguro de automóvil plus'); --servicio
    crearProductoServicio(9, 1, 00.05, 'Servicio de deposito'); --servicio
    crearProductoServicio(10, 1, 00.10, 'Servicio Debito'); --servicio

    crearProductoServicio(11, 2, 00.00, 'Pago energía Eléctrica (EEGSA)'); --producto
    crearProductoServicio(12, 2, 00.00, 'Pago de agua potable (Empagua)'); --producto
    crearProductoServicio(13, 2, 00.00, 'Pago de Matricula USAC'); --producto
    crearProductoServicio(14, 2, 00.00, 'Pago de curso de vacaciones USAC'); --producto
    crearProductoServicio(15, 2, 00.00, 'Pago de servicio de internet'); --producto
    crearProductoServicio(16, 2, 00.00, 'Servicio de suscripción plataformas streaming'); --producto
    crearProductoServicio(17, 2, 00.00, 'Servicios Cloud'); --producto
END;