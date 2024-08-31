unit CLMayorAsociacion;

interface

uses CRegContAsociacion, CPlanctasAsociacion, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CPeriodoAsociacion;

type

TTLMayor = class(TTRegCont)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListMayor(df, hf, dc, hc: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  datok: boolean;
  procedure SubtotalCuenta(salida: char);
  procedure CorteCuenta(salida: char);
  procedure titulos;
 protected
  { Declaraciones Protegidas }
end;

function lmayor: TTLMayor;

implementation

var
  xlmayor: TTLMayor = nil;

constructor TTLMayor.Create;
begin
  inherited Create;
end;

destructor TTLMayor.Destroy;
begin
  inherited Destroy;
end;

procedure TTLMayor.titulos;
// Objetivo...: Listar titulos para la impresion en modo texto
Begin
  Inc(pag);
  ListarDatosEmpresa('T');
  list.LineaTxt('Libro Mayor                                               Hoja: ' + IntToStr(Pag), True);
  list.LineaTxt('', True);
  list.LineaTxt(CHR15 + ' Fecha    Concepto                                   Nro.As.        Debe       Haber Sal.Deudor Sal.Acreedor',  True);
  list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('', True);
  lineas := lineas + 5;
end;

procedure TTLMayor.CorteCuenta(salida: char);
{Objetivo...: Nivel de ruptura por cuenta}
begin
  if datok then SubtotalCuenta(salida);
  planctas.getDatos(asientos.FieldByName('codcta').AsString);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, 'Cuenta:    ' + asientos.FieldByName('codcta').AsString + '  ' + TrimLeft(planctas.Cuenta), 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(62, list.lineactual, 'Saldo Anterior:  ', 2, 'Arial, negrita, 8', salida, 'N');
    if saldoanter > 0 then list.importe(80, list.lineactual, '', saldoanter, 3, 'Arial, negrita, 8') else list.importe(93, list.lineactual, '', saldoanter * (-1), 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(CHR15 + 'Cuenta:    ' + asientos.FieldByName('codcta').AsString + '  ' + utiles.StringLongitudFija(TrimLeft(planctas.Cuenta), 45) + '           Saldo Anterior:', False);
    if saldoanter >= 0 then list.ImporteTxt(saldoanter, 12, 2, True) else list.importetxt(saldoanter * (-1), 12, 2, True);
    Inc(lineas); if ControlarSalto then RealizarSalto;
    list.LineaTxt('', True);
    Inc(lineas); if ControlarSalto then titulos;
  end;
  datok := True;
end;

procedure TTLMayor.SubtotalCuenta;
{Objetivo...: Subtotal de Cuenta}
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(55, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
    list.derecha(67, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
    list.derecha(80, list.lineactual, '', '--------------', 4, 'Arial, normal, 8');
    list.derecha(93, list.lineactual, '', '--------------', 5, 'Arial, normal, 8');
    list.Linea(95, list.lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Saldo Actual: ', 1, 'Arial, negrita, 8', salida, 'N');
    if totdebe <> 0  then list.importe(55, list.lineactual, '', totdebe, 2, 'Arial, negrita, 8');
    if tothaber <> 0 then list.importe(67, list.lineactual, '', tothaber, 3, 'Arial, negrita, 8');
    if saldofinal > 0 then list.importe(80, list.lineactual, '', saldofinal, 4, 'Arial, negrita, 8') else list.importe(93, list.lineactual, '', saldofinal * (-1), 4, 'Arial, negrita, 8');
    list.Linea(95, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'N');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 6', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(CHR15, True);
    Inc(lineas); if ControlarSalto then titulos;
    list.LineaTxt(utiles.espacios(63) +  '----------  ----------  -----------  ----------', True);
    Inc(lineas); if ControlarSalto then titulos;
    list.LineaTxt(CHR15 + 'Saldo Actual: ' + utiles.espacios(46), False);
    if totdebe <> 0  then list.importeTxt(totdebe, 12, 2, False);
    if tothaber <> 0 then list.importeTxt(tothaber, 12, 2, False);
    if tothaber <> 0 then Begin
      if saldofinal > 0 then list.importeTxt(saldofinal, 12, 2, False) else list.importeTxt(saldofinal * (-1), 24, 2, False);
    end;
    if tothaber = 0 then Begin
      if saldofinal > 0 then list.importeTxt(saldofinal, 24, 2, False) else list.importeTxt(saldofinal * (-1), 36, 2, False);
    end;
    list.LineaTxt('', True);
    Inc(lineas); if ControlarSalto then titulos;
    list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
    Inc(lineas); if ControlarSalto then titulos;
    list.LineaTxt('', True);
    Inc(lineas); if ControlarSalto then titulos;
  end;
  totdebe := 0; tothaber := 0;
end;

procedure TTLMayor.ListMayor(df, hf, dc, hc: string; salida: char);
// Objetivo...: Listado Libro Mayor
var
  xdc, xhc: string;
begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Setear(salida);
    ListarDatosEmpresa(salida);
    list.Titulo(0, 0, ' Libro Mayor', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Times New Roman, normal, 6');
    list.Titulo(0, 0, utiles.espacios(12) + 'Fecha    Concepto', 1, 'Arial, cursiva, 8');
    list.Titulo(50, list.lineactual, 'Debe',  2, 'Arial, cursiva, 8');
    list.Titulo(60, list.lineactual, 'Haber', 3, 'Arial, cursiva, 8');
    list.Titulo(71, list.lineactual, 'Sal. Deudor',  4, 'Arial, cursiva, 8');
    list.Titulo(81, list.lineactual, 'Sal. Acreedor',  5, 'Arial, cursiva, 8');
    list.Titulo(94, list.lineactual, 'Nº Asiento',  6, 'Arial, cursiva, 8');

    list.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    Pag := 0;
    titulos;
  end;

  totdebe := 0; tothaber := 0; idanterior := ''; datok := False; saldo := 0;
  xdc := dc; xhc := hc;
  if Length(Trim(xdc)) < 12 then
    begin
      xdc := '0.0.0.00.000'; xhc := '9.9.9.99.999';
    end;

  asientos.First;
  while not asientos.EOF do
    begin
      if asientos.FieldByName('codcta').AsString <> idanterior1 then
        begin
          saldo := 0;
          if asientos.FieldByName('dh').AsString = '1' then saldo := saldo + asientos.FieldByName('importe').AsFloat else saldo := saldo  - asientos.FieldByName('importe').AsFloat;
        end
      else
        if asientos.FieldByName('dh').AsString = '1' then saldo := saldo + asientos.FieldByName('importe').AsFloat else saldo := saldo  - asientos.FieldByName('importe').AsFloat;
      if asientos.FieldByName('dh').AsString = '1' then saldoanter := saldo - asientos.FieldByName('importe').AsFloat else saldoanter := saldo + asientos.FieldByName('importe').AsFloat;

      if ((asientos.FieldByName('fecha').AsString >= utiles.sExprFecha2000(df)) and (asientos.FieldByName('fecha').AsString <= utiles.sExprFecha2000(hf))) and ((asientos.FieldByName('codcta').AsString >= xdc) and (asientos.FieldByName('codcta').AsString <= xhc)) then
        begin
          if asientos.FieldByName('codcta').AsString <> idanterior then CorteCuenta(salida);

          if (salida = 'I') or (salida = 'P') then Begin
            list.Linea(0, 0, utiles.espacios(10) + utiles.sFormatoFecha(asientos.FieldByName('fecha').AsString) + '  ' + asientos.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
            if asientos.FieldByName('dh').AsString = '1' then list.importe(55, list.lineactual, '', asientos.FieldByName('importe').AsFloat, 2, 'Arial, normal, 8') else list.importe(67, list.lineactual, '', asientos.FieldByName('importe').AsFloat, 2, 'Arial, normal, 8');
            if asientos.FieldByName('dh').AsString = '1' then totdebe := totdebe + asientos.FieldByName('importe').AsFloat else tothaber := tothaber + asientos.FieldByName('importe').AsFloat;
            if saldo >= 0 then list.importe(80, list.lineactual, '', saldo  , 3, 'Arial, normal, 8')
              else list.importe(93, list.lineactual, '', saldo * (-1)  , 3, 'Arial, normal, 8');
            list.Linea(94, list.Lineactual, asientos.FieldByName('nroasien').AsString, 4, 'Arial, normal, 8', salida, 'S');
          end;
          if (salida = 'T') then Begin
            list.LineaTxt(' ' + CHR15 + utiles.sFormatoFecha(asientos.FieldByName('fecha').AsString) + ' ' + utiles.StringLongitudFija(asientos.FieldByName('concepto').AsString, 42) + ' ' + asientos.FieldByName('nroasien').AsString, False);
            if asientos.FieldByName('dh').AsString = '1' then Begin
              list.importetxt(asientos.FieldByName('importe').AsFloat, 12, 2, False);
              list.LineaTxt(utiles.espacios(12), False);
            end else
              list.importetxt(asientos.FieldByName('importe').AsFloat, 24, 2, False);
            if asientos.FieldByName('dh').AsString = '1' then totdebe := totdebe + asientos.FieldByName('importe').AsFloat else tothaber := tothaber + asientos.FieldByName('importe').AsFloat;
            if saldo >= 0 then
              list.importetxt(saldo, 12, 2, False)
            else
              list.importetxt(saldo * (-1), 24, 2, False);
            list.LineaTxt('', True);
            Inc(lineas); if ControlarSalto then titulos;
          end;

          idanterior := asientos.FieldByName('codcta').AsString;
          saldofinal := saldo;
        end;


      idanterior1 := asientos.FieldByName('codcta').AsString;

      asientos.Next;
    end;
  if (totdebe + tothaber) <> 0 then SubtotalCuenta(salida);

  if (salida = 'I') or (salida = 'P') then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTLMayor.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  inherited conectar;
  asientos.IndexFieldNames := 'Periodo;Codcta;Fecha';
end;

procedure TTLMayor.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
end;

{===============================================================================}

function lmayor: TTLMayor;
begin
  if xlmayor = nil then
    xlmayor := TTLMayor.Create;
  Result := xlmayor;
end;

{===============================================================================}

initialization

finalization
  xlmayor.Free;

end.
