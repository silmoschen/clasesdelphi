{ Objetivo....: Gestionar los cálculos para la Emisión de los Informes Contables
  Fianales - Estado de Resultados, Balances, entre otros}

unit CPlsaldo;

interface

uses CEstFin, CPlanctas, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM, CListar;

type

TTPlanillaSaldos = class(TTEstadosContables)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Listar(tipolistado, salida: char);
 private
  { Declaraciones Privadas }
  procedure ListLinea(tipolistado, salida: char);
 protected
  { Declaraciones Protegidas }
end;

function plsaldos: TTPlanillaSaldos;

implementation

var
  xplsaldos: TTPlanillaSaldos = nil;

constructor TTPlanillaSaldos.Create;
begin
  inherited Create;
end;

destructor TTPlanillaSaldos.Destroy;
begin
  inherited Destroy;
end;

procedure TTPlanillaSaldos.ListLinea(tipolistado, salida: char);
{Objetivo...: Emitir una Línea de Detalle}
var
  l: string;
begin
  if tipolistado = 'N' then
    if (plctas.FieldByName('totaldebe').AsFloat > 0) or (plctas.FieldByName('totalhaber').AsFloat > 0) then l := 'S' else l := 'N';
  if tipolistado = 'S' then l := 'S';
  if l = 'S' then
    begin
      list.Linea(0, 0, plctas.FieldByName('codcta').AsString + '  ' + plctas.FieldByName('cuenta').AsString, 1, 'Arial, fsBold, 8', salida, 'N');
      saldo := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
      {Calculamos la Distancia a mirar el Importe}
      list.importe(55, list.lineactual, '', plctas.FieldByName('totaldebe').AsFloat, 2, 'Arial, normal, 8');
      list.importe(65, list.lineactual, '', plctas.FieldByName('totalhaber').AsFloat, 3, 'Arial, normal, 8');
      if saldo > 0 then list.importe(80, list.lineactual, '', saldo, 4, 'Arial, normal, 8');
      if saldo < 0 then list.importe(90, list.lineactual, '', saldo * (-1), 5, 'Arial, normal, 8');
      list.Linea(95, list.lineactual, '  ', 6, 'Arial, fsBold, 8', salida, 'S');
    end;
end;

procedure TTPlanillaSaldos.Listar(tipolistado, salida: char);
begin
  saldo := 0; totdebe := 0; tothaber := 0; totsaldodeudor := 0; totsaldoacreedor := 0;
  ///IniciarInforme(salida);
  list.Titulo(0, 0, ' Planilla de Saldos', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 6');
  list.Titulo(0, 0, '  Código          Cuenta ', 1, 'Arial, cursiva, 8');
  list.Titulo(48, list.lineactual, 'Tot. Debe', 2, 'Arial, cursiva, 8');
  list.Titulo(58, list.lineactual, 'Tot. Haber', 3, 'Arial, cursiva, 8');
  list.Titulo(70, list.lineactual, 'Saldo Deudor', 4, 'Arial, cursiva, 8');
  list.Titulo(82, list.lineactual, 'Saldo Acreedor', 5, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');

  plctas.First;
  while not plctas.EOF do
    begin
       ListLinea(tipolistado, salida);
       plctas.Next;
    end;
    
  list.FinList;
end;

{===============================================================================}

function plsaldos: TTPlanillaSaldos;
begin
  if xplsaldos = nil then
    xplsaldos := TTPlanillaSaldos.Create;
  Result := xplsaldos;
end;

{===============================================================================}

initialization

finalization
  xplsaldos.Free;

end.