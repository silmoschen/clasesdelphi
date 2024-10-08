unit CDerivacionesAnalisisClinicos;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CTitulos,
     CDerivacionesAnalisis, CPaciente, CNomecla, CObrasSociales,
     CCBloqueosLaboratorios, Contnrs, CNBU;

type

TTDerivAnalisis = class
  Nroderiv, Protocolo, Codigo, Codos, Codpac, Items, Fecha, Identidad, Encabezado, Pie, Itemsprot: String;
  Existe: Boolean;
  cabderiv, detderiv, formato, ultnro: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnroderiv: String): Boolean;
  function    BuscarItems(xnroderiv, xitems: String): Boolean;
  procedure   Guardar(xnroderiv, xfecha, xidentidad, xitems, xprotocolo, xcodigo, xcodos, xcodpac, xitemsprot: String; xcantitems: Integer);
  procedure   Borrar(xnroderiv: String);
  procedure   getDatos(xnroderiv: String);
  function    Nuevo: String;
  function    setDerivaciones(xnroderiv: String): TObjectList;
  function    setDerivEntidad(xidentidad: String): TObjectList;

  procedure   DefinirFormato(xencabezado, xpie: String);
  procedure   getDatosFormato;

  procedure   Listar(xnroderiv: String; salida: char);
  procedure   ListarDerivaciones(xdesde, xhasta: String; salida: char);

  function    Bloquear(xproceso: String): Boolean;
  procedure   QuitarBloqueo(xproceso: String);

  procedure   RegistrarUltimaDerivacion(xnroderivacion: string);
  function    setUltimaDerivacion: String;

  procedure   Depurar(xfecha: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure ListarDetalle(xnroderiv: String; salida: char);
end;

function derivacion: TTDerivAnalisis;

implementation

var
  xderivacion: TTDerivAnalisis = nil;

constructor TTDerivAnalisis.Create;
begin
  if dbs.BaseClientServ = 'N' then Begin
    cabderiv := datosdb.openDB('cabderivacion', '');
    detderiv := datosdb.openDB('detderivacion', '');
    formato  := datosdb.openDB('formatoderivacion', '');
    ultnro   := datosdb.openDB('ultnro', '');
  end;
  if dbs.BaseClientServ = 'S' then Begin
    cabderiv := datosdb.openDB('cabderivacion', '', '', dbs.baseDat_N);
    detderiv := datosdb.openDB('detderivacion', '', '', dbs.baseDat_N);
    formato  := datosdb.openDB('formatoderivacion', '', '', dbs.baseDat_N);
    ultnro   := datosdb.openDB('ultnro', '', '', dbs.baseDat_N);
  end;
end;

destructor TTDerivAnalisis.Destroy;
begin
  inherited Destroy;
end;

function  TTDerivAnalisis.Buscar(xnroderiv: String): Boolean;
Begin
  if cabderiv.IndexFieldNames <> 'nroderiv' then cabderiv.IndexFieldNames := 'nroderiv';
  Existe := cabderiv.FindKey([xnroderiv]);
  Result := Existe;
end;

function  TTDerivAnalisis.BuscarItems(xnroderiv, xitems: String): Boolean;
Begin
  if detderiv.IndexFieldNames <> 'nroderiv;items' then detderiv.IndexFieldNames := 'nroderiv;items';
  Result := datosdb.Buscar(detderiv, 'nroderiv', 'items', xnroderiv, xitems);
end;

procedure TTDerivAnalisis.Guardar(xnroderiv, xfecha, xidentidad, xitems, xprotocolo, xcodigo, xcodos, xcodpac, xitemsprot: String; xcantitems: Integer);
Begin
  if xitems = '01' then Begin
    if Buscar(xnroderiv) then cabderiv.Edit else cabderiv.Append;
    cabderiv.FieldByName('nroderiv').AsString  := xnroderiv;
    cabderiv.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
    //cabderiv.FieldByName('identidad').AsString := xidentidad;
    try
      cabderiv.Post
     except
      cabderiv.Cancel
    end;
    datosdb.closeDB(cabderiv); cabderiv.Open;
  end;
  if BuscarItems(xnroderiv, xitems) then detderiv.Edit else detderiv.Append;
  detderiv.FieldByName('nroderiv').AsString  := xnroderiv;
  detderiv.FieldByName('items').AsString     := xitems;
  detderiv.FieldByName('protocolo').AsString := xprotocolo;
  detderiv.FieldByName('codigo').AsString    := xcodigo;
  detderiv.FieldByName('codos').AsString     := xcodos;
  detderiv.FieldByName('codpac').AsString    := xcodpac;
  detderiv.FieldByName('itemsprot').AsString := xitemsprot;
  detderiv.FieldByName('identidad').AsString := xidentidad;
  try
    detderiv.Post
   except
    detderiv.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then begin
    datosdb.tranSQL(detderiv.DatabaseName, 'delete from ' + detderiv.TableName + ' where nroderiv = ' + '''' + xnroderiv + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(detderiv); detderiv.Open;

    if not Existe then
      if (utiles.sLlenarIzquierda(Nuevo, 5, '0') <= xnroderiv) then RegistrarUltimaDerivacion(xnroderiv);
  end;
end;

procedure TTDerivAnalisis.Borrar(xnroderiv: String);
Begin
  if Buscar(xnroderiv) then Begin
    cabderiv.Delete;
    datosdb.closeDB(cabderiv); cabderiv.Open;
    datosdb.tranSQL(detderiv.DatabaseName, 'delete from ' + detderiv.TableName + ' where nroderiv = ' + '''' + xnroderiv + '''');
    datosdb.closeDB(detderiv); detderiv.Open;
  end;
end;

procedure TTDerivAnalisis.getDatos(xnroderiv: String);
Begin
  if Buscar(xnroderiv) then Begin
    Nroderiv  := cabderiv.FieldByName('nroderiv').AsString;
    Fecha     := utiles.sFormatoFecha(cabderiv.FieldByName('fecha').AsString);
    Identidad := cabderiv.FieldByName('identidad').AsString;
  end else Begin
    Nroderiv := ''; Fecha := utiles.setFechaActual; Identidad := '';
  end;
end;

function TTDerivAnalisis.Nuevo: String;
Begin
  ultnro.First;
  if ultnro.RecordCount = 0 then Result := '1' else Result := IntToStr(ultnro.FieldByName('nroderivacion').AsInteger + 1);
end;

function TTDerivAnalisis.setDerivaciones(xnroderiv: String): TObjectList;
// Objetivo...: Devolver las derivaciones
var
  l: TObjectList;
  objeto: TTDerivAnalisis;
Begin
  l := TObjectList.Create;
  if BuscarItems(xnroderiv, '01') then Begin
    while not detderiv.Eof do Begin
      if detderiv.FieldByName('nroderiv').AsString <> xnroderiv then Break;
      objeto := TTDerivAnalisis.Create;
      objeto.Items     := detderiv.FieldByName('items').AsString;
      objeto.Protocolo := detderiv.FieldByName('protocolo').AsString;
      objeto.codigo    := detderiv.FieldByName('codigo').AsString;
      objeto.codos     := detderiv.FieldByName('codos').AsString;
      objeto.codpac    := detderiv.FieldByName('codpac').AsString;
      objeto.Itemsprot := detderiv.FieldByName('itemsprot').AsString;
      objeto.Identidad := detderiv.FieldByName('identidad').AsString;
      l.Add(objeto);
      detderiv.Next;
    end;
  end;
  Result := l;
end;

procedure TTDerivAnalisis.DefinirFormato(xencabezado, xpie: String);
// Objetivo...: registrar formato
Begin
  if formato.FindKey(['1']) then formato.Edit else formato.Append;
  formato.FieldByName('id').AsString         := '1';
  formato.FieldByName('encabezado').AsString := xencabezado;
  formato.FieldByName('pie').AsString        := xpie;
  try
    formato.Post
   except
    formato.Cancel
  end;
end;

procedure TTDerivAnalisis.getDatosFormato;
// Objetivo...: recuperar formato
Begin
  if formato.FindKey(['1']) then Begin
    Encabezado := formato.FieldByName('encabezado').AsString;
    Pie        := formato.FieldByName('pie').AsString;
  end else Begin
    Encabezado := ''; Pie := '';
  end;
end;

function  TTDerivAnalisis.setDerivEntidad(xidentidad: String): TObjectList;
// Obejtivo...: Obtener lista de derivaciones
var
  l: TObjectList;
  objeto: TTDerivAnalisis;
Begin
  l := TObjectList.Create;
  cabderiv.IndexFieldNames := 'Identidad';
  if cabderiv.FindKey([xidentidad]) then Begin
    while not cabderiv.Eof do Begin
      if cabderiv.FieldByName('identidad').AsString <> xidentidad then Break;
      objeto := TTDerivAnalisis.Create;
      objeto.Nroderiv  := cabderiv.FieldByName('nroderiv').AsString;
      objeto.Fecha     := utiles.sFormatoFecha(cabderiv.FieldByName('fecha').AsString);
      objeto.Identidad := cabderiv.FieldByName('identidad').AsString;
      l.Add(objeto);
      cabderiv.Next;
    end;
  end;
  cabderiv.IndexFieldNames := 'Nroderiv';
  Result := l;
end;

procedure TTDerivAnalisis.Listar(xnroderiv: String; salida: char);
// Objetivo...: Listar N�mina de Derivaciones
Begin
  list.Setear(salida); list.NoImprimirPieDePagina;
  titulos.conectar;
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 18');
  list.Titulo(0, 0, titulos.titulo, 1, titulos.fTitulo);
  list.ListMemo('Direccion', titulos.fdirtel, 0, salida, titulos.tabla, 0);

  list.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, negrita, 11', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 16', salida, 'S');
  titulos.desconectar;

  getDatos(xnroderiv);
  list.IniciarMemoImpresiones(formato, 'encabezado', 700);
  list.RemplazarEtiquetasEnMemo('#fecha', Copy(fecha, 1, 2) + ' de ' + utiles.setMes(StrToInt(Copy(fecha, 4, 2))) + ' del ' + Copy(utiles.sExprFecha2000(fecha), 1, 4));
  list.RemplazarEtiquetasEnMemo('#derivacion', xnroderiv);
  list.ListMemo('', 'Arial, normal, 9', 0, salida, Nil, 500);

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, 'Prot.', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(7, list.Lineactual, 'Paciente', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(35, list.Lineactual, 'Determinaciones', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(68, list.Lineactual, 'Edad', 4, 'Arial, normal, 8', salida, 'N');
  list.Linea(73, list.Lineactual, 'Obra Social', 5, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '-----', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(7, list.Lineactual, '----------', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(35, list.Lineactual, '--------------------', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(68, list.Lineactual, '------', 4, 'Arial, normal, 8', salida, 'N');
  list.Linea(73, list.Lineactual, '--------------', 5, 'Arial, normal, 8', salida, 'S');

  ListarDetalle(xnroderiv, salida);
  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

  list.IniciarMemoImpresiones(formato, 'pie', 700);
  list.ListMemo('', 'Arial, normal, 9', 0, salida, Nil, 700);

  list.FinList;
end;

procedure TTDerivAnalisis.ListarDerivaciones(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Derivaciones Realizadas
var
  cantidad: Integer;
Begin
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Determinaciones Derivadas - Per�odo: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Prot.', 1, 'Arial, cursiva, 8');
  list.Titulo(7, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
  list.Titulo(35, list.Lineactual, 'Determinaciones', 3, 'Arial, cursiva, 8');
  list.Titulo(68, list.Lineactual, 'Edad', 4, 'Arial, cursiva, 8');
  list.Titulo(73, list.Lineactual, 'Obra Social', 5, 'Arial, cursiva, 8');
  list.Titulo(90, list.Lineactual, 'Entidad a la que se Deriva', 6, 'Arial, cursiva, 8');
  list.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 16', salida, 'S');

  derivanalisis.conectar; cantidad := 0;
  datosdb.Filtrar(cabderiv, 'fecha >= ' + '''' + utiles.sexprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  while not cabderiv.Eof do Begin
    //derivanalisis.getDatos(cabderiv.FieldByName('identidad').AsString);
    list.Linea(0, 0, cabderiv.FieldByName('nroderiv').AsString, 1, 'Arial, negrita, 9', salida, 'N');
    list.Linea(10, list.Lineactual, utiles.sFormatoFecha(cabderiv.FieldByName('fecha').AsString), 2, 'Arial, negrita, 9', salida, 'S');
    //list.Linea(20, list.Lineactual, derivanalisis.Descrip, 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    ListarDetalle(cabderiv.FieldByName('nroderiv').AsString, salida);
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    Inc(cantidad);
    cabderiv.Next;
  end;
  datosdb.QuitarFiltro(cabderiv);
  derivanalisis.desconectar;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, IntToStr(cantidad) + '   Derviciones Realizadas.', 1, 'Arial, negrita, 9', salida, 'S');

  list.FinList;
end;

procedure TTDerivAnalisis.ListarDetalle(xnroderiv: String; salida: char);
// Objetivo...: Listar Derivaciones Realizadas
var
  idanter: String;
Begin
  if BuscarItems(xnroderiv, '01') then Begin
    while not detderiv.eof do Begin
      if detderiv.FieldByName('nroderiv').AsString <> xnroderiv then Break;
      if detderiv.FieldByName('protocolo').AsString <> idanter then Begin
        list.Linea(0, 0, detderiv.FieldByName('protocolo').AsString, 1, 'Arial, normal, 8', salida, 'N');
        paciente.getDatos(detderiv.FieldByName('codpac').AsString);
        list.Linea(7, list.Lineactual, paciente.nombre, 2, 'Arial, normal, 8', salida, 'N');
      end else Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(7, list.Lineactual, '', 2, 'Arial, normal, 8', salida, 'N');
      end;
      if (Length(Trim(detderiv.FieldByName('codigo').AsString)) = 4) then begin
        nomeclatura.getDatos(detderiv.FieldByName('codigo').AsString);
        list.Linea(35, list.Lineactual, Copy(nomeclatura.descrip, 1, 40), 3, 'Arial, normal, 8', salida, 'N');
      end else begin
        nbu.getDatos(detderiv.FieldByName('codigo').AsString);
        list.Linea(35, list.Lineactual, Copy(nbu.descrip, 1, 40), 3, 'Arial, normal, 8', salida, 'N');
      end;
      if detderiv.FieldByName('protocolo').AsString <> idanter then Begin
        utiles.calc_antiguedad(utiles.sExprFecha(paciente.fenac), utiles.sExprFecha2000(utiles.setFechaActual));
        list.Linea(70, list.Lineactual, IntToStr(utiles.getAnios), 4, 'Arial, normal, 8', salida, 'N');
      end;
      derivanalisis.getDatos(detderiv.FieldByName('identidad').AsString);
      obsocial.getDatos(detderiv.FieldByName('codos').AsString);
      list.Linea(73, list.Lineactual, Copy(obsocial.nombre, 1, 20), 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(90, list.Lineactual, Copy(derivanalisis.Descrip, 1, 20), 6, 'Arial, normal, 8', salida, 'S');
      idanter := detderiv.FieldByName('protocolo').AsString;
      detderiv.Next;
    end;
  end;
end;

function  TTDerivAnalisis.Bloquear(xproceso: String): Boolean;
// Objetivo...: Bloquear Proceso
begin
  Result := bloqueo.Bloquear(xproceso);
end;

procedure TTDerivAnalisis.QuitarBloqueo(xproceso: String);
// Objetivo...: Quitar Bloqueo
begin
  bloqueo.QuitarBloqueo(xproceso);
end;

procedure TTDerivAnalisis.RegistrarUltimaDerivacion(xnroderivacion: string);
// Objetivo...: Almacenar el �ltimo de la ultima solicitud v�lida
begin
  if ultnro.RecordCount = 0 then begin
    ultnro.Append;
    ultnro.FieldByName('id').asinteger := 1;
  end
  else ultnro.Edit;  // Guardamos el �ltimo nro. de solicitud
  ultnro.FieldByName('nroderivacion').AsString := xnroderivacion;
  try
    ultnro.Post
  except
    ultnro.Cancel
  end;
  datosdb.refrescar(ultnro);
end;

function TTDerivAnalisis.setUltimaDerivacion: String;
// Objetivo...: devolver la ultima derivacion
begin
  if ultnro.RecordCount = 0 then result := '1' else result :=  ultnro.FieldByName('nroderivacion').AsString;
end;

procedure TTDerivAnalisis.Depurar(xfecha: string);
// Objetivo...: depurar movimientos
var
  r: TQuery;
begin
  r := datosdb.tranSQL(cabderiv.DatabaseName, 'select nroderiv from ' + cabderiv.TableName + ' where fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  r.Open;
  while not r.Eof do begin
    if Buscar(r.FieldByName('nroderiv').AsString) then begin
      cabderiv.Delete;
      datosdb.tranSQL(detderiv.DatabaseName, 'delete from ' + detderiv.TableName + ' where nroderiv = ' + '''' + r.FieldByName('nroderiv').AsString + '''');
      datosdb.refrescar(cabderiv); datosdb.refrescar(detderiv);
    end;
    r.Next;
  end;
  datosdb.closedb(cabderiv); datosdb.closedb(detderiv);
  cabderiv.Open; detderiv.Open;
  r.Close; r.Free;
end;

procedure TTDerivAnalisis.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cabderiv.Active then cabderiv.Open;
    if not detderiv.Active then detderiv.Open;
    if not formato.Active then formato.Open;
    if not ultnro.Active then ultnro.Open;
  end;
  Inc(conexiones);
end;

procedure TTDerivAnalisis.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    if cabderiv.Active then datosdb.closeDB(cabderiv);
    if detderiv.Active then datosdb.closeDB(detderiv);
    if formato.Active then datosdb.closeDB(formato);
    if ultnro.Active then datosdb.closeDB(ultnro);
  end;
end;

{===============================================================================}

function derivacion: TTDerivAnalisis;
begin
  if xderivacion = nil then
    xderivacion := TTDerivAnalisis.Create;
  Result := xderivacion;
end;

{===============================================================================}

initialization

finalization
  xderivacion.Free;

end.
