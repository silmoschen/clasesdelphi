unit Nomina_NBU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, Buttons, DBCtrls, ExtCtrls, ComCtrls, StdCtrls, Mask;

type
  TfmListNBU = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Panel2: TPanel;
    DBNavigator: TDBNavigator;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    DBGrid: TDBGrid;
    DTS: TDataSource;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    desde: TMaskEdit;
    hasta: TMaskEdit;
    dispositivo: TComboBox;
    Panel4: TPanel;
    emitir: TBitBtn;
    cerrar: TBitBtn;
    Panel5: TPanel;
    codigo: TRadioButton;
    alfabetico: TRadioButton;
    Panel6: TPanel;
    entorno: TRadioButton;
    exclusion: TRadioButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Panel7: TPanel;
    Label1: TLabel;
    criterio: TComboBox;
    Label2: TLabel;
    expresion: TMaskEdit;
    Panel8: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure expresionChange(Sender: TObject);
    procedure criterioClick(Sender: TObject);
    procedure expresionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure DBGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure criterioChange(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure codigoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure codigoClick(Sender: TObject);
    procedure alfabeticoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure alfabeticoClick(Sender: TObject);
    procedure desdeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure hastaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dispositivoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure emitirClick(Sender: TObject);
    procedure cerrarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure desdeClick(Sender: TObject);
    procedure hastaClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
  private
    { Private declarations }
    ordenact: string; control: byte;
    redim: Boolean;
  public
    { Public declarations }
    introSalir, seleccionOK: boolean;
  end;

var
  fmListNBU: TfmListNBU;

implementation

uses CNBU, CUtiles, tablaNBU, CConfigForms;

{$R *.DFM}

procedure TfmListNBU.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  configform.Guardar(fmListNBU, redim);
  if not introSalir then Begin
    nbu.desconectar;
    Release; fmListNBU := nil;
  end;
end;

procedure TfmListNBU.expresionChange(Sender: TObject);
begin
  if criterio.Text = 'Descripción'   then nbu.BuscarPorDescrip(expresion.Text);
  if criterio.Text = 'Código'        then nbu.BuscarPorId(expresion.Text);
  if criterio.Text = 'Código N.N.N.' then nbu.BuscarPorCodigoNNN(expresion.Text);
end;

procedure TfmListNBU.criterioClick(Sender: TObject);
begin
  ActiveControl := expresion;
end;

procedure TfmListNBU.expresionKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_INSERT then SpeedButton1Click(Sender);
  if Key = VK_ESCAPE then Close;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then ActiveControl := DBGrid;
end;

procedure TfmListNBU.SpeedButton1Click(Sender: TObject);
begin
  Application.CreateForm(TfmTablaNBU, fmTablaNBU);
  fmTablaNBU.AltaClick(nil);
  fmTablaNBU.descrip.Text  := expresion.Text;
  fmTablaNBU.ActiveControl := fmTablaNBU.descrip;
  fmTablaNBU.NoCerrarFinal := True;
  fmTablaNBU.ShowModal;
end;

procedure TfmListNBU.SpeedButton2Click(Sender: TObject);
begin
  Application.CreateForm(TfmTablaNBU, fmTablaNBU);
  fmTablaNBU.NoCerrarFinal := True;
  fmTablaNBU.codigo.Text    := nbu.tabla.FieldByName('codigo').AsString;
  fmTablaNBU.ShowModal;
end;

procedure TfmListNBU.DBGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_INSERT then SpeedButton1Click(Sender);
  if Key = VK_DELETE then SpeedButton3Click(Self);
  if Key = VK_RETURN then Begin
   if introSalir then Begin
     seleccionOk := True;
     Close;
   end else
     if Not Panel3.Visible then SpeedButton2Click(Sender) else Begin
        if control = 0 then Begin    // El control es del id
          if codigo.Checked then desde.Text := nbu.tabla.FieldByName('codigo').AsString else desde.Text := nbu.tabla.FieldByName('descrip').AsString;
          ActiveControl := hasta;
        end;
        if control = 1 then Begin    // El control es de la descripción
          if codigo.Checked then hasta.Text := nbu.tabla.FieldByName('codigo').AsString else hasta.Text := nbu.tabla.FieldByName('descrip').AsString;
          ActiveControl := dispositivo;
        end;
     end;
   end;
  if Key = VK_ESCAPE then Close;
end;

procedure TfmListNBU.criterioChange(Sender: TObject);
begin
  expresion.Text := '';
  expresionChange(Sender);
end;

procedure TfmListNBU.SpeedButton4Click(Sender: TObject);
begin
  ordenact := criterio.Text;
  if Not Panel3.Visible then Begin
    Panel3.Visible  := True;
    codigo.Checked  := True; entorno.Checked := True;
    desde.Text := ''; hasta.Text := ''; expresion.Text := '';
    criterio.Text   := 'Código';
    expresionChange(Sender);
    ActiveControl   := desde;
  end;
end;

procedure TfmListNBU.codigoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then ActiveControl := desde;
end;

procedure TfmListNBU.codigoClick(Sender: TObject);
begin
  criterio.Text := 'Código';
  expresionChange(Sender);
  desde.Text := ''; hasta.Text := ''; dispositivo.Text := 'Presentación Preliminar';
end;

procedure TfmListNBU.alfabeticoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then ActiveControl := desde;
end;

procedure TfmListNBU.alfabeticoClick(Sender: TObject);
begin
  Criterio.Text := 'Nombre';
  expresionChange(Sender);
  desde.Text := ''; hasta.Text := ''; dispositivo.Text := 'Presentación Preliminar';
end;

procedure TfmListNBU.desdeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then
    if codigo.Checked then ActiveControl := codigo else ActiveControl := alfabetico;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if Length(Trim(expresion.Text)) = 0 then ActiveControl := expresion else ActiveControl := hasta;
    control := 0;
  end;
end;

procedure TfmListNBU.hastaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := desde;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if Length(Trim(expresion.Text)) = 0 then ActiveControl := expresion else ActiveControl := dispositivo;
    control := 1;
  end;
end;

procedure TfmListNBU.dispositivoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then ActiveControl := emitir;
end;

procedure TfmListNBU.emitirClick(Sender: TObject);
var
  salida, ordensalida, entornosal: char;
begin
  if (Length(Trim(desde.Text)) = 0) or (Length(Trim(hasta.Text)) = 0) then utiles.msgError('No se han definido suficientes parámetros ...!') else Begin
    StatusBar1.Panels[0].Text := 'Generando Informe ...!'; StatusBar1.Refresh;
    //DTS.DataSet := nil;
    salida := 'P'; ordensalida := 'C'; entornosal := 'E';
    if dispositivo.Text = 'Impresora' then salida := 'I';
    if alfabetico.Checked then ordensalida := 'A';
    if exclusion.Checked then entornosal := 'X';
    nbu.Listar(ordensalida, desde.Text, hasta.Text, entornosal, salida);
    DTS.DataSet   := nbu.tabla;
    StatusBar1.Panels[0].Text := '';
  end;
  ActiveControl := cerrar;
end;

procedure TfmListNBU.cerrarClick(Sender: TObject);
begin
  Panel3.Visible := False;
  criterio.Text  := ordenact;
  expresionChange(Sender);
  ActiveControl  := expresion;
end;

procedure TfmListNBU.FormShow(Sender: TObject);
begin
  if not configform.Setear(fmListNBU) then Begin
    Height := 380; Width := 596; Top := 25; Left:=(Screen.Width - Width) div 2;
  End;
  DTS.DataSet := nbu.tabla;
  if not introSalir then nbu.conectar;
  redim := False;
  expresion.SetFocus;
end;

procedure TfmListNBU.desdeClick(Sender: TObject);
begin
  control := 0;
end;

procedure TfmListNBU.hastaClick(Sender: TObject);
begin
  control := 1;
end;

procedure TfmListNBU.SpeedButton3Click(Sender: TObject);
begin
  Application.CreateForm(TfmTablaNBU, fmTablaNBU);
  fmTablaNBU.codigo.Text := nbu.tabla.FieldByName('codigo').AsString;
  fmTablaNBU.BajaClick(Sender);
  ActiveControl := DBGrid;
end;

procedure TfmListNBU.SpeedButton5Click(Sender: TObject);
begin
  if utiles.msgSiNo('Seguro para Sincornizar Códigos con Nomenclador Nacional Normalizado ?') then nbu.Sincronizar;
  expresion.SetFocus;
end;

procedure TfmListNBU.Panel2Resize(Sender: TObject);
begin
  redim := True;
end;

end.
