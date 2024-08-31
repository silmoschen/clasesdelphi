{Objetivo...: Clase que verifica un Password introducido, teniendo
              en cuenta si el sistema tiene o no habilitada la protección ...
Version....: 1.0
Autor......: Silvio Moschen
Heredada de: Superclase}

unit CVerPasw;

interface

uses CBDT, DB, DBTables, CHabpw, SysUtils, Forms, pasword;

type

TTVerifPassword = class(TObject)          // Clase Base
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function verifPassword(clave: string): boolean;
  function getNivelProteccion: byte;
 private
  { Declaraciones Privadas }
  protegido: shortint;
  function testPassword(clave: string): boolean;
end;

function ctrlPas: TTVerifPassword;

implementation

var
  xctrlPas: TTVerifPassword = nil;

constructor TTVerifPassword.Create;
begin
  inherited Create;
  protegido := 0;
end;

destructor TTVerifPassword.Destroy;
begin
  inherited Destroy;
end;

function TTVerifPassword.verifPassword(clave: string): boolean;
begin
  datospw.conectar;
  protegido := datospw.getEstado;

  if protegido = 1 then Result := True else     // si protegido es cero significa que el nivel del usuario seleccionado es sin protección ...
    Result := testPassword(clave);  // ... caso contrario hacemos la verificación del password
  datospw.desconectar;
end;

function TTVerifPassword.getNivelProteccion: byte;
// Objetivo...: Devolver el estado de protección, es decir, si está o o protegido
begin
  datospw.conectar;
  Result := datospw.getEstado;
  datospw.desconectar;
end;

function TTVerifPassword.testPassword(clave: string): boolean;
begin
  Application.CreateForm(TfmPasword, fmPasword);
  fmPasword.clave_acceso := clave;
  fmPasword.ShowModal;
  if fmPasword.pwdok then Result := True else Result := False;
  fmPasword.Free;
end;

{===============================================================================}

function ctrlPas: TTVerifPassword;
begin
  if xctrlPas = nil then
    xctrlPas := TTVerifPassword.Create;
  Result := xctrlPas;
end;

{===============================================================================}

initialization

finalization
  xctrlPas.Free;

end.