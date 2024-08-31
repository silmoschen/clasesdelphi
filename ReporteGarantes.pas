unit ReporteGarantes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ToolWin, DBTables, DB, CGarante;

type
  TfmListadoGarantes = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar2: TToolBar;
    Ayuda: TBitBtn;
    Orden: TBitBtn;
    Filtro: TBitBtn;
    DispositivoSalida: TBitBtn;
    Emitir: TBitBtn;
    Salir: TBitBtn;
    procedure SalirClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OrdenClick(Sender: TObject);
    procedure FiltroClick(Sender: TObject);
    procedure DispositivoSalidaClick(Sender: TObject);
    procedure EmitirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    clase: TTGarante;
  public
    { Public declarations }
  end;

var
  fmListadoGarantes: TfmListadoGarantes;

implementation

uses CVias, OrdenDeSalida, FiltroPorNombre, Disposit, FiltroPorCodigo;

{$R *.DFM}

procedure TfmListadoGarantes.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmListadoGarantes.FormActivate(Sender: TObject);
var
  v: string;
begin
  clase := cliengar;

  Application.CreateForm(TOrdenDeDatos, OrdenDeDatos);
  Application.CreateForm(TfmFiltroCodigo, fmFiltroCodigo);
  Application.CreateForm(TfmFiltroNombre, fmFiltroNombre);
  Application.CreateForm(TDispositivo, Dispositivo);

  {----------------------------------------------------------------------------}
  v := via.getVia1;
  orden.Glyph.LoadFromFile(v + '\pq011999\orden.bmp');
  filtro.Glyph.LoadFromFile(v + '\pq011999\filtro.bmp');
  dispositivosalida.Glyph.LoadFromFile(v + '\pq011999\dispositivo.bmp');
  emitir.Glyph.LoadFromFile(v + '\pq011999\emitir.bmp');
  salir.Glyph.LoadFromFile(v + '\pq011999\salir.bmp');

  fmFiltroCodigo.Campo          := clase.tperso.IndexFieldNames;
  fmFiltroCodigo.Idx1           := clase.tperso.IndexFieldNames;
  fmFiltroCodigo.TBDatos        := clase.tperso;
  fmFiltroNombre.NCampo         := clase.tperso.IndexDefs.Items[1].Name;
  fmFiltroNombre.SelCampoExacto := True;
  fmFiltroNombre.NIdx1          := clase.tperso.IndexDefs.Items[1].Name;
  fmFiltroNombre.NTBDatos       := clase.tperso;
  fmFiltroNombre.OrdenAlf       := clase.tperso.IndexDefs.Items[1].Name;
  {----------------------------------------------------------------------------}
end;

procedure TfmListadoGarantes.OrdenClick(Sender: TObject);
begin
  OrdenDeDatos.ShowModal;
  ActiveControl := Filtro;
end;

procedure TfmListadoGarantes.FiltroClick(Sender: TObject);
begin
  if OrdenDeDatos.CheckBox1.Checked then         {Listado Ordenado por Código}
    fmFiltroCodigo.ShowModal;
  if OrdenDeDatos.CheckBox2.Checked then         {Listado Ordenado Alfabéticamente}
    fmFiltroNombre.ShowModal;
  ActiveControl := DispositivoSalida;
end;

procedure TfmListadoGarantes.DispositivoSalidaClick(Sender: TObject);
begin
  Dispositivo.ShowModal;
  ActiveControl := Emitir;
end;

procedure TfmListadoGarantes.EmitirClick(Sender: TObject);
var
  salida : char; l: boolean;
begin
  l := False;
  if Dispositivo.Impresor.Checked then salida := 'I' else salida := 'P';
  if OrdenDeDatos.ordenDatos = 'C' then
    begin
      clase.Listar(OrdenDeDatos.ordenDatos, fmFiltroCodigo.Desde.Text, fmFiltroCodigo.Hasta.Text, fmFiltroCodigo.modoListado, salida);
      l := True;
    end;
  if OrdenDeDatos.ordenDatos = 'A' then
    begin
      clase.Listar(OrdenDeDatos.ordenDatos, fmFiltroNombre.Desde.Text, fmFiltroNombre.Hasta.Text, fmFiltroNombre.modoListado, salida);
      l := True;
    end;

  if not l then if (OrdenDeDatos.ordenDatos <> 'C') or (OrdenDeDatos.ordenDatos <> 'A') then clase.Listar('C', '000000', '999999', 'E', salida);  // Por defecto, si no se seleccionaron Parámetros de Impresión

  ActiveControl := Salir;
end;

procedure TfmListadoGarantes.FormCreate(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
end;

procedure TfmListadoGarantes.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  OrdenDeDatos.Free;
  fmFiltroCodigo.Free;
  fmFiltroNombre.Free;
  Dispositivo.Free;
end;

end.
