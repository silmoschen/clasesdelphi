unit CArticulosGross;

interface

uses CArtic, SysUtils, DB, DBTables, CListar, CUtiles, CIDBFM, Classes;

type

TTArticuloGross = class(TTArticulos)
  Honorarios, Descuento, DHonorarios, DAranceles, DMedicamentos, Retiva: Real;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep, xhonorarios, xdescuento: real); overload;
  procedure   Grabar(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep, xhonorarios, xdescuento, xretiva: real); overload;
  procedure   getDatos(xcodart: String);

  procedure   GrabarRubro(xcodrubro, xDescrip: string; xhonorarios, xaranceles, xmedicamentos, xPorcentaje: real); overload;
  procedure   getDatosRubro(xcodrubro: string); override;

  procedure   OcultarColumnasAdicionales;
 private
  { Declaraciones Privadas }
end;

function art: TTArticuloGross;

implementation

var
  xart: TTArticuloGross = nil;

//------------------------------------------------------------------------------

procedure TTArticuloGross.Grabar(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep, xhonorarios, xdescuento: real);
Begin
  inherited Grabar(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva, xpuntorep);
  tabla.Edit;
  tabla.FieldByName('honorarios').AsFloat := xhonorarios;
  tabla.FieldByName('descuento').AsFloat  := xdescuento;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
end;

procedure TTArticuloGross.Grabar(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep, xhonorarios, xdescuento, xretiva: real);
Begin
  inherited Grabar(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva, xpuntorep);
  tabla.Edit;
  tabla.FieldByName('honorarios').AsFloat := xhonorarios;
  tabla.FieldByName('descuento').AsFloat  := xdescuento;
  tabla.FieldByName('retiva').AsFloat     := xretiva;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
end;

procedure TTArticuloGross.getDatos(xcodart: String);
Begin
  inherited getDatos(xcodart);
  if ArticuloEncontrado then Begin
    Honorarios := tabla.FieldByName('honorarios').AsFloat;
    Descuento  := tabla.FieldByName('descuento').AsFloat;
    if datosdb.verificarSiExisteCampo(tabla, 'retiva') then Retiva := tabla.FieldByName('retiva').AsFloat;
  end else Begin
    Honorarios := 0; Descuento := 0; retiva := 0;
  end;
end;

procedure TTArticuloGross.GrabarRubro(xcodrubro, xdescrip: string; xhonorarios, xaranceles, xmedicamentos, xporcentaje: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarRubro(xcodrubro) then trubro.Edit else trubro.Append;
  trubro.FieldByName('codrubro').AsString    := xcodrubro;
  trubro.FieldByName('descrip').AsString     := xdescrip;
  trubro.FieldByName('honorarios').AsFloat   := xhonorarios;
  trubro.FieldByName('aranceles').AsFloat    := xaranceles;
  trubro.FieldByName('medicamentos').AsFloat := xmedicamentos;
  trubro.FieldByName('porcentaje').AsFloat   := xporcentaje;
  try
    trubro.Post
  except
    trubro.Cancel
  end;
end;

procedure  TTArticuloGross.getDatosRubro(xcodrubro: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarRubro(xcodrubro) then Begin
    codrubro      := trubro.FieldByName('codrubro').AsString;
    desrubro      := trubro.FieldByName('descrip').AsString;
    dhonorarios   := trubro.FieldByName('honorarios').AsFloat;
    daranceles    := trubro.FieldByName('aranceles').AsFloat;
    dmedicamentos := trubro.FieldByName('medicamentos').AsFloat;
    porcentaje    := trubro.FieldByName('porcentaje').AsFloat;
  end else Begin
    codrubro := ''; desrubro := ''; porcentaje := 0; daranceles := 0; dmedicamentos := 0; dhonorarios := 0;
  end;
end;

constructor TTArticuloGross.Create;
begin
  inherited Create('', '', '', '', '', '', '', '', '', '', '', 0);
  tabla := datosdb.openDB('articulo', 'codart');
end;

destructor TTArticuloGross.Destroy;
begin
  inherited Destroy;
end;

procedure TTArticuloGross.OcultarColumnasAdicionales;
// Objetivo...: Ocultar las columnas adicionales
Begin
  trubro.FieldByName('honorarios').Visible   := False;
  trubro.FieldByName('aranceles').Visible    := False;
  trubro.FieldByName('medicamentos').Visible := False;
  trubro.FieldByName('porcentaje').Visible   := False;
end;

{===============================================================================}

function art: TTArticuloGross;
begin
  if xart = nil then
    xart := TTArticuloGross.Create;
  Result := xart;
end;

{===============================================================================}

initialization

finalization
  xart.Free;

end.