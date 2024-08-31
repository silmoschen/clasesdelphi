unit CtrlPer;

interface

uses SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTcontrolperiodo = class(TObject)
  actual, anterior: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xanterior, xactual: string);
  destructor  Destroy; override;

  function  getActual: string;
  function  getAnterior: string;

  procedure Grabar(xanterior, xactual: string);
  procedure getDatos(xperiodo: string);
  procedure Borrar(xperiodo: string);

  procedure conectar(sesion, privatedir: string); overload;
  procedure conectar; overload;
  procedure CambiarVia(xvia: string);
  procedure desconectar;
 private
  { Declaraciones Privadas }
 protected
  { Declaraciones Protegidas }
end;

function controlper: TTcontrolperiodo;

implementation

var
  xcontrolper: TTcontrolperiodo = nil;

constructor TTcontrolperiodo.Create(xanterior, xactual: string);
begin
  inherited Create;
  actual   := xactual;
  anterior := xanterior;
  tabla := datosdb.openDB('ctrlper.DB', 'actual');
end;

destructor TTcontrolperiodo.Destroy;
begin
  inherited Destroy;
end;

function TTcontrolperiodo.getActual: string;
begin
  Result := actual;
end;

function TTcontrolperiodo.getAnterior: string;
begin
  Result := anterior;
end;

procedure TTcontrolperiodo.Grabar(xanterior, xactual: string);
// Objetivo...: Grabar atributos de persistencia
begin
  if tabla.FindKey([xactual]) then tabla.Edit else tabla.Append;
  tabla.FieldByName('anterior').AsString := xanterior;
  tabla.FieldByName('actual').AsString   := xactual;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTcontrolperiodo.getDatos(xperiodo: string);
// Objetivo...: recuperar atributos para un objeto dado
begin
  if tabla.FindKey([xperiodo]) then
    begin
     actual   := tabla.FieldByName('actual').AsString;
     anterior := tabla.FieldByName('anterior').AsString;
    end
  else
    begin
      actual := ''; anterior := '';
    end;
end;

procedure TTcontrolperiodo.Borrar(xperiodo: string);
// Objetivo...: recuperar atributos para un objeto dado
begin
  if tabla.FindKey([xperiodo]) then tabla.Delete;
end;

procedure TTcontrolperiodo.CambiarVia(xvia: string);
// Objetivo...: Determinar características multiempresa
begin
  tabla := nil;   // Necesitamos definirla de nuevo, para soporte de múltiples Vías
  //conectar(dbs.P.SessionName, dbs.P.PrivateDir);
end;

procedure TTcontrolperiodo.conectar;
// Objetivo...: Abrir tperiodos de persistencia
begin
  if not tabla.Active then tabla.Open;
end;

procedure TTcontrolperiodo.conectar(sesion, privatedir: string);
// Objetivo...: Abrir tperiodos de persistencia
begin
  tabla := datosdb.openDB('ctrlper.DB', 'actual', sesion, privatedir);
  if not tabla.Active then tabla.Open;
end;

procedure TTcontrolperiodo.desconectar;
// Objetivo...: cerrar tperiodos de persistencia
begin
  datosdb.closeDB(tabla);
end;

{===============================================================================}

function controlper: TTcontrolperiodo;
begin
  if xcontrolper = nil then
    xcontrolper := TTcontrolperiodo.Create('', '');
  Result := xcontrolper;
end;

{===============================================================================}

initialization

finalization
  xcontrolper.Free;

end.