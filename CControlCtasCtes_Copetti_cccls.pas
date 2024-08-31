unit CControlCtasCtes_Copetti_cccls;

interface

uses CControlCtasCtes_Copetti, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CccteclSimple;

type

TTControlCtasCtes_cccls = class(TTControlCtasCtes)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  procedure DatosTitularCtaCte(xidtitular: String); override;
end;

function controlcccls: TTControlCtasCtes_cccls;

implementation

var
  xcontrolcccls: TTControlCtasCtes_cccls = nil;

constructor TTControlCtasCtes_cccls.Create;
begin
  inherited create;
  audit_ctasctes := datosdb.openDB('auditoria_cccls', '', '');
end;

destructor TTControlCtasCtes_cccls.Destroy;
begin
  inherited Destroy;
end;

procedure TTControlCtasCtes_cccls.DatosTitularCtaCte(xidtitular: String);
Begin
  titular := cccls.getCliente(xidtitular); 
end;

{===============================================================================}

function controlcccls: TTControlCtasCtes_cccls;
begin
  if xcontrolcccls = nil then
    xcontrolcccls := TTControlCtasCtes_cccls.Create;
  Result := xcontrolcccls;
end;

{===============================================================================}

initialization

finalization
  xcontrolcccls.Free;

end.
