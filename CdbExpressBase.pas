unit CdbExpressBase;

interface

uses SysUtils, CUtiles, CDDBExpress, Forms;

type

TTdbExpressBase = class
  conn: TTdbExpress;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

 private
  { Declaraciones Privadas }
end;

function dbEx: TTdbExpressBase;

implementation

var
  xdbEx: TTdbExpressBase = nil;

constructor TTdbExpressBase.Create;
begin
  conn := TTdbExpress.Create;
  conn.Conectar(Copy(ExtractFilePath(Application.ExeName), 1, Length(ExtractFilePath(Application.ExeName))-1) + '\firebird.conf');
  //conn.Conectar('C:\sidelphi32\SGen\isp4dbExpress\Interbase\isp4.gdb',
    //                 'sysdba', 'masterkey', 'Interbase', 'getSQLDriverINTERBASE', 'dbxint30.dll', 'GDS32.DLL');
end;

destructor TTdbExpressBase.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function dbEx: TTdbExpressBase;
begin
  if xdbEx = nil then
    xdbEx := TTdbExpressBase.Create;
  Result := xdbEx;
end;

{===============================================================================}

initialization

finalization
  xdbEx.Free;

end.
