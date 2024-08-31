unit acerca_de;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfmAcercaDe = class(TForm)
    Timer1: TTimer;
    Button1: TButton;
    Imagen: TImage;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    no_cerrar: boolean;
    { Public declarations }
  end;

var
  fmAcercaDe: TfmAcercaDe;

implementation

{$R *.DFM}

procedure TfmAcercaDe.Timer1Timer(Sender: TObject);
begin
  if not no_cerrar then Close;
end;

procedure TfmAcercaDe.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfmAcercaDe.FormActivate(Sender: TObject);
begin
  if no_cerrar then
    begin
      BorderStyle := bsDialog;
      Button1.Visible := True;
    end;
end;

procedure TfmAcercaDe.FormCreate(Sender: TObject);
begin
  {MD.VIASSIST.Open;
  Imagen.Picture.LoadFromFile(MD.viassistVia.Value + '\pq011999\logo1.bmp');
  MD.VIASSIST.Close;}
end;

end.
