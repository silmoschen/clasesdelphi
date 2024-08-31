unit CRegMovvariosADR;

interface

uses CClientesVariosADR, CBancos, CBDT, SysUtils, DBTables, CMunicipios_Asociacion,
     CUtiles, CListar, Classes, CIDBFM, CLogSeg, CUsuario, CCodPost, CServers2000_Excel;

type

TTMovvarios = class
  Efectivo, Cheques: Real;
  Nrosol, Codprov, Fechaotor, Acta, Observac: String; Monto, MontoRec, Pagare: Real;
  Existe, Cancelado, Judiciales, Refinanciados: Boolean;
  tmov, dist, movch, cabrecupro: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnrosol, xitems: String): Boolean;
  procedure   Registrar(xfecha, xitems, xnrosol, xcomprobante, xconcepto, xcodprov: String; xmonto: Real; xcantitems: Integer);
  function    setItems: TStringList; overload;
  function    setItems(xnrosol: String): TStringList; overload;
  function    setItemsCliente(xcodcli: String): TStringList;
  procedure   Borrar(xnrosol, xitems: String);

  function    BuscarDist(xnrosol, xitems: String): Boolean;
  procedure   RegistrarDist(xnrosol, xitems: String; xefectivo, xcheque: Real);
  procedure   BorrarDist(xnrosol, xitems: String);
  procedure   getDatosDist(xnrosol, xitems: String);

  function    BuscarCheque(xnrosol, xitems, xsubitems: String): Boolean;
  procedure   RegistrarCheque(xnrosol, xitems, xsubitems, xnrocheque, xcodbanco, xsucursal, xfecha: String; xmonto: Real; xcantitems: Integer);
  procedure   BorrarCheque(xnrosol, xitems: String);
  function    setCheques(xnrosol, xitems: String): TStringList;

  function    BuscarNroSolicitud(xnrosol: String): Boolean;

  procedure   InfDetalleOperaciones(xdesde, xhasta: String; xlocalidades: TStringList; salida: char);

  function    BuscarRecupro(xnrosol: String): Boolean;
  procedure   RegistrarRecupro(xnrosol, xcodprov, xfecha, xacta, xobservacion: String; xpagare, xmonto: Real);
  procedure   BorrarRecupro(xnrosol: String);
  procedure   EstadoCancelado(xnrosol: String; xestado: Boolean);
  procedure   EstadoJudiciales(xnrosol: String; xestado: Boolean);
  procedure   EstadoRefinanciado(xnrosol: String; xestado: Boolean);

  procedure   getDatosRecupro(xnrosol: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  idanter, l1: String;
  totales: array[1..10] of Real;
  detalle1: array[1..100, 1..10] of String;
  detalle2: array[1..100, 1..10] of String;
  conexiones, vc: shortint;
  filas1, filas2, c1: Integer;
  procedure   SubtotalDetalle(salida: char);
  procedure   ListTotalRecupro(salida: char);
  procedure   ListTotalLocalidad(salida: char);
  procedure   IniciarArreglos;
  procedure   ListLineaRecupro(salida: char);
  procedure   VerificarCancelaciones;
end;

function movvarios: TTMovvarios;

implementation

var
  xmovvarios: TTMovvarios = nil;

constructor TTMovvarios.Create;
begin
  tmov       := datosdb.openDB('movivarios', '');
  dist       := datosdb.openDB('distmovivarios', '');
  movch      := datosdb.openDB('cheques_movvarios', '');
  cabrecupro := datosdb.openDB('cabrecupro', '');
end;

destructor TTMovvarios.Destroy;
begin
  inherited Destroy;
end;

function  TTMovvarios.Buscar(xnrosol, xitems: String): Boolean;
// Objetivo...: Buscar Items
begin
  if tmov.IndexFieldNames <> 'Nrosol;Items' then tmov.IndexFieldNames := 'Nrosol;Items';
  Existe := datosdb.Buscar(tmov, 'nrosol', 'items', xnrosol, xitems);
  Result := Existe;
end;

procedure TTMovvarios.Registrar(xfecha, xitems, xnrosol, xcomprobante, xconcepto, xcodprov: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Registrar datos de persistencia
begin
  if Buscar(xnrosol, xitems) then tmov.Edit else tmov.Append;
  tmov.FieldByName('nrosol').AsString      := xnrosol;
  tmov.FieldByName('items').AsString       := xitems;
  tmov.FieldByName('comprobante').AsString := xcomprobante;
  tmov.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  tmov.FieldByName('concepto').AsString    := xconcepto;
  tmov.FieldByName('codprov').AsString     := xcodprov;
  tmov.FieldByName('monto').AsFloat        := xmonto;
  try
    tmov.Post
   except
    tmov.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from movivarios where nrosol = ' + '''' + xnrosol + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(tmov); tmov.Open;
  end;
  logsist.RegistrarLog(usuario.usuario, 'Ingresos Varios', 'Registrando Operación ' + xfecha + ' ' + xitems);
end;

function TTMovvarios.setItems(xnrosol: String): TStringList;
// Objetivo...: devolver items
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(tmov, 'nrosol = ' + '''' + xnrosol + '''');
  while not tmov.Eof do Begin
    l.Add(utiles.sFormatoFecha(tmov.FieldByName('fecha').AsString) + tmov.FieldByName('items').AsString + tmov.FieldByName('codprov').AsString + tmov.FieldByName('comprobante').AsString + ';1' + tmov.FieldByName('concepto').AsString + ';2' + utiles.FormatearNumero(tmov.FieldByName('monto').AsString));
    tmov.Next;
  end;
  datosdb.QuitarFiltro(tmov);
  Result := l;
end;

function TTMovvarios.setItemsCliente(xcodcli: String): TStringList;
// Objetivo...: devolver items del cliente
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(cabrecupro, 'codprov = ' + '''' + xcodcli + '''');
  while not cabrecupro.Eof do Begin
    l.Add(cabrecupro.FieldByName('nrosol').AsString + utiles.sFormatoFecha(cabrecupro.FieldByName('fecha').AsString) + cabrecupro.FieldByName('observacion').AsString);
    cabrecupro.Next;
  end;
  datosdb.QuitarFiltro(cabrecupro);
  Result := l;
end;

procedure TTMovvarios.Borrar(xnrosol, xitems: String);
// Objetivo...: Borrar datos de persistencia
begin
  if Buscar(xnrosol, xitems) then Begin
    BorrarDist(xnrosol, xitems);
    BorrarCheque(xnrosol, xitems);
    tmov.Delete;
    datosdb.closeDB(tmov); tmov.Open;
    logsist.RegistrarLog(usuario.usuario, 'Ingresos Varios', 'Borrando Movimiento ' + xnrosol + ' ' + xitems);
  end;
end;

function  TTMovvarios.BuscarDist(xnrosol, xitems: String): Boolean;
// Objetivo...: buscar distribuciones
begin
  Result := datosdb.Buscar(dist, 'nrosol', 'items', xnrosol, xitems);
end;

procedure TTMovvarios.RegistrarDist(xnrosol, xitems: String; xefectivo, xcheque: Real);
// Objetivo...: registrar distribuciones
begin
  if BuscarDist(xnrosol, xitems) then dist.Edit else dist.Append;
  dist.FieldByName('nrosol').AsString  := xnrosol;
  dist.FieldByName('items').AsString   := xitems;
  dist.FieldByName('efectivo').AsFloat := xefectivo;
  dist.FieldByName('cheque').AsFloat   := xcheque;
  try
    dist.Post
   except
    dist.Cancel
  end;
  datosdb.closeDB(dist); dist.Open;

  if Existe then  // Verificamos si se cambia el pago a Efectivo
    if xcheque = 0 then BorrarCheque(xnrosol, xitems);
  logsist.RegistrarLog(usuario.usuario, 'Ingresos Varios', 'Registrando Distribución ' + xnrosol + ' ' + xitems);
end;

procedure TTMovvarios.BorrarDist(xnrosol, xitems: String);
// Objetivo...: borrar distribuciones
begin
  if BuscarDist(xnrosol, xitems) then dist.Delete;
  datosdb.closeDB(dist); dist.Open;
  logsist.RegistrarLog(usuario.usuario, 'Ingresos Varios', 'Borrando Distribución ' + xnrosol + ' ' + xitems);
end;

procedure TTMovvarios.getDatosDist(xnrosol, xitems: String);
// Objetivo...: Cargar una Instancia
begin
  if BuscarDist(xnrosol, xitems) then Begin
    efectivo := dist.FieldByName('efectivo').AsFloat;
    cheques  := dist.FieldByName('cheque').AsFloat;
  end else Begin
    efectivo := 0; cheques := 0;
  end;
end;

function  TTMovvarios.BuscarCheque(xnrosol, xitems, xsubitems: String): Boolean;
// Objetivo...: Buscar cheque
begin
  Result := datosdb.Buscar(movch, 'nrosol', 'items', 'subitems', xnrosol, xitems, xsubitems);
end;

procedure TTMovvarios.RegistrarCheque(xnrosol, xitems, xsubitems, xnrocheque, xcodbanco, xsucursal, xfecha: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: cerrar tablas de persistencia
begin
  if BuscarCheque(xnrosol, xitems, xsubitems) then movch.Edit else movch.Append;
  movch.FieldByName('nrosol').AsString    := xnrosol;
  movch.FieldByName('items').AsString     := xitems;
  movch.FieldByName('subitems').AsString  := xsubitems;
  movch.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  movch.FieldByName('nrocheque').AsString := xnrocheque;
  movch.FieldByName('codbanco').AsString  := xcodbanco;
  movch.FieldByName('filial').AsString    := xsucursal;
  movch.FieldByName('monto').AsFloat      := xmonto;
  try
    movch.Post
   except
    movch.Cancel
  end;

  if xsubitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then datosdb.tranSQL('delete from ' + movch.TableName + ' where fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''' + ' and items = ' + '''' + xitems + '''' + ' and subitems > ' + '''' + xsubitems + '''');
  datosdb.closeDB(movch); movch.Open;
  logsist.RegistrarLog(usuario.usuario, 'Ingresos Varios', 'Registrando Cheque ' + xnrosol + ' ' + xitems);
end;

procedure TTMovvarios.BorrarCheque(xnrosol, xitems: String);
// Objetivo...: Borrar cheque
begin
  datosdb.tranSQL('delete from ' + movch.TableName + ' where nrosol = ' + '''' + xnrosol + '''' + ' and items = ' + '''' + xitems + '''');
  datosdb.closeDB(movch); movch.Open;
  logsist.RegistrarLog(usuario.usuario, 'Ingresos Varios', 'Borrando Cheque ' + xnrosol + ' ' + xitems);
end;

function  TTMovvarios.setCheques(xnrosol, xitems: String): TStringList;
// Objetivo...: devolver cheques
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarCheque(xnrosol, xitems, '001') then Begin
    while not movch.Eof do Begin
      if (Trim(movch.FieldByName('nrosol').AsString) <> Trim(xnrosol)) or (Trim(movch.FieldByName('items').AsString) <> Trim(xitems)) then Break;
      l.Add(utiles.sFormatoFecha(movch.FieldByName('fecha').AsString) + movch.FieldByName('subitems').AsString + movch.FieldByName('codbanco').AsString + movch.FieldByName('nrocheque').AsString + ';1' + movch.FieldByName('filial').AsString + ';2' + movch.FieldByName('monto').AsString);
      movch.Next;
    end;
  end;
  Result := l;
end;

function  TTMovvarios.BuscarNroSolicitud(xnrosol: String): Boolean;
// Objetivo...: Buscar Nro. Solicitud
begin
  tmov.IndexFieldNames := 'Nrosol';
  Result := tmov.FindKey([xnrosol]);
  tmov.IndexFieldNames := 'Fecha;Items';
end;

procedure TTMovvarios.InfDetalleOperaciones(xdesde, xhasta: String; xlocalidades: TStringList; salida: char);
// Objetivo...: cerrar tablas de persistencia
var
  i: Integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Detalle de Operaciones Ingresos R.E.C.U.P.R.O. - Período: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
    List.Titulo(8, list.Lineactual, 'Sol/Acta/Comp.', 2, 'Arial, cursiva, 8');
    List.Titulo(22, list.Lineactual, 'Entidad/Concepto', 3, 'Arial, cursiva, 8');
    List.Titulo(50, list.Lineactual, 'Concepto', 4, 'Arial, cursiva, 8');
    List.Titulo(64, list.Lineactual, 'Efectivo', 5, 'Arial, cursiva, 8');
    List.Titulo(71, list.Lineactual, 'A Pagar/Cheque', 6, 'Arial, cursiva, 8');
    List.Titulo(84, list.Lineactual, 'Monto Rec./Saldo', 7, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'X') then Begin
    c1 := 0;
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 8);
    excel.setString('a' + l1, 'a' + l1, 'Detalle de Operaciones Ingresos R.E.C.U.P.R.O. - Período: ' + xdesde + '-' + xhasta, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Fecha', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 20);
    excel.setString('b' + l1, 'b' + l1, 'Sol/Acta/Comp.', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 30);
    excel.setString('c' + l1, 'c' + l1, 'Entidad/Concepto', 'Arial, negrita, 10');
    excel.setString('d' + l1, 'd' + l1, 'Concepto', 'Arial, negrita, 10');
    excel.setString('e' + l1, 'e' + l1, 'Efectivo', 'Arial, negrita, 10');
    excel.setString('f' + l1, 'f' + l1, 'A Pagar/Cheque', 'Arial, negrita, 10');
    excel.setString('g' + l1, 'g' + l1, 'Monto Rec./Saldo', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('e' + l1, 'e' + l1, 15);
    excel.FijarAnchoColumna('f' + l1, 'f' + l1, 15);
    excel.FijarAnchoColumna('g' + l1, 'g' + l1, 15);
    Inc(c1);
  end;

  if vc = 0 then VerificarCancelaciones;
  vc := 1;

  idanter := ''; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0;
  tmov.IndexFieldNames := 'Nrosol;Items';
  datosdb.Filtrar(tmov, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');

  For i := 1 to xlocalidades.Count do Begin
    if (totales[6] + totales[7]) > 0 then ListTotalLocalidad(salida);
    municipio.getDatos(xlocalidades.Strings[i-1]);
    cpost.getDatos(municipio.codpost, municipio.orden);
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, 'Localidad: ' + cpost.cp + '-' + cpost.orden + '  ' + cpost.localidad, 1, 'Arial, negrita, 12', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Localidad: ' + cpost.cp + '-' + cpost.orden + '  ' + cpost.localidad, 'Arial, negrita, 9');
    end;

    // -------------------------------------------------------------------------

    IniciarArreglos; idanter := '';

    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '***  Créditos Adeudados  ***', 1, 'Arial, normal, 12', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '***  Créditos Adeudados  ***', 'Arial, normal, 9');
    end;

    tmov.First;
    while not tmov.Eof do Begin    // Deudores
      clientesvarios.getDatos(tmov.FieldByName('codprov').AsString);
      if (clientesvarios.codpost = municipio.codpost) and (clientesvarios.orden = municipio.orden) then Begin
        if tmov.FieldByName('nrosol').AsString <> idanter then Begin

          if {totales[4] - totales[5] >= 0} not cancelado  then
            if Length(Trim(idanter)) > 0 then ListLineaRecupro(salida);

          if Length(Trim(idanter)) > 0 then Begin
            if {totales[4] - totales[5] >= 0} not cancelado then Begin
              ListTotalRecupro(salida);
              list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
            end;
          end;

          getDatosRecupro(tmov.FieldByName('nrosol').AsString);
          IniciarArreglos;

          totales[4] := 0; totales[5] := 0;
          totales[4] := Pagare;
        end;
        idanter := tmov.FieldByName('nrosol').AsString;

        Inc(filas1);
        detalle1[filas1, 1] := utiles.sFormatoFecha(tmov.FieldByName('fecha').AsString);
        detalle1[filas1, 2] := tmov.FieldByName('comprobante').AsString;
        detalle1[filas1, 3] := tmov.FieldByName('concepto').AsString;
        getDatosDist(tmov.FieldByName('nrosol').AsString, tmov.FieldByName('items').AsString);
        detalle1[filas1, 4] := FloatToStr(Efectivo);
        detalle1[filas1, 5] := FloatToStr(Cheques);
        detalle1[filas1, 6] := tmov.FieldByName('nrosol').AsString;
        detalle1[filas1, 7] := tmov.FieldByName('items').AsString;
        detalle1[filas1, 8] := tmov.FieldByName('saldo').AsString;
        totales[8]          := tmov.FieldByName('saldo').AsFloat;
        totales[5] := totales[5] + (Efectivo + Cheques);

        totales[1] := totales[1] + efectivo;
        totales[2] := totales[2] + cheques;
      end;

      tmov.Next;
    end;

    if not cancelado {totales[4] - totales[5] >= 0} then Begin
      ListLineaRecupro(salida);
      ListTotalRecupro(salida);
    end;

    SubtotalDetalle(salida);

    // -------------------------------------------------------------------------

    IniciarArreglos; idanter := '';
    idanter := ''; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
    totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0;


    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, '***  Créditos Saldados  ***', 1, 'Arial, normal, 12', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '***  Créditos Saldados  ***', 'Arial, normal, 9');
    end;

    tmov.First;
    while not tmov.Eof do Begin    // Deudores
      clientesvarios.getDatos(tmov.FieldByName('codprov').AsString);
      if (clientesvarios.codpost = municipio.codpost) and (clientesvarios.orden = municipio.orden) then Begin
        if tmov.FieldByName('nrosol').AsString <> idanter then Begin

          if {totales[4] - totales[5] <= 0} cancelado then
            if Length(Trim(idanter)) > 0 then ListLineaRecupro(salida);

          if Length(Trim(idanter)) > 0 then Begin
            if {totales[4] - totales[5] <= 0} cancelado then Begin
              ListTotalRecupro(salida);
              list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
            end;
          end;

          getDatosRecupro(tmov.FieldByName('nrosol').AsString);
          IniciarArreglos;
          totales[4] := 0; totales[5] := 0;

          totales[4] := Pagare;
        end;
        idanter := tmov.FieldByName('nrosol').AsString;

        Inc(filas1);
        detalle1[filas1, 1] := utiles.sFormatoFecha(tmov.FieldByName('fecha').AsString);
        detalle1[filas1, 2] := tmov.FieldByName('comprobante').AsString;
        detalle1[filas1, 3] := tmov.FieldByName('concepto').AsString;
        getDatosDist(tmov.FieldByName('nrosol').AsString, tmov.FieldByName('items').AsString);
        detalle1[filas1, 4] := FloatToStr(Efectivo);
        detalle1[filas1, 5] := FloatToStr(Cheques);
        detalle1[filas1, 6] := tmov.FieldByName('nrosol').AsString;
        detalle1[filas1, 7] := tmov.FieldByName('items').AsString;
        detalle1[filas1, 8] := tmov.FieldByName('saldo').AsString;
        totales[8]          := tmov.FieldByName('saldo').AsFloat;
        totales[5] := totales[5] + (Efectivo + Cheques);

        totales[1] := totales[1] + efectivo;
        totales[2] := totales[2] + cheques;
      end;

      tmov.Next;
    end;

    if {totales[4] - totales[5] <= 0} cancelado  then Begin
      ListLineaRecupro(salida);
      ListTotalRecupro(salida);
    end;

    SubtotalDetalle(salida);

    // -------------------------------------------------------------------------

    if (totales[6] + totales[7]) > 0 then ListTotalLocalidad(salida);

    if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
  end;

  datosdb.QuitarFiltro(tmov);
  tmov.IndexFieldNames := 'tipomov;fecha';

  if (salida = 'P') or (salida = 'I') then list.FinList else Begin
    excel.setString('a2', 'a2', '');
    excel.Visulizar;
  end;
end;

procedure TTMovvarios.ListLineaRecupro(salida: char);
// Objetivo...: Listar Subtotal
var
  i: Integer;
  j: String;
begin
  getDatosRecupro(idanter);
  if judiciales then j := 'G.Jud.' else j := '';
  if refinanciados then
    if Length(Trim(j)) > 0 then j := j + ' - REF.' else j := 'REF.';
  clientesvarios.getDatos(codprov);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, Fechaotor, 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(8, list.Lineactual, idanter + '-' + Acta, 2, 'Arial, negrita, 8', salida, 'N');
    list.Linea(22, list.Lineactual, clientesvarios.nombre, 3, 'Arial, negrita, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', Pagare, 4, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', MontoRec, 5, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, j, 6, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if (salida = 'X') then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, Fechaotor, 'Arial, negrita, 8');
    excel.setString('b' + l1, 'b' + l1, idanter + '-' + Acta, 'Arial, negrita, 8');
    excel.setString('c' + l1, 'c' + l1, clientesvarios.nombre, 'Arial, negrita, 8');
    excel.setReal('d' + l1, 'd' + l1, Pagare, 'Arial, negrita, 8');
    excel.setReal('e' + l1, 'e' + l1, MontoRec, 'Arial, negrita, 8');
  end;

  For i := 1 to filas1 do Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '  ' + detalle1[i, 1], 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(9, list.Lineactual, detalle1[i, 2], 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(23, list.Lineactual, detalle1[i, 3], 3, 'Arial, normal, 8', salida, 'N');
      list.importe(70, list.Lineactual, '', StrToFloat(detalle1[i, 4]), 4, 'Arial, normal, 8');
      list.importe(80, list.Lineactual, '', StrToFloat(detalle1[i, 5]), 5, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', StrToFloat(detalle1[i, 8]), 6, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, detalle1[i, 2], 'Arial, normal, 8');
      excel.setString('b' + l1, 'b' + l1, detalle1[i, 3], 'Arial, normal, 8');
      excel.setReal('c' + l1, 'c' + l1, StrToFloat(detalle1[i, 4]), 'Arial, normal, 8');
      excel.setReal('d' + l1, 'd' + l1, StrToFloat(detalle1[i, 5]), 'Arial, normal, 8');
      excel.setReal('e' + l1, 'e' + l1, StrToFloat(detalle1[i, 8]), 'Arial, normal, 8');
    end;

    if cheques > 0 then Begin
      if BuscarCheque(detalle1[i, 6], detalle1[i, 7], '001') then Begin
        while not movch.Eof do Begin
          if (movch.FieldByName('nrosol').AsString <> tmov.FieldByName('nrosol').AsString) or (movch.FieldByName('items').AsString <> tmov.FieldByName('items').AsString) then Break;
          entbcos.getDatos(movch.FieldByName('codbanco').AsString);
          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, '', 1, 'Arial, normal, 7', salida, 'N');
            list.Linea(5, list.Lineactual, utiles.sFormatoFecha(movch.FieldByName('fecha').AsString), 2, 'Arial, normal, 7', salida, 'N');
            list.Linea(11, list.Lineactual, entbcos.codbanco + '  ' + entbcos.descrip, 3, 'Arial, normal, 7', salida, 'N');
            list.Linea(56, list.Lineactual, movch.FieldByName('filial').AsString, 4, 'Arial, normal, 7', salida, 'N');
            list.importe(95, list.Lineactual, '', movch.FieldByName('monto').AsFloat, 5, 'Arial, normal, 7');
            list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 7', salida, 'S');
          end;
          if (salida = 'X') then Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(movch.FieldByName('fecha').AsString), 'Arial, normal, 8');
            excel.setString('b' + l1, 'b' + l1, entbcos.codbanco + '  ' + entbcos.descrip, 'Arial, normal, 8');
            excel.setString('c' + l1, 'c' + l1, movch.FieldByName('filial').AsString, 'Arial, normal, 8');
            excel.setReal('d' + l1, 'd' + l1, movch.FieldByName('monto').AsFloat, 'Arial, normal, 8');
          end;

          movch.Next;
        end;
      end;
    end;
  end;

  IniciarArreglos;
end;

procedure TTMovvarios.SubtotalDetalle(salida: char);
// Objetivo...: Listar Subtotal
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal Efectivo / Cheques:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 9');
  end;
  if (salida = 'X') then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Subtotal Efectivo / Cheques:', 'Arial, negrita, 8');
    excel.setReal('d' + l1, 'd' + l1, totales[1], 'Arial, negrita, 8');
    excel.setReal('e' + l1, 'e' + l1, totales[2], 'Arial, negrita, 8');
  end;
  totales[1] := 0; totales[2] := 0; totales[3] := 0;
end;

procedure TTMovvarios.ListTotalRecupro(salida: char);
// Objetivo...: Listar Subtotal
begin
  if totales[5] + totales[4] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Subtotal - Saldo Actual:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(70, list.Lineactual, '', totales[5], 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', totales[8], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Subtotal - Saldo Actual:', 'Arial, negrita, 8');
      excel.setReal('d' + l1, 'd' + l1, totales[5], 'Arial, negrita, 8');
      excel.setReal('e' + l1, 'e' + l1, totales[8], 'Arial, negrita, 8');
    end;
    totales[6] := totales[6] + totales[5];
    totales[7] := totales[7] + (totales[4] - totales[5]);
    totales[4] := 0; totales[5] := 0; totales[8] := 0;
  end;
end;

procedure TTMovvarios.ListTotalLocalidad(salida: char);
// Objetivo...: Listar Subtotal
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal Localidad:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[6], 2, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', totales[7], 3, 'Arial, negrita, 9');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if (salida = 'X') then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Subtotal Localidad:', 'Arial, negrita, 8');
    excel.setReal('d' + l1, 'd' + l1, totales[6], 'Arial, negrita, 8');
    excel.setReal('e' + l1, 'e' + l1, totales[7], 'Arial, negrita, 8');
  end;
  totales[6] := 0; totales[7] := 0;
end;

procedure TTMovvarios.IniciarArreglos;
var
  i, j: Integer;
Begin
  For i := 1 to 100 do
    For j := 1 to 10 do Begin
      detalle1[i, j] := '';
      detalle2[i, j] := '';
    end;
  filas1 := 0; filas2 := 0;
end;

procedure TTMovvarios.VerificarCancelaciones;
// Objetivo...: verificar cancelaciones recupro
var
  t, s: Real;
Begin
  datosdb.tranSQL('update cabrecupro set estado = ' + '''' + '' + '''');
  cabrecupro.First;
  while not cabrecupro.Eof do Begin
    s := cabrecupro.FieldByName('pagare').AsFloat;
    datosdb.Filtrar(tmov, 'nrosol = ' + '''' + cabrecupro.FieldByName('nrosol').AsString + '''');
    tmov.First; t := 0;
    while not tmov.Eof do Begin
      t := t + tmov.FieldByName('monto').AsFloat;
      s := s - tmov.FieldByName('monto').AsFloat;
      tmov.Edit;
      tmov.FieldByName('saldo').AsFloat := s;
      try
        tmov.Post
      except
       tmov.Cancel
      end;
      tmov.Next;
    end;
    datosdb.QuitarFiltro(tmov);

    cabrecupro.Edit;
    if cabrecupro.FieldByName('pagare').AsFloat <= t then cabrecupro.FieldByName('estado').AsString := 'C' else
      cabrecupro.FieldByName('estado').AsString := '';
    try
      cabrecupro.Post
     except
      cabrecupro.Cancel
    end;

    cabrecupro.Next;
  end;
end;

function  TTMovvarios.BuscarRecupro(xnrosol: String): Boolean;
Begin
  if cabrecupro.IndexFieldNames <> 'Nrosol' then cabrecupro.IndexFieldNames := 'Nrosol';
  Result := cabrecupro.FindKey([xnrosol]);
end;

procedure TTMovvarios.RegistrarRecupro(xnrosol, xcodprov, xfecha, xacta, xobservacion: String; xpagare, xmonto: Real);
Begin
  if BuscarRecupro(xnrosol) then cabrecupro.Edit else cabrecupro.Append;
  cabrecupro.FieldByName('nrosol').AsString      := xnrosol;
  cabrecupro.FieldByName('codprov').AsString     := xcodprov;
  cabrecupro.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  cabrecupro.FieldByName('acta').AsString        := xacta;
  cabrecupro.FieldByName('observacion').AsString := xobservacion;
  cabrecupro.FieldByName('monto').AsFloat        := xmonto;
  cabrecupro.FieldByName('pagare').AsFloat       := xpagare;
  try
    cabrecupro.Post
   except
    cabrecupro.Cancel
  end;
  datosdb.closeDB(cabrecupro); cabrecupro.Open;
end;

procedure TTMovvarios.BorrarRecupro(xnrosol: String);
Begin
  if BuscarRecupro(xnrosol) then Begin
    cabrecupro.Delete;
    datosdb.closeDB(cabrecupro); cabrecupro.Open;
  end;
end;

function TTMovvarios.setItems: TStringList;
// Objetivo...: devolver items
var
  l: TStringList;
begin
  l := TStringList.Create;
  cabrecupro.First;
  while not cabrecupro.Eof do Begin
    l.Add(cabrecupro.FieldByName('nrosol').AsString + cabrecupro.FieldByName('codprov').AsString);
    cabrecupro.Next;
  end;
  Result := l;
end;

procedure TTMovvarios.EstadoCancelado(xnrosol: String; xestado: Boolean);
// Objetivo...: Modificar Estado
begin
  if BuscarRecupro(xnrosol) then Begin
    cabrecupro.Edit;
    if xestado then cabrecupro.FieldByName('estado').AsString := 'C' else
      cabrecupro.FieldByName('estado').AsString := '';
    try
      cabrecupro.Post
     except
      cabrecupro.Cancel
    end;
    datosdb.refrescar(cabrecupro);
  end;
end;

procedure TTMovvarios.EstadoJudiciales(xnrosol: String; xestado: Boolean);
// Objetivo...: Enviar a Judiciales
begin
  if BuscarRecupro(xnrosol) then Begin
    cabrecupro.Edit;
    if xestado then cabrecupro.FieldByName('judiciales').AsString := 'S' else
      cabrecupro.FieldByName('judiciales').AsString := '';
    try
      cabrecupro.Post
     except
      cabrecupro.Cancel
    end;
    datosdb.refrescar(cabrecupro);
  end;
end;

procedure TTMovvarios.EstadoRefinanciado(xnrosol: String; xestado: Boolean);
// Objetivo...: Refinanciados
begin
  if BuscarRecupro(xnrosol) then Begin
    cabrecupro.Edit;
    if xestado then cabrecupro.FieldByName('refinanciado').AsString := 'S' else
      cabrecupro.FieldByName('refinanciado').AsString := '';
    try
      cabrecupro.Post
     except
      cabrecupro.Cancel
    end;
    datosdb.refrescar(cabrecupro);
  end;
end;

procedure TTMovvarios.getDatosRecupro(xnrosol: String);
// Objetivo...: Recuperar una Instancia del RECUPRO
begin
  if BuscarRecupro(xnrosol) then Begin
    Codprov   := cabrecupro.FieldByName('codprov').AsString;
    Fechaotor := utiles.sFormatoFecha(cabrecupro.FieldByName('fecha').AsString);
    Acta      := cabrecupro.FieldByName('acta').AsString;
    Observac  := cabrecupro.FieldByName('observacion').AsString;
    MontoRec  := cabrecupro.FieldByName('monto').AsFloat;
    Pagare    := cabrecupro.FieldByName('pagare').AsFloat;
    if cabrecupro.FieldByName('judiciales').AsString = 'S' then Judiciales := True else Judiciales := False;
    if cabrecupro.FieldByName('estado').AsString = 'C' then Cancelado := True else Cancelado := False;
    if cabrecupro.FieldByName('refinanciado').AsString = 'S' then Refinanciados := True else Refinanciados := False;
  end else Begin
    Codprov := ''; Fechaotor := ''; Observac := ''; MontoRec := 0; Pagare := 0; Cancelado := False; Judiciales := False; Refinanciados := False;
  end;
end;

procedure TTMovvarios.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tmov.Active then tmov.Open;
    if not dist.Active then dist.Open;
    if not movch.Active then movch.Open;
    if not cabrecupro.Active then cabrecupro.Open;
  end;
  Inc(conexiones);
  entbcos.conectar;
  clientesvarios.conectar;
  municipio.conectar;
  vc := 0;
end;

procedure TTMovvarios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tmov);
    datosdb.closeDB(dist);
    datosdb.closeDB(movch);
    datosdb.closeDB(cabrecupro);
  end;
  entbcos.desconectar;
  clientesvarios.desconectar;
  municipio.desconectar;
end;

{===============================================================================}

function movvarios: TTMovvarios;
begin
  if xmovvarios = nil then
    xmovvarios := TTMovvarios.Create;
  Result := xmovvarios;
end;

{===============================================================================}

initialization

finalization
  xmovvarios.Free;

end.
