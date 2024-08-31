{ Objetivo....: Gestionar los cálculos para la Emisión de los Informes Contables
  Fianales - Estado de Resultados, Balances, entre otros}

unit CBalcss;

interface

uses CEstFin, CPlanctas, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM, CListar;

type

TTBalanceComprobacion = class(TTEstadosContables)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure tipoBalance(t: char);
  procedure Listar(tipolistado, salida: char);
 private
  { Declaraciones Privadas }
  l: char;
  procedure ListLinea(tipolistado, salida: char);
 protected
  { Declaraciones Protegidas }
end;

function bcss: TTBalanceComprobacion;

implementation

var
  xbcss: TTBalanceComprobacion = nil;

constructor TTBalanceComprobacion.Create;
begin
  inherited Create;
end;

destructor TTBalanceComprobacion.Destroy;
begin
  inherited Destroy;
end;

procedure TTBalanceComprobacion.tipoBalance(t: char);
// Objetivo...: determinar si en el bcss se incluyen o no las cuentas de resultado
var
  cta: string;
begin
  if t = 'N' then
    begin
      planctas.getDatos;
      if planctas.Ganancias < planctas.Perdidas then cta := planctas.Ganancias else cta := planctas.Perdidas;
      CalcPatNeto(t);
      datosdb.Filtrar(plctas, 'codcta < ' + '''' + cta + '''');
    end
  else
    plctas.Filtered := False;
end;

procedure TTBalanceComprobacion.ListLinea(tipolistado, salida: char);
{Objetivo...: Emitir una Línea de Detalle}
begin
  if tipolistado = 'N' then
    if (plctas.FieldByName('totaldebe').AsFloat > 0) or (plctas.FieldByName('Totalhaber').AsFloat > 0) then l := 'S' else l := 'N';
  if tipolistado = 'S' then l := 'S';
  if l = 'S' then
    begin
      list.Linea(0, 0, plctas.FieldByName('codcta').AsString + '  ' + plctas.FieldByName('cuenta').AsString, 1, 'Arial, fsBold, 8', salida, 'N');
      if plctas.FieldByName('totaldebe').AsFloat > 0 then list.importe(60, list.lineactual, '', plctas.FieldByName('totaldebe').AsFloat, 2, 'Arial, normal, 8');
      if plctas.FieldByName('totalhaber').AsFloat > 0 then list.importe(70, list.lineactual, '', plctas.FieldByName('totalhaber').AsFloat, 3, 'Arial, normal, 8');
      saldo := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
      if saldo > 0 then list.importe(85, list.lineactual, '', saldo, 4, 'Arial, normal, 8') else if saldo < 0 then list.importe(95, list.lineactual, '', saldo * (-1), 4, 'Arial, normal, 8');
      totdebe  := totdebe  + plctas.FieldByName('totaldebe').AsFloat;
      tothaber := tothaber + plctas.FieldByName('totalhaber').AsFloat;
      if saldo > 0 then totsaldodeudor := totsaldodeudor + saldo else totsaldoacreedor := totsaldoacreedor + saldo;
      list.Linea(98, list.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
    end;
end;

procedure TTBalanceComprobacion.Listar(tipolistado, salida: char);
begin
  saldo := 0; totdebe := 0; tothaber := 0; totsaldodeudor := 0; totsaldoacreedor := 0;
  ListDatosEmpresa(salida);
  list.Titulo(0, 0, ' Balance de Comprobación de Sumas y Saldos', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  list.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 6');
  list.Titulo(0, 0, '  Código         Cuenta ', 1, 'Arial, cursiva, 8');
  list.Titulo(56, list.lineactual, 'Debe', 2, 'Arial, cursiva, 8');
  list.Titulo(65, list.lineactual, 'Haber', 3, 'Arial, cursiva, 8');
  list.Titulo(75, list.lineactual, 'Saldo Deudor', 4, 'Arial, cursiva, 8');
  list.Titulo(87, list.lineactual, 'Saldo Acreedor', 5, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, cursiva, 8');

  plctas.First;
  while not plctas.EOF do
    begin
      if list.SaltoPagina then list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
      if plctas.FieldByName('imputable').AsString = 'S' then listLinea(tipolistado, salida);
      plctas.Next;
    end;

    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

    list.Linea(0, 0, utiles.espacios(40) + 'Totales ........:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(60, list.lineactual, '', totdebe, 2, 'Arial, negrita, 8');
    list.importe(70, list.lineactual, '', tothaber, 3, 'Arial, negrita, 8');
    list.importe(85, list.lineactual, '', totsaldodeudor, 4, 'Arial, normal, 8');
    list.importe(95, list.lineactual, '', totsaldoacreedor * (-1), 5, 'Arial, normal, 8');

    list.FinList;
end;

{===============================================================================}

function bcss: TTBalanceComprobacion;
begin
  if xbcss = nil then
    xbcss := TTBalanceComprobacion.Create;
  Result := xbcss;
end;

{===============================================================================}

initialization

finalization
  xbcss.Free;

end.