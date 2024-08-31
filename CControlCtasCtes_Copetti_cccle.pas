unit CControlCtasCtes_Copetti_cccle;

interface

uses CControlCtasCtes_Copetti, CccteclEspecial, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTControlCtasCtes_cccle = class(TTControlCtasCtes)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  procedure DatosTitularCtaCte(xidtitular: String); override;
end;

function controlcccle: TTControlCtasCtes_cccle;

implementation

var
  xcontrolcccle: TTControlCtasCtes_cccle = nil;

constructor TTControlCtasCtes_cccle.Create;
begin
  inherited create;
  audit_ctasctes := datosdb.openDB('auditoria_cccle', '', '');
end;

destructor TTControlCtasCtes_cccle.Destroy;
begin
  inherited Destroy;
end;

procedure TTControlCtasCtes_cccle.DatosTitularCtaCte(xidtitular: String);
Begin
  titular := cccle.getCliente(xidtitular);
end;

{===============================================================================}

function controlcccle: TTControlCtasCtes_cccle;
begin
  if xcontrolcccle = nil then
    xcontrolcccle := TTControlCtasCtes_cccle.Create;
  Result := xcontrolcccle;
end;

{===============================================================================}

initialization

finalization
  xcontrolcccle.Free;

end.
