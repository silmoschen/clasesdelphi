unit Ccctepr;

interface

uses SysUtils, DB, DBTables, CCtactes, CProve, CListar, CUtiles, CBDT, CIDBFM;

type

TTCtactepr = class(TTCtacte)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    VerifProveedor(xcodprov: string): boolean;
  function    getProveedor(xcodprov: string): string;
  function    getOperaciones(xt, xc: string): TTable;
  procedure   Depurar(fecha: string);

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   rListar(iniciar, finalizar: string; salida: char);
  procedure   rListarccpr(iniciar, finalizar: string; salida: char);
  function    getMcctpr: TQuery;
  function    AuditoriaPagosEfectuados(fecha: string): TQuery;
  function    AuditoriaOperacionesProveedores(fecha: string): TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   rSubtotales(salida: char);
  function    obtener_total(fecha, idc, idt, dc: string): real;
  procedure   List_linea(salida: char);
  procedure   rList_linea(salida: char);
  procedure   rList_lineaccpr(salida: char);
end;

function ccpr: TTCtactepr;

implementation

var
  xctactepr: TTCtactepr = nil;

constructor TTCtactepr.Create;
begin
  inherited Create;
  tabla2 := nil;
  tabla1 := datosdb.openDB('cctpr', 'Idtitular');
  tabla3 := datosdb.openDB('ctactepr', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero');
end;

destructor TTCtactepr.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTCtactepr.VerifProveedor(xcodprov: string): boolean;
// Objetivo...: Verificamos que el proveedor ingresado Exista
begin
  if proveedor.Buscar(xcodprov) then Result := True else Result := False;
end;

function TTCtactepr.getProveedor(xcodprov: string): string;
// Objetivo...: Recuperamos el Proveedor titular de la Cuenta
begin
  proveedor.getDatos(xcodprov);
  Result := proveedor.Nombre;
end;

function TTCtactepr.getOperaciones(xt, xc: string): TTable;
// Objetivo...: Retornar un Sub set de registros con los movimientos de la cuenta corriente
begin
  Result := datosdb.Filtrar(tabla3, 'idtitular = ' + '''' + xt + '''' + ' and clavecta = ' + '''' + xc + '''');
end;

function TTCtactepr.obtener_total(fecha, idc, idt, dc: string): real;
// Objetivo...: devolver subtotal
begin
  datosdb.tranSQL('SELECT SUM(importe) FROM ctactepr WHERE fecha < ' + '''' + utiles.sExprFecha(fecha) + '''' + ' AND clavecta = ' + '''' + idc + '''' + ' AND idtitular = ' + '''' + idt + '''' + ' AND DC = ' + '''' + dc + '''');
  datosdb.setSQL.Open;
  Result := datosdb.setSQL.Fields[0].AsFloat;
  datosdb.setSQL.Close;
end;

procedure TTCtactepr.Depurar(fecha: string);
// Objetivo...: Eliminar los movimientos que no se necesiten mas
var
  td, th: real; tm: string;
begin
  tabla1.First;
  while not tabla1.EOF do
    begin
      // 1º Obtenemos los totales para el saldo inicial
      td := obtener_total(fecha, tabla1.FieldByName('clavecta').AsString, tabla1.FieldByName('idtitular').AsString, '1');
      th := obtener_total(fecha, tabla1.FieldByName('clavecta').AsString, tabla1.FieldByName('idtitular').AsString, '2');
      // 2º Eliminamos los movimientos
      datosdb.tranSQL('DELETE FROM ctactepr WHERE fecha < ' + '''' + utiles.sExprFecha(fecha) + '''' + ' AND clavecta = ' + '''' + tabla1.FieldByName('clavecta').AsString + '''' + ' AND idtitular = ' + '''' + tabla1.FieldByName('idtitular').AsString + '''');
      // 3º Grabamos el movimiento inicial
      if (td-th) >= 0 then tm := '1' else tm := '2';
      Grabar(tabla1.FieldByName('clavecta').AsString, tabla1.FieldByName('idtitular').AsString, 'NUE', 'X', '0000', '00000000', fecha, tm, 'Saldo inicial', (td - th));

      tabla1.Next;
    end;
end;

procedure TTCtactepr.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    proveedor.conectar;
    if not tabla1.Active then
      begin
        tabla1.Open;
        tabla1.FieldByName('fealta').Visible := False; tabla1.FieldByName('clave').Visible := False; tabla1.FieldByName('sel').Visible := False;
        tabla1.FieldByName('idtitular').DisplayLabel := 'Titular'; tabla1.FieldByName('clavecta').DisplayLabel := 'Cta.'; tabla1.FieldByName('obs').DisplayLabel := 'Observaciones';
      end;
    if not tabla3.Active then tabla3.Open;
  end;
  Inc(conexiones);
end;

procedure TTCtactepr.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    proveedor.desconectar;
    datosdb.closeDB(tabla1);
    datosdb.closeDB(tabla3);
  end;
end;

procedure TTCtactepr.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  proveedor.Buscar(tabla1.FieldByName('idtitular').AsString);
  if tabla1.FieldByName('idtitular').AsString <> idant then pr := proveedor.tperso.FieldByName('rsocial').AsString else pr := ' ';
  List.Linea(0, 0, tabla1.FieldByName('idtitular').AsString + ' ' + tabla1.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(57, List.lineactual, tabla1.FieldByName('obs').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(90, List.lineactual, utiles.sFormatoFecha(tabla1.FieldByName('fealta').AsString), 3, 'Courier New, normal, 8', salida, 'S');
  idant := tabla1.FieldByName('idtitular').AsString;
end;

procedure TTCtactepr.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de Proveedores Definidas
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Cuentas Corrientes de Proveedores', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta       Titular', 1, 'Courier New, cursiva, 8');
  List.Titulo(57, List.lineactual, 'Observaciones', 2, 'Courier New, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Fe. Alta', 3, 'Courier New, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla1.First;
  while not tabla1.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla1.FieldByName('idtitular').AsString >= iniciar) and (tabla1.FieldByName('idtitular').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla1.FieldByName('idtitular').AsString < iniciar) or (tabla1.FieldByName('idtitular').AsString > finalizar) then List_linea(salida);

      tabla1.Next;
    end;
    List.FinList;

    tabla1.First;
end;

procedure TTCtactepr.rSubtotales(salida: char);
// Objetivo...: Emitir Subtotales
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(85, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.derecha(100, list.lineactual, '', '--------------', 4, 'Arial, normal, 8');
  List.Linea(101, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Subtotal Cuenta ..........: ', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', td, 2, 'Arial, normal, 8');
  List.importe(85, list.lineactual, '', th, 3, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 4, 'Arial, normal, 8');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
  saldo := 0; td := 0; th := 0;
end;

procedure TTCtactepr.rListar(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de Proveedores Definidas
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Cuentas Corrientes de Proveedores', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Comprobante                   Concepto Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Debe', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Haber', 4, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla3.IndexName := 'Listado';

  tabla1.First;
  while not tabla1.EOF do
    begin
      if tabla1.FieldByName('sel').AsString = 'X' then
        begin
           saldo := 0; td := 0; th := 0; idant := ''; clant := '';

           tabla3.First;
           while not tabla3.EOF do
             begin
               if (tabla3.FieldByName('idtitular').AsString = tabla1.FieldByName('idtitular').AsString) and (tabla3.FieldByName('clavecta').AsString = tabla1.FieldByName('clavecta').AsString) then
                 begin
                   if tabla3.FieldByName('DC').AsString = '1' then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
                   if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
                   if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then rList_Linea(salida);
                 end;

               tabla3.Next;
             end;

           if td + th <> 0 then rSubtotales(salida);

        end;
      tabla1.Next;
    end;

    List.FinList;

    tabla3.IndexFieldNames := indice;
end;

procedure TTCtactepr.rList_linea(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);

      proveedor.Buscar(tabla3.FieldByName('idtitular').AsString);
      pr := proveedor.tperso.FieldByName('rsocial').AsString;
      List.Linea(0, 0, 'Cuenta: ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      if tabla3.FieldByName('DC').AsString = '1' then saldoanter := saldo - tabla3.FieldByName('importe').AsFloat else saldoanter := saldo + tabla3.FieldByName('importe').AsFloat;
      List.importe(100, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
      List.Linea(101, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
  List.Linea(0, 0, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(8, List.lineactual, tabla3.FieldByName('idcompr').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(12, List.lineactual, tabla3.FieldByName('tipo').AsString + ' ' + tabla3.FieldByName('sucursal').AsString + ' ' + tabla3.FieldByName('numero').AsString + '   ' + tabla3.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'S');
  if tabla3.FieldByName('DC').AsString = '1' then List.importe(70, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
  if tabla3.FieldByName('DC').AsString = '2' then List.importe(85, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 5, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 6, 'Arial, normal, 8');
  List.Linea(101, List.lineactual, '', 8, 'Arial, normal, 7', salida, 'S');
  idant := tabla3.FieldByName('idtitular').AsString;
  clant := tabla3.FieldByName('clavecta').AsString;
end;

procedure TTCtactepr.rListarccpr(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Resumen de Cuentas de Proveedores discriminado por Proveedor
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Cuentas Corrientes de Proveedores', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Comprobante                   Concepto Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Debe', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Haber', 4, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla3.IndexName := 'Listado';

  tabla1.First;
  while not tabla1.EOF do
    begin
      if tabla1.FieldByName('sel').AsString = 'X' then
        begin
           saldo := 0; td := 0; th := 0; idant := ''; clant := '';

           tabla3.First;
           while not tabla3.EOF do
             begin
               if tabla3.FieldByName('idtitular').AsString = tabla1.FieldByName('idtitular').AsString then
                 begin
                   if tabla3.FieldByName('DC').AsString = '1' then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
                   if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
                   if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then rList_Lineaccpr(salida);
                 end;

               tabla3.Next;
             end;

           if td + th <> 0 then rSubtotales(salida);

        end;
      tabla1.Next;
    end;

    List.FinList;

    tabla3.IndexFieldNames := indice;
end;

procedure TTCtactepr.rList_lineaccpr(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if tabla3.FieldByName('idtitular').AsString <> idant then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);

      proveedor.Buscar(tabla3.FieldByName('idtitular').AsString);
      pr := proveedor.tperso.FieldByName('rsocial').AsString;
      List.Linea(0, 0, 'Cuenta: ' + tabla3.FieldByName('idtitular').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      if tabla3.FieldByName('DC').AsString = '1' then saldoanter := saldo - tabla3.FieldByName('importe').AsFloat else saldoanter := saldo + tabla3.FieldByName('importe').AsFloat;
      List.importe(100, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
      List.Linea(101, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
  List.Linea(0, 0, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(8, List.lineactual, tabla3.FieldByName('idcompr').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(12, List.lineactual, tabla3.FieldByName('tipo').AsString + ' ' + tabla3.FieldByName('sucursal').AsString + ' ' + tabla3.FieldByName('numero').AsString + '   ' + tabla3.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'S');
  if tabla3.FieldByName('DC').AsString = '1' then List.importe(70, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
  if tabla3.FieldByName('DC').AsString = '2' then List.importe(85, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 5, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 6, 'Arial, normal, 8');
  List.Linea(101, List.lineactual, '', 8, 'Arial, normal, 7', salida, 'S');
  idant := tabla3.FieldByName('idtitular').AsString;
end;

function TTCtactepr.getMcctpr: TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactepr.fecha, ctactepr.idtitular, ctactepr.clavecta, ctactepr.idcompr AS IDC, ctactepr.tipo AS Tipo, ctactepr.sucursal AS Sucur, ctactepr.numero AS Numero, clientes.nombre AS Cliente, ctactepr.concepto AS Concepto, ctactepr.importe AS Importe ' +
               'FROM ctactepr, clientes WHERE ctactepr.idtitular = clientes.codcli AND ctactepr.tipo <> ' + '''' + 'X' + '''' + ' ORDER BY fecha');
end;

function TTCtactepr.AuditoriaPagosEfectuados(fecha: string): TQuery;
// Objetivo...: Generar TransacSQL para auditoría de pagos efectuados
begin
  Result := datosdb.tranSQL('SELECT ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, provedor.rsocial, ctactepr.importe '
                           +'FROM ctactepr, provedor WHERE ctactepr.idtitular = provedor.codprov AND ctactepr.fecha = ' + '''' + fecha + '''' + ' AND dc = ' + '''' + '2' + '''');
end;

function TTCtactepr.AuditoriaOperacionesProveedores(fecha: string): TQuery;
// Objetivo...: Generar TransacSQL para auditoría de operaciones con proveedores
begin
  Result := datosdb.tranSQL('SELECT ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, provedor.rsocial, ctactepr.importe '
                           +'FROM ctactepr, provedor WHERE ctactepr.idtitular = provedor.codprov AND ctactepr.fecha = ' + '''' + fecha + '''' + ' AND dc = ' + '''' + '1' + '''');
end;

{===============================================================================}

function ccpr: TTCtactepr;
begin
  if xctactepr = nil then
    xctactepr := TTCtactepr.Create;
  Result := xctactepr;
end;

{===============================================================================}

initialization

finalization
  xctactepr.Free;

end.
