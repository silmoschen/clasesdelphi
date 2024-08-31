unit TJPEG;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, jpeg, Graphics;

type

TTJPG = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ConvertirBMP_JPG(xarchivo_bmp, xarchivo_jpg: String);

 private
  { Declaraciones Privadas }
end;

function imgjpg: TTJPG;

implementation

var
  ximgjpg: TTJPG = nil;

constructor TTJPG.Create;
begin
  inherited Create;
end;

destructor TTJPG.Destroy;
begin
  inherited Destroy;
end;

procedure  TTJPG.ConvertirBMP_JPG(xarchivo_bmp, xarchivo_jpg: String);
// Objetivo...: Convertir una Imagen BMP en JPG
var
  MyJPEG: TJPEGImage;
  MyBMP: TBitmap;
begin
  MyBMP := TBitmap.Create;
  with MyBMP do
    try
      {Cargamos el BMP}
      LoadFromFile(xarchivo_bmp);
      MyJPEG := TJPEGImage.Create;
      with MyJPEG do begin
        Assign(MyBMP);
        {Grabamos el JPG}
        SaveToFile(xarchivo_jpg);
        Free;
      end;
      finally
      Free;
    end;
end;

{===============================================================================}

function imgjpg: TTJPG;
begin
  if ximgjpg = nil then
    ximgjpg := TTJPG.Create;
  Result := ximgjpg;
end;

{===============================================================================}

initialization

finalization
  ximgjpg.Free;

end.
