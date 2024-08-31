unit CHorario;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTHorario = class(TObject)            // Superclase
  idhorario, inicio, fin: string;
  thorario: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xidhorario, xinicio, xfin: string);
  destructor  Destroy; override;

  function    getidhorario: string;
  function    getInicio: string;
  function    getFin: string;

  procedure   Grabar(xidhorario, xinicio, xfin: string);
  function    Borrar(xidhorario: string): boolean;
  function    Buscar(xidhorario: string): boolean;
  procedure   getDatos(xidhorario: string);
  function    sethorarios: TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function horario: TTHorario;

implementation

var
  xhorario: TTHorario = nil;

constructor TTHorario.Create(xidhorario, xinicio, xfin: string);
begin
  inherited Create;
  idhorario := xidhorario;
  inicio    := xinicio;
  fin       := xfin;

  thorario := datosdb.openDB('horario.DB', 'idhorario');
end;

destructor TTHorario.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTHorario.getidhorario: string;
// Objetivo....: Retornar Cod. marca
begin
  Result := idhorario;
end;

function TTHorario.getInicio: string;
// Objetivo...: Retornar Descripción
begin
  Result := inicio;
end;

function TTHorario.getFin: string;
// Objetivo...: Retornar Descripción
begin
  Result := fin;
end;

procedure TTHorario.Grabar(xidhorario, xinicio, xfin: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidhorario) then thorario.Edit else thorario.Append;
  thorario.FieldByName('idhorario').AsString := xidhorario;
  thorario.FieldByName('inicio').AsString    := xinicio;
  thorario.FieldByName('fin').AsString       := xfin;
  try
    thorario.Post;
  except
    thorario.Cancel;
  end;
end;

function TTHorario.Borrar(xidhorario: string): boolean;
// Objetivo...: Eliminar un Objeto
begin
  try
    if Buscar(xidhorario) then
      begin
        thorario.Delete;
        getDatos(thorario.FieldByName('idhorario').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
        Result := True;
      end
    finally
      Result := False;
    end;
end;

function TTHorario.Buscar(xidhorario: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not thorario.Active then conectar;
  if thorario.FindKey([xidhorario]) then Result := True else Result := False;
end;

procedure  TTHorario.getDatos(xidhorario: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidhorario) then
    begin
      idhorario := thorario.FieldByName('idhorario').AsString;
      inicio    := thorario.FieldByName('inicio').AsString;
      fin       := thorario.FieldByName('fin').AsString;
    end
   else
    begin
      idhorario := ''; inicio := ''; fin := '';
    end;
end;

function TTHorario.sethorarios: TQuery;
// Objetivo...: Devolver un set con los horarios definidos
begin
  Result := datosdb.tranSQL('SELECT * FROM horario ORDER BY idhorario');
end;

procedure TTHorario.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de descrips
begin

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Horarios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(1) +  'Inicio/Fianlización', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  thorario.First;
  while not thorario.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (thorario.FieldByName('idhorario').AsString >= iniciar) and (thorario.FieldByName('idhorario').AsString <= finalizar) then List.Linea(0, 0, thorario.FieldByName('idhorario').AsString + '   ' + thorario.FieldByName('inicio').AsString + ' - ' + thorario.FieldByName('fin').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (thorario.FieldByName('idhorario').AsString < iniciar) or (thorario.FieldByName('idhorario').AsString > finalizar) then List.Linea(0, 0, thorario.FieldByName('idhorario').AsString + '    ' + thorario.FieldByName('inicio').AsString + ' - ' + thorario.FieldByName('fin').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      thorario.Next;
    end;
    List.FinList;

    thorario.First;
end;

procedure TTHorario.conectar;
// Objetivo...: Abrir thorarios de persistencia
var
  i: integer;
begin
  thorario.Open;
  thorario.FieldByName('idhorario').DisplayLabel := 'Cód.';
end;

procedure TTHorario.desconectar;
// Objetivo...: cerrar thorarios de persistencia
begin
  datosdb.closeDB(thorario);
end;

{===============================================================================}

function horario: TTHorario;
begin
  if xhorario = nil then
    xhorario := TTHorario.Create('', '', '');
  Result := xhorario;
end;

{===============================================================================}

initialization

finalization
  xhorario.Free;

end.
