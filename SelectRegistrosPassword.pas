unit SelectRegistrosPassword;

interface

uses SysUtils, SelectRegistros, DB, DBTables, Forms, CVerPasw;

type

TTSelectRegistrospw = class(TTSelectRegistros)
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   xselectreg(tabla: TTable; campo: string);
    procedure   xSelTodos(tabla: TTable; campo: string; t_marca: string);
end;

function selectreg: TTSelectRegistrospw;

implementation

var
  xselectreg: TTSelectRegistrospw = nil;

constructor TTSelectRegistrospw.Create;
// Objetivo...: Implementación del constructor
begin
  inherited Create;
end;

destructor TTSelectRegistrospw.Destroy;
// Objetivo...: Implementación del destructor
begin
  inherited Destroy;
end;

 procedure TTSelectRegistrospw.xselectreg(tabla: TTable; campo: string);
//Objetivo...: Marcar/Desmarcar Registros ante un Evento
begin
  if tabla.FieldByName(campo).AsString = 'X' then
    inherited xselectreg(tabla, campo)
  else
   if Length(trim(tabla.FieldByName('clave').AsString)) = 0 then inherited xselectreg(tabla, campo) else
     if ctrlPas.verifPassword(tabla.FieldByName('clave').AsString) then inherited xselectreg(tabla, campo);
end;

procedure TTSelectRegistrospw.xSelTodos(tabla: TTable; campo: string; t_marca: string);
//Objetivo...: Marcar/Desmarcar Todos los Registros ante un Evento
var
  n_rec: integer;
begin
  n_rec := tabla.Recno;
  tabla.First;
  while not tabla.EOF do
    begin
      if (Length(Trim(tabla.FieldByName('clave').AsString)) = 0) or (ctrlPas.getNivelProteccion = 1) then
        begin
          tabla.Edit;
          tabla.FieldByName(campo).AsString := t_marca;
          tabla.Post;
        end;
      if (Length(Trim(tabla.FieldByName('sel').AsString)) > 0) and (t_marca <> 'X') then
        begin
          tabla.Edit;
          tabla.FieldByName(campo).AsString := ' ';
          tabla.Post;
        end;
      tabla.Next;
    end;

  tabla.Refresh;
  tabla.First; // Restablecer la Posisción Original del Registro
  while tabla.Recno <> n_rec do tabla.Next;
end;

{===============================================================================}

function selectreg: TTSelectRegistrospw;
begin
  if xselectreg = nil then
    xselectreg := TTSelectRegistrospw.Create;
  Result := xselectreg;
end;

{===============================================================================}

initialization

finalization
  xselectreg.Free;

end.
