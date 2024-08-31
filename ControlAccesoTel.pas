unit ControlAccesoTel;

interface

uses SysUtils, Forms, CUtiles, Dialogs, VERLOGS;

type
 TControl = Record      // Definimos el registro que almacena el log
   Cuenta: string[20];
   Fecha: string[8];
   Hinicio: string[5];
   HSalida: string[5];
   Duracion: string[9];
 end;

TTControles = class(TObject)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Guardar(xcuenta, xfecha, xhinicio, xhsalida, xduracion: string);
  procedure   Consultar;
  procedure   Borrar;

 private
  { Declaraciones Privadas }
protected
  { Declaraciones Protegidas }
end;

function control: TTControles;

implementation

var
  registro: TControl;
  ctrlAcceso: File of TControl;
  xcontrol: TTControles = nil;

constructor TTControles.Create;
begin
  inherited Create;
end;

destructor TTControles.Destroy;
begin
  inherited Destroy;
end;

procedure TTControles.Guardar(xcuenta, xfecha, xhinicio, xhsalida, xduracion: string);
// Objetivo...: Guardar una entrada
begin
  AssignFile(ctrlAcceso, 'ffffx001.x00');
  if FileExists('ffffx001.x00') then Reset(ctrlAcceso) else Rewrite(ctrlAcceso);

  Seek(ctrlAcceso, FileSize(ctrlAcceso));

  registro.cuenta   := xcuenta;
  registro.fecha    := xfecha;
  registro.hinicio  := xhinicio;
  registro.hsalida  := xhsalida;
  registro.duracion := xduracion;

  Try
    Write(ctrlAcceso, registro);
   Except On Exception Do ShowMessage('Fallo de escirura');
  end;

  CloseFile(ctrlAcceso);
end;

procedure TTControles.Consultar;
// Objetivo...: Consultar el log
var
  f: boolean; i: integer;
begin
  AssignFile(ctrlAcceso, 'ffffx001.x00');
  if FileExists('ffffx001.x00') then Begin
    Reset(ctrlAcceso);
    f := True;
  end else Begin
    f := False;
    ShowMessage('No se registraron ingresos');
  end;

  if f then Begin

    Application.CreateForm(TfmConsultar, fmConsultar);
    i := 0;
    while not EOF(ctrlAcceso) do Begin
      Read(ctrlAcceso, registro);
      Inc(i);
      fmConsultar.F.Cells[0, i] := registro.Cuenta;
      fmConsultar.F.Cells[1, i] := registro.Fecha;
      fmConsultar.F.Cells[2, i] := registro.Hinicio;
      fmConsultar.F.Cells[3, i] := registro.HSalida;
      fmConsultar.F.Cells[4, i] := registro.Duracion;
    end;

    CloseFile(ctrlAcceso);
    if i > 0 then fmConsultar.Label3.Caption := IntToStr(i) else fmConsultar.Label3.Caption := '1';
    fmConsultar.nroitems := i;
    fmConsultar.ShowModal;
    fmConsultar.Release; fmConsultar := nil;

  end;
end;

procedure TTControles.Borrar;
// Objetivo...: Consultar el log
begin
  AssignFile(ctrlAcceso, 'ffffx001.x00');
  if FileExists('ffffx001.x00') then Rewrite(ctrlAcceso);
end;

{===============================================================================}

function control: TTControles;
begin
  if xcontrol = nil then
    xcontrol := TTControles.Create;
  Result := xcontrol;
end;

{===============================================================================}

initialization

finalization
  xcontrol.Free;

end.
