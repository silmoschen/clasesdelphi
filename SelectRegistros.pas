unit SelectRegistros;

interface

uses DB, DBTables;

type

TTSelectRegistros = class(TObject)
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   xselectreg(tabla: TTable; campo: string);
    procedure   xSelTodos(tabla: TTable; campo: string; t_marca: string);
    procedure   xDesMarcar(tabla: TTable; campo: string);
end;

function selectreg: TTSelectRegistros;

implementation

var
  xselectreg: TTSelectRegistros = nil;

constructor TTSelectRegistros.Create;
// Objetivo...: Implementación del constructor
begin
  inherited Create;
end;

destructor TTSelectRegistros.Destroy;
// Objetivo...: Implementación del destructor
begin
  inherited Destroy;
end;

procedure TTSelectRegistros.xselectreg(tabla: TTable; campo: string);
//Objetivo...: Marcar/Desmarcar Registros ante un Evento
var
  x: string;
begin
  if tabla.FieldByName(campo).AsString = '' then x := 'X' else x := ' ';
  tabla.Edit;
  tabla.FieldByName(campo).AsString := x;
  tabla.Post;
  if not tabla.EOF then tabla.Next;
  tabla.Refresh;
end;

procedure TTSelectRegistros.xSelTodos(tabla: TTable; campo: string; t_marca: string);
//Objetivo...: Marcar/Desmarcar Todos los Registros ante un Evento
var
  n_rec: integer;
begin
  n_rec := tabla.Recno;
  tabla.First;
  while not tabla.EOF do
    begin
      tabla.Edit;
      tabla.FieldByName(campo).AsString := t_marca;
      tabla.Post;
      tabla.Next;
      tabla.Refresh;
    end;

  tabla.First; // Restablecer la Posisción Original del Registro
  while tabla.Recno <> n_rec do tabla.Next;
  tabla.Refresh;
end;

procedure TTSelectRegistros.xDesMarcar(tabla: TTable; campo: string);
//Objetivo...: Marcar/Desmarcar Registros ante un Evento
begin
  if tabla <> nil then
    begin
      if not tabla.Active then tabla.Open;
      tabla.First;
      while not tabla.EOF do
        begin
          if tabla.FieldByName(campo).AsString <> '' then
            begin
              tabla.Edit;
              tabla.FieldByName(campo).AsString := ' ';
              tabla.Post;
            end;
          tabla.Next;
        end;
        tabla.Refresh;
    end;
end;

{===============================================================================}

function selectreg: TTSelectRegistros;
begin
  if xselectreg = nil then
    xselectreg := TTSelectRegistros.Create;
  Result := xselectreg;
end;

{===============================================================================}

initialization

finalization
  xselectreg.Free;

end.
