unit CStrinGridExport;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CServers2000_Excel, Classes,
     Grids;

const
  columna: array [1..30] of String = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
                                      'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
                                      'W', 'X', 'Y', 'Z', 'AA', 'AB', 'AC', 'AD');
type

TTExportGridExcel = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ExportarAExcel(xtitulo, xfuente: String; xsubtitulo: TStringList; xgrid: TStringGrid);
 private
  { Declaraciones Privadas }
end;

function exportarGrid: TTExportGridExcel;

implementation

var
  xexportarGrid: TTExportGridExcel = nil;

constructor TTExportGridExcel.Create;
begin
end;

destructor TTExportGridExcel.Destroy;
begin
  inherited Destroy;
end;

procedure TTExportGridExcel.ExportarAExcel(xtitulo, xfuente: String; xsubtitulo: TStringList; xgrid: TStringGrid);
//Objetivo...: Exportar un StringGrid a una hoja de Excel
var
  i, j, x, cantitems, columnas, c1: integer;
  lista: TStringList;
  l1: String;
begin
  lista := TStringList.Create;

  if xsubtitulo <> Nil then Begin
    for i := 1 to xsubtitulo.Count do Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, xsubtitulo.Strings[i-1], 'Arial, normal, 10');
    end;
  end;

  if Length(Trim(xtitulo)) > 0 then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, xtitulo, 'Arial, negrita, 12');
  end;

  for i := 1 to xgrid.RowCount do Begin
    if Length(Trim(xgrid.Cells[0, i-1] + xgrid.Cells[1, i-1] + xgrid.Cells[2, i-1] + xgrid.Cells[3, i-1])) > 0 then cantitems := i;
  end;

  x := 0;
  Inc(c1); l1 := Trim(IntToStr(c1));
  For i := 1 to xgrid.ColCount do Begin
    if Length(Trim(xgrid.Cells[i-1, 0])) > 0 then Begin
      columnas := i;
      if i = 1 then excel.setString(columna[i] + l1, columna[i] + l1, xgrid.Cells[i-1, 0], xfuente) else Begin
        x := x + xgrid.ColWidths[i-2] div 8;
        lista.Add(IntToStr(x));
        excel.setString(columna[i] + l1, columna[i] + l1, xgrid.Cells[i-1, 0], xfuente);
      end;
    end;
  end;

  For i := 1 to cantitems do Begin
    x := 0;
    Inc(c1); l1 := Trim(IntToStr(c1));
    for j := 1 to columnas do Begin
      if j = 1 then excel.setString(columna[j] + l1, columna[j] + l1, xgrid.Cells[j-1, i], xfuente) else Begin
        x := StrToInt(lista.Strings[j-2]);
        excel.setString(columna[j] + l1, columna[j] + l1, xgrid.Cells[j-1, i], xfuente);
      end;
    end;
  end;

  excel.setString('d1', 'd1', '', xfuente);

  excel.Visulizar;
end;

{===============================================================================}

function exportarGrid: TTExportGridExcel;
begin
  if xexportarGrid = nil then
    xexportarGrid := TTExportGridExcel.Create;
  Result := xexportarGrid;
end;

{===============================================================================}

initialization

finalization
  xexportarGrid.Free;

end.
