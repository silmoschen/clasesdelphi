unit CPlantAnalisis;

interface

uses CNomecla, CNBU, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, ContenedorMemo,
     Forms, CCBloqueosLaboratorios, Contnrs;

type

TTPlantillaAnalisisClinicos = class(TObject)
  codigo, items, itemsParalelo, elemento, valoresn, resultado, imputable,
  observaciones, distancia, Encabezado, Detalle, Formula, Unidad,
  Sigla, Ceros: string;
  tabla, tabref, thojatrab, tsol: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xitems, xitemsParalelo, xelemento, xvaloresn, xresultado, ximputable, xdistancia, xformula, xunidad, xsigla, xceros: string; xcantitems: Integer);
  procedure   GrabarRef(xcodigo, xitems, xobservaciones: string);
  procedure   Borrar(xcodigo: string);
  function    BuscarRef(xcodigo, xitems: string): boolean;
  function    Buscar(xcodigo, xitems: string): boolean;
  procedure   getDatos(xcodigo, xitems: string);
  procedure   getDatosRef(xcodigo, xitems: string);
  function    setPlantanalisis: TQuery; overload;
  function    setPlantanalisis(xcodigo: string): TQuery; overload;
  procedure   Listar(xdcodigo, xhcodigo: string; salida: char);
  procedure   ListarModelo(xdcodigo, xhcodigo: string; salida: char);

  function    verificarCodNomeclador(xcodigo: string): boolean;
  function    getRefPlantanalisis: TQuery;

  function    BuscarItemsSol(xcodigo, xitems: String): Boolean;
  procedure   RegistrarItemsSol(xcodigo, xitems, xcolumna1, xcolumna2: String; xcantitems: Integer);
  procedure   BorrarItemsSol(xcodigo: String);
  function    setItemsSol(xcodigo: String): TQuery;

  function    Bloquear(xproceso: String): Boolean;
  procedure   QuitarBloqueo(xproceso: String);

  function    getplantanalisis: TQuery;

  function    getPlantanalisisBySigla(xsigla: string): TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: integer;
  idanter, dir: string;

  l: TObjectList;
  objeto: TTPlantillaAnalisisClinicos;

  procedure loadList;
end;

function plantanalisis: TTPlantillaAnalisisClinicos;

implementation

var
  xplantanalisis: TTPlantillaAnalisisClinicos = nil;

constructor TTPlantillaAnalisisClinicos.Create;
begin
  inherited Create;
  if (dbs.BaseClientServ = 'N') or (Length(Trim(dbs.baseDat_N)) = 0) then Begin
    tabla  := datosdb.openDB('plantan', 'codigo;items');     // Plantilla
    tabref := datosdb.openDB('refplantan', 'codigo;items');  // Referencia de an�lisis
    tsol   := datosdb.openDB('plantansolicitud', 'codigo;items');  // Referencia de an�lisis para Solicitudes
    dir    := dbs.baseDat;
  end;
  if (dbs.BaseClientServ = 'S') and (Length(Trim(dbs.baseDat_N)) > 0) then Begin
    tabla  := datosdb.openDB('plantan', 'codigo;items', '', dbs.baseDat_N);     // Plantilla
    tabref := datosdb.openDB('refplantan', 'codigo;items', '', dbs.baseDat_N);  // Referencia de an�lisis
    tsol   := datosdb.openDB('plantansolicitud', 'codigo;items', '', dbs.baseDat_N);  // Referencia de an�lisis para Solicitudes
    dir    := dbs.baseDat_N;
  end;
end;

destructor TTPlantillaAnalisisClinicos.Destroy;
begin
  inherited Destroy;
end;

procedure TTPlantillaAnalisisClinicos.loadList;
begin
  l := TObjectList.Create;

  tabla.First;
  while not tabla.eof do begin
     objeto := TTPlantillaAnalisisClinicos.Create;
     objeto.codigo        := tabla.FieldByName('codigo').AsString;
     objeto.items         := tabla.FieldByName('items').AsString;
     objeto.itemsParalelo := tabla.FieldByName('itemsParalelo').AsString;
     objeto.elemento      := tabla.FieldByName('elemento').AsString;
     objeto.valoresn      := tabla.FieldByName('valoresn').AsString;
     objeto.resultado     := tabla.FieldByName('resultado').AsString;
     objeto.imputable     := tabla.FieldByName('imputable').AsString;
     objeto.distancia     := tabla.FieldByName('distancia').AsString;
     objeto.formula       := tabla.FieldByName('formula').AsString;
     objeto.Unidad        := tabla.FieldByName('unidad').AsString;
     objeto.Sigla         := tabla.FieldByName('sigla').AsString;
     l.Add(objeto);
     tabla.Next;
  end;

end;

function TTPlantillaAnalisisClinicos.Buscar(xcodigo, xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if datosdb.Buscar(tabla, 'codigo', 'items', xcodigo, xitems) then Result := True else Result := False;
end;

function TTPlantillaAnalisisClinicos.BuscarRef(xcodigo, xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if datosdb.Buscar(tabref, 'codigo', 'items', xcodigo, xitems) then Result := True else Result := False;
end;

procedure TTPlantillaAnalisisClinicos.Grabar(xcodigo, xitems, xitemsParalelo, xelemento, xvaloresn, xresultado, ximputable, xdistancia, xformula, xunidad, xsigla, xceros: string; xcantitems: Integer);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo, xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString        := xcodigo;
  tabla.FieldByName('items').AsString         := xitems;
  tabla.FieldByName('itemsParalelo').AsString := xitemsParalelo;
  tabla.FieldByName('elemento').AsString      := xelemento;
  tabla.FieldByName('valoresn').AsString      := xvaloresn;
  tabla.FieldByName('resultado').AsString     := xresultado;
  tabla.FieldByName('imputable').AsString     := ximputable;
  tabla.FieldByName('distancia').AsString     := xdistancia;
  tabla.FieldByName('formula').AsString       := xformula;
  tabla.FieldByName('unidad').AsString        := xunidad;
  tabla.FieldByName('sigla').AsString         := xsigla;
  tabla.FieldByName('ceros').AsString         := xceros;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL(tabla.DatabaseName, 'delete from ' + tabla.TableName + ' where codigo = ' + '"' + xcodigo + '"' +  ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') + '"');
    datosdb.refrescar(tabla);
    l := nil;
    //loadList;
  end;       

end;

procedure TTPlantillaAnalisisClinicos.GrabarRef(xcodigo, xitems, xobservaciones: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarRef(xcodigo, xitems) then tabref.Edit else tabref.Append;
  tabref.FieldByName('codigo').AsString     := xcodigo;
  tabref.FieldByName('items').AsString      := xitems;
  tabref.FieldByName('observaciones').Value := xobservaciones;
  try
    tabref.Post;
  except
    tabref.Cancel;
  end;
end;

procedure TTPlantillaAnalisisClinicos.Borrar(xcodigo: string);
// Objetivo...: Eliminar un set de objetos, pertenecientes a un an�lisis concreto
begin
  datosdb.tranSQL(tabla.DatabaseName, 'DELETE FROM ' + tabla.TableName + ' WHERE codigo = ' + '"' + xcodigo + '"');
  loadList;
end;

procedure  TTPlantillaAnalisisClinicos.getDatos(xcodigo, xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
var
  i: integer;
begin
  if (l <> nil) then begin
    codigo := ''; items := ''; itemsParalelo := ''; elemento := ''; valoresn := ''; resultado := ''; imputable := ''; distancia := ''; formula := ''; ceros := '';
    for i := 1 to l.Count do Begin
      objeto := TTPlantillaAnalisisClinicos(l.Items[i-1]);
      if (trim(objeto.codigo) = xcodigo) and (objeto.items = xitems) then begin
        codigo := objeto.codigo;
        items := objeto.items;
        itemsParalelo := objeto.itemsParalelo;
        elemento := objeto.elemento;
        valoresn := objeto.valoresn;
        resultado := objeto.resultado;
        imputable := objeto.imputable;
        distancia := objeto.distancia;
        formula := objeto.Formula;
        unidad := objeto.Unidad;
        sigla := objeto.Sigla;
        ceros := objeto.Ceros;
        break;
      end;
    End;
    exit;
  end;

  if Buscar(trim(xcodigo), xitems) then
    begin
      codigo        := tabla.FieldByName('codigo').AsString;
      items         := tabla.FieldByName('items').AsString;
      itemsParalelo := tabla.FieldByName('itemsParalelo').AsString;
      elemento      := tabla.FieldByName('elemento').AsString;
      valoresn      := tabla.FieldByName('valoresn').AsString;
      resultado     := tabla.FieldByName('resultado').AsString;
      imputable     := tabla.FieldByName('imputable').AsString;
      distancia     := tabla.FieldByName('distancia').AsString;
      formula       := tabla.FieldByName('formula').AsString;
      unidad        := tabla.FieldByName('unidad').AsString;
      sigla         := tabla.FieldByName('sigla').AsString;
      ceros         := tabla.FieldByName('ceros').AsString;
    end
   else
    begin
      codigo := ''; items := ''; itemsParalelo := ''; elemento := ''; valoresn := ''; resultado := ''; imputable := ''; distancia := ''; formula := ''; unidad := ''; sigla := ''; ceros := '';
    end;
   if Trim(elemento) = '-' then elemento := '';
end;

procedure  TTPlantillaAnalisisClinicos.getDatosRef(xcodigo, xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarRef(xcodigo, xitems) then observaciones := tabref.FieldByName('observaciones').Value else observaciones := '';
end;

function TTPlantillaAnalisisClinicos.setplantanalisis: TQuery;
// Objetivo...: Devolver un set de registro con los items
begin
  Result := datosdb.tranSQL(dir, 'SELECT codigo, sigla, items, elemento, resultado, valoresn, imputable, distancia, itemsparalelo, formula, unidad, ceros FROM plantan');
end;

function TTPlantillaAnalisisClinicos.setplantanalisis(xcodigo: string): TQuery;
// Objetivo...: Devolver un set de registro con los items
begin
  Result := datosdb.tranSQL(dir, 'SELECT codigo, sigla, items, elemento, resultado, valoresn, imputable, distancia, itemsparalelo, formula, unidad, ceros FROM plantan WHERE codigo = ' + '''' + xcodigo + '''' + ' ORDER BY Items');
end;

procedure TTPlantillaAnalisisClinicos.ListarModelo(xdcodigo, xhcodigo: string; salida: char);
// Objetivo...: Listar Plantilla de an�lisis cl�nicos
var
  l, r, t: TQuery; distancia: integer; itp, dtl: boolean;
begin
  List.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Modelo de Presentaci�n Informes An�lisis Cl�nicos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, utiles.espacios(3) +  'Elemento', 1, 'Arial, cursiva, 8');
  List.Titulo(55, list.Lineactual, 'Items Paralelos', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  l := TQuery.Create(nil); r := TQuery.Create(nil); t := TQuery.Create(nil);
  l := nomeclatura.setNomeclatura;
  l.Open; l.First;
  while not l.EOF do Begin
    if (l.FieldByName('codigo').AsString >= xdcodigo) and (l.FieldByName('codigo').AsString <= xhcodigo) then Begin
      if datosdb.Buscar(tabla, 'codigo', 'items', l.FieldByName('codigo').AsString, '01') then Begin
        // Datos del An�lisis
        nomeclatura.getDatos(l.FieldByName('codigo').AsString);
        List.Linea(0, 0, nomeclatura.codigo + '   ' + UpperCase(nomeclatura.descrip), 1, 'Arial, negrita, 9', salida, 'N');
        // Extraemos los items de la plantilla
        r := TQuery.Create(nil); t := TQuery.Create(nil);
        r := setPlantanalisis(l.FieldByName('codigo').AsString); t := setPlantanalisis(l.FieldByName('codigo').AsString);
        r.Open; t.Open;

        // Ahora imprimimos los items paralelo a la desripci�n del anlalisis - Nivel 0
        t.First; itp := False;
        while not t.EOF do Begin
          if t.FieldByName('itemsParalelo').AsString = '00' then Begin
            if Length(Trim(t.FieldByName('distancia').AsString)) > 0 then distancia := StrToInt(t.FieldByName('distancia').AsString) else distancia := 50;
            List.Linea(distancia, list.lineactual, t.FieldByName('elemento').AsString, 2, 'Arial, normal, 8', salida, 'N');
            if Length(Trim(t.FieldByName('resultado').AsString)) > 0 then List.Linea(distancia + 25, list.lineactual, t.FieldByName('resultado').AsString, 3, 'Arial, normal, 8', salida, 'N');
            if Length(Trim(t.FieldByName('valoresn').AsString)) > 0 then List.Linea(distancia + 25, list.lineactual, t.FieldByName('valoresn').AsString, 4, 'Arial, normal, 8', salida, 'S') else List.Linea(distancia + 25, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
            itp := True;
          end;
          t.Next;
        end;

        // Completamos
        if not itp then List.Linea(95, list.lineactual, ' ', 2, 'Arial, normal, 8', salida, 'S');
        List.Linea(0, 0, '   ', 1, 'Arial, negrita, 5', salida, 'S');

        // Damos Formato a la Plantilla
        while not r.EOF do Begin
          if Length(Trim(r.FieldByName('itemsParalelo').AsString)) = 0 then Begin
            // Items Independientes
            List.Linea(0, 0, utiles.espacios(3) + r.FieldByName('elemento').AsString, 1, 'Arial, normal, 8', salida, 'N');
            // Ahora imprimimos los items paralelos
            t.First; itp := False;
            while not t.EOF do Begin
              if t.FieldByName('itemsParalelo').AsString = r.FieldByName('items').AsString then Begin
                if Length(Trim(t.FieldByName('distancia').AsString)) > 0 then distancia := StrToInt(t.FieldByName('distancia').AsString) else distancia := 50;
                List.Linea(distancia, list.lineactual, t.FieldByName('elemento').AsString, 2, 'Arial, normal, 8', salida, 'N');
                List.Linea(distancia + 25, list.lineactual, t.FieldByName('resultado').AsString, 3, 'Arial, normal, 8', salida, 'S');
                if Length(Trim(t.FieldByName('valoresn').AsString)) > 0 then List.Linea(distancia + 25, list.lineactual, t.FieldByName('valoresn').AsString, 4, 'Arial, normal, 8', salida, 'S') else List.Linea(distancia + 25, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
                itp := True;
              end;
              t.Next;
            end;
          end;
          r.Next;
        end;
        r.Close; t.Close;
        // Fin Impresi�n de Items
        dtl := True;
      end;
    end;

    l.Next;
  end;
  l.Close; l.Free; r.Free; t.Free; l := nil; r := nil;

  if not dtl then utiles.msgError('No Existen datos para Listar ...!') else list.FinList;
end;

procedure TTPlantillaAnalisisClinicos.Listar(xdcodigo, xhcodigo: string; salida: char);
// Objetivo...: Listar Plantilla de an�lisis cl�nicos
begin
  List.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Modelo de Presentaci�n Informes An�lisis Cl�nicos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, utiles.espacios(3) +  'Elemento', 1, 'Arial, cursiva, 8');
  List.Titulo(38, list.Lineactual, 'Valores Normales', 2, 'Arial, cursiva, 8');
  List.Titulo(65, list.Lineactual, 'Resultado Predet.', 3, 'Arial, cursiva, 8');
  List.Titulo(85, list.Lineactual, 'Imp.', 4, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'Dist.', 5, 'Arial, cursiva, 8');
  List.Titulo(96, list.Lineactual, 'It.Par.', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First; idanter := '';
  while not tabla.EOF do
    begin
      if (tabla.FieldByName('codigo').AsString >= xdcodigo) and (tabla.FieldByName('codigo').AsString <= xhcodigo) then Begin
        if tabla.FieldByName('codigo').AsString <> idanter then
          begin
            List.Linea(0, 0, '   ', 1, 'Arial, negrita, 5', salida, 'S');
            list.ListMemo('observaciones', 'Arial, cursiva, 8', 0, salida, tabla, 0);
            if (idanter <> '') and not (list.EfectuoSaltoPagina) then Begin
              List.Linea(0, 0, list.LineaLargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
              List.Linea(0, 0, '   ', 1, 'Arial, negrita, 5', salida, 'S');
            end;
            nomeclatura.getDatos(tabla.FieldByName('codigo').AsString);
            List.Linea(0, 0, nomeclatura.codigo + '   ' + UpperCase(nomeclatura.descrip), 1, 'Arial, negrita, 9', salida, 'S');
            List.Linea(0, 0, '   ', 1, 'Arial, negrita, 5', salida, 'S');
            idanter := tabla.FieldByName('codigo').AsString;
          end;
        List.Linea(0, 0, utiles.espacios(3) + tabla.FieldByName('elemento').AsString, 1, 'Arial, normal, 8', salida, 'N');
        List.Linea(38, list.lineactual, tabla.FieldByName('valoresn').AsString, 2, 'Arial, normal, 8', salida, 'N');
        List.Linea(65, list.lineactual, tabla.FieldByName('resultado').AsString, 3, 'Arial, normal, 8', salida, 'N');
        List.Linea(85, list.lineactual, tabla.FieldByName('imputable').AsString, 4, 'Courier New, normal, 8', salida, 'N');
        List.Linea(90, list.lineactual, tabla.FieldByName('Distancia').AsString, 5, 'Courier New, normal, 8', salida, 'N');
        List.Linea(97, list.lineactual, tabla.FieldByName('itemsParalelo').AsString, 6, 'Courier New, normal, 8', salida, 'S');
        list.ListMemo('observaciones', 'Arial, cursiva, 8', 0, salida, tabref, 0);
      end;
      tabla.Next;
    end;

  List.Linea(0, 0, list.LineaLargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.FinList;
end;

function TTPlantillaAnalisisClinicos.verificarCodNomeclador(xcodigo: string): boolean;
// Objetivo...: Verificar la existencia del c�digo del nomeclador
var
  b: boolean;
begin
  b := False;
  if not tabla.Active then Begin
    tabla.Open;
    b := True;
  end;

  Result := False;
  tabla.First;
  while not tabla.EOF do Begin
    if tabla.FieldByName('codigo').AsString = xcodigo then Begin
      Result := True;
      Break;
    end;
    tabla.Next;
  end;

  if b then tabla.Close;
end;

function  TTPlantillaAnalisisClinicos.Bloquear(xproceso: String): Boolean;
// Objetivo...: Bloquear Proceso
begin
  Result := bloqueo.Bloquear(xproceso);
end;

procedure TTPlantillaAnalisisClinicos.QuitarBloqueo(xproceso: String);
// Objetivo...: Quitar Bloqueo
begin
  bloqueo.QuitarBloqueo(xproceso);
end;

function  TTPlantillaAnalisisClinicos.BuscarItemsSol(xcodigo, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  Result := datosdb.Buscar(tsol, 'codigo', 'items', xcodigo, xitems);
end;

procedure TTPlantillaAnalisisClinicos.RegistrarItemsSol(xcodigo, xitems, xcolumna1, xcolumna2: String; xcantitems: Integer);
// Objetivo...: Registrar Instancia
begin
  if BuscarItemsSol(xcodigo, xitems) then tsol.Edit else tsol.Append;
  tsol.FieldByName('codigo').AsString   := xcodigo;
  tsol.FieldByName('items').AsString    := xitems;
  tsol.FieldByName('columna1').AsString := xcolumna1;
  tsol.FieldByName('columna2').AsString := xcolumna2;
  try
    tsol.Post
   except
    tsol.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from ' + tsol.TableName + ' where codigo = ' + '''' + xcodigo + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(tsol); tsol.Open;
  end;
end;

procedure TTPlantillaAnalisisClinicos.BorrarItemsSol(xcodigo: String);
// Objetivo...: Borrar Items Sol
begin
  datosdb.tranSQL('delete from ' + tsol.TableName + ' where codigo = ' + '''' + xcodigo + '''');
  datosdb.closeDB(tsol); tsol.Open;
end;

function  TTPlantillaAnalisisClinicos.setItemsSol(xcodigo: String): TQuery;
// Objetivo...: Devolver Items Sol
begin
  Result := datosdb.tranSQL('select * from ' + tsol.TableName + ' where codigo = ' + '''' + xcodigo + '''' + ' order by items');
end;

function TTPlantillaAnalisisClinicos.getplantanalisis: TQuery;
// Objetivo...: Devolver un set de registro con los items
begin
  tabla.Filtered := false;
  Result := datosdb.tranSQL(tabla.DatabaseName, 'SELECT codigo, items, elemento, resultado as res, valoresn, imputable, distancia, itemsparalelo, formula, observaciones FROM plantan WHERE codigo is not null and items is not null order by codigo, items');
end;

function TTPlantillaAnalisisClinicos.getRefPlantanalisis: TQuery;
// Objetivo...: Devolver un set de registro con los items
begin
  Result := datosdb.tranSQL(tabla.DatabaseName, 'SELECT * FROM refplantan WHERE codigo is not null and items is not null');
end;

function  TTPlantillaAnalisisClinicos.getPlantanalisisBySigla(xsigla: string): TQuery;
begin
  result := datosdb.tranSQL(tabla.DatabaseName, 'select codigo, items, ceros from plantan where sigla = ' + '''' + xsigla + '''');
end;

procedure TTPlantillaAnalisisClinicos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  nomeclatura.conectar;
  nbu.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not tabref.Active then tabref.Open;
    if not tsol.Active then tsol.Open;
    if (l = nil) then loadList;
  end;
  Inc(conexiones);
end;

procedure TTPlantillaAnalisisClinicos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  nomeclatura.desconectar;
  nbu.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(tabref);
    datosdb.closeDB(tsol);
  end;
end;

{===============================================================================}

function plantanalisis: TTPlantillaAnalisisClinicos;
begin
  if xplantanalisis = nil then
    xplantanalisis := TTPlantillaAnalisisClinicos.Create;
  Result := xplantanalisis;
end;

{===============================================================================}

initialization

finalization
  xplantanalisis.Free;

end.
