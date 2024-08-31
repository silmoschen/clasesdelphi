unit CCTurnosVicentin;

interface

uses CCHistoriaDieteticaVicentin, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CAtencionPacientes_Vicentin;

type

TTurnos = class
  turnos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarTurno(xfecha, xitems: String): Boolean;
  procedure   RegistrarTurno(xfecha, xitems, xhora, xcodpac, xnombre, xmotivo, xtelefono, xtt, xatencion: String; xdebe: Real; xcantitems: Integer);
  function    setTurnos(xfecha: String): TStringList;
  procedure   ListarTurnos(xfecha, xmaniana_tarde, xtitulo1, xtitulo2, xtitulo3: String; salida: char);
  procedure   ListarResumenTurnos(xdesde, xhasta, xtitulo1, xtitulo2, xtitulo3: String; salida: char);
  procedure   EstablecerHoras(xhoram1, xhoram2, xhorat1, xhorat2: String);
  procedure   getHoras;
  procedure   BorrarTurnos(xfecha: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  listam: array[1..60, 1..31] of String;
  listat: array[1..60, 1..31] of String;
  archivo: TextFile;
  HoraM1, HoraM2, HoraT1, HoraT2: String;
end;

function turnospac: TTurnos;

implementation

var
  xturnospac: TTurnos = nil;

constructor TTurnos.Create;
begin
  turnos         := datosdb.openDB('turnos', '');
end;

destructor TTurnos.Destroy;
begin
  inherited Destroy;
end;

function  TTurnos.BuscarTurno(xfecha, xitems: String): Boolean;
// Objetivo...: Buscar Turno
begin
  Result := datosdb.Buscar(turnos, 'fecha', 'items', utiles.sExprFecha2000(xfecha), xitems);
end;

procedure TTurnos.RegistrarTurno(xfecha, xitems, xhora, xcodpac, xnombre, xmotivo, xtelefono, xtt, xatencion: String; xdebe: Real; xcantitems: Integer);
// Objetivo...: Registrar Turnos
begin
  turnos.Open;
  if BuscarTurno(xfecha, xitems) then turnos.Edit else turnos.Append;
  turnos.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  turnos.FieldByName('items').AsString    := xitems;
  turnos.FieldByName('hora').AsString     := xhora;
  turnos.FieldByName('codpac').AsString   := xcodpac;
  turnos.FieldByName('nombre').AsString   := xnombre;
  turnos.FieldByName('opcion').AsString   := xmotivo;
  turnos.FieldByName('telefono').AsString := xtelefono;
  turnos.FieldByName('atencion').AsString := xatencion;
  turnos.FieldByName('tt').AsString       := xtt;
  turnos.FieldByName('debe').AsFloat      := xdebe;
  try
    turnos.Post
   except
    turnos.Cancel
  end;
  datosdb.closeDB(turnos);
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then datosdb.tranSQL('delete from turnos where fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''' + ' and items > ' + '''' + xitems + '''');
end;

function  TTurnos.setTurnos(xfecha: String): TStringList;
// Objetivo...: Recuperar Turnos
var
  l: TStringList;
  tt: String;
begin
  turnos.Open;
  l := TStringList.Create;
  if BuscarTurno(xfecha, '01') then Begin
    while not turnos.Eof do Begin
      if turnos.FieldByName('fecha').AsString <> utiles.sExprFecha2000(xfecha) then Break;
      if Length(Trim(turnos.FieldByName('tt').AsString)) > 0 then tt := turnos.FieldByName('tt').AsString else tt := 'M';
      l.Add(turnos.FieldByName('items').AsString + turnos.FieldByName('hora').AsString + turnos.FieldByName('codpac').AsString + turnos.FieldByName('nombre').AsString + ';1' + turnos.FieldByName('opcion').AsString + ';2' + utiles.FormatearNumero(turnos.FieldByName('debe').AsString) + ';3' + turnos.FieldByName('telefono').AsString + ';4' + tt + turnos.FieldByName('atencion').AsString);
      turnos.Next;
    end;
  end;
  turnos.Close;
  Result := l;
end;

procedure TTurnos.ListarTurnos(xfecha, xmaniana_tarde, xtitulo1, xtitulo2, xtitulo3: String; salida: char);
var
  f, lm: Boolean;
  nombre: String;
Begin
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
  if Length(Trim(xtitulo1)) > 0 then List.Titulo(0, 0, xtitulo1, 1, 'Arial, normal, 9');
  if Length(Trim(xtitulo2)) > 0 then List.Titulo(0, 0, xtitulo2, 1, 'Arial, normal, 8');
  if Length(Trim(xtitulo3)) > 0 then List.Titulo(0, 0, xtitulo3, 1, 'Arial, normal, 8');
  List.Titulo(0, 0, 'Turnos para el día - ' + (FormatDateTime( 'dddd, d "de" mmmm "del" yyyy', StrToDate(xfecha))), 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Hora', 1, 'Arial, cursiva, 9');
  List.Titulo(12, list.Lineactual, 'Nombre del Paciente', 2, 'Arial, cursiva, 9');
  List.Titulo(49, list.Lineactual, 'Mot.', 3, 'Arial, cursiva, 9');
  List.Titulo(60, list.Lineactual, 'Debe', 4, 'Arial, cursiva, 9');
  List.Titulo(90, list.Lineactual, 'Teléfono', 5, 'Arial, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  turnos.Open;
  if BuscarTurno(xfecha, '01') then Begin
    while not turnos.Eof do Begin
      lm := False;
      if xmaniana_tarde = 'X' then lm := True;
      if xmaniana_tarde = 'M' then
        if Copy(turnos.FieldByName('hora').AsString, 1, 2) <= '14' then lm := True;
      if xmaniana_tarde = 'T' then
        if Copy(turnos.FieldByName('hora').AsString, 1, 2) >= '15' then lm := True;
      if lm then Begin
        if turnos.FieldByName('fecha').AsString <> utiles.sExprFecha2000(xfecha) then Break;
        list.Linea(0, 0, turnos.FieldByName('hora').AsString, 1, 'Arial, normal, 9', salida, 'N');
        if turnos.FieldByName('codpac').AsString = '00000' then nombre := turnos.FieldByName('nombre').AsString else historiadiet.getDatos(turnos.FieldByName('codpac').AsString);
        list.Linea(12, list.Lineactual, nombre, 2, 'Arial, normal, 9', salida, 'N');
        list.Linea(50, list.Lineactual, turnos.FieldByName('opcion').AsString, 3, 'Arial, normal, 9', salida, 'N');
        list.importe(65, list.Lineactual, '', turnos.FieldByName('debe').AsFloat, 4, 'Arial, normal, 9');
        list.Linea(80, list.Lineactual, turnos.FieldByName('telefono').AsString, 5, 'Arial, normal, 9', salida, 'S');
        list.Linea(0, 0, '................................................................................................................................................................................................................................................', 1, 'Arial, normal, 9', salida, 'S');
        f := True;
      end;
      turnos.Next;
    end;
  end;
  turnos.Close;

  if not f then list.Linea(0, 0, 'No hay Turnos Otorgados !' , 1, 'Arial, normal, 10', salida, 'S');
  list.CompletarPagina;
  list.FinList;
end;

procedure TTurnos.ListarResumenTurnos(xdesde, xhasta, xtitulo1, xtitulo2, xtitulo3: String; salida: char);
var
  f: Boolean;
  l1: array[1..31] of String;
  l2: array[1..31] of String;
  m1: array[1..31] of String;
  m2: array[1..31] of String;
  i, p, t, n, maxm, maxt, x: Integer;
Begin
  For i := 1 to 31 do
    For p := 1 to 25 do Begin
      listam[i, p] := '';
      listat[i, p] := '';
    end;
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
  if Length(Trim(xtitulo1)) > 0 then List.Titulo(0, 0, xtitulo1, 1, 'Arial, normal, 9');
  if Length(Trim(xtitulo2)) > 0 then List.Titulo(0, 0, xtitulo2, 1, 'Arial, normal, 8');
  if Length(Trim(xtitulo3)) > 0 then List.Titulo(0, 0, xtitulo3, 1, 'Arial, normal, 8');
  List.Titulo(0, 0, 'Resumen Turnos Semana: ' + xdesde + ' al ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Lunes', 1, 'Arial, cursiva, 9');
  List.Titulo(22, list.Lineactual, 'Martes', 2, 'Arial, cursiva, 9');
  List.Titulo(44, list.Lineactual, 'Miércoles', 3, 'Arial, cursiva, 9');
  List.Titulo(66, list.Lineactual, 'Jueves', 4, 'Arial, cursiva, 9');
  List.Titulo(88, list.Lineactual, 'Viernes', 5, 'Arial, cursiva, 9');
  List.Titulo(0, 0, xdesde, 1, 'Arial, cursiva, 9');
  List.Titulo(22, list.Lineactual, utiles.FechaSumarDias(xdesde, 1), 2, 'Arial, cursiva, 9');
  List.Titulo(44, list.Lineactual, utiles.FechaSumarDias(xdesde, 2), 3, 'Arial, cursiva, 9');
  List.Titulo(66, list.Lineactual, utiles.FechaSumarDias(xdesde, 3), 4, 'Arial, cursiva, 9');
  List.Titulo(88, list.Lineactual, utiles.FechaSumarDias(xdesde, 4), 5, 'Arial, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  turnos.Open;
  datosdb.Filtrar(turnos, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  while not turnos.Eof do Begin
    atencionpac.getDatos(turnos.FieldByName('atencion').AsString);
    if Copy(turnos.FieldByName('hora').AsString, 1, 2) <= '14' then Begin
      // Rastreamos el 1º Turno - Mañana
      if Length(Trim(Copy(turnos.FieldByName('codpac').AsString, 1, 2))) > 0 then Begin
        if Length(Trim(l1[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))])) = 0 then l1[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'M' + turnos.FieldByName('hora').AsString;
        // 2º Turno
        l2[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'M' + turnos.FieldByName('hora').AsString + '  ' + UpperCase(Copy(atencionpac.descrip, 1, 6));
      end;
      // Detalle de turnos
      if Length(Trim(Copy(turnos.FieldByName('codpac').AsString, 1, 2))) > 0 then Begin
        for n := 1 to 50 do
          if Length(Trim(listam[n, StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))])) = 0 then Break;
        listam[n, StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'M' + turnos.FieldByName('hora').AsString + '  ' + turnos.FieldByName('nombre').AsString;
        if n > maxm then maxm := n;
      end;
    end;
    if Copy(turnos.FieldByName('hora').AsString, 1, 2) > '15' then Begin
      // Rastreamos el 1º Turno - Tarde
      if Length(Trim(Copy(turnos.FieldByName('codpac').AsString, 1, 2))) > 0 then Begin
        if Length(Trim(m1[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))])) = 0 then m1[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'T' + Copy(turnos.FieldByName('fecha').AsString, 7, 2) + turnos.FieldByName('hora').AsString;
        // 2º Turno
        m2[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'T' + Copy(turnos.FieldByName('fecha').AsString, 7, 2) + turnos.FieldByName('hora').AsString + '  ' + UpperCase(Copy(atencionpac.descrip, 1, 6));
      end;
      // Detalle de turnos
      if Length(Trim(Copy(turnos.FieldByName('codpac').AsString, 1, 2))) > 0 then Begin
        for n := 1 to 50 do
          if Length(Trim(listat[n, StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))])) = 0 then Break;
        listat[n, StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'T' + turnos.FieldByName('hora').AsString + '  ' + turnos.FieldByName('nombre').AsString;
        if n > maxt then maxt := n;
      end;
    end;
    turnos.Next;
  end;
  datosdb.QuitarFiltro(turnos);
  turnos.Close;

  t := 0;               // 1º Linea Mañana
  For i := 1 to 5 do Begin
    if i = 1 then p := StrToInt(Copy(xdesde, 1, 2)) else
      p := StrToInt(Copy(xdesde, 1, 2)) + (i-1);

    // Ajustamos el día
    if p > StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4))) then
      p := p - StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4)));

    if i = 1 then Begin
      if Copy(l1[p], 1, 1) = 'M' then list.Linea(0, 0, Trim(Copy(l1[p], 2, 12)) + '-' + TrimLeft(Copy(l2[p], 2, 15)), 1, 'Arial, negrita, 9', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'N');
    end else Begin
      t := t + 22;
      if Copy(l1[p], 1, 1) = 'M' then list.Linea(t, list.Lineactual, Trim(Copy(l1[p], 2, 12)) + '-' + TrimLeft(Copy(l2[p], 2, 15)), i, 'Arial, negrita, 9', salida, 'N') else list.Linea(0, 0, '', i, 'Arial, negrita, 9', salida, 'N');
    end;
  end;
  list.Linea(t+5, list.Lineactual, '', i+1, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  //----------------------------------------------------------------------------

  for x := 1 to maxm do Begin // Detalle Turnos Mañana
    t := 0;
    For i := 1 to 5 do Begin
      if i = 1 then p := StrToInt(Copy(xdesde, 1, 2)) else
        p := StrToInt(Copy(xdesde, 1, 2)) + (i-1);

      // Ajustamos el día
      if p > StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4))) then
        p := p - StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4)));

      if i = 1 then Begin
        if Copy(listam[x, p], 1, 1) = 'M' then list.Linea(0, 0, Copy(listam[x, p], 2, 27), 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      end else Begin
        t := t + 22;
        if Copy(listam[x, p], 1, 1) = 'M' then list.Linea(t, list.Lineactual, Copy(listam[x, p], 2, 27), i, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', i, 'Arial, normal, 8', salida, 'N');
      end;

      list.Linea(t+15, list.Lineactual, '', i+1, 'Arial, normal, 9', salida, 'S');
    end;
  end;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  //----------------------------------------------------------------------------

  t := 0;               // 1º Linea Tarde
  For i := 1 to 5 do Begin
    if i = 1 then p := StrToInt(Copy(xdesde, 1, 2)) else
      p := StrToInt(Copy(xdesde, 1, 2)) + (i-1);

    // Ajustamos el día
    if p > StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4))) then
      p := p - StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4)));

    if i = 1 then Begin
      if Copy(m1[p], 1, 1) = 'T' then list.Linea(0, 0, Trim(Copy(m1[p], 4, 12)) + '-' + TrimLeft(Copy(m2[p], 4, 15)), 1, 'Arial, negrita, 9', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'N');
    end else Begin
      t := t + 22;
      if Copy(m1[p], 1, 1) = 'T' then list.Linea(t, list.Lineactual, Trim(Copy(m1[p], 4, 12)) + '-' + TrimLeft(Copy(m2[p], 4, 15)), i, 'Arial, negrita, 9', salida, 'N') else list.Linea(0, 0, '', i, 'Arial, negrita, 9', salida, 'N');
    end;
  end;
  list.Linea(t+15, list.Lineactual, '', i+1, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  //----------------------------------------------------------------------------

  for x := 1 to maxt do Begin // Detalle Turnos Tarde
    t := 0;
    For i := 1 to 5 do Begin
      if i = 1 then p := StrToInt(Copy(xdesde, 1, 2)) else
        p := StrToInt(Copy(xdesde, 1, 2)) + (i-1);

      // Ajustamos el día
      if p > StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4))) then
        p := p - StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4)));

      if i = 1 then Begin
        if Copy(listat[x, p], 1, 1) = 'T' then list.Linea(0, 0, Copy(listat[x, p], 2, 27), 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      end else Begin
        t := t + 22;
        if Copy(listat[x, p], 1, 1) = 'T' then list.Linea(t, list.Lineactual, Copy(listat[x, p], 2, 27), i, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', i, 'Arial, normal, 8', salida, 'N');
      end;

      list.Linea(t+15, list.Lineactual, '', i+1, 'Arial, normal, 9', salida, 'S');
    end;
  end;

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

  //----------------------------------------------------------------------------

  list.FinList;
end;

procedure TTurnos.EstablecerHoras(xhoram1, xhoram2, xhorat1, xhorat2: String);
// Objetivo...: cerrar tablas de persistencia
begin
  AssignFile(archivo, dbs.DirSistema + '\ctrlhoras.ini');
  Rewrite(archivo);
  WriteLn(archivo, xhoram1);
  WriteLn(archivo, xhoram2);
  WriteLn(archivo, xhorat1);
  WriteLn(archivo, xhorat2);
  closeFile(archivo);
end;

procedure TTurnos.getHoras;
// Objetivo...: cerrar tablas de persistencia
begin
  if FileExists(dbs.DirSistema + '\ctrlhoras.ini') then Begin
    AssignFile(archivo, dbs.DirSistema + '\ctrlhoras.ini');
    Reset(archivo);
    ReadLn(archivo, horam1);
    ReadLn(archivo, horam2);
    ReadLn(archivo, horat1);
    ReadLn(archivo, horat2);
    closeFile(archivo);
  end;
end;

procedure TTurnos.BorrarTurnos(xfecha: String);
// Objetivo...: Borrar turnos
Begin
  datosdb.tranSQL('delete from turnos where fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  datosdb.refrescar(turnos);
end;

procedure TTurnos.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not turnos.Active then turnos.Open;
  end;
  Inc(conexiones);
  historiadiet.conectarHD;
  atencionpac.conectar;
end;

procedure TTurnos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closedb(turnos);
  end;
  historiadiet.desconectarHD;
  atencionpac.desconectar;
end;

{===============================================================================}

function turnospac: TTurnos;
begin
  if xturnospac = nil then
    xturnospac := TTurnos.Create;
  Result := xturnospac;
end;

{===============================================================================}

initialization

finalization
  xturnospac.Free;

end.
