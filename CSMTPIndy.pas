unit CSMTPIndy;

interface

uses SysUtils, CUtiles;

type

TTSMTP = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

 private
  { Declaraciones Privadas }

end;


implementation

constructor TTSMTP.Create;
begin
end;

destructor TTSMTP.Destroy;
begin
  inherited Destroy;
end;

end.
