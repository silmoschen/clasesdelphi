unit SeleccionarRegistros;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ExtCtrls, DBCtrls, Grids, DBGrids, Db,
  ToolWin, DBTables, ImgList;

type
  TfmSeleccion = class(TForm)
    Seleccion: TDBGrid;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    DBNavigator: TDBNavigator;
    ToolBar1: TToolBar;
    SelectUno: TToolButton;
    SeletTodos: TToolButton;
    SelectNinguno: TToolButton;
    DTS: TDataSource;
    procedure Salir(Sender: TObject);
    procedure SelctTodos(Sender: TObject);
    procedure SeleccionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure SelReg(Sender: TObject);
    procedure SelTodos(Sender: TObject; modo: string);
    procedure DesMarcar;
    procedure ToolButton1Click(Sender: TObject);
    procedure SeletTodosClick(Sender: TObject);
    procedure SelectNingunoClick(Sender: TObject);
    procedure FijarCuentas(campo_remplazar, identificador: byte; valor: char; tabla: TTable);
    procedure ActivarRegistros(campo_remplazar, identificador: byte; valor: char; tabla: TTable);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    tabla: TTable;
    campo: string;
    largo: integer;
  end;

var
  fmSeleccion: TfmSeleccion;

implementation

uses SelectRegistros;

{$R *.DFM}

procedure TfmSeleccion.SelReg(Sender: TObject);
// Objetivo...: Marcar/Desmarcar un Registro
begin
  selectreg.xSelectReg(tabla, campo);
end;

procedure TfmSeleccion.DesMarcar;
// Objetivo...: Desmarcar todos los Registro
begin
  selectreg.xDesMarcar(tabla, campo);
end;

procedure TfmSeleccion.SelTodos(Sender: TObject; modo: string);
// Objetivo...: Desmarcar todos los Registro
begin
  selectreg.xSelTodos(tabla, campo, modo);
end;

//------------------------------------------------------------------------------

procedure TfmSeleccion.Salir(Sender: TObject);
begin
  Close;
end;


procedure TfmSeleccion.SelctTodos(Sender: TObject);
begin
  Close;
end;

procedure TfmSeleccion.SeleccionKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if (Shift = [ssCtrl]) and (Key = Word('T')) then SelTodos(Sender, 'X');
  if (Shift = [ssCtrl]) and (Key = Word('N')) then SelTodos(Sender, ' ');
  if (Shift = [ssCtrl]) and (Key = Word('L')) then SelReg(Sender);
end;

procedure TfmSeleccion.FormActivate(Sender: TObject);
begin
  if largo > 0 then Width := largo;
  Left  := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));

  tabla.Open;
  seleccion.Width := Width - 8;
  ///StatusBar1.Panels[0].Text := 'CTRL+L Sí/No Selección - CTRL+T Sel. Todos - CTRL+N Ninguno';
  DBNavigator.Left := Width - 250;
end;

procedure TfmSeleccion.ToolButton1Click(Sender: TObject);
// Objetivo...: Marca un Registro
begin
  SelTodos(Sender, 'X');
end;

procedure TfmSeleccion.SeletTodosClick(Sender: TObject);
// Objetivo...: Desmarca todos los Registros
begin
  SelTodos(Sender, 'X');
end;

procedure TfmSeleccion.SelectNingunoClick(Sender: TObject);
// Objetivo...: Desmarca todos
begin
  SelTodos(Sender, ' ');
end;

// -----------------------------
procedure TfmSeleccion.FijarCuentas(campo_remplazar, identificador: byte; valor: char; tabla: TTable);
// Objetivo...: Marcar algunas cuentas
begin
  // Quitamos las Marcas viejas
  tabla.Filtered := False;
  tabla.First;
  while not tabla.EOF do
    begin
      if tabla.Fields[campo_remplazar].AsString = valor then
        begin
          tabla.Edit;
          tabla.Fields[campo_remplazar].AsString := ' ';
          tabla.Post;
        end;
      tabla.Next;
    end;

  // Ponemos las Marcas Nuevas
  tabla.First;
  while not tabla.EOF do
    begin
      if tabla.Fields[identificador].AsString = 'X' then
        if tabla.Fields[campo_remplazar].AsString <> valor then
          begin
            tabla.Edit;
            tabla.Fields[campo_remplazar].AsString := valor;
            tabla.Post;
          end;
      tabla.Next;
    end;
end;

procedure TfmSeleccion.ActivarRegistros(campo_remplazar, identificador: byte; valor: char; tabla: TTable);
// Objetivo...: Poner marca de Selección a aquellos Registros que cumplan la condición
begin
  tabla.First;
  while not tabla.EOF do
    begin
      if tabla.Fields[campo_remplazar].AsString = valor then
        begin
          tabla.Edit;
          tabla.Fields[identificador].AsString := 'X';
          tabla.Post;
        end;
      tabla.Next;
    end;
    // Nos posicionamos en el 1º Registro
    tabla.First;
end;

procedure TfmSeleccion.FormCreate(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
end;

end.
