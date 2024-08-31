{ Objetivo....: Gestionar los cálculos para la Emisión de los Informes Contables
  Fianales - Estado de Resultados, Balances, entre otros}

unit CBalcssAsociacion;

interface

uses CEstFinAsociacion, CPlanctasAsociacion, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM, CListar;

type

TTBalanceComprobacion = class(TTEstadosContables)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   tipoBalance(t: char);
  procedure   Listar(tipolistado, salida: char);
 private
  { Declaraciones Privadas }
  l: char; idanter: String;
  procedure ListLinea(tipolistado, salida: char);
  procedure titulo;
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
      if (salida = 'P') or (salida = 'I') then Begin
        if (Copy(plctas.FieldByName('codcta').AsString, 1, 1) <> idanter) and (Length(Trim(idanter)) > 0) then list.Linea(0, 0, '', 1, 'Arial, fsBold, 5', salida, 'S');
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
      if (salida = 'T') then Begin
        if (Copy(plctas.FieldByName('codcta').AsString, 1, 1) <> idanter) and (Length(Trim(idanter)) > 0) then Begin
          list.LineaTxt('', True);
          Inc(lineas); if ControlarSalto then titulo;
        end;
        list.LineaTxt(CHR15 + plctas.FieldByName('codcta').AsString + '  ' + utiles.StringLongitudFija(plctas.FieldByName('cuenta').AsString, 40), False);
        if plctas.FieldByName('totaldebe').AsFloat > 0 then list.importetxt(plctas.FieldByName('totaldebe').AsFloat, 12, 2, False);
        if plctas.FieldByName('totalhaber').AsFloat > 0 then list.importetxt(plctas.FieldByName('totalhaber').AsFloat, 12, 2, False);
        saldo := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
        if saldo > 0 then list.importetxt(saldo, 12, 2, False) else if saldo < 0 then list.importetxt(saldo * (-1), 24, 2, False);
        totdebe  := totdebe  + plctas.FieldByName('totaldebe').AsFloat;
        tothaber := tothaber + plctas.FieldByName('totalhaber').AsFloat;
        if saldo > 0 then totsaldodeudor := totsaldodeudor + saldo else totsaldoacreedor := totsaldoacreedor + saldo;
        list.LineaTxt('', True);
        Inc(lineas); if ControlarSalto then titulo;
      end;
      idanter := Copy(plctas.FieldByName('codcta').AsString, 1, 1);
    end;
end;

procedure TTBalanceComprobacion.titulo;
// objetivo.... listar titulo en modo texto
Begin
  ListarDatosEmpresa('T');
  list.LineaTxt('', True);
  list.LineaTxt(CHR18 + 'Balance de Comprobación de Sumas y Saldos                   Hoja: ' + IntToStr(Pag), True);
   list.LineaTxt('', True);
  list.LineaTxt(CHR15 + 'Código        Cuenta                                           Debe       Haber Sal. Deudor Sal. Acreedor', True);
  list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('', True);
  Lineas := Lineas + 6;
end;

procedure TTBalanceComprobacion.Listar(tipolistado, salida: char);
begin
  saldo := 0; totdebe := 0; tothaber := 0; totsaldodeudor := 0; totsaldoacreedor := 0; idanter := '';
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    ListarDatosEmpresa(salida);

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
  end;
  if (salida = 'T') then Begin
    list.IniciarImpresionModoTexto;
    Pag := 0;
    titulo;
  end;

  plctas.First;
  while not plctas.EOF do
    begin
      if (salida = 'P') or (salida = 'I') then Begin
        if list.SaltoPagina then list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
      end;
      if plctas.FieldByName('imputable').AsString = 'S' then listLinea(tipolistado, salida);
      plctas.Next;
    end;

    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

      list.Linea(0, 0, 'Totales:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(57, list.lineactual, '', totdebe, 2, 'Arial, negrita, 8');
      list.importe(69, list.lineactual, '', tothaber, 3, 'Arial, negrita, 8');
      list.importe(84, list.lineactual, '', totsaldodeudor, 4, 'Arial, normal, 8');
      list.importe(95, list.lineactual, '', totsaldoacreedor * (-1), 5, 'Arial, normal, 8');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
      Inc(lineas); if ControlarSalto then titulo;
      list.LineaTxt(CHR15 + 'Totales:' + utiles.espacios(47), False);
      list.importeTxt(totdebe, 12, 2, False);
      list.importeTxt(tothaber, 12, 2, False);
      list.importeTxt(totsaldodeudor, 12, 2, False);
      list.importeTxt(totsaldoacreedor * (-1), 12, 2, True);
    end;

    if (salida = 'P') or (salida = 'I') then list.FinList;
    if salida = 'T' then list.FinalizarImpresionModoTexto(1);
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