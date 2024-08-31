unit CConServ;

interface

uses CConcepto, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTConServ = class(TTConceptos)
 public
  { Declaraciones Públicas }
  constructor Create(xcodconc, xdescrip: string);
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
end;

function conceptoser: TTConServ;

implementation

var
  xconceptoser: TTConServ = nil;

constructor TTConServ.Create(xcodconc, xdescrip: string);
begin
  inherited Create(xcodconc, xdescrip);

  tabla := datosdb.openDB('conserv', 'codconc');
end;

destructor TTConServ.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function conceptoser: TTConServ;
begin
  if xconceptoser = nil then
    xconceptoser := TTConServ.Create('', '');
  Result := xconceptoser;
end;

{===============================================================================}

initialization

finalization
  xconceptoser.Free;

end.