unit CLMayor;

interface

uses CRegCont, CPlanctas, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CPeriodo;

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

  cabasien := datosdb.openDB('cabasien.DB', 'Periodo;Nroasien');
  asientos := datosdb.openDB('asientos.DB', '', 'Idasiento');
  ccostos  := datosdb.openDB('ccostos.DB', 'Periodo;Nroasien;Codcta;Nromovi');
end;

destructor TTLMayor.Destroy;
begin
  inherited Destroy;
end;

procedure TTLMayor.CorteCuenta(salida: char);
{Objetivo...: Nivel de ruptura por cuenta}
begin
  if datok then SubtotalCuenta(salida);
  planctas.getDatos(asientos.FieldByName('codcta').AsString);
  list.Linea(0, 0, 'Cuenta:    ' + asientos.FieldByName('codcta').AsString + '  ' + TrimLeft(planctas.Cuenta), 1, 'Arial, negrita, 8', salida, 'N');
  list.Linea(370, list.lineactual, 'Saldo Anterior ..............:  ', 2, 'Arial, negrita, 8', salida, 'N');
  if saldoanter > 0 then list.importe(80, list.lineactual, '', saldoanter, 3, 'Arial, negrita, 8') else list.importe(93, list.lineactual, '', saldoanter * (-1), 3, 'Arial, negrita, 8');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'N');
  datok := True;
end;

procedure TTLMayor.SubtotalCuenta;
{Objetivo...: Subtotal de Cuenta}
begin
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(55, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  list.derecha(67, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  list.derecha(80, list.lineactual, '', '--------------', 4, 'Arial, normal, 8');
  list.derecha(93, list.lineactual, '', '--------------', 5, 'Arial, normal, 8');
  list.Linea(95, list.lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  if totdebe <> 0  then list.importe(55, list.lineactual, '', totdebe, 2, 'Arial, negrita, 8');
  if tothaber <> 0 then list.importe(67, list.lineactual, '', tothaber, 3, 'Arial, negrita, 8');
  list.Linea(0, 0, 'Saldo Actual .........................:  ', 1, 'Arial, negrita, 8', salida, 'N');
  if saldofinal > 0 then list.importe(80, list.lineactual, '', saldofinal, 2, 'Arial, negrita, 8') else list.importe(93, list.lineactual, '', saldofinal * (-1), 2, 'Arial, negrita, 8');
  list.Linea(95, list.lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'N');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 6', salida, 'S');
  totdebe := 0; tothaber := 0;
end;

procedure TTLMayor.ListMayor(df, hf, dc, hc: string; salida: char);
// Objetivo...: Listado Libro Mayor
var
  xdc, xhc: string;
begin
  ListDatosEmpresa(salida);
  list.Titulo(0, 0, ' Libro Mayor', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Times New Roman, normal, 6');
  list.Titulo(0, 0, utiles.espacios(12) + 'Fecha    Concepto', 1, 'Arial, cursiva, 8');
  list.Titulo(50, list.lineactual, 'Debe',  2, 'Arial, cursiva, 8');
  list.Titulo(60, list.lineactual, 'Haber', 3, 'Arial, cursiva, 8');
  list.Titulo(71, list.lineactual, 'Sal. Deudor',  4, 'Arial, cursiva, 8');
  list.Titulo(81, list.lineactual, 'Sal. Acreedor',  5, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

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

      if ((asientos.FieldByName('fecha').AsString >= utiles.sExprfecha(df)) and (asientos.FieldByName('fecha').AsString <= utiles.sExprFecha(hf))) and ((asientos.FieldByName('codcta').AsString >= xdc) and (asientos.FieldByName('codcta').AsString <= xhc)) then
        begin
          if asientos.FieldByName('codcta').AsString <> idanterior then CorteCuenta(salida);
          list.Linea(0, 0, utiles.espacios(10) + utiles.sFormatoFecha(asientos.FieldByName('fecha').AsString) + '  ' + asientos.FieldByName('concepto').AsString, 1, 'Arial, fsBold, 8', salida, 'N');
          if asientos.FieldByName('dh').AsString = '1' then list.importe(55, list.lineactual, '', asientos.FieldByName('importe').AsFloat, 2, 'Arial, normal, 8') else list.importe(67, list.lineactual, '', asientos.FieldByName('importe').AsFloat, 2, 'Arial, normal, 8');
          if asientos.FieldByName('dh').AsString = '1' then totdebe := totdebe + asientos.FieldByName('importe').AsFloat else tothaber := tothaber + asientos.FieldByName('importe').AsFloat;
          if saldo >= 0 then list.importe(80, list.lineactual, '', saldo  , 3, 'Arial, normal, 8')
            else list.importe(93, list.lineactual, '', saldo * (-1)  , 3, 'Arial, normal, 8');
          idanterior := asientos.FieldByName('codcta').AsString;
          saldofinal := saldo;
        end;


      idanterior1 := asientos.FieldByName('codcta').AsString;

      asientos.Next;
    end;
  if (totdebe + tothaber) <> 0 then SubtotalCuenta(salida);

  list.FinList;
end;

procedure TTLMayor.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  inherited conectar;
  asientos.IndexName := 'Mayor';
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
