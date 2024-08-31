unit CPresupuestoRapidoFabbrissin;

interface

uses CPaciente, CProfesional, CNomecla, CPlantanalisis, CObrasSociales, CTitulos,
     CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CSolAnalisis, CCBloqueos;

const
  meses: array[1..12] of string = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre');

type

TTpresupuestoAnalisis = class(TObject)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   RegistrarItemsPresupuestoRapido(xitems, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer); overload;
  procedure   RegistrarItemsPresupuestoRapido(xitems, xcantidad, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer); overload;
  procedure   ImprimirPresupuestoRapido(salida: char);

 protected
  { Declaraciones Privadas }
 private
  { Declaraciones Privadas }
  controlSQL, s_inicio: boolean;
  archivo: array[1..90, 1..6] of String;
  totales: array[1..5] of String;
  conexiones, totitems: integer;
end;

function presupuesto: TTpresupuestoAnalisis;

implementation

var
  xsolanalisis: TTpresupuestoAnalisis = nil;

constructor TTpresupuestoAnalisis.Create;
begin
  inherited Create;
end;

destructor TTpresupuestoAnalisis.Destroy;
begin
  inherited Destroy;
end;

procedure   TTpresupuestoAnalisis.RegistrarItemsPresupuestoRapido(xitems, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer);
// Objetivo...: registrar Items Presupuesto rápido
Begin
  archivo[StrToInt(xitems), 1] := xitems;
  archivo[StrToInt(xitems), 2] := xcodanalisis;
  archivo[StrToInt(xitems), 3] := xdescrip;
  archivo[StrToInt(xitems), 4] := xprecio;
  archivo[StrToInt(xitems), 5] := xcftoma;
  totitems   := xcantidaditems;
  totales[1] := xpreciototal;
  totales[2] := xcftoma;
  totales[3] := xtotal;
  totales[4] := xiva;
end;

procedure   TTpresupuestoAnalisis.RegistrarItemsPresupuestoRapido(xitems, xcantidad, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer);
// Objetivo...: registrar Items Presupuesto rápido
Begin
  archivo[StrToInt(xitems), 1] := xitems;
  archivo[StrToInt(xitems), 2] := xcodanalisis;
  archivo[StrToInt(xitems), 3] := xdescrip;
  archivo[StrToInt(xitems), 4] := xprecio;
  archivo[StrToInt(xitems), 5] := xcftoma;
  archivo[StrToInt(xitems), 6] := xcantidad;
  totitems   := xcantidaditems;
  totales[1] := xpreciototal;
  totales[2] := xcftoma;
  totales[3] := xtotal;
  totales[4] := xiva;
end;

procedure   TTpresupuestoAnalisis.ImprimirPresupuestoRapido(salida: char);
// Objetivo...: Imprimir Presupuesto rápido
var
  i: Integer;
Begin
  list.NoImprimirPieDePagina;
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Presupuesto al:  ' + utiles.setFechaActual, 1, 'Arial, negrita, 11');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'It.  Código    Determinación', 1, 'Arial, cursiva, 8');
  list.Titulo(52, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 7');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');

  For i := 1 to totitems do Begin
    list.Linea(0, 0, archivo[i, 1] + '  ' + archivo[i, 2] + ' - ' + archivo[i, 3], 1, 'Arial, normal, 8', salida, 'N');
    list.importe(56, list.Lineactual, '', StrToFloat(archivo[i, 4]), 2, 'Arial, normal, 8');
    list.Linea(60, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  end;
  //falta subtotal ...
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
  list.Importe(25, list.Lineactual, '', StrToFloat(totales[1]), 2, 'Arial, negrita, 8');
  list.Linea(30, list.Lineactual, 'Rec. y Toma:', 3, 'Arial, negrita, 9', salida, 'N');
  list.Importe(56, list.Lineactual, '', StrToFloat(totales[2]), 4, 'Arial, negrita, 8');
  list.Linea(57, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');

  list.Linea(0, 0, 'I.V.A.:', 1, 'Arial, negrita, 8', salida, 'N');
  list.Importe(25, list.Lineactual, '', StrToFloat(totales[4]), 2, 'Arial, negrita, 8');
  list.Linea(30, list.Lineactual, 'Subtotal:', 3, 'Arial, negrita, 8', salida, 'N');
  list.Importe(56, list.Lineactual, '', StrToFloat(totales[3]), 4, 'Arial, negrita, 8');
  list.Linea(56, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 8', salida, 'N');
  list.Importe(25, list.Lineactual, '', StrToFloat(totales[4]) + StrToFloat(totales[3]), 2, 'Arial, negrita, 8');
  list.Linea(56, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;

{===============================================================================}

function presupuesto: TTpresupuestoAnalisis;
begin
  if xsolanalisis = nil then
    xsolanalisis := TTpresupuestoAnalisis.Create;
  Result := xsolanalisis;
end;

{===============================================================================}

initialization

finalization
  xsolanalisis.Free;

end.
