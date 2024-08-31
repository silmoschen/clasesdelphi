unit SelectDatos;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, DBCtrls, Grids, DBGrids, StdCtrls, Db, CConfigForms;

type
  TfmSelDatos = class(TForm)
    DTS: TDataSource;
    Panel1: TPanel;
    Panel2: TPanel;
    DBNavigator: TDBNavigator;
    datos: TDBGrid;
    Panel3: TPanel;
    Button1: TButton;
    procedure datosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure okClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    redim: Boolean;
    seleccionOK: Boolean;
  end;

var
  fmSelDatos: TfmSelDatos;

implementation

{$R *.DFM}

procedure TfmSelDatos.datosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) or (Key = VK_ESCAPE) then Close;
end;

procedure TfmSelDatos.okClick(Sender: TObject);
begin
  seleccionOK := True;
  DTS.DataSet := nil;
  Close;
end;


procedure TfmSelDatos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  configform.Guardar(fmSelDatos, redim);
  datos.DataSource       := nil;
  DBNavigator.DataSource := nil;
  DTS.DataSet            := nil;
end;

procedure TfmSelDatos.FormShow(Sender: TObject);
begin
  configform.Setear(fmSelDatos);
  datos.DataSource       := DTS;
  DBNavigator.DataSource := datos.DataSource;
  redim := False;
end;

procedure TfmSelDatos.Panel1Resize(Sender: TObject);
begin
  redim := True;
end;

end.
