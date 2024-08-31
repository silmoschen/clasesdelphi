unit CConceRS;

interface

uses CConcepto, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTConceptosRS = class(TTConceptos)
 public
  { Declaraciones Públicas }
  constructor Create(xcodconc, xdescrip: string);
  destructor  Destroy; override;

 private
  { Declaraciones Privadas }
end;

function concepto: TTConceptosRS;

implementation

var
  xconcepto: TTConceptosRS = nil;

constructor TTConceptosRS.Create(xcodconc, xdescrip: string);
begin
  inherited Create(xcodconc, xdescrip);

  tabla := datosdb.openDB('conceptos', 'codconc');
end;

destructor TTConceptosRS.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function concepto: TTConceptosRS;
begin
  if xconcepto = nil then
    xconcepto := TTConceptosRS.Create('', '');
  Result := xconcepto;
end;

{===============================================================================}

initialization

finalization
  xconcepto.Free;

end.