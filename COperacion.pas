unit COperacion;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TToperacion = class(TObject)            // Superclase
  codoper, Descrip: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodoper, xdescrip: string);
  destructor  Destroy; override;

  function    getcodoper: string;
  function    getDescrip: string;

  procedure   Grabar(xcodoper, xDescrip: string);
  procedure   Borrar(xcodoper: string);
  function    Buscar(xcodoper: string): boolean;
  procedure   getDatos(xcodoper: string);
  function    setOperaciones: TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function operacion: TToperacion;

implementation

var
  xoperacion: TToperacion = nil;

constructor TToperacion.Create(xcodoper, xdescrip: string);
begin
  inherited Create;
  codoper := xcodoper;
  descrip  := xdescrip;

  tabla := datosdb.openDB('tipoper.DB', 'codoper');
end;

destructor TToperacion.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TToperacion.getcodoper: string;
// Objetivo....: Retornar Cod. marca
begin
  Result := codoper;
end;

function TToperacion.getDescrip: string;
// Objetivo...: Retornar Descripción
begin
  Result := descrip;
end;

procedure TToperacion.Grabar(xcodoper, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodoper) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codoper').Value := xcodoper;
  tabla.FieldByName('descrip').Value  := xdescrip;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TToperacion.Borrar(xcodoper: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodoper) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codoper').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TToperacion.Buscar(xcodoper: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then conectar;
  if tabla.FindKey([xcodoper]) then Result := True else Result := False;
end;

procedure  TToperacion.getDatos(xcodoper: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodoper) then
    begin
      codoper  := tabla.FieldByName('codoper').Value;
      descrip  := tabla.FieldByName('descrip').Value;
    end
   else
    begin
      codoper := ''; descrip := '';
    end;
end;

function TToperacion.setOperaciones: TQuery;
// Objetivo...: Devolver un set con los operacion definidos
begin
  Result := datosdb.tranSQL('SELECT * FROM operacion ORDER BY descrip');
end;

procedure TToperacion.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de descrips
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de operacion', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'operacion', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codoper').AsString >= iniciar) and (tabla.FieldByName('codoper').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codoper').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codoper').AsString < iniciar) or (tabla.FieldByName('codoper').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codoper').AsString + '    ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codoper').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codoper').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TToperacion.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Open;
  tabla.FieldByName('codoper').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción';
end;

procedure TToperacion.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(tabla);
end;

{===============================================================================}

function operacion: TToperacion;
begin
  if xoperacion = nil then
    xoperacion := TToperacion.Create('', '');
  Result := xoperacion;
end;

{===============================================================================}

initialization

finalization
  xoperacion.Free;

end.
