unit CLPsimpl_Gross;

interface

uses CArticulosGross, CLPsimpl, SysUtils, DB, DBTables, CIDBFM, Classes, CListar, CUtiles;

type

TTLPreciosSimples_Gross = class(TTLPreciosSimples)            // Superclase
  constructor Create(xcodart, xdescrip: string; xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: real);
  destructor  Destroy; override;

  procedure   ListarPrecios(xlista: TStringList; salida, orden: char);
 private
  { Declaraciones Privadas }
  procedure List_linea(salida: char); override;
  procedure Titulos(salida: char; lp, tit: string); override;
end;

function presimples: TTLPreciosSimples_Gross;

implementation

var
  xprecios: TTLPreciosSimples_Gross = nil;

constructor TTLPreciosSimples_Gross.Create(xcodart, xdescrip: string; xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: real);
begin
  inherited Create(xcodart, xdescrip, xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7);
end;

destructor TTLPreciosSimples_Gross.Destroy;
begin
  inherited Destroy;
end;

procedure TTLPreciosSimples_Gross.ListarPrecios(xlista: TStringList; salida, orden: char);
Begin
  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(7, list.Lineactual, 'Lista de Precios', 2, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 8');
  list.Titulo(0, 0, '', 1, 'Arial, cursiva, 12');
  list.Titulo(7, list.Lineactual, 'Código', 2, 'Arial, cursiva, 12');
  list.Titulo(26, list.Lineactual, 'Descripción', 3, 'Arial, cursiva, 12');
  list.Titulo(83, list.Lineactual, 'Precio', 4, 'Arial, cursiva, 12');
  list.Titulo(92, list.Lineactual, '% H.', 5, 'Arial, cursiva, 12');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 12');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 8');

  if orden = 'A' then tabla.IndexFieldNames := 'descrip' else tabla.IndexFieldNames := 'codart';
  tabla.First;
  while not tabla.Eof do Begin
    if utiles.verificarItemsLista(xlista, tabla.FieldByName('codart').AsString) then Begin
      art.getDatos(tabla.FieldByName('codart').AsString);
      list.Linea(0, 0, '   ', 1, 'Arial, normal, 12', salida, 'N');
      list.Linea(7, list.Lineactual, tabla.FieldByName('codart').AsString, 2, 'Arial, normal, 12', salida, 'N');
      list.Linea(26, list.Lineactual, tabla.FieldByName('descrip').AsString, 3, 'Arial, normal, 12', salida, 'N');
      list.importe(90, list.Lineactual, '', tabla.FieldByName('precio1').AsFloat, 4, 'Arial, normal, 12');
      list.importe(96, list.Lineactual, '##', art.Descuento, 5, 'Arial, normal, 12');
      list.Linea(96, list.Lineactual, '', 6, 'Arial, normal, 12', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;
    tabla.Next;
  end;
  tabla.IndexFieldNames := 'codart';

  list.FinList;
end;

procedure TTLPreciosSimples_Gross.List_linea(salida: char);
// Objetivo...: Listar una linea de articulos
begin
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.importe(8, List.lineactual, '#############', r.FieldByName('codart').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(9, list.Lineactual, Copy(r.FieldByName('articulo').AsString, 1, 30), 3, 'Arial, normal, 8', salida, 'N');
  art.getDatos(r.FieldByName('codart').AsString);
  List.importe(43, List.lineactual, '', art.stock, 4, 'Arial, normal, 8');
  List.importe(50, List.lineactual, '', r.FieldByName('precio2').AsFloat, 5, 'Arial, normal, 8');
  List.importe(58, List.lineactual, '', r.FieldByName('precio1').AsFloat, 6, 'Arial, normal, 8');
  List.importe(66, List.lineactual, '', r.FieldByName('precio3').AsFloat, 7, 'Arial, normal, 8');
  List.importe(74, List.lineactual, '', r.FieldByName('precio4').AsFloat, 8, 'Arial, normal, 8');
  List.importe(83, List.lineactual, '', r.FieldByName('precio5').AsFloat, 9, 'Arial, normal, 8');
  List.importe(91, List.lineactual, '', r.FieldByName('precio6').AsFloat, 10, 'Arial, normal, 8');
  List.importe(99, List.lineactual, '', r.FieldByName('precio7').AsFloat, 11, 'Arial, normal, 8');
  List.Linea(99,   List.lineactual, '', 12, 'Arial, normal, 8', salida, 'S');
end;

procedure TTLPreciosSimples_Gross.Titulos(salida: char; lp, tit: string);
// Objetivo...: Listar Línea de Datos
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, tit, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código', 1, 'Arial, cursiva, 8');
  List.Titulo(18, List.lineactual, 'Descripción', 2, 'Arial, cursiva, 8');
  List.Titulo(39, List.lineactual, 'Stock', 3, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, LPrecio2, 4, 'Arial, cursiva, 8');
  List.Titulo(53, List.lineactual, LPrecio1, 5, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, LPrecio3, 6, 'Arial, cursiva, 8');
  List.Titulo(69, List.lineactual, LPrecio4, 7, 'Arial, cursiva, 8');
  List.Titulo(77, List.lineactual, LPrecio5, 8, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, LPrecio6, 9, 'Arial, cursiva, 8');
  List.Titulo(94, List.lineactual, LPrecio7, 10, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

{===============================================================================}

function presimples: TTLPreciosSimples_Gross;
begin
  if xprecios = nil then
    xprecios := TTLPreciosSimples_Gross.Create('', '', 0, 0, 0, 0, 0, 0, 0);
  Result := xprecios;
end;

{===============================================================================}

initialization

finalization
  xprecios.Free;

end.
