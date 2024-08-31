unit CRecibosAsociacion;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTRecibosAdr = class
  LineasSep, LineasDet, LineaDiv, Modelo, FechaCobro, CCodprest, CExpediente, MargenSup, MargenIzq, Anulado: String;
  Efectivo, Cheques: Real;
  recibos_detalle, distribucioncobros, cheques_mov, formato_impresion: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  { Gestión de Cobros }
  function    BuscarCobro(xsucursal, xnumero: String): Boolean;
  procedure   RegistrarCobro(xsucursal, xnumero, xexpediente, xfecha: String; xefectivo, xcheque: Real);
  procedure   getDatosCobro(xsucursal, xnumero: String);
  procedure   BorrarCobro(xsucursal, xnumero: String);

  { Gestión de Recibos de Pago }
  function    BuscarReciboCobro(xsucursal, xnumero, xitems: String): Boolean;
  procedure   RegistrarRecibo(xsucursal, xnumero, xitems, xconcepto, xidc, xtipo, xsucrec, xnumrec, xfecha, xmodo: String; xmonto: Real; xcantitems: Integer);
  function    setRecibosPago(xsucursal, xnumero: String): TQuery;
  function    BuscarReciboPorNumeroImpresion(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   AnularReciboPago(xidc, xtipo, xsucursal, xnumero, xanular: String);
  procedure   ImprimirRecibo(xsucursal, xnumero, xnombre, xdireccion, xlocalidad, xcodpost, xcuit, xcodpfis, xcategoria, xlinea: String; salida: char);

  { Registración de Cheques }
  procedure   RegistrarCheque(xsucursal, xnumero, xitems, xnrocheque, xfecha, xcodbanco, xfilial: String; xmonto: real; xcantitems: Integer);
  function    setCheques(xsucursal, xnumero: String): TQuery;

  { Formato de Impresión }
  procedure   getFormatoImpresion;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  totales: array[1..5] of Real;
  idanter: array[1..2] of String;
end;

function recibo: TTRecibosAdr;

implementation

var
  xrecibo: TTRecibosAdr = nil;

constructor TTRecibosAdr.Create;
begin
  distribucioncobros := datosdb.openDB('distribucioncobros', '');
  recibos_detalle    := datosdb.openDB('recibos_detalle', '');
  cheques_mov        := datosdb.openDB('cheques_mov', '');
  formato_Impresion  := datosdb.openDB('formatoImpresion', '');
end;

destructor TTRecibosAdr.Destroy;
begin
  inherited Destroy;
end;

function    TTRecibosAdr.BuscarCobro(xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar un cobro
Begin
  Result := datosdb.Buscar(distribucioncobros, 'sucursal', 'numero', xsucursal, xnumero);
end;

procedure   TTRecibosAdr.RegistrarCobro(xsucursal, xnumero, xexpediente, xfecha: String; xefectivo, xcheque: Real);
// Objetivo...: Registrar Cobros
Begin
  if BuscarCobro(xsucursal, xnumero) then distribucioncobros.Edit else distribucioncobros.Append;
  distribucioncobros.FieldByName('sucursal').AsString   := xsucursal;
  distribucioncobros.FieldByName('numero').AsString     := xnumero;
  if Length(Trim(xfecha)) = 8       then distribucioncobros.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  distribucioncobros.FieldByName('expediente').AsString := xexpediente;
  distribucioncobros.FieldByName('efectivo').AsFloat    := xefectivo;
  distribucioncobros.FieldByName('cheques').AsFloat     := xcheque;
  try
    distribucioncobros.Post
   except
    distribucioncobros.Cancel
  end;
  datosdb.closeDB(distribucioncobros); distribucioncobros.Open;
end;

procedure   TTRecibosAdr.getDatosCobro(xsucursal, xnumero: String);
// Objetivo...: Recuperar los datos de un cobro
Begin
  if BuscarCobro(xsucursal, xnumero) then Begin
    efectivo    := distribucioncobros.FieldByName('efectivo').AsFloat;
    cheques     := distribucioncobros.FieldByName('cheques').AsFloat;
    ccodprest   := Copy(distribucioncobros.FieldByName('expediente').AsString, 1, 5);
    cexpediente := Copy(distribucioncobros.FieldByName('expediente').AsString, 7, 4);
    Fechacobro  := utiles.sFormatoFecha(distribucioncobros.FieldByName('fecha').AsString);
  end else Begin
    ccodprest := ''; cexpediente := ''; fechaCobro := '';
    efectivo := 0; cheques := 0;
  end;
end;

procedure   TTRecibosAdr.BorrarCobro(xsucursal, xnumero: String);
// Objetivo...: Borrar un cobro
Begin
  if BuscarCobro(xsucursal, xnumero) then Begin
    // Borramos si el recibo No Fue Impreso
    if BuscarReciboCobro(xsucursal, xnumero, '01') then
      if recibos_detalle.FieldByName('impreso').AsString <> 'S' then Begin
        // Borramos los registros vinculados
        datosdb.tranSQL('delete from recibos_detalle where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"');
        datosdb.closeDB(recibos_detalle); recibos_detalle.Open;
        datosdb.tranSQL('delete from cheques_mov where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"');
        datosdb.refrescar(cheques_mov);
        datosdb.closeDB(cheques_mov); cheques_mov.Open;
        distribucioncobros.Delete;
        datosdb.closeDB(distribucioncobros); distribucioncobros.Open;
      end;
  end;
end;

function TTRecibosAdr.BuscarReciboCobro(xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: registrar recibos de pago
Begin
  Result := datosdb.Buscar(recibos_detalle, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems);
end;

procedure TTRecibosAdr.RegistrarRecibo(xsucursal, xnumero, xitems, xconcepto, xidc, xtipo, xsucrec, xnumrec, xfecha, xmodo: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: registrar recibos de pago
Begin
  if BuscarReciboCobro(xsucursal, xnumero, xitems) then recibos_detalle.Edit else recibos_detalle.Append;
  recibos_detalle.FieldByName('sucursal').AsString := xsucursal;
  recibos_detalle.FieldByName('numero').AsString   := xnumero;
  recibos_detalle.FieldByName('items').AsString    := xitems;
  recibos_detalle.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  recibos_detalle.FieldByName('concepto').AsString := xconcepto;
  recibos_detalle.FieldByName('idc').AsString      := xidc;
  recibos_detalle.FieldByName('tipo').AsString     := xtipo;
  recibos_detalle.FieldByName('sucrec').AsString   := xsucrec;
  recibos_detalle.FieldByName('numrec').AsString   := xnumrec;
  recibos_detalle.FieldByName('modo').AsString     := xmodo;
  recibos_detalle.FieldByName('monto').AsFloat     := xmonto;
  try
    recibos_detalle.Post
   except
    recibos_detalle.Cancel
  end;
  if utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') = xitems then Begin
    datosdb.tranSQL('delete from recibos_detalle where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') + '"');
    datosdb.closeDB(recibos_detalle); recibos_detalle.Open;
  end;
end;

function  TTRecibosAdr.setRecibosPago(xsucursal, xnumero: String): TQuery;
// Objetivo...: Recuperar recibos de pago
Begin
  Result := datosdb.tranSQL('select * from recibos_detalle where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' order by items');
end;

function  TTRecibosAdr.BuscarReciboPorNumeroImpresion(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar Recibo de Pago
Begin
  Anulado := '';
  recibos_detalle.IndexFieldNames := 'Idc;tipo;sucrec;numrec';
  if datosdb.Buscar(recibos_detalle, 'Idc' , 'Tipo', 'Sucrec', 'Numrec', xidc, xtipo, xsucursal, xnumero) then Begin
    Anulado := recibos_detalle.FieldByName('anulado').AsString;
    Result  := True;
  end else Result := False;
  recibos_detalle.IndexFieldNames := 'Sucursal;Numero;Items';
end;

procedure TTRecibosAdr.AnularReciboPago(xidc, xtipo, xsucursal, xnumero, xanular: String);
// Objetivo...: Anular/Activar Recibo
Begin
  datosdb.tranSQL('update recibos_detalle set anulado = ' + '"' + xanular + '"' + ' where idc = ' + '"' + xidc + '"' + ' and tipo = ' + '"' + xtipo + '"' + ' and sucrec = ' + '"' + xsucursal + '"' + ' and numrec = ' + '"' + xnumero + '"');
end;

procedure TTRecibosAdr.ImprimirRecibo(xsucursal, xnumero, xnombre, xdireccion, xlocalidad, xcodpost, xcuit, xcodpfis, xcategoria, xlinea: String; salida: char);
// Objetivo...: Imprimir Recibo de Pago
const
  espacios = 34;
var
  i, j, k, l, esp: Integer;
  hc: Boolean;
Begin
  getFormatoImpresion;
  if salida = 'I' then list.ImprimirHorizontal;
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  getDatosCobro(xsucursal, xnumero);
  //prestatario.getDatos(ccodprest);
  totales[1] := Efectivo + Cheques;
  if Length(Trim(margenIzq)) = 0 then margenIzq := '0';
  esp := espacios + StrToInt(margenIzq);

  for i := 1 to strtoint(margensup) do list.Linea(0, 0, '     ', 1, 'Arial, normal, 8', salida, 'S');

  {if credito_historico then categoria.getDatos(Idcredito);
  getDatos(ccodprest, cexpediente);
  if not credito_historico then categoria.getDatos(Idcredito);
  if Length(Trim(idcredito)) = 0 then Begin
    verificarSiExisteExpedienteHistorico(ccodprest, cexpediente);
    categoria.getDatos(Idcredito);
  end;}

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(63, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + Fechacobro, 2, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 60, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + Fechacobro, 3, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '        ' + utiles.espacios(StrToInt(margenIzq)) + xcategoria + ' - ' + xlinea, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, '        ' + utiles.espacios(StrToInt(margenIzq)) + xcategoria + ' - ' + xlinea, 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '     ', 1, 'Arial, normal, 20', salida, 'S');
  list.Linea(0, 0, '     ', 1, 'Arial, normal, 18', salida, 'S');

  list.Linea(0, 0, utiles.espacios(esp + 5) + xnombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + xnombre, 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp + 5) + xdireccion, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + xdireccion, 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp + 5) + xlocalidad, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(60, list.lineactual, utiles.espacios(StrToInt(margenIzq)) + xcodpost, 2, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + xlocalidad, 3, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 60, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + xcodpost, 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  if Length(Trim(xcuit)) = 13 then list.Linea(0, 0, utiles.espacios(esp + 5) + xcuit, 1, 'Arial, normal, 9', salida, 'N') else list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(45, list.lineactual, xCodpfis, 2, 'Arial, normal, 9', salida, 'N');
  if Length(Trim(xcuit)) = 13 then list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + xcuit, 3, 'Arial, normal, 9', salida, 'N') else list.Linea(StrToInt(lineadiv), list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 45, list.Lineactual, xcodpfis, 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');


  list.Linea(0, 0, utiles.espacios(esp - 18) + 'Recibí(mos) la suma de Pesos:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 18) + 'Recibí(mos) la suma de Pesos:', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp - 17) + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[1])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[1])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 1, 2) + ' ctvos.', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 17) + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[1])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[1])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 1, 2) + ' ctvos.', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp - 18) + 'En Concepto de:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 18) + 'En Concepto de:', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  BuscarReciboCobro(xsucursal, xnumero, '01');
  idanter[1] := recibos_detalle.FieldByName('sucursal').AsString;
  idanter[2] := recibos_detalle.FieldByName('numero').AsString;
  l := 0; totales[1] := 0;
  while not recibos_detalle.Eof do Begin  // Detalle de Cobros
    if (recibos_detalle.FieldByName('sucursal').AsString <> idanter[1]) or (recibos_detalle.FieldByName('numero').AsString <> idanter[2]) then Break;
    list.Linea(0, 0, utiles.espacios(esp - 17) + recibos_detalle.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(65, list.Lineactual, '', recibos_detalle.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
    list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 17) + recibos_detalle.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'S');
    list.importe(StrToInt(lineadiv) + 65, list.Lineactual, '', recibos_detalle.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(StrToInt(lineadiv) + 66, list.Lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
    Inc(l);
    idanter[1] := recibos_detalle.FieldByName('sucursal').AsString;
    idanter[2] := recibos_detalle.FieldByName('numero').AsString;
    totales[1] := totales[1] + recibos_detalle.FieldByName('monto').AsFloat;
    recibos_detalle.Next;
  end;

  getDatosCobro(xsucursal, xnumero);      // Efectivo
  tcuotas[1, 1] := utiles.espacios(esp - 7) + 'En Efectivo';
  tcuotas[1, 3] := utiles.FormatearNumero(FloatToStr(efectivo));

   hc := False;
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, '01') then Begin
    idanter[1] := cheques_mov.FieldByName('sucursal').AsString;
    idanter[2] := cheques_mov.FieldByName('numero').AsString;
    i := 1;
    while not cheques_mov.Eof do Begin  // Detalle de Cheques
      if (cheques_mov.FieldByName('sucursal').AsString <> idanter[1]) or (cheques_mov.FieldByName('numero').AsString <> idanter[2]) then Break;
      entbcos.getDatos(cheques_mov.FieldByName('codbanco').AsString);
      Inc(i);
      tcuotas[i, 1] := cheques_mov.FieldByName('nrocheque').AsString;
      tcuotas[i, 2] := entbcos.descrip;
      tcuotas[i, 3] := cheques_mov.FieldByName('monto').AsString;

      idanter[1] := cheques_mov.FieldByName('sucursal').AsString;
      idanter[2] := cheques_mov.FieldByName('numero').AsString;
      cheques_mov.Next;
    end;
    hc := True;
  end;

  k := StrToInt(lineasdet) - l;
  for j := 1 to k - (i+1) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');  // Lineas entre comprobantes y Efectivo

  for j := 1 to i do Begin
    if j = 1 then Begin
      list.Linea(0, 0, utiles.espacios(esp - 7) + 'En Efectivo:', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(25 + ((esp - 7) div 2), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 2, 'Arial, normal, 8');
      list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 7) + 'En Efectivo:', 3, 'Arial, normal, 8', salida, 'N');
      list.importe(StrToInt(lineadiv) + 25 + ((esp - 7) div 2), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 4, 'Arial, normal, 8');
      list.Linea(StrToInt(lineadiv) + 50 + ((esp - 7) div 2), list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    end else Begin
      if hc then Begin
        if j = 2 then list.Linea(0, 0, utiles.espacios(esp - 7) + 'En Cheques:', 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(20 + ((esp - 7) div 3), list.Lineactual,tcuotas[j, 1], 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(30 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 2], 3, 'Arial, normal, 8', salida, 'N');
        list.importe(67 + ((esp - 7) div 3), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 4, 'Arial, normal, 8');

        if j = 2 then list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 7) + 'En Cheques:', 5, 'Arial, normal, 8', salida, 'N') else list.Linea(StrToInt(lineadiv), list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'N');
        list.Linea(StrToInt(lineadiv) + 20 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 1], 6, 'Arial, normal, 8', salida, 'N');
        list.Linea(StrToInt(lineadiv) + 30 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 2], 7, 'Arial, normal, 8', salida, 'N');
        list.importe(StrToInt(lineadiv) + 67 + ((esp - 7) div 3), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 8, 'Arial, normal, 8');
        list.Linea(StrToInt(lineadiv) + 67 + ((esp - 7) div 3), list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
      end else Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      end;
    end;
  end;

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 20', salida, 'S');
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 20', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(34, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 11');
  list.Linea(StrToInt(lineadiv), list.Lineactual, '  ', 3, 'Arial, negrita, 11', salida, 'N');
  list.importe(StrToInt(lineadiv) + 34, list.Lineactual, '', totales[1], 5, 'Arial, negrita, 11');

  credito_historico := False;

  list.FinList;

  if salida = 'I' then Begin
    list.ImprimirVetical;  // Normalizamos Impesión
    // Marcamos el Recibo como Impreso
    datosdb.tranSQL('update recibos_detalle set impreso = ' + '''' + 'S' + '''' + ' where sucursal = ' + '''' +  xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
    datosdb.refrescar(recibos_detalle);
  end;
end;

procedure TTRecibosAdr.ListarControlRecibos(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Control de Recibos
var
  r: TQuery;
  f: Byte;
Begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Control de Ingresos por Cobro de Recibos - Período: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  List.Titulo(1, list.Lineactual, 'Nº de Recibo', 2, 'Arial, cursiva, 8');
  List.Titulo(20, list.Lineactual, 'Expediente      Prestatario', 3, 'Arial, cursiva, 8');
  List.Titulo(74, list.Lineactual, 'Efectivo', 4, 'Arial, cursiva, 8');
  List.Titulo(88, list.Lineactual, 'Cheques', 5, 'Arial, cursiva, 8');
  List.Titulo(96, list.Lineactual, 'An.', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  IniciarArreglos;

  rsql := datosdb.tranSQL('select distinct * from recibos_detalle where fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by idc, tipo, sucrec, numrec');
  rsql.Open; idanter[1] := 'N';
  while not rsql.Eof do Begin
    if rsql.FieldByName('idc').AsString + rsql.FieldByName('tipo').AsString + rsql.FieldByName('sucrec').AsString + rsql.FieldByName('numrec').AsString <> idanter[2] then Begin
      BuscarCobro(rsql.FieldByName('sucursal').AsString, rsql.FieldByName('numero').AsString);
      prestatario.getDatos(Copy(distribucioncobros.FieldByName('expediente').AsString, 1, 5));
      list.Linea(0, 0, rsql.FieldByName('idc').AsString + '  ' + rsql.FieldByName('tipo').AsString + '  ' + rsql.FieldByName('sucrec').AsString + '  ' + rsql.FieldByName('numrec').AsString, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(20, list.Lineactual, distribucioncobros.FieldByName('expediente').AsString + '  ' + Copy(prestatario.nombre, 1, 30), 2, 'Arial, normal, 9', salida, 'N');
      list.importe(80, list.Lineactual, '', distribucioncobros.FieldByname('efectivo').AsFloat, 3, 'Arial, normal, 9');
      list.importe(95, list.Lineactual, '', distribucioncobros.FieldByname('cheques').AsFloat, 4, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');
      r := datosdb.tranSQL('select * from cheques_mov where sucursal = ' + '"' + rsql.FieldByName('sucursal').AsString + '"' + ' and numero = ' + '"' + rsql.FieldByName('numero').AsString + '"');
      r.Open; f := 0;
      while not r.Eof do Begin
        if f = 0 then list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        f := 1;
        list.Linea(0, 0, '     ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(12, list.Lineactual, r.FieldByName('nrocheque').AsString, 2, 'Arial, normal, 8', salida, 'N');
        entbcos.getDatos(r.FieldByName('codbanco').AsString);
        list.Linea(22, list.Lineactual, entbcos.descrip, 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, r.FieldByName('filial').AsString, 4, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', r.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
        list.Linea(96, list.Lineactual, rsql.FieldByName('anulado').AsString, 6, 'Arial, normal, 8', salida, 'N');
        r.Next;
      end;
      r.Close; r.Free;

      if Length(Trim(rsql.FieldByName('anulado').AsString)) = 0 then Begin
        totales[1] := totales[1] + distribucioncobros.FieldByname('efectivo').AsFloat;
        totales[2] := totales[2] + distribucioncobros.FieldByname('cheques').AsFloat;
      end;
      idanter[1] := 'S';

      list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');
      idanter[2] := rsql.FieldByName('idc').AsString + rsql.FieldByName('tipo').AsString + rsql.FieldByName('sucrec').AsString + rsql.FieldByName('numrec').AsString;
    end;

    rsql.Next;
  end;
  rsql.Close; rsql := Nil;

  if totales[1] + totales[2] > 0 then Begin
    list.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
  end;

  if idanter[1] = 'N' then list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 10', salida, 'S');

  list.FinList;
end;

procedure TTRecibosAdr.RegistrarCheque(xsucursal, xnumero, xitems, xnrocheque, xfecha, xcodbanco, xfilial: String; xmonto: real; xcantitems: Integer);
// Objetivo...: registrar cheques
Begin
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems) then cheques_mov.Edit else cheques_mov.Append;
  cheques_mov.FieldByName('sucursal').AsString  := xsucursal;
  cheques_mov.FieldByName('numero').AsString    := xnumero;
  cheques_mov.FieldByName('items').AsString     := xitems;
  cheques_mov.FieldByName('nrocheque').AsString := xnrocheque;
  cheques_mov.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  cheques_mov.FieldByName('codbanco').AsString  := xcodbanco;
  cheques_mov.FieldByName('filial').AsString    := xfilial;
  cheques_mov.FieldByName('monto').AsFloat      := xmonto;
  try
    cheques_mov.Post
   except
    cheques_mov.Cancel
  end;
  if utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') = xitems then datosdb.tranSQL('delete from cheques_mov where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') + '"');
end;

function  TTRecibosAdr.setCheques(xsucursal, xnumero: String): TQuery;
// Objetivo...: Devolver set de cheques
Begin
  Result := datosdb.tranSQL('select * from cheques_mov where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' order by items');
end;

procedure TTRecibosAdr.RegistrarFormatoImpresion(xlineassep, xlineasdet, xlineaDiv, xmargenSup, xmargenIzq, xmodelo: String);
// Objetivo...: Registrar Modelo de Impresión
Begin
  if formato_impresion.FindKey(['REC001']) then formato_impresion.Edit else formato_impresion.Append;
  formato_impresion.FieldByName('id').AsString         := 'REC001';
  formato_impresion.FieldByName('formato').AsString    := xmodelo;
  formato_impresion.FieldByName('lineassep').AsInteger := StrToInt(Trim(xlineassep));
  formato_impresion.FieldByName('lineasdet').AsInteger := StrToInt(Trim(xlineasdet));
  formato_impresion.FieldByName('lineadiv').AsInteger  := StrToInt(Trim(xlineadiv));
  formato_impresion.FieldByName('margenIzq').AsInteger := StrToInt(Trim(xmargenIzq));
  formato_impresion.FieldByName('margensup').AsInteger := StrToInt(Trim(xmargensup));
  try
    formato_impresion.Post
   except
    formato_impresion.Cancel
  end;
  datosdb.closeDB(formato_impresion);
end;

procedure TTRecibosAdr.getFormatoImpresion;
// Objetivo...: Recuperar Modelo de Impresión
Begin
  if formato_impresion.FindKey(['REC001']) then Begin
    lineassep := formato_impresion.FieldByName('lineassep').AsString;
    lineasdet := formato_impresion.FieldByName('lineasdet').AsString;
    lineadiv  := formato_impresion.FieldByName('lineadiv').AsString;
    modelo    := formato_impresion.FieldByName('formato').AsString;
    margenSup := formato_impresion.FieldByName('margensup').AsString;
    margenIzq := formato_impresion.FieldByName('margenizq').AsString;
  end else Begin
    lineassep := '0'; lineasdet := '0'; modelo := ''; lineadiv := '95'; margensup := '8'; margenizq := '0';
  end;
  if lineadiv  = '' then lineadiv  := '95';
  if lineassep = '' then lineassep := '20';
end;

procedure TTRecibosAdr.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
  end;
  Inc(conexiones);
end;

procedure TTRecibosAdr.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
  end;
end;

{===============================================================================}

function recibo: TTRecibosAdr;
begin
  if xrecibo = nil then
    xrecibo := TTRecibosAdr.Create;
  Result := xrecibo;
end;

{===============================================================================}

initialization

finalization
  xrecibo.Free;

end.
