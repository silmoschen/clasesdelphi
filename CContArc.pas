unit CContArc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl;

type
  TfmContArchivos = class(TForm)
    FileListBox1: TFileListBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmContArchivos: TfmContArchivos;

implementation

{$R *.DFM}

end.
