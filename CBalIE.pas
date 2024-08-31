{ Objetivo....: Gestionar los cálculos para la Emisión de los Informes Contables
  Fianales - Estado de Resultados, Balances, entre otros}

unit CBalIE;

interface

uses CEstFin, CPlanctas, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM, CListar;

type

TTBalanceIE = class(TTEstadosContables)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   tipoBalance(t: char);
  procedure   Listar(tipolistado, salida: char);
 private
  { Declaraciones Privadas }
  digitoct, cta, cti, cte: string;
  procedure ListLinea(tipolistado, salida: char);
 protected
  { Declaraciones Protegidas }
end;

function balingegr: TTBalanceIE;

implementation

var
  xbalingegr: TTBalanceIE = nil;

constructor TTBalanceIE.Create;
begin
  inherited Create;
end;

destructor TTBalanceIE.Destroy;
begin
  inherited Destroy;
end;

procedure TTBalanceIE.tipoBalance(t: char);
// Objetivo...: determinar si en el balingegr se incluyen o no las cuentas de resultado
begin
  plctas.Filtered := False;
  if t = 'S' then
    begin
      planctas.getDatos;
      cti := planctas.Ganancias;
      cte := planctas.Perdidas;
      if cti < cte then cta := cti else cta := cte;
      CalcPatNeto(t);
      datosdb.Filtrar(plctas, 'codcta >= ' + '''' + cta + '''');
    end;
end;

procedure TTBalanceIE.ListLinea(tipolistado, salida: char);
{Objetivo...: Emitir una Línea de Detalle}
var
  x, n, distancia: byte; s_ant: real;
  l, ft: string;
begin
  if tipolistado = 'N' then
    if (plctas.FieldByName('totaldebe').AsFloat > 0) or (plctas.FieldByName('totalhaber').AsFloat > 0) or (plctas.FieldByName('a_totaldebe').AsFloat > 0) or (plctas.FieldByName('a_totalhaber').AsFloat > 0) then l := 'S' else l := 'N';
  if tipolistado = 'S' then l := 'S';
  if l = 'S' then
    begin
      if (Copy(plctas.FieldByName('codcta').AsString, 1, 1)) <> digitoct then ft := 'Arial, negrita, 8' else ft := 'Arial, normal, 8';
      if (plctas.FieldByName('imputable').AsString = 'N') and not (Copy(plctas.FieldByName('codcta').AsString, 1, 1) <> digitoct) then ft := 'Arial, cursiva, 8';
      if ((Copy(plctas.FieldByName('codcta').AsString, 1, 1)) <> digitoct) and (digitoct <> '') then list.Linea(0, 0, '  ', 1, ft, salida, 'S');
      list.Linea(0, 0, plctas.FieldByName('codcta').AsString + '  ' + utiles.espacios(plctas.FieldByName('nivel').AsInteger * 2) + plctas.FieldByName('cuenta').AsString, 1, ft, salida, 'N');
      saldo := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
      s_ant := plctas.FieldByName('a_totaldebe').AsFloat - plctas.FieldByName('a_totalhaber').AsFloat;
      if saldo < 0 then saldo := saldo * (-1);
      if s_ant < 0 then s_ant := s_ant * (-1);
      {Calculamos la Distancia a mirar el Importe}
      distancia := 0;
      n         := plctas.FieldByName('nivel').AsInteger;
      For x := 1 to n do distancia := distancia + 3;
      if s_ant <> 0 then list.importe(57 + distancia, list.lineactual, '', s_ant, 2, ft);
      if saldo <> 0 then list.importe(77 + distancia, list.lineactual, '', saldo, 3, ft);
      if (s_ant + saldo <> 0) then list.importe(97 + distancia, list.lineactual, '', s_ant + saldo, 4, ft);

      list.Linea(99, list.lineactual, ' ', 5, ft, salida, 'S');
      digitoct := Copy(plctas.FieldByName('codcta').AsString, 1, 1);
    end;
end;

procedure TTBalanceIE.Listar(tipolistado, salida: char);
var
  digitoct: string;
begin
  tipoBalance('S');

  saldo := 0; totdebe := 0; tothaber := 0; totsaldodeudor := 0; totsaldoacreedor := 0;
  IniciarInforme(salida);
  list.Titulo(0, 0, ' Balance de Ingresos y Egresos', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  list.Titulo(95, list.lineactual, 'Pág.: ' + utiles.sLlenarIzquierda(IntToStr(list.nroPagina), 4, '0'), 2, 'Arial, normal, 8');
  list.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 6');
  list.Titulo(0, 0, '  Código         Cuenta ', 1, 'Arial, cursiva, 8');
  list.Titulo(60, list.lineactual, 'S. Anterior', 2, 'Arial, cursiva, 8');
  list.Titulo(80, list.lineactual, 'S. Período', 3, 'Arial, cursiva, 8');
  list.Titulo(100, list.lineactual, 'S.Final', 4, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, cursiva, 8');

  digitoct := '';
  plctas.Open;

  plctas.First;
  while not plctas.EOF do  // Ingresos
    begin
       if Copy(plctas.FieldByName('codcta').AsString, 1, 1) = cti then ListLinea(tipolistado, salida);
       plctas.Next;
    end;

  plctas.First;
  while not plctas.EOF do // Egresos
    begin
       if Copy(plctas.FieldByName('codcta').AsString, 1, 1) = cte then ListLinea(tipolistado, salida);
       plctas.Next;
    end;

  list.CompletarPagina;

  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  list.FinList;
end;

{===============================================================================}

function balingegr: TTBalanceIE;
begin
  if xbalingegr = nil then
    xbalingegr := TTBalanceIE.Create;
  Result := xbalingegr;
end;

{===============================================================================}

initialization

finalization
  xbalingegr.Free;

end.