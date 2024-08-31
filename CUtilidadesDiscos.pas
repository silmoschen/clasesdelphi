unit CUtilidadesDiscos;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  StdCtrls, FileCtrl, Forms;

type
  TTTUtilidadesDiscos = class(TForm)
    function  FormatDiskette(xdrive: Char; VisualizarMsgFormateado: Boolean): Boolean;
    function  DiskInDrive(Drive: Char): Boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TTUtilidadesDiscos: TTTUtilidadesDiscos;

implementation

{$R *.DFM}

const UNIDAD_A = 0;
      UNIDAD_B = 1;
      POR_DEFECTO = $FFFF;

      FORMATORAPIDO = 0;
      FORMATOCOMPLETO = 1;
      FORMATOSISTEMA = 2;

      ERROR = -1;
      CANCELADO = -2;
      NO_FORMATEADO = -3;


function SHFormatDrive(hWnd : HWND;
                       Unidad : Word;
                       fmtID : Word;
                       Opciones : Word) : Longint stdcall; external
                      'Shell32.dll' name 'SHFormatDrive';

{...y este procedimiento muestra el diálogo típico de formato}
function TTTUtilidadesDiscos.FormatDiskette(xdrive: Char; VisualizarMsgFormateado: Boolean): Boolean;
var
   Resultado: Longint;
begin
   Result   := False;
   if lowercase(xdrive) = 'a' then
     Resultado:= ShFormatDrive(Handle, UNIDAD_A, POR_DEFECTO,
                  FORMATORAPIDO);
   if lowercase(xdrive) = 'b' then
     Resultado:= ShFormatDrive(Handle, UNIDAD_B, POR_DEFECTO,
                  FORMATORAPIDO);

   case Resultado  of
      ERROR : ShowMessage('Error al formatear el disco');
      CANCELADO : ShowMessage('Operación cancelada por el usuario');
      NO_FORMATEADO : ShowMessage('No se ha formateado')
   else Begin
      if VisualizarMsgFormateado then ShowMessage('El disco ha sido formateado satisfactoriamente');
      Result := True;
   end;
   end;
end;

function TTTUtilidadesDiscos.DiskInDrive(Drive: Char): Boolean;
var
  ErrorMode: word;
begin
  { make it upper case }
  if Drive in ['a'..'z'] then Dec(Drive, $20);
  { make sure it's a letter }
  if not (Drive in ['A'..'Z']) then
    raise EConvertError.Create('Unidad No Válida');
  { turn off critical errors }
  ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
  try
    { drive 1 = a, 2 = b, 3 = c, etc. }
    if DiskSize(Ord(Drive) - $40) = -1 then
      Result := False
     else
      Result := True;
      finally
      { restore old error mode }
      SetErrorMode(ErrorMode);
    end;
  end;

end.
