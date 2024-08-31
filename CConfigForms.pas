unit CConfigForms;

interface

uses SysUtils, CUtiles, Forms, Classes;

type

TTConfigForms = class
 public
  { Declaraciones Públicas }
  guardarSeteos: Boolean; EstiloFondo: Integer;
  constructor Create;
  destructor  Destroy; override;

  procedure Guardar(xform: TForm; xredimensionado: Boolean); overload;
  function  Setear(xform: TForm): Boolean;
  procedure GuardarImagenDeFondo(xform: TForm; ximagen: String; Estilo: Integer);
  function  RecuperarImagenDeFondo(xform: TForm): String;
  procedure GuardarEfectosDeSonido(xestado: Boolean);
  function  setEfectosDeSonido: Boolean;

  procedure GuardarListaBotonesVisiblesMDI(xlista: TStringList);
  function  setListaBotonesVisiblesMDI: TStringList;
 private
  { Declaraciones Privadas }
  archivo: TextFile;
  DirSistema: String;
  ftop, fttop, ftleft, fleft: Integer;   // Manejadores de altos para los MDIForms y los Modal
  procedure Guardar(xform: TForm); overload;
end;

function configform: TTConfigForms;

implementation

var
  xconfigform: TTConfigForms = nil;

constructor TTConfigForms.Create;
begin
  guardarSeteos := True;
  DirSistema := Copy(ExtractFilePath(Application.ExeName), 1, Length(ExtractFilePath(Application.ExeName))-1);
end;

destructor TTConfigForms.Destroy;
begin
  inherited Destroy;
end;

procedure TTConfigForms.Guardar(xform: TForm);
// Objetivo...: Guardar la configuración del form
Begin
  if Assigned(xform) then
    if (xform.WindowState = wsNormal) and (guardarSeteos) then Begin    // Solo Guardamos si el estado del form es normal
      AssignFile(archivo, DirSistema + '\' + lowercase(xform.Name) + '.ini');
      rewrite(archivo);
      if xform.FormStyle = FsMDIChild then WriteLn(archivo, xform.top) else WriteLn(archivo, ftop);
      if xform.FormStyle = FsMDIChild then WriteLn(archivo, xform.left) else WriteLn(archivo, fleft);
      WriteLn(archivo, xform.width);
      WriteLn(archivo, xform.height);
      if xform.FormStyle <> FsMDIChild then WriteLn(archivo, xform.top) else WriteLn(archivo, fttop);
      if xform.FormStyle <> FsMDIChild then WriteLn(archivo, xform.left) else WriteLn(archivo, ftleft);
      closeFile(archivo);
    end;
end;

procedure TTConfigForms.Guardar(xform: TForm; xredimensionado: Boolean);
// Objetivo...: Guardar la configuración del form
Begin
  if xredimensionado then Guardar(xform);
end;

function TTConfigForms.Setear(xform: TForm): Boolean;
// Objetivo...: Setear la configuración del form
var
  t, l, w, h, tt, ff: Integer;
Begin
  tt := 0;
  if FileExists(DirSistema + '\' + lowercase(xform.Name) + '.ini') then Begin
    AssignFile(archivo, DirSistema + '\' + {Copy(ExtractFilePath(Application.ExeName), 1, Length(ExtractFilePath(Application.ExeName))-1)} lowercase(xform.Name) + '.ini');
    reset(archivo);
    ReadLn(archivo, t); ReadLn(archivo, l); ReadLn(archivo, w); ReadLn(archivo, h); ReadLn(archivo, tt); ReadLn(archivo, ff);
    ftop := t; fttop := tt; ftleft := ff; fleft := l;
    if xform.FormStyle = FsMDIChild then Begin
      xform.Top  := t;
      xform.Left := l;
    end else Begin
      xform.Top  := tt;
      xform.Left := ff;
    end;
    xform.Width := w; xform.Height := h;
    closeFile(archivo);
    Result := True;
  end else
    Result := False;

  if xform.Left = 0 then xform.Left :=(Screen.Width - xform.Width) div 2;

  if (xform.FormStyle <> FsMDIChild) and (tt = 0) then Begin
    xform.Top := (Screen.Height - xform.Top) div 5;
    Result := True;
  end;
end;

procedure TTConfigForms.GuardarImagenDeFondo(xform: TForm; ximagen: String; Estilo: Integer);
// Objetivo...: Guardar la configuración del form de fondo
Begin
  AssignFile(archivo, DirSistema + '\' + lowercase(xform.Name) + '.ini');
  rewrite(archivo);
  WriteLn(archivo, ximagen);
  WriteLn(archivo, Estilo);
  closeFile(archivo);
end;

function TTConfigForms.RecuperarImagenDeFondo(xform: TForm): String;
// Objetivo...: Setear la configuración del form de fondo
var
  Imagen, Est: String;
Begin
  Imagen := '';
  if FileExists(DirSistema + '\' + lowercase(xform.Name) + '.ini') then Begin
    AssignFile(archivo, DirSistema + '\' + lowercase(xform.Name) + '.ini');
    reset(archivo);
    ReadLn(archivo, Imagen);
    ReadLn(archivo, Est);
    closeFile(archivo);
  end;
  if Length(Trim(Est)) > 0 then EstiloFondo := StrToInt(Est) + 1 else EstiloFondo := 1;
  Result := Imagen;
end;

procedure TTConfigForms.GuardarEfectosDeSonido(xestado: Boolean);
// Objetivo...: Guardar Botones activos
Begin
  AssignFile(archivo, DirSistema + '\' + 'sonidos.ini');
  rewrite(archivo);
  if xestado then WriteLn(archivo, '1') else WriteLn(archivo, '0');
  closeFile(archivo);
end;

function TTConfigForms.setEfectosDeSonido: Boolean;
// Objetivo...: Guardar Botones activos
var
  e: String;
Begin
  Result := False;
  if FileExists(DirSistema + '\' + 'sonidos.ini') then Begin
    AssignFile(archivo, DirSistema + '\' + 'sonidos.ini');
    reset(archivo);
    ReadLn(archivo, e);
    closeFile(archivo);
    if e = '1' then Result := True;
  end;
end;

procedure TTConfigForms.GuardarListaBotonesVisiblesMDI(xlista: TStringList);
// Objetivo...: Guardar Botones activos
var
  i: Integer;
Begin
  AssignFile(archivo, DirSistema + '\' + 'botones_visibles.ini');
  rewrite(archivo);
  for i := 1 to xlista.Count do WriteLn(archivo, xlista.Strings[i-1]);
  closeFile(archivo);
end;

function TTConfigForms.setListaBotonesVisiblesMDI: TStringList;
// Objetivo...: Recuperar una lista de botones visibles
var
  lista: TStringList;
  opt: String;
begin
  lista := TStringList.Create;
  lista.Clear;
  if FileExists(DirSistema + '\' + 'botones_visibles.ini') then Begin
    AssignFile(archivo, DirSistema + '\' + 'botones_visibles.ini');
    reset(archivo);
    while not eof(archivo) do Begin
      ReadLn(archivo, opt);
      lista.Add(opt);
    end;
    closeFile(archivo);
  end;
  Result := lista;
end;

{===============================================================================}

function configform: TTConfigForms;
begin
  if xconfigform = nil then
    xconfigform := TTConfigForms.Create;
  Result := xconfigform;
end;

{===============================================================================}

initialization

finalization
  xconfigform.Free;

end.
