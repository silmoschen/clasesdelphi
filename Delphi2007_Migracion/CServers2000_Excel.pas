unit CServers2000_Excel;

interface

uses
  SysUtils, Variants, Classes, OleServer, Excel2000, CUtiles, CUtilidadesArchivos;

const
  Format = '###.###.##0,00';
  FormatFecha = '##/##/##';

type
TExcel = class
  libro: TExcelApplication;
  Rango: Excel2000.ExcelRange;
  //Rango: Excel2000.Range;
  ws: _WorkSheet;

  constructor Create;
  destructor  Destroy; override;
  procedure   setString(xcelda1, xcelda2, xvalor: String); overload;
  procedure   setString(xcelda1, xcelda2, xvalor, xfuente: String); overload;
  procedure   setReal(xcelda1, xcelda2: String; xvalor: Real); overload;
  procedure   setReal(xcelda1, xcelda2: String; xvalor: Real; xfuente: String); overload;
  procedure   setInteger(xcelda1, xcelda2: String; xvalor: Integer); overload;
  procedure   setInteger(xcelda1, xcelda2: String; xvalor: Integer; xfuente: String); overload;
  procedure   setFormula(xcelda1, xcelda2: String; xvalor: String); overload;
  procedure   setFormula(xcelda1, xcelda2: String; xvalor: String; xfuente: String); overload;
  procedure   setFormulaArray(xcelda1, xcelda2: String; xvalor: String); overload;
  procedure   setFormulaArray(xcelda1, xcelda2: String; xvalor: String; xfuente: String); overload;
  procedure   FijarAnchoColumna(xcelda1, xcelda2: String; xancho: Real);
  procedure   Alinear(xcelda1, xcelda2: String; xalineacion: char);
  procedure   Fuente(xcelda1, xcelda2: String; fuente: String);

  function    ProcesarFormula(xcelda1, xcelda2: String; xvalor: String): String;

  procedure   Visulizar;
end;

function excel: TExcel;

implementation

var
  xexcel: TExcel = nil;

constructor TExcel.Create;
Begin
  libro := TExcelApplication.Create(Nil);
  libro.Workbooks.Add(NULL,0);
  libro.AutoQuit := True;
end;

destructor  TExcel.Destroy;
Begin
  inherited Destroy;
end;

procedure   TExcel.setString(xcelda1, xcelda2, xvalor: String);
// Objetivo...: Fijar un String en una Celda
Begin
  if libro = Nil then Create;
  libro.Range[xcelda1, xcelda2].Select;
  Rango := libro.ActiveCell;
  Rango.Value := xvalor;
end;

procedure   TExcel.setString(xcelda1, xcelda2, xvalor, xfuente: String);
// Objetivo...: Fijar un String en una Celda
Begin
  setString(xcelda1, xcelda2, xvalor);
  Fuente(xcelda1, xcelda2, xfuente);
end;

procedure   TExcel.setReal(xcelda1, xcelda2: String; xvalor: Real);
// Objetivo...: Fijar un Real en una Celda
Begin
  if libro = Nil then Create;
  libro.Range[xcelda1, xcelda2].Select;
  Rango := libro.ActiveCell;
  Rango.Value := xvalor;
  libro.Range[xcelda1, xcelda2].NumberFormat := Format;
end;

procedure   TExcel.setReal(xcelda1, xcelda2: String; xvalor: Real; xfuente: String);
// Objetivo...: Fijar un Real en una Celda
Begin
  setReal(xcelda1, xcelda2, xvalor);
  Fuente(xcelda1, xcelda2, xfuente);
end;

procedure   TExcel.setInteger(xcelda1, xcelda2: String; xvalor: Integer);
// Objetivo...: Fijar un Entero en una Celda
Begin
  if libro = Nil then Create;
  libro.Range[xcelda1, xcelda2].Select;
  Rango := libro.ActiveCell;
  Rango.Value := xvalor;
end;

procedure   TExcel.setInteger(xcelda1, xcelda2: String; xvalor: Integer; xfuente: String);
// Objetivo...: Fijar un Real en una Celda
Begin
  setInteger(xcelda1, xcelda2, xvalor);
  Fuente(xcelda1, xcelda2, xfuente);
end;

procedure   TExcel.setFormula(xcelda1, xcelda2: String; xvalor: String);
// Objetivo...: Fijar una Formula en una Celda
Begin
  if libro = Nil then Create;
  libro.Range[xcelda1, xcelda2].Select;
  Rango := libro.ActiveCell;
  Rango.Formula := xvalor;
  libro.Range[xcelda1, xcelda2].NumberFormat := Format;
end;

procedure   TExcel.setFormula(xcelda1, xcelda2: String; xvalor: String; xfuente: String);
// Objetivo...: Fijar un Real en una Celda
Begin
  setFormula(xcelda1, xcelda2, xvalor);
  Fuente(xcelda1, xcelda2, xfuente);
end;

procedure   TExcel.setFormulaArray(xcelda1, xcelda2: String; xvalor: String);
// Objetivo...: Fijar una Formula en una Celda
Begin
  if libro = Nil then Create;
  libro.Range[xcelda1, xcelda2].Select;
  Rango := libro.ActiveCell;
  Rango.FormulaArray := xvalor;
  libro.Range[xcelda1, xcelda2].NumberFormat := Format;
end;

procedure   TExcel.setFormulaArray(xcelda1, xcelda2: String; xvalor: String; xfuente: String);
// Objetivo...: Fijar un Real en una Celda
Begin
  setFormulaArray(xcelda1, xcelda2, xvalor);
  Fuente(xcelda1, xcelda2, xfuente);
  libro.Range[xcelda1, xcelda2].NumberFormat := Format;
end;

procedure   TExcel.FijarAnchoColumna(xcelda1, xcelda2: String; xancho: Real);
// Objetivo...: Definir el ancho de una columna
Begin
  if libro = Nil then Create;
  libro.Range[xcelda1, xcelda2].ColumnWidth := xancho;
end;

procedure   TExcel.Alinear(xcelda1, xcelda2: String; xalineacion: char);
// Objetivo...: Definir el ancho de una columna
Begin
  if libro = Nil then Create;
  if UpperCase(xalineacion) = 'I' then libro.Range[xcelda1, xcelda2].HorizontalAlignment := xlHAlignLeft;
  if UpperCase(xalineacion) = 'C' then libro.Range[xcelda1, xcelda2].HorizontalAlignment := xlHAlignCenter;
  if UpperCase(xalineacion) = 'D' then libro.Range[xcelda1, xcelda2].HorizontalAlignment := xlHAlignRight;
end;

procedure   TExcel.Fuente(xcelda1, xcelda2: String; fuente: String);
// Objetivo...: Definir el ancho de una columna
var
  strnueva, color, tipofuente, estilo: String;
  posicion, tamanio: Integer;
Begin
  if libro = Nil then Create;
  color := '';
  if Length(Trim(fuente)) > 0 then Begin
    {Buscamos la primer coma para obtener el Nombre de la Fuente}
    posicion  := 0;
    posicion  := Pos(',', fuente);
    tipofuente:= Copy(fuente, 1, posicion - 1);
    {Recortamos la Cadena para continuar la búsqueda del resto de los datos}
    strnueva  := Trim(Copy(fuente, posicion + 1, Length(fuente)));
    posicion  := Pos(',', strnueva);
    estilo    := Copy(strnueva, 1, posicion - 1);
    strnueva  := Copy(strnueva, posicion + 1, Length(strnueva));
    {Seteo del Color}
    posicion := Pos(',', strnueva);
    if Pos(',', strnueva) = 0 then tamanio := StrToInt(Trim(strnueva)) else Begin
      tamanio  := StrToInt(Trim(Copy(strnueva, 1, posicion - 1)));
      strnueva := Trim(Copy(strnueva, posicion + 1, Length(strnueva)));
      color    := strnueva;
    end;

    if LowerCase(estilo) = 'negrita'    then libro.Range[xcelda1, xcelda2].Font.Bold          := True;
    if LowerCase(estilo) = 'cursiva'    then libro.Range[xcelda1, xcelda2].Font.Italic        := True;
    if LowerCase(estilo) = 'subrrayado' then libro.Range[xcelda1, xcelda2].Font.Underline     := True;
    if LowerCase(estilo) = 'tachado'    then libro.Range[xcelda1, xcelda2].Font.Strikethrough := True;

    libro.Range[xcelda1, xcelda2].Font.Size := tamanio;
    libro.Range[xcelda1, xcelda2].Font.Name := tipofuente;
  end;
end;

function    TExcel.ProcesarFormula(xcelda1, xcelda2: String; xvalor: String): String;
Begin
  if libro = Nil then Create;
  libro.Range[xcelda1, xcelda2].Select;
  Rango := libro.ActiveCell;
  Rango.FormulaArray := xvalor;
  libro.Range[xcelda1, xcelda2].NumberFormat := Format;
  Result := libro.Range[xcelda1, xcelda2].Value;
  libro.Visible[0] := False;
  //if FileExists('c:\Libro2.xls') then utilesarchivos.BorrarArchivo('c:\Libro2.xls');
  //libro.ActiveWorkbook.SaveAs('c:\Libro2.xls',Null,Null,Null,false,false,xlNoChange,xlUserResolution,false,Null,Null,0);
  libro.Disconnect;
  libro := Nil; Rango := Nil;
end;

procedure   TExcel.Visulizar;
Begin
  libro.Calculate;
  libro.Visible[0] := True;
  //libro.Disconnect;
  libro := Nil; Rango := Nil;
end;

{===============================================================================}

function excel: TExcel;
begin
  if xexcel = nil then
    xexcel := TExcel.Create;
  Result := xexcel;
end;

{===============================================================================}

initialization

finalization
  xexcel.Free;

end.

