unit Margenes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Editv;

type
  TfmMargenes = class(TForm)
    GroupBox1: TGroupBox;
    superior: TEditValid;
    izquierdo: TEditValid;
    derecho: TEditValid;
    inferior: TEditValid;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMargenes: TfmMargenes;

implementation

{$R *.DFM}








procedure TfmMargenes.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfmMargenes.FormCreate(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
end;

end.
