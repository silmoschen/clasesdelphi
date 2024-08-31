unit CArtSim;

interface

uses CArtic, SysUtils, DB, DBTables, CListar, CUtiles, CIDBFM;

type

TTArticuloSimple = class(TTArticulos)            // Superclase
  Retiva: Real;
 public
  { Declaraciones Públicas }
  constructor Create(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep: real);
  destructor  Destroy; override;

  procedure   GuardarRetIva(xcodart: String; xretiva: Real);
  procedure   getDatos(xcodart: String);

 private
  { Declaraciones Privadas }
end;

function art: TTArticuloSimple;

implementation

var
  xart: TTArticuloSimple = nil;

//------------------------------------------------------------------------------

constructor TTArticuloSimple.Create(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep: real);
begin
  inherited Create(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva, xpuntorep);
  tabla := datosdb.openDB('articulo', 'codart');
end;

destructor TTArticuloSimple.Destroy;
begin
  inherited Destroy;
end;

procedure TTArticuloSimple.GuardarRetIva(xcodart: String; xretiva: Real);
Begin
  if Buscar(xcodart) then Begin
    tabla.Edit;
    tabla.FieldByName('retiva').AsFloat := xretiva;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTArticuloSimple.getDatos(xcodart: String);
Begin
  if Buscar(xcodart) then Begin
    inherited getDatos(xcodart);
    retiva := tabla.FieldByName('retiva').AsFloat;
  end else
    retiva := 0;
end;


{===============================================================================}

function art: TTArticuloSimple;
begin
  if xart = nil then
    xart := TTArticuloSimple.Create('', '', '', '', '', '', '', '', '', '', '', 0);
  Result := xart;
end;

{===============================================================================}

initialization

finalization
  xart.Free;

end.