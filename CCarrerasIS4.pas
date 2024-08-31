unit CCarrerasIS4;

interface

uses SysUtils, CListar, CUtiles, Contnrs, CIDBFM, DBTables;

type

TTCarrera = class
  Idcarrera, Carrera, Duracion, Modalidad, Turno, Matcom: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   Grabar(xidcarrera, xCarrera, xDuracion, xTurno, xModalidad, xmatcom: string);
  procedure   Borrar(xidcarrera: string);
  function    Buscar(xidcarrera: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xidcarrera: string);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorCodigo(xexpr: string);

  function    setCarrerasAlf: TObjectList;

  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure ListarLinea(salida: char);
end;

function carrera: TTCarrera;

implementation

var
  xcarrera: TTCarrera = nil;

constructor TTCarrera.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('carreras', '');
end;

destructor TTCarrera.Destroy;
begin
  inherited Destroy;
end;

procedure TTCarrera.Grabar(xidcarrera, xCarrera, xDuracion, xTurno, xModalidad, xmatcom: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcarrera) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idcarrera').Value := xidcarrera;
  tabla.FieldByName('carrera').Value   := xcarrera;
  tabla.FieldByName('duracion').Value  := xduracion;
  tabla.FieldByName('modalidad').Value := xmodalidad;
  tabla.FieldByName('turno').Value     := xturno;
  tabla.FieldByName('matcom').Value    := xmatcom;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTCarrera.Borrar(xidcarrera: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidcarrera) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('idcarrera').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    datosdb.refrescar(tabla);
  end;
end;

function TTCarrera.Buscar(xidcarrera: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then conectar;
  tabla.IndexFieldNames := 'idcarrera';
  if tabla.FindKey([xidcarrera]) then Result := True else Result := False;
end;

procedure  TTCarrera.getDatos(xidcarrera: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidcarrera) then Begin
    idcarrera := tabla.FieldByName('idcarrera').AsString;
    carrera   := tabla.FieldByName('carrera').AsString;
    duracion  := tabla.FieldByName('duracion').AsString;
    modalidad := tabla.FieldByName('modalidad').AsString;
    turno     := tabla.FieldByName('turno').AsString;
    matcom    := tabla.FieldByName('matcom').AsString;
  end else Begin
    idcarrera := ''; carrera := ''; duracion := ''; turno := ''; modalidad := ''; matcom := '';
  end;
  //if Length(Trim(matcom)) = 0 then matcom := 'N';
end;

function TTCarrera.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla.Refresh;
  tabla.IndexFieldNames := 'Idcarrera';
  tabla.Last;
  if tabla.RecordCount > 0 then Result := IntToStr(tabla.FieldByName('idcarrera').AsInteger + 1) else Result := '1';
end;

procedure TTCarrera.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Descrips
begin
  list.Setear(salida);
  if orden = 'A' then tabla.IndexFieldNames := 'Carrera';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Carreras', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Carrera', 1, 'Courier New, cursiva, 9');
  List.Titulo(67, list.Lineactual, 'Duración', 2, 'Courier New, cursiva, 9');
  List.Titulo(82, list.Lineactual, 'Modalidad', 3, 'Courier New, cursiva, 9');
  List.Titulo(90, list.Lineactual, 'Turno', 4, 'Courier New, cursiva, 9');
  List.Titulo(93, list.Lineactual, 'M.Com.', 5, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idcarrera').AsString >= iniciar) and (tabla.FieldByName('idcarrera').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idcarrera').AsString < iniciar) or (tabla.FieldByName('idcarrera').AsString > finalizar) then ListarLinea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('Carrera').AsString >= iniciar) and (tabla.FieldByName('Carrera').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('Carrera').AsString < iniciar) or (tabla.FieldByName('Carrera').AsString > finalizar) then ListarLinea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCarrera.ListarLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('idcarrera').AsString + '     ' + tabla.FieldByName('carrera').AsString, 1, 'Courier New, normal, 9', salida, 'N');
  List.Linea(70, list.Lineactual, tabla.FieldByName('duracion').AsString, 2, 'Courier New, normal, 9', salida, 'N');
  List.Linea(85, list.Lineactual, tabla.FieldByName('modalidad').AsString, 3, 'Courier New, normal, 9', salida, 'N');
  List.Linea(90, list.Lineactual, tabla.FieldByName('turno').AsString, 4, 'Courier New, normal, 9', salida, 'N');
  List.Linea(93, list.Lineactual, tabla.FieldByName('matcom').AsString, 5, 'Courier New, normal, 9', salida, 'S');
end;

procedure TTCarrera.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Carrera';
  tabla.FindNearest([xexpr]);
end;

procedure TTCarrera.BuscarPorCodigo(xexpr: string);
begin
  tabla.IndexFieldNames := 'Idcarrera';
  tabla.FindNearest([xexpr]);
end;

function  TTCarrera.setCarrerasAlf: TObjectList;
// Objetivo...: devolver set de materias para una carrera
var
  l: TObjectList;
  objeto: TTCarrera;
begin
  l := TObjectList.Create;
  tabla.IndexFieldNames := 'Carrera';
  tabla.First;
  while not tabla.Eof do Begin
    objeto := TTCarrera.Create;
    objeto.Idcarrera := tabla.FieldByName('idcarrera').AsString;
    objeto.Carrera   := tabla.FieldByName('carrera').AsString;
    objeto.Duracion  := tabla.FieldByName('duracion').AsString;
    objeto.Modalidad := tabla.FieldByName('modalidad').AsString;
    objeto.Turno     := tabla.FieldByName('turno').AsString;
    objeto.Matcom    := tabla.FieldByName('matcom').AsString;
    l.Add(objeto);
    tabla.Next;
  end;
  tabla.IndexFieldNames := 'Idcarrera';

  Result := l;
end;

procedure TTCarrera.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idcarrera').DisplayLabel := 'Cód.'; tabla.FieldByName('carrera').DisplayLabel := 'Carrera';
    tabla.FieldByName('duracion').DisplayLabel := 'Duración'; tabla.FieldByName('turno').DisplayLabel := 'Turno';
    tabla.FieldByName('modalidad').DisplayLabel := 'Modalidad'; tabla.FieldByName('matcom').DisplayLabel := 'MC';
  end;
  Inc(conexiones);
end;

procedure TTCarrera.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function carrera: TTCarrera;
begin
  if xcarrera = nil then
    xcarrera := TTCarrera.Create;
  Result := xcarrera;
end;

{===============================================================================}

initialization

finalization
  xcarrera.Free;

end.
