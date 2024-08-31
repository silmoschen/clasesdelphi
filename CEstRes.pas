{ Objetivo....: Gestionar los cálculos para la Emisión de los Informes Contables
  Fianales - Estado de Resultados, Balances, entre otros}

unit CEstRes;

interface

uses CEstFin, CEEstRes, CPlanctas, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM, CListar;

type

TTEstadoResultados = class(TTEstadosContables)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Listar(salida: char);
 private
  { Declaraciones Privadas }
  tm: shortint;
  function ListMovimientos(digito: string; salida: char): integer;
 protected
  { Declaraciones Protegidas }
end;

function estres: TTEstadoResultados;

implementation

var
  xestres: TTEstadoResultados = nil;

constructor TTEstadoResultados.Create;
begin
  inherited Create;
end;

destructor TTEstadoResultados.Destroy;
begin
  inherited Destroy;
end;

function TTEstadoResultados.ListMovimientos(digito: string; salida: char): integer;
begin
  plctas.First;
  planctas.getDatos;
  tm := 0;
  while not plctas.EOF do
    begin
      if ((Copy(plctas.FieldByName('codcta').AsString, 1, 1) = digito) and (plctas.FieldByName('imputable').AsString = 'S')) and (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat <> 0) then
        begin
          if (digito = planctas.Ganancias) and (plctas.FieldByName('codcta').AsString <> ctestres.Ctaingreso) and (plctas.FieldByName('sumariza').AsString <> ctestres.Ctaingreso) then
            begin
               list.Linea(0, 0, utiles.espacios(10) + plctas.FieldByName('codcta').AsString + '  ' + plctas.FieldByName('cuenta').AsString, 1, 'Arial, negrita, 9', salida, 'N');
               list.importe(90, list.lineactual, '', (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1), 2, 'Arial, negrita, 9');
               totingresos := totingresos + plctas.FieldByName('totalhaber').AsFloat;
               tm := 1;
            end;
          if (digito = planctas.Perdidas) and (plctas.FieldByName('codcta').AsString <> ctestres.Ctaegreso) and (plctas.FieldByName('sumariza').AsString <> ctestres.Ctaegreso) then
            begin
              list.Linea(0, 0, utiles.espacios(10) + plctas.FieldByName('codcta').AsString + '  ' + plctas.FieldByName('cuenta').AsString, 1, 'Arial, negrita, 9', salida, 'N');
              list.importe(70, list.lineactual, '', plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat, 2, 'Arial, negrita, 9');
              totegresos := totegresos + plctas.FieldByName('totaldebe').AsFloat;
              tm := 1;
            end;
          list.Linea(95, list.lineactual, ' ', 3, 'Arial, negrita, 9', salida, 'S');
        end;
        plctas.Next;
    end;
    Result := tm;
end;

procedure TTEstadoResultados.Listar(salida: char);
begin
  {Abrimos la tabla con los Parámetros de Emisión}
  saldo := 0; totdebe := 0; tothaber := 0; totingresos := 0; totegresos := 0;
  ///IniciarInforme(salida);
  ListDatosEmpresa(salida);
  list.Titulo(0, 0, ' Estado de Resultados', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 6');
  list.Titulo(0, 0, '  Código          Cuenta ', 1, 'Arial, cursiva, 9');
  list.Titulo(65, list.lineactual, 'Debe', 2, 'Arial, cursiva, 9');
  list.Titulo(84, list.lineactual, 'Haber', 3, 'Arial, cursiva, 9');
  list.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 9');

  ctestres.getDatos;    // Extracción de las cuentas que determinan los niveles de ruptura

  planctas.Buscar(ctestres.Ctaingreso);
  list.Linea(0, 0, utiles.espacios(10) + plctas.FieldByName('codcta').AsString + '  ' + plctas.FieldByName('cuenta').AsString, 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(90, list.lineactual, '', (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1), 2, 'Arial, negrita, 9');
  tothaber := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
  list.Linea(0, 0, 'menos', 1, 'Arial, normal, 9', salida, 'N');

  planctas.Buscar(ctestres.Ctaegreso);
  list.Linea(0, 0, utiles.espacios(10) + plctas.FieldByName('codcta').AsString + '  ' + plctas.FieldByName('cuenta').AsString, 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(70, list.lineactual, '', plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat, 2, 'Arial, negrita, 9');
  totdebe := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;

  list.Linea(0, 0, 'igual', 1, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
  list.derecha(90, list.lineactual, '###############', '------------------', 2, 'Arial, negrita, 9');
  list.Linea(0, 0, 'UTILIDAD BRUTA', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(90, list.lineactual, '', (tothaber - (totdebe * (-1))) * (-1), 2, 'Arial, negrita, 9');
  list.Linea(0, 0, 'mas', 1, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, utiles.espacios(5) + 'OTROS INGRESOS', 1, 'Arial, negrita, 9', salida, 'S');

  if ListMovimientos(ctestres.Digctaingr, salida) > 0 then
    begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(90, list.lineactual, '###############', '------------------', 2, 'Arial, negrita, 9');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
      list.importe(90, list.lineactual, '', totingresos, 2, 'Arial, negrita, 9');
      list.Linea(0, 90, ' ', 3, 'Arial, negrita, 9', salida, 'S');
    end;

  list.Linea(0, 0, 'menos', 1, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, utiles.espacios(5) + 'OTROS EGRESOS', 1, 'Arial, negrita, 9', salida, 'S');

  if ListMovimientos(ctestres.Digctaegr, salida) > 0 then
    begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(70, list.lineactual, '###############', '------------------', 2, 'Arial, negrita, 9');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(70, list.lineactual, '', totegresos, 2, 'Arial, negrita, 9');
      list.Linea(0, 80, ' ', 3, 'Arial, negrita, 9', salida, 'S');
    end;

  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, 'UTILIDAD NETA OPERATIVA', 1, 'Arial, negrita, 9', salida, 'S');
  if (tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos) < 0 then list.importe(70, list.lineactual, '', (tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos), 2, 'Arial, negrita, 9')
    else list.importe(90, list.lineactual, '', (tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos), 2, 'Arial, negrita, 9');

  list.CompletarPagina;
  list.Linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, 'Pág.: ' + utiles.sLlenarIzquierda(IntToStr(list.nroPagina), 4, '0'), 1, 'Arial, normal, 8', salida, 'S');

  list.FinList;
end;

{===============================================================================}

function estres: TTEstadoResultados;
begin
  if xestres = nil then
    xestres := TTEstadoResultados.Create;
  Result := xestres;
end;

{===============================================================================}

initialization

finalization
  xestres.Free;

end.