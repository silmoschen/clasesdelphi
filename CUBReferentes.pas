unit CUBReferentes;

interface

uses SysUtils, CListar, CUtiles, DBTables, Contnrs, CIDBFM;

type

TTUBReferente = class
  Codos, Periodo: string;
  Unidad: real;
  tabla: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;

  procedure   Registrar(xcodos, xperiodo: string; xunidad: real);
  procedure   Borrar(xcodos, xperiodo: string);
  function    Buscar(xcodos, xperiodo: string): boolean;
  procedure   getDatos(xcodos, xperiodo: string);
  function    getObjects(xcodos: string): TObjectList;

  function    getUnidad(xcodos, xperiodo: string): real;

  procedure   conectar;
  procedure   desconectar;

  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

implementation

constructor TTUBReferente.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('NBUREFERENTE', '');
end;

destructor TTUBReferente.Destroy;
begin
  inherited Destroy;
end;

procedure TTUBReferente.Registrar(xcodos, xperiodo: string; xunidad: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodos, xperiodo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codos').AsString   := xcodos;
  tabla.FieldByName('periodo').AsString := copy(xperiodo, 1, 2) + copy(xperiodo, 4, 4);
  tabla.FieldByName('unidad').AsFloat   := xunidad;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTUBReferente.Borrar(xcodos, xperiodo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodos, xperiodo) then
    begin
      tabla.Delete;
      datosdb.closeDB(tabla); tabla.Open;
    end;
end;

function TTUBReferente.Buscar(xcodos, xperiodo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  result := datosdb.Buscar(tabla, 'codos', 'periodo', xcodos, copy(xperiodo, 1, 2) + copy(xperiodo, 4, 4));
end;

procedure TTUBReferente.getDatos(xcodos, xperiodo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodos, xperiodo) then begin
    codos   := tabla.FieldByName('codos').AsString;
    periodo := copy(tabla.FieldByName('periodo').AsString, 1, 2) + '/' + copy(tabla.FieldByName('periodo').AsString, 3, 4);
    unidad  := tabla.FieldByName('unidad').AsFloat;
  end else   begin
    codos := ''; periodo := ''; unidad := 0;
  end;
end;

function TTUBReferente.getObjects(xcodos: string): TObjectList;
// Objetivo...: Retornar una lista de objetos
var
  l: TObjectList;
  objeto: TTUBReferente;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'codos = ' + '''' + xcodos + '''');
  tabla.First;
  while not tabla.Eof do begin
    objeto         := TTUBReferente.Create;
    objeto.codos   := tabla.FieldByName('codos').AsString;
    objeto.periodo := copy(tabla.FieldByName('periodo').AsString, 1, 2) + '/' + copy(tabla.FieldByName('periodo').AsString, 3, 4);
    objeto.unidad  := tabla.FieldByName('unidad').AsFloat;
    l.Add(objeto);
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  result := l;
end;

function TTUBReferente.getUnidad(xcodos, xperiodo: string): real;
// Objetivo...: Retornar una lista de objetos
var
  u: real;
  peranter: string;
begin
  datosdb.Filtrar(tabla, 'codos = ' + '''' + xcodos + '''');
  tabla.First; u := 0;
  while not tabla.Eof do begin
    if (copy(tabla.FieldByName('periodo').AsString, 3, 4)+copy(tabla.FieldByName('periodo').AsString, 1, 2) > peranter) then begin
      u := tabla.FieldByName('unidad').AsFloat;
      peranter := copy(tabla.FieldByName('periodo').AsString, 3, 4)+copy(tabla.FieldByName('periodo').AsString, 1, 2);
    end;
    if (strtoint(copy(tabla.FieldByName('periodo').AsString, 3, 4)+copy(tabla.FieldByName('periodo').AsString, 1, 2)) >= strtoint(copy(xperiodo, 4, 4)+copy(xperiodo, 1, 2)) ) then break;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  result := u;
end;

procedure TTUBReferente.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTUBReferente.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

end.
