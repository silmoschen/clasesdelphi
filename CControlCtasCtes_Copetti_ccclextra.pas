unit CControlCtasCtes_Copetti_ccclextra;

interface

uses CControlCtasCtes_Copetti, CccteclExtra, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTControlCtasCtes_ccclextra = class(TTControlCtasCtes)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  procedure DatosTitularCtaCte(xidtitular: String); override;
end;

function controlccclextra: TTControlCtasCtes_ccclextra;

implementation

var
  xcontrolccclextra: TTControlCtasCtes_ccclextra = nil;

constructor TTControlCtasCtes_ccclextra.Create;
begin
  inherited create;
  audit_ctasctes := datosdb.openDB('auditoria_ccclextra', '', '');
end;

destructor TTControlCtasCtes_ccclextra.Destroy;
begin
  inherited Destroy;
end;

procedure TTControlCtasCtes_ccclextra.DatosTitularCtaCte(xidtitular: String);
Begin
  titular := ccclextra.getCliente(xidtitular);
end;

{===============================================================================}

function controlccclextra: TTControlCtasCtes_ccclextra;
begin
  if xcontrolccclextra = nil then
    xcontrolccclextra := TTControlCtasCtes_ccclextra.Create;
  Result := xcontrolccclextra;
end;

{===============================================================================}

initialization

finalization
  xcontrolccclextra.Free;

end.
