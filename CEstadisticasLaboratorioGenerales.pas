unit CEstadisticasLaboratorioGenerales;

interface

uses CEstInfoLab, CSolAnalisisFabrissin, SysUtils, DB, DBTables, CVias, CUtiles,
     CListar, CBDT, CIDBFM, Classes, CNomecla, CSolAnalisisFabrissinInternacion;

type

TTEstadisticaLaboratorioGen= class(TTInformesEstadisticos)
   tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListEstAnalisisEfectuados(salida: char);
  function    setIncluirDeterminaciones: TStringList;
  procedure   RegistrarCodigo(xcodigo, xestado: String);
 private
  { Declaraciones Privadas }
  l: TStringList;
  practicas: array[1..1000, 1..2] of String;
  procedure IniciarArray;
  procedure RegistrarArray(xcodigo, xcantidad: String);
end;

function estadisticagen: TTEstadisticaLaboratorioGen;

implementation

var
  xestadisticagen: TTEstadisticaLaboratorioGen= nil;

constructor TTEstadisticaLaboratorioGen.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('incluir_det', '');
end;

destructor TTEstadisticaLaboratorioGen.Destroy;
begin
  inherited Destroy;
end;

procedure TTEstadisticaLaboratorioGen.ListEstAnalisisEfectuados(salida: char);
// Objetivo...: Estadística de análisis efectuados
var
  i: Integer;
  l: TStringList;
begin
  verifListado(salida);
  List.Linea(0, 0, 'Análisis Efectuados', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');

  IniciarArray;
  Q := solanalisis.setEstadisticaSolicitudes(fecha1, fecha2);
  Q.Open; Q.First; total := 0; idanter := '';
  while not Q.EOF do
    begin
      if Q.FieldByName('codanalisis').AsString <> idanter then Begin
          if Length(Trim(idanter)) > 0 then Begin
            RegistrarArray(idanter, FloatToStr(total));
            total := 0;
          end;
      end;
      total := total + 1;

      idanter := Q.FieldByName('codanalisis').AsString;
      Q.Next;
    end;

  RegistrarArray(idanter, FloatToStr(total));

  Q.Close;

  Q := solanalisisint.setEstadisticaSolicitudes(fecha1, fecha2);
  Q.Open; Q.First; total := 0; idanter := '';
  while not Q.EOF do
    begin
      if Q.FieldByName('codanalisis').AsString <> idanter then Begin
          if Length(Trim(idanter)) > 0 then Begin
            RegistrarArray(idanter, FloatToStr(total));
            total := 0;
          end;
      end;
      total := total + 1;

      idanter := Q.FieldByName('codanalisis').AsString;
      Q.Next;
    end;

  RegistrarArray(idanter, FloatToStr(total));

  Q.Close;

  l := setIncluirDeterminaciones;

  nomeclatura.conectar;
  For i := 1 to 1000 do Begin
    if Length(Trim(practicas[i, 1])) = 0 then Break;
    if utiles.verificarItemsLista(l, practicas[i, 1]) then Begin
      nomeclatura.getDatos(practicas[i, 1]);
      list.Linea(0, 0, practicas[i, 1], 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(8, list.Lineactual, nomeclatura.descrip, 2, 'Arial, normal, 9', salida, 'N');
      list.importe(70, list.Lineactual, '#####', StrToFloat(practicas[i, 2]), 3, 'Arial, normal, 9');
      list.Linea(90, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
    end;
  end;
  nomeclatura.desconectar;

  list.FinList;
end;

function  TTEstadisticaLaboratorioGen.setIncluirDeterminaciones: TStringList;
// Objetivo...: Excluir Determinaciones
Begin
  l := TStringList.Create;
  tabla.Open;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('codigo').AsString);
    tabla.Next;
  end;
  tabla.Close;

  Result := l;
end;

procedure TTEstadisticaLaboratorioGen.RegistrarCodigo(xcodigo, xestado: String);
// Objetivo...: Registrar Determinacion
Begin
  tabla.Open;
  if xestado = 'S' then Begin
    if tabla.FindKey([xcodigo]) then tabla.Edit else tabla.Append;
    tabla.FieldByName('codigo').AsString := xcodigo;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end else
    if tabla.FindKey([xcodigo]) then tabla.Delete;
  tabla.Close;
end;

procedure TTEstadisticaLaboratorioGen.IniciarArray;
var
  i: Integer;
Begin
  For i := 1 to 1000 do Begin
    practicas[i, 1] := '';
    practicas[i, 2] := '0';
  end;
end;

procedure TTEstadisticaLaboratorioGen.RegistrarArray(xcodigo, xcantidad: String);
var
  i: Integer;
Begin
  For i := 1 to 1000 do Begin
    if practicas[i, 1] = xcodigo then Begin
      practicas[i, 2] := IntToStr( (StrToInt(practicas[i, 2]) + StrToInt(xcantidad)));
      Break;
    end;
    if Length(Trim(practicas[i, 1])) = 0 then Begin
      practicas[i, 1] := xcodigo;
      practicas[i, 2] := xcantidad;
      Break;
    end;
  end;
end;
 
{===============================================================================}

function estadisticagen: TTEstadisticaLaboratorioGen;
begin
  if xestadisticagen = nil then
    xestadisticagen := TTEstadisticaLaboratorioGen.Create;
  Result := xestadisticagen;
end;

{===============================================================================}

initialization

finalization
  xestadisticagen.Free;

end.
