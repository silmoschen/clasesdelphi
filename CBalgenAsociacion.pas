{ Objetivo....: Gestionar los cálculos para la Emisión de los Informes Contables
  Fianales - Estado de Resultados, Balances, entre otros}

unit CBalgenAsociacion;

interface

uses CEstFinAsociacion, CPlanctasAsociacion, SysUtils, DB, DBTables, CBDT, CUtiles,
     CIDBFM, CListar, CServers2000_Excel;

const mascara = '###,###,###,##0.00';

type

TTBalanceGeneral = class(TTEstadosContables)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure tipoBalance(t: char);
  procedure Listar(tipolistado, tipobal, salida: char);
 private
  { Declaraciones Privadas }
  digitoct, l1: string;
  c1: Integer;
  procedure ListLinea(tipolistado, salida: char);
  procedure titulo;
 protected
  { Declaraciones Protegidas }
end;

function balgen: TTBalanceGeneral;

implementation

var
  xbalgen: TTBalanceGeneral = nil;

constructor TTBalanceGeneral.Create;
begin
  inherited Create;
end;

destructor TTBalanceGeneral.Destroy;
begin
  inherited Destroy;
end;

procedure TTBalanceGeneral.tipoBalance(t: char);
// Objetivo...: determinar si en el balgen se incluyen o no las cuentas de resultado
var
  cta: string;
begin
  plctas.Filtered := False;
  if t = 'S' then
    begin
      planctas.getDatos;
      if planctas.Ganancias < planctas.Perdidas then cta := planctas.Ganancias else cta := planctas.Perdidas;
      CalcPatNeto(t);
      datosdb.Filtrar(plctas, 'codcta < ' + '''' + cta + '''');
    end
  else
    plctas.Filtered := False;
end;

procedure TTBalanceGeneral.ListLinea(tipolistado, salida: char);
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

      if (salida = 'P') or (salida = 'I') then Begin
        if ((Copy(plctas.FieldByName('codcta').AsString, 1, 1)) <> digitoct) and (digitoct <> '') then list.Linea(0, 0, '  ', 1, ft, salida, 'S');
        list.Linea(0, 0, plctas.FieldByName('codcta').AsString + ' ' + plctas.FieldByName('nivel').AsString + '  ' + utiles.espacios(plctas.FieldByName('nivel').AsInteger * 2) + plctas.FieldByName('cuenta').AsString, 1, ft, salida, 'N');
      end;
      if salida = 'X' then Begin
       Inc(c1); l1 := Trim(IntToStr(c1));
       excel.setString('a' + l1, 'a' + l1, plctas.FieldByName('codcta').AsString, ft);
       excel.setString('b' + l1, 'b' + l1, plctas.FieldByName('cuenta').AsString, ft);
      end;
      if (salida = 'T') then Begin
        if ((Copy(plctas.FieldByName('codcta').AsString, 1, 1)) <> digitoct) and (digitoct <> '') then list.LineaTxt('', True);
        list.LineaTxt(CHR15 + plctas.FieldByName('codcta').AsString + ' ' + plctas.FieldByName('nivel').AsString + '  ' + utiles.espacios(plctas.FieldByName('nivel').AsInteger * 2) + utiles.StringLongitudFija(plctas.FieldByName('cuenta').AsString, 30), False);
      end;

      saldo := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
      s_ant := plctas.FieldByName('a_totaldebe').AsFloat - plctas.FieldByName('a_totalhaber').AsFloat;
      if saldo < 0 then saldo := saldo * (-1);
      if s_ant < 0 then s_ant := s_ant * (-1);
      {Calculamos la Distancia a mirar el Importe}
      distancia := 0;
      n         := plctas.FieldByName('nivel').AsInteger;
      For x := 1 to n do distancia := distancia + 3;
      if salida = 'T' then Begin
        distancia := 0;
        For x := 1 to n do distancia := distancia + 2;
      end;

      if (salida = 'P') or (salida = 'I') then Begin
        if s_ant <> 0 then list.importe(57 + distancia, list.lineactual, mascara, s_ant, 2, ft);
        if saldo <> 0 then list.importe(77 + distancia, list.lineactual, mascara, saldo, 3, ft);
        if (s_ant + saldo <> 0) then list.importe(95 + distancia, list.lineactual, mascara, s_ant + saldo, 4, ft) else
          list.importe(95 + distancia, list.lineactual, '#', 0, 4, ft);

        list.Linea(99, list.lineactual, ' ', 5, ft, salida, 'S');
      end;
      if salida = 'X' then Begin
        if s_ant <> 0 then excel.setReal('c' + l1, 'c' + l1, s_ant, ft);
        if saldo <> 0 then excel.setReal('d' + l1, 'd' + l1, saldo, ft);
        if (s_ant + saldo <> 0) then excel.setReal('e' + l1, 'e' + l1, s_ant + saldo, ft);
      end;

      if (salida = 'T') then Begin
        list.LineaTxt(utiles.espacios(distancia), False);
        if s_ant <> 0 then list.importetxt(s_ant, 12, 2, False) else list.LineaTxt('              ', False);
        if saldo <> 0 then list.importetxt(saldo, 12, 2, False);
        if (s_ant + saldo <> 0) then list.importetxt(s_ant + saldo, 12, 2, false) else
          list.importetxt(0, 12, 2, False);

        list.LineaTxt('', True);
        Inc(lineas); if ControlarSalto then titulo;
      end;

      digitoct := Copy(plctas.FieldByName('codcta').AsString, 1, 1);
    end;
end;

procedure TTBalanceGeneral.Listar(tipolistado, tipobal, salida: char);
var
  digitoct: string;
begin
  tipoBalance(tipobal);

  saldo := 0; totdebe := 0; tothaber := 0; totsaldodeudor := 0; totsaldoacreedor := 0; c1 := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    ListarDatosEmpresa(salida);
    list.Titulo(0, 0, ' Balance de General', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
    //list.Titulo(95, list.lineactual, 'Pág.: ' + utiles.sLlenarIzquierda(IntToStr(list.nroPagina), 4, '0'), 2, 'Arial, normal, 8');
    list.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 6');
    list.Titulo(0, 0, '  Código         Cuenta ', 1, 'Arial, cursiva, 8');
    list.Titulo(60, list.lineactual, 'S. Anterior', 2, 'Arial, cursiva, 8');
    list.Titulo(80, list.lineactual, 'S. Período', 3, 'Arial, cursiva, 8');
    list.Titulo(100, list.lineactual, 'S.Final', 4, 'Arial, cursiva, 8');

    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, cursiva, 8');
  end;

  if salida = 'X' then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 9.5);
    excel.setString('a' + l1, 'a' + l1, 'Balance General', 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Código', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 37);
    excel.setString('b' + l1, 'b' + l1, 'Cuenta', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 14);
    excel.setString('c' + l1, 'c' + l1, 'S. Anterior', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('d' + l1, 'd' + l1, 10);
    excel.setString('d' + l1, 'd' + l1, 'S. Período', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('e' + l1, 'e' + l1, 10);
    excel.setString('e' + l1, 'e' + l1, 'S. Final', 'Arial, negrita, 10');
    Inc(c1);
  end;

  if (salida = 'T') then Begin
    list.IniciarImpresionModoTexto;
    Pag := 0;
    titulo;
  end;

  digitoct := '';
  plctas.Open;
  while not plctas.EOF do
    begin
       ListLinea(tipolistado, salida);
       plctas.Next;
    end;

  if (salida = 'P') or (salida = 'I') then Begin
    list.FinList;
  end;

  if salida = 'X' then Begin
    excel.setString('a2', 'a2', '', 'Arial, negrita, 8');
    excel.Visulizar;
  end;

  if (salida = 'T') then list.FinalizarImpresionModoTexto(1); 
end;

procedure TTBalanceGeneral.titulo;
// objetivo.... listar titulo en modo texto
Begin
  ListarDatosEmpresa('T');
  list.LineaTxt('', True);
  list.LineaTxt(CHR18 + 'Balance General                                             Hoja: ' + IntToStr(Pag), True);
   list.LineaTxt('', True);
  list.LineaTxt(CHR15 + 'Código            Cuenta                                          S. Anterior  S.Actual    S.Final', True);
  list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  list.LineaTxt('', True);
  Lineas := Lineas + 6;
end;

{===============================================================================}

function balgen: TTBalanceGeneral;
begin
  if xbalgen = nil then
    xbalgen := TTBalanceGeneral.Create;
  Result := xbalgen;
end;

{===============================================================================}

initialization

finalization
  xbalgen.Free;

end.