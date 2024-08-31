unit CForm;

interface

uses CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTForms = class(TObject)
  nroform, feoper, dominio: string;
  monto: real;
  tform: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xnroform, xfeoper, xdominio: string; xmonto: real);
  destructor  Destroy; override;

  function    Buscar(xnroform: string): boolean;
  procedure   Grabar(xnroform, xfeoper, xdominio: string; xmonto: real);
  procedure   Borrar(xnroform: string);
  procedure   getDatos(xnroform: string);

 private
  { Declaraciones Privadas }
end;

function forms: TTForms;

implementation

var
  xforms: TTForms = nil;

constructor TTForms.Create(xnroform, xfeoper, xdominio: string; xmonto: real);
// Vendedor - Heredada de Persona
begin
  nroform   := xnroform;
  feoper    := xfeoper;
  dominio   := xdominio;
  monto     := xmonto;
end;

destructor TTForms.Destroy;
begin
  inherited Destroy;
end;

function TTForms.Buscar(xnroform: string): boolean;
// Objetivo...: buscar una instancia
begin
  if tform.FindKey([xnroform]) then Result := True else Result := False;
end;

procedure TTForms.Grabar(xnroform, xfeoper, xdominio: string; xmonto: real);
// Objetivo...: Grabar una instacia
begin
  if Buscar(xnroform) then tform.Edit else tform.Append;
  tform.FieldByName('nroform').AsString := xnroform;
  tform.FieldByName('feoper').AsString  := utiles.sExprFecha(xfeoper);
  tform.FieldByName('dominio').AsString := xdominio;
  tform.FieldByName('monto').AsFloat    := xmonto;
  try
    tform.Post;
  except
    tform.Cancel;
  end;
end;

procedure TTForms.Borrar(xnroform: string);
// Objetivo...: Borrar una instancia de la clase
begin
  if Buscar(xnroform) then
    begin
      tform.Delete;
      getDatos(tform.FieldByName('nroform').AsString);
    end;
end;

procedure TTForms.getDatos(xnroform: string);
// Objetivo...: Cargar los atributos de una instacia
begin
  if Buscar(xnroform) then
    begin
      nroform := tform.FieldByName('nroform').AsString;
      feoper  := utiles.sFormatoFecha(tform.FieldByName('feoper').AsString);
      dominio := tform.FieldByName('dominio').AsString;
      monto   := tform.FieldByName('monto').AsFloat;
    end
  else
    begin
      nroform := ''; feoper := ''; dominio:= ''; monto := 0;
    end;
end;

{===============================================================================}

function forms: TTForms;
begin
  if xforms = nil then
    xforms := TTForms.Create('', '', '', 0);
  Result := xforms;
end;

{===============================================================================}

initialization

finalization
  xforms.Free;

end.