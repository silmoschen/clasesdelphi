unit CLPrecio;

interface

uses CArtSim, CVias, SysUtils, DB, DBTables, CListar, Listado, CUtiles, CIDBFM, Classes, CBDT, Forms;

type

TTListaPrecios = class(TObject)
  codart, descrip: string;
  precio1, precio2, precio3, precio4, precio5, precio6, precio7: real;                   // Atributos de Precios
  codrubro, codmarca, medida, cpuni: string;
  Llista, Lestado, Lprecio1, Lprecio2, Lprecio3, Lprecio4, Lprecio5, Lprecio6, Lprecio7: string;  // Atributos manejadores de lista
  Linteres, Lintplista: real;
  ModeloEt, FuenteEt, CantPagEt, CantAlto, MargenSup, Separacion: String;                // Etiquetas Articulos
  Etiqueta1, Etiqueta2, Etiqueta3: Integer;
  tabla, ref1, ref11, et, preciosEt: TTable;                                                        // Tablas de persistencia
  r, t: TQuery;                                                                          // Queryes
  etpag: array[1..3, 1..3] of String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodart, xdescrip: string; xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: real);
  procedure   CambiarDescrip(xcodart, xdescrip: String);
  procedure   Borrar(xcodart: string);
  function    Buscar(xcodart: string): boolean;

  procedure   getDatos(xcodart: string);
  procedure   prepararActualizacion(xnroprecio: integer; xactualizaSN, xvariacion, xproporcion: string);
  procedure   ActPrecios;
  procedure   FiltrarRubro(xcodrubro: string);
  procedure   FiltrarMarca(xcodmarca: string);
  procedure   DesactivarFiltro;

  { Métodos para el mantenimiento de Referencias a Listas de Precios }
  procedure   GrabarRL(xlista, xestado: string);
  procedure   BorrarRL(xlista: string);
  function    BuscarRL(xlista: string): boolean;
  procedure   getDatosRL(xlista: string);
  function    setListasRL: TQuery;
  procedure   BajaListaRL(arch: string);
  function    VerificarListaRL(xlista: string): string;
  function    FormarNombreListaRL(s: string): string;
  function    CopiarListaRL(xlistaOriginal, xlistaNueva: string): string;
  procedure   FijarIdNombrePreciosRL(xlista, xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: string);
  procedure   FijarInteresRL(xlista: string; xinteres1: real);
  procedure   FijarIntplistaRL(xlista: string; xintplista: real);
  function    ActivarListaRL(lista: string): string;
  { Fin }

  function    setNominaArticulos: TQuery;
  function    setNominaArticulosAlf: TQuery;
  procedure   ListarEtiquetas(xlista: TStringList; xfilaini, xcolini: Integer; salida: char);
  procedure   GuardarModeloEtiquetas(xid, xmodelo, xfuente: String; xcant_pag, xcant_alto, xmargen_sup, xseparacion, xetiqueta1, xetiqueta2, xetiqueta3: Integer);
  procedure   getModeloEtiquetas(xid: String);

  procedure   BuscarPorCodigo(xexpresion: String);
  procedure   BuscarPorDescrip(xexpresion: String);

  procedure   SeleccionarImpresora(ximpresora: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: ShortInt;
  parametrosact: array[1..7, 1..3] of string;
  idanter: string; listNivel: boolean; filtro: byte;
  procedure   List_lineaRubro(salida: char);
  procedure   List_lineaMarca(salida: char);
  procedure   ListarEtiqueta(salida: char);
 protected
  { Declaraciones Protegidas }
  procedure   Titulos(salida: char; lp, tit: string); virtual;
  procedure   Listar_r(orden, iniciar, finalizar, ent_excl: string; salida: char; lp, tit: string);
  procedure   Listar_m(orden, iniciar, finalizar, ent_excl: string; salida: char; lp, tit: string);
  procedure   List_linea(salida: char); virtual;
end;

function precios: TTListaPrecios;

implementation

var
  xprecios: TTListaPrecios = nil;

constructor TTListaPrecios.Create;
begin
  inherited Create;
  et := datosdb.openDB('modeloEtiquetas', '');
end;

destructor TTListaPrecios.Destroy;
begin
  inherited Destroy;
end;

procedure TTListaPrecios.Grabar(xcodart, xdescrip: string; xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodart) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codart').AsString  := xcodart;
  tabla.FieldByName('descrip').AsString := xdescrip;
  tabla.FieldByName('precio1').asFloat  := xprecio1;
  tabla.FieldByName('precio2').asFloat  := xprecio2;
  tabla.FieldByName('precio3').asFloat  := xprecio3;
  tabla.FieldByName('precio4').asFloat  := xprecio4;
  tabla.FieldByName('precio5').asFloat  := xprecio5;
  tabla.FieldByName('precio6').asFloat  := xprecio6;
  tabla.FieldByName('precio7').asFloat  := xprecio7;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTListaPrecios.CambiarDescrip(xcodart, xdescrip: String);
// Objetivo...: Cambiar la leyenda del articulo
Begin
  if Buscar(xcodart) then Begin
    tabla.Edit;
    tabla.FieldByName('descrip').AsString := xdescrip;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTListaPrecios.Borrar(xcodart: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodart) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codart').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end
end;

function TTListaPrecios.Buscar(xcodart: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
var
  i: String;
begin
  if not tabla.Active then conectar;
  i := tabla.IndexFieldNames;
  if tabla.IndexFieldNames <> 'Codart' then tabla.IndexFieldNames := 'Codart';
  if tabla.FindKey([xcodart]) then Result := True else Result := False;
  tabla.IndexFieldNames := i;
end;

procedure  TTListaPrecios.getDatos(xcodart: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodart) then
    begin
      codart  := tabla.FieldByName('codart').AsString;
      descrip := tabla.FieldByName('descrip').AsString;
      precio1 := tabla.FieldByName('precio1').AsFloat;
      precio2 := tabla.FieldByName('precio2').AsFloat;
      precio3 := tabla.FieldByName('precio3').AsFloat;
      precio4 := tabla.FieldByName('precio4').AsFloat;
      precio5 := tabla.FieldByName('precio5').AsFloat;
      precio6 := tabla.FieldByName('precio6').AsFloat;
      precio7 := tabla.FieldByName('precio7').AsFloat;
    end
   else
    begin
      codart := ''; descrip := ''; precio1 := 0; precio2 := 0; precio3 := 0; precio4 := 0; precio5 := 0; precio6 := 0; precio7 := 0;
    end;

  art.getDatos(xcodart);      // Recuperamos los Atributos del artículo
  codrubro := art.Desrubro;
  codmarca := art.DesMarca;
  medida   := art.DesMedida;
  cpuni    := art.Cant_bulto;
end;

//------------------------------------------------------------------------------

procedure TTListaPrecios.FiltrarRubro(xcodrubro: string);
begin
  filtro  := 1;
  idanter := xcodrubro;
end;

procedure TTListaPrecios.FiltrarMarca(xcodmarca: string);
begin
  filtro  := 2;
  idanter := xcodmarca;
end;

procedure TTListaPrecios.DesactivarFiltro;
begin
  filtro  := 0;
end;

procedure TTListaPrecios.prepararActualizacion(xnroprecio: integer; xactualizaSN, xvariacion, xproporcion: string);
// Objetivo...: Prepara la actualización de las listas de precios
begin
  parametrosact[xnroprecio, 1] := xactualizaSN;
  parametrosact[xnroprecio, 2] := xvariacion;
  parametrosact[xnroprecio, 3] := xproporcion;
end;

procedure TTListaPrecios.ActPrecios;
// Objetivo...: Actualizar una Lista de Precios
var
  importe, variacion: array[1..7] of real;
  actualizar: boolean;
begin
  tabla.First;
  while not tabla.EOF do
    begin
      importe[1]   := tabla.FieldByName('precio1').AsFloat;
      importe[2]   := tabla.FieldByName('precio2').AsFloat;
      importe[3]   := tabla.FieldByName('precio3').AsFloat;
      importe[4]   := tabla.FieldByName('precio4').AsFloat;
      importe[5]   := tabla.FieldByName('precio5').AsFloat;
      importe[6]   := tabla.FieldByName('precio6').AsFloat;
      importe[7]   := tabla.FieldByName('precio7').AsFloat;

      if parametrosact[1, 1] = 'S' then variacion[1] := (importe[1] * StrToFloat(parametrosact[1, 3])) / 100;
      if parametrosact[2, 1] = 'S' then variacion[2] := (importe[2] * StrToFloat(parametrosact[2, 3])) / 100;
      if parametrosact[3, 1] = 'S' then variacion[3] := (importe[3] * StrToFloat(parametrosact[3, 3])) / 100;
      if parametrosact[4, 1] = 'S' then variacion[4] := (importe[4] * StrToFloat(parametrosact[4, 3])) / 100;
      if parametrosact[5, 1] = 'S' then variacion[5] := (importe[5] * StrToFloat(parametrosact[5, 3])) / 100;
      if parametrosact[6, 1] = 'S' then variacion[6] := (importe[6] * StrToFloat(parametrosact[6, 3])) / 100;
      if parametrosact[7, 1] = 'S' then variacion[7] := (importe[7] * StrToFloat(parametrosact[7, 3])) / 100;

      if parametrosact[1, 1] = 'S' then if parametrosact[1, 2] = '+' then importe[1] := importe[1] + variacion[1] else importe[1] := importe[1] - variacion[1];
      if parametrosact[2, 1] = 'S' then if parametrosact[2, 2] = '+' then importe[2] := importe[2] + variacion[2] else importe[2] := importe[2] - variacion[2];
      if parametrosact[3, 1] = 'S' then if parametrosact[3, 2] = '+' then importe[3] := importe[3] + variacion[3] else importe[3] := importe[3] - variacion[3];
      if parametrosact[4, 1] = 'S' then if parametrosact[4, 2] = '+' then importe[4] := importe[4] + variacion[4] else importe[4] := importe[4] - variacion[4];
      if parametrosact[5, 1] = 'S' then if parametrosact[5, 2] = '+' then importe[5] := importe[5] + variacion[5] else importe[5] := importe[5] - variacion[5];
      if parametrosact[6, 1] = 'S' then if parametrosact[6, 2] = '+' then importe[6] := importe[6] + variacion[6] else importe[6] := importe[6] - variacion[6];
      if parametrosact[7, 1] = 'S' then if parametrosact[7, 2] = '+' then importe[7] := importe[7] + variacion[7] else importe[7] := importe[7] - variacion[7];

      actualizar := False;
      if filtro = 0 then actualizar := True;  // Filtros
      if filtro = 1 then Begin
        art.getDatos(tabla.FieldByName('codart').AsString);
        if art.codrubro = idanter then actualizar := True else actualizar := False;
      end;
      if filtro = 2 then Begin
        art.getDatos(tabla.FieldByName('codart').AsString);
        if art.codmarca = idanter then actualizar := True else actualizar := False;
      end;

      if actualizar then Begin
        tabla.Edit;
        tabla.FieldByName('precio1').AsFloat := importe[1];
        tabla.FieldByName('precio2').AsFloat := importe[2];
        tabla.FieldByName('precio3').AsFloat := importe[3];
        tabla.FieldByName('precio4').AsFloat := importe[4];
        tabla.FieldByName('precio5').AsFloat := importe[5];
        tabla.FieldByName('precio6').AsFloat := importe[6];
        tabla.FieldByName('precio7').AsFloat := importe[7];
        tabla.Post;
      end;
      tabla.Next;
    end;
    datosdb.refrescar(tabla);
end;

procedure TTListaPrecios.Titulos(salida: char; lp, tit: string);
// Objetivo...: Listar Línea de Datos
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, tit, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código', 1, 'Arial, cursiva, 8');
  List.Titulo(18, List.lineactual, 'Descripción', 2, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, LPrecio2, 3, 'Arial, cursiva, 8');
  List.Titulo(53, List.lineactual, LPrecio1, 4, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, LPrecio3, 5, 'Arial, cursiva, 8');
  List.Titulo(69, List.lineactual, LPrecio4, 6, 'Arial, cursiva, 8');
  List.Titulo(77, List.lineactual, LPrecio5, 7, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, LPrecio6, 8, 'Arial, cursiva, 8');
  List.Titulo(94, List.lineactual, LPrecio7, 9, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTListaPrecios.Listar_r(orden, iniciar, finalizar, ent_excl: string; salida: char; lp, tit: string);
// Objetivo...: Listar Articulos con Nivel de Ruptura por Rubro
begin
  if orden = 'C' then t := art.setRubros else t := art.setRubrosAlf;
  Titulos(salida, lp, tit);

  r.Open;
  t.Open; t.First;
  while not t.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (t.FieldByName('codrubro').AsString >= iniciar) and (t.FieldByName('codrubro').AsString <= finalizar) then List_lineaRubro(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (t.FieldByName('codrubro').AsString < iniciar) or (t.FieldByName('codrubro').AsString > finalizar) then List_lineaRubro(salida);
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'A') then
        if (t.FieldByName('descrip').AsString >= iniciar) and (t.FieldByName('descrip').AsString <= finalizar) then List_lineaRubro(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (t.FieldByName('descrip').AsString < iniciar) or (t.FieldByName('descrip').AsString > finalizar) then List_lineaRubro(salida);

      t.Next;
    end;

  r.Close; t.Close;
  List.FinList;
end;

procedure TTListaPrecios.Listar_m(orden, iniciar, finalizar, ent_excl: string; salida: char; lp, tit: string);
// Objetivo...: Listar Articulos con Nivel de Ruptura por Marca
begin
  if orden = 'C' then t := art.setMarcas else t := art.setMarcasAlf;
  Titulos(salida, lp, tit);

  r.Open;
  t.Open; t.First;
  while not t.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (t.FieldByName('codmarca').AsString >= iniciar) and (t.FieldByName('codmarca').AsString <= finalizar) then List_lineaMarca(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (t.FieldByName('codmarca').AsString < iniciar) or (t.FieldByName('codmarca').AsString > finalizar) then List_lineaMarca(salida);
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'A') then
        if (t.FieldByName('descrip').AsString >= iniciar) and (t.FieldByName('descrip').AsString <= finalizar) then List_lineaMarca(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (t.FieldByName('descrip').AsString < iniciar) or (t.FieldByName('descrip').AsString > finalizar) then List_lineaMarca(salida);

      t.Next;
    end;

  r.Close; t.Close;
  List.FinList;
end;

procedure TTListaPrecios.List_lineaRubro(salida: char);
// Objetivo...: Listar una linea de articulos
begin
  listNivel := False;

  r.First;
  while not r.EOF do  // Aislamos los movimientos del rubro que correspondan
    begin
      if r.FieldByName('codrubro').AsString = t.FieldByName('codrubro').AsString then Begin
        if not listNivel then Begin    // Nivel de ruptura
          art.getDatosRubro(t.FieldByName('codrubro').AsString);
          List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
          List.Linea(0, 0, art.Desrubro, 1, 'Arial, negrita, 12', salida, 'N');
          List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
          listNivel := True;
        end;

        if r.FieldByName('codmarca').AsString <> idanter then List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        List_linea(salida);
        idanter := r.FieldByName('codmarca').AsString;
      end;
      r.Next;
    end;
end;

procedure TTListaPrecios.List_lineaMarca(salida: char);
// Objetivo...: Listar una linea de articulos
begin
  listNivel := False;

  r.First;
  while not r.EOF do  // Aislamos los movimientos del rubro que correspondan
    begin
      if r.FieldByName('codmarca').AsString = t.FieldByName('codmarca').AsString then Begin
        if not listNivel then Begin    // Nivel de ruptura
          art.getDatosMarca(t.FieldByName('codmarca').AsString);
          List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
          List.Linea(0, 0, art.desmarca, 1, 'Arial, negrita, 12', salida, 'N');
          List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
          listNivel := True;
        end;

        List_linea(salida);
      end;
      r.Next;
    end;
end;

procedure TTListaPrecios.List_linea(salida: char);
// Objetivo...: Listar una linea de articulos
begin
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.importe(8, List.lineactual, '#############', r.FieldByName('codart').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(9, list.Lineactual, r.FieldByName('articulo').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.importe(50, List.lineactual, '', r.FieldByName('precio2').AsFloat, 4, 'Arial, normal, 8');
  List.importe(58, List.lineactual, '', r.FieldByName('precio1').AsFloat, 5, 'Arial, normal, 8');
  List.importe(66, List.lineactual, '', r.FieldByName('precio3').AsFloat, 6, 'Arial, normal, 8');
  List.importe(74, List.lineactual, '', r.FieldByName('precio4').AsFloat, 7, 'Arial, normal, 8');
  List.importe(83, List.lineactual, '', r.FieldByName('precio5').AsFloat, 8, 'Arial, normal, 8');
  List.importe(91, List.lineactual, '', r.FieldByName('precio6').AsFloat, 9, 'Arial, normal, 8');
  List.importe(99, List.lineactual, '', r.FieldByName('precio7').AsFloat, 10, 'Arial, normal, 8');
  List.Linea(99,   List.lineactual, '', 11, 'Arial, normal, 8', salida, 'S');
end;

{*******************************************************************************}
function TTListaPrecios.setListasRL: TQuery;
// Objetivo....: Retornar un recordSet con las Listas Definidas
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + ref1.TableName);
end;

procedure TTListaPrecios.GrabarRL(xlista, xestado: string);
// Objetivo...: Grabar Atributos del Objeto
var
  g: boolean;
begin
  g := False;
  if BuscarRL(xlista) then ref1.Edit else
    begin
      g := True;
      ref1.Append;
    end;
  ref1.FieldByName('lista').AsString  := xlista;
  ref1.FieldByName('estado').AsString := xestado;
  try
    ref1.Post;
  except
    ref1.Cancel;
  end;
  if g then FijarIdNombrePreciosRL(xlista, 'Precio1', 'Precio2', 'Precio3', 'Precio4', 'Precio5', 'Precio6', 'Precio7');  // Fijamos el precio inicial
  datosdb.refrescar(ref1);
end;

procedure TTListaPrecios.BorrarRL(xlista: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarRL(xlista) then
    begin
      ref1.Delete;
      getDatosRL(ref1.FieldByName('lista').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTListaPrecios.BuscarRL(xlista: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if ref1.FindKey([xlista]) then Result := True else Result := False;
end;

procedure  TTListaPrecios.getDatosRL(xlista: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarRL(xlista) then Begin
    Llista     := ref1.FieldByName('lista').AsString;
    Lestado    := ref1.FieldByName('estado').AsString;
    Lprecio1   := ref1.FieldByName('precio1').AsString;
    Lprecio2   := ref1.FieldByName('precio2').AsString;
    Lprecio3   := ref1.FieldByName('precio3').AsString;
    Lprecio4   := ref1.FieldByName('precio4').AsString;
    Lprecio5   := ref1.FieldByName('precio5').AsString;
    Lprecio6   := ref1.FieldByName('precio6').AsString;
    Lprecio7   := ref1.FieldByName('precio7').AsString;
    Linteres   := ref1.FieldByName('interes').AsFloat;
    LintPlista := ref1.FieldByName('intplista').AsFloat;
  end else begin
    Llista := ''; Lestado := ''; Lprecio1 := ''; Lprecio2 := ''; Lprecio3 := ''; Lprecio4 := ''; Lprecio5 := ''; Lprecio6 := ''; Lprecio7 := ''; Linteres := 0; Lintplista := 0;
  end;
end;

procedure TTListaPrecios.BajaListaRL(arch: string);
//Objetivo...: Baja de Listas de Precios, id y ref1 asociada
var
  v, l, t: string;
begin
  v := via.getVia1;      // Path de ref1s
  l := arch;
  arch := FormarNombreListaRL(arch);
  if FileExists(v + '\arch\' + arch + '.*') then
    begin
      datosdb.closeDB(tabla);
      t    := arch;
      arch := arch + '.db';
      datosdb.tranSQL('DROP INDEX ' + '''' + t + '''' + '.descrip');
      datosdb.tranSQL('DROP INDEX ' + '''' + t + '''' + '.PRIMARY');
      datosdb.tranSQL('DROP TABLE ' + '''' + arch + '''');
    end;
  BorrarRL(l);
end;

function TTListaPrecios.VerificarListaRL(xlista: string): string;
var
  v, l, Lista: string;
begin
  v := via.getVia1;      // Path de ref1s
  l := xlista;
  Lista := FormarNombreListaRL(l);
  if not FileExists(v + '\arch\' + Lista + '.*') then
     begin
       ref11.Close;
       // TRANSAC SQL CREATE TABLE precios(codart char(20), precio float, PRIMARY KEY(codart))
       datosdb.tranSQL('CREATE TABLE ' + lista + '(codart CHAR(20), descrip CHAR(30), precio1 FLOAT, precio2 FLOAT, precio3 FLOAT, precio4 FLOAT, precio5 FLOAT, precio6 FLOAT, precio7 FLOAT, sel CHAR(1), PRIMARY KEY(codart))');
       datosdb.tranSQL('CREATE INDEX descrip ON ' + lista + ' (descrip)');
     end;

  GrabarRL(l, '');
  Result := l;
end;

function TTListaPrecios.FormarNombreListaRL(s: string): string;
// Objetivo...: Formar un Nombre de Archivo
var
  n: string;
  i: integer;
begin
  For i := 1 to Length(s) do
     if Length(trim(Copy(s, i, 1))) > 0 then n := n + Copy(s, i, 1) else n := n + '_';
  Result := n;
end;

function TTListaPrecios.CopiarListaRL(xlistaOriginal, xlistaNueva: string): string;
// Objetivo...: Duplicar Listas
var
  linu, lior, v: string;
  r: TQuery;
begin
  linu := FormarNombreListaRL(xlistaNueva);
  lior := FormarNombreListaRL(xlistaOriginal);

  v := via.getVia1;      // Path de ref1s
  if FileExists(v + '\arch\' + linu + '.*') then
   begin
      datosdb.closeDB(tabla);
      datosdb.tranSQL('DROP INDEX ' + '''' + linu + '''' + '.descrip');
      datosdb.tranSQL('DROP INDEX ' + '''' + linu + '''' + '.PRIMARY');
      datosdb.tranSQL('DROP TABLE ' + '''' + linu + '''');
      BorrarRL(linu);
    end;

  datosdb.tranSQL('CREATE TABLE ' + linu + '(codart CHAR(20), descrip CHAR(30), precio1 FLOAT, precio2 FLOAT, precio3 FLOAT, precio4 FLOAT, precio5 FLOAT, precio6 FLOAT, precio7 FLOAT, sel CHAR(1), PRIMARY KEY(codart)) ');
  datosdb.tranSQL('CREATE INDEX descrip ON ' + linu + ' (descrip)');
  // hacemos el volcado de registros

  r := datosdb.tranSQL('SELECT * FROM ' + lior);
  r.Open; r.First;
  while not r.EOF do
    begin
      datosdb.tranSQL('INSERT INTO ' + linu + '(codart, descrip, precio1, precio2, precio3, precio4, precio5, precio6, precio7) VALUES ' + '(' +
         '''' + r.FieldByName('codart').AsString + '''' + ',' + '''' + r.FieldByName('descrip').AsString + '''' + ',' + r.FieldByName('precio1').AsString + ',' +  r.FieldByName('precio2').AsString + ',' +
         r.FieldByName('precio3').AsString + ',' + r.FieldByName('precio4').AsString + ',' + r.FieldByName('precio5').AsString + ',' + r.FieldByName('precio6').AsString + ',' + r.FieldByName('precio7').AsString + ')');
      r.Next;
    end;
  r.Close; r.Free;

  GrabarRL(xListaNueva, '');
end;

procedure TTListaPrecios.FijarIdNombrePreciosRL(xlista, xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: string);
// Objetivo...: Fijar Nombre cabacera para las listas de precios
begin
  if BuscarRL(xlista) then
    begin
      ref1.Edit;
      ref1.FieldByName('precio1').AsString := xprecio1;
      ref1.FieldByName('precio2').AsString := xprecio2;
      ref1.FieldByName('precio3').AsString := xprecio3;
      ref1.FieldByName('precio4').AsString := xprecio4;
      ref1.FieldByName('precio5').AsString := xprecio5;
      ref1.FieldByName('precio6').AsString := xprecio6;
      ref1.FieldByName('precio7').AsString := xprecio7;
      try
        ref1.Post;
      except
        ref1.Cancel;
      end;
    end;
    datosdb.refrescar(ref1);
end;

function TTListaPrecios.ActivarListaRL(lista: string): string;
//Objetivo...: Activar la ref1 que corresponda a la Lista Seleccionada
var
  l: string;
begin
  if ref1.FindKey([lista]) then
   if Pos('redeterminada', lista) = 0 then
    begin
      ref11.Close;
      l := FormarNombreListaRL(lista) + '.DB';
      ref11.Open;
    end
  else
    begin
      ref11.Close;
      l := 'precios.DB';   // Lista por omisión
      ref11.Open;
    end;
  Result := l;
end;

procedure TTListaPrecios.FijarInteresRL(xlista: string; xinteres1: real);
// Objetivo...: Fijar/Variar el porcentaje de interes
begin
  if BuscarRL(xlista) then
    begin
      ref1.Edit;
      ref1.FieldByName('interes').AsFloat := xinteres1;
      try
        ref1.Post;
      except
        ref1.Cancel;
      end;
    end;
    datosdb.refrescar(ref1);
end;

procedure TTListaPrecios.FijarIntplistaRL(xlista: string; xintplista: real);
// Objetivo...: Fijar/Variar el porcentaje de interes
begin
  if BuscarRL(xlista) then
    begin
      ref1.Edit;
      ref1.FieldByName('intplista').AsFloat := xintplista;
      try
        ref1.Post;
      except
        ref1.Cancel;
      end;
    end;
    datosdb.refrescar(ref1);
end;

function TTListaPrecios.setNominaArticulos: TQuery;
Begin
  Result := datosdb.tranSQL('select codart, descrip from precios order by codart');
end;

function TTListaPrecios.setNominaArticulosAlf: TQuery;
Begin
  Result := datosdb.tranSQL('select codart, descrip from precios order by descrip');
end;

procedure TTListaPrecios.ListarEtiquetas(xlista: TStringList; xfilaini, xcolini: Integer; salida: char);
var
  i, j, max, cant, inicio, nroet, fila, columna: Integer;
Begin
  getModeloEtiquetas('01');

  max := StrToInt(CantPagEt) * StrToInt(CantAlto);

  list.Setear(salida);
  list.NoImprimirPieDePagina;
  for i := 1 to StrToInt(margensup) do list.Titulo(0, 0, '', 1, 'Arial, normal, 8');

  nroet := 0;
  if (xfilaini > 1) or (xcolini > 1) then Begin
    for i := 1 to xfilaini do Begin
      for j := 1 to 3 do Begin
        if (i = xfilaini) and (j = xcolini) then Break;

        Inc(nroet);
        if nroet > StrToInt(CantPagEt) then Begin
          ListarEtiqueta(salida);
          nroet := 1;
        end;

        if nroet = 1 then Begin          // Etiqueta 1
          etpag[1, 1] := '';
          etpag[2, 1] := '';
          etpag[3, 1] := '';
        end;
        if nroet = 2 then Begin          // Etiqueta 2
          etpag[1, 2] := '';
          etpag[2, 2] := '';
          etpag[3, 2] := '';
        end;
        if nroet = 3 then Begin          // Etiqueta 3
          etpag[1, 3] := '';
          etpag[2, 3] := '';
          etpag[3, 3] := '';
        end;

        Inc(cant);
        if cant > max then Begin
          list.IniciarNuevaPagina;
          cant := 0;
        end;
      end;
    end;
  end;

  for i := 1 to xlista.Count do Begin
    getDatos(xlista.Strings[i-1]);

    Inc(nroet);
    if nroet > StrToInt(CantPagEt) then Begin
      ListarEtiqueta(salida);
      nroet := 1;
    end;

    if nroet = 1 then Begin          // Etiqueta 1
      etpag[1, 1] := 'Cód.: ' + codart;
      etpag[2, 1] := descrip;
      etpag[3, 1] := 'Precio: ' + utiles.FormatearNumero(FloatToStr(precio1));
    end;
    if nroet = 2 then Begin          // Etiqueta 2
      etpag[1, 2] := 'Cód.: ' + codart;
      etpag[2, 2] := descrip;
      etpag[3, 2] := 'Precio: ' + utiles.FormatearNumero(FloatToStr(precio1));
    end;
    if nroet = 3 then Begin          // Etiqueta 3
      etpag[1, 3] := 'Cód.: ' + codart;
      etpag[2, 3] := descrip;
      etpag[3, 3] := 'Precio: ' + utiles.FormatearNumero(FloatToStr(precio1));
    end;

    Inc(cant);
    if cant > max then Begin
      list.IniciarNuevaPagina;
      cant := 0;
    end;
  end;

  ListarEtiqueta(salida);

  list.FinList;
end;

procedure TTListaPrecios.ListarEtiqueta(salida: char);
// Objetivo...: Listar Etiquetas
var
  i, j: Integer;
Begin
  for i := 1 to 3 do Begin
    list.Linea(0, 0, '', 1, FuenteEt, salida, 'N');
    for j := 1 to 3 do Begin
      if j = 1 then list.Linea(Etiqueta1, list.Lineactual,  etpag[i, j], j+1, FuenteEt, salida, 'N');
      if j = 2 then list.Linea(Etiqueta2, list.Lineactual,  etpag[i, j], j+1, FuenteEt, salida, 'N');
      if j = 3 then list.Linea(Etiqueta3, list.Lineactual,  etpag[i, j], j+1, FuenteEt, salida, 'N');
    end;
    list.Linea(96, list.Lineactual, '', j+2, FuenteEt, salida, 'S');
  end;

  for i := 1 to 3 do
    for j := 1 to 3 do etpag[i, j] := '';

  for i := 1 to StrToInt(Separacion) do list.Linea(0, 0, '', 1, 'Arial, normal, 6', salida, 'S'); 
end;

procedure TTListaPrecios.GuardarModeloEtiquetas(xid, xmodelo, xfuente: String; xcant_pag, xcant_alto, xmargen_sup, xseparacion, xetiqueta1, xetiqueta2, xetiqueta3: Integer);
Begin
  if et.FindKey([xid]) then et.Edit else et.Append;
  et.FieldByName('id').AsString := xid;
  et.FieldByName('modelo').AsString      := xmodelo;
  et.FieldByName('fuente').AsString      := xfuente;
  et.FieldByName('cantpag').AsInteger    := xcant_pag;
  et.FieldByName('cantalto').AsInteger   := xcant_alto;
  et.FieldByName('margensup').AsInteger  := xmargen_sup;
  et.FieldByName('separacion').AsInteger := xseparacion;
  et.FieldByName('et1').AsInteger        := xetiqueta1;
  et.FieldByName('et2').AsInteger        := xetiqueta2;
  et.FieldByName('et3').AsInteger        := xetiqueta3;
  try
    et.Post
   except
    et.Cancel
  end;
  datosdb.refrescar(et); 
end;

procedure TTListaPrecios.getModeloEtiquetas(xid: String);
Begin
  if et.FindKey([xid]) then Begin
    ModeloEt   := et.FieldByName('modelo').AsString;
    FuenteEt   := et.FieldByName('fuente').AsString;
    CantPagEt  := et.FieldByName('cantpag').AsString;
    CantAlto   := et.FieldByName('cantalto').AsString;
    MargenSup  := et.FieldByName('margensup').AsString;
    Separacion := et.FieldByName('separacion').AsString;
    Etiqueta1  := et.FieldByName('et1').AsInteger;
    Etiqueta2  := et.FieldByName('et2').AsInteger;
    Etiqueta3  := et.FieldByName('et3').AsInteger;
  end else Begin
    ModeloEt := ''; FuenteEt := ''; CantPagEt := '0'; CantAlto := '0'; MargenSup := '0'; Separacion := '5'; Etiqueta1 := 0; Etiqueta2 := 0; Etiqueta3 := 0;
  end;
  if Length(Trim(FuenteEt)) = 0 then FuenteEt := 'Courier New, normal, 8';
end;

procedure TTListaPrecios.BuscarPorCodigo(xexpresion: String);
Begin
  if tabla.IndexFieldNames <> 'Codart' then tabla.IndexFieldNames := 'Codart';
  tabla.FindNearest([xexpresion]);
end;


procedure TTListaPrecios.BuscarPorDescrip(xexpresion: String);
Begin
  if tabla.IndexFieldNames <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpresion]);
end;

procedure TTListaPrecios.SeleccionarImpresora(ximpresora: String);
// objetivo...: Seleccionar Impresora
Begin
  list.SeleccionarImpresora(StrToInt(ximpresora), ''); 
end;

{*******************************************************************************}

procedure TTListaPrecios.conectar;
// Objetivo...: conectar tabla de persistencia
begin
  art.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('codart').DisplayLabel := 'Cód. Artículo'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; //tabla.FieldByName('precio').DisplayLabel := 'Precio';
    if not ref1.Active then ref1.Open;
    if not ref11.Active then ref11.Open;
    if not Et.Active then Et.Open;
    via.conectar;
  end;
  Inc(conexiones);
end;

procedure TTListaPrecios.desconectar;
// Objetivo...: desconectar tabla de persistencia
begin
  art.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(ref1);
    datosdb.closeDB(ref11);
    datosdb.closeDB(et);
    via.desconectar;
  end;
end;

{===============================================================================}

function precios: TTListaPrecios;
begin
  if xprecios = nil then
    xprecios := TTListaPrecios.Create;
  Result := xprecios;
end;

{===============================================================================}

initialization

finalization
  xprecios.Free;

end.
