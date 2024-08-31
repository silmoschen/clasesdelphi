unit CDigitoVerificador;

interface

uses SysUtils;

type

TTDigitoVerificador = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    setDigitoVerificador(xnumero: String): String;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function digitoverificador: TTDigitoVerificador;

implementation

var
  xdigitoverificador: TTDigitoVerificador = nil;

constructor TTDigitoVerificador.Create;
begin
end;

destructor TTDigitoVerificador.Destroy;
begin
  inherited Destroy;
end;


function TTDigitoVerificador.setDigitoVerificador(xnumero: String): String;
// Objetivo...: Obtener Dígito Verificador
var
  i, j, vin, suma, resto: Integer;
  num: String;
begin
  j   := Length(Trim(xnumero));
  num := Trim(xnumero);
  vin := 2; suma := 0;
  For i := j  downto 1 do Begin
    suma := suma + StrToInt(Copy(num, i, 1)) * vin;
    Inc(vin);
    if vin > 7 then vin := 2;
  end;

  if j > 0 then Begin
    resto := suma mod 11;
    Result := Copy(IntToStr(11 - resto), 1, 1);
    //Result := IntToStr(11 - resto);
  end else
    Result := '';
end;

{===============================================================================}

function digitoverificador: TTDigitoVerificador;
begin
  if xdigitoverificador = nil then
    xdigitoverificador := TTDigitoVerificador.Create;
  Result := xdigitoverificador;
end;

{===============================================================================}

initialization

finalization
  xdigitoverificador.Free;

end.
