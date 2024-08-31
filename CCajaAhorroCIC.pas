unit CCajaAhorroCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CBancos, CCuentasTransferenciasCCE;

type

TTCajaAhorro = class(TTCtaTransferencias)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Listar(salida: char);
  function    setBanco(xcuenta: String): String;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function cajaahorro: TTCajaAhorro;

implementation

var
  xcajaahorro: TTCajaAhorro = nil;

constructor TTCajaAhorro.Create;
begin
  tabla := datosdb.openDB('cajaahorro', '');
end;

destructor TTCajaAhorro.Destroy;
begin
  inherited Destroy;
end;

procedure TTCajaAhorro.Listar(salida: char);
// Objetivo...: Listar Datos de Provincias
var
  idanter: String;

  procedure ListLinea(salida: char);
  Begin
    if tabla.FieldByName('codigo').AsString <> idanter then Begin
      entbcos.getDatos(tabla.FieldByName('codigo').AsString);
      if Length(Trim(idanter)) > 0 then List.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, 'Banco: ' + entbcos.codbanco + ' - ' + entbcos.descrip, 1, 'Arial, negrita, 9', salida, 'S');
      idanter := tabla.FieldByName('codigo').AsString;
    end;
    List.Linea(0, 0, '  ' + tabla.FieldByName('nrocuenta').AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(12, list.Lineactual, tabla.FieldByName('descrip').AsString, 2, 'Arial, normal, 8', salida, 'S');
  end;

begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cajas de Ahorro', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta', 1, 'Arial, cursiva, 8');
  List.Titulo(12, list.Lineactual, 'Descripción', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    ListLinea(salida);
    tabla.Next;
  end;

  tabla.First;

  if Length(Trim(idanter)) = 0 then List.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  List.FinList;
end;

function  TTCajaAhorro.setBanco(xcuenta: String): String;
// Objetivo...: Recuperar el Banco de una Cuenta
begin
  Result := '';
  datosdb.Filtrar(tabla, 'nrocuenta = ' + '''' + xcuenta + '''');
  if tabla.RecordCount > 0 then Begin
    tabla.First;
    entbcos.getDatos(tabla.FieldByName('codbanco').AsString);
    Result := entbcos.descrip;
  end;
end;

procedure TTCajaAhorro.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  entbcos.conectar;
  inherited conectar;
end;

procedure TTCajaAhorro.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  entbcos.desconectar;
  inherited desconectar;
end;

{===============================================================================}

function cajaahorro: TTCajaAhorro;
begin
  if xcajaahorro = nil then
    xcajaahorro := TTCajaAhorro.Create;
  Result := xcajaahorro;
end;

{===============================================================================}

initialization

finalization
  xcajaahorro.Free;

end.
