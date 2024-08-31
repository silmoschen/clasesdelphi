unit CDias;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTDias = class(TObject)            // Superclase
  iddias, inicio, fin: string;
  tdias: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xiddias, xinicio, xfin: string);
  destructor  Destroy; override;

  function    getiddias: string;
  function    getInicio: string;
  function    getFin: string;

  procedure   Grabar(xiddias, xinicio, xfin: string);
  function    Borrar(xiddias: string): boolean;
  function    Buscar(xiddias: string): boolean;
  procedure   getDatos(xiddias: string);
  function    setdias: TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function dias: TTDias;

implementation

var
  xdias: TTDias = nil;

constructor TTDias.Create(xiddias, xinicio, xfin: string);
begin
  inherited Create;
  iddias := xiddias;
  inicio    := xinicio;
  fin       := xfin;

  tdias := datosdb.openDB('dias.DB', 'iddias');
end;

destructor TTDias.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTDias.getiddias: string;
// Objetivo....: Retornar Cod. marca
begin
  Result := iddias;
end;

function TTDias.getInicio: string;
// Objetivo...: Retornar Descripción
begin
  Result := inicio;
end;

function TTDias.getFin: string;
// Objetivo...: Retornar Descripción
begin
  Result := fin;
end;

procedure TTDias.Grabar(xiddias, xinicio, xfin: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xiddias) then tdias.Edit else tdias.Append;
  tdias.FieldByName('iddias').AsString := xiddias;
  tdias.FieldByName('inicio').AsString    := xinicio;
  tdias.FieldByName('fin').AsString       := xfin;
  try
    tdias.Post;
  except
    tdias.Cancel;
  end;
end;

function TTDias.Borrar(xiddias: string): boolean;
// Objetivo...: Eliminar un Objeto
begin
  try
    if Buscar(xiddias) then
      begin
        tdias.Delete;
        getDatos(tdias.FieldByName('iddias').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
        Result := True;
      end
    finally
      Result := False;
    end;
end;

function TTDias.Buscar(xiddias: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tdias.Active then conectar;
  if tdias.FindKey([xiddias]) then Result := True else Result := False;
end;

procedure  TTDias.getDatos(xiddias: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xiddias) then
    begin
      iddias := tdias.FieldByName('iddias').AsString;
      inicio    := tdias.FieldByName('inicio').AsString;
      fin       := tdias.FieldByName('fin').AsString;
    end
   else
    begin
      iddias := ''; inicio := ''; fin := '';
    end;
end;

function TTDias.setdias: TQuery;
// Objetivo...: Devolver un set con los diass definidos
begin
  Result := datosdb.tranSQL('SELECT * FROM dias ORDER BY iddias');
end;

procedure TTDias.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de descrips
begin

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Días de Cursos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Días', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tdias.First;
  while not tdias.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tdias.FieldByName('iddias').AsString >= iniciar) and (tdias.FieldByName('iddias').AsString <= finalizar) then List.Linea(0, 0, tdias.FieldByName('iddias').AsString + '   ' + tdias.FieldByName('inicio').AsString + ' - ' + tdias.FieldByName('fin').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tdias.FieldByName('iddias').AsString < iniciar) or (tdias.FieldByName('iddias').AsString > finalizar) then List.Linea(0, 0, tdias.FieldByName('iddias').AsString + '    ' + tdias.FieldByName('inicio').AsString + ' - ' + tdias.FieldByName('fin').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tdias.Next;
    end;
    List.FinList;

    tdias.First;
end;

procedure TTDias.conectar;
// Objetivo...: Abrir tdiass de persistencia
var
  i: integer;
begin
  tdias.Open;
  tdias.FieldByName('iddias').DisplayLabel := 'Cód.';
end;

procedure TTDias.desconectar;
// Objetivo...: cerrar tdiass de persistencia
begin
  datosdb.closeDB(tdias);
end;

{===============================================================================}

function dias: TTDias;
begin
  if xdias = nil then
    xdias := TTDias.Create('', '', '');
  Result := xdias;
end;

{===============================================================================}

initialization

finalization
  xdias.Free;

end.
