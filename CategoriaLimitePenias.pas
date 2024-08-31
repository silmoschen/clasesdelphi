unit CategoriaLimitePenias;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Grids, DBGrids, Editv;

type
  TfmLimitesPenias = class(TForm)
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    idcategoria: TMaskEdit;
    StatusBar1: TStatusBar;
    categoria: TMaskEdit;
    DTS: TDataSource;
    Label3: TLabel;
    Panel1: TPanel;
    ToolBar1: TToolBar;
    DBNavigator: TDBNavigator;
    Alta: TToolButton;
    Baja: TToolButton;
    Modificar: TToolButton;
    Buscar: TToolButton;
    Deshacer: TToolButton;
    Salir: TToolButton;
    Label2: TLabel;
    limite: TEditValid;

    procedure idcategoriaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure categoriaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AltaClick(Sender: TObject);
    procedure BajaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure DeshacerClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
    procedure FormShow(Sender: TObject);
    procedure limiteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure CargarDatos;
  public
    { Public declarations }
  end;

var
  fmLimitesPenias: TfmLimitesPenias;

implementation

uses CLimitesCreditos_Penias, CUtiles, ImgForms;

{$R *.DFM}

procedure TfmLimitesPenias.CargarDatos;
begin
  limitepenia.getDatos(idcategoria.Text);
  categoria.Text := limitepenia.Descrip;
  limite.Text    := utiles.FormatearNumero(FloatToStr(limitepenia.Limite));
end;

procedure TfmLimitesPenias.idcategoriaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin                              {Edita y Da de Alta Registro ...}
    utiles.LlenarIzquierda(idcategoria, 3, '0');
    if limitepenia.Buscar(idcategoria.Text) then begin
      CargarDatos;
      StatusBar1.Panels[0].Text := '';
      ActiveControl := categoria;
    end else
      if utiles.DarDeAlta('Cód. Categoría ' + idcategoria.Text) then begin
        CargarDatos;
        StatusBar1.Panels[0].Text := '';
        ActiveControl := categoria;
      end;
    end;
end;

procedure TfmLimitesPenias.categoriaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := idcategoria;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(categoria.Text)) > 0 then limite.SetFocus;
end;

procedure TfmLimitesPenias.AltaClick(Sender: TObject);
begin
  idcategoria.Text := utiles.sLlenarIzquierda(limitepenia.Nuevo, 3, '0');
  ActiveControl := idcategoria;
end;

procedure TfmLimitesPenias.BajaClick(Sender: TObject);
begin
  if utiles.BajaRegistro('Seguro para Eliminar Categoría ' + idcategoria.Text + ' ?') then begin
    limitepenia.Borrar(idcategoria.Text);
    idcategoria.Text := limitepenia.idcategoria;
    CargarDatos;
  end;
  ActiveControl := idcategoria;
end;

procedure TfmLimitesPenias.ModificarClick(Sender: TObject);
begin
  ActiveControl := idcategoria;
end;

procedure TfmLimitesPenias.DeshacerClick(Sender: TObject);
begin
  ActiveControl := idcategoria;
end;

procedure TfmLimitesPenias.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmLimitesPenias.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (Length(Trim(idcategoria.Text)) > 0) and (Length(Trim(categoria.Text)) > 0) and (StrToFloat(limite.Text) > 0) then Begin
    limitepenia.Registrar(idcategoria.Text, categoria.Text, StrToFloat(limite.Text));
    limitepenia.BuscarPorDescrip(categoria.Text);
  end;  
  DBNavigator.Free;
end;

procedure TfmLimitesPenias.DBNavigatorClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  idcategoria.Text := limitepenia.tabla.FieldByName('idcategoria').AsString;
  CargarDatos;
end;

procedure TfmLimitesPenias.FormShow(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
  DTS.DataSet := limitepenia.tabla;
  if Length(Trim(idcategoria.Text)) > 0 then Begin
    CargarDatos;
    ActiveControl := categoria;
  end;
end;

procedure TfmLimitesPenias.limiteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := categoria;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(limite.Text)) > 0 then Begin
      limite.Text := utiles.FormatearNumero(limite.Text);
      Close;
    end;
end;

end.
