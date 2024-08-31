unit CEstadoCuotasPreveer;

interface

uses CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles, CListar;

const
  cantitems = 15;

type

TTEstadoCuotasPreveer = class(TObject)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  function    setAbonados: TQuery;
  function    setAbonadosNumero: TQuery;
  procedure   InformeEstadoCuotas(xfdesde, xfhasta: String; listSel: Array of String; salida: Char);
  procedure   InformeFechasDePago(xfdesde, xfhasta: String; listSel: Array of String; salida: Char);
  procedure   InformeAbonadosPlan(listSel: Array of String; salida: Char);

  function    setAbonos: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones, mes, mi, mac: ShortInt;
  totales : array[1..cantitems] of Real;
  totmeses: array[1..cantitems] of Real;
  totpag: array[1..cantitems] of Real;
  DB: TDataBase;
  rmeses, mm: array[1..12] of String; s: string;
  ExistenDatos: Boolean;
  procedure Linea(xcodigo, xnombre, xabono, xrealizado, xpromotor: String; xmonto: Real; xmi: Integer; listSel: Array of String; salida: Char);
  procedure LineaFecha(xcodigo, xnombre, xabono, xrealizado, xpromotor: String; xmonto: Real; xmi: Integer; listSel: Array of String; salida: Char);
  function  verificarItemsEnLista(listArray: Array of String; xitems: String): Boolean;
  procedure TotalesFinales(xmi: Integer; salida: char);
  procedure TotPagina(xtotpag: real; salida: char);
 protected
  { Declaraciones Protegidas }
end;

function estadocuotas: TTEstadoCuotasPreveer;

implementation

var
  xestadocuotas: TTEstadoCuotasPreveer = nil;

constructor TTEstadoCuotasPreveer.Create;
begin
  inherited Create;
  DB := TDataBase.Create(nil);
  DB.AliasName    := 'Preveer';
  DB.DataBaseName := 'Preveer';
  DB.Name         := 'Preveer';
  DB.Params.Add('USER NAME=' + 'admin');
  DB.Params.Add('PASSWORD=' + '');
  DB.LoginPrompt := False;
end;

destructor TTEstadoCuotasPreveer.Destroy;
begin
  inherited Destroy;
end;

function TTEstadoCuotasPreveer.verificarItemsEnLista(listArray: Array of String; xitems: String): Boolean;
// Objetivo...: Verificar que el codigo exista en el arreglo de Obras Sociales
var
  i: Integer;
begin
  Result := False;
  if Length(Trim(listArray[Low(listArray)])) = 0 then  Result := True else Begin  // Retornamos True si no hay elementos, es decir, se listan todas
    For i := Low(listArray) to High(listArray) do
      if listArray[i] = xitems then Begin
        Result := True;
        Break;
      end;
  end;
end;

function  TTEstadoCuotasPreveer.setAbonados: TQuery;
// Objetivo...: Recuperar y devolver la lista de abonados
Begin
  Result := datosdb.tranSQL('Preveer', 'SELECT Personas.Documento_Tipo, Personas.Apellido, Personas.Nombre, Personas.Domicilio_Calle, Abonados.Codigo FROM Personas, Abonados WHERE (Abonados.Adh_Documento_Nro = Personas.Documento_Nro) ORDER BY Personas.Apellido, Personas.Nombre');
end;

function  TTEstadoCuotasPreveer.setAbonadosNumero: TQuery;
// Objetivo...: Recuperar y devolver la lista de abonados
Begin
  Result := datosdb.tranSQL('Preveer', 'SELECT Personas.Documento_Tipo, Personas.Apellido, Personas.Nombre, Personas.Domicilio_Calle, Abonados.Codigo FROM Personas, Abonados WHERE (Abonados.Adh_Documento_Nro = Personas.Documento_Nro) ORDER BY Codigo');
end;

procedure TTEstadoCuotasPreveer.InformeEstadoCuotas(xfdesde, xfhasta: String; listSel: Array of String; salida: char);
var
  r: TQuery; xidanter, xnombre, xabono, xrealizado, xpromotor, ma: String; xmonto: Real; i: Integer;
  j, x, k: Integer;
Begin
  for j := 1 to 5 do Begin
    totales[j] := 0;
    totpag[j] := 0;
  end;
  ExistenDatos := False;
  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial
  For j := 1 to 12 do Begin
    case mi of
      1: mm[j]  := 'E';
      2: mm[j]  := 'F';
      3: mm[j]  := 'M';
      4: mm[j]  := 'A';
      5: mm[j]  := 'M';
      6: mm[j]  := 'J';
      7: mm[j]  := 'J';
      8: mm[j]  := 'A';
      9: mm[j]  := 'S';
      10: mm[j] := 'O';
      11: mm[j] := 'N';
      12: mm[j] := 'D';
    end;
    Inc(mi);
    if mi > 12 then mi := 1;
  end;

  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial

  list.Setear(salida);
  list.NoImprimirPieDePagina;
  //list.FijarSaltoManual;
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Informe sobre comportamiento abonados entre ' + xfdesde + ' y ' + xfhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  list.Titulo(0, 0, 'Abono', 1, 'Arial, cursiva, 8');
  list.Titulo(7, list.Lineactual, 'Apellido y Nombre', 2, 'Arial, cursiva, 8');
  list.Titulo(37, list.Lineactual, 'Tipo', 3, 'Arial, cursiva, 8');
  list.Titulo(45, list.Lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  list.Titulo(51, list.Lineactual, 'Fecha', 5, 'Arial, cursiva, 8');
  list.Titulo(58, list.Lineactual, 'Promotor', 6, 'Arial, cursiva, 8');
  list.Titulo(76, list.Lineactual, mm[1], 7, 'Arial, cursiva, 8');
  list.Titulo(78, list.Lineactual, mm[2], 8, 'Arial, cursiva, 8');
  list.Titulo(80, list.Lineactual, mm[3], 9, 'Arial, cursiva, 8');
  list.Titulo(82, list.Lineactual, mm[4], 10, 'Arial, cursiva, 8');
  list.Titulo(84, list.Lineactual, mm[5], 11, 'Arial, cursiva, 8');
  list.Titulo(86, list.Lineactual, mm[6], 12, 'Arial, cursiva, 8');
  list.Titulo(88, list.Lineactual, mm[7], 13, 'Arial, cursiva, 8');
  list.Titulo(90, list.Lineactual, mm[8], 14, 'Arial, cursiva, 8');
  list.Titulo(92, list.Lineactual, mm[9], 15, 'Arial, cursiva, 8');
  list.Titulo(94, list.Lineactual, mm[10], 16, 'Arial, cursiva, 8');
  list.Titulo(96, list.Lineactual, mm[11], 17, 'Arial, cursiva, 8');
  list.Titulo(98, list.Lineactual, mm[12], 18, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  For x := Low(listsel) to High(listsel) do Begin
    if length(trim(listsel[x])) > 0 then Begin
    r := datosdb.tranSQL('Preveer', 'SELECT Liquidacion.Abono, Liquidacion.Adh_Nombre, Liquidacion.Anio, Liquidacion.Mes, Liquidacion.Recibo, Liquidacion.Abono, Liquidacion.Importe, Liquidacion.Estado, Liquidacion.Importe, Liquidacion.Promotor, Liquidacion.Abonado ' +
                                  ' FROM Liquidacion WHERE liquidacion.anio >= ' + '''' + Copy(utiles.sExprFecha(xfdesde), 1, 4) + '''' + ' AND liquidacion.anio <= ' + '''' + Copy(utiles.sExprFecha(xfhasta), 1, 4) + '''' +
                                  ' AND liquidacion.Abonado = ' + listsel[x] +
                                  ' ORDER BY Liquidacion.Abonado, liquidacion.Anio, liquidacion.Mes');

    for k := 1 to 12 do rmeses[k] := '';
    r.Open; mes := 0; xmonto := 0; s := '';
    xidanter := r.FieldByName('Abonado').AsString;
    while not r.Eof do Begin
      if (r.FieldByName('anio').AsString + r.FieldByName('mes').AsString >= Copy(utiles.sExprFecha(xfdesde), 1, 4) + Copy(utiles.sExprFecha(xfdesde), 5, 2)) then
        if (r.FieldByName('anio').AsString + r.FieldByName('mes').AsString <= Copy(utiles.sExprFecha(xfhasta), 1, 4) + Copy(utiles.sExprFecha(xfhasta), 5, 2)) then Begin
          if r.FieldByName('Abonado').AsString <> xidanter then Begin
            linea(xidanter, xnombre, xabono, xrealizado, xpromotor, xmonto, mi, listSel, salida);
            xidanter := r.FieldByName('Abonado').AsString;
            mes := 0; s := '';
            For i := 1 to 12 do rmeses[i] := '';
          end;

          if r.FieldByName('anio').AsInteger - StrToInt(Copy(utiles.sExprFecha(xfdesde), 1, 4)) = 0 then mac := 0 else mac := 12;

          if r.FieldByName('mes').AsString <> ma then
            if (r.FieldByName('estado').AsString = 'C') or (r.FieldByName('estado').AsString = 'A') then rmeses[StrToInt(r.FieldByName('mes').AsString)] := 'P';

          xpromotor  := r.FieldByName('Promotor').AsString;
          xabono     := r.FieldByName('Abono').AsString;
          xnombre    := r.FieldByName('Adh_Nombre').AsString;
          xmonto     := r.FieldByName('Importe').AsFloat;
        end;
        ma := r.FieldByName('mes').AsString;
        r.Next;
      end;
      linea(xidanter, xnombre, xabono, xrealizado, xpromotor, xmonto, mi, listSel, salida);
      r.Close; r.Free;
    end;
  end;
  if not ExistenDatos then list.Linea(0, 0, 'No existen datos para listar', 1, 'Arial, normal, 9', salida, 'S') else Begin
    TotPagina(totpag[1], salida);
    TotalesFinales(0, salida);
  end;
  list.FinList;
end;

procedure TTEstadoCuotasPreveer.Linea(xcodigo, xnombre, xabono, xrealizado, xpromotor: String; xmonto: Real; xmi: Integer; listSel: Array of String; salida: Char);
var
  i, j, q: Integer; n, f, apn, abono, doc: String;
  t, lt, ab: TQuery; monto: real;
Begin
  if verificarItemsEnLista(listSel, xcodigo) then Begin
    if (Length(Trim(xpromotor)) > 0) and (Length(Trim(xcodigo)) > 0) then Begin
      t := datosdb.tranSQL('Preveer', 'SELECT Nombre FROM promotores WHERE codigo = ' + xpromotor);
      t.Open;
      n := t.FieldByName('Nombre').AsString;
      t.Close; t.Free;
      t := datosdb.tranSQL('Preveer', 'SELECT Fecha_Alta, Adh_Documento_Nro, abono, estado FROM abonados WHERE codigo = ' + xcodigo);
      t.Open;
      f   := t.FieldByName('Fecha_Alta').AsString;
      abono := t.FieldByName('abono').AsString;
      doc := t.FieldByName('Adh_Documento_Nro').AsString;

      lt := datosdb.tranSQL('Preveer', 'SELECT Apellido, Nombre FROM personas WHERE Documento_Nro = ' + '''' + doc + '''');
      lt.Open;
      apn := lt.FieldByName('Apellido').AsString + ' ' + lt.FieldByName('Nombre').AsString;
      lt.Close; lt.Free;

      ab := datosdb.tranSQL('Preveer', 'SELECT * FROM abonos WHERE codigo = ' + '''' + abono + '''');
      ab.Open;
      monto := ab.FieldByName('parcela').AsFloat + ab.FieldByName('subsidio').AsFloat + ab.FieldByName('servicio').AsFloat + ab.FieldByName('promotor').AsFloat + ab.FieldByName('cobrador').AsFloat;
      ab.Close; ab.Free;

      if t.FieldByName('estado').AsString <> 'D' then Begin    // Si no esta dado de baja
      list.Linea(0, 0, xcodigo, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(7, list.Lineactual, Copy(apn, 1, 35), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(37, list.Lineactual, abono, 3, 'Arial, normal, 8', salida, 'N');
      list.Importe(50, list.Lineactual, '', monto, 4, 'Arial, normal, 8');
      list.Linea(51, list.Lineactual, Copy(f, 1, 6) + Copy(f, 9, 2), 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(58, list.Lineactual, Copy(n, 1, 18), 6, 'Arial, normal, 8', salida, 'N');
      ExistenDatos := True;
      totales[1] := totales[1] + 1;
      totales[2] := totales[2] + monto;
      totpag[1]  := totpag[1]  + monto;

      q := 6; j := 76;
      For i := xmi to 12 do Begin   // Desde el mes inicial hasta fin de año
        Inc(q);
        list.Linea(j, list.Lineactual, rmeses[i], q, 'Arial, normal, 8', salida, 'N');
        j := j + 2;
      end;
      For i := 1 to xmi-1 do Begin   // Desde el mes inicial del año siguiente hasta el principio del primero
        Inc(q);
        list.Linea(j, list.Lineactual, rmeses[i], q, 'Arial, normal, 8', salida, 'N');
        j := j + 2;
      end;

      Inc(q);
      list.Linea(j+3, list.Lineactual, '',q ,'Arial, normal, 8', salida, 'S');

      if list.SaltoPagina then Begin
        TotPagina(totpag[1], salida);
        list.IniciarNuevaPagina;
      end;

    end;
    t.Close; t.Free;
    end;
  end;
end;

procedure TTEstadoCuotasPreveer.TotPagina(xtotpag: real; salida: char);
Begin
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'N');
  list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
  list.Importe(50, list.Lineactual, '',xtotpag , 2, 'Arial, negrita, 8');
  list.Linea(90, list.Lineactual, 'Pág: ' +  utiles.sLlenarIzquierda(IntToStr(list.nroPagina), 4, '0') , 3, 'Arial, normal, 8', salida, 'N');
  totpag[1] := 0;
end;

{-------------------------------------------------------------------------------}

procedure TTEstadoCuotasPreveer.InformeFechasDePago(xfdesde, xfhasta: String; listSel: Array of String; salida: char);
var
  r: TQuery; xidanter, xnombre, xabono, xrealizado, xpromotor, ma: String; xmonto: Real; i, x, k: Integer; l: Boolean;
  j: Integer;
Begin
  For i := 1 to cantitems do totales[i] := 0;
  For i := 1 to cantitems do totmeses[i] := 0;
  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial
  For j := 1 to 12 do Begin
    case mi of
      1: mm[j]  := 'E';
      2: mm[j]  := 'F';
      3: mm[j]  := 'M';
      4: mm[j]  := 'A';
      5: mm[j]  := 'M';
      6: mm[j]  := 'J';
      7: mm[j]  := 'J';
      8: mm[j]  := 'A';
      9: mm[j]  := 'S';
      10: mm[j] := 'O';
      11: mm[j] := 'N';
      12: mm[j] := 'D';
    end;
    Inc(mi);
    if mi > 12 then mi := 1;
  end;
  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial

  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Registración Cobros a Abonados entre ' + xfdesde + ' - ' + xfhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  list.Titulo(0, 0, 'Abono', 1, 'Arial, cursiva, 8');
  list.Titulo(6, list.Lineactual, 'Apellido y Nombre', 2, 'Arial, cursiva, 8');
  list.Titulo(32, list.Lineactual, 'Abono', 3, 'Arial, cursiva, 8');
  list.Titulo(39, list.Lineactual, mm[1], 4,  'Arial, cursiva, 8');
  list.Titulo(44, list.Lineactual, mm[2], 5,  'Arial, cursiva, 8');
  list.Titulo(49, list.Lineactual, mm[3], 6,  'Arial, cursiva, 8');
  list.Titulo(54, list.Lineactual, mm[4], 7,  'Arial, cursiva, 8');
  list.Titulo(59, list.Lineactual, mm[5], 8,  'Arial, cursiva, 8');
  list.Titulo(64, list.Lineactual, mm[6], 9, 'Arial, cursiva, 8');
  list.Titulo(69, list.Lineactual, mm[7], 10, 'Arial, cursiva, 8');
  list.Titulo(74, list.Lineactual, mm[8], 11, 'Arial, cursiva, 8');
  list.Titulo(79, list.Lineactual, mm[9], 12, 'Arial, cursiva, 8');
  list.Titulo(84, list.Lineactual, mm[10], 13, 'Arial, cursiva, 8');
  list.Titulo(89, list.Lineactual, mm[11], 14, 'Arial, cursiva, 8');
  list.Titulo(94, list.Lineactual, mm[12], 15, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  For x := Low(listsel) to High(listsel) do Begin
    if length(trim(listsel[x])) > 0 then Begin
    r := datosdb.tranSQL('Preveer', 'SELECT Liquidacion.Abono, Liquidacion.Adh_Nombre, Liquidacion.Anio, Liquidacion.Mes, Liquidacion.Recibo, Liquidacion.Abono, Liquidacion.Importe, Liquidacion.Estado, Liquidacion.Importe, Liquidacion.Promotor, Liquidacion.Abonado, Liquidacion.Fecha_Caja ' +
                                  ' FROM Liquidacion WHERE liquidacion.anio >= ' + '''' + Copy(utiles.sExprFecha(xfdesde), 1, 4) + '''' + ' AND liquidacion.anio <= ' + '''' + Copy(utiles.sExprFecha(xfhasta), 1, 4) + '''' +
                                  ' AND liquidacion.Abonado = ' + listsel[x] +
                                  ' ORDER BY Liquidacion.Abonado, liquidacion.Anio, liquidacion.Mes');

    for k := 1 to 12 do rmeses[k] := '';
    r.Open; mes := 0; xmonto := 0; s := '';
    xidanter := r.FieldByName('Abonado').AsString;
    while not r.Eof do Begin
      if (r.FieldByName('anio').AsString + r.FieldByName('mes').AsString >= Copy(utiles.sExprFecha(xfdesde), 1, 4) + Copy(utiles.sExprFecha(xfdesde), 5, 2)) then
        if (r.FieldByName('anio').AsString + r.FieldByName('mes').AsString <= Copy(utiles.sExprFecha(xfhasta), 1, 4) + Copy(utiles.sExprFecha(xfhasta), 5, 2)) then Begin
          if r.FieldByName('Abonado').AsString <> xidanter then Begin
            lineaFecha(xidanter, xnombre, xabono, xrealizado, xpromotor, xmonto, mi, listSel, salida);
            xidanter := r.FieldByName('Abonado').AsString;
            mes := 0; s := '';
            For i := 1 to 12 do rmeses[i] := '';
          end;
          if r.FieldByName('mes').AsString <> ma then
            if (r.FieldByName('estado').AsString = 'C') or (r.FieldByName('estado').AsString = 'A') then Begin
              rmeses[StrToInt(r.FieldByName('mes').AsString)]  := Copy(r.FieldByName('Fecha_Caja').AsString, 1, 5);
              //totales[StrToInt(r.FieldByName('mes').AsString)] := totales[StrToInt(r.FieldByName('mes').AsString)] + xmonto;
            end;
          xabono  := r.FieldByName('Abono').AsString;
          xnombre := r.FieldByName('Adh_Nombre').AsString;
          xmonto  := r.FieldByName('Importe').AsFloat;
        end;
        ma := r.FieldByName('mes').AsString;
        r.Next;
      end;
      lineaFecha(xidanter, xnombre, xabono, xrealizado, xpromotor, xmonto, mi, listSel, salida);
      r.Close; r.Free;
    end;
  end;
  if not ExistenDatos then list.Linea(0, 0, 'No existen datos para listar', 1, 'Arial, normal, 9', salida, 'S') else TotalesFinales(mi, salida);
  list.FinList;
end;

procedure TTEstadoCuotasPreveer.LineaFecha(xcodigo, xnombre, xabono, xrealizado, xpromotor: String; xmonto: Real; xmi: Integer; listSel: Array of String; salida: Char);
var
  i, j, q: Integer; f, n, abono, doc, apn: String;
  t, lt, ab: TQuery; monto: real;
Begin
  if (Length(Trim(xcodigo)) > 0) then
   if verificarItemsEnLista(listSel, xcodigo) then Begin
    t := datosdb.tranSQL('Preveer', 'SELECT Fecha_Alta, Adh_Documento_Nro, abono, estado FROM abonados WHERE codigo = ' + xcodigo);
    t.Open;
    f   := t.FieldByName('Fecha_Alta').AsString;
    abono := t.FieldByName('abono').AsString;
    doc := t.FieldByName('Adh_Documento_Nro').AsString;

    lt := datosdb.tranSQL('Preveer', 'SELECT Apellido, Nombre FROM personas WHERE Documento_Nro = ' + '''' + doc + '''');
    lt.Open;
    apn := lt.FieldByName('Apellido').AsString + ' ' + lt.FieldByName('Nombre').AsString;
    lt.Close; lt.Free;

    f := t.FieldByName('Fecha_Alta').AsString;

    ab := datosdb.tranSQL('Preveer', 'SELECT * FROM abonos WHERE codigo = ' + '''' + abono + '''');
    ab.Open;
    monto := ab.FieldByName('parcela').AsFloat + ab.FieldByName('subsidio').AsFloat + ab.FieldByName('servicio').AsFloat + ab.FieldByName('promotor').AsFloat + ab.FieldByName('cobrador').AsFloat;
    ab.Close; ab.Free;

    if t.FieldByName('estado').AsString <> 'D' then Begin    // Si no esta dado de baja
      list.Linea(0, 0, xcodigo, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(6, list.Lineactual, Copy(apn, 1, 26), 2, 'Arial, normal, 8', salida, 'N');
      list.Importe(35, list.Lineactual, '', monto, 3, 'Arial, normal, 8');
      ExistenDatos := True;
      totales[1] := totales[1] + 1;
      totales[2] := totales[2] + monto;

      q := 3; j := 39;
      For i := xmi to 12 do Begin   // Desde el mes inicial hasta fin de año
        Inc(q);
        list.Linea(j, list.Lineactual, rmeses[i], q, 'Arial, normal, 8', salida, 'N');
        if Length(Trim(rmeses[i])) > 0 then totmeses[i] := totmeses[i] + monto;
        j := j + 5;
      end;
      For i := 1 to xmi-1 do Begin   // Desde el mes inicial del año siguiente hasta el principio del primero
        Inc(q);
        list.Linea(j, list.Lineactual, rmeses[i], q, 'Arial, normal, 8', salida, 'N');
        if Length(Trim(rmeses[i])) > 0 then totmeses[i] := totmeses[i] + monto;
        j := j + 5;
      end;

      Inc(q);
      list.Linea(j+3, list.Lineactual, '',q ,'Arial, normal, 8', salida, 'S');
    end;
    t.Close; t.Free;
  end;
end;

procedure TTEstadoCuotasPreveer.TotalesFinales(xmi: Integer; salida: char);
var
  q, j, i, k: Integer;
begin
  k := 0;
  if xmi > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida) , 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, 'Tot.Final Mensual: ', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    q := 1; j := 1;
    For i := xmi to 12 do Begin   // Desde el mes inicial hasta fin de año
      Inc(q); Inc(k);
      list.Linea(j, list.Lineactual, mm[k], q, 'Arial, normal, 8', salida, 'N');
      j := j + 8;
    end;
    For i := 1 to xmi-1 do Begin   // Desde el mes inicial del año siguiente hasta el principio del primero
      Inc(q); Inc(k);
      list.Linea(j, list.Lineactual, mm[k], q, 'Arial, normal, 8', salida, 'N');
      j := j + 8;
    end;
    Inc(q);
    list.Linea(j+3, list.Lineactual, '',q ,'Arial, normal, 8', salida, 'S');

    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    q := 1; j := 1;
    For i := xmi to 12 do Begin   // Desde el mes inicial hasta fin de año
      Inc(q); Inc(k);
      list.Linea(j, list.Lineactual, utiles.FormatearNumero(FloatToStr(totmeses[i])), q, 'Arial, normal, 8', salida, 'N');
      j := j + 8;
    end;
    For i := 1 to xmi-1 do Begin   // Desde el mes inicial del año siguiente hasta el principio del primero
      Inc(q); Inc(k);
      list.Linea(j, list.Lineactual, utiles.FormatearNumero(FloatToStr(totmeses[i])), q, 'Arial, normal, 8', salida, 'N');
      j := j + 8;
    end;
  end;

  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Cantidad de Abonos:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(50, list.Lineactual, '####', totales[1], 2, 'Arial, negrita, 9');
  list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, 'Total Cobrado por Abonos:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(50, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
  list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
end;

{-------------------------------------------------------------------------------}

procedure TTEstadoCuotasPreveer.InformeAbonadosPlan(listSel: Array of String; salida: Char);
// Objetivo...: Listar Abonados por Plan
var
  r: TQuery; idanter: String;
Begin
  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Listado de Abonados por Plan', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Cód.', 1, 'Arial, cursiva, 8');
  list.Titulo(8, list.Lineactual, 'Documento', 2, 'Arial, cursiva, 8');
  list.Titulo(20, list.Lineactual, 'Adherente', 3, 'Arial, cursiva, 8');
  list.Titulo(55, list.Lineactual, 'Dirección', 4, 'Arial, cursiva, 8');
  list.Titulo(85, list.Lineactual, 'F.Nacimiento', 5, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  r := datosdb.tranSQL('Preveer', 'SELECT Abonos.Codigo, Abonos.Nombre, Abonados.Codigo, Abonados.Adh_Documento_Tipo, Abonados.Adh_Documento_Nro, Personas.Apellido, Personas.Nombre, Personas.Domicilio_Calle, Personas.Domicilio_Puerta, Personas.Domicilio_Piso, Personas.Barrio, ' +
                       'Personas.Fecha_Nacimiento FROM Abonos, Abonados, Personas WHERE Abonos.Codigo = Abonados.Abono AND Abonados.Adh_Documento_Tipo = Personas.Documento_Tipo AND Abonados.Adh_Documento_Nro = Personas.Documento_Nro AND Abonados.Estado = ' + '''' + 'V' + '''' +
                       ' ORDER BY Abonos.Codigo, Abonados.Codigo');
  r.Open;
  while not r.Eof do Begin
   if utiles.verificarItemsEnLista(listSel, r.FieldByName('codigo').AsString) then Begin
    if r.FieldByName('codigo').AsString <> idanter then Begin
      if Length(Trim(idanter)) > 0 then list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, r.FieldByName('codigo').AsString + '    ' + r.FieldByName('nombre').AsString, 1, 'Arial, negrita, 12', salida, 'S');
      idanter := r.FieldByName('codigo').AsString;
    end;
    list.Linea(0, 0, r.Fields[2].AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(8, list.Lineactual, r.FieldByName('Adh_documento_tipo').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(11, list.Lineactual, r.FieldByName('Adh_documento_nro').AsString, 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(20, list.Lineactual, r.FieldByName('Apellido').AsString + ', ' + r.Fields[6].AsString, 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(55, list.Lineactual, r.FieldByName('domicilio_calle').AsString + '  ' + r.FieldByName('domicilio_puerta').AsString + '  ' + r.FieldByName('domicilio_piso').AsString, 5, 'Arial, normal, 8', salida, 'N');
    list.Linea(85, list.Lineactual, r.FieldByName('fecha_nacimiento').AsString, 6, 'Arial, normal, 8', salida, 'S');
   end;
   r.Next;
  end;

  if Length(Trim(idanter)) > 0 then list.FinList else utiles.msgError('No Existen Datos para Listar ...!');

end;

function  TTEstadoCuotasPreveer.setAbonos: TQuery;
// Objetivo...: Devolver nomina de abonos
Begin
  Result := datosdb.tranSQL('Preveer', 'SELECT * FROM abonos ORDER BY codigo');
end;

procedure TTEstadoCuotasPreveer.conectar;
begin
  Inc(conexiones);
  if conexiones = 0 then DB.Open;
end;

procedure TTEstadoCuotasPreveer.desconectar;
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then DB.Close;
end;

{===============================================================================}

function estadocuotas: TTEstadoCuotasPreveer;
begin
  if xestadocuotas = nil then
    xestadocuotas := TTEstadoCuotasPreveer.Create;
  Result := xestadocuotas;
end;

{===============================================================================}

initialization

finalization
  xestadocuotas.Free;

end.
