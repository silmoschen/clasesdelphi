unit CVueltosDamevin;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTVueltos = class(TObject)
  condicion, importe: string; vuelto: real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcondicion, ximporte: string; xvuelto: real);
  procedure   Borrar(xcondicion, ximporte: string);
  function    Buscar(xcondicion, ximporte: string): boolean;
  procedure   getDatos(xcondicion, ximporte: string);
  function    setVuelto(ximporte: string): real;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function vuelto: TTVueltos;

implementation

var
  xcomprob: TTVueltos = nil;

constructor TTVueltos.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('vueltos', 'Condicion;Importe');
end;

destructor TTVueltos.Destroy;
begin
  inherited Destroy;
end;

procedure TTVueltos.Grabar(xcondicion, ximporte: string; xvuelto: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcondicion, ximporte) then tabla.Edit else tabla.Append;
  tabla.FieldByName('condicion').AsString := xcondicion;
  tabla.FieldByName('importe').AsString   := ximporte;
  tabla.FieldByName('vuelto').AsFloat     := xvuelto;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTVueltos.Borrar(xcondicion, ximporte: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcondicion, ximporte) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('condicion').AsString, tabla.FieldByName('importe').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTVueltos.Buscar(xcondicion, ximporte: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := datosdb.Buscar(tabla, 'condicion', 'importe', xcondicion, ximporte);
end;

procedure  TTVueltos.getDatos(xcondicion, ximporte: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xcondicion, ximporte) then
    begin
      vuelto  := tabla.FieldByName('vuelto').AsFloat;
    end
   else
    begin
      vuelto := 0;
    end;
end;

function TTVueltos.setVuelto(ximporte: string): real;
begin
  Result := 0;
  tabla.First;
  while not tabla.EOF do Begin
    if (StrToFloat(ximporte) <= tabla.FieldByName('importe').AsFloat) and (tabla.FieldByName('condicion').AsString = '<') then Result := tabla.FieldByName('vuelto').AsFloat;
    if (StrToFloat(ximporte) >= tabla.FieldByName('importe').AsFloat) and (tabla.FieldByName('condicion').AsString = '>') then Result := tabla.FieldByName('vuelto').AsFloat;
    tabla.Next;
  end;
end;

procedure TTVueltos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then
    if not tabla.Active then tabla.Open;
  Inc(conexiones);
end;

procedure TTVueltos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function vuelto: TTVueltos;
begin
  if xcomprob = nil then
    xcomprob := TTVueltos.Create;
  Result := xcomprob;
end;

{===============================================================================}

initialization

finalization
  xcomprob.Free;

end.
