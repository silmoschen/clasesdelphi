unit CHabitacionesMagni;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM, Classes;

type

TTHabitacion = class(TObject)            // Superclase
  Nrohabitacion, Descrip, Observacion: string; Precio: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xnrohabitacion, xdescrip, xobservacion: string; xprecio: Real);
  procedure   Borrar(xnrohabitacion: string);
  function    Buscar(xnrohabitacion: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xnrohabitacion: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xcodigo: string);
  procedure   BuscarPorNombre(xdescrip: string);

  procedure   OcuparHabitacion(xnrohabitacion, xnroregistro: String);
  procedure   DesocuparHabitacion(xnrohabitacion: String);
  function    Ocupada(xnrohabitacion: String): String;
  function    setHabilacionesDisponibles: TStringList;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListarLinea(salida: char);
  { Declaraciones Privadas }
end;

function habitacion: TTHabitacion;

implementation

var
  xhabitacion: TTHabitacion = nil;

constructor TTHabitacion.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('habitaciones', '');
end;

destructor TTHabitacion.Destroy;
begin
  inherited Destroy;
end;

procedure TTHabitacion.Grabar(xnrohabitacion, xdescrip, xobservacion: string; xprecio: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xnrohabitacion) then tabla.Edit else tabla.Append;
  tabla.FieldByName('nrohabitacion').AsString := xnrohabitacion;
  tabla.FieldByName('descrip').AsString       := xdescrip;
  tabla.FieldByName('observacion').AsString   := xobservacion;
  tabla.FieldByName('precio').AsFloat         := xprecio;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTHabitacion.Borrar(xnrohabitacion: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xnrohabitacion) then begin
    tabla.Delete;
    getDatos(tabla.FieldByName('nrohabitacion').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTHabitacion.Buscar(xnrohabitacion: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Nrohabitacion' then tabla.IndexFieldNames := 'Nrohabitacion';
  if tabla.FindKey([xnrohabitacion]) then Result := True else Result := False;
end;

procedure  TTHabitacion.getDatos(xnrohabitacion: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xnrohabitacion) then begin
    nrohabitacion := tabla.FieldByName('nrohabitacion').AsString;
    descrip       := tabla.FieldByName('descrip').AsString;
    observacion   := tabla.FieldByName('observacion').AsString;
    precio        := tabla.FieldByName('precio').AsFloat;
  end else begin
    nrohabitacion := ''; descrip := ''; observacion := ''; precio := 0;
  end;
end;

function TTHabitacion.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
var
  indice: String;
begin
  indice := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'Nrohabitacion';
  tabla.Refresh; tabla.Last;
  if Length(Trim(tabla.FieldByName('nrohabitacion').AsString)) > 0 then Result := IntToStr(tabla.FieldByName('nrohabitacion').AsInteger + 1) else Result := '1';
  tabla.IndexFieldNames := indice;
end;

procedure TTHabitacion.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Habitaciones', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nro.  Habitación', 1, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, 'Nro.  Habitación', 2, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'Observaciones', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('nrohabitacion').AsString >= iniciar) and (tabla.FieldByName('nrohabitacion').AsString <= finalizar) then ListarLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('nrohabitacion').AsString < iniciar) or (tabla.FieldByName('nrohabitacion').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('nrohabitacion').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'S');
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('nrohabitacion').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'S');
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('nrohabitacion').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'S');

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTHabitacion.ListarLinea(salida: char);
Begin
  List.Linea(0, 0, tabla.FieldByName('nrohabitacion').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.importe(48, list.Lineactual, '', tabla.FieldByName('precio').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(60, list.Lineactual, tabla.FieldByName('observaciones').AsString, 3, 'Arial, normal, 8', salida, 'S');
end;

procedure TTHabitacion.BuscarPorCodigo(xcodigo: string);
begin
  if tabla.IndexFieldNames <> 'Nrohabitacion' then tabla.IndexFieldNames := 'Nrohabitacion';
  tabla.FindNearest([xcodigo]);
end;

procedure TTHabitacion.BuscarPorNombre(xdescrip: string);
begin
  if tabla.IndexName <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xdescrip]);
end;

procedure TTHabitacion.OcuparHabitacion(xnrohabitacion, xnroregistro: String);
// Objetivo...: Ocupar una habitacion
begin
  if Buscar(xnrohabitacion) then Begin
    tabla.Edit;
    tabla.FieldByName('estado').AsString      := 'O';
    tabla.FieldByName('nroregistro').AsString := xnroregistro;
    try
      tabla.Post
     except
      tabla.Cancel
     end;
     datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTHabitacion.DesocuparHabitacion(xnrohabitacion: String);
// Objetivo...: Desocupar una habitacion
begin
  if Buscar(xnrohabitacion) then Begin
    tabla.Edit;
    tabla.FieldByName('estado').AsString      := 'D';
    tabla.FieldByName('nroregistro').AsString := '';
    try
      tabla.Post
     except
      tabla.Cancel
     end;
     datosdb.closeDB(tabla); tabla.Open;
  end;
end;

function TTHabitacion.Ocupada(xnrohabitacion: String): String;
// Objetivo...: Ocupar una habitacion
begin
  if Buscar(xnrohabitacion) then Result := tabla.FieldByName('nroregistro').AsString else Result := '';
end;

function  TTHabitacion.setHabilacionesDisponibles: TStringList;
// Objetivo...: Retornar un set de Habitaciones Disponibles
var
  l: TStringList;
Begin
  l := TStringList.Create;
  tabla.First;
  while not tabla.Eof do Begin
    if tabla.FieldByName('estado').AsString <> 'O' then l.Add(tabla.FieldByName('nrohabitacion').AsString + tabla.FieldByName('descrip').AsString + ';1' + tabla.FieldByName('precio').AsString);
    tabla.Next;
  end;
  Result := l;
end;

procedure TTHabitacion.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('nrohabitacion').DisplayLabel := 'Nro.'; tabla.FieldByName('Descrip').DisplayLabel := 'Habitación';
    tabla.FieldByName('precio').DisplayLabel := 'Precio'; tabla.FieldByName('observacion').DisplayLabel := 'Observaciones';
  end;
  Inc(conexiones);
end;

procedure TTHabitacion.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones < 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function habitacion: TTHabitacion;
begin
  if xhabitacion = nil then
    xhabitacion := TTHabitacion.Create;
  Result := xhabitacion;
end;

{===============================================================================}

initialization

finalization
  xhabitacion.Free;

end.
