unit CIva_Gasparutti;

interface

uses CLibCont, CTablaIva, CCNetos, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CEmpresas, CProvin;

const
  meses: array[1..12] of string = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre');
  elementos = 11;

type

TTIva = class(TTLibrosCont)
  idcompr, tipo, sucursal, numero, cuit, clipro, rsocial, codiva, concepto, ferecep, fecha, codprovin, codmov, tipomov: string;
  nettot, nettot1, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper, saldoanter: real;
  neto, ivari, ivarni, total: real; LineasFinal: Integer;
  iva_existe, infresumido: boolean;
  tiva, iiva, saldoiva: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   CalcularIva(xneto, xtotal: real; xcondfisc: string);
  procedure   CalcularIvaCoefInverso(xneto, xtotal, xcoeinverso: real; xcondfisc: string);
  procedure   CalcularIvaMovimiento(xneto, xtotal: real; xcondfisc: string);
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper, xretencion, ximporte: real); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xnettot1, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper, xretencion, ximporte: real); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems, xfecha, xitems: string; xNettot, xIvari, xIvarec: real); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems, xfecha, xitems: string; xNettot, xNettot1, xIvari, xIvarec: real); overload;
  procedure   Borrar(xidcompr, xtipo, xsucursal, xnumero, xcuit: string); overload;
  procedure   BorrarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);
  function    Buscar(xidcompr, xtipo, xsucursal, xnumero, xcuit: string): boolean; overload;
  function    BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems: string): boolean;
  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);
  function    setItems(xidcompr, xtipo, xsucursal, xnumero, xcuit: string): TQuery;
  procedure   FijarSaldoPeriodoAnterior(xperiodo: string; xsaldoanter: real);
  procedure   getDatosSaldo(xperiodo: string);

  procedure   Depurar(xfecha: string); overload;
  procedure   Depurar(xfecha, xtipomov: string); overload;

  procedure   IniciarListado;
  procedure   IniciarPagina(pagini: integer);
  procedure   ListarNeto(movi: string; salida: char);
  procedure   Listar_Netodiscr(op: string; salida: char);
  procedure   ListCodpfis(op: string; salida: char);
  function    selIva: TQuery; overload;
  function    selIva(xtipomov: string): TQuery; overload;
  function    setIva(xdf, xhf: string): TQuery; overload;
  function    setAuditoria(xfecha: string): TQuery;
  procedure   FiltrarMovimientos(xtipomov: string);
  procedure   ListInfAnual(xperiodo, xdfr, xhfr: string; salida: char; xfecharecep: boolean);
  procedure   PresentarInforme;
  procedure   IniciarInfSubtotales(salida: char; LineasSubtotales: Integer);

  procedure   vaciarBuffer;
  procedure   Via(xvia: string);
  procedure   FijarVia(xvia: string);
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;

  mesanter, df, hf: string;
  ctotales: array[1..12, 1..elementos] of real;
  vtotales: array[1..12, 1..elementos]  of real;
  finales : array[1..4]         of real;
  {totNettot, totOpexenta, totConnograv, totIva, totIvarec, totPercepcion, totPeringb, totTotOper, totDebfiscal: real;}
  procedure PrepararCompras(xperiodo, xdfr, xhfr: string; salida: char; fecharecep: boolean);
  procedure PrepararVentas(xperiodo, xdfr, xhfr: string; salida: char; fecharecep: boolean);
  procedure Listar(salida: char);
  procedure transpMes(mesanter, operacion: string);
  procedure iniciarTot;
  procedure TOperacion(salida: char; movim: string);
  procedure ListTotal(xoperacion, salida: char);
  procedure ListResumen(xperiodo: string; salida: char);
  procedure Titulo(salida: char; movim, xperiodo: string);
 protected
  tipolist: char; nropagina, lineasimpresas: integer;
  xmes, rsocial1, rsocial2, nrocuit, dir_tel, path, lin, nombre: string;
  totNettot, totNettot1, totOpexenta, totConnograv, totIva, totIvarec, totPercepcion, totPergan, totTotOper, totCdfiscal, totRetencion: real;
  tctotNettot, tctotOpexenta, tctotConnograv, tctotIva, tctotIvarec, tctotPercep1, tctotCdfiscal, tctotPercep2, tctotTotOper, totcRetencion: real;  // Totales Anuales
  inf_iniciado: boolean;
  archivo     : TextFile;

  procedure  trans_datos;
  procedure  iniciar_datos;
  procedure  Act_atributos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov: string;
                    xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real);
  procedure  IniciarInforme(salida: char); override;
  procedure  ListarIva(movi: string; salida: char);
  procedure  Tit_Netodiscr(tipolist: char); overload;
  procedure  Tit_Listcodpfis(tipolist: char);
end;

function iva: TTIva;

implementation

var
  xiva: TTIva = nil;

constructor TTIva.Create;
begin
  inherited Create;
end;

destructor TTIva.Destroy;
begin
  inherited Destroy;
end;

procedure TTIva.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero, xcuit) then tiva.Edit else tiva.Append;
  Act_atributos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
end;

procedure TTIva.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real);
// Objetivo...: Grabar Atributos del Objeto - Identificar los movimientos autom�ticos de los ingresados manualmente a trav�s del libro de I.V.A.
var
  f: boolean;
begin
  f := tiva.Filtered;
  if f then tiva.Filtered := False;
  Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
  tiva.Edit;
  tiva.FieldByName('tipomov').AsString   := xtipomov;
  try
    tiva.Post;
   except
    tiva.Cancel;
  end;
  if f then tiva.Filtered := True;
end;

procedure TTIva.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper, xretencion, ximporte: real);
// Objetivo...: Grabar Atributos del Objeto - Identificar los movimientos autom�ticos de los ingresados manualmente a trav�s del libro de I.V.A.
var
  f: boolean;
begin
  f := tiva.Filtered;
  if f then tiva.Filtered := False;
  Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
  tiva.Edit;
  tiva.FieldByName('tipomov').AsString   := xtipomov;
  tiva.FieldByName('retencion').AsFloat  := xretencion;
  tiva.FieldByName('importe').AsFloat    := ximporte;
  try
    tiva.Post;
   except
    tiva.Cancel;
  end;
  if f then tiva.Filtered := True;
end;

procedure TTIva.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xnettot1, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper, xretencion, ximporte: real);
// Objetivo...: Grabar Atributos del Objeto - 2 Netos
var
  f: boolean;
begin
  f := tiva.Filtered;
  if f then tiva.Filtered := False;
  Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
  tiva.Edit;
  tiva.FieldByName('tipomov').AsString   := xtipomov;
  tiva.FieldByName('retencion').AsFloat  := xretencion;
  tiva.FieldByName('importe').AsFloat    := ximporte;
  tiva.FieldByName('nettot1').AsFloat    := xnettot1;
  try
    tiva.Post;
   except
    tiva.Cancel;
  end;
  if f then tiva.Filtered := True;
end;

procedure TTIva.Act_atributos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xfecha, xferecep, xcodprovin, xcodmov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real);
// Objetivo...: Actualizar atributos
begin
  tiva.FieldByName('idcompr').AsString   := xidcompr;
  tiva.FieldByName('tipo').AsString      := xtipo;
  tiva.FieldByName('sucursal').AsString  := xsucursal;
  tiva.FieldByName('numero').AsString    := xnumero;
  tiva.FieldByName('cuit').AsString      := xcuit;
  tiva.FieldByName('clipro').AsString    := xclipro;
  tiva.FieldByName('rsocial').AsString   := xrsocial;
  tiva.FieldByName('codiva').AsString    := xcodiva;
  tiva.FieldByName('concepto').AsString  := xconcepto;
  tiva.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
  tiva.FieldByName('ferecep').AsString   := utiles.sExprFecha(xferecep);
  tiva.FieldByName('codprovin').AsString := xcodprovin;
  tiva.FieldByName('codmov').AsString    := xcodmov;
  tiva.FieldByName('nettot').AsFloat     := xnettot;
  tiva.FieldByName('opexenta').AsFloat   := xopexenta;
  tiva.FieldByName('connograv').AsFloat  := xconnograv;
  tiva.FieldByName('iva').AsFloat        := xiva;
  tiva.FieldByName('ivarec').AsFloat     := xivarec;
  tiva.FieldByName('percep1').AsFloat    := xpercep1;
  tiva.FieldByName('percep2').AsFloat    := xpercep2;
  tiva.FieldByName('cdfiscal').AsFloat   := xcdfiscal;
  tiva.FieldByName('totoper').AsFloat    := xtotoper;
  try
    tiva.Post;
  except
    tiva.Cancel;
  end;
end;

procedure TTIva.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems, xfecha, xitems: string; xNettot, xIvari, xIvarec: real);
// Objetivo...: Grabar una L�nea de detalle para un movimiento de IVA
var
  t: string;
begin
  t := iiva.TableName;
  if (xcoditems = '001') and (iva_existe) then BorrarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit);
  if BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems) then iiva.Edit else iiva.Append;
  iiva.FieldByName('idcompr').AsString  := xidcompr;
  iiva.FieldByName('tipo').AsString     := xtipo;
  iiva.FieldByName('sucursal').AsString := xsucursal;
  iiva.FieldByName('numero').AsString   := xnumero;
  iiva.FieldByName('cuit').AsString     := xcuit;
  iiva.FieldByName('codmov').AsString   := xcodmov;
  iiva.FieldByName('coditems').AsString := xcoditems;
  iiva.FieldByName('items').AsString    := xitems;
  iiva.FieldByName('fecha').AsString    := utiles.sExprFecha(xfecha);
  iiva.FieldByName('nettot').AsFloat    := xnettot;
  iiva.FieldByName('iva').AsFloat       := xIvari;
  iiva.FieldByName('ivarec').AsFloat    := xIvarec;
  try
    iiva.Post;
   except
    iiva.Cancel;
  end;
end;

procedure TTIva.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems, xfecha, xitems: string; xNettot, xNettot1, xIvari, xIvarec: real);
// Objetivo...: Grabar una L�nea de detalle para un movimiento de IVA
begin
  Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems, xfecha, xitems, xNettot, xIvari, xIvarec);
  iiva.Edit;
  iiva.FieldByName('nettot1').AsFloat := xnettot1;
  try
    iiva.Post;
   except
    iiva.Cancel;
  end;
end;

function TTIva.BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems: string): boolean;
// Objetivo...: Buscar un Movimiento
begin
  iiva.Filtered := False;
  Result := datosdb.Buscar(iiva, 'idcompr', 'tipo', 'sucursal', 'numero', 'cuit', 'codmov', 'coditems', xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems);
end;

function TTIva.Buscar(xidcompr, xtipo, xsucursal, xnumero, xcuit: string): boolean;
// Objetivo...: Buscar un Movimiento
begin
  iva_existe := datosdb.Buscar(tiva, 'idcompr', 'tipo', 'sucursal', 'numero', 'cuit', xidcompr, xtipo, xsucursal, xnumero, xcuit);
  Result     := iva_existe;
end;

procedure TTIva.Borrar(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero, xcuit) then Begin
    tiva.Delete;  // Movimiento maestro
    BorrarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit);   // Detalle
    getDatos(tiva.FieldByName('idcompr').AsString, tiva.FieldByName('tipo').AsString, tiva.FieldByName('sucursal').AsString, tiva.FieldByName('numero').AsString, tiva.FieldByName('cuit').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

procedure TTIva.BorrarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Eliminar un Items
begin
  datosdb.tranSQL(path, 'DELETE FROM ' + iiva.TableName + ' WHERE idcompr = ' + '"' + xidcompr + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND sucursal = ' + '"' + xsucursal + '"' + ' AND numero = ' + '"' + xnumero + '"' + ' AND cuit = ' + '"' + xcuit + '"');
end;

procedure  TTIva.getDatos(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero, xcuit) then trans_datos else iniciar_datos;
end;

procedure TTIva.trans_datos;
// Objetivo...: Cargar los atributos
begin
  idcompr  := tiva.FieldByName('idcompr').AsString;
  tipo     := tiva.FieldByName('tipo').AsString;
  sucursal := tiva.FieldByName('sucursal').AsString;
  numero   := tiva.FieldByName('numero').AsString;
  cuit     := tiva.FieldByName('cuit').AsString;
  clipro   := tiva.FieldByName('clipro').AsString;
  rsocial  := tiva.FieldByName('rsocial').AsString;
  codiva   := tiva.FieldByName('codiva').AsString;
  concepto := tiva.FieldByName('concepto').AsString;
  ferecep  := utiles.sFormatoFecha(tiva.FieldByName('ferecep').AsString);
  fecha    := utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString);
  codprovin:= tiva.FieldByName('codprovin').AsString;
  codmov   := tiva.FieldByName('codmov').AsString;
  nettot   := tiva.FieldByName('nettot').AsFloat;
  opexenta := tiva.FieldByName('opexenta').AsFloat;
  connograv:= tiva.FieldByName('connograv').AsFloat;
  iva      := tiva.FieldByName('iva').AsFloat;
  ivarec   := tiva.FieldByName('ivarec').AsFloat;
  percep1  := tiva.FieldByName('percep1').AsFloat;
  percep2  := tiva.FieldByName('percep2').AsFloat;
  cdfiscal := tiva.FieldByName('cdfiscal').AsFloat;
  totoper  := tiva.FieldByName('totoper').AsFloat;
  tipomov  := tiva.FieldByName('tipomov').AsString;
end;

procedure TTIva.iniciar_datos;
// Objetivo...: Iniciar los datos
begin
  idcompr := ''; tipo := ''; sucursal := ''; numero := ''; cuit := ''; clipro := ''; rsocial := ''; codiva := ''; concepto := ''; ferecep := ''; fecha := ''; codprovin := ''; codmov := ''; tipomov := ''; nettot := 0; opexenta := 0; connograv := 0; iva := 0; ivarec := 0; percep1 := 0; percep2 := 0; cdfiscal := 0; totoper := 0;
end;

function TTIva.setItems(xidcompr, xtipo, xsucursal, xnumero, xcuit: string): TQuery;
// Objetivo...: Retornar un Set de movimientos para un comprobante dado
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + iiva.TableName + ' WHERE tipo = ' + '"' + xtipo + '"' + ' and sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' and cuit = ' + '"' + xcuit + '"');
end;

procedure TTIva.FiltrarMovimientos(xtipomov: string);
// Objetivo...: Aislar movimientos de I.V.A. (Manuales/Autom�ticos)
begin
  datosdb.Filtrar(tiva, 'Tipomov = ' + '''' + xtipomov + '''');
end;

procedure TTIva.CalcularIva(xneto, xtotal: real; xcondfisc: string);
//Objetivo...: Clacular I.V.A
begin
  // Inicializamos los c�lculos de I.V.A.
  neto  := xneto; total := xtotal;
  ivari := 0; ivarni := 0;
  if tabliva.Buscar(xcondfisc) then
    begin
      tabliva.getDatos(xcondfisc);  // Cargamos los datos
      if (tabliva.AV = 'S') or (tabliva.AC = 'S')  then  // Si la condici�n est� Activa en Compras
        begin
          ivari := xneto * (tabliva.Ivari * 0.01);
          if tabliva.Ivarni > 0 then ivarni := xneto * (tabliva.Ivarni * 0.01);  // IVA Recargo
        end;

      // C�lculo a partir del Total
      if tabliva.Coeinverso > 0 then
        begin
          neto := StrToFloat(FormatFloat('######0.000000', xtotal / tabliva.Coeinverso));
          ivari := neto * (tabliva.Ivari * 0.01);
        end;
    end;
end;

procedure TTIva.CalcularIvaCoefInverso(xneto, xtotal, xcoeinverso: real; xcondfisc: string);
//Objetivo...: Clacular I.V.A
begin
  // Inicializamos los c�lculos de I.V.A.
  neto  := xneto; total := xtotal;
  ivari := 0; ivarni := 0;
  if tabliva.Buscar(xcondfisc) then
    begin
      tabliva.getDatos(xcondfisc);  // Cargamos los datos
      if (tabliva.AV = 'S') or (tabliva.AC = 'S')  then  // Si la condici�n est� Activa en Compras
        begin
          ivari := xneto * (tabliva.Ivari * 0.01);
          if tabliva.Ivarni > 0 then ivarni := xneto * (tabliva.Ivarni * 0.01);  // IVA Recargo
        end;

      // C�lculo a partir del Total
      if xcoeinverso > 0 then Begin
        neto := StrToFloat(FormatFloat('######0.000000', xtotal / xcoeinverso));
        ivari := neto * ((xcoeinverso - 1));
      end;
    end;
end;

procedure TTIva.CalcularIvaMovimiento(xneto, xtotal: real; xcondfisc: string);
// Objetivo...: Calcular I.V.A. a partir del c�digo de movimiento del Neto
begin
  if netos.Buscar(xcondfisc) then Begin
    netos.getDatos(xcondfisc);
    CalcularIva(xneto, xtotal, netos.codiva);
  end;
end;

function TTIva.selIva: TQuery;
// Objetivo...: retornar un set con los Movimientos de Iva
begin
  Result := datosdb.tranSQL(path, 'SELECT fecha, idcompr, tipo, sucursal, numero, clipro, rsocial, cuit, codiva, nettot, iva, ivarec, totoper FROM ' + tiva.TableName + ' ORDER BY fecha');
end;

function TTIva.selIva(xtipomov: string): TQuery;
// Objetivo...: retornar un subset con los movimientos de I.V.A. para un periodo dado
begin
  Result := datosdb.tranSQL(path, 'SELECT fecha, idcompr AS IDC, tipo AS Tipo, sucursal, numero, cuit AS CUIT, codiva AS IVA, nettot AS Neto FROM ' + tiva.TableName + ' WHERE tipomov = ' + '''' + xtipomov + '''' + ' ORDER BY fecha');
end;

function TTIva.setAuditoria(xfecha: string): TQuery;
// Objetivo...: retornar un set con los Movimientos de Iva
begin
  Result := datosdb.tranSQL(path, 'SELECT fecha, idcompr, tipo, sucursal, numero, clipro, rsocial, cuit, codiva, nettot, iva, ivarec, totoper FROM ' + tiva.TableName + ' WHERE fecha = ' + '"' + xfecha + '"' + ' ORDER BY fecha');
end;

procedure TTIva.Depurar(xfecha: string);
// Objetivo...: Depurar aquellos movimientos Inferiores al Periodo Seleccionado
begin
  datosDB.tranSQL(path, 'DELETE FROM ' + tiva.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha(xfecha) + '''');
  datosDB.tranSQL(path, 'DELETE FROM ' + iiva.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha(xfecha) + '''');
end;

procedure TTIva.Depurar(xfecha, xtipomov: string);
// Objetivo...: Depurar aquellos movimientos Inferiores al Periodo Seleccionado, seleccionando ademas el tipo de movimiento (autom�tico/manual)
begin
  datosDB.tranSQL(path, 'DELETE FROM ' + tiva.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha(xfecha) + '''' + ' AND tipomov = ' + '''' + xtipomov + '''');
  datosDB.tranSQL(path, 'DELETE FROM ' + iiva.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha(xfecha) + '''' + ' AND tipomov = ' + '''' + xtipomov + '''');
end;

//******************** OPERACIONES COMUNES DE IMPRESION ******************

procedure TTIva.IniciarListado;
// Objetivo...: Inicializar los atributos a utilizar en los informes
begin
  list.altopag := 0; list.m := 0; pag := 0;
  inf_iniciado := True;
end;

procedure TTIva.IniciarInforme(salida: char);
// Objetivo...: Desencadenar una secuencia de eventos para la Preparaci�n de Informes
begin
  IniciarListado;          // Emisi�n M�ltiple
  list.Setear(salida);     // Iniciar Listado
  list.FijarSaltoManual;   // Controlamos el Salto de la P�gina
  if salida = 'T' then list.IniciarImpresionModoTexto else list.ImprimirHorizontal;
end;

procedure  TTIva.IniciarInfSubtotales(salida: char; LineasSubtotales: Integer);
begin
  //list.ReservarLineasParaSubtotales(LineasSubtotales);
  IniciarInforme(salida);
end;

procedure TTIva.IniciarPagina(pagini: integer);
// Objetivo...: Determinar la p�gina de inicio
begin
  nropagina := pagini;
end;

procedure TTIva.ListarNeto(movi: string; salida: char);
// Objetivo...: Listar Linea
begin
  netos.getDatos(movi);
  list.Linea(0, 0, movi, 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(6, list.lineactual, netos.Descrip, 2, 'Arial, normal, 8', salida, 'N');
  list.importe(70, list.lineactual, '', totNettot, 3, 'Arial, normal, 8');
  list.importe(88, list.lineactual, '', totIva, 4, 'Arial, normal, 8');
  list.importe(108, list.lineactual, '', totIvarec, 5, 'Arial, normal, 8');
  list.Linea(115, list.lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
  totNettot := 0; totIva := 0; totIvarec := 0;totCdfiscal := 0;
end;

procedure TTIva.Tit_Netodiscr(tipolist: char);
{Objetivo....: Emitir los T�tulos del Listado}
begin
  pag := pag + 1;
  ListDatosEmpresa(tipolist);
  list.Titulo(0, 0, 'Totales I.V.A. por Netos Discriminados', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, utiles.espacios(394) + 'Hoja N�: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), 1, 'Times New Roman, ninguno, 8');
  list.Titulo(0, 0, 'Neto Discriminado',1 , 'Arial, cursiva, 8');
  list.Titulo(60, list.lineactual, 'Neto/Tot/Exento',2 , 'Arial, cursiva, 8');
  list.Titulo(78, list.lineactual, 'I.V.A. (Normal)',3 , 'Arial, cursiva, 8');
  list.Titulo(97, list.lineactual, 'I.V.A. (Recargo)',4 , 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.linealargopagina(tipolist), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');
end;

procedure TTIva.Listar_Netodiscr(op: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
var
  netoanterior: string;
begin
  // Datos para Iniciar Reporte
  list.IniciarTitulos; Tit_Netodiscr(salida);
  if op = 'Netos Discriminados en Ventas' then  // Si se trata de un contribuyente distinto efectuamos un salto de p�gina
    begin
      if list.altopag > 0 then
        begin
          list.CompletarPagina;     // Provocamos el Salto de P�gina
          list.Linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'N');
          list.IniciarNuevaPagina;
          Tit_NetoDiscr(salida);
        end;
    end;

  // Netos Discriminados Ventas
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');
  list.Linea(0, 0, op, 1, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');

  // Inicializamos subtotales
  totNettot := 0; totIva := 0; totIvarec := 0;totCdfiscal := 0;

  TSQL.Open; TSQL.First;
  netoanterior := TSQL.FieldByName('codmov').AsString;
  while not TSQL.EOF do
    begin
      if TSQL.FieldByName('codmov').AsString <> netoanterior then ListarNeto(netoanterior, salida);
      netoanterior := TSQL.FieldByName('codmov').AsString;
      totNettot    := totNettot + TSQL.FieldByName('Nettot').AsFloat + TSQL.FieldByName('Nettot1').AsFloat + TSQL.FieldByName('OpExenta').AsFloat + TSQL.FieldByName('Connograv').AsFloat;
      totIva       := totIva + TSQL.FieldByName('Iva').AsFloat;
      totIvarec    := totIvarec + TSQL.FieldByName('Ivarec').AsFloat;
      totCdfiscal  := totCdfiscal + TSQL.FieldByName('Cdfiscal').AsFloat;
      TSQL.Next;
    end;
  ListarNeto(netoanterior, salida);
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');
  list.Linea(0, 0, 'Cr�d. Resoluciones Varias : ', 1, 'Arial, normal, 8', salida, 'N');
  list.importe(50, list.lineactual, '', totCdfiscal, 2, 'Arial, normal, 8');
  list.Linea(80, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  TSQL.Close;
end;

procedure TTIva.Tit_Listcodpfis(tipolist: char);
{Objetivo....: Emitir los T�tulos del Listado}
begin
  pag := pag + 1;
  ListDatosEmpresa(tipolist);
  list.Titulo(0, 0, 'Totales I.V.A. Disc. por Condiciones Fiscales', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, utiles.espacios(394) + 'Hoja N�: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), 1, 'Times New Roman, ninguno, 8');
  list.Titulo(0, 0, ' ',1 , 'Arial, normal, 7');
  // 1� L�nea de T�tulos
  list.Titulo(0, 0, 'Condici�n Fiscal',1 , 'Arial, cursiva, 8');
  list.Titulo(60, list.lineactual, 'Netos/Tot/Exento',2 , 'Arial, cursiva, 8');
  list.Titulo(76, list.lineactual, 'I.V.A. (Normal)',3 , 'Arial, cursiva, 8');
  list.Titulo(94, list.lineactual, 'I.V.A. (Diferencial)',4 , 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.linealargopagina(tipolist), 1, 'Arial, normal, 11');
end;

procedure TTIva.ListarIva(movi: string; salida: char);
// Objetivo...: Listar Linea Informe de I.V.A. discriminado por Condici�n Fiscal
begin
  tabliva.getDatos(movi);
  list.Linea(0, 0, movi, 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(5, list.lineactual, tabliva.Descrip, 2, 'Arial, normal, 8', salida, 'N');
  list.importe(72, list.lineactual, '', totNettot, 3, 'Arial, normal, 8');
  list.importe(87, list.lineactual, '', totIva, 4, 'Arial, normal, 8');
  list.importe(108, list.lineactual, '', totIvarec, 5, 'Arial, normal, 8');
  list.Linea(111, list.lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
  totNettot := 0; totIva := 0; totIvarec := 0;
end;

procedure TTIva.ListCodpfis(op: string; salida: char);
// Objetivo...: Emitir Listado Informe I.V.A. diascriminado por Condici�n Fiscal
var
  ivaanterior: string;
begin
  // Datos para Iniciar Reporte
  list.IniciarTitulos; Tit_ListCodpfis(salida);
  if op = 'I.V.A. Discriminado en Ventas' then  // Si se trata de un contribuyente distinto efectuamos un salto de p�gina
    begin
      if list.altopag > 0 then
        begin
          list.CompletarPagina;     // Provocamos el Salto de P�gina
          list.Linea(0, 0, list.linealargopagina(tipolist), 1, 'Arial, normal, 11', salida, 'N');
          list.IniciarNuevaPagina;
          Tit_NetoDiscr(salida);
        end;
    end;
  totNettot := 0; totIva := 0; totIvarec := 0;

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, op, 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  TSQL.Open; TSQL.First;
  ivaanterior := TSQL.FieldByName('codiva').AsString;
  while not TSQL.EOF do
    begin
      if TSQL.FieldByName('codiva').AsString <> ivaanterior then ListarIva(ivaanterior, salida);
      ivaanterior := TSQL.FieldByName('codiva').AsString;
      totNettot := totNettot + TSQL.FieldByName('nettot').AsFloat;
      totIva    := totIva    + TSQL.FieldByName('iva').AsFloat;
      totIvarec := totIvarec + TSQL.FieldByName('ivarec').AsFloat;
      TSQL.Next;
    end;
  if totNettot <> 0 then ListarIva(ivaanterior, salida);
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');

  list.Linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  TSQL.Close;
end;

function TTIva.setIva(xdf, xhf: string): TQuery;
// Objetivo...: retornar un subset con los movimientos de I.V.A. para un periodo dado
begin
  Result := datosdb.tranSQL(path, 'SELECT fecha, ferecep, nettot, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper FROM ' + tiva.TableName +  ' WHERE fecha >= ' + '''' + xdf + '''' + ' AND fecha <= ' + '''' + xhf + '''' + ' ORDER BY fecha');
end;

{ Resumen Anual I.V.A. }

procedure TTiva.Titulo(salida: char; movim, xperiodo: string);
{Objetivo....: Emitir los T�tulos del Listado}
var
  i: integer;
begin
  pag := pag + 1;
  if (salida = 'P') or (salida = 'I') then Begin
    list.IniciarTitulos;
    //ListDatosEmpresa(salida);

    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, empresa.Nombre, 1, 'Arial, normal, 8', salida, 'S');
    if empresa.Rsocial2 <> '' then list.Linea(0, 0, empresa.Rsocial2, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, empresa.Nrocuit, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, empresa.Domicilio, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, ' ',1 , 'Arial, normal, 7', salida, 'S');

    list.Linea(0, 0, 'Resumen Anual  -  ' + movim + '  -   A�o: ' + xperiodo, 1, 'Arial, negrita, 14', salida, 'S');
    if movim = 'Compras' then list.titulo(0, 0, utiles.espacios(40) + 'Hoja N�: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), 1, 'Times New Roman, ninguno, 8');
    list.Linea(0, 0, ' ',1 , 'Arial, normal, 7', salida, 'S');
  end else Begin
    list.LineaTxt(CHR(18), True);
    For i := 1 to empresa.margenes do list.LineaTxt('  ', True);
    list.LineaTxt(empresa.Nombre, True);
    if empresa.Rsocial2 <> '' then list.LineaTxt(empresa.Rsocial2, True);
    list.LineaTxt(empresa.Nrocuit, True);
    list.LineaTxt(empresa.Domicilio, True);
    list.LineaTxt('  ', True);
    list.LineaTxt('Resumen Anual  -  ' + movim + '  Anio: ' + xperiodo + CHR(15), True);
    if movim = 'Compras' then list.LineaTxt(utiles.espacios(40) + 'Hoja N�: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), True);
    list.LineaTxt(' ', True);
  end;
end;

procedure TTiva.TOperacion(salida: char; movim: string);
{Objetivo....: Emitir los Titulos de compras y ventas}
begin
  if (salida = 'P') or (salida = 'I') then Begin
    if movim = 'Ventas' then Begin
      // 1� L�nea
      list.linea(0, 0, 'Mes de' ,1 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(25,  list.lineactual, 'Neto 1' ,2 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(40,  list.lineactual, 'Neto 2' ,3 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(51,  list.lineactual, 'Operaciones' ,4 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(67,  list.lineactual, 'Conceptos' ,5 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(88,  list.lineactual, 'I.V.A.' ,6 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(101, list.lineactual, 'I.V.A.' ,7 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(111, list.lineactual, 'Retenciones' ,8 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(127, list.lineactual, 'Percepci�n' ,9 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(146, list.lineactual, 'Total' ,10 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(155, list.lineactual, 'C.F. Res. DGI' ,11 , 'Arial, cursiva, 8', salida, 'N');
      // 2� L�nea
      list.linea(0, 0, 'Registro' ,1 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(54,  list.lineactual, 'Exentas' ,2 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(65,  list.lineactual, 'No Gravados' ,3 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(86,  list.lineactual, 'Normal' ,4 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(99,  list.lineactual, 'Recargo' ,5 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(116, list.lineactual, 'I.V.A.' ,6 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(127, list.lineactual, 'Ing. Brutos' ,7 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(143, list.lineactual, 'Operaci�n' ,8 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(159, list.lineactual, 'N� 2784' ,9 , 'Arial, cursiva, 8', salida, 'S');
    end;
    if movim = 'Compras' then Begin
      // 1� L�nea
      list.linea(0, 0, 'Mes de' ,1 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(25,  list.lineactual, 'Neto 1' ,2 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(40,  list.lineactual, 'Neto 2' ,3 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(51,  list.lineactual, 'Operaciones' ,4 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(67,  list.lineactual, 'Conceptos' ,5 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(88,  list.lineactual, 'I.V.A.' ,6 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(101, list.lineactual, 'I.V.A.' ,7 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(111, list.lineactual, 'Cr�d. p/Res.' ,8 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(127, list.lineactual, 'Percepci�n' ,9 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(146, list.lineactual, 'Total' ,10 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(159, list.lineactual, 'C.F. Res.' ,11 , 'Arial, cursiva, 8', salida, 'S');
      list.linea(175, list.lineactual, 'Reten.' ,12 , 'Arial, cursiva, 8', salida, 'S');
      // 2� L�nea
      list.linea(0, 0, 'Registro' ,1 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(54,  list.lineactual, 'Exentas' ,2 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(65,  list.lineactual, 'No Gravados' ,3 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(86,  list.lineactual, 'Normal' ,4 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(99,  list.lineactual, 'Recargo',5 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(116, list.lineactual, 'Varias',6 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(127, list.lineactual, 'Ganancias',7 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(143, list.lineactual, 'Operaci�n' ,8 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(161, list.lineactual, 'Varias',9 , 'Arial, cursiva, 8', salida, 'S');
      list.linea(175, list.lineactual, 'Combust.',10 , 'Arial, cursiva, 8', salida, 'S');
    end;
    list.linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.linea(0, 0, '  ', 1, 'Arial, negrita, 8', salida, 'S');
  end else Begin
    list.LineaTxt(utiles.sLLenarIzquierda(lin, 198, CHR(196)), True);
    if movim = 'Ventas' then Begin
      // 1� L�nea
      list.LineaTxt('Mes de', False);
      list.LineaTxt(utiles.espacios(61) + 'Neto 1       Neto 2  Operaciones    Conceptos       I.V.A.       I.V.A.  Retenciones   Percepcion        Total  C.F. Resol.', True);
      // 2� L�nea
      list.LineaTxt(utiles.espacios(92) + 'Exentas  No Gravados       Normal      Recargo       I.V.A.  Ing. Brutos    Operacion       D.G.I.', True);
    end;
    if movim = 'Compras' then Begin
      // 1� L�nea
      list.LineaTxt('Mes de', False);
      list.LineaTxt(utiles.espacios(61) + 'Neto 1       Neto 2  Operaciones    Conceptos       I.V.A.       I.V.A.  Cred. p/Res.  Percepcion        Total  C.F. Resol.  Reten.', True);
      // 2� L�nea
      list.LineaTxt(utiles.espacios(92) + 'Exentas  No Gravados       Normal      Recargo       Varias    Ganancias      Operacion     Varias Combus.', True);
    end;
    list.LineaTxt(utiles.sLLenarIzquierda(lin, 198, CHR(196)), True);
  end;
end;

procedure TTiva.PrepararVentas(xperiodo, xdfr, xhfr: string; salida: char; fecharecep: boolean);
var
  r: TQuery;
begin
  iniciarTot;
  if fecharecep then r := datosdb.tranSQL(path, 'SELECT fecha, ferecep, nettot, netto1, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper FROM ivaventa WHERE ferecep >= ' + '''' + utiles.sExprFecha(xdfr) + '''' + ' AND ferecep <= ' + '''' + utiles.sExprFecha(xhfr) + '''' + ' ORDER BY ferecep')
     else r := datosdb.tranSQL(path, 'SELECT fecha, ferecep, nettot, nettot1, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper FROM ivaventa WHERE fecha >= ' + '''' + utiles.sExprFecha(xdfr) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(xhfr) + '''' + ' ORDER BY fecha');
  r.Open; r.First;
  if not fecharecep then mesanter := Copy(r.FieldByName('fecha').AsString, 5, 2) else mesanter := Copy(r.FieldByName('ferecep').AsString, 5, 2);
  while not r.EOF do
    begin
      if not fecharecep then Begin   // Por fecha de emisi�n
        if Copy(r.FieldByName('fecha').AsString, 5, 2) <> mesanter then transpMes(mesanter, '1')
      end else Begin
        if Copy(r.FieldByName('ferecep').AsString, 5, 2) <> mesanter then transpMes(mesanter, '1');
      end;
      totNettot     := totNettot     + r.FieldByName('nettot').AsFloat;
      totNettot1    := totNettot1    + r.FieldByName('nettot1').AsFloat;
      totOpexenta   := totOpexenta   + r.FieldByName('opexenta').AsFloat;
      totConnograv  := totConnograv  + r.FieldByName('connograv').AsFloat;
      totIva        := totIva        + r.FieldByName('iva').AsFloat;
      totIvarec     := totIvarec     + r.FieldByName('ivarec').AsFloat;
      totPercepcion := totPercepcion + r.FieldByName('percep1').AsFloat;
      totPergan     := totPergan     + r.FieldByName('percep2').AsFloat;
      totTotOper    := totTotOper    + r.FieldByName('totoper').AsFloat;
      totCdfiscal   := totCdFiscal   + r.FieldByName('cdfiscal').AsFloat;
      if not fecharecep then mesanter := Copy(r.FieldByName('fecha').AsString, 5, 2) else mesanter := Copy(r.FieldByName('ferecep').AsString, 5, 2);
      r.Next;
    end;
  transpMes(mesanter, '1');
  r.Close; r.Free;
end;

procedure TTiva.PrepararCompras(xperiodo, xdfr, xhfr: string; salida: char; fecharecep: boolean);
var
  r: TQuery;
begin
  iniciarTot;
  if fecharecep then r := datosdb.tranSQL(path, 'SELECT fecha, ferecep, nettot, nettot1, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper, retencion, importe FROM ivacompr WHERE ferecep >= ' + '''' + utiles.sExprFecha(xdfr) + '''' + ' AND ferecep <= ' + '''' + utiles.sExprFecha(xhfr) + '''' + ' ORDER BY ferecep')
     else r := datosdb.tranSQL(path, 'SELECT fecha, ferecep, nettot, nettot1, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper, retencion, importe FROM ivacompr WHERE fecha >= ' + '''' + utiles.sExprFecha(xdfr) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(xhfr) + '''' + ' ORDER BY fecha');
  r.Open; r.First;
  if not fecharecep then mesanter := Copy(r.FieldByName('fecha').AsString, 5, 2) else mesanter := Copy(r.FieldByName('ferecep').AsString, 5, 2);
  while not r.EOF do
    begin
      if not fecharecep then Begin
        if Copy(r.FieldByName('fecha').AsString, 5, 2) <> mesanter then transpMes(mesanter, '2')
      end else Begin
        if Copy(r.FieldByName('ferecep').AsString, 5, 2) <> mesanter then transpMes(mesanter, '2')
      end;
      totNettot     := totNettot     + r.FieldByName('nettot').AsFloat;
      totNettot1    := totNettot1    + r.FieldByName('nettot1').AsFloat;
      totOpexenta   := totOpexenta   + r.FieldByName('opexenta').AsFloat;
      totConnograv  := totConnograv  + r.FieldByName('connograv').AsFloat;
      totIva        := totIva        + r.FieldByName('iva').AsFloat;
      totIvarec     := totIvarec     + r.FieldByName('ivarec').AsFloat;
      totPercepcion := totPercepcion + r.FieldByName('Cdfiscal').AsFloat;
      totPergan     := totPergan     + r.FieldByName('Percep1').AsFloat;
      totTotOper    := totTotOper    + r.FieldByName('totoper').AsFloat;
      totCdfiscal   := totCdfiscal   + 0;
      totRetencion  := totRetencion  + (r.FieldByName('retencion').AsFloat * r.FieldByName('importe').AsFloat);
      if not fecharecep then mesanter := Copy(r.FieldByName('fecha').AsString, 5, 2) else mesanter := Copy(r.FieldByName('ferecep').AsString, 5, 2);
      r.Next;
    end;
  transpMes(mesanter, '2');
  r.Close; r.Free;
end;

procedure TTiva.transpMes(mesanter, operacion: string);
// Objetivo...: retener los resultados mensuales en un arreglo
begin
  if (operacion = '2') and (Length(trim(mesanter)) > 0) then
    begin
      ctotales[StrToInt(mesanter), 1] := totNettot;
      ctotales[StrToInt(mesanter), 2] := totNettot1;
      ctotales[StrToInt(mesanter), 3] := totOpexenta;
      ctotales[StrToInt(mesanter), 4] := totConnoGrav;
      ctotales[StrToInt(mesanter), 5] := totIva;
      ctotales[StrToInt(mesanter), 6] := totIvarec;
      ctotales[StrToInt(mesanter), 7] := totPercepcion;
      ctotales[StrToInt(mesanter), 8] := totPergan;
      ctotales[StrToInt(mesanter), 9] := totTotOper;
      ctotales[StrToInt(mesanter),10] := totCdfiscal;
      ctotales[StrToInt(mesanter),11] := totRetencion;
    end;
  if (operacion = '1') and (Length(trim(mesanter)) > 0) then
    begin
      vtotales[StrToInt(mesanter), 1] := totNettot;
      vtotales[StrToInt(mesanter), 2] := totNettot1;
      vtotales[StrToInt(mesanter), 3] := totOpexenta;
      vtotales[StrToInt(mesanter), 4] := totConnoGrav;
      vtotales[StrToInt(mesanter), 5] := totIva;
      vtotales[StrToInt(mesanter), 6] := totIvarec;
      vtotales[StrToInt(mesanter), 7] := totPercepcion;
      vtotales[StrToInt(mesanter), 8] := totPergan;
      vtotales[StrToInt(mesanter), 9] := totTotOper;
      vtotales[StrToInt(mesanter),10] := totCdfiscal;
    end;
  iniciarTot;
end;

procedure TTiva.iniciarTot;
// Objetivo...: inicilizar subtotales
begin
  totNettot := 0; totNettot1 := 0; totOpexenta := 0; totConnoGrav := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0; totRetencion := 0;
end;

procedure TTiva.Listar(salida: char);
// Objetivo...: Listar Ventas
var
  i: integer;
begin
  TOperacion(salida, 'Ventas');   // Ventas
  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    For i := 1 to 12 do Begin
      list.Linea(0, 0,  utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i], 1, 'Arial, normal, 8', salida, 'N');
      list.importe(30,  list.lineactual, '', vtotales[i, 1], 2, 'Arial, normal, 8');
      list.importe(45,  list.lineactual, '', vtotales[i, 2], 3, 'Arial, normal, 8');
      list.importe(60,  list.lineactual, '', vtotales[i, 3], 4, 'Arial, normal, 8');
      list.importe(75,  list.lineactual, '', vtotales[i, 4], 5, 'Arial, normal, 8');
      list.importe(90,  list.lineactual, '', vtotales[i, 5], 6, 'Arial, normal, 8');
      list.importe(105, list.lineactual, '', vtotales[i, 6], 7, 'Arial, normal, 8');
      list.importe(120, list.lineactual, '', vtotales[i, 7], 8, 'Arial, normal, 8');
      list.importe(135, list.lineactual, '', vtotales[i, 8], 9, 'Arial, normal, 8');
      list.importe(150, list.lineactual, '', vtotales[i, 9], 10, 'Arial, normal, 8');
      list.importe(165, list.lineactual, '', vtotales[i,10], 11, 'Arial, normal, 8');
      list.Linea(0, 0, ' ', 12, 'Arial, normal, 8', salida, 'S');
      totNettot    := totNettot    + vtotales[i, 1]; totOpexenta   := totOpexenta   + vtotales[i, 3];
      totConnograv := totConnograv + vtotales[i, 4]; totIva        := totIva        + vtotales[i, 5];
      totIvarec    := totIvarec    + vtotales[i, 6]; totPercepcion := totPercepcion + vtotales[i, 7];
      totPergan    := totPergan    + vtotales[i, 8]; totTotOper    := totTotOper    + vtotales[i, 9];
      totCdfiscal  := totCdfiscal  + vtotales[i, 10]; totNettot1   := totNettot1    + vtotales[i, 2];
    end;
    ListTotal('V', salida);
    finales[1] := totIva + totIvarec; finales[3] := totPercepcion;

    totNettot := 0; totNettot1 := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0; totRetencion := 0;
    list.linea(0, 0, 'Resumen Anual  -  Compras', 1, 'Arial, negrita, 14', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    TOperacion(salida, 'Compras');   // Compras
    For i := 1 to 12 do Begin
      list.Linea(0, 0,  utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i], 1, 'Arial, normal, 8', salida, 'N');
      list.importe(30,  list.lineactual, '', ctotales[i, 1], 2, 'Arial, normal, 8');
      list.importe(45,  list.lineactual, '', ctotales[i, 2], 3, 'Arial, normal, 8');
      list.importe(60,  list.lineactual, '', ctotales[i, 3], 4, 'Arial, normal, 8');
      list.importe(75,  list.lineactual, '', ctotales[i, 4], 5, 'Arial, normal, 8');
      list.importe(90,  list.lineactual, '', ctotales[i, 5], 6, 'Arial, normal, 8');
      list.importe(105, list.lineactual, '', ctotales[i, 6], 7, 'Arial, normal, 8');
      list.importe(120, list.lineactual, '', ctotales[i, 7], 8, 'Arial, normal, 8');
      list.importe(135, list.lineactual, '', ctotales[i, 8], 9, 'Arial, normal, 8');
      list.importe(150, list.lineactual, '', ctotales[i, 9],10, 'Arial, normal, 8');
      list.importe(165, list.lineactual, '', ctotales[i,10],11, 'Arial, normal, 8');
      list.importe(180, list.lineactual, '', ctotales[i,11],12, 'Arial, normal, 8');
      list.Linea(181, list.Lineactual, ' ', 13, 'Arial, normal, 8', salida, 'S');
      totNettot    := totNettot    + ctotales[i, 1];  totOpexenta   := totOpexenta   + ctotales[i, 3];
      totConnograv := totConnograv + ctotales[i, 4];  totIva        := totIva        + ctotales[i, 5];
      totIvarec    := totIvarec    + ctotales[i, 6];  totPercepcion := totPercepcion + ctotales[i, 7];
      totPergan    := totPergan    + ctotales[i, 8];  totTotOper    := totTotOper    + ctotales[i, 9];
      totCdfiscal  := totCdfiscal  + ctotales[i, 10]; totRetencion  := totRetencion  + ctotales[i, 11];
      totNettot1   := totNettot1   + ctotales[i, 2];
    end;
    ListTotal('C', salida);
    finales[2] := totIva; finales[3] := totPercepcion; finales[4] := totRetencion;

  end else Begin

    For i := 1 to 12 do Begin
      nombre := utiles.sLLenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i] + utiles.espacios(60 - Length(Trim(utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i])));
      list.LineaTxt(nombre, False);

      list.ImporteTxt(vtotales[i, 1], 13, 2, False);
      list.ImporteTxt(vtotales[i, 2], 13, 2, False);
      list.ImporteTxt(vtotales[i, 3], 13, 2, False);
      list.ImporteTxt(vtotales[i, 4], 13, 2, False);
      list.ImporteTxt(vtotales[i, 5], 13, 2, False);
      list.ImporteTxt(vtotales[i, 6], 13, 2, False);
      list.ImporteTxt(vtotales[i, 7], 13, 2, False);
      list.ImporteTxt(vtotales[i, 8], 13, 2, False);
      list.ImporteTxt(vtotales[i, 9], 13, 2, False);
      list.ImporteTxt(vtotales[i,10], 13, 2, True);
      totNettot    := totNettot    + vtotales[i, 1]; totOpexenta   := totOpexenta   + vtotales[i, 3];
      totConnograv := totConnograv + vtotales[i, 4]; totIva        := totIva        + vtotales[i, 5];
      totIvarec    := totIvarec    + vtotales[i, 6]; totPercepcion := totPercepcion + vtotales[i, 7];
      totPergan    := totPergan    + vtotales[i, 8]; totTotOper    := totTotOper    + vtotales[i, 9];
      totCdfiscal  := totCdfiscal  + vtotales[i,10]; totNettot1    := totNettot1    + vtotales[i, 2];
    end;
    ListTotal('V', salida);
    finales[1] := totIva + totIvarec; finales[3] := totPercepcion;
    totNettot := 0; totNettot1 := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0; totRetencion := 0;

    list.LineaTxt(CHR(18), True);
    list.LineaTxt(' ', True);
    list.LineaTxt('Resumen Anual  -  Compras' + CHR(15), True);
    list.LineaTxt(' ', True);
    TOperacion(salida, 'Compras');   // Compras
    list.LineaTxt(' ', True);

    For i := 1 to 12 do Begin
      nombre := utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i] + utiles.espacios(60 - Length(Trim(utiles.sLLenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i])));
      list.LineaTxt(nombre, False);
      list.ImporteTxt(ctotales[i, 1], 13, 2, False);
      list.ImporteTxt(ctotales[i, 2], 13, 2, False);
      list.ImporteTxt(ctotales[i, 3], 13, 2, False);
      list.ImporteTxt(ctotales[i, 4], 13, 2, False);
      list.ImporteTxt(ctotales[i, 5], 13, 2, False);
      list.ImporteTxt(ctotales[i, 6], 13, 2, False);
      list.ImporteTxt(ctotales[i, 7], 13, 2, False);
      list.ImporteTxt(ctotales[i, 8], 13, 2, False);
      list.ImporteTxt(ctotales[i, 9], 13, 2, False);
      list.ImporteTxt(ctotales[i,10], 13, 2, False);
      list.ImporteTxt(ctotales[i,11], 8, 2, True);
      totNettot    := totNettot     + ctotales[i, 1]; totOpexenta   := totOpexenta   + ctotales[i, 3];
      totConnograv := totConnograv  + ctotales[i, 4]; totIva        := totIva        + ctotales[i, 5];
      totIvarec    := totIvarec     + ctotales[i, 6]; totPercepcion := totPercepcion + ctotales[i, 7];
      totPergan    := totPergan     + ctotales[i, 8]; totTotOper    := totTotOper    + ctotales[i, 9];
      totCdfiscal  := totCdfiscal   + ctotales[i,10]; totRetencion  := totRetencion  + ctotales[i, 11];
      totNettot1   := totNettot1    + ctotales[i, 2];
    end;
    finales[2] := totIva; finales[3] := finales[3] + totPercepcion; finales[4] := totRetencion;
    ListTotal('C', salida);
  end;
end;

procedure TTiva.ListInfAnual(xperiodo, xdfr, xhfr: string; salida: char; xfecharecep: boolean);
var
  i, j: integer;
begin
  For i := 1 to 12 do
    For j := 1 to elementos do Begin
      ctotales[i, j] := 0; vtotales[i, j] := 0;
    end;
  finales[1] := 0; finales[2] := 0; finales[3] := 0; finales[4] := 0;
  // Preparamos el rango de fechas
  list.tipolist := salida;
  df := '01/01/' + Copy(xperiodo, 3, 2); hf := '31/12/' + Copy(xperiodo, 3, 2);
  if not inf_iniciado then Begin
    IniciarInforme(salida);
    if salida = 'I' then list.ImprimirHorizontal;
  end else
    if salida <> 'T' then Begin
      if salida = 'I' then list.ImprimirHorizontal;
      list.IniciarNuevaPagina;
    end else
      if inf_iniciado then List.LineaTxt(CHR(12), True);
  inf_iniciado := True;
  titulo(salida, 'Ventas', xperiodo);
  PrepararVentas(xperiodo, df, hf, salida, xfecharecep);
  PrepararCompras(xperiodo, xdfr, xhfr, salida, xfecharecep);
  Listar(salida);
  ListResumen(xperiodo, salida);
  if salida <> 'T' then list.CompletarPagina;
end;

procedure TTiva.ListTotal(xoperacion, salida: char);
// Objetivo...: Listar Subtotales I.V.A.
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0,  list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0,  'Subtotales .........:', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(30,  list.lineactual, '', totNettot, 2, 'Arial, normal, 8');
    list.importe(45,  list.lineactual, '', totNettot1, 3, 'Arial, normal, 8');
    list.importe(60,  list.lineactual, '', totOpexenta, 4, 'Arial, normal, 8');
    list.importe(75,  list.lineactual, '', totConnograv, 5, 'Arial, normal, 8');
    list.importe(90,  list.lineactual, '', totIva, 6, 'Arial, normal, 8');
    list.importe(105, list.lineactual, '', totIvarec, 7, 'Arial, normal, 8');
    list.importe(120, list.lineactual, '', totPercepcion, 8, 'Arial, normal, 8');
    list.importe(135, list.lineactual, '', totPergan, 9, 'Arial, normal, 8');
    list.importe(150, list.lineactual, '', totTotOper, 10, 'Arial, normal, 8');
    list.importe(165, list.lineactual, '', totCdfiscal, 11, 'Arial, normal, 8');
    if xoperacion = 'C' then list.importe(180, list.lineactual, '', totRetencion, 12, 'Arial, normal, 8');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(utiles.sLLenarIzquierda(lin, 198, CHR(196)), True);
    nombre := 'Subtotales .........:' + utiles.espacios(60 - Length(Trim('Subtotales .........:')));
    list.LineaTxt(nombre, False);
    list.ImporteTxt(totNettot, 13, 2, False);
    list.ImporteTxt(totNettot1, 13, 2, False);
    list.ImporteTxt(totOpexenta, 13, 2, False);
    list.ImporteTxt(totConnograv, 13, 2, False);
    list.ImporteTxt(totIva, 13, 2, False);
    list.ImporteTxt(totIvarec, 13, 2, False);
    list.ImporteTxt(totPercepcion, 13, 2, False);
    list.ImporteTxt(totPergan, 13, 2, False);
    list.ImporteTxt(totTotOper, 13, 2, False);
    if xoperacion = 'C' then list.ImporteTxt(totCdfiscal, 13, 2, False) else list.ImporteTxt(totCdfiscal, 13, 2, True);
    if xoperacion = 'C' then list.ImporteTxt(totRetencion, 8, 2, True);
  end;
end;

procedure TTiva.ListResumen(xperiodo: string; salida: char);
// Objetivo...: Resumen del Informe Anual
begin
  getDatosSaldo(xperiodo);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 12', salida, 'S');
    list.Linea(0, 0, 'Resultado para la Evaluaci�n frente a D.G.I. ', 1,'Arial, normal, 12', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'D�bito Fiscal ..................: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', finales[1] * (-1), 2, 'Courier New, normal, 8');
    list.Linea(90, list.lineactual, ' ', 3, 'Courier New, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Cr�dito Fiscal .................: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', finales[2], 2, 'Courier New, normal, 8');
    list.Linea(90, list.lineactual, ' ', 3, 'Courier New, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Saldo Per�odo Anterior .........: ', 1, 'Courier New, normal, 10', salida, 'S');
    list.importe(60,  list.lineactual, '', saldoanter, 2, 'Courier New, normal, 8');
    list.Linea(0, 0, 'Retenciones y Cr�ditos .........: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', finales[3], 2, 'Courier New, normal, 8');
    list.Linea(90, list.lineactual, ' ', 3, 'Courier New, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Retenci�n Combustibles .........: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', finales[4], 2, 'Courier New, normal, 8');
    list.Linea(90, list.lineactual, ' ', 3, 'Courier New, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Saldo ..........................: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', (finales[1] - (finales[2] + saldoanter + finales[3] + finales[4])) * (-1), 2, 'Courier New, normal, 8');
    list.linea(0, 0, list.linealargopagina(salida), 1, 'Corrier New, normal, 11', salida, 'N');
  end else Begin
    List.LineaTxt(' ', True);
    List.LineaTxt(CHR(18), True);
    List.LineaTxt('Resultado para la Evaluacion frente a D.G.I. ', True);
    List.LineaTxt(' ', True);
    nombre := 'Debito Fiscal ..................: ' + utiles.espacios(59 - Length(Trim('D�bito Fiscal ..................: ')));
    List.LineaTxt(nombre, False);
    list.ImporteTxt(finales[1] * (-1), 13, 2, True);
    nombre := 'Credito Fiscal .................: ' + utiles.espacios(59 - Length(Trim('Cr�dito Fiscal .................: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt(finales[2], 13, 2, True);
    nombre := 'Saldo Periodo Anterior .........: ' + utiles.espacios(59 - Length(Trim('Saldo Per�odo Anterior .........: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt(saldoanter, 13, 2, True);
    nombre := 'Retenciones y Creditos .........: ' + utiles.espacios(59 - Length(Trim('Retenciones y Cr�ditos .........: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt(finales[3], 13, 2, True);
    nombre := 'Retencion Combustibles .........: ' + utiles.espacios(59 - Length(Trim('Retencion Combustibles .........: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt(finales[4], 13, 2, True);
    nombre := 'Saldo ..........................: ' + utiles.espacios(59 - Length(Trim('Saldo ..........................: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt((finales[1] - (finales[2] + saldoanter + finales[3] + finales[4])) * (-1), 13, 2, True);
  end;
end;
//------------------------------------------------------------------------------

procedure TTIva.FijarSaldoPeriodoAnterior(xperiodo: string; xsaldoanter: real);
begin
  saldoiva.Open;
  if saldoiva.FindKey([xperiodo]) then saldoiva.Edit else saldoiva.Append;
  saldoiva.FieldByName('periodo').AsString   := xperiodo;
  saldoiva.FieldByName('saldoanter').AsFloat := xsaldoanter;
  try
    saldoiva.Post
  except
    saldoiva.Cancel
  end;
  saldoiva.Close;
end;

procedure TTIva.getDatosSaldo(xperiodo: string);
begin
  saldoiva.Open;
  if saldoiva.FindKey([xperiodo]) then saldoanter := saldoiva.FieldByName('saldoanter').AsFloat else saldoanter := 0;
  saldoiva.Close;
end;

procedure TTIva.PresentarInforme;
begin
  list.CompletarPagina;
  if list.tipolist <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
  inf_iniciado := False; iva_existe := False;
  if list.tipolist <> 'T' then list.ImprimirVetical;
end;

procedure TTIva.vaciarBuffer;
// Objetivo...: vaciar buffers de tablas al disco
begin
  datosdb.vaciarBuffer(tiva);
  datosdb.vaciarBuffer(iiva);
end;

procedure TTIva.Via(xvia: string);
// Objetivo...: conectar tablas de persistencia, apuntado a un directorio de trabajo X
begin
  netos.Via(xvia);
  conexiones := 0;
end;

procedure TTIva.FijarVia(xvia: string);
begin
  saldoiva := datosdb.openDB('saldoiva', 'periodo', '', dbs.dirSistema + '\' + xvia);
  path := dbs.dirSistema + '\' + xvia;
end;

procedure TTIva.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tiva.Active then tiva.Open;
    if not iiva.Active then iiva.Open;
  end;
  Inc(conexiones);
  netos.conectar;
  provincia.conectar;
  tabliva.conectar;
end;

procedure TTIva.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tiva);
    datosdb.closeDB(iiva);
  end;
  netos.desconectar;
  provincia.desconectar;
  tabliva.desconectar;
end;

{===============================================================================}

function iva: TTIva;
begin
  if xiva = nil then
    xiva := TTIva.Create;
  Result := xiva;
end;

{===============================================================================}

initialization

finalization
  xiva.Free;

end.
