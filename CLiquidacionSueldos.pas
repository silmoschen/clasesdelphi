unit CLiquidacionSueldos;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird, CUtilidadesArchivos,
     IBDatabase, IBCustomDataSet, IBTable, Variants, CBDT, CConceptoSueldo,
     CEmpleadosSueldos, CEmpresasSueldos, CAntiguedadSueldos, CGremioSueldos, Classes;

type

TTLiquidacionSueldo = class(TObject)
  Nrolegajo, Items, Codigo: string;
  Concepto, Tipomov, Formula, Valores_For, cabecera, detalle, pie, Recibo, Lugar, Fechaco, Fechadep: String;
  Monto, Cantidad: Real;
  lineas_detalle, lineas_seprecibos, LineasPag, Lineas_blanco: Integer;
  liquidacion, itsueldo, modelosimpr, recibos: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xnrolegajo, xnroliq, xitems: String): Boolean;
  procedure   Grabar(xperiodo, xnrolegajo, xnroliq, xitems, xcodigo, xconcepto, xtipomov, xformula, xvalores_for: String; xmonto, xcantidad: Real; xcantitems: Integer);
  procedure   Borrar(xperiodo, xnrolegajo, xnroliq: String);
  function    setLiquidacion(xperiodo, xnrolegajo, xnroliq: String): TStringList;
  procedure   getDatosLiquidacion(xperiodo, xnrolegajo, xnroliq, xitems: string);
  procedure   getDatosLiquidacionConcepto(xperiodo, xnrolegajo, xnroliq, xcodigo: string);

  procedure   GrabarItems(xnrolegajo, xitems, xcodigo, xformula: string; xcantitems: Integer);
  procedure   BorrarItems(xnrolegajo, xitems: string); overload;
  procedure   BorrarItems(xnrolegajo: string); overload;
  function    BuscarItems(xnrolegajo, xitems: string): boolean;
  procedure   getDatosItems(xnrolegajo, xitems: string);
  function    setItemsLiq(xnrolegajo: String): TStringList;
  function    setFormula(xnrolegajo, xcodigo: String): String;

  function    BuscarConcepto(xperiodo, xnrolegajo, xnroliq, xcodigo: String): Boolean;

  function    BuscarModelo(xid: Integer): Boolean;
  procedure   RegistrarModelo(xid: Integer; xcabecera, xdetalle, xpie: String);
  procedure   getDatosModelo(xid: Integer);

  procedure   ListarRecibo(xlista: TStringList; xperiodo, xnroliq, xcodemp, xlugar, xfecha, xfechadep: String; salida: char);
  procedure   ListarLibro(xlista: TStringList; xperiodo, xnroliq, xcodemp: String; salida: char);
  procedure   ListarEncabezadoLibro(xlista: TStringList; xperiodo, xnroliq, xcodemp: String; salida: char);
  procedure   ListarDetalleLibro(xlista: TStringList; xperiodo, xnroliq, xcodemp: String; salida: char);

  function    BuscarRecibo(xnrolegajo, xperiodo, xnroliq: String): Boolean;
  function    setNroRecibo(xnrolegajo, xperiodo, xnroliq: String): String;
  procedure   GuardarRecibo(xnrolegajo, xperiodo, xnroliq, xrecibo, xlugar, xfecha, xfechadep: String);
  procedure   BorrarRecibo(xnrolegajo, xperiodo, xnroliq: String);
  procedure   getRecibo(xnrolegajo, xperiodo, xnroliq: String);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  objfirebird: TTFirebird;
  totales: array [1..5] of Real;
  detsueldo: array[1..100, 1..6] of String;
  ln, lineas: Integer;
  lin: String;
  ocultar_titulos, ocultar_detalle: Boolean;
  { Declaraciones Privadas }
  procedure ListTituloLibro(xcodemp, xperiodo, xnroliq: String; xlisttitulos: Boolean; salida: char);
  procedure IniciarArrays;
  procedure ListDetalle(xcodemp, xperiodo, xnroliq: String; xlisttitulos: Boolean; salida: char);
  procedure ListSubtotal(xcodemp, xperiodo, xnroliq: String; xlisttitulos: Boolean; salida: char);
  function  ControlarSalto: boolean;
  procedure RealizarSalto;
end;

function liquidacionsueldo: TTLiquidacionSueldo;

implementation

var
  xliquidacionsueldo: TTLiquidacionSueldo = nil;

constructor TTLiquidacionSueldo.Create;
begin
  inherited Create;
  objfirebird := TTFirebird.Create;
  firebird.getModulo('sueldos');
  objfirebird.Conectar(firebird.Host + '\' + empresa.setViaSeleccionada + '\datosempr.gdb', firebird.Usuario, firebird.Password);
  itsueldo    := objfirebird.InstanciarTabla('items_sueldos');
  liquidacion := objfirebird.InstanciarTabla('liquidacion');
  modelosimpr := objfirebird.InstanciarTabla('modelosimpr');
  recibos     := objfirebird.InstanciarTabla('recibos');
end;

destructor TTLiquidacionSueldo.Destroy;
begin
  inherited Destroy;
end;

function  TTLiquidacionSueldo.Buscar(xperiodo, xnrolegajo, xnroliq, xitems: String): Boolean;
// Objetivo...: Buscar una Instancia del Objeto
begin
  Result := objfirebird.Buscar(liquidacion, 'periodo;nrolegajo;nroliq;items', xperiodo, xnrolegajo, xnroliq, xitems);
end;

procedure TTLiquidacionSueldo.Grabar(xperiodo, xnrolegajo, xnroliq, xitems, xcodigo, xconcepto, xtipomov, xformula, xvalores_for: String; xmonto, xcantidad: Real; xcantitems: Integer);
// Objetivo...: Grabar una instancia del Objeto
begin
  if Buscar(xperiodo, xnrolegajo, xnroliq, xitems) then liquidacion.Edit else liquidacion.Append;
  liquidacion.FieldByName('periodo').AsString     := xperiodo;
  liquidacion.FieldByName('nrolegajo').AsString   := xnrolegajo;
  liquidacion.FieldByName('nroliq').AsString      := xnroliq;
  liquidacion.FieldByName('items').AsString       := xitems;
  liquidacion.FieldByName('codigo').AsString      := xcodigo;
  liquidacion.FieldByName('concepto').AsString    := xconcepto;
  liquidacion.FieldByName('tipomov').AsString     := xtipomov;
  liquidacion.FieldByName('monto').AsFloat        := xmonto;
  liquidacion.FieldByName('cantidad').AsFloat     := xcantidad;
  liquidacion.FieldByName('formula').AsString     := xformula;
  liquidacion.FieldByName('valores_for').AsString := xvalores_for;
  try
    liquidacion.Post
   except
    liquidacion.Cancel
  end;
  objfirebird.RegistrarTransaccion(liquidacion);

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    objfirebird.TransacSQL('delete from liquidacion where periodo = ' + '''' + xperiodo + '''' + ' and nrolegajo = ' + '''' + xnrolegajo + '''' + ' and nroliq = ' + '''' + xnroliq + '''' + ' and items > ' + '''' + xitems + '''');
    objfirebird.RegistrarTransaccion(liquidacion);
  end;
end;

procedure  TTLiquidacionSueldo.getDatosLiquidacion(xperiodo, xnrolegajo, xnroliq, xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xperiodo, xnrolegajo, xnroliq, xitems) then Begin
    nrolegajo   := liquidacion.FieldByName('nrolegajo').AsString;
    items       := liquidacion.FieldByName('items').AsString;
    codigo      := liquidacion.FieldByName('codigo').AsString;
    formula     := liquidacion.FieldByName('formula').AsString;
    concepto    := liquidacion.FieldByName('concepto').AsString;
    valores_for := liquidacion.FieldByName('valores_for').AsString;
    tipomov     := liquidacion.FieldByName('tipomov').AsString;
    cantidad    := liquidacion.FieldByName('cantidad').AsFloat;
    monto       := liquidacion.FieldByName('monto').AsFloat;
  end else Begin
    nrolegajo := ''; items := ''; codigo := ''; formula := ''; concepto := ''; valores_for := ''; tipomov := '';
    cantidad := 0; monto := 0;
  end;
end;

procedure  TTLiquidacionSueldo.getDatosLiquidacionConcepto(xperiodo, xnrolegajo, xnroliq, xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarConcepto(xperiodo, xnrolegajo, xnroliq, xcodigo) then Begin
    nrolegajo   := liquidacion.FieldByName('nrolegajo').AsString;
    items       := liquidacion.FieldByName('items').AsString;
    codigo      := liquidacion.FieldByName('codigo').AsString;
    formula     := liquidacion.FieldByName('formula').AsString;
    concepto    := liquidacion.FieldByName('concepto').AsString;
    valores_for := liquidacion.FieldByName('valores_for').AsString;
    tipomov     := liquidacion.FieldByName('tipomov').AsString;
    cantidad    := liquidacion.FieldByName('cantidad').AsFloat;
    monto       := liquidacion.FieldByName('monto').AsFloat;
  end else Begin
    nrolegajo := ''; items := ''; codigo := ''; formula := ''; concepto := ''; valores_for := ''; tipomov := '';
    cantidad := 0; monto := 0;
  end;
end;

procedure  TTLiquidacionSueldo.Borrar(xperiodo, xnrolegajo, xnroliq: String);
// Objetivo...: Borrar una instancia del Objeto
begin
  objfirebird.TransacSQL('delete from liquidacion where periodo = ' + '''' + xperiodo + '''' + ' and nrolegajo = ' + '''' + xnrolegajo + '''' + ' and nroliq = ' + '''' + xnroliq + '''');
  objfirebird.RegistrarTransaccion(liquidacion);
  BorrarRecibo(xnrolegajo, xperiodo, xnroliq);
end;

function  TTLiquidacionSueldo.setLiquidacion(xperiodo, xnrolegajo, xnroliq: String): TStringList;
// Objetivo...: Devolver items liquidación
var
  l: TStringList;
begin
  l := TStringList.Create;
  objfirebird.Filtrar(liquidacion, 'periodo = ' + '''' + xperiodo + '''' + ' and nrolegajo = ' + '''' + xnrolegajo + '''' + ' and nroliq = ' + '''' + xnroliq + '''');
  liquidacion.First;
  while not liquidacion.Eof do Begin
    l.Add(liquidacion.FieldByName('items').AsString + liquidacion.FieldByName('codigo').AsString + liquidacion.FieldByName('tipomov').AsString + liquidacion.FieldByName('concepto').AsString + ';1' + utiles.FormatearNumero(liquidacion.FieldByName('monto').AsString, '########.##') + ';2' + utiles.FormatearNumero(liquidacion.FieldByName('cantidad').AsString, '########.##'));
    liquidacion.Next;
  end;
  objfirebird.QuitarFiltro(liquidacion);

  Result := l;
end;

procedure TTLiquidacionSueldo.GrabarItems(xnrolegajo, xitems, xcodigo, xformula: string; xcantitems: Integer);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarItems(xnrolegajo, xitems) then itsueldo.Edit else itsueldo.Append;
  itsueldo.FieldByName('nrolegajo').AsString := xnrolegajo;
  itsueldo.FieldByName('items').AsString     := xitems;
  itsueldo.FieldByName('codigo').AsString    := xcodigo;
  itsueldo.FieldByName('formula').AsString   := xformula;
  try
    itsueldo.Post;
   except
    itsueldo.Cancel
  end;
  objfirebird.RegistrarTransaccion(itsueldo);
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    objfirebird.TransacSQL('delete from ' + itsueldo.TableName + ' where nrolegajo = ' + '''' + xnrolegajo + '''' + ' and items > ' + '''' + xitems + '''');
    objfirebird.RegistrarTransaccion(itsueldo);
  end;
end;

procedure TTLiquidacionSueldo.BorrarItems(xnrolegajo, xitems: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarItems(xnrolegajo, xitems) then Begin
    itsueldo.Delete;
    getDatosItems(itsueldo.FieldByName('nrolegajo').AsString, itsueldo.FieldByName('items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    objfirebird.RegistrarTransaccion(itsueldo);
  end;
end;

procedure TTLiquidacionSueldo.BorrarItems(xnrolegajo: string);
// Objetivo...: Eliminar un Objeto
begin
  objfirebird.TransacSQL('delete from ' + itsueldo.TableName + ' where nrolegajo = ' + '''' + xnrolegajo + '''');
  objfirebird.RegistrarTransaccion(itsueldo);
end;

function TTLiquidacionSueldo.BuscarItems(xnrolegajo, xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if itsueldo.IndexFieldNames <> 'NROLEGAJO;ITEMS' then itsueldo.IndexFieldNames := 'NROLEGAJO;ITEMS';
  Result := objfirebird.Buscar(itsueldo, 'NROLEGAJO;ITEMS', xnrolegajo, xitems);
end;

procedure  TTLiquidacionSueldo.getDatosItems(xnrolegajo, xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarItems(xnrolegajo, xitems) then Begin
    nrolegajo   := itsueldo.FieldByName('nrolegajo').AsString;
    items       := itsueldo.FieldByName('items').AsString;
    codigo      := itsueldo.FieldByName('codigo').AsString;
    formula     := itsueldo.FieldByName('formula').AsString;
    concepto    := itsueldo.FieldByName('concepto').AsString;
  end else Begin
    nrolegajo := ''; items := ''; codigo := ''; formula := ''; concepto := '';
  end;
end;

function  TTLiquidacionSueldo.setItemsLiq(xnrolegajo: String): TStringList;
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if itsueldo.IndexFieldNames <> 'NROLEGAJO;ITEMS' then itsueldo.IndexFieldNames := 'NROLEGAJO;ITEMS';
  objfirebird.Filtrar(itsueldo, 'NROLEGAJO = ' + '''' + xnrolegajo + '''');
  itsueldo.First;
  while not itsueldo.Eof do Begin
    l.Add(itsueldo.FieldByName('items').AsString + itsueldo.FieldByName('codigo').AsString + itsueldo.FieldByName('formula').AsString);
    itsueldo.Next;
  end;
  objfirebird.QuitarFiltro(itsueldo);
  Result := l;
end;

function  TTLiquidacionSueldo.setFormula(xnrolegajo, xcodigo: String): String;
// Objetivo...: Recuperar Formula Items
begin
  itsueldo.IndexFieldNames := 'NROLEGAJO;CODIGO';
  if objfirebird.Buscar(itsueldo, 'nrolegajo;codigo', xnrolegajo, xcodigo) then
    Result := itsueldo.FieldByName('formula').AsString
  else
    Result := '';
  itsueldo.IndexFieldNames := 'NROLEGAJO;ITEMS';
end;

function  TTLiquidacionSueldo.BuscarConcepto(xperiodo, xnrolegajo, xnroliq, xcodigo: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  liquidacion.IndexFieldNames := 'PERIODO;NROLEGAJO;NROLIQ;CODIGO';
  Result := objfirebird.Buscar(liquidacion, 'periodo;nrolegajo;nroliq;codigo', xperiodo, xnrolegajo, xnroliq, xcodigo);
  liquidacion.IndexFieldNames := 'PERIODO;NROLEGAJO;NROLIQ;ITEMS';
end;

function  TTLiquidacionSueldo.BuscarModelo(xid: Integer): Boolean;
// Objetivo...: Guardar Instancia
begin
  modelosimpr.IndexFieldNames := 'IDMODELO';
  Result := objfirebird.Buscar(modelosimpr, 'idmodelo', IntToStr(xid));
end;

procedure TTLiquidacionSueldo.RegistrarModelo(xid: Integer; xcabecera, xdetalle, xpie: String);
// Objetivo...: Registrar Instancia
begin
  if BuscarModelo(xid) then modelosimpr.Edit else modelosimpr.Append;
  modelosimpr.FieldByName('idmodelo').AsInteger := xid;
  modelosimpr.FieldByName('cabecera').AsString  := xcabecera;
  modelosimpr.FieldByName('detalle').AsString   := xdetalle;
  modelosimpr.FieldByName('pie').AsString       := xpie;
  try
    modelosimpr.Post
   except
    modelosimpr.Cancel
  end;
  objfirebird.RegistrarTransaccion(modelosimpr);
end;

procedure TTLiquidacionSueldo.getDatosModelo(xid: Integer);
// Objetivo...: Recuperar Instancia
begin
  if BuscarModelo(xid) then Begin
    cabecera := modelosimpr.FieldByName('cabecera').AsString;
    detalle  := modelosimpr.FieldByName('detalle').AsString;
    pie      := modelosimpr.FieldByName('pie').AsString;
  end else Begin
    cabecera := ''; detalle := ''; pie := '';
  end;
end;

procedure TTLiquidacionSueldo.ListarRecibo(xlista: TStringList; xperiodo, xnroliq, xcodemp, xlugar, xfecha, xfechadep: String; salida: char);
var
  i, lineas, j, k, xi, m, lindet: Integer;
  l, n: TStringList;
  ldat: Boolean;
  il, nrorecibo: String;
Begin
  ldat := False;
  For i := 1 to xlista.Count do Begin

    if Buscar(xperiodo, xlista.Strings[i-1], xnroliq, '01') then Begin

      empleado.getDatos(xlista.Strings[i-1]);
      empresa.getDatos(xcodemp);

      if not ldat then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.Setear(salida);
          list.NoImprimirPieDePagina;
        end else
          list.IniciarImpresionModoTexto;
        end;
      end;

      nrorecibo := utiles.sLlenarIzquierda(setNroRecibo(xlista.Strings[i-1], xperiodo, xnroliq), 5, '0');
      ldat := True;
      totales[1] := 0; totales[2] := 0; totales[3] := 0; lindet := 0; lineas := 0;

      getDatosModelo(1);
      list.IniciarMemoImpresionesIBase(modelosImpr, 'cabecera', 700);
      list.RemplazarEtiquetasEnMemo('#n-empleador', utiles.StringLongitudFija(empresa.Nombre, 30));
      list.RemplazarEtiquetasEnMemo('#d-empleador', utiles.StringLongitudFija(empresa.Domicilio, 30));
      list.RemplazarEtiquetasEnMemo('#c-empleador', empresa.CUIT);
      list.RemplazarEtiquetasEnMemo('#n-empleado', utiles.StringLongitudFija(empleado.Nombre, 30));
      list.RemplazarEtiquetasEnMemo('#s-empleado', empleado.Seccion);
      list.RemplazarEtiquetasEnMemo('#legajo', empleado.Nrolegajo);
      list.RemplazarEtiquetasEnMemo('#ingreso', empleado.FechaIng);
      list.RemplazarEtiquetasEnMemo('#recibo', nrorecibo);
      list.RemplazarEtiquetasEnMemo('#periodo', xperiodo);
      list.RemplazarEtiquetasEnMemo('#categoria', utiles.StringLongitudFija(empleado.setCategoria(xlista.Strings[i-1]), 20));
      list.RemplazarEtiquetasEnMemo('#calificacion', 'calificacion');
      list.RemplazarEtiquetasEnMemo('#remuneracion', utiles.FormatearNumero(FloatToStr(empleado.Sueldo)));

      if (salida = 'P') or (salida = 'I') then Begin
        list.ListMemo('', 'Courier New, normal, 8', 0, salida, nil, 700);
      end else Begin
        l := list.setContenidoMemoIBase(modelosImpr, 'cabecera', 700);
        For j := 1 to l.Count do Begin
          list.LineaTxt(l.Strings[j-1], True);
          Inc(lineas);
        end;
      end;
      list.LiberarMemoImpresiones;

      if Buscar(xperiodo, xlista.Strings[i-1], xnroliq, '01') then Begin
        while not liquidacion.Eof do Begin
          if liquidacion.FieldByName('nrolegajo').AsString <> xlista.Strings[i-1] then Break;
          if liquidacion.FieldByName('monto').AsFloat <> 0 then Begin
            list.IniciarMemoImpresionesIBase(modelosImpr, 'detalle', 700);
            list.RemplazarEtiquetasEnMemo('#cod', liquidacion.FieldByName('codigo').AsString);
            list.RemplazarEtiquetasEnMemo('#concepto', utiles.StringLongitudFija(liquidacion.FieldByName('concepto').AsString, 25));
            list.RemplazarEtiquetasEnMemo('#unidades', '');
            if liquidacion.FieldByName('tipomov').AsString = 'R' then list.RemplazarEtiquetasEnMemo('#RSR', utiles.StringLongitudFija( utiles.sLlenarIzquierda( utiles.FormatearNumero(liquidacion.FieldByName('monto').AsString), 7, ' '), 7)) else
              list.RemplazarEtiquetasEnMemo('#RSR', utiles.StringLongitudFija( utiles.sLlenarIzquierda( ' ', 7, ' '), 7));
            if liquidacion.FieldByName('tipomov').AsString = 'E' then list.RemplazarEtiquetasEnMemo('#REX', utiles.StringLongitudFija( utiles.sLlenarIzquierda( utiles.FormatearNumero(liquidacion.FieldByName('monto').AsString), 7, ' '), 7)) else
              list.RemplazarEtiquetasEnMemo('#REX', utiles.StringLongitudFija( utiles.sLlenarIzquierda( ' ', 7, ' '), 7));
            if liquidacion.FieldByName('tipomov').AsString = 'T' then list.RemplazarEtiquetasEnMemo('#DTO', utiles.StringLongitudFija( utiles.sLlenarIzquierda( utiles.FormatearNumero(liquidacion.FieldByName('monto').AsString), 7, ' '), 7)) else
              list.RemplazarEtiquetasEnMemo('#DTO', utiles.StringLongitudFija( utiles.sLlenarIzquierda( ' ', 7, ' '), 7));

            if liquidacion.FieldByName('tipomov').AsString = 'R' then totales[1] := totales[1] + liquidacion.FieldByName('monto').AsFloat;
            if liquidacion.FieldByName('tipomov').AsString = 'E' then totales[2] := totales[2] + liquidacion.FieldByName('monto').AsFloat;
            if liquidacion.FieldByName('tipomov').AsString = 'T' then totales[3] := totales[3] + liquidacion.FieldByName('monto').AsFloat;

            if (salida = 'P') or (salida = 'I') then Begin
              list.ListMemo('', 'Courier New, normal, 8', 0, salida, nil, 700);
            end else Begin
              l := list.setContenidoMemoIBase(modelosImpr, 'cabecera', 700);
            For j := 1 to l.Count do Begin
              list.LineaTxt(l.Strings[j-1], True);
              Inc(lineas);
            end;
            list.LiberarMemoImpresiones;

            Inc(lindet);
          end;

        end;
        liquidacion.Next;
      end;

      For m := 1 to (lineas_detalle - lindet) do Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '', 1, 'Courier New, normal, 8', salida, 'S');
        end else Begin
          list.LineaTxt('', True);
          Inc(lineas);
        end;
      end;

      list.IniciarMemoImpresionesIBase(modelosImpr, 'pie', 700);
      list.RemplazarEtiquetasEnMemo('#contratacion', utiles.StringLongitudFija(empleado.contratacion, 20));
      list.RemplazarEtiquetasEnMemo('#cuil', utiles.StringLongitudFija(empleado.CUIL, 13));
      list.RemplazarEtiquetasEnMemo('#contratacion', utiles.StringLongitudFija(empleado.Contratacion, 20));
      if totales[1] > 0 then list.RemplazarEtiquetasEnMemo('#TRSR', utiles.StringLongitudFija( utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr(totales[1])), 7, ' '), 7)) else
        list.RemplazarEtiquetasEnMemo('#TRSR', utiles.StringLongitudFija( utiles.sLlenarIzquierda( ' ', 7, ' '), 7));
      if totales[2] > 0 then list.RemplazarEtiquetasEnMemo('#TREX', utiles.StringLongitudFija( utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr(totales[2])), 7, ' '), 7)) else
        list.RemplazarEtiquetasEnMemo('#TREX', utiles.StringLongitudFija( utiles.sLlenarIzquierda( ' ', 7, ' '), 7));
      if totales[3] > 0 then list.RemplazarEtiquetasEnMemo('#TDTO', utiles.StringLongitudFija( utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr(totales[3])), 7, ' '), 7)) else
        list.RemplazarEtiquetasEnMemo('#TDTO', utiles.StringLongitudFija( utiles.sLlenarIzquierda( ' ', 7, ' '), 7));
      list.RemplazarEtiquetasEnMemo('#NETO', utiles.StringLongitudFija( utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr( (totales[1] + totales[2]) - totales[3] )), 7, ' '), 7));
      if empleado.TipoCobro = 'E' then list.RemplazarEtiquetasEnMemo('#forma-pago', 'Efectivo');
      if empleado.TipoCobro = 'B' then list.RemplazarEtiquetasEnMemo('#forma-pago', 'Bancario');
      il := utiles.FormatearNumero(FloatToStr( (totales[1] + totales[2]) - totales[3] ));
      xi := StrToInt(Copy(il, 1, Length(Trim(il)) - 3));
      list.RemplazarEtiquetasEnMemo('#importe-letras', utiles.StringLongitudFija( LowerCase(utiles.xIntToLletras(xi) + ' C/ ' + Copy(il, Length(Trim(il)) - 1, 2)), 50));
      list.RemplazarEtiquetasEnMemo('#lugar-fecha', utiles.StringLongitudFija(Copy(xlugar, 1, 17) + ', ' + xfecha, 28));
      list.RemplazarEtiquetasEnMemo('#fecha-deposito', xfechadep);

      if (salida = 'P') or (salida = 'I') then Begin
        list.ListMemo('', 'Courier New, normal, 8', 0, salida, nil, 700);
      end else Begin
        l := list.setContenidoMemoIBase(modelosImpr, 'cabecera', 700);
        For j := 1 to l.Count do Begin
          list.LineaTxt(l.Strings[j-1], True);
          Inc(lineas);
        end;
      end;
      list.LiberarMemoImpresiones;

      GuardarRecibo(xlista.Strings[i-1], xperiodo, xnroliq, nrorecibo, xlugar, xfecha, xfechadep);

    end;

    if (salida = 'P') or (salida = 'I') then list.CompletarPagina else
      if salida = 'T' then Begin
        For m := 1 to (lineas_seprecibos - lineas) do Begin
          list.LineaTxt('', True);
        end;
      end;

  end;

  if ldat then Begin
    if (salida = 'P') or (salida = 'I') then list.FinList;
    if (salida = 'T') then list.FinalizarImpresionModoTexto(1);
  end else
    utiles.msgError('La Liquidación no está Registrada ...!');

end;

procedure TTLiquidacionSueldo.ListarLibro(xlista: TStringList; xperiodo, xnroliq, xcodemp: String; salida: char);
// Objetivo...: Listar Libro de Sueldos
var
  nroanter: String;
  cf: Boolean;
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    lin := utiles.sLlenarIzquierda(lin, 80, '-');
    ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
  end;

  totales[1] := 0; totales[2] := 0; totales[3] := 0; ln := 0;
  objfirebird.Filtrar(liquidacion, 'PERIODO = ' + '''' + xperiodo + '''' + ' and NROLIQ = ' + '''' + xnroliq + '''');
  liquidacion.First;
  while not liquidacion.Eof do Begin
    if liquidacion.FieldByName('nrolegajo').AsString <> nroanter then Begin
      if totales[1] > 0 then ListDetalle(xcodemp, xperiodo, xnroliq, True, salida);
      if totales[1] > 0 then ListSubtotal(xcodemp, xperiodo, xnroliq, True, salida);

      if (salida = 'P') or (salida = 'I') then Begin
        if not ocultar_detalle then Begin
          empleado.getDatos(liquidacion.FieldByName('nrolegajo').AsString);
          list.Linea(0, 0, liquidacion.FieldByName('nrolegajo').AsString, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(5, list.Lineactual, empleado.Nombre, 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(30, list.Lineactual, 'ADM', 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(35, list.Lineactual, empleado.Calificacion, 4, 'Arial, normal, 8', salida, 'N');
          list.Linea(50, list.Lineactual, empleado.FechaIng, 5, 'Arial, normal, 8', salida, 'N');
          list.Linea(60, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'N');
          list.Linea(70, list.Lineactual, empleado.setCategoria(empleado.Nrolegajo), 7, 'Arial, normal, 8', salida, 'N');
          list.Linea(85, list.Lineactual, utiles.FormatearNumero(FloatToStr(empleado.Sueldo)), 8, 'Arial, normal, 8', salida, 'S');

          getRecibo(liquidacion.FieldByName('nrolegajo').AsString, xperiodo, xnroliq);
          list.Linea(0, 0, lugar, 1, 'Arial, normal, 8', salida, 'N');
          empleado.getDatos(liquidacion.FieldByName('nrolegajo').AsString);
          list.Linea(30, list.Lineactual, empleado.Contratacion, 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(50, list.Lineactual, empleado.Jubilacion, 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(85, list.Lineactual, empleado.TipoLiq, 4, 'Arial, normal, 8', salida, 'S');

          empleado.getDatos(liquidacion.FieldByName('nrolegajo').AsString);
          list.Linea(0, 0, empleado.Fechanac, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(30, list.Lineactual, empleado.Estcivil, 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(40, list.Lineactual, empleado.Domicilio, 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(60, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'N');
          list.Linea(78, list.Lineactual, empleado.CUIL + '  ' + empleado.DNI, 5, 'Arial, normal, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
        end else Begin
          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(5, list.Lineactual, '', 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(30, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(35, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'N');
          list.Linea(50, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'N');
          list.Linea(60, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'N');
          list.Linea(70, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'N');
          list.Linea(85, list.Lineactual, '', 8, 'Arial, normal, 8', salida, 'S');

          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(30, list.Lineactual, '', 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(50, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(85, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');

          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(30, list.Lineactual, '', 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(40, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(60, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'N');
          list.Linea(78, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
        end;
      end;

      if (salida = 'T') then Begin
        if not ocultar_detalle then Begin
          empleado.getDatos(liquidacion.FieldByName('nrolegajo').AsString);
          list.LineaTxt(liquidacion.FieldByName('nrolegajo').AsString + ' ', False);
          list.LineaTxt(utiles.StringLongitudFija(empleado.Nombre, 30), False);
          list.LineaTxt(utiles.StringLongitudFija('ADM', 3), False);
          list.LineaTxt(utiles.StringLongitudFija(empleado.Calificacion, 16), False);
          list.LineaTxt(empleado.FechaIng + ' ', False);
          list.LineaTxt('', False);
          list.LineaTxt(utiles.StringLongitudFija(empleado.setCategoria(empleado.Nrolegajo), 11), False);
          list.importeTxt(empleado.Sueldo, 10, 2, True);
          Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);

          getRecibo(liquidacion.FieldByName('nrolegajo').AsString, xperiodo, xnroliq);
          list.LineaTxt(utiles.StringLongitudFija(lugar, 20), False);
          empleado.getDatos(liquidacion.FieldByName('nrolegajo').AsString);
          list.LineaTxt(utiles.StringLongitudFija(empleado.Contratacion, 21), False);
          list.LineaTxt(utiles.StringLongitudFija(empleado.Jubilacion, 16), False);
          list.LineaTxt(utiles.StringLongitudFija(empleado.TipoLiq, 6), True);
          Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);

          empleado.getDatos(liquidacion.FieldByName('nrolegajo').AsString);
          list.LineaTxt(empleado.Fechanac + ' ', False);
          list.LineaTxt(empleado.Estcivil + '      ', False);
          list.LineaTxt(utiles.StringLongitudFija(empleado.Domicilio, 18), False);
          list.LineaTxt('                                ', False);
          list.LineaTxt(empleado.CUIL + ' ' + empleado.DNI, True);
          list.LineaTxt('', True);
          Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
        end else Begin
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', True);
          Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);

          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', True);
          Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);

          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', False);
          list.LineaTxt('', True);
          list.LineaTxt('', True);
          Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
        end;
      end;

      nroanter := liquidacion.FieldByName('nrolegajo').AsString;
      cf       := False;
    end;


    if not cf then Begin
      Inc(ln);
      detsueldo[ln, 1] := liquidacion.FieldByName('codigo').AsString;
      detsueldo[ln, 2] := liquidacion.FieldByName('concepto').AsString;
      detsueldo[ln, 3] := liquidacion.FieldByName('monto').AsString;
      cf               := True;
    end else Begin
      detsueldo[ln, 4] := liquidacion.FieldByName('codigo').AsString;
      detsueldo[ln, 5] := liquidacion.FieldByName('concepto').AsString;
      detsueldo[ln, 6] := liquidacion.FieldByName('monto').AsString;
      cf               := False;
    end;

    if liquidacion.FieldByName('tipomov').AsString = 'R' then totales[1] := totales[1] + liquidacion.FieldByName('monto').AsFloat;
    if liquidacion.FieldByName('tipomov').AsString = 'E' then totales[2] := totales[2] + liquidacion.FieldByName('monto').AsFloat;
    if liquidacion.FieldByName('tipomov').AsString = 'T' then totales[3] := totales[3] + liquidacion.FieldByName('monto').AsFloat;

    liquidacion.Next;
  end;

  ListDetalle(xcodemp, xperiodo, xnroliq, True, salida);
  ListSubtotal(xcodemp, xperiodo, xnroliq, True, salida);

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1); 
end;

procedure TTLiquidacionSueldo.ListTituloLibro(xcodemp, xperiodo, xnroliq: String; xlisttitulos: Boolean; salida: char);
// Objetivo...: Listar Titulos
Begin
  if xlisttitulos then Begin
    empresa.getDatos(xcodemp);
    if (salida = 'P') or (salida = 'I') then Begin
      if not ocultar_titulos then Begin
        list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
        list.Titulo(0, 0, empresa.Nombre, 1, 'Arial, negrita, 8');
        list.Titulo(30, list.Lineactual, empresa.Domicilio, 2, 'Arial, negrita, 8');
        list.Titulo(75, list.Lineactual, 'Liq.: ' + xnroliq +  ', Per.: ' + xperiodo, 3, 'Arial, negrita, 8');
        list.Titulo(0, 0, empresa.Actividad, 1, 'Arial, negrita, 8');
        list.Titulo(30, list.Lineactual, 'C.U.I.T.: ' + empresa.CUIT, 2, 'Arial, negrita, 8');

        list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
        list.Titulo(0, 0, 'Hojas Móviles en Reemplazo del Libro Especial Lay 20744 T.O. (art. 52)', 1, 'Arial, negrita, 12');
        list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

        list.Titulo(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10');
        list.Titulo(0, 0, 'Legajo', 1, 'Arial, cursiva, 8');
        list.Titulo(7,  list.Lineactual, 'Apellido y Nombre', 2, 'Arial, cursiva, 8');
        list.Titulo(30, list.Lineactual, 'C. de', 3, 'Arial, cursiva, 8');
        list.Titulo(35, list.Lineactual, 'Calificación', 4, 'Arial, cursiva, 8');
        list.Titulo(50, list.Lineactual, 'Fecha', 5, 'Arial, cursiva, 8');
        list.Titulo(60, list.Lineactual, 'Fecha', 6, 'Arial, cursiva, 8');
        list.Titulo(70, list.Lineactual, 'Categoría', 7, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, 'Remuneración', 8, 'Arial, cursiva, 8');

        list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
        list.Titulo(30, list.Lineactual, 'Costo', 2, 'Arial, cursiva, 8');
        list.Titulo(35, list.Lineactual, 'Profesional', 3, 'Arial, cursiva, 8');
        list.Titulo(50, list.Lineactual, 'Ingreso', 4, 'Arial, cursiva, 8');
        list.Titulo(60, list.Lineactual, 'Egreso', 5, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, 'Asignada', 6, 'Arial, cursiva, 8');
        list.Titulo(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10');

        list.Titulo(0, 0, 'Lugar de Trabajo', 1, 'Arial, cursiva, 8');
        list.Titulo(30, list.Lineactual, 'Contratación', 2, 'Arial, cursiva, 8');
        list.Titulo(50, list.Lineactual, 'Régimen Previsional', 3, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, 'Mensual/Jornal', 4, 'Arial, cursiva, 8');
        list.Titulo(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10');

        list.Titulo(0, 0, 'Fe.Nac.', 1, 'Arial, cursiva, 8');
        list.Titulo(30, list.Lineactual, 'E.Civil', 2, 'Arial, cursiva, 8');
        list.Titulo(40, list.Lineactual, 'Domicilio', 3, 'Arial, cursiva, 8');
        list.Titulo(60, list.Lineactual, 'Provincia', 4, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, 'C.U.I.L./Doc.:', 5, 'Arial, cursiva, 8');
        list.Titulo(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10');

        list.Titulo(0, 0, 'Cód.', 1, 'Arial, cursiva, 8');
        list.Titulo(5,  list.Lineactual, 'Concepto', 2, 'Arial, cursiva, 8');
        list.Titulo(35, list.Lineactual, 'Un.', 3, 'Arial, cursiva, 8');
        list.Titulo(43, list.Lineactual, 'Importe', 4, 'Arial, cursiva, 8');
        list.Titulo(50, list.Lineactual, 'Cód.', 5, 'Arial, cursiva, 8');
        list.Titulo(55, list.Lineactual, 'Concepto', 6, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, 'Un.', 7, 'Arial, cursiva, 8');
        list.Titulo(90, list.Lineactual, 'Importe', 8, 'Arial, cursiva, 8');

        list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
        list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
      end else Begin
        list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
        list.Titulo(0, 0, '', 1, 'Arial, negrita, 8');
        list.Titulo(30, list.Lineactual, '', 2, 'Arial, negrita, 8');
        list.Titulo(75, list.Lineactual, '', 3, 'Arial, negrita, 8');
        list.Titulo(0, 0, '', 1, 'Arial, negrita, 8');
        list.Titulo(30, list.Lineactual, '', 2, 'Arial, negrita, 8');

        list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
        list.Titulo(0, 0, '', 1, 'Arial, negrita, 12');
        list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

        list.Titulo(0, 0, '', 1, 'Arial, normal, 10');
        list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
        list.Titulo(7,  list.Lineactual, '', 2, 'Arial, cursiva, 8');
        list.Titulo(30, list.Lineactual, '', 3, 'Arial, cursiva, 8');
        list.Titulo(35, list.Lineactual, '', 4, 'Arial, cursiva, 8');
        list.Titulo(50, list.Lineactual, '', 5, 'Arial, cursiva, 8');
        list.Titulo(60, list.Lineactual, '', 6, 'Arial, cursiva, 8');
        list.Titulo(70, list.Lineactual, '', 7, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, '', 8, 'Arial, cursiva, 8');

        list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
        list.Titulo(30, list.Lineactual, '', 2, 'Arial, cursiva, 8');
        list.Titulo(35, list.Lineactual, '', 3, 'Arial, cursiva, 8');
        list.Titulo(50, list.Lineactual, '', 4, 'Arial, cursiva, 8');
        list.Titulo(60, list.Lineactual, '', 5, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, '', 6, 'Arial, cursiva, 8');
        list.Titulo(0, 0, '', 1, 'Arial, normal, 10');

        list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
        list.Titulo(30, list.Lineactual, '', 2, 'Arial, cursiva, 8');
        list.Titulo(50, list.Lineactual, '', 3, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, '', 4, 'Arial, cursiva, 8');
        list.Titulo(0, 0, '', 1, 'Arial, normal, 10');

        list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
        list.Titulo(30, list.Lineactual, '', 2, 'Arial, cursiva, 8');
        list.Titulo(40, list.Lineactual, '', 3, 'Arial, cursiva, 8');
        list.Titulo(60, list.Lineactual, '', 4, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, '', 5, 'Arial, cursiva, 8');
        list.Titulo(0, 0, '', 1, 'Arial, normal, 10');

        list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
        list.Titulo(5,  list.Lineactual, '', 2, 'Arial, cursiva, 8');
        list.Titulo(35, list.Lineactual, '', 3, 'Arial, cursiva, 8');
        list.Titulo(43, list.Lineactual, '', 4, 'Arial, cursiva, 8');
        list.Titulo(50, list.Lineactual, '', 5, 'Arial, cursiva, 8');
        list.Titulo(55, list.Lineactual, '', 6, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, '', 7, 'Arial, cursiva, 8');
        list.Titulo(90, list.Lineactual, '', 8, 'Arial, cursiva, 8');

        list.Titulo(0, 0, '', 1, 'Arial, normal, 11');
        list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
      end;
    end;

    if (salida = 'T') then Begin
      if not ocultar_titulos then Begin
        list.LineaTxt(CHR(18), True);
        list.LineaTxt(utiles.StringLongitudFija(empresa.Nombre, 31), False);
        list.LineaTxt(utiles.StringLongitudFija(empresa.Domicilio, 31), False);
        list.LineaTxt('Liq.: ' + xnroliq +  ', Per.: ' + xperiodo, True);
        list.LineaTxt(utiles.StringLongitudFija(empresa.Actividad, 31), False);
        list.LineaTxt('C.U.I.T.: ' + empresa.CUIT, True);

        list.LineaTxt('', True);
        list.LineaTxt('Hojas Móviles en Reemplazo del Libro Especial Lay 20744 T.O. (art. 52)', True);
        list.LineaTxt(CHR(15), True);

        list.LineaTxt(CHR(18) + lin + CHR(15), True);
        list.LineaTxt('Legajo Apellido y Nombre             C. de  Calificacion Fecha  Fecha   Categoria Remuneracion', True);
        list.LineaTxt('                                     Costo  Profesional  Ingr. Egreso             Asignada', True);
        list.LineaTxt(CHR(18) + lin + CHR(15), True);

        list.LineaTxt('Lugar de Trabajo             Contratación          Regimen Previsional      Mensual/Jornal', True);
        list.LineaTxt(CHR(18) + lin + CHR(15), True);

        list.LineaTxt('Fe.Nac. E.Civil Domicilio                           Provincia      C.U.I.L./Doc.', True);
        list.LineaTxt(CHR(18) + lin + CHR(15), True);

        list.LineaTxt('Cód. Concepto            Un.    Importe  Cód. Concepto            Un.    Importe', True);

        list.LineaTxt(CHR(18) + lin + CHR(15), True);
        list.LineaTxt(CHR(15), True);
        lineas := 16;
      end else Begin
        list.LineaTxt(CHR(18), True);
        list.LineaTxt('', False);
        list.LineaTxt('', False);
        list.LineaTxt('', True);
        list.LineaTxt('', False);
        list.LineaTxt('', True);

        list.LineaTxt('', True);
        list.LineaTxt('', True);
        list.LineaTxt('', True);

        list.LineaTxt('', True);
        list.LineaTxt('', True);
        list.LineaTxt('', True);
        list.LineaTxt('', True);

        list.LineaTxt('', True);
        list.LineaTxt('', True);

        list.LineaTxt('', True);
        list.LineaTxt('', True);

        list.LineaTxt('', True);

        list.LineaTxt('', True);
        list.LineaTxt(CHR(15), True);
        lineas := 16;
      end;
    end;
  end;
end;

procedure TTLiquidacionSueldo.ListDetalle(xcodemp, xperiodo, xnroliq: String; xlisttitulos: Boolean; salida: char);
// Objetivo...: Listar Items
var
  i: Integer;
Begin
  For i := 1 to ln do Begin
    if (salida = 'P') or (salida = 'P') then Begin
      if not ocultar_detalle then Begin
        list.Linea(0, 0, detsueldo[i, 1], 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(5, list.Lineactual, detsueldo[i, 2], 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(35, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'N');
        list.importe(49, list.Lineactual, '#######.##', StrToFloat(utiles.FormatearNumero(detsueldo[i, 3])), 4, 'Arial, normal, 8');
        list.Linea(55, list.Lineactual, detsueldo[i, 4], 5, 'Arial, normal, 8', salida, 'N');
        list.Linea(60, list.Lineactual, detsueldo[i, 5], 6, 'Arial, normal, 8', salida, 'N');
        list.Linea(90, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual, '#######.##', StrToFloat(utiles.FormatearNumero(detsueldo[i, 6])), 8, 'Arial, normal, 8');
        list.Linea(95, list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
      end else Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(5, list.Lineactual, '', 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(35, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'N');
        list.importe(49, list.Lineactual, '#######.##', 0, 4, 'Arial, normal, 8');
        list.Linea(55, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'N');
        list.Linea(60, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'N');
        list.Linea(90, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual, '#######.##', 0, 8, 'Arial, normal, 8');
        list.Linea(95, list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
      end;
    end;
    if (salida = 'T') then Begin
      if not ocultar_detalle then Begin
        list.LineaTxt(detsueldo[i, 1] + ' ', False);
        list.LineaTxt(utiles.StringLongitudFija(detsueldo[i, 2], 30), False);
        list.LineaTxt('      ', False);
        list.importeTxt(StrToFloat(utiles.FormatearNumero(detsueldo[i, 3])), 10, 2, False);
        list.LineaTxt(' ' + detsueldo[i, 4] + ' ', False);
        list.LineaTxt(utiles.StringLongitudFija(detsueldo[i, 5], 30), False);
        list.LineaTxt('      ', False);
        list.importeTxt(StrToFloat(utiles.FormatearNumero(detsueldo[i, 6])), 10, 2, True);
        Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
      end else Begin
        list.LineaTxt('', False);
        list.LineaTxt('', False);
        list.LineaTxt('', False);
        list.LineaTxt('', False);
        list.LineaTxt('', False);
        list.LineaTxt('', False);
        list.LineaTxt('', False);
        list.LineaTxt('', True);
        Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
      end;
    end;
  end;

  IniciarArrays;
  ln := 0;
end;

procedure TTLiquidacionSueldo.ListSubtotal(xcodemp, xperiodo, xnroliq: String; xlisttitulos: Boolean; salida: char);
// Objetivo...: Listar Linea Subtotales
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    if not ocultar_detalle then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Rem. Suj. a Retenc.: ', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(25, list.Lineactual, '', totales[1], 2, 'Arial, normal, 8');
      list.Linea(27, list.lineactual, 'Haberes Exentos: ', 3, 'Arial, normal, 8', salida, 'N');
      list.importe(50, list.Lineactual, '', totales[2], 4, 'Arial, normal, 8');
      list.Linea(52, list.Lineactual, 'Retenciones: ', 5, 'Arial, normal, 8', salida, 'N');
      list.importe(73, list.Lineactual, '', totales[3], 6, 'Arial, normal, 8');
      list.Linea(76, list.Lineactual, 'NETO: ', 7, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', (totales[1] + totales[2]) - totales[3], 8, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(25, list.Lineactual, '####', 0, 2, 'Arial, normal, 8');
      list.Linea(27, list.lineactual, '', 3, 'Arial, normal, 8', salida, 'N');
      list.importe(50, list.Lineactual, '####', 0, 4, 'Arial, normal, 8');
      list.Linea(52, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'N');
      list.importe(73, list.Lineactual, '####', 0, 6, 'Arial, normal, 8');
      list.Linea(76, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '####', 0, 8, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;
  end;
  if (salida = 'T') then Begin
    if not ocultar_detalle then Begin
      list.LineaTxt('Rem. Suj. a Retenc.: ', False);
      list.importeTxt(totales[1], 11, 2, False);
      list.LineaTxt(' Haberes Exentos: ', False);
      list.importeTxt(totales[2], 11, 2, False);
      list.LineaTxt(' Retenciones: ', False);
      list.importeTxt(totales[3], 11, 2, False);
      list.LineaTxt(' NETO: ', False);
      list.importeTxt((totales[1] + totales[2]) - totales[3], 11, 2, True);
      Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
      list.LineaTxt(CHR(18) + lin + CHR(15), True);
      Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
      list.LineaTxt('', True);
      Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
      list.LineaTxt(CHR(18) + lin + CHR(15), True);
      Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
    end else Begin
      list.LineaTxt('', False);
      list.LineaTxt('', False);
      list.LineaTxt('', False);
      list.LineaTxt('', False);
      list.LineaTxt('', False);
      list.LineaTxt('', False);
      list.LineaTxt('', False);
      list.LineaTxt('', True);
      Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
      list.LineaTxt('', True);
      Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
      list.LineaTxt('', True);
      Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
      list.LineaTxt('', True);
      Inc(lineas); if controlarsalto then ListTituloLibro(xcodemp, xperiodo, xnroliq, True, salida);
    end;
  end;

  totales[1] := 0; totales[2] := 0; totales[3] := 0;
end;

procedure TTLiquidacionSueldo.ListarEncabezadoLibro(xlista: TStringList; xperiodo, xnroliq, xcodemp: String; salida: char);
// Objetivo...: Listar Encabezado Libro
Begin
  ocultar_detalle := True;
  ListarLibro(xlista, xperiodo, xnroliq, xcodemp, salida);
  ocultar_detalle := False;
end;

procedure TTLiquidacionSueldo.ListarDetalleLibro(xlista: TStringList; xperiodo, xnroliq, xcodemp: String; salida: char);
// Objetivo...: Listar Detalle Libro
Begin
  ocultar_titulos := True;
  ListarLibro(xlista, xperiodo, xnroliq, xcodemp, salida);
  ocultar_titulos := False;
end;

function  TTLiquidacionSueldo.BuscarRecibo(xnrolegajo, xperiodo, xnroliq: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  if recibos.IndexFieldNames <> 'NROLEGAJO;PERIODO;NROLIQ' then recibos.IndexFieldNames := 'NROLEGAJO;PERIODO;NROLIQ';
  Result := objfirebird.Buscar(recibos, 'NROLEGAJO;PERIODO;NROLIQ', xnrolegajo, xperiodo, xnroliq);
end;

function  TTLiquidacionSueldo.setNroRecibo(xnrolegajo, xperiodo, xnroliq: String): String;
// Objetivo...: Recuperar Nro. de Recibo
begin
  if BuscarRecibo(xnrolegajo, xperiodo, xnroliq) then Begin
    Result := recibos.FieldByName('recibo').AsString
  end else Begin
    recibos.IndexFieldNames := 'NROLEGAJO;RECIBO';
    objfirebird.Filtrar(recibos, 'NROLEGAJO = ' + '''' + xnrolegajo + '''');
    if recibos.RecordCount = 0 then Result := '1' else Begin
      recibos.Last;
      Result := IntToStr(recibos.FieldByName('recibo').AsInteger + 1);
    end;
    objfirebird.QuitarFiltro(recibos);
    recibos.IndexFieldNames := 'NROLEGAJO;PERIODO;NROLIQ';
  end;
end;

procedure TTLiquidacionSueldo.GuardarRecibo(xnrolegajo, xperiodo, xnroliq, xrecibo, xlugar, xfecha, xfechadep: String);
// Objetivo...: Guardar Recibo
begin
  if BuscarRecibo(xnrolegajo, xperiodo, xnroliq) then recibos.Edit else recibos.Append;
  recibos.FieldByName('nrolegajo').AsString := xnrolegajo;
  recibos.FieldByName('periodo').AsString   := xperiodo;
  recibos.FieldByName('nroliq').AsString    := xnroliq;
  recibos.FieldByName('recibo').AsString    := xrecibo;
  recibos.FieldByName('lugar').AsString     := xlugar;
  recibos.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  recibos.FieldByName('fechadep').AsString  := utiles.sExprFecha2000(xfechadep);
  try
    recibos.Post
   except
    recibos.Cancel
  end;
  objfirebird.RegistrarTransaccion(recibos);
end;

procedure TTLiquidacionSueldo.BorrarRecibo(xnrolegajo, xperiodo, xnroliq: String);
// Objetivo...: Borrar Instancia
begin
  if BuscarRecibo(xnrolegajo, xperiodo, xnroliq) then Begin
    recibos.Delete;
    objfirebird.RegistrarTransaccion(recibos);
  end;
end;

procedure TTLiquidacionSueldo.getRecibo(xnrolegajo, xperiodo, xnroliq: String);
// Objetivo...: Recuperar Instancia Recibo
Begin
  if BuscarRecibo(xnrolegajo, xperiodo, xnroliq) then Begin
    recibo   := recibos.FieldByName('recibo').AsString;
    lugar    := recibos.FieldByName('lugar').AsString;
    fechaco  := utiles.sFormatoFecha(recibos.FieldByName('fecha').AsString);
    fechadep := utiles.sFormatoFecha(recibos.FieldByName('fechadep').AsString);
  end else Begin
    recibo := ''; lugar := ''; fechaco := ''; fechadep := '';
  end;
end;

procedure TTLiquidacionSueldo.IniciarArrays;
// Objetivo...: Iniciar Arreglos
var
  i, j: Integer;
Begin
  for i := 1 to 100 do
    for j := 1 to 6 do detsueldo[i, j] := '';
end;

function TTLiquidacionSueldo.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  k: Integer;
begin
  Result := False;
  if lineas >= LineasPag then Begin
    if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else
      for k := 1 to lineas_blanco do list.LineaTxt('', True);
    Result := True;
  end;
end;

procedure TTLiquidacionSueldo.RealizarSalto;
// Objetivo...: imprimir lineas en blanco hasta realizar salto de página
var
  k: Integer;
begin
  if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else Begin
    for k := lineas + 1 to LineasPag do list.LineaTxt('', True);
    lineas := LineasPag + 5;
    ControlarSalto;
  end;
end;

procedure TTLiquidacionSueldo.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not itsueldo.Active then itsueldo.Open;
    if not liquidacion.Active then liquidacion.Open;
    if not modelosimpr.Active then modelosimpr.Open;
    if not recibos.Active then recibos.Open;
  end;
  Inc(conexiones);
  conceptoliq.conectar;
  empleado.conectar;
  gremio.conectar;
  jubilacionsueldo.conectar;
end;

procedure TTLiquidacionSueldo.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    objfirebird.closeDB(liquidacion);
    objfirebird.closeDB(itsueldo);
    objfirebird.closeDB(modelosimpr);
    objfirebird.closeDB(recibos);
  end;
  conceptoliq.desconectar;
  empleado.desconectar;
  gremio.desconectar;
  jubilacionsueldo.desconectar;
end;

{===============================================================================}

function liquidacionsueldo: TTLiquidacionSueldo;
begin
  if xliquidacionsueldo = nil then
    xliquidacionsueldo := TTLiquidacionSueldo.Create;
  Result := xliquidacionsueldo;
end;

{===============================================================================}

initialization

finalization
  xliquidacionsueldo.Free;

end.
