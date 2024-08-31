unit CccteclEspecial;

interface

uses Ccctecl, SysUtils, DB, DBTables, CBDT, CClientespecial, CListar, CUtiles, CIDBFM, WinProcs;

type

TTCtacteclE = class(TTCtactecl)
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
  procedure   IniciarTablasObj; override;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   DatosCliente; override;
 protected
  { Declaraciones Protegidas }
   procedure  ListTitFichaPagos(salida: char);
   procedure  ListDatosCliente(salida: char); override;
   function   DatosClientePS(xcodcli, xclavecta: string): string; override;
   procedure  DatosClienteVenc(xcodcli: string); override;
end;

function cccle: TTCtacteclE;

implementation

var
  xctactecle: TTCtacteclE = nil;

constructor TTCtactecle.Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
begin
  inherited Create;
  tabla1  := nil; tabla2 := nil; tabla3:= nil;
  tabla1  := datosdb.openDB('cctcl1', 'Idtitular;Clavecta');
  tabla2  := datosdb.openDB('ctactecf1', 'Idcompr;Tipo;Sucursal;Numero');
  tabla3  := datosdb.openDB('ctactecl1', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items');
  morosos := datosdb.openDB('morosos2', 'Idtitular;Clavecta;Idc;Tipo;Sucursal;Numero');
end;

destructor TTCtacteclE.Destroy;
begin
  desconectar;
  inherited Destroy;
end;

function TTCtacteclE.VerifCliente(xcodcli: string): boolean;
// Objetivo...: Verificamos que el proveedor ingresado Exista
begin
  if clientespecial.Buscar(xcodcli) then Result := True else Result := False;
end;

function TTCtacteclE.getCliente(xcodcli: string): string;
// Objetivo...: Recuperamos el Cliente titular de la Cuenta
begin
  clientespecial.getDatos(xcodcli);
  Result := clientespecial.Nombre;
end;

function TTCtacteclE.DatosClientePS(xcodcli, xclavecta: string): string;
// Objetivo...: Listar los datos del cliente
begin
  clientespecial.getDatos(xcodcli);
  Result := clientespecial.nombre + '___' + clientespecial.domicilio;
end;

procedure TTCtacteclE.DatosClienteVenc(xcodcli: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  clientespecial.getDatos(TSQL.FieldByName('idtitular').AsString);
  pr   := clientespecial.Nombre;
  dom  := clientespecial.domicilio;
  docc := 'C.U.I.T. Nº: ' + clientespecial.nrocuit;
end;

procedure TTCtacteclE.ListarFichaPlanPagos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; salida: char);
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

procedure TTCtacteclE.ListTitFichaPagos(salida: char);
// Objetivo...: Listar Titulos Ficha de Cuenta Corriente para los Pagos
begin
  clientespecial.getDatos(tabla3.FieldByName('idtitular').AsString);

  List.Linea(0, 0, 'Titular', 1, 'Arial, negrita, 11', salida, 'N');
  List.Linea(12, list.Lineactual, ': ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + ' ' + clientespecial.nombre, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Garante: ', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ', 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Domicilio', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clientespecial.domicilio, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Domicilio', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ', 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Localidad', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clientespecial.Localidad, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Localidad', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ', 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Documento', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clientespecial.nrocuit, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Documento', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ', 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(24, list.Lineactual, 'Tel.:  ', 5, 'Arial, normal, 10', salida, 'N');
  List.Linea(29, list.Lineactual, clientespecial.telcom, 6, 'Arial, negrita, 10', salida, 'N');
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

procedure TTCtacteclE.ImprimirRecibo(xconcepto: string; ximporte: real; salida: char);
// Objetivo...: Imprimir recibo
var
  i: integer;
begin
  if Buscar(clavecta, idtitular, idc, tipo, sucursal, numero, items) then Begin
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

procedure TTCtacteclE.DatosCliente;
// Objetivo...: subtotalizar una deuda para un cliente
begin
  clientespecial.getDatos(idtitular);
  rsCliente  := clientespecial.nombre;
  domCliente := clientespecial.domicilio;
  docc       := clientespecial.nrocuit;
end;

procedure TTCtacteclE.ListDatosCliente(salida: char);
// Objetivo...: subtotalizar una deuda para un cliente
begin
  // Subtotal
  if idant <> '' then rSubtotales(salida);
  clientespecial.Buscar(tabla3.FieldByName('idtitular').AsString);
  pr := clientespecial.tperso.FieldByName('nombre').AsString;
  List.Linea(0, 0, 'Cuenta: ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
  List.importe(95, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
  List.Linea(98, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
end;

procedure TTCtacteclE.IniciarTablasObj;
// Objetivo...: Instanciamos las tablas
begin
  htabla1 := datosdb.openDB('hcctcl1', 'Idtitular;Clavecta', '', dbs.BDhistorico);
  htabla2 := datosdb.openDB('hctactecf1', 'Idcompr;Tipo;Sucursal;Numero', '', dbs.BDhistorico);
  htabla3 := datosdb.openDB('hctactecl1', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items', '', dbs.BDhistorico);
  inherited IniciarTablasObj;
end;

procedure TTCtacteclE.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then clientespecial.conectar;
  Inc(conexiones);
end;

procedure TTCtacteclE.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then clientespecial.desconectar;
end;

{===============================================================================}

function cccle: TTCtacteclE;
begin
  if xctacteclE = nil then
    xctacteclE := TTCtacteclE.Create('', '', '', '', '', '', '', '', '', '', '', '', 0);
  Result := xctactecle;
end;

{===============================================================================}

initialization

finalization
  xctactecle.Free;

end.
