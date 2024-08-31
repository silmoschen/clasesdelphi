unit CFecha;

interface

uses SysUtils, CUtiles;

type

TTFecha = class(TObject)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  function    sigfecha(fecha: string; cant_dias: integer): string;
  function    ultimodiames(mes, anio: string): string;
 private
  { Declaraciones Privadas }
 end;

function vfecha: TTFecha;

implementation

var
  xfecha: TTFecha = nil;

constructor TTFecha.Create;
begin
  inherited Create;
end;

destructor TTFecha.Destroy;
begin
  inherited Destroy;
end;

function TTFecha.ultimodiames(mes, anio: string): string;
//Objetivo...: Devolver el últmio Día del mes
var
  dia: string;
begin
  dia := '';
  if mes = '02' then
    if StrToInt(anio) mod 4 = 0 then dia := '29' else dia := '28';
  if (mes = '01') or (mes = '03') or (mes = '05') or (mes = '07') or (mes = '08') or (mes = '10') or (mes = '12') then dia := '31';
  if (mes = '04') or (mes = '06') or (mes = '09') or (mes = '11') then dia := '30';
  Result := dia;
end;

function TTFecha.sigfecha(fecha: string; cant_dias: integer): string;
//Objetivo...: Obtener una fecha a los dias indicados en cant_dias
var
  mes, anio, dia: integer;
  smes, sdia, u : string;
  f: string;
begin
  f    := utiles.sExprFecha(fecha);   // Expresión del tipo ddddmmaa
  if cant_dias < 30 then dia := StrToInt(Copy(f, 7, 2)) + cant_dias else dia := StrToInt(Copy(f, 7, 2));

  // Tratamiento del mes
  anio := StrToInt(Copy(f, 1, 4));
  mes  := StrToInt(Copy(fecha, 4, 2));
  if cant_dias = 30 then Inc(mes);

  if cant_dias div 30 > 1 then mes := mes + cant_dias div 30;
  // Tratamiento del Año
  if mes > 12 then // Verificamos que el mes no se exeda
    begin
      mes  := mes  - 12;
      anio := anio + 1;
    end;

  // Ajustes ...
  smes := utiles.sLlenarIzquierda(inttostr(mes), 2, '0');
  sdia := utiles.sLlenarIzquierda(inttostr(dia), 2, '0');

  // Ajustes Finales
  u := ultimodiames(smes, inttostr(anio));
  if sdia > u then
    begin
      dia  := dia - StrToInt(u);
      sdia := utiles.sLlenarIzquierda(inttostr(dia), 2, '0');
      if u > '29' then  smes := utiles.sLlenarIzquierda(inttostr(mes + 1), 2, '0');
    end;

  Result := inttostr(anio) + smes + sdia;

end;

{===============================================================================}

function vfecha: TTFecha;
begin
  if xfecha = nil then
    xfecha := TTFecha.Create;
  Result := xfecha;
end;

{===============================================================================}

initialization

finalization
  xfecha.Free;

end.
