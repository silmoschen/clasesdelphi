unit CdbExpress;

interface

uses FMTBcd, DB, SqlExpr, SysUtils;

type

TTdbExpress = class
  DBEDatabase: TSQLConnection;
  DBETable: TSQLTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function   Conectar(xbasedatos, xusuario, xpassword, xdriver, xgetDriverFunc, xLibraryName, xvendorLib: String): Boolean;

 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function dbExpress: TTdbExpress;

implementation

var
  xdbExpress: TTdbExpress = nil;

constructor TTdbExpress.Create;
begin
end;

destructor TTdbExpress.Destroy;
begin
  inherited Destroy;
end;

function TTdbExpress.(xbasedatos, xusuario, xpassword, xdriver, xgetDriverFunc, xLibraryName, xvendorLib: String): Boolean;
// Objetivo...: Establecer una conexión a un Driver
Begin
  if DBEDatabase = Nil then Begin
    DBEDatabase := DBEDatabase.Create(nil);
    DBEDatabase.DriverName    := xdriver;
    DBEDatabase.Params.Add('database=' + xbasedatos);
    DBEDatabase.Params.Add('user_name=' + xusuario);
    DBEDatabase.Params.Add('password=' + xpassword);
    DBEDatabase.GetDriverFunc := xgetDriverFunc;
    DBEDatabase.LibraryName   := xlibraryName;
    DBEDatabase.VendorLib     := xvendorLib;
    DBEDatabase.LoginPrompt   := False;
    try
      DBEDatabase.Connected := True;
    except
      on E:DBExpress do utiles.msgError(E.Message + ' ' + IntToStr(E.IBErrorCode));
    end;
  End;
End;

{===============================================================================}

function dbExpress: TTdbExpress;
begin
  if xdbExpress = nil then
    xdbExpress := TTdbExpress.Create;
  Result := xdbExpress;
end;

{===============================================================================}

initialization

finalization
  xdbExpress.Free;

end.
