unit CEstadisticasFacturacionCCB;

interface

uses CFacturacionCCB, CEstadisticas, CObrasSocialesCCB, CProfesionalCCB, CNomeclaCCB,
     SysUtils, DB, DBTables, CUtiles, CListar, CBDT, CIDBFM, Classes, CServers2000_Excel,
     CNomeclatura_ObraSocial, CNBU, CUtilidadesArchivos, Contnrs, CDebitosCreditosIAPOS, CUBReferentes,
     IBQuery, CUnidadesNBU;

const
  cantitems = 10;

type

TTestadisticaCCBCCB = class(TTEstadistica)
  Entidad, Fepago: String;
  Debito, Pago, TotalProf: real;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   InicidenciaDeCadaObraSocial_Global(xperiodo: String; salida: Char);
  procedure   InicidenciaPorDeterminacion_Global(xperiodo, xcodos: String; salida: Char);
  procedure   InicidenciaDeCadaProfesional_Global(xperiodo, xcodos: String; salida: Char);
  procedure   InicidenciaDeCadaProfesionalDet_Global(xperiodo: String; listprof, listos: TStringList; salida: Char);
  procedure   PracticasFacturadas_Global(xperiodo: String; obsociales: TStringList; salida: Char);

  procedure   InicidenciaCodigosFactPesos(xperiodo, xcodos: String; salida: Char);
  procedure   InicidenciaCodigosFacturadosPorProfesional(xperiodo, xcodos: String; salida: Char);
  procedure   InicidenciaPorDeterminacion_Detallada(xperiodo, xcodos, xsubtitulo: String; salida: Char; xinfderiv, xseparar9984, xpresentarcantidades, xrecalcular: Boolean);
  function    getTotalesInicidenciaPorDeterminacion_Detallada(xperiodo: string): TQuery;
  procedure   BorrarTotalesInicidenciaPorDeterminacion_Detallada(xperiodo, xcodos: string);
  procedure   InfComparacinProfesionales(xcodos, xperdesde, xperhasta: String; salida: char);
  procedure   InfRecuentoPorPractica(xperiodo: String; xcodigos: TStringList; salida: char);

  procedure   ConectarDebitosProfesionales(xperiodo: string);
  procedure   AjustarDebito(xcodos, xperiodo, xidprof: string; xdebito, xpago, xtotalprof: real);
  procedure   AjustarFecha(xcodos, xperiodo, xidprof, xfecha: string);
  procedure   AjustarPago(xcodos, xperiodo, xidprof: string; xmonto: real);
  procedure   getDatos(xcodos, xperiodo, xidprof: string);
  procedure   DesconectarDebitosProfesionales;

  procedure   ListarResumenIAPOS(xperiodo, xcodos: string; salida: char);
 private
  { Declaraciones Privadas }
  totDet: Real; fila, ffila: Integer; vf, codosanter, __periodo: String;
  totalfinal: array[1..cantitems] of Real;
  tot9984: array[1..cantitems] of Real;
  cantdet: array[1..cantitems] of Real;
  totnbu: array[1..cantitems] of Real;
  monto9984, dmontofijo, cantidadfinal, unidadref: Real;
  infderiv: Boolean;
  c4: integer;
  lista, listadet, listadet1: TStringList;
  dc: TTDebitosCreditosIapos;
  ur: TTUBReferente;
  debitos: TTable;
  procedure   LineaDeterminacion(xcodos, xcodanalisis: String; salida: Char);
  procedure   LineaDeterminacionParticular(xcodanalisis: String; salida: Char);
  procedure   LineaProf(xidanter, xcodos: String; salida: Char);
  procedure   LineaDeterminacionDetallada(xcodos, xcodanalisis: String; salida: Char; xpresentarcantidades: boolean);
  procedure   LineaDeterminacionCodigos(xcodos, xcodanalisis: String; salida: Char);
  { Impresiones en Modo Texto }
  procedure   Titulo1;
  procedure   Titulo2;
  procedure   Titulo3(xcodos: String);
  procedure   Titulo4;
  procedure   Titulo5;
  procedure   Titulo6;
  procedure   Titulo7;
  procedure   TotalObraSocialOrdenes(salida: char);
  procedure   LineaDeterminacionDetalladaMontosFijos(salida: Char; xpresentarcantidades: boolean);
  procedure   IniciarArreglos;
  procedure   LineaDeterminaciones(xcodanalisis: String; xtotal: Real; salida: char);
  procedure   TotalDeterminaciones(salida: char);
 protected
  { Declaraciones Protegidas }
end;

function estadisticaCCB: TTestadisticaCCBCCB;

implementation

var
  xestadisticaCCB: TTestadisticaCCBCCB = nil;

constructor TTestadisticaCCBCCB.Create;
begin
  inherited Create;
  NotrazarLineaTitulos := True;
  listadet  := TStringList.Create;
  listadet1 := TStringList.Create;
end;

destructor TTestadisticaCCBCCB.Destroy;
begin
  inherited Destroy;
end;

procedure TTestadisticaCCBCCB.InicidenciaDeCadaObraSocial_Global(xperiodo: String; salida: Char);
// Objetivo...: List. Porcentaje de incidencia de cada obra social sobre el total facturado
begin
  fecha1 := xperiodo;

  obsocial.conectar;
  profesional.conectar;
  nbu.conectar;
  total := facturacion.setTotalFacturado(xperiodo);
  Q     := facturacion.setItemsTotalFacturado(xperiodo);
  Q.Open; totales[1] := 0; totales[2] := 0;

  NoTrazarLineaTitulos := True;
  inherited Titulos('Porcentaje de Incidencia por Obra Social', salida);
  if salida <> 'T' then Begin
    list.Titulo(0, 0, 'C�d.       Obra Social', 1, 'Arial, cursiva, 8');
    list.Titulo(61, list.Lineactual, 'Valores Facturados', 2, 'Arial, cursiva, 8');
    list.Titulo(87, list.Lineactual, 'Porcentaje', 3, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end else titulo1;

  while not Q.Eof do Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, Q.FieldByName('codos').AsString + '   ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', Q.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', (Q.FieldByName('monto').AsFloat / total) * 100, 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.LineaTxt(Q.FieldByName('codos').AsString + '   ' + Copy(Q.FieldByName('nombre').AsString, 1, 35) + utiles.espacios(40 - Length(TrimRight(Copy(Q.FieldByName('nombre').AsString, 1, 35)))), False);
      list.importeTxt(Q.FieldByName('monto').AsFloat, 12, 2, False);
      list.importeTxt((Q.FieldByName('monto').AsFloat / total) * 100, 17, 2, True); Inc(lineas); if ControlarSalto then titulo1;
    end;
    totales[1] := totales[1] + (Q.FieldByName('monto').AsFloat / total) * 100;
    totales[2] := totales[2] + Q.FieldByName('monto').AsFloat;
    Q.Next;
  end;
  if salida <> 'T' then Begin
    list.Linea(0, 0, list.Linealargopagina(salida) , 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, ' ' , 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Totales: ' , 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  end else Begin
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True); Inc(lineas); if ControlarSalto then titulo1;
    list.LineaTxt(' ', True); Inc(lineas); Inc(lineas); if ControlarSalto then titulo1;
    list.LineaTxt('Totales: ' + utiles.espacios(42), False);
    list.importeTxt(totales[2], 10, 2, False);
    list.importeTxt(totales[1], 17, 2, True);
  end;
  Q.Close; Q.Free;
  obsocial.desconectar;
  profesional.desconectar;
  nbu.desconectar;
end;

procedure TTestadisticaCCBCCB.InicidenciaPorDeterminacion_Global(xperiodo, xcodos: String; salida: Char);
var
  codosanter, idanter: String;
begin
  fecha1 := xperiodo;
  nomeclatura.conectar;
  profesional.conectar;
  obsocial.conectar;
  nbu.conectar;

  total := facturacion.setTotalFacturado(xperiodo);
  if Length(Trim(xcodos)) > 0 then total := facturacion.setTotalFactObraSocial(xperiodo, xcodos);
  Q     := facturacion.setDeterminacionesFacturadas(xperiodo);
  Q.Open; totales[4] := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; cantdet[1] := 0; cantdet[2] := 0; cantdet[3] := 0; cantdet[4] := 0; cantdet[5] := 0;
  if Length(Trim(xcodos)) > 0 then datosdb.Filtrar(Q, 'codos = ' + xcodos);
  totales[1] := Q.RecordCount;
  idanter    := Q.FieldByName('codanalisis').AsString;
  codosanter := Q.FieldByName('codos').AsString;

  if Length(Trim(xcodos)) > 0 then Begin
     obsocial.getDatos(xcodos);
     if salida <> 'T' then Begin
       inherited Titulos('Porcentaje de Incidencia por Determinaci�n', salida);
       list.Titulo(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, Negrita, 12');
       list.Titulo(0, 0, ' ', 1, 'Arial, Normal, 5');
     end else Begin
       Titulo2;
       list.LineaTxt('Obra Social: ' + obsocial.Nombre, True);
       list.LineaTxt(' ', True);
     end;
  end;

  if salida <> 'T' then Begin
    if Length(Trim(xcodos)) = 0 then inherited Titulos('Porcentaje de Incidencia por Determinaci�n', salida);
    list.Titulo(0, 0, 'C�digo      Determinaci�n', 1, 'Arial, cursiva, 8');
    list.Titulo(71, list.Lineactual, 'Incidencia %', 2, 'Arial, cursiva, 8');
    list.Titulo(87, list.Lineactual, 'Incidencia', 3, 'Arial, cursiva, 8');
    list.Titulo(0, 0, ' ', 1, 'Arial, cursiva, 8');
    list.Titulo(72, list.Lineactual, 'en Cantidad', 2, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, '% en $', 3, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');

    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end else
    if Length(Trim(xcodos)) = 0 then Titulo2;

  while not Q.Eof do Begin
    if Q.FieldByName('codanalisis').AsString <> idanter then LineaDeterminacion(codosanter, idanter, salida);
    idanter    := Q.FieldByName('codanalisis').AsString;
    codosanter := Q.FieldByName('codos').AsString;
    totdet     := totdet     + facturacion.setImporteAnalisis(Q.FieldByName('codos').AsString, Q.FieldByName('codanalisis').AsString);
    totales[2] := totales[2] + 1;
    Q.Next;
  end;
  LineaDeterminacion(codosanter, idanter, salida);
  if salida <> 'T' then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, ' ' , 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Totales: ' , 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[4], 3, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  end else Begin
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True); Inc(lineas); if ControlarSalto then titulo2;
    list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then Titulo2;
    list.LineaTxt('Totales: ' + utiles.espacios(42), False);
    list.ImporteTxt(totales[3], 12, 2, False);
    list.ImporteTxt(totales[4], 15, 2, True);   Inc(lineas); if controlarSalto then Titulo2;
  end;
  Q.Close; Q.Free;
  obsocial.desconectar;
  profesional.desconectar;
  nomeclatura.desconectar;
  nbu.desconectar;
end;

procedure TTestadisticaCCBCCB.LineaDeterminacion(xcodos, xcodanalisis: String; salida: Char);
// Objetivo...: List. Porcentaje de incidencia de cada Profesional
var
  des: String;
begin
  if (obsocial.Factnbu = 'S') and (Length(trim(xcodanalisis)) = 6) then Begin
    nbu.getDatos(xcodanalisis);
    des := nbu.Descrip;
  end;
  if (obsocial.Factnbu = 'N') or (Length(trim(xcodanalisis)) = 4) then Begin
    nomeclatura.getDatos(xcodanalisis);
    des := nomeclatura.descrip;
  end;
  if salida <> 'T' then Begin
    list.Linea(0, 0, xcodanalisis + '          ' + des, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', (totales[2] / totales[1]) * 100, 2, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', (totdet / total) * 100, 3, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(xcodanalisis + '  ' + Copy(des, 1, 43) + utiles.espacios(45 - Length(TrimRight(Copy(des, 1, 43)))), False);
    list.ImporteTxt((totales[2] / totales[1]) * 100, 12, 2, False);
    list.ImporteTxt((totdet / total) * 100, 15, 2, True);   Inc(lineas); if controlarSalto then Titulo2;
  end;
  totales[4] := totales[4] + (totdet / total) * 100;
  totales[3] := totales[3] + (totales[2] / totales[1]) * 100;
  totdet := 0; totales[2] := 0;
end;

function TTestadisticaCCBCCB.getTotalesInicidenciaPorDeterminacion_Detallada(xperiodo: string): TQuery;
var
  r: TQuery;
  per: string;
begin
  result := facturacion.getTotalesInicidenciaPorDeterminacion_Detallada(xperiodo);
  {per := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  if (FileExists(dbs.DirSistema + '\estadisticas\' + per + '\totales.db')) then
    result := datosdb.tranSQL(dbs.DirSistema + '\estadisticas\' + per, 'select * from totales where periodo = ' + '''' + per + '''')
  else
    result := nil;}
end;

procedure TTestadisticaCCBCCB.BorrarTotalesInicidenciaPorDeterminacion_Detallada(xperiodo, xcodos: string);
{var
  r: TQuery;
  per: string;}
begin
  facturacion.BorrarTotalesInicidenciaPorDeterminacion_Detallada(xperiodo, xcodos);
  {per := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  if (FileExists(dbs.DirSistema + '\estadisticas\' + per + '\totales.db')) then
    datosdb.tranSQL(dbs.DirSistema + '\estadisticas\' + per, 'delete from totales where codos = ' + '''' + xcodos + '''');}
end;

procedure TTestadisticaCCBCCB.InicidenciaPorDeterminacion_Detallada(xperiodo, xcodos, xsubtitulo: String; salida: Char; xinfderiv, xseparar9984, xpresentarcantidades, xrecalcular: Boolean);
// Objetivo...: Estadistica detallada de determinaciones
var
  idanter, idanter1, ff, per: String;
  _caran, m9984, importedet: Real;
  cantPac: integer;
  r: TIBQuery;
  totos: TTable;
begin
  __periodo := xperiodo;
  if (salida = 'P') or (salida = 'I') then list.Setear(salida);
  infderiv := xinfderiv;
  fecha1   := xperiodo;
  fila     := 0; dmontofijo := 0; codosanter := ''; cantidadfinal := 0; totnbu[10] := 0; totnbu[9] := 0;
  listadet.Clear;
  listadet1.Clear;
  IniciarArreglos;
  nomeclatura.conectar;
  profesional.conectar;
  obsocial.conectar;
  nomeclaturaos.conectar;

  ur := TTUBReferente.Create;
  ur.conectar;
  unidadref := ur.getUnidad(xcodos, xperiodo);
  ur.desconectar;
  ur.Destroy; ur := nil;

  {per := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  if not (DirectoryExists(dbs.DirSistema + '\estadisticas')) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\estadisticas');
  if not (DirectoryExists(dbs.DirSistema + '\estadisticas\' + per)) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\estadisticas\' + per);
  if not (FileExists(dbs.DirSistema + '\estadisticas\' + per + '\totales.db')) then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\estadisticas', 'totales.*', dbs.DirSistema + '\estadisticas\' + per);
  totos := datosdb.openDB('totales', '', '', dbs.DirSistema + '\estadisticas\' + per);
  totos.Open;}

  totos := datosdb.openDB('totos', '', '', facturacion.getDBConexion);
  totos.Open;

  if Length(Trim(xcodos)) > 0 then Begin
     obsocial.getDatos(xcodos);
     if salida <> 'T' then Begin
       if salida <> 'X' then Begin
         if not infderiv then Begin
           Titulos('Estad�stica Detallada', salida);
           list.Titulo(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, Negrita, 12');
           list.Titulo(0, 0, ' ', 1, 'Arial, Normal, 5');
         end;
       end else Begin
         excel.setString('a1', 'a1', 'Estad�stica Detallada', 'Arial, negrita, 16');
         excel.setString('a3', 'a3', 'Obra Social: ' + obsocial.Nombre, 'Arial, negrita, 12');
       end;
     end else Begin
       Titulo5;
       list.LineaTxt('Obra Social: ' + obsocial.Nombre, True);
       list.LineaTxt(' ', True);
     end;
  end;

  if salida <> 'T' then Begin
    if salida <> 'X' then Begin
      if not (infderiv) and not (xpresentarcantidades) then Begin
        if Length(Trim(xcodos)) = 0 then Titulos('Estad�stica Detallada', salida);
        list.Titulo(0, 0, 'C�digo', 1, 'Arial, cursiva, 8');
        list.Titulo(34, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
        list.Titulo(47, list.Lineactual, 'Gastos', 3, 'Arial, cursiva, 8');
        list.Titulo(57, list.Lineactual, 'Honorarios', 4, 'Arial, cursiva, 8');
        list.Titulo(68, list.Lineactual, 'Comp.Aran.', 5, 'Arial, cursiva, 8');
        list.Titulo(86, list.Lineactual, 'Total', 6, 'Arial, cursiva, 8');
        list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
        list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      end;
      if (infderiv) and not (xpresentarcantidades) then Begin
        list.Titulo(0, 0, '', 1, 'Arial, Negrita, 14');
        list.Titulo(0, 0, 'Prestador: ' + Entidad, 1, 'Arial, Normal, 12');
        list.Titulo(0, 0, '', 1, 'Arial, Normal, 8');
        if (Length(Trim(xsubtitulo))) = 0 then
          list.Titulo(0, 0, 'Per�odo: ' + xperiodo, 1, 'Arial, Normal, 12')
        else
          list.Titulo(0, 0, xsubtitulo, 1, 'Arial, Normal, 12');
        list.Titulo(0, 0, '', 1, 'Arial, Normal, 8');
        list.Titulo(0, 0, 'Pr�cticas Facturadas  -  ' + obsocial.Nombre, 1, 'Arial, Negrita, 14');
        list.Titulo(0, 0, '', 1, 'Arial, Normal, 8');
        list.Titulo(0, 0, '', 1, 'Arial, Normal, 8');
        list.Titulo(30, list.Lineactual, 'Valor Unitario', 2, 'Arial, cursiva, 8');
        list.Titulo(74, list.Lineactual, 'Valor Total', 3, 'Arial, cursiva, 8');
        list.Titulo(0, 0, '', 1, 'Arial, Normal, 8');
        list.Titulo(0, 0, 'C�digo', 1, 'Arial, cursiva, 8');
        list.Titulo(9, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
        if (obsocial.Factnbu <> 'S') then
          list.Titulo(18, list.Lineactual, 'Hon/U.B.', 3, 'Arial, cursiva, 8')
        else
          list.Titulo(21, list.Lineactual, 'U.B.', 3, 'Arial, cursiva, 8');
        list.Titulo(29, list.Lineactual, 'NBU Ref.', 4, 'Arial, cursiva, 8');
        list.Titulo(41, list.Lineactual, 'P.Unit.', 5, 'Arial, cursiva, 8');
        list.Titulo(51, list.Lineactual, 'Total', 6, 'Arial, cursiva, 8');
        list.Titulo(58, list.Lineactual, 'NBU Dist.', 7, 'Arial, cursiva, 8');
        list.Titulo(69, list.Lineactual, 'Tot. UB', 8, 'Arial, cursiva, 8');
        //list.Titulo(77, list.Lineactual, 'Comp.Aran.', 8, 'Arial, cursiva, 8');
        list.Titulo(91, list.Lineactual, 'Total', 9, 'Arial, cursiva, 8');
        list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
        list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      end;
      if (xpresentarcantidades) then Begin
        list.Titulo(0, 0, '', 1, 'Arial, Negrita, 14');
        list.Titulo(0, 0, 'Prestador: ' + Entidad, 1, 'Arial, Normal, 12');
        list.Titulo(0, 0, '', 1, 'Arial, Normal, 8');
        list.Titulo(0, 0, 'Per�odo: ' + facturacion.setRangoPeriodos, 1, 'Arial, Normal, 12');
        list.Titulo(0, 0, '', 1, 'Arial, Normal, 8');
        list.Titulo(0, 0, 'Pr�cticas Facturadas  -  ' + obsocial.Nombre, 1, 'Arial, Negrita, 14');
        list.Titulo(0, 0, '', 1, 'Arial, Normal, 8');
        list.Titulo(0, 0, 'C�digo', 1, 'Arial, cursiva, 8');        list.Titulo(47, list.Lineactual, 'Gastos', 3, 'Arial, cursiva, 8');
        list.Titulo(8, list.Lineactual, 'Determinaci�n', 2, 'Arial, cursiva, 8');        list.Titulo(47, list.Lineactual, 'Gastos', 3, 'Arial, cursiva, 8');
        list.Titulo(85, list.Lineactual, 'Cantidad', 3, 'Arial, cursiva, 8');
        list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
        list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      End;
    end else Begin
      if (infderiv) and not (xpresentarcantidades) then Begin
        excel.Alinear('a5', 'a5', 'D');
        excel.Alinear('b5', 'b5', 'D');
        excel.Alinear('c5', 'c5', 'D');
        excel.Alinear('d5', 'd5', 'D');
        excel.Alinear('e5', 'e5', 'D');
        excel.Alinear('f5', 'f5', 'D');
        excel.Alinear('g5', 'g5', 'D');
        excel.Alinear('h5', 'h5', 'D');
        excel.Alinear('i5', 'i5', 'D');
        excel.Alinear('j5', 'j5', 'D');
        excel.setString('a5', 'a5', 'C�digo', 'Arial, negrita, 9');
        excel.setString('b5', 'b5', 'Cantidad', 'Arial, negrita, 9');
        if (obsocial.Factnbu <> 'S') then begin
          excel.setString('c5', 'c5', 'U.H./U.B.', 'Arial, negrita, 9');
          excel.setString('d5', 'd5', 'U.G.', 'Arial, negrita, 9');
        end else begin
          excel.setString('c5', 'c5', 'U.B.', 'Arial, negrita, 9');
          excel.setString('d5', 'd5', 'NBU Ref', 'Arial, negrita, 9');
        end;
        excel.setString('e5', 'e5', 'P.Unit.', 'Arial, negrita, 9');
        excel.setString('f5', 'f5', 'Total', 'Arial, negrita, 9');
        excel.setString('g5', 'g5', 'NBU Dist.', 'Arial, negrita, 9');
        excel.setString('h5', 'h5', 'Tot. UB', 'Arial, negrita, 9');
        excel.setString('i5', 'i5', 'Total', 'Arial, negrita, 9');
      end;
      if not (infderiv) and not (xpresentarcantidades) then Begin
        excel.Alinear('a5', 'a5', 'D');
        excel.Alinear('b5', 'b5', 'D');
        excel.Alinear('c5', 'c5', 'D');
        excel.Alinear('d5', 'd5', 'D');
        excel.Alinear('e5', 'e5', 'D');
        excel.Alinear('f5', 'f5', 'D');
        excel.setString('a5', 'a5', 'C�digo', 'Arial, negrita, 9');
        excel.setString('b5', 'b5', 'Cantidad', 'Arial, negrita, 9');
        excel.setString('c5', 'c5', 'Gastos', 'Arial, negrita, 9');
        excel.setString('d5', 'd5', 'Honorarios', 'Arial, negrita, 9');
        excel.setString('e5', 'e5', 'C.Arnac.', 'Arial, negrita, 9');
        excel.setString('f5', 'f5', 'Total', 'Arial, negrita, 9');
      end;
      if (xpresentarcantidades) then Begin
        excel.Alinear('c5', 'c5', 'D');
        excel.setString('a5', 'a5', 'C�digo', 'Arial, negrita, 9');
        excel.setString('b5', 'b5', 'Determinaci�n', 'Arial, negrita, 9');
        excel.setString('c5', 'c5', 'Cantidad', 'Arial, negrita, 9');
        excel.FijarAnchoColumna('b5', 'b5', 30);
      end;
    end;
  end else
    if Length(Trim(xcodos)) = 0 then Titulo5;

  facturacion.Periodo := xperiodo;
  fila  := 5;
  if (xrecalcular) then total := facturacion.setTotalFacturado(xperiodo);
  if Length(Trim(xcodos)) > 0 then total := facturacion.setTotalFactObraSocial(xperiodo, xcodos);

  if (facturacion.interbase <> 'S') then begin
  Q     := facturacion.setDeterminacionesFacturadasPorObraSocial(xperiodo, xcodos);
  Q.Open;
  totales[4] := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0; totales[12] := 0; totales[13] := 0; totales[14] := 0; totales[15] := 0;
  totales[1] := Q.RecordCount;
  idanter    := Q.FieldByName('codanalisis').AsString;
  codosanter := Q.FieldByName('codos').AsString;
  c4         := length(trim(Q.FieldByName('codanalisis').AsString));
  lista      := TStringList.Create;
  while not Q.Eof do Begin
    if (Q.FieldByName('codanalisis').AsString <> idanter) then LineaDeterminacionDetallada(codosanter, idanter, salida, xpresentarcantidades);
    idanter    := Q.FieldByName('codanalisis').AsString;
    codosanter := Q.FieldByName('codos').AsString;

    c4         := length(trim(Q.FieldByName('codanalisis').AsString));
    if Q.FieldByName('idprof').AsString <> idanter1 then Begin
      profesional.getDatos(Q.FieldByName('idprof').AsString);
      profesional.SincronizarCategoria(Q.FieldByName('idprof').AsString, xperiodo);
      idanter1 := Q.FieldByName('idprof').AsString;
    end;
    if not xseparar9984 then Begin
      totdet     := totdet + (facturacion.setImporteAnalisis(Q.FieldByName('codos').AsString, Q.FieldByName('codanalisis').AsString, xperiodo) + facturacion.setTot9984);
      totdet     := totdet + facturacion.setTot9984;
      _caran     := facturacion.setCompensacionArancelariaIndividual;
      totdet     := totdet + _caran;
      totales[7] := totales[7] + _caran;
      totales[5] := totales[5] + facturacion.setUG;
      totales[6] := totales[6] + facturacion.setUB;
    end else Begin
      if (length(trim(Q.FieldByName('codanalisis').AsString)) = 4) then obsocial.SincronizarArancel(Q.FieldByName('codos').AsString, xperiodo);
      if (length(trim(Q.FieldByName('codanalisis').AsString)) = 6) then obsocial.SincronizarArancelNBU(Q.FieldByName('codos').AsString, xperiodo);

      importedet := (facturacion.setImporteAnalisis(Q.FieldByName('codos').AsString, Q.FieldByName('codanalisis').AsString, xperiodo));

      m9984      := 0;
      totdet     := totdet + importedet;
      m9984      := facturacion.setTot9984;
      monto9984  := m9984;
      totales[1] := totales[1] + m9984;
      _caran     := facturacion.setCaranSin9984;
      totdet     := totdet + _caran;
      totales[7] := totales[7] + _caran;
      totales[5] := totales[5] + facturacion.setTotUGSin9984;
      totales[6] := totales[6] + facturacion.setTotUBSin9984;

      if Length(Trim(facturacion.setCodigoMontoFijo)) = 0 then Begin  // Determinaciones sin Monto Fijo
        tot9984[2] := tot9984[2] + facturacion.setTotUG9984;
        tot9984[3] := tot9984[3] + facturacion.setTotUB9984;
        tot9984[4] := tot9984[4] + facturacion.setCaran9984;
        tot9984[6] := tot9984[6] + m9984;
        tot9984[7] := tot9984[7] + _caran;
        cantdet[1] := cantdet[1] + 1;
      end else Begin
        dmontofijo := dmontofijo + 1;
        cantdet[3] := cantdet[3] + m9984;  // Total Montos Fijos
      end;

      if m9984 > 0 then Begin    // Reservamos para el 9984
        cantdet[2] := m9984;
      end;

    end;

    if (obsocial.Factnbu = 'S') and (length(trim( Q.FieldByName('codanalisis').AsString)) = 6) then Begin
      totales[5] := 0; totales[6] := 0;
    end else begin
      totnbu[1]  := 0;
    end;

    idanter1   := Q.FieldByName('idprof').AsString;
    totales[2] := totales[2] + 1;

    // Obtener la cantidad de ordenes
    if lista.Count = 0 then lista.Add(Q.FieldByName('idprof').AsString + Q.FieldByName('orden').AsString) else
      if not utiles.verificarItemsLista(lista, Q.FieldByName('idprof').AsString + Q.FieldByName('orden').AsString) then lista.Add(Q.FieldByName('idprof').AsString + Q.FieldByName('orden').AsString);

    Q.Next;
  end;
  Q.Close; Q.Free;
  end;

  if (facturacion.interbase = 'S') then begin
    r     := facturacion.setDeterminacionesFacturadasPorObraSocialIB(xperiodo, xcodos);
    r.Open;
    totales[4] := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0; totales[12] := 0; totales[13] := 0; totales[14] := 0; totales[15] := 0;
    totales[1] := r.RecordCount;
    idanter    := r.FieldByName('codanalisis').AsString;
    codosanter := r.FieldByName('codos').AsString;
    c4         := length(trim(r.FieldByName('codanalisis').AsString));
    lista      := TStringList.Create;
    while not r.Eof do Begin
      if (r.FieldByName('codanalisis').AsString <> idanter) then LineaDeterminacionDetallada(codosanter, idanter, salida, xpresentarcantidades);
      idanter    := r.FieldByName('codanalisis').AsString;
      codosanter := r.FieldByName('codos').AsString;

      c4         := length(trim(r.FieldByName('codanalisis').AsString));
      if r.FieldByName('idprof').AsString <> idanter1 then Begin
        profesional.getDatos(r.FieldByName('idprof').AsString);
        profesional.SincronizarCategoria(r.FieldByName('idprof').AsString, xperiodo);
        idanter1 := r.FieldByName('idprof').AsString;
      end;
      if not xseparar9984 then Begin
        totdet     := totdet + (facturacion.setImporteAnalisis(r.FieldByName('codos').AsString, r.FieldByName('codanalisis').AsString, xperiodo) + facturacion.setTot9984);
        totdet     := totdet + facturacion.setTot9984;
        _caran     := facturacion.setCompensacionArancelariaIndividual;
        totdet     := totdet + _caran;
        totales[7] := totales[7] + _caran;
        totales[5] := totales[5] + facturacion.setUG;
        totales[6] := totales[6] + facturacion.setUB;
      end else Begin
        //if (length(trim(r.FieldByName('codanalisis').AsString)) = 4) then obsocial.SincronizarArancel(r.FieldByName('codos').AsString, xperiodo);
        //if (length(trim(r.FieldByName('codanalisis').AsString)) = 6) then obsocial.SincronizarArancelNBU(r.FieldByName('codos').AsString, xperiodo);

        //importedet := (facturacion.setImporteAnalisis(r.FieldByName('codos').AsString, r.FieldByName('codanalisis').AsString, xperiodo));

        // ------------------------------- 15/01/2020
        __periodo := xperiodo;
        if (length(trim(r.FieldByName('ref1').AsString)) = 7) then __periodo := r.FieldByName('ref1').AsString;

        if (length(trim(r.FieldByName('codanalisis').AsString)) = 4) then obsocial.SincronizarArancel(r.FieldByName('codos').AsString, __periodo);
        if (length(trim(r.FieldByName('codanalisis').AsString)) = 6) then obsocial.SincronizarArancelNBU(r.FieldByName('codos').AsString, __periodo);

        importedet := (facturacion.setImporteAnalisis(r.FieldByName('codos').AsString, r.FieldByName('codanalisis').AsString, __periodo));

        m9984      := 0;
        totdet     := totdet + importedet;
        m9984      := facturacion.setTot9984;
        monto9984  := m9984;
        totales[1] := totales[1] + m9984;
        _caran     := facturacion.setCaranSin9984;
        totdet     := totdet + _caran;
        totales[7] := totales[7] + _caran;
        totales[5] := totales[5] + facturacion.setTotUGSin9984;
        totales[6] := totales[6] + facturacion.setTotUBSin9984;

        if Length(Trim(facturacion.setCodigoMontoFijo)) = 0 then Begin  // Determinaciones sin Monto Fijo
          tot9984[2] := tot9984[2] + facturacion.setTotUG9984;
          tot9984[3] := tot9984[3] + facturacion.setTotUB9984;
          tot9984[4] := tot9984[4] + facturacion.setCaran9984;
          tot9984[6] := tot9984[6] + m9984;
          tot9984[7] := tot9984[7] + _caran;
          cantdet[1] := cantdet[1] + 1;
        end else Begin
          dmontofijo := dmontofijo + 1;
          cantdet[3] := cantdet[3] + m9984;  // Total Montos Fijos
        end;

        if m9984 > 0 then Begin    // Reservamos para el 9984
          cantdet[2] := m9984;
        end;

      end;

      if (obsocial.Factnbu = 'S') and (length(trim( r.FieldByName('codanalisis').AsString)) = 6) then Begin
        totales[5] := 0; totales[6] := 0;
      end else begin
        totnbu[1]  := 0;
      end;

      idanter1   := r.FieldByName('idprof').AsString;
      totales[2] := totales[2] + 1;

      // Obtener la cantidad de ordenes
      if lista.Count = 0 then lista.Add(r.FieldByName('idprof').AsString + r.FieldByName('orden').AsString) else
        if not utiles.verificarItemsLista(lista, r.FieldByName('idprof').AsString + r.FieldByName('orden').AsString) then lista.Add(r.FieldByName('idprof').AsString + r.FieldByName('orden').AsString);

      r.Next;
    end;
    r.Close; r.Free;
  end;

  cantPac := facturacion.setCantidadPacientesFacturadosObraSocial(xperiodo, xcodos);

  LineaDeterminacionDetallada(codosanter, idanter, salida, xpresentarcantidades);
  if (xseparar9984) and (obsocial.FactNBU <> 'S') then Begin   // Linea del 9984
    totales[2] := tot9984[5];
    totales[7] := tot9984[4];
    totales[5] := tot9984[2];
    totales[6] := tot9984[3];

    totdet     := tot9984[3] + tot9984[2] + tot9984[4];
    LineaDeterminacionDetallada(codosanter, '9984', salida, xpresentarcantidades);
  end;

  if not (infderiv) and (totalfinal[1] > 0) and not (xpresentarcantidades) then Begin
    if salida <> 'T' then Begin
      if salida <> 'X' then Begin
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, ' ' , 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Totales: ' , 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(40, list.Lineactual, '', totales[10], 2, 'Arial, negrita, 8');
        list.importe(52, list.Lineactual, '', totales[11], 3, 'Arial, negrita, 8');
        list.importe(64, list.Lineactual, '', totales[12], 4, 'Arial, negrita, 8');
        list.importe(76, list.Lineactual, '', totales[13], 5, 'Arial, negrita, 8');
        list.importe(90, list.Lineactual, '', totales[14], 6, 'Arial, negrita, 8');
      end else Begin
        Inc(fila); vf := IntToStr(fila);
        excel.Alinear('a' + vf, 'a' + vf, 'D');
        excel.setString('a' + vf, 'a' + vf, 'Totales:', 'Arial, negrita, 9');
        ff := vf;
        Dec(fila); vf := IntToStr(fila);
        excel.setFormulaArray('b' + ff, 'b' + ff, '=suma(b6..' + 'b' + vf + ')', 'Arial, negrita, 9');
        excel.setFormulaArray('c' + ff, 'c' + ff, '=suma(c6..' + 'c' + vf + ')', 'Arial, negrita, 9');
        excel.setFormulaArray('d' + ff, 'd' + ff, '=suma(d6..' + 'd' + vf + ')', 'Arial, negrita, 9');
        excel.setFormulaArray('e' + ff, 'e' + ff, '=suma(e6..' + 'e' + vf + ')', 'Arial, negrita, 9');
        excel.setFormulaArray('f' + ff, 'f' + ff, '=suma(f6..' + 'f' + vf + ')', 'Arial, negrita, 9');
      end;
    end else Begin
      list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True); Inc(lineas); if ControlarSalto then titulo5;
      list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then Titulo5;
      list.LineaTxt('Totales:          ', False);
      list.ImporteTxt(totales[10], 5, 2, False);
      list.ImporteTxt(totales[11], 11, 2, False);
      list.ImporteTxt(totales[12], 11, 2, False);
      list.ImporteTxt(totales[13], 11, 2, False);
      list.ImporteTxt(totales[14], 15, 2, True);
    end;
  end;

  if (infderiv) and (totalfinal[1] > 0) and not (xpresentarcantidades) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, ' ' , 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Totales: ' , 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(15, list.Lineactual, '', totalfinal[1], 2, 'Arial, negrita, 8');
      list.importe(25, list.Lineactual, '', totalfinal[2], 3, 'Arial, negrita, 8');
      list.importe(35, list.Lineactual, '', totalfinal[3], 4, 'Arial, negrita, 8');
      list.importe(45, list.Lineactual, '', totalfinal[5] - totalfinal[4], 5, 'Arial, negrita, 8');
      list.importe(65, list.Lineactual, '', totalfinal[6], 6, 'Arial, negrita, 8');
      list.importe(75, list.Lineactual, '', totalfinal[7], 7, 'Arial, negrita, 8');
      list.importe(85, list.Lineactual, '', totalfinal[8], 8, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', totalfinal[9], 9, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 10, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, ' ' , 1, 'Arial, normal, 5', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(fila); vf := IntToStr(fila);
      excel.Alinear('a' + vf, 'a' + vf, 'D');
      excel.setString('a' + vf, 'a' + vf, 'Totales:', 'Arial, negrita, 9');
      ff := vf;
      Dec(fila); vf := IntToStr(fila);
      excel.setFormulaArray('b' + ff, 'b' + ff, '=suma(b6..' + 'b' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('c' + ff, 'c' + ff, '=suma(c6..' + 'c' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('d' + ff, 'd' + ff, '=suma(d6..' + 'd' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('e' + ff, 'e' + ff, '=suma(e6..' + 'e' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('f' + ff, 'f' + ff, '=suma(f6..' + 'f' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('g' + ff, 'g' + ff, '=suma(g6..' + 'g' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('h' + ff, 'h' + ff, '=suma(h6..' + 'h' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('i' + ff, 'i' + ff, '=suma(i6..' + 'i' + vf + ')', 'Arial, negrita, 9');

      fila := fila + 3; vf := IntToStr(fila);
      excel.setString('a' + vf, 'a' + vf, 'Determinaciones con Monto Fijo', 'Arial, negrita, 10');
      fila := fila + 1; vf := IntToStr(fila);
    end;
    totalfinal[10] := totalfinal[9];
    totalfinal[1] := 0; totalfinal[2] := 0; totalfinal[3] := 0; totalfinal[4] := 0; totalfinal[5] := 0; totalfinal[6] := 0; totalfinal[7] := 0; totalfinal[8] := 0; totalfinal[9] := 0;
  end;

  LineaDeterminacionDetalladaMontosFijos(salida, xpresentarcantidades);
  if xseparar9984 then Begin   // Linea del 9984
    totales[2] := dmontofijo;
    totales[7] := 0;
    totales[5] := 0;
    totales[6] := -1;
    totdet     := cantdet[3];

    totalfinal[3] := totalfinal[3] + totdet;
    LineaDeterminacionDetallada(codosanter, '9984', salida, xpresentarcantidades);
  end;

  totalfinal[2]  := totalfinal[2] + cantdet[3];
  totalfinal[10] := totalfinal[10] + totalfinal[2];
  if not (infderiv) and not (xpresentarcantidades) then Begin
    if salida <> 'T' then Begin
      if salida <> 'X' then Begin
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, ' ' , 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Totales: ' , 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(40, list.Lineactual, '', totalfinal[1], 2, 'Arial, negrita, 8');
        list.importe(52, list.Lineactual, '', 0, 3, 'Arial, negrita, 8');
        list.importe(64, list.Lineactual, '', 0, 4, 'Arial, negrita, 8');
        list.importe(76, list.Lineactual, '', 0, 5, 'Arial, negrita, 8');
        list.importe(90, list.Lineactual, '', 0, 6, 'Arial, negrita, 8');
      end else Begin
        Inc(fila); vf := IntToStr(fila);
        excel.Alinear('a' + vf, 'a' + vf, 'D');
        excel.setString('a' + vf, 'a' + vf, 'Totales:', 'Arial, negrita, 9');
        ff := vf;
        Dec(fila); vf := IntToStr(fila);
        excel.setFormulaArray('b' + ff, 'b' + ff, '=suma(b' + IntToStr(ffila) + '..' + 'b' + vf + ')', 'Arial, negrita, 9');
        excel.setFormulaArray('c' + ff, 'c' + ff, '=suma(c' + IntToStr(ffila) + '..' + 'c' + vf + ')', 'Arial, negrita, 9');
        excel.setFormulaArray('d' + ff, 'd' + ff, '=suma(d' + IntToStr(ffila) + '..' + 'd' + vf + ')', 'Arial, negrita, 9');
        excel.setFormulaArray('e' + ff, 'e' + ff, '=suma(e' + IntToStr(ffila) + '..' + 'e' + vf + ')', 'Arial, negrita, 9');
        excel.setFormulaArray('f' + ff, 'f' + ff, '=suma(f' + IntToStr(ffila) + '..' + 'f' + vf + ')', 'Arial, negrita, 9');
      end;
    end else Begin
      list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True); Inc(lineas); if ControlarSalto then titulo5;
      list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then Titulo5;
      list.LineaTxt('Totales:          ', False);
      list.ImporteTxt(totalfinal[1], 5, 2, False);
      list.ImporteTxt(0, 11, 2, False);
      list.ImporteTxt(0, 11, 2, False);
      list.ImporteTxt(0, 11, 2, False);
      list.ImporteTxt(totalfinal[2], 15, 2, True);
    end;
  end;

  if (infderiv) and not (xpresentarcantidades) then Begin
    if (datosdb.Buscar(totos, 'codos', 'periodo', xcodos, xperiodo)) then totos.Edit else totos.Append;
    totos.FieldByName('codos').AsString   := xcodos;
    totos.FieldByName('periodo').AsString := xperiodo;
    totos.FieldByName('total1').AsFloat   := totnbu[6];
    totos.FieldByName('total2').AsFloat   := totalfinal[2];
    try
      totos.Post
     except
      totos.Cancel
    end;

    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, ' ' , 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Totales: ' , 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(15, list.Lineactual, '', totalfinal[1], 2, 'Arial, negrita, 8');
      list.importe(25, list.Lineactual, '', totnbu[5], 3, 'Arial, negrita, 8');
      list.importe(35, list.Lineactual, '##', 0, 4, 'Arial, negrita, 8');
      list.importe(45, list.Lineactual, '', totnbu[9] {totalfinal[3]}, 5, 'Arial, negrita, 8');
      list.importe(55, list.Lineactual, '', totnbu[10], 6, 'Arial, negrita, 8');
      list.importe(65, list.Lineactual, '##', 0, 7, 'Arial, negrita, 8');
      list.importe(75, list.Lineactual, '', totnbu[6], 8, 'Arial, negrita, 8');
      list.importe(85, list.Lineactual, '##', 0, 9, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', totalfinal[2], 10, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 11, 'Arial, normal, 8', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, 'Cant. Ordenes:    ' + IntToStr(lista.Count), 1, 'Arial, negrita, 9', salida, 'N');
      list.Linea(33, list.Lineactual, 'Cant. Pacientes:    ' + inttostr(cantPac), 2, 'Arial, negrita, 9', salida, 'N');

      list.Linea(60, list.Lineactual, 'Total General:', 3, 'Arial, negrita, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totalfinal[10], 4, 'Arial, negrita, 10');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 9', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'S');

      list.Linea(0, 0, '-----------------------------------------------', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(70, list.Lineactual, '-----------------------------------------------', 2, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '             Firma y Sello', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(72, list.Lineactual, '         Firma y Sello', 2, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '          Representante Legal', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(72, list.Lineactual, '     Representante Legal', 2, 'Arial, normal, 10', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, normal, 40', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 40', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 40', salida, 'S');

      list.Linea(0, 0, 'Observaciones:........................................................................................................................................................', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '................................................................................................................................................................................', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '................................................................................................................................................................................', 1, 'Arial, normal, 10', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(fila); vf := IntToStr(fila);
      excel.Alinear('a' + vf, 'a' + vf, 'D');
      excel.setString('a' + vf, 'a' + vf, 'Totales:', 'Arial, negrita, 9');
      ff := vf;
      Dec(fila); vf := IntToStr(fila);
      if ffila > 0 then Begin
      excel.setFormulaArray('b' + ff, 'b' + ff, '=suma(b' + IntToStr(ffila) + '..b' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('c' + ff, 'c' + ff, '=suma(c' + IntToStr(ffila) + '..c' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('d' + ff, 'd' + ff, '=suma(d' + IntToStr(ffila) + '..d' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('e' + ff, 'e' + ff, '=suma(e' + IntToStr(ffila) + '..e' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('f' + ff, 'f' + ff, '=suma(f' + IntToStr(ffila) + '..f' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('g' + ff, 'g' + ff, '=suma(g' + IntToStr(ffila) + '..g' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('h' + ff, 'h' + ff, '=suma(h' + IntToStr(ffila) + '..h' + vf + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('i' + ff, 'i' + ff, '=suma(i' + IntToStr(ffila) + '..i' + vf + ')', 'Arial, negrita, 9');
      end;

      fila := fila + 3; vf := IntToStr(fila);
      excel.setString('a' + vf, 'a' + vf, 'Cant. Ordenes:', 'Arial, negrita, 10');
      excel.Alinear('f' + vf, 'f' + vf, 'D');
      excel.setString('b' + vf, 'b' + vf, IntToStr(lista.Count), 'Arial, negrita, 10');

      excel.setString('d' + vf, 'd' + vf, 'Cant. Pacientes:', 'Arial, negrita, 10');
      excel.setInteger('e' + vf, 'e' + vf, facturacion.setCantidadPacientesFacturadosObraSocial(xperiodo, xcodos), 'Arial, negrita, 10');

      excel.setString('g' + vf, 'g' + vf, 'Total General:', 'Arial, negrita, 10');
      excel.setReal('i' + vf, 'i' + vf, totalfinal[10], 'Arial, negrita, 10');

      fila := fila + 10; vf := IntToStr(fila);
      excel.setString('b' + vf, 'b' + vf, '      Firma y Sello', 'Arial, normal, 8');
      excel.setString('i' + vf, 'i' + vf, '      Firma y Sello', 'Arial, normal, 8');
      fila := fila + 1; vf := IntToStr(fila);
      excel.setString('b' + vf, 'b' + vf, 'Representante Legal', 'Arial, normal, 8');
      excel.setString('i' + vf, 'i' + vf, 'Representante Legal', 'Arial, normal, 8');
      fila := fila + 3; vf := IntToStr(fila);
      excel.setString('a' + vf, 'a' + vf, 'Observaciones:', 'Arial, negrita, 9');
      excel.setString('a2', 'a2', '', 'Arial, normal, 9');
    end;
//    totalfinal[1] := 0; totalfinal[2] := 0; totalfinal[3] := 0; totalfinal[4] := 0; totalfinal[5] := 0; totalfinal[6] := 0; totalfinal[7] := 0; totalfinal[8] := 0; totalfinal[9] := 0;
  end;

  if (xpresentarcantidades) then Begin
    if salida <> 'T' then Begin
      if salida <> 'X' then Begin
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, ' ' , 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Total de Determinaciones: ' , 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(91, list.Lineactual, '', cantidadfinal, 2, 'Arial, negrita, 8');
        list.linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      end else Begin
        Inc(fila); vf := IntToStr(fila);
        excel.Alinear('a' + vf, 'a' + vf, 'D');
        excel.setString('b' + vf, 'b' + vf, 'Totalde Determinaciones:', 'Arial, negrita, 9');
        excel.setReal('c' + vf, 'c' + vf, cantidadfinal, 'Arial, negrita, 9');
      end;
    end else Begin
      list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True); Inc(lineas); if ControlarSalto then titulo5;
      list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then Titulo5;
      list.LineaTxt('Total de Determ.: ', False);
      list.ImporteTxt(cantidadfinal, 5, 2, True);
    end;
  end;

  totalfinal[1] := 0; totalfinal[2] := 0; totalfinal[3] := 0; totalfinal[4] := 0; totalfinal[5] := 0; totalfinal[6] := 0; totalfinal[7] := 0; totalfinal[8] := 0; totalfinal[9] := 0;
  totalfinal[10] := 0; totnbu[5] := 0; totnbu[1] := 0; totnbu[6] := 0;
  lista.Destroy;

  datosdb.closeDB(totos);
  obsocial.desconectar;
  profesional.desconectar;
  nomeclatura.desconectar;
  nomeclaturaos.desconectar;
end;

procedure TTestadisticaCCBCCB.LineaDeterminacionDetallada(xcodos, xcodanalisis: String; salida: Char; xpresentarcantidades: Boolean);
// Objetivo...: List. Detalle de cada codigo facturado
var
  l: Boolean;
  c: String;
begin
  l := True;
  if (length(trim(xcodanalisis)) = 4) or (obsocial.Factnbu = 'N') then c := nomeclaturaos.setCodigoNomeclaturaNacional(xcodos, xcodanalisis) else
    c := xcodanalisis;
  if Length(Trim(c)) = 0 then c := xcodanalisis;

  if not (infderiv) and not (xpresentarcantidades) then Begin
    if {(infderiv) and} (totales[2] > 0) and (totdet > 0) then Begin
      if salida <> 'T' then Begin
        if salida <> 'X' then Begin
          list.Linea(0, 0, c, 1, 'Arial, normal, 8', salida, 'N');
          list.importe(40, list.Lineactual, '', totales[2], 2, 'Arial, normal, 8');
          list.importe(52, list.Lineactual, '', totales[5], 3, 'Arial, normal, 8');
          list.importe(64, list.Lineactual, '', totales[6], 4, 'Arial, normal, 8');
          list.importe(76, list.Lineactual, '', totales[7], 5, 'Arial, normal, 8');
          list.importe(90, list.Lineactual, '', totdet, 6, 'Arial, normal, 8');
          list.Linea(96, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
        end else Begin
          Inc(fila); vf := IntToStr(fila);
          excel.setString('a' + vf, 'a' + vf, '''' + c, 'Arial, normal, 9');
          excel.Alinear('a' + vf, 'a' + vf, 'D');
          excel.setReal('b' + vf, 'b' + vf, totales[2], 'Arial, normal, 9');
          excel.setReal('c' + vf, 'c' + vf, totales[5], 'Arial, normal, 9');
          excel.setReal('d' + vf, 'd' + vf, totales[6], 'Arial, normal, 9');
          excel.setReal('e' + vf, 'e' + vf, totales[7], 'Arial, normal, 9');
          excel.setFormula('f' + vf, 'f' + vf, '=' + 'c' + vf + '+' + 'd' + vf + '+' + 'e' + vf, 'Arial, normal, 9');
        end;
      end else Begin
        list.LineaTxt(c + '               ', False);
        list.ImporteTxt(totales[2], 5, 2, False);
        list.ImporteTxt(totales[5], 11, 2, False);
        list.ImporteTxt(totales[6], 11, 2, False);
        list.ImporteTxt(totales[7], 11, 2, False);
        list.ImporteTxt(totdet, 15, 2, True);
      end;
    end else Begin
      listadet.Add(c + FloatToStr(totales[2]) + ';1' + FloatToStr(totdet));
      listadet1.Add(c);
      l := False;
    end;
  end;

  if (infderiv) and (totales[2] > 0) and (totdet > 0) and not (xpresentarcantidades) then Begin
    if (totales[5] + totales[6] + totales[7] > 0) or (totales[6] < 0) then Begin
      if totales[6] < 0 then totales[6] := 0;
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, xcodanalisis, 1, 'Arial, normal, 8', salida, 'N');
        list.importe(15, list.Lineactual, '', totales[2], 2, 'Arial, normal, 8');
        list.importe(25, list.Lineactual, '', totales[6] / totales[2], 3, 'Arial, normal, 8');
        list.importe(35, list.Lineactual, '', totales[5] / totales[2], 4, 'Arial, normal, 8');
        if totales[6] > 0 then list.importe(45, list.Lineactual, '', utiles.setNro2Dec((totales[5] + totales[6]) / totales[2]), 5, 'Arial, normal, 8') else
          list.importe(45, list.Lineactual, '', totdet / totales[2], 5, 'Arial, normal, 8');
        list.importe(65, list.Lineactual, '', totales[6], 6, 'Arial, normal, 8');
        list.importe(75, list.Lineactual, '', totales[5], 7, 'Arial, normal, 8');
        list.importe(85, list.Lineactual, '', totales[7], 8, 'Arial, normal, 8');
        list.importe(95, list.Lineactual, '', totdet, 9, 'Arial, normal, 8');
        list.Linea(96, list.Lineactual, '', 10, 'Arial, normal, 8', salida, 'S');
      end;
      if salida = 'X' then Begin
        Inc(fila); vf := IntToStr(fila);
        excel.setString('a' + vf, 'a' + vf, '''' + xcodanalisis, 'Arial, normal, 9');
        excel.Alinear('a' + vf, 'a' + vf, 'D');
        excel.setReal('b' + vf, 'b' + vf, totales[2], 'Arial, normal, 9');
        excel.setReal('c' + vf, 'c' + vf, totales[6] / totales[2], 'Arial, normal, 9');
        excel.setReal('d' + vf, 'd' + vf, totales[5] / totales[2], 'Arial, normal, 9');
        if totales[6] > 0 then excel.setReal('e' + vf, 'e' + vf, utiles.setNro2Dec((totales[5] + totales[6] {+ totales[7]}) / totales[2]), 'Arial, normal, 9') else
          excel.setReal('e' + vf, 'e' + vf, totdet / totales[2], 'Arial, normal, 9');
        excel.setReal('f' + vf, 'f' + vf, totales[6], 'Arial, normal, 9');
        excel.setReal('g' + vf, 'g' + vf, totales[5], 'Arial, normal, 9');
        excel.setReal('h' + vf, 'h' + vf, totales[7], 'Arial, normal, 9');
        excel.setReal('i' + vf, 'i' + vf, totdet, 'Arial, normal, 9');
      end;
    end else Begin
      listadet.Add(xcodanalisis + FloatToStr(totales[2]) + ';1' + FloatToStr(totdet));
      listadet1.Add(xcodanalisis);
      l := False;
    end;
    if (l) then Begin
      totalfinal[1] := totalfinal[1] + totales[2];
      totalfinal[2] := totalfinal[2] + (totales[6] / totales[2]);
      totalfinal[3] := totalfinal[3] + (totales[5] / totales[2]);
      totalfinal[4] := totalfinal[4] + (totales[7] / totales[2]);
      totalfinal[5] := totalfinal[5] + (totdet / totales[2]);
      totalfinal[6] := totalfinal[6] + (totales[6]);
      totalfinal[7] := totalfinal[7] + (totales[5]);
      totalfinal[8] := totalfinal[8] + totales[7];
      totalfinal[9] := totalfinal[9] + totdet;
    end;
  end;

  if (l) and not (xpresentarcantidades) then Begin
    if (totdet <> 0) and (total <> 0) then
     totales[4]  := totales[4]  + (totdet / total) * 100;
    if (totales[1] > 0) and (totales[2] > 0) then totales[3]  := totales[3]  + (totales[2] / totales[1]) * 100;
    totales[10] := totales[10] + totales[2];
    totales[11] := totales[11] + totales[5];
    totales[12] := totales[12] + totales[6];
    totales[13] := totales[13] + totales[7];
    totales[14] := totales[14] + totdet;
  end;

  if xcodanalisis <> '9984' then
    if facturacion.setCodigoRecepcionToma then tot9984[5] := tot9984[5] + cantdet[1];

  if (xpresentarcantidades) then Begin
    if (totales[2] > 0) and (totdet > 0) then Begin
      cantidadfinal := cantidadfinal + totales[2];
      nomeclatura.getDatos(c);
      if salida <> 'T' then Begin
        if salida <> 'X' then Begin
          list.Linea(0, 0, c, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(8, list.Lineactual, nomeclatura.Descrip, 2, 'Arial, normal, 8', salida, 'N');
          list.importe(91, list.Lineactual, '', totales[2], 3, 'Arial, normal, 8');
          list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
        end else Begin
          Inc(fila); vf := IntToStr(fila);
          excel.setString('a' + vf, 'a' + vf, '''' + c, 'Arial, normal, 9');
          excel.Alinear('a' + vf, 'a' + vf, 'D');
          excel.setString('b' + vf, 'b' + vf, nomeclatura.descrip, 'Arial, normal, 9');
          excel.setReal('c' + vf, 'c' + vf, totales[2], 'Arial, normal, 9');
        end;
      end;
    End;
  End;

  totdet := 0; totales[2] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; cantdet[1] := 0;
end;

procedure TTestadisticaCCBCCB.LineaDeterminacionDetalladaMontosFijos(salida: Char; xpresentarcantidades: boolean);
// Objetivo...: List. Detalle de cada codigo facturado
var
  i, p: Integer;
  c: String;
begin
  if totalfinal[1] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Determinaciones con Monto Fijo', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;
  end;

  totalfinal[1] := 0; totalfinal[2] := 0; ffila := 0;

  For i := 1 to listadet.Count do Begin
    p := Pos(';1', listadet.Strings[i-1]);
    c4 := length(trim(listadet1.Strings[i-1]));

    if (obsocial.Factnbu = 'N') or  (c4 = 4) then Begin
      c := nomeclaturaos.setCodigoNomeclaturaNacional(codosanter, Copy(listadet.Strings[i-1], 1, 4));
      if Length(Trim(c)) = 0 then c := Copy(listadet.Strings[i-1], 1, 4);
    end;
    if (obsocial.Factnbu = 'S') and (c4 = 6) then Begin
      c := Copy(listadet.Strings[i-1], 1, 6);
      if Length(Trim(c)) = 0 then c := Copy(listadet.Strings[i-1], 1, 6);
    end;

    if not (infderiv) and not (xpresentarcantidades) then Begin
      if salida <> 'T' then Begin
        if salida <> 'X' then Begin
          if (obsocial.Factnbu = 'N') or (c4 = 4) then Begin
            list.Linea(0, 0, c, 1, 'Arial, normal, 8', salida, 'N');
            list.importe(40, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 2, 'Arial, normal, 8');
            list.importe(52, list.Lineactual, '', 0, 3, 'Arial, normal, 8');
            list.importe(64, list.Lineactual, '', 0, 4, 'Arial, normal, 8');
            list.importe(76, list.Lineactual, '', 0, 5, 'Arial, normal, 8');
            list.importe(90, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 6, 'Arial, normal, 8');
            list.Linea(96, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
          end;
          if (obsocial.Factnbu = 'S') and (c4 = 6) then Begin
            list.Linea(0, 0, c, 1, 'Arial, normal, 8', salida, 'N');
            list.importe(40, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))), 2, 'Arial, normal, 8');
            list.importe(52, list.Lineactual, '', 0, 3, 'Arial, normal, 8');
            list.importe(64, list.Lineactual, '', 0, 4, 'Arial, normal, 8');
            list.importe(76, list.Lineactual, '', 0, 5, 'Arial, normal, 8');
            list.importe(90, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 6, 'Arial, normal, 8');
            list.Linea(96, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
          end;
        end else Begin
          Inc(fila); vf := IntToStr(fila);
          if ffila = 0 then ffila := fila;
          if (obsocial.Factnbu = 'N') or (c4 = 4) then Begin
            excel.setString('a' + vf, 'a' + vf, '''' + c, 'Arial, normal, 9');
            excel.Alinear('a' + vf, 'a' + vf, 'D');
            excel.setReal('b' + vf, 'b' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 'Arial, normal, 9');
            excel.setReal('c' + vf, 'c' + vf, 0, 'Arial, normal, 9');
            excel.setReal('d' + vf, 'd' + vf, 0, 'Arial, normal, 9');
            excel.setReal('e' + vf, 'e' + vf, 0, 'Arial, normal, 9');
            excel.setReal('f' + vf, 'f' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 'Arial, normal, 9');
          end;
          if (obsocial.Factnbu = 'N') or (c4 = 6) then Begin
            excel.setString('a' + vf, 'a' + vf, '''' + c, 'Arial, normal, 9');
            excel.Alinear('a' + vf, 'a' + vf, 'D');
            excel.setReal('b' + vf, 'b' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))), 'Arial, normal, 9');
            excel.setReal('c' + vf, 'c' + vf, 0, 'Arial, normal, 9');
            excel.setReal('d' + vf, 'd' + vf, 0, 'Arial, normal, 9');
            excel.setReal('e' + vf, 'e' + vf, 0, 'Arial, normal, 9');
            excel.setReal('f' + vf, 'f' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 'Arial, normal, 9');
          end;
        end;
      end else Begin
        list.LineaTxt(c + '               ', False);
        list.ImporteTxt(StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 5, 2, False);
        list.ImporteTxt(0, 11, 2, False);
        list.ImporteTxt(0, 11, 2, False);
        list.ImporteTxt(0, 11, 2, False);
        list.ImporteTxt(StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 15, 2, True);
      end;
    end;

    if (infderiv) and not (xpresentarcantidades) then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        if (obsocial.Factnbu = 'N') or (c4 = 4) then Begin
          list.Linea(0, 0, Copy(listadet.Strings[i-1], 1, 4), 1, 'Arial, normal, 8', salida, 'N');
          list.importe(15, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 2, 'Arial, normal, 8');
          list.importe(25, list.Lineactual, '', 0, 3, 'Arial, normal, 8');
          list.importe(35, list.Lineactual, '', 0, 4, 'Arial, normal, 8');
          list.importe(45, list.Lineactual, '', (StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20)))) / StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 5, 'Arial, normal, 8');
          list.importe(65, list.Lineactual, '', 0, 6, 'Arial, normal, 8');
          list.importe(75, list.Lineactual, '', 0, 7, 'Arial, normal, 8');
          list.importe(85, list.Lineactual, '', 0, 8, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 9, 'Arial, normal, 8');
          list.Linea(96, list.Lineactual, '', 10, 'Arial, normal, 8', salida, 'S');
        end;
        if (obsocial.Factnbu = 'S') and (c4 = 6) then Begin
          // para estadisticas IAPOS
          list.Linea(0, 0, Copy(listadet.Strings[i-1], 1, 6), 1, 'Arial, normal, 8', salida, 'N');
          list.importe(15, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))), 2, 'Arial, normal, 8');
          nbu.getDatos(Copy(listadet.Strings[i-1], 1, 6));

          totnbu[1] := unidadesNBU.getUnidad(nbu.Codigo, __periodo);
          //totnbu[1] := nbu.unidad;
          totnbu[5] := totnbu[5] + nbu.unidad;
          if (totnbu[1] <> 0) then
            list.importe(25, list.Lineactual, '', totnbu[1], 3, 'Arial, normal, 8')
          else
            list.importe(25, list.Lineactual, '', 0, 3, 'Arial, normal, 8');

          list.importe(35, list.Lineactual, '', unidadref, 4, 'Arial, normal, 8');
          if (unidadref = 0) then
            list.importe(45, list.Lineactual, '', (StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20)))) / StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))), 5, 'Arial, normal, 8')
          else
            list.importe(45, list.Lineactual, '', totnbu[1] * unidadref, 5, 'Arial, normal, 8');

          totnbu[2] := nbu.unidad * StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7)));
          totnbu[9] := totnbu[9] + (totnbu[1] * unidadref);

          list.importe(55, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))) * (totnbu[1] * unidadref), 6, 'Arial, normal, 8');
          totnbu[10] := totnbu[10] + (StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))) * (totnbu[1] * unidadref));

          list.importe(65, list.Lineactual, '', obsocial.valorNBU, 7, 'Arial, normal, 8');
          totnbu[6] := totnbu[6] + totnbu[2];
          list.importe(75, list.Lineactual, '', totnbu[2], 8, 'Arial, normal, 8');
          list.importe(85, list.Lineactual, '##', 0, 9, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 10, 'Arial, normal, 8');
          list.Linea(96, list.Lineactual, '', 11, 'Arial, normal, 8', salida, 'S');
        end;
      end;
      if salida = 'X' then Begin
        Inc(fila); vf := IntToStr(fila);
        if ffila = 0 then ffila := fila;
        if (obsocial.Factnbu = 'N') or (c4 = 4) then Begin
          excel.setString('a' + vf, 'a' + vf, '''' + Copy(listadet.Strings[i-1], 1, 4), 'Arial, normal, 9');
          excel.Alinear('a' + vf, 'a' + vf, 'D');
          excel.setReal('b' + vf, 'b' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 'Arial, normal, 9');
          excel.setReal('c' + vf, 'c' + vf, 0, 'Arial, normal, 9');
          excel.setReal('d' + vf, 'd' + vf, 0, 'Arial, normal, 9');
          excel.setReal('e' + vf, 'e' + vf, (StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20)))) / StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 'Arial, normal, 9');
          excel.setReal('f' + vf, 'f' + vf, 0, 'Arial, normal, 9');
          excel.setReal('g' + vf, 'g' + vf, 0, 'Arial, normal, 9');
          excel.setReal('h' + vf, 'h' + vf, 0, 'Arial, normal, 9');
          excel.setReal('i' + vf, 'i' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 'Arial, normal, 9');
        end;
        if (obsocial.Factnbu = 'S') and (c4 = 6) then Begin
          // para estadisticas IAPOS
          excel.setString('a' + vf, 'a' + vf, '''' + c, 'Arial, normal, 9');
          excel.Alinear('a' + vf, 'a' + vf, 'D');
          excel.setReal('b' + vf, 'b' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))), 'Arial, normal, 9');
          nbu.getDatos(Copy(listadet.Strings[i-1], 1, 6));
          //totnbu[1] := nbu.unidad;
          totnbu[1] := unidadesNBU.getUnidad(nbu.Codigo, __periodo);
          totnbu[5] := totnbu[5] + nbu.unidad;
          if (totnbu[1] <> 0) then
            excel.setReal('c' + vf, 'c' + vf, totnbu[1], 'Arial, normal, 9')
          else
            excel.setReal('c' + vf, 'c' + vf, 0, 'Arial, normal, 9');

          excel.setReal('d' + vf, 'd' + vf, unidadref, 'Arial, normal, 9');
          if (unidadref = 0) then
            excel.setReal('e' + vf, 'e' + vf, (StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20)))) / StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))), 'Arial, normal, 9')
          else
            excel.setReal('e' + vf, 'e' + vf, totnbu[1] * unidadref, 'Arial, normal, 9');

          totnbu[2] := nbu.unidad * StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7)));
          totnbu[9] := totnbu[9] + (totnbu[1] * unidadref);

          excel.setReal('f' + vf, 'f' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))) * (totnbu[1] * unidadref), 'Arial, normal, 9');
          totnbu[10] := totnbu[10] + (StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))) * (totnbu[1] * unidadref));
          excel.setReal('g' + vf, 'g' + vf, obsocial.valorNBU, 'Arial, normal, 9');
          totnbu[6] := totnbu[6] + totnbu[2];
          excel.setReal('h' + vf, 'h' + vf, totnbu[2], 'Arial, normal, 9');
          excel.setReal('i' + vf, 'i' + vf, 0, 'Arial, normal, 9');
          excel.setReal('j' + vf, 'j' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20))), 'Arial, normal, 9');
        end;
      end;
    end;

    if (xpresentarcantidades) then Begin
      if salida <> 'T' then Begin
        if salida <> 'X' then Begin
          if (obsocial.Factnbu = 'N') or (Length(trim(c)) = 4) then Begin
            nomeclatura.getDatos(c);
            list.Linea(0, 0, c, 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(8, list.Lineactual, nomeclatura.descrip, 2, 'Arial, normal, 8', salida, 'N');
            list.importe(91, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 3, 'Arial, normal, 8');
            list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
          end;
          if (obsocial.Factnbu = 'S') and (Length(trim(c)) = 6) then Begin
            nbu.getDatos(c);
            list.Linea(0, 0, c, 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(8, list.Lineactual, nbu.descrip, 2, 'Arial, normal, 8', salida, 'N');
            list.importe(91, list.Lineactual, '', StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 3, 'Arial, normal, 8');
            list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
          end;
        end else Begin
          Inc(fila); vf := IntToStr(fila);
          if ffila = 0 then ffila := fila;
          if (obsocial.Factnbu = 'N') or (Length(trim(c)) = 4) then Begin
            nomeclatura.getDatos(c);
            excel.setString('a' + vf, 'a' + vf, '''' + c, 'Arial, normal, 9');
            excel.Alinear('a' + vf, 'a' + vf, 'D');
            excel.setString('b' + vf, 'b' + vf, '''' + nomeclatura.descrip, 'Arial, normal, 9');
            excel.setReal('c' + vf, 'c' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5))), 'Arial, normal, 9');
          end;
          if (obsocial.Factnbu = 'N') or (Length(trim(c)) = 4) then Begin
            nbu.getDatos(c);
            excel.setString('a' + vf, 'a' + vf, '''' + c, 'Arial, normal, 9');
            excel.Alinear('a' + vf, 'a' + vf, 'D');
            excel.setString('b' + vf, 'b' + vf, '''' + nbu.Descrip, 'Arial, normal, 9');
            excel.setReal('c' + vf, 'c' + vf, StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7))), 'Arial, normal, 9');
          end;
        end;
      End;
      cantidadfinal := cantidadfinal + StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7)));
    End;

    if (obsocial.Factnbu = 'N') or (c4 = 4) then Begin
      totalfinal[1] := totalfinal[1] + StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5)));
      totalfinal[2] := totalfinal[2] + StrToFloat(Trim(Copy(listadet.Strings[i-1], P+2, 20)));
      totalfinal[3] := totalfinal[3] + (StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20)))) / StrToFloat(Trim(Copy(listadet.Strings[i-1], 5, p-5)));
    end;
    if (obsocial.Factnbu = 'S') and (c4 = 6) then Begin
      totalfinal[1] := totalfinal[1] + StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7)));
      totalfinal[2] := totalfinal[2] + StrToFloat(Trim(Copy(listadet.Strings[i-1], P+2, 20)));
      totalfinal[3] := totalfinal[3] + (StrToFloat(Trim(Copy(listadet.Strings[i-1], p+2, 20)))) / StrToFloat(Trim(Copy(listadet.Strings[i-1], 7, p-7)));
    end;
  end;
end;

procedure TTestadisticaCCBCCB.InicidenciaDeCadaProfesional_Global(xperiodo, xcodos: String; salida: Char);
// Objetivo...: List. Porcentaje de incidencia de cada Profesional
var
  idanter: String;
begin
  fecha1 := xperiodo;
  obsocial.conectar;
  profesional.conectar;
  nbu.conectar;
  if Length(Trim(xcodos)) > 0 then obsocial.getDatos(xcodos);

  if salida <> 'T' then Begin
    inherited Titulos('Porcentaje de Incidencia por Profesional', salida);
    list.Titulo(0, 0, 'Id.        Profesional', 1, 'Arial, cursiva, 8');
    list.Titulo(87, list.Lineactual, 'Porcentaje', 2, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end else Titulo3(xcodos);

  total := facturacion.setTotalFacturadoProfesionales(xperiodo);
  Q     := facturacion.setItemsTotalFacturadoProfesionales(xperiodo);
  Q.Open; totales[4] := 0; totales[5] := 0;
  idanter := Q.FieldByName('idprof').AsString;
  while not Q.Eof do Begin
    if Q.FieldByName('idprof').AsString <> idanter then lineaProf(idanter, xcodos, salida);
    totales[5] := totales[5] + (Q.FieldByName('monto').AsFloat / total) * 100;
    totales[4] := totales[4] + (Q.FieldByName('monto').AsFloat / total) * 100;
    idanter    := Q.FieldByName('idprof').AsString;
    Q.Next;
  end;
  lineaProf(idanter, xcodos, salida);
  if salida <> 'T' then Begin
    list.Linea(0, 0, ' ' , 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Totales: ' , 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[4], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end else Begin
    list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then Titulo3(xcodos);
    list.LineaTxt('Totales: ' + utiles.espacios(57), False);
    list.ImporteTxt(totales[4], 13, 2, True); Inc(lineas); if controlarSalto then Titulo3(xcodos);
  end;
  Q.Close; Q.Free;
  obsocial.desconectar;
  profesional.desconectar;
  nbu.desconectar;
end;

procedure TTestadisticaCCBCCB.LineaProf(xidanter, xcodos: String; salida: Char);
// Objetivo...: Linea subtotal Profesional
Begin
  profesional.getDatos(xidanter);
  if salida <> 'T' then Begin
    list.Linea(0, 0, xidanter + '   ' + profesional.nombre, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[5], 2, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(Copy(xidanter + '   ' + profesional.nombre, 1, 43) + utiles.espacios(56 - Length(TrimRight(Copy(profesional.nombre, 1, 43)))), False);
    list.ImporteTxt(totales[5], 14, 2, True); Inc(lineas); if controlarSalto then Titulo3(xcodos);
  end;
  totales[5] := 0;
end;

procedure TTestadisticaCCBCCB.LineaDeterminacionParticular(xcodanalisis: String; salida: Char);
// Objetivo...: List. Porcentaje de incidencia de cada Obra Social
var
  des: String;
begin
  if obsocial.Factnbu = 'S' then Begin
    nbu.getDatos(xcodanalisis);
    des := nbu.Descrip;
  end;
  if obsocial.Factnbu = 'N' then Begin
    nomeclatura.getDatos(xcodanalisis);
    des := nomeclatura.descrip;
  end;
  if salida <> 'T' then Begin
    list.Linea(0, 0, xcodanalisis + '          ' + des, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[1], 2, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', totdet, 3, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(xcodanalisis + '  ' + Copy(des, 1, 43) + utiles.espacios(45 - (Length(TrimRight(Copy(des, 1, 43))))), False);
    list.ImporteTxt(totales[1], 12, 2, False);
    list.ImporteTxt(totdet, 12, 2, True); Inc(lineas); if controlarSalto then Titulo4;
  end;
  totdet := 0; totales[1] := 0;
end;

procedure TTestadisticaCCBCCB.InicidenciaDeCadaProfesionalDet_Global(xperiodo: String; listprof, listos: TStringList; salida: Char);
// Objetivo...: List. Porcentaje de incidencia de cada Profesional
var
  idanter, codanter: String;
begin
  fecha1 := xperiodo;
  obsocial.conectar;
  profesional.conectar;
  nbu.conectar;

  if salida <> 'T' then Begin
    inherited Titulos('Pr�cticas Facturadas por Profesional', salida);
    list.Titulo(0, 0, 'C�digo   Determinaci�n', 1, 'Arial, cursiva, 8');
    list.Titulo(87, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end else Titulo7;

  Q     := facturacion.setDeterminacionesProfesional(xperiodo);
  Q.Open; totales[4] := 0; codosanter := ''; idanter := ''; totales[1] := 0;
  while not Q.Eof do Begin
    if (utiles.verificarItemsLista(listprof, Q.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(listos, Q.FieldByName('codos').AsString)) then Begin

      if (Q.FieldByName('codanalisis').AsString <> codanter) and (totales[4] > 0) then Begin
        LineaDeterminaciones(codanter, totales[4], salida);
      end;

      if Q.FieldByName('idprof').AsString <> idanter then Begin
        if totales[4] > 0 then  LineaDeterminaciones(codanter, totales[4], salida);

        profesional.getDatos(Q.FieldByName('idprof').AsString);
        if salida <> 'T' then Begin
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
          list.Linea(0, 0, Q.FieldByName('idprof').AsString + '   ' + profesional.nombre, 1, 'Arial, negrita, 9, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        end else Begin
          list.LineaTxt(Q.FieldByName('idprof').AsString + ' ' + profesional.nombre, True);
          Inc(lineas); if controlarSalto then Titulo7;
        end;
        codosanter := '';
      end;

      if Q.FieldByName('codos').AsString <> codosanter then Begin
        if totales[4] > 0 then LineaDeterminaciones(codanter, totales[4], salida);
        if totales[1] > 0 then TotalDeterminaciones(salida);

        obsocial.getDatos(Q.FieldByName('codos').AsString);
        if salida <> 'T' then Begin
          list.Linea(0, 0, Q.FieldByName('codos').AsString + '   ' + obsocial.Nombre, 1, 'Arial, negrita, 8', salida, 'S');
        end else Begin
          list.LineaTxt(Copy(Q.FieldByName('codos').AsString + '  ' + obsocial.nombre, 1, 43) + utiles.espacios(56 - Length(TrimRight(Copy(obsocial.nombre, 1, 43)))), True);
          Inc(lineas); if controlarSalto then Titulo7;
        end;
      end;

      totales[4] := totales[4] + 1;
      idanter    := Q.FieldByName('idprof').AsString;
      codosanter := Q.FieldByName('codos').AsString;
      codanter   := Q.FieldByName('codanalisis').AsString;
    end;
    Q.Next;
  end;

  LineaDeterminaciones(codanter, totales[4], salida);
  TotalDeterminaciones(salida);

  Q.Close; Q.Free;
  obsocial.desconectar;
  profesional.desconectar;
  nbu.desconectar;

  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTestadisticaCCBCCB.LineaDeterminaciones(xcodanalisis: String; xtotal: Real; salida: char);
// Objetivo...: Listar Linea de determinaciones
var
  descrip: String;
Begin
  if Length(Trim(xcodanalisis)) = 4 then Begin
    nomeclatura.getDatos(xcodanalisis);
    descrip := nomeclatura.descrip;
  end;
  if Length(Trim(xcodanalisis)) = 6 then Begin
    nbu.getDatos(xcodanalisis);
    descrip := nbu.Descrip;
  end;
  if salida <> 'T' then Begin
    list.Linea(0, 0, '   ' + xcodanalisis, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, descrip, 2, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.Lineactual, '#####', xtotal, 3, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
  end else Begin
    descrip := xcodanalisis + '  ' + Copy(descrip, 1, 45);
    list.LineaTxt(Copy(descrip, 1, 50) + utiles.espacios(51 - Length(TrimRight(Copy(descrip, 1, 50)))), False);
    list.ImporteTxt(xtotal, 6, 0, True);
    Inc(lineas); if controlarSalto then Titulo7;
  end;
  totales[1] := totales[1] + totales[4];
  totales[4] := 0;
end;

procedure TTestadisticaCCBCCB.TotalDeterminaciones(salida: char);
// Objetivo...: Listar total de determinaciones
var
  descrip: String;
Begin
  descrip := 'Total de Determinaciones:';
  if salida <> 'T' then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'N');
    list.derecha(90, list.Lineactual, '', '------------------', 2, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, descrip, 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(90, list.Lineactual, '#####', totales[1], 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, ' ', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end else Begin
    list.LineaTxt(Copy(descrip, 1, 50) + utiles.espacios(51 - Length(TrimRight(Copy(descrip, 1, 50)))), False);
    list.ImporteTxt(totales[1], 6, 0, True);
    Inc(lineas); if controlarSalto then Titulo7;
  end;
  totales[1] := 0;
end;

procedure TTestadisticaCCBCCB.PracticasFacturadas_Global(xperiodo: String; obsociales: TStringList; salida: Char);
// Objetivo...: Listar C�digos a Facturar
var
  codosanter, idanter, idprofanter: String;
Begin
  fecha1 := xperiodo;
  nomeclatura.conectar;
  profesional.conectar;
  obsocial.conectar;
  nbu.conectar;

  if salida <> 'T' then Begin
    inherited Titulos('Informe de Pr�cticas Realizadas', salida);
    list.Titulo(0, 0, 'C�digo      Determinaci�n', 1, 'Arial, cursiva, 8');
    list.Titulo(44, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
    list.Titulo(55, list.Lineactual, 'Gastos', 3, 'Arial, cursiva, 8');
    list.Titulo(62, list.Lineactual, 'Honorarios', 4, 'Arial, cursiva, 8');
    list.Titulo(71, list.Lineactual, 'Compensaci�n', 5, 'Arial, cursiva, 8');
    list.Titulo(92, list.Lineactual, 'Total', 6, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end else
    Titulo6;

  Q := facturacion.setDeterminacionesFacturadas(xperiodo);
  Q.Open; totales[4] := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[5] := 0; totales[6] := 0;
  obsocial.getDatos(Q.FieldByName('codos').AsString);

  while not Q.Eof do Begin
    if utiles.verificarItemsLista(obsociales, Q.FieldByName('codos').AsString) then Begin

      if Q.FieldByName('codos').AsString <> codosanter then Begin
        obsocial.getDatos(Q.FieldByName('codos').AsString);
        if totales[2] > 0 then Begin
          LineaDeterminacionCodigos(codosanter, idanter, salida);
          if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S') else Begin
            list.LineaTxt('  ', True);
            Inc(lineas); if controlarSalto then Titulo6;
          end;
        end;

        if totales[6] > 0 then TotalObraSocialOrdenes(salida);

        if salida <> 'T' then Begin
          list.Linea(0, 0, 'Obra Social: ' + Q.FieldByName('codos').AsString + '  ' + obsocial.Nombre, 1, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end else Begin
          list.LineaTxt('Obra Social: ' + Q.FieldByName('codos').AsString + '  ' + obsocial.Nombre, True);
          Inc(lineas); if controlarSalto then Titulo6;
          list.LineaTxt('  ', True);
          Inc(lineas); if controlarSalto then Titulo6;
        end;
      end;

      if (Q.FieldByName('codanalisis').AsString <> idanter) and (Length(Trim(idanter)) > 0) then LineaDeterminacionCodigos(codosanter, idanter, salida);
      totales[2]  := totales[2] + 1;

      if Q.FieldByName('idprof').AsString <> idprofanter then Begin
        profesional.getDatos(Q.FieldByName('idprof').AsString);
        profesional.SincronizarCategoria(Q.FieldByName('idprof').AsString, xperiodo);
      end;

      if (length(trim(Q.FieldByName('codanalisis').AsString)) = 4) then obsocial.SincronizarArancel(Q.FieldByName('codos').AsString, xperiodo);
      if (length(trim(Q.FieldByName('codanalisis').AsString)) = 6) then obsocial.SincronizarArancelNBU(Q.FieldByName('codos').AsString, xperiodo);

      totales[5] := totales[5] + (facturacion.setImporteAnalisis(Q.FieldByName('codos').AsString, Q.FieldByName('codanalisis').AsString, xperiodo));


      {ver nbu
      nomeclatura.getDatos(Q.FieldByName('codanalisis').AsString);
      totales[5] := totales[5] + ((nomeclatura.ub * obsocial.UB) * (profesional.porcUB * 0.01));
      }

      idanter     := Q.FieldByName('codanalisis').AsString;
      codosanter  := Q.FieldByName('codos').AsString;
      idprofanter := Q.FieldByName('idprof').AsString;

    end;
    Q.Next;
  end;

  LineaDeterminacionCodigos(codosanter, idanter, salida);
  TotalObraSocialOrdenes(salida);

  if salida <> 'T' then Begin
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(50, list.Lineactual, '####', totales[11], 2, 'Arial, negrita, 8');
    list.importe(60, list.Lineactual, '', totales[12], 3, 'Arial, negrita, 8');
    list.importe(70, list.Lineactual, '', totales[13], 4, 'Arial, negrita, 8');
    list.importe(80, list.Lineactual, '', totales[14], 5, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[15], 6, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 7, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  end else Begin
    list.LineaTxt('', True); Inc(lineas); if controlarSalto then Titulo6;
    list.LineaTxt('TOTAL GENERAL:' + utiles.espacios(36 - Length(TrimRight('TOTAL GENERAL:'))), False);
    list.ImporteTxt(totales[11], 5, 0, False);
    list.ImporteTxt(totales[12], 10, 2, False);
    list.ImporteTxt(totales[13], 10, 2, False);
    list.ImporteTxt(totales[14], 9, 2, False);
    list.ImporteTxt(totales[15], 10, 2, True);
  end;

  Q.Close; Q.Free;
  obsocial.desconectar;
  profesional.desconectar;
  nomeclatura.desconectar;
  nbu.desconectar;
end;

procedure TTestadisticaCCBCCB.LineaDeterminacionCodigos(xcodos, xcodanalisis: String; salida: Char);
// Objetivo...: List. Porcentaje de incidencia de cada Profesional
var
  des: String;
begin
  if totales[2] <> 0 then Begin
    if obsocial.Factnbu = 'S' then Begin
      nbu.getDatos(xcodanalisis);
      des := nbu.Descrip;
    end;
    if obsocial.Factnbu = 'N' then Begin
      nomeclatura.getDatos(xcodanalisis);
      des := nomeclatura.descrip;
    end;
    if salida <> 'T' then Begin
      list.Linea(0, 0, xcodanalisis + '  ' + des, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(50, list.Lineactual, '####', totales[2], 2, 'Arial, normal, 8');
      list.importe(60, list.Lineactual, '', (nomeclatura.gastos * obsocial.UG) * totales[2], 3, 'Arial, normal, 8');
      list.importe(70, list.Lineactual, '', (nomeclatura.ub * obsocial.UB) * totales[2], 4, 'Arial, normal, 8');
      list.importe(80, list.Lineactual, '', totales[5], 5, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', totales[5] + ((nomeclatura.gastos * obsocial.UG) * totales[2]) + ((nomeclatura.ub * obsocial.UB) * totales[2]), 6, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.LineaTxt(xcodanalisis + ' ' + Copy(TrimRight(des), 1, 30) + utiles.espacios(31 - Length(Copy(TrimRight(des), 1, 30))), False);
      list.ImporteTxt(totales[2], 5, 0, False);
      list.ImporteTxt((nomeclatura.gastos * obsocial.UG) * totales[2], 10, 2, False);
      list.ImporteTxt((nomeclatura.ub * obsocial.UB) * totales[2], 10, 2, False);
      list.ImporteTxt(totales[5], 9, 2, False);
      list.ImporteTxt(totales[5] + ((nomeclatura.gastos * obsocial.UG) * totales[2]) + ((nomeclatura.ub * obsocial.UB) * totales[2]), 10, 2, True);
      Inc(lineas); if controlarSalto then Titulo6;
    end;
    totales[6]  := totales[6]  + totales[2];
    totales[7]  := totales[7]  + ((nomeclatura.gastos * obsocial.UG) * totales[2]);
    totales[8]  := totales[8]  + ((nomeclatura.ub * obsocial.UB) * totales[2]);
    totales[9]  := totales[9]  + totales[5];
    totales[10] := totales[10] + (totales[5] + ((nomeclatura.gastos * obsocial.UG) * totales[2]) + ((nomeclatura.ub * obsocial.UB) * totales[2]));
    totdet := 0; totales[2] := 0; totales[5] := 0;
  end;
end;

procedure TTestadisticaCCBCCB.TotalObraSocialOrdenes(salida: char);
// Objetivo...: List. Porcentaje de incidencia de cada Profesional
begin
  if salida <> 'T' then Begin
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total Obra Social:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(50, list.Lineactual, '####', totales[6], 2, 'Arial, negrita, 8');
    list.importe(60, list.Lineactual, '', totales[7], 3, 'Arial, negrita, 8');
    list.importe(70, list.Lineactual, '', totales[8], 4, 'Arial, negrita, 8');
    list.importe(80, list.Lineactual, '', totales[9], 5, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[10], 6, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 7, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  end else Begin
    list.LineaTxt('', True); Inc(lineas); if controlarSalto then Titulo6;
    list.LineaTxt('Total Obra Social:' + utiles.espacios(36 - Length(TrimRight('Total Obra Social:'))), False);
    list.ImporteTxt(totales[6], 5, 0, False);
    list.ImporteTxt(totales[7], 10, 2, False);
    list.ImporteTxt(totales[8], 10, 2, False);
    list.ImporteTxt(totales[9], 9, 2, False);
    list.ImporteTxt(totales[10], 10, 2, True);
    Inc(lineas); if controlarSalto then Titulo6;
    list.LineaTxt('', True); Inc(lineas); if controlarSalto then Titulo6;
  end;
  totales[11] := totales[11] + totales[6];
  totales[12] := totales[12] + totales[7];
  totales[13] := totales[13] + totales[8];
  totales[14] := totales[14] + totales[9];
  totales[15] := totales[15] + totales[10];
  totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0;
end;

procedure TTestadisticaCCBCCB.InicidenciaCodigosFactPesos(xperiodo, xcodos: String; salida: Char);
// Objetivo...: Incidencia por c�digo en cada Obra Social, expresado en pesos
var
  idanter: String;
Begin
  fecha1 := xperiodo;
  nomeclatura.conectar;
  profesional.conectar;
  obsocial.conectar;
  nbu.conectar;
  obsocial.getDatos(xcodos);

  if salida <> 'T' then Begin
    inherited Titulos('Incidencia de Codigos Facturados en Valores', salida);
    list.Titulo(0, 0, 'C�digo      Determinaci�n', 1, 'Arial, cursiva, 8');
    list.Titulo(74, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, 'Importe', 3, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
    list.Titulo(0, 0, 'Obra Social: ' + Copy(obsocial.Nombre, 1, 30), 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end else Titulo4;

  total := facturacion.setTotalFacturado(xperiodo);
  facturacion.setTotalFacturado(xperiodo);
  Q     := facturacion.setDeterminacionesFacturadasPorObraSocial(xperiodo, xcodos);
  Q.Open; totales[1] := 0;
  idanter := Q.FieldByName('codanalisis').AsString;
  while not Q.Eof do Begin
    if Q.FieldByName('codanalisis').AsString <> idanter then LineaDeterminacionParticular(idanter, salida);
    idanter    := Q.FieldByName('codanalisis').AsString;
    totdet     := totdet + facturacion.setImporteAnalisis(Q.FieldByName('codos').AsString, Q.FieldByName('codanalisis').AsString);
    totales[1] := totales[1]   + 1;
    Q.Next;
  end;
  LineaDeterminacionParticular(idanter, salida);
  Q.Close; Q.Free;
  obsocial.desconectar;
  profesional.desconectar;
  nomeclatura.desconectar;
  nbu.desconectar;
end;

procedure TTestadisticaCCBCCB.InicidenciaCodigosFacturadosPorProfesional(xperiodo, xcodos: String; salida: Char);
// Objetivo...: Incidencia por c�digo en cada Obra Social, expresado en pesos
Begin
  fecha1 := xperiodo;
  nomeclatura.conectar;
  profesional.conectar;
  obsocial.conectar;
  nbu.conectar;
  obsocial.getDatos(xcodos);
  if salida <> 'T' then Begin
    inherited Titulos('Porcentaje de Incidencia de C�digos por Profesional', salida);
    list.Titulo(0, 0, 'Id.        Profesional', 1, 'Arial, cursiva, 8');
    list.Titulo(87, list.Lineactual, 'Porcentaje', 2, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Obra Social: ' + Copy(obsocial.Nombre, 1, 30), 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end else Titulo3(xcodos);

  facturacion.setTotalFacturadoProfesionales(xperiodo, xcodos);
  total := facturacion.setTotalProfesional(xperiodo, xcodos);
  Q     := facturacion.setItemsTotalFacturadoProfesionales(xperiodo);
  Q.Open; totales[4] := 0;
  datosdb.Filtrar(Q, 'codos = ' + xcodos);
  while not Q.Eof do Begin
    totales[5] := facturacion.setTotalProfesional(xperiodo, Q.FieldByName('idprof').AsString, xcodos);
    if totales[5] > 0 then Begin
      if salida <> 'T' then Begin
        list.Linea(0, 0, Q.FieldByName('idprof').AsString + '   ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', (totales[5] / total) * 100, 2, 'Arial, normal, 8');
        list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
        totales[4] := totales[4] + (totales[5] / total) * 100;
      end else Begin
        list.LineaTxt(Q.FieldByName('idprof').AsString + '   ' + Copy(Q.FieldByName('nombre').AsString, 1, 43) + utiles.espacios(56 - Length(TrimRight(Copy(Q.FieldByName('nombre').AsString, 1, 43)))), False);
        list.ImporteTxt((totales[5] / total) * 100, 14, 2, True); Inc(lineas); if controlarSalto then Titulo3(xcodos);
      end;
    end;
    Q.Next;
  end;
  if salida <> 'T' then Begin
    list.Linea(0, 0, ' ' , 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total: ' , 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[4], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end else Begin
    list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then Titulo3(xcodos);
    list.LineaTxt('Total: ' + utiles.espacios(59), False);
    list.ImporteTxt(totales[4], 13, 2, True); Inc(lineas); if controlarSalto then Titulo3(xcodos);
  end;
  Q.Close; Q.Free;
  obsocial.desconectar;
  profesional.desconectar;
  nomeclatura.desconectar;
  nbu.desconectar;
end;

//------------------------------------------------------------------------------

procedure TTestadisticaCCBCCB.InfComparacinProfesionales(xcodos, xperdesde, xperhasta: String; salida: char);
const
  l: array[1..12] of String = ('b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm');
var
  i, j: Integer;
  per: String;
  p: array[1..15] of String;
  imp: Real;
Begin
  obsocial.getDatos(xcodos);
  if salida <> 'X' then Begin
    if not infderiv then Begin
      Titulos('Comparaci�n Total Facturado Profesionales', salida);
      list.Titulo(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, Negrita, 12');
      list.Titulo(0, 0, ' ', 1, 'Arial, Normal, 5');
    end;
  end else Begin
    excel.FijarAnchoColumna('a1', 'a1', 25);
    excel.setString('a1', 'a1', 'Comparaci�n Total Facturado Profesionales', 'Arial, negrita, 16');
    excel.setString('a3', 'a3', 'Obra Social: ' + obsocial.Nombre, 'Arial, negrita, 12');
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, 'Per./Profesional', 1, 'Arial, cursiva, 8');
    j := 18; per := xperdesde;
    For i := 1 to 12 do Begin
      list.Titulo(j, list.Lineactual, per, i+1, 'Arial, cursiva, 8');
      per  := utiles.SumarPeriodo(per, '1');
      p[i] := per;
      j    := j + 7;
    end;
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if salida = 'X' then Begin
    excel.setString('a5', 'a5', 'Per./Profesional', 'Arial, negrita, 9');

    j := 18; per := xperdesde;
    For i := 1 to 12 do Begin
      list.Titulo(j, list.Lineactual, per, i+1, 'Arial, cursiva, 8');
      excel.setString(l[i] + '5',  l[i] + '5', per, 'Arial, negrita, 9');
      per  := utiles.SumarPeriodo(per, '1');
      p[i] := per;
      j    := j + 7;
    end;
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;

  q := profesional.setProfesionalesAlf;
  q.Open; fila := 5;

  facturacion.ConectarTotalesProf;
  while not q.Eof do Begin
    list.Linea(0, 0, Copy(q.FieldByName('nombre').AsString, 1, 18), 1, 'Arial, normal, 8', salida, 'N');
    j := 18; per := xperdesde;
    Inc(fila); vf := IntToStr(fila);
    For i := 1 to 12 do Begin
      imp := facturacion.setNetoACobrarProfesional(per, q.FieldByName('idprof').AsString, xcodos);
      if (salida = 'I') or (salida = 'P') then list.importe(j+6, list.Lineactual, '', imp, i+1, 'Arial, normal, 8');
      if salida = 'X' then Begin
        excel.setString('a' + vf, 'a' + vf, Copy(q.FieldByName('nombre').AsString, 1, 18), 'Arial, normal, 9');
        excel.Alinear(l[i] + vf, l[i] + vf, 'D');
        excel.setReal(l[i] + vf, l[i] + vf, imp, 'Arial, normal, 9');
      end;
      j    := j + 7;
      per  := utiles.SumarPeriodo(per, '1');
    end;
    if (salida = 'I') or (salida = 'P') then
      list.Linea(j, list.Lineactual, '', i+1, 'Arial, normal, 8', salida, 'S');

    q.Next;
  end;
  q.Close; q.Free;
  facturacion.DesConectarTotalesProf;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'X' then Begin
    excel.setString('a1', 'a1', '', 'Arial, negrita, 9');
    excel.Visulizar;
  end;
end;

procedure TTestadisticaCCBCCB.InfRecuentoPorPractica(xperiodo: String; xcodigos: TStringList; salida: char);
// Objetivo...: Listar Totales Facturados por pr�ctica
var
  i: Integer;
  des: String;
Begin
  inherited Titulos('Cantidad de Pr�cticas Facturadas en el Per�odo - ' + xperiodo, salida);
  list.Titulo(0, 0, 'C�digo Determinaci�n', 1, 'Arial, cursiva, 8');
  list.Titulo(87, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');

  facturacion.conectar;
  facturacion.ProcesarDatosCentrales(xperiodo);

  q := facturacion.setPracticasFacturadas;
  q.Open; total := 0;
  For i := 1 to xcodigos.Count do Begin
    datosdb.Filtrar(q, 'codanalisis = ' + '''' + xcodigos.Strings[i-1] + '''');
    if q.RecordCount > 0 then Begin
      obsocial.getDatos(q.FieldByName('codos').AsString);
      if obsocial.Factnbu = 'S' then Begin
        nbu.getDatos(xcodigos.Strings[i-1]);
        des := nbu.Descrip;
      end;
      if obsocial.Factnbu = 'N' then Begin
        nomeclatura.getDatos(xcodigos.Strings[i-1]);
        des := nomeclatura.Descrip;
      end;
      list.Linea(0, 0, xcodigos.Strings[i-1] + '  ' + des, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(93, list.Lineactual, '######', StrToFloat(IntToStr(q.RecordCount)), 2, 'Arial, normal, 8');
      list.Linea(94, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      total := total + StrToFloat(IntToStr(q.RecordCount));
    end;
    datosdb.QuitarFiltroSQL(q);
  end;

  facturacion.desconectar;

  if total > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(0, 0, 'Cantidad de Pr�cticas Realizadas:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(93, list.Lineactual, '######', total, 2, 'Arial, negrita, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTestadisticaCCBCCB.ListarResumenIAPOS(xperiodo, xcodos: string; salida: char);
var
  r: TQuery;
  t1, t2, t3, t4, t5: real;
  i, p, j: integer;
  objeto: TTDebitosCreditosIapos;
  l: TObjectList;
  s, t, obs: TStringList;
begin
  inherited Titulos('Detalle de Operaciones', salida);
  list.Titulo(0, 0, '', 1, 'Arial, cursiva, 5');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');

  list.Linea(0, 0, 'Resumen Obra Social', 1, 'Arial, negrita, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '      Obra Social', 1, 'Arial, cursiva, 8', salida, 'N');
  list.Linea(64, list.Lineactual, 'Total UB', 2, 'Arial, cursiva, 8', salida, 'N');
  list.Linea(90, list.Lineactual, 'Monto', 3, 'Arial, cursiva, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  obs := TStringList.Create;

  ConectarDebitosProfesionales(xperiodo);
  r := estadisticaCCB.getTotalesInicidenciaPorDeterminacion_Detallada(xperiodo);
  r.Open; t1 := 0; t2 := 0; t3 := 0;
  while not r.Eof do begin
    obsocial.getDatos(r.FieldByName('codos').AsString);
    list.Linea(0, 0, '    ' + obsocial.nombre, 1, 'Arial, normal, 9', salida, 'N');
    list.importe(70, list.Lineactual, '', r.FieldByName('total1').AsFloat, 2, 'Arial, normal, 9');
    list.importe(95, list.Lineactual, '', r.FieldByName('total2').AsFloat, 3, 'Arial, normal, 9');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
    t1 := t1 + r.FieldByName('total1').AsFloat;
    t2 := t2 + r.FieldByName('total2').AsFloat;
    obs.Add(r.FieldByName('codos').AsString);
    r.Next;
  end;
  r.Close; r.Free;

  if (t1 + t2 <> 0) then begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(60, list.Lineactual, '--------------------------------------------------------------', 2, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, '    Subtotal:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(70, list.Lineactual, '', t1, 2, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', t2, 3, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
  end;

  list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, 'D�bitos y Cr�ditos', 1, 'Arial, negrita, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  dc := TTDebitosCreditosIapos.Create;
  dc.conectar(xperiodo);

  l := dc.getObjects;
  for i := 1 to l.Count do begin
    objeto := TTDebitosCreditosIapos(l.Items[i-1]);
    list.Linea(0, 0, '      ' + objeto.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(15, list.Lineactual, objeto.Concepto , 2, 'Arial, normal, 8', salida, 'N');
    if (objeto.Tipomov = '1') then
      list.importe(70, list.Lineactual, '', objeto.Monto, 3, 'Arial, normal, 8')
    else
      list.importe(95, list.Lineactual, '', objeto.Monto, 3, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
  end;
  l.Free; l := nil;

  dc.desconectar; dc.Free;

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 16', salida, 'S');
  list.Linea(0, 0, '      Profesional', 1, 'Arial, cursiva, 8', salida, 'N');
  list.Linea(41, list.Lineactual, 'Monto Fact.', 2, 'Arial, cursiva, 8', salida, 'N');
  list.Linea(55, list.Lineactual, 'Monto Pagado', 3, 'Arial, cursiva, 8', salida, 'N');
  list.Linea(67, list.Lineactual, 'F. Pago', 4, 'Arial, cursiva, 8', salida, 'N');
  list.Linea(85, list.Lineactual, 'Debitos', 5, 'Arial, cursiva, 8', salida, 'N');
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');

  for j  := 1 to obs.Count do begin

  t1 := 0; t3 := 0; t4 := 0; t5 := 0;

  obsocial.getDatos(obs.Strings[j-1]);
  list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, 'Montos Liquidados a Prestadores - ' + obsocial.Nombre, 1, 'Arial, negrita, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  t := TStringList.Create;
  t.Add(obs.Strings[j-1]);
  s := facturacion.setTotalProfesionalesLiquidacion(xperiodo, t, False);
  For i := 1 to s.Count do Begin
    profesional.getDatos(Copy(s.Strings[i-1], 1, 6));
    getDatos(obsocial.codos, xperiodo, profesional.codigo);
    p := Pos(';1', s.Strings[i-1]);
    list.Linea(0, 0, '      ' + profesional.nombre, 1, 'Arial, normal, 8', salida, 'N');

    // 29-05-2017
    t5 := strtofloat(Copy(s.Strings[i-1], p+2, 10));
    if (Totalprof > 0) then t5 := Totalprof;    

    //list.importe(50, list.Lineactual, '', strtofloat(Copy(s.Strings[i-1], p+2, 10)), 2, 'Arial, normal, 8');
    list.importe(50, list.Lineactual, '', t5, 2, 'Arial, normal, 8');
    list.importe(65, list.Lineactual, '', pago, 3, 'Arial, normal, 8');
    list.Linea(67, list.Lineactual, fepago, 4, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', debito, 5, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
    t1 := t1 + t5; //strtofloat(Copy(s.Strings[i-1], p+2, 10));
    t3 := t3 + pago;
    t4 := t4 + debito;
  end;
  s.Free; s := nil;

  if (t1 <> 0) then begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(40, list.Lineactual, '----------------------------------------------------------------------------------------------', 2, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, '    Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(50, list.Lineactual, '', t1, 2, 'Arial, negrita, 9');
    list.importe(65, list.Lineactual, '', t3, 3, 'Arial, negrita, 9');
    list.importe(90, list.Lineactual, '', t4, 4, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 9', salida, 'S');
  end;

  end;

  obs.Free; obs := Nil;

  list.FinList;
end;

{-------------------------------------------------------------------------------}
procedure TTestadisticaCCBCCB.Titulo1;
Begin
  list.LineaTxt(CHR(18) + '  ', true);
  list.LineaTxt('Cod.       Obra Social                     Valores Facturados       Porcentaje', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := lineas + 3;
end;

procedure TTestadisticaCCBCCB.Titulo2;
Begin
  inherited Titulos('Porcentaje de Incidencia Determinacion', 'T');
  list.LineaTxt('Cod.  Determinacion                                Incidencia %     Incidencia', True);
  list.LineaTxt('                                                    en Cantidad         % en $', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := lineas + 3;
end;

procedure TTestadisticaCCBCCB.Titulo3(xcodos: String);
Begin
  list.LineaTxt(CHR(18) + '  ', true);
  inherited Titulos('Porcentaje de Incidencia por Profesional', 'T');
  if Length(Trim(xcodos)) > 0 then Begin
    list.LineaTxt('Obra Social: ' + Copy(obsocial.Nombre, 1, 30), True);
    list.LineaTxt(' ', True);
    lineas := lineas + 2;
  end;
  list.LineaTxt('Id.      Profesional                                                 Porcentaje', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := lineas + 2;
end;

procedure TTestadisticaCCBCCB.Titulo4;
Begin
  list.LineaTxt(CHR(18) + '  ', true);
  inherited Titulos('Incidencia de Codigos Facturados en Valores', 'T');
  list.LineaTxt('Obra Social: ' + Copy(obsocial.Nombre, 1, 30), True);
  list.LineaTxt(' ', True);
  list.LineaTxt('Codigo    Determinacion                                Cantidad     Importe', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := lineas + 4;
end;

procedure TTestadisticaCCBCCB.Titulo5;
Begin
  inherited Titulos('Porcentaje de Incidencia Determinacion', 'T');
  list.LineaTxt('Codigo          Cantidad     Gastos Honorarios Comp.Arnan.         Total', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := lineas + 3;
end;

procedure TTestadisticaCCBCCB.Titulo6;
Begin
  inherited Titulos('Informe de Practicas Realizadas', 'T');
  list.LineaTxt('Cod. Determinacion               Cantidad    Gastos    Honor.  C.Aran.     Total', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := lineas + 3;
end;

procedure TTestadisticaCCBCCB.Titulo7;
Begin
  inherited Titulos('Practicas Facturadas por Profesional', 'T');
  list.LineaTxt('Codigo Determinacion                              Cantidad', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := lineas + 3;
end;

procedure TTestadisticaCCBCCB.IniciarArreglos;
var
  i: Integer;
Begin
  for i := 1 to cantitems do Begin
    totalfinal[i] := 0; tot9984[i] := 0; cantdet[i] := 0; totnbu[i] := 0;
  end;
end;

procedure TTestadisticaCCBCCB.ConectarDebitosProfesionales(xperiodo: string);
var
  per: string;
begin
  {per := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  if not (DirectoryExists(dbs.DirSistema + '\estadisticas')) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\estadisticas');
  if not (DirectoryExists(dbs.DirSistema + '\estadisticas\' + per)) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\estadisticas\' + per);
  if not (FileExists(dbs.DirSistema + '\estadisticas\' + per + '\movprof.db')) then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\estadisticas', 'movprof.*', dbs.DirSistema + '\estadisticas\' + per);}
  debitos := datosdb.openDB('movprof', '', '', facturacion.getDBConexion);
  debitos.Open;
end;

procedure TTestadisticaCCBCCB.AjustarDebito(xcodos, xperiodo, xidprof: string; xdebito, xpago, xtotalprof: real);
begin
  if (datosdb.Buscar(debitos, 'codos', 'periodo', 'idprof', xcodos, xperiodo, xidprof)) then debitos.Edit else debitos.Append;
  debitos.FieldByName('codos').AsString    := xcodos;
  debitos.FieldByName('periodo').AsString  := xperiodo;
  debitos.FieldByName('idprof').AsString   := xidprof;
  debitos.FieldByName('debito').AsFloat    := xdebito;
  debitos.FieldByName('pago').AsFloat      := xpago;
  if (xtotalprof > 0) then debitos.FieldByName('totalprof').AsFloat := xtotalprof;
  try
    debitos.Post
   except
    debitos.Cancel
  end;
  datosdb.refrescar(debitos);
end;

procedure TTestadisticaCCBCCB.AjustarFecha(xcodos, xperiodo, xidprof, xfecha: string);
begin
  if (datosdb.Buscar(debitos, 'codos', 'periodo', 'idprof', xcodos, xperiodo, xidprof)) then debitos.Edit else debitos.Append;
  debitos.FieldByName('codos').AsString   := xcodos;
  debitos.FieldByName('periodo').AsString := xperiodo;
  debitos.FieldByName('idprof').AsString  := xidprof;
  debitos.FieldByName('fepago').AsString  := xfecha;
  try
    debitos.Post
   except
    debitos.Cancel
  end;
  datosdb.refrescar(debitos);
end;

procedure TTestadisticaCCBCCB.AjustarPago(xcodos, xperiodo, xidprof: string; xmonto: real);
begin
  if (datosdb.Buscar(debitos, 'codos', 'periodo', 'idprof', xcodos, xperiodo, xidprof)) then debitos.Edit else debitos.Append;
  debitos.FieldByName('codos').AsString   := xcodos;
  debitos.FieldByName('periodo').AsString := xperiodo;
  debitos.FieldByName('idprof').AsString  := xidprof;
  debitos.FieldByName('pago').AsFloat     := xmonto;
  try
    debitos.Post
   except
    debitos.Cancel
  end;
  datosdb.refrescar(debitos);
end;

procedure TTestadisticaCCBCCB.getDatos(xcodos, xperiodo, xidprof: string);
begin
  if (datosdb.Buscar(debitos, 'codos', 'periodo', 'idprof', xcodos, xperiodo, xidprof)) then begin
    fepago    := debitos.FieldByName('fepago').AsString;
    debito    := debitos.FieldByName('debito').AsFloat;
    pago      := debitos.FieldByName('pago').AsFloat;
    totalprof := debitos.FieldByName('totalprof').AsFloat;
  end else begin
    fepago := '';
    debito := 0;
    totalprof := 0;
    pago   := -100000;
  end;
end;

procedure TTestadisticaCCBCCB.DesconectarDebitosProfesionales;
begin
  datosdb.closeDB(debitos); 
end;

{===============================================================================}

function estadisticaCCB: TTestadisticaCCBCCB;
begin
  if xestadisticaCCB = nil then
    xestadisticaCCB := TTestadisticaCCBCCB.Create;
  Result := xestadisticaCCB;
end;

{===============================================================================}

initialization

finalization
  xestadisticaCCB.Free;

end.
