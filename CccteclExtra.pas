unit CccteclExtra;

interface

uses Ccctecl, SysUtils, DB, DBTables, CBDT, CClientExtra, CListar, CUtiles, CIDBFM, WinProcs;

type

TTCtacteclExtra = class(TTCtactecl)
 public
  { Declaraciones Públicas }
  constructor Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
  destructor  Destroy; override;

  function    VerifCliente(xcodcli: string): boolean; override;
  function    getCliente(xcodcli: string): string; override;
  procedure   ListarFichaPlanPagos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; salida: char); override;
  procedure   ImprimirRecibo(xconcepto: string; ximporte: real; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   DatosCliente;
 protected
  { Declaraciones Protegidas }
   procedure IniciarTablasObj; override;
   procedure ListTitFichaPagos(salida: char);
   procedure ListDatosCliente(salida: char); override;
   function  DatosClientePS(xcodcli, xclavecta: string): string; override;
   procedure DatosClienteVenc(xcodcli: string); override;
end;

function ccclextra: TTCtacteclExtra;

implementation

var
  xctacteclextra: TTCtacteclExtra = nil;

constructor TTCtacteclExtra.Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
begin
  inherited Create;
  tabla1  := nil; tabla2 := nil; tabla3:= nil;
  tabla1  := datosdb.openDB('cctcl2', 'Idtitular;Clavecta');
  tabla2  := datosdb.openDB('ctactecf2', 'Idcompr;Tipo;Sucursal;Numero');
  tabla3  := datosdb.openDB('ctactecl2', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items');
  morosos := datosdb.openDB('morosos3', 'Idtitular;Clavecta;Idc;Tipo;Sucursal;Numero');
end;

destructor TTCtacteclExtra.Destroy;
begin
  desconectar;
  inherited Destroy;
end;

function TTCtacteclExtra.VerifCliente(xcodcli: string): boolean;
// Objetivo...: Verificamos que el proveedor ingresado Exista
begin
  if clienteextra.Buscar(xcodcli) then Result := True else Result := False;
end;

function TTCtacteclExtra.getCliente(xcodcli: string): string;
// Objetivo...: Recuperamos el Cliente titular de la Cuenta
begin
  clienteextra.getDatos(xcodcli);
  Result := clienteextra.Nombre;
end;

function TTCtacteclExtra.DatosClientePS(xcodcli, xclavecta: string): string;
// Objetivo...: Listar los datos del cliente
begin
  clienteextra.getDatos(xcodcli);
  Result := clienteextra.nombre + '___' + clienteextra.domicilio;
end;

procedure TTCtacteclExtra.DatosClienteVenc(xcodcli: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  clienteextra.getDatos(TSQL.FieldByName('idtitular').AsString);
  pr   := clienteextra.Nombre;
  dom  := clienteextra.domicilio;
  docc := 'C.U.I.T. Nº: ' + clienteextra.nrocuit;
end;

procedure TTCtacteclExtra.ListarFichaPlanPagos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; salida: char);
// Objetivo...: Listar Ficha con el Formato de la cuenta corriente - como para registrar los pagos
var
  indice: string;
begin
  // Buscamos la Ficha correspondiente
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '-1') then Begin
    indice := tabla3.IndexFieldNames;
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
    ListTitFichaPagos(salida);
    GenerarFichaPago(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero, salida);
    tabla3.IndexFieldNames := indice;
   end
  else
   if not existenMov then utiles.msgError('Cuentas sin Operaciones ...!') else List.FinList;
end;

procedure TTCtacteclExtra.ListTitFichaPagos(salida: char);
// Objetivo...: Listar Titulos Ficha de Cuenta Corriente para los Pagos
begin
  clienteextra.getDatos(tabla3.FieldByName('idtitular').AsString);

  List.Linea(0, 0, 'Titular', 1, 'Arial, negrita, 11', salida, 'N');
  List.Linea(12, list.Lineactual, ': ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + ' ' + clienteextra.nombre, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Garante: ', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ', 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Domicilio', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clienteextra.domicilio, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Domicilio', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ', 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Localidad', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clienteextra.Localidad, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Localidad', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ', 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Documento', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clienteextra.nrocuit, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Documento', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ', 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(24, list.Lineactual, 'Tel.:  ', 5, 'Arial, normal, 10', salida, 'N');
  List.Linea(29, list.Lineactual, clienteextra.telcom, 6, 'Arial, negrita, 10', salida, 'N');
  List.Linea(72, list.Lineactual, 'Tel.:  ', 7, 'Arial, nomal, 10', salida, 'S');

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');

  List.Linea(0, 0, 'Fecha', 1, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(9, List.lineactual, 'Concepto', 2, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(37, List.lineactual, 'Comprobante', 3, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(55, List.lineactual, 'Debe', 4, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(70, List.lineactual, 'Haber', 5, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(85, List.lineactual, 'Saldo', 6, 'Arial, cursiva, 8', salida, 'S');

  List.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
end;

procedure TTCtacteclExtra.ImprimirRecibo(xconcepto: string; ximporte: real; salida: char);
// Objetivo...: Imprimir recibo
var
  i: integer;
begin
  if Buscar(clavecta, idtitular, idc, tipo, sucursal, numero, items) then Begin
    // Atributos del cliente
    DatosCliente;
    // Emisión del comprobante
    inherited getDatosFormatoCartas(50);
    inherited listRecibo(xconcepto, ximporte ,salida);
    For i := 1 to StrToInt(modeloc.FieldByName('fc').AsString) do List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    inherited listRecibo(xconcepto, ximporte, salida);

    if (salida = 'I') or (salida = 'P') then Begin
      list.CompletarPagina;
      list.FinList;
    end else
      Winexec('list.exe', 0);

    listdat := False;  // Fags para imprimir otro recibo
  end;
end;

procedure TTCtacteclExtra.DatosCliente;
// Objetivo...: Datos del cliente
begin
  clienteextra.getDatos(idtitular);
  rsCliente  := clienteextra.nombre;
  domCliente := clienteextra.domicilio;
  docc       := clienteextra.nrocuit;
end;

procedure TTCtacteclExtra.ListDatosCliente(salida: char);
// Objetivo...: subtotalizar una deuda para un cliente
begin
  // Subtotal
  if idant <> '' then rSubtotales(salida);
  clienteextra.Buscar(tabla3.FieldByName('idtitular').AsString);
  pr := clienteextra.tperso.FieldByName('nombre').AsString;
  List.Linea(0, 0, 'Cuenta: ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
  List.importe(95, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
  List.Linea(98, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
end;

procedure TTCtacteclExtra.IniciarTablasObj;
// Objetivo...: Instanciamos las tablas
begin
  htabla1 := datosdb.openDB('hcctcl2', 'Idtitular;Clavecta', '', dbs.BDhistorico);
  htabla2 := datosdb.openDB('hctactecf2', 'Idcompr;Tipo;Sucursal;Numero', '', dbs.BDhistorico);
  htabla3 := datosdb.openDB('hctactecl2', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items', '', dbs.BDhistorico);

  inherited IniciarTablasObj;
end;

procedure TTCtacteclExtra.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    clienteextra.conectar;
    inherited conectar;
  end;
  Inc(conexiones);
end;

procedure TTCtacteclExtra.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    clienteextra.desconectar;
    inherited desconectar;
  end;
end;

{===============================================================================}

function ccclextra: TTCtacteclExtra;
begin
  if xctacteclExtra = nil then
    xctacteclExtra := TTCtacteclExtra.Create('', '', '', '', '', '', '', '', '', '', '', '', 0);
  Result := xctacteclextra;
end;

{===============================================================================}

initialization

finalization
  xctacteclextra.Free;

end.
