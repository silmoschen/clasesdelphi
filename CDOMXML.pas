unit CDOMXML;

interface

uses main_analizadorXML, Classes, Windows, Forms;

type

TTDOMXML = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Analizar(xdocumentoxml: String);

  function    setDOMXMLDatos: TStringList;
  function    setDOMXMLEtiquetas: TStringList;
 private
  { Declaraciones Privadas }
  list1, list2: TStringList;
end;

function domxml: TTDOMXML;

implementation

var
  xdomxml: TTDOMXML = nil;

constructor TTDOMXML.Create;
begin

end;

destructor TTDOMXML.Destroy;
begin
  inherited Destroy;
end;

procedure TTDOMXML.Analizar(xdocumentoxml: String);
var
  i: Integer;
Begin
  list1 := TStringList.Create; list2 := TStringList.Create;
  Application.CreateForm(TMainpage, Mainpage);
  Mainpage.AnalizarDocumentoXML(xdocumentoxml);
  for i := 1 to Mainpage.Memo2.Lines.Count do list1.Add(Mainpage.Memo2.Lines[i-1]);
  for i := 1 to Mainpage.Memo4.Lines.Count do list2.Add(Mainpage.Memo4.Lines[i-1]);
  Mainpage.Release; Mainpage := Nil;
end;

function TTDOMXML.setDOMXMLDatos: TStringList;
// Objetivo...: Devolver datos
Begin
  Result := list1;
end;

function TTDOMXML.setDOMXMLEtiquetas: TStringList;
// Objetivo...: Devolver Etiquetas
Begin
  Result := list2;
end;

{===============================================================================}

function domxml: TTDOMXML;
begin
  if xdomxml = nil then
    xdomxml := TTDOMXML.Create;
  Result := xdomxml;
end;

{===============================================================================}

initialization

finalization
  xdomxml.Free;

end.
