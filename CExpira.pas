unit CExpira;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, MsgExpiracion;

type

TTExpira = class(TObject)
  Fecha: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Verificar(xfecha: string): boolean;
  function    VerificarExpiracion(xfecha, xfechaexpiracion: string): boolean;
 private
  { Declaraciones Privadas }
  function  sExprFecha2000(fecha: string): string;
end;

function expira: TTExpira;

implementation

var
  xexpira: TTExpira = nil;

constructor TTExpira.Create;
begin
  inherited Create;
end;

destructor TTExpira.Destroy;
begin
  inherited Destroy;
end;

function TTExpira.Verificar(xfecha: string): boolean;
// Objetivo...: determinar estado del sistema
begin
  Result := False;
  if Length(Trim(fecha)) = 0 then Result := True else Begin
    if sExprFecha2000(xfecha) >= sExprFecha2000(Fecha) then Begin
      Application.CreateForm(TfmExpira, fmExpira);
      fmExpira.ShowModal;
      fmExpira.Release; fmExpira := Nil;
      Application.Terminate;
      Result := False;
    end;
  end;
end;

function  TTExpira.sExprFecha2000(fecha: string): string;
{Objetivo....: Dada una fecha, convertirla al Formato aaaammdd}
var
  sFecha, anio: string;
begin
  if Length(Trim(fecha)) > 4 then
    begin
      sFecha := FormatDateTime('dd/mm/yyyy', StrToDateTime(Fecha));
      if Length(Trim(fecha)) = 8 then
        if (Copy(fecha, 7, 2) > '07') then anio := '20' + Copy(fecha, 7, 2) else anio := Copy(sFecha, 7, 4);
      if Length(Trim(fecha)) > 8 then
        if (Copy(fecha, 9, 2) > '07') then anio := '20' + Copy(fecha, 7, 2) else anio := Copy(sFecha, 7, 4);
      if Copy(anio, 3, 2) > '50' then anio := '19' + Copy(anio, 3, 2);
      Result := anio + Copy(sFecha, 4, 2) + Copy(sFecha, 1, 2);
    end
  else
    Result := '  /  /  ';
end;

function TTExpira.VerificarExpiracion(xfecha, xfechaexpiracion: string): boolean;
// Objetivo...: verificar expiración
var
  d, lec: String;
  archivo: TextFile;
begin
  fecha  := xfechaexpiracion;
  d      := ExtractFilePath(Application.ExeName) + Copy(ExtractFileName(Application.ExeName), 1, Length(ExtractFileName(Application.ExeName)) - 4) + '.dat';
  Result := False;
  if Length(Trim(xfechaexpiracion)) < 8 then Result := True else Begin

    if not FileExists(d) then Begin
      AssignFile(archivo, d);
      Rewrite(archivo);
      WriteLn(archivo, 'zsdklmntz');
      closeFile(archivo);
    end;

    if Length(Trim(fecha)) = 0 then Result := True else Begin
      if sExprFecha2000(xfecha) >= sExprFecha2000(Fecha) then Begin
        AssignFile(archivo, d);
        Rewrite(archivo);
        WriteLn(archivo, 'zsdklmnztz');
        closeFile(archivo);
        Application.CreateForm(TfmExpira, fmExpira);
        fmExpira.ShowModal;
        fmExpira.Release; fmExpira := Nil;
        Application.Terminate;
        Result := False;
      end;
    end;

    if FileExists(d) then Begin
      AssignFile(archivo, d);
      Reset(archivo);
      ReadLn(archivo, lec);
      closeFile(archivo);
      if lec = 'zsdklmnztz' then Begin
        Application.CreateForm(TfmExpira, fmExpira);
        fmExpira.ShowModal;
        fmExpira.Release; fmExpira := Nil;
        Application.Terminate;
        Result := False;
      end;
    end;
  end;
end;

{===============================================================================}

function expira: TTExpira;
begin
  if xexpira = nil then
    xexpira := TTExpira.Create;
  Result := xexpira;
end;

{===============================================================================}

initialization

finalization
  xexpira.Free;

end.