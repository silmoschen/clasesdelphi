unit CCobrosTarjetas_Gross;

interface

uses CTarjetasCredito_Gross, CClienteGross, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTCobroTarjetas = class
  Id, Periodo, Fecha, Idtarjeta, Codcli, Ingreso: String; Monto: Real;
  cobros: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xid: String): Boolean;
  procedure   Registrar(xid, xperiodo, xfecha, xidtarjeta, xcodcli, xingreso, xcliente: String; xmonto: Real);
  procedure   getDatos(xid: String);
  procedure   Borrar(xid: String);

  function    setTarjetas(xperiodo: String): TStringList;
  function    setMovimientos(xperiodo: String): TQuery;

  procedure   Marcartarjeta(xperiodo, xid, xestado: String);
  function    setCliente(xid: String): String;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  basedat: String;
end;

function cobrostarj: TTCobroTarjetas;

implementation

var
  xcobrostarj: TTCobroTarjetas = nil;

constructor TTCobroTarjetas.Create;
begin
  basedat := dbs.DirSistema + '\controles';
  cobros  := datosdb.openDB('cobrostarjetas', '', '', basedat);
end;

destructor TTCobroTarjetas.Destroy;
begin
  inherited Destroy;
end;

function  TTCobroTarjetas.Buscar(xid: String): Boolean;
Begin
  Result := cobros.FindKey([xid]);
end;

procedure TTCobroTarjetas.Registrar(xid, xperiodo, xfecha, xidtarjeta, xcodcli, xingreso, xcliente: String; xmonto: Real);
Begin
  if Length(Trim(xid)) > 0 then Id := xid else Id := utiles.setIdRegistroFecha + '-';
  if Buscar(Id) then cobros.Edit else cobros.Append;
  cobros.FieldByName('Id').AsString        := Id;
  cobros.FieldByName('periodo').AsString   := xperiodo;
  cobros.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  cobros.FieldByName('Idtarjeta').AsString := xidtarjeta;
  cobros.FieldByName('codcli').AsString    := xcodcli;
  cobros.FieldByName('Ingreso').AsString   := xingreso;
  cobros.FieldByName('estado').AsString    := 'N';
  cobros.FieldByName('cliente').AsString   := xcliente;
  cobros.FieldByName('monto').AsFloat      := xmonto;
  try
    cobros.Post
   except
    cobros.Cancel
  end;
  datosdb.refrescar(cobros);
end;

procedure TTCobroTarjetas.getDatos(xid: String);
Begin
  if Buscar(Id) then Begin
    Id := cobros.FieldByName('Id').AsString;
    Periodo   := cobros.FieldByName('periodo').AsString;
    Fecha     := utiles.sFormatoFecha(cobros.FieldByName('fecha').AsString);
    Idtarjeta := cobros.FieldByName('Idtarjeta').AsString;
    Codcli    := cobros.FieldByName('codcli').AsString;
    Ingreso   := cobros.FieldByName('Ingreso').AsString;
    Monto     := cobros.FieldByName('monto').AsFloat;
  end else Begin
    Id := ''; Periodo := ''; Fecha := ''; Idtarjeta := ''; Codcli := ''; Ingreso := ''; Monto := 0;
  end;
end;

procedure TTCobroTarjetas.Borrar(xid: String);
Begin
  if Buscar(xid) then cobros.Delete;
end;

function  TTCobroTarjetas.setTarjetas(xperiodo: String): TStringList;
// Objetivo...: Devolver set de registros
var
  l: TStringList;
Begin
  l := TStringList.Create;
  datosdb.Filtrar(cobros, 'periodo = ' + '''' + xperiodo + '''' + ' and idtarjeta >= ' + '''' + '001' + '''');
  cobros.First;
  while not cobros.Eof do Begin
    l.Add(cobros.FieldByName('fecha').AsString + cobros.FieldByName('idtarjeta').AsString + cobros.FieldByName('codcli').AsString + cobros.FieldByName('estado').AsString + cobros.FieldByName('Id').AsString + cobros.FieldByName('monto').AsString);
    cobros.Next;
  end;
  datosdb.QuitarFiltro(cobros);

  Result := l;
end;

function  TTCobroTarjetas.setMovimientos(xperiodo: String): TQuery;
Begin
  Result := datosdb.tranSQL(basedat, 'select * from cobrostarjetas where periodo = ' + '"' + xperiodo + '"' + ' order by idtarjeta, fecha');
end;

procedure TTCobroTarjetas.Marcartarjeta(xperiodo, xid, xestado: String);
Begin
  if Buscar(xid) then Begin
    cobros.Edit;
    cobros.FieldByName('estado').AsString := xestado;
    try
      cobros.Post
     except
      cobros.Cancel
    end;
  end;
end;

function  TTCobroTarjetas.setCliente(xid: String): String;
Begin
  if Buscar(xid) then Result := cobros.FieldByName('cliente').AsString else Result := '';
end;

procedure TTCobroTarjetas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cobros.Active then cobros.Open;
  end;
  Inc(conexiones);
  tarjeta.conectar;
  cliente.conectar;
end;

procedure TTCobroTarjetas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cobros);
  end;
  tarjeta.desconectar;
  cliente.desconectar;
end;

{===============================================================================}

function cobrostarj: TTCobroTarjetas;
begin
  if xcobrostarj = nil then
    xcobrostarj := TTCobroTarjetas.Create;
  Result := xcobrostarj;
end;

{===============================================================================}

initialization

finalization
  xcobrostarj.Free;

end.
