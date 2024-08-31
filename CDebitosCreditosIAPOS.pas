unit CDebitosCreditosIAPOS;

interface

uses SysUtils, CListar, CUtiles, DBTables, Contnrs, CIDBFM, CBDT,
     CUtilidadesArchivos;

type

TTDebitosCreditosIapos = class
  Id, Fecha, Concepto, Tipomov: string;
  Monto: real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;

  procedure   Registrar(xid, xfecha, xconcepto, xtipomov: string; xmonto: real);
  procedure   Borrar(xid: string);
  function    Buscar(xid: string): boolean;
  procedure   getDatos(xid: string);
  function    getObjects: TObjectList;

  procedure   conectar(xperiodo: string);
  procedure   desconectar;

  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

implementation

constructor TTDebitosCreditosIapos.Create;
begin
  inherited Create;
end;

destructor TTDebitosCreditosIapos.Destroy;
begin
  inherited Destroy;
end;

procedure TTDebitosCreditosIapos.Registrar(xid, xfecha, xconcepto, xtipomov: string; xmonto: real);
// Objetivo...: Grabar Atributos del Objeto
var
  id: string;
begin
  if (length(trim(xid)) > 0) then id := xid else id := utiles.setIdRegistroFecha;
  if Buscar(xid) then tabla.Edit else tabla.Append;
  tabla.FieldByName('id').AsString       := id;
  tabla.FieldByName('fecha').AsString    := xfecha;
  tabla.FieldByName('concepto').AsString := xconcepto;
  tabla.FieldByName('tipomov').AsString  := xtipomov;
  tabla.FieldByName('monto').AsFloat     := xmonto;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTDebitosCreditosIapos.Borrar(xid: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xid) then
    begin
      tabla.Delete;
      datosdb.closeDB(tabla); tabla.Open;
    end;
end;

function TTDebitosCreditosIapos.Buscar(xid: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  result := tabla.FindKey([xid]);
end;

procedure TTDebitosCreditosIapos.getDatos(xid: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xid) then begin
    id       := tabla.FieldByName('id').AsString;
    fecha    := tabla.FieldByName('fecha').AsString;
    concepto := tabla.FieldByName('concepto').AsString;
    tipomov  := tabla.FieldByName('tipomov').AsString;
    monto    := tabla.FieldByName('monto').AsFloat;
  end else   begin
    id := ''; fecha := ''; concepto := ''; tipomov := ''; monto := 0;
  end;
end;

function TTDebitosCreditosIapos.getObjects: TObjectList;
// Objetivo...: Retornar una lista de objetos
var
  l: TObjectList;
  objeto: TTDebitosCreditosIapos;
begin
  l := TObjectList.Create;
  tabla.First;
  while not tabla.Eof do begin
    objeto          := TTDebitosCreditosIapos.Create;
    objeto.id       := tabla.FieldByName('id').AsString;
    objeto.fecha    := tabla.FieldByName('fecha').AsString;
    objeto.concepto := tabla.FieldByName('concepto').AsString;
    objeto.tipomov  := tabla.FieldByName('tipomov').AsString;
    objeto.monto    := tabla.FieldByName('monto').AsFloat;
    l.Add(objeto);
    tabla.Next;
  end;
  result := l;
end;

procedure TTDebitosCreditosIapos.conectar(xperiodo: string);
// Objetivo...: Abrir tablas de persistencia
var
  per: string;
begin
  per := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  if not (DirectoryExists(dbs.DirSistema + '\estadisticas')) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\estadisticas');
  if not (DirectoryExists(dbs.DirSistema + '\estadisticas\' + per)) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\estadisticas\' + per);
  if not (FileExists(dbs.DirSistema + '\estadisticas\' + per + '\movimientos.db')) then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\estadisticas', 'movimientos.*', dbs.DirSistema + '\estadisticas\' + per);
  tabla := datosdb.openDB('movimientos', '', '', dbs.DirSistema + '\estadisticas\' + per);
  tabla.Open;
end;

procedure TTDebitosCreditosIapos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(tabla);
end;

end.
