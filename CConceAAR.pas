unit CConceAAR;

interface

uses CConcepto, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTConceptosAAR = class(TTConceptos)
 public
  { Declaraciones Públicas }
  constructor Create(xcodconc, xdescrip: string);
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
end;

function conceptoar: TTConceptosAAR;

implementation

var
  xconceptoar: TTConceptosAAR = nil;

constructor TTConceptosAAR.Create(xcodconc, xdescrip: string);
begin
  inherited Create(xcodconc, xdescrip);

  tabla := datosdb.openDB('conceAAR', 'codconc');
end;

destructor TTConceptosAAR.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function conceptoar: TTConceptosAAR;
begin
  if xconceptoar = nil then
    xconceptoar := TTConceptosAAR.Create('', '');
  Result := xconceptoar;
end;

{===============================================================================}

initialization

finalization
  xconceptoar.Free;

end.