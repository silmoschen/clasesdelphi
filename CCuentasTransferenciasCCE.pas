unit CCuentasTransferenciasCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTCtaTransferencias = class
  Codigo, Items, Nrocuenta, Codbanco, Descrip: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodigo, xitems: String): Boolean;
  procedure   Registrar(xcodigo, xitems, xnrocuenta, xdescrip: String; xcantitems: Integer);
  procedure   Borrar(xcodigo: String);
  procedure   getDatos(xcodigo, xitems: String);

  procedure   BuscarPorCuenta(xexpr: String);
  
  function    setCuentas(xcodigo: String): TQuery; overload;
  function    setCuentas: TQuery; overload;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

implementation


constructor TTCtaTransferencias.Create;
begin

end;

destructor TTCtaTransferencias.Destroy;
begin
  inherited Destroy;
end;

function  TTCtaTransferencias.Buscar(xcodigo, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  if tabla.IndexFieldNames <> 'Codigo;Items' then tabla.IndexFieldNames := 'Codigo;Items';
  Result := datosdb.Buscar(tabla, 'codigo', 'items', xcodigo, xitems);
end;

procedure TTCtaTransferencias.Registrar(xcodigo, xitems, xnrocuenta, xdescrip: String; xcantitems: Integer);
// Objetivo...: Registrar una Instancia
begin
  if Buscar(xcodigo, xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString    := xcodigo;
  tabla.FieldByName('items').AsString     := xitems;
  tabla.FieldByName('nrocuenta').AsString := xnrocuenta;
  tabla.FieldByName('descrip').AsString   := xdescrip;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  if (utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') = xitems) then Begin
    datosdb.tranSQL('delete from ' + tabla.TableName + ' where codigo = ' + '''' + xcodigo + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closedb(tabla); tabla.Open;
  end;
end;

procedure TTCtaTransferencias.Borrar(xcodigo: String);
// Objetivo...: Borrar una Instancia
begin
  datosdb.tranSQL('delete from ' + tabla.TableName + ' where codigo = ' + '''' + xcodigo + '''');
  datosdb.closedb(tabla); tabla.Open;
end;

procedure TTCtaTransferencias.getDatos(xcodigo, xitems: String);
// Objetivo...: recuperar una instancia
begin
  if Buscar(xcodigo, xitems) then Begin
    Codigo    := tabla.FieldByName('codigo').AsString;
    Items     := tabla.FieldByName('items').AsString;
    Nrocuenta := tabla.FieldByName('nrocuenta').AsString;
    Codbanco  := tabla.FieldByName('codbanco').AsString;
    Descrip   := tabla.FieldByName('descrip').AsString;
  end else Begin
    Nrocuenta := '';
    Codbanco  := '';
    Descrip   := '';
  end;
end;

procedure TTCtaTransferencias.BuscarPorCuenta(xexpr: String);
// Objetivo...: Buscar Instancia
begin
  tabla.FindNearest([xexpr]);
end;

function TTCtaTransferencias.setCuentas(xcodigo: String): TQuery;
// Objetivo...: Devolver Lista de Cuentas para una Entidad
var
  r: TQuery;
begin
  result := datosdb.tranSQL('select * from ' + tabla.TableName + ' where codigo = ' + '''' + xcodigo + '''' + ' order by items');
end;

function TTCtaTransferencias.setCuentas: TQuery;
// Objetivo...: Devolver Lista de Cuentas para una Entidad
var
  r: TQuery;
begin
  result := datosdb.tranSQL('select * from ' + tabla.TableName + ' order by codigo, items');
end;

procedure TTCtaTransferencias.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('items').DisplayLabel := 'Items';
    tabla.FieldByName('nrocuenta').DisplayLabel := 'Nro.Cta.'; tabla.FieldByName('codigo').DisplayLabel := 'Cód.Ba.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexiones);
end;

procedure TTCtaTransferencias.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

end.
