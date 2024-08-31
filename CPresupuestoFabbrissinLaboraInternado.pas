unit CPresupuestoFabbrissinLaboraInternado;

interface

uses CPaciente, CProfesional, CNomeclaCCB, {CPlantAnalisis_Int,} CObrasSocialesCCBInt, CTitulos,
     CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CSolAnalisis, CCBloqueos;

const
  meses: array[1..12] of string = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre');

type

TTpresupuestoAnalisisRapido = class(TObject)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  { Presupuesto Rápido }
  procedure   RegistrarItemsPresupuestoRapido(xitems, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer); overload;
  procedure   RegistrarItemsPresupuestoRapido(xitems, xcantidad, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer); overload;
  procedure   ImprimirPresupuestoRapido(salida: char);

 protected
  { Declaraciones Privadas }
 private
  { Declaraciones Privadas }
  archivo: array[1..90, 1..6] of String;
  totales: array[1..5] of String;
  lin, Caracter: String;
  totitems: integer;
end;

function presupuesto: TTpresupuestoAnalisisRapido;

implementation

var
  xsolanalisis: TTpresupuestoAnalisisRapido = nil;

constructor TTpresupuestoAnalisisRapido.Create;
begin
  Caracter := '-';
end;

destructor TTpresupuestoAnalisisRapido.Destroy;
begin
  inherited Destroy;
end;

procedure   TTpresupuestoAnalisisRapido.RegistrarItemsPresupuestoRapido(xitems, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer);
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

procedure   TTpresupuestoAnalisisRapido.RegistrarItemsPresupuestoRapido(xitems, xcantidad, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer);
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

procedure   TTpresupuestoAnalisisRapido.ImprimirPresupuestoRapido(salida: char);
// Objetivo...: Imprimir Presupuesto rápido
var
  i: Integer;
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.NoImprimirPieDePagina;
    list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Presupuesto al:  ' + utiles.setFechaActual, 1, 'Arial, negrita, 11');
    list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
    list.Titulo(0, 0, 'It.  Código    Determinación', 1, 'Arial, cursiva, 8');
    list.Titulo(52, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 7');
    list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    list.LineaTxt(CHR(18) + 'Presupuesto al:  ' + utiles.setFechaActual, True);
    list.LineaTxt('', True);
    list.LineaTxt('It. Cant.  Código  Determinación                        Monto', True);
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  end;

  For i := 1 to totitems do Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, archivo[i, 1] + '  ' + archivo[i, 2] + ' - ' + archivo[i, 3], 1, 'Arial, normal, 8', salida, 'N');
      list.importe(56, list.Lineactual, '', StrToFloat(archivo[i, 4]), 2, 'Arial, normal, 8');
      list.Linea(60, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(archivo[i, 1] + '    ' + utiles.sLlenarIzquierda(archivo[i, 6], 3, ' ') + '  ' + archivo[i, 2] + ' -  ' +  Copy(archivo[i, 3], 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(archivo[i, 3], 1, 30))))), False);
      list.importeTxt(StrToFloat(archivo[i, 4]), 10, 2, True);
    end;
  end;

  if (salida = 'P') or (salida = 'I') then Begin
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

  if salida = 'T' then Begin
    list.LineaTxt('', True);
    list.LineaTxt('Subtotal     : ', False);
    list.ImporteTxt(StrToFloat(totales[1]), 12, 2, False);
    list.LineaTxt('   Rec. y Toma  : ', False);
    list.ImporteTxt(StrToFloat(totales[2]), 12, 2, True);
    list.LineaTxt('I.V.A.       : ', False);
    list.ImporteTxt(StrToFloat(totales[4]), 12, 2, False);
    list.LineaTxt('   Subtotal     : ', False);
    list.ImporteTxt(StrToFloat(totales[3]), 12, 2, True);
    list.LineaTxt('Total        : ', False);
    list.ImporteTxt(StrToFloat(totales[4]) + StrToFloat(totales[3]), 12, 2, True);

    list.FinalizarImpresionModoTexto(1);
  end;
end;

{===============================================================================}

function presupuesto: TTpresupuestoAnalisisRapido;
begin
  if xsolanalisis = nil then
    xsolanalisis := TTpresupuestoAnalisisRapido.Create;
  Result := xsolanalisis;
end;

{===============================================================================}

initialization

finalization
  xsolanalisis.Free;

end.
