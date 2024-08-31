unit CPlanillaHorariosPersonal;

interface

uses CPersonalCtrlHorarios, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM, Classes;

const
  elementos = 4;

type

TTPlanillaHorariosPersonal = class
  Nrodoc, Fecha, Turno, Entrada, Salida, HoraCambioDeTurno: String;
  horarios: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnrodoc, xfecha, xturno: String): Boolean;
  procedure   Registrar(xnrodoc, xfecha, xturno, xentrada_salida, xhora: String);
  procedure   Borrar(xnrodoc, xfecha, xturno: String);
  procedure   getDatos(xnrodoc, xfecha, xturno: String);
  procedure   ListarPlanillaHorarios(xdfecha, xhfecha: String; perSel: TStringList; salida: Char);
  procedure   ListarPlanillaResumen(xdfecha, xhfecha: String; perSel: TStringList; salida: Char);

  function    DetalleRegistro(xnrodoc, xperiodo: String): TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  entsalida : array[1..elementos, 1..4] of String;
  totdias: Integer;
  tothoras: Array[1..3] of Integer;
  archivo: TextFile;
  procedure   DatosPersonal(xnrodoc: String; salida: char);
  procedure   listLinea(xfechaanter: String; salida: char);
  procedure   listResumen(salida: char);
end;

function horario: TTPlanillaHorariosPersonal;

implementation

var
  xhorario: TTPlanillaHorariosPersonal = nil;

constructor TTPlanillaHorariosPersonal.Create;
var
  h: String;
begin
  horarios := datosdb.openDB('horarios', '');
  HoraCambioDeTurno := '13:00';
  if FileExists('initurno.ini') then Begin
    AssignFile(archivo, 'initurno.ini');
    Reset(archivo);
    ReadLn(archivo, h);
    HoraCambioDeTurno := h;
    CloseFile(archivo);
  end;
end;

destructor TTPlanillaHorariosPersonal.Destroy;
begin
  inherited Destroy;
end;

function TTPlanillaHorariosPersonal.Buscar(xnrodoc, xfecha, xturno: String): Boolean;
// Objetivo...: Buscar una Instancia
Begin
  Result := datosdb.Buscar(horarios, 'Nrodoc', 'Fecha', 'Turno', xnrodoc, utiles.sExprFecha2000(xfecha), xturno);
end;

procedure TTPlanillaHorariosPersonal.Registrar(xnrodoc, xfecha, xturno, xentrada_salida, xhora: String);
// Objetivo...: Registrar la entrada
Begin
  if Buscar(xnrodoc, xfecha, xturno) then horarios.Edit else horarios.Append;
  horarios.FieldByName('nrodoc').AsString  := xnrodoc;
  horarios.FieldByName('fecha').AsString   := utiles.sExprFecha2000(xfecha);
  horarios.FieldByName('turno').AsString   := xturno;
  if xentrada_salida = 'E' then horarios.FieldByName('entrada').AsString := xhora else horarios.FieldByName('salida').AsString  := xhora;
  try
    horarios.Post
   except
    horarios.Cancel
  end;
end;

procedure TTPlanillaHorariosPersonal.Borrar(xnrodoc, xfecha, xturno: String);
// Objetivo...: Borrar una Instancia
Begin
  if Buscar(xnrodoc, xfecha, xturno) then horarios.Delete;
end;

procedure TTPlanillaHorariosPersonal.getDatos(xnrodoc, xfecha, xturno: String);
// Objetivo...: Borrar una Instancia
Begin
  if Buscar(xnrodoc, xfecha, xturno) then Begin
    nrodoc  := horarios.FieldByName('nrodoc').AsString;
    fecha   := utiles.sFormatoFecha(horarios.FieldByName('nrodoc').AsString);
    turno   := horarios.FieldByName('turno').AsString;
    entrada := horarios.FieldByName('entrada').AsString;
    salida  := horarios.FieldByName('salida').AsString;
  end else Begin
    entrada := ''; salida := '';
  end;
end;

procedure TTPlanillaHorariosPersonal.ListarPlanillaHorarios(xdfecha, xhfecha: String; perSel: TStringList; salida: Char);
// Objetivo...: Listar Planilla de Horarios
var
  fechaanter: String;
  j, k: Integer;
  r, t: TQuery;
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Planilla de Horarios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(15, list.Lineactual, 'Entrada', 2, 'Arial, cursiva, 8');
  List.Titulo(25, list.Lineactual, 'Salida', 3, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'Entrada', 4, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, 'Salida', 5, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Firma', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  conectar;
  //horarios.IndexFieldNames := 'Nrodoc';

  r := personal.setPersonalAlf;
  r.Open;
  while not r.Eof do Begin
    if utiles.verificarItemsLista(perSel, r.FieldByName('nrodoc').AsString) then Begin
      DatosPersonal(r.FieldByName('nrodoc').AsString, salida);

      horarios.FindKey([r.FieldByName('nrodoc').AsString]);
      //datosdb.Filtrar(horarios, 'nrodoc = ' + '"' + r.FieldByName('nrodoc').AsString + '"');

      t := datosdb.tranSQL('select * from horarios where nrodoc = ' + '"' + r.FieldByName('nrodoc').AsString + '"');
      t.Open;
      totdias := 0; tothoras[1] := 0; tothoras[2] := 0; tothoras[3] := 0; entsalida[1, 1] := ''; entsalida[1, 2] := ''; entsalida[1, 3] := ''; entsalida[1, 4] := '';
      fechaanter := t.FieldByName('fecha').AsString;
      while not t.EOF do Begin
        if (t.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (t.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then Begin
          if t.FieldByName('fecha').AsString <> fechaanter then Begin
            listLinea(fechaanter, salida);
            For j := 1 to elementos do
              For k := 1 to 4 do entsalida[j, k] := '';
            fechaanter := t.FieldByName('fecha').AsString;
          end;

          if t.FieldByName('turno').AsString = 'M' then Begin
            entsalida[1, 1] := t.FieldByName('entrada').AsString;
            entsalida[1, 2] := t.FieldByName('salida').AsString;
          end;
          if t.FieldByName('turno').AsString = 'T' then Begin
            entsalida[1, 3] := t.FieldByName('entrada').AsString;
            entsalida[1, 4] := t.FieldByName('salida').AsString;
          end;
        end;
        t.Next;
      end;

      listLinea(fechaanter, salida);
      listResumen(salida);
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
      t.Close; t.Free;
    end;

    r.Next;
  end;

  //horarios.IndexFieldNames := 'Nrodoc;Fecha;Turno';
  desconectar;
  list.FinList;
end;

procedure TTPlanillaHorariosPersonal.DatosPersonal(xnrodoc: String; salida: char);
// Objetivo...: Listar datos personales del personal
Begin
  personal.getDatos(xnrodoc);
  if salida = 'P' then list.Linea(0, 0, xnrodoc + '   ' + personal.nombre, 1, 'Arial, negrita, 9, clNavy', salida, 'S') else list.Linea(0, 0, xnrodoc + '   ' + personal.nombre, 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
end;

procedure TTPlanillaHorariosPersonal.listLinea(xfechaanter: String; salida: char);
// Objetivo...: Listar Detalle de horas trabajadas
begin
  if (Length(Trim(entsalida[1, 1])) > 0) or (Length(Trim(entsalida[1, 2])) > 0) or (Length(Trim(entsalida[1, 3])) > 0) or (Length(Trim(entsalida[1, 4])) > 0) then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, utiles.sFormatoFecha(xfechaanter), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(15, list.Lineactual, entsalida[1, 1], 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(25, list.Lineactual, entsalida[1, 2], 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(40, list.Lineactual, entsalida[1, 3], 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, entsalida[1, 4], 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(75, list.Lineactual, '......................................................................', 6, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    end;
    Inc(totdias);
    if (Length(Trim(entsalida[1, 1])) > 0) and (Length(Trim(entsalida[1, 2])) > 0) then Begin
      utiles.difHoras(entsalida[1, 1], entsalida[1, 2]);
      tothoras[1] := tothoras[1] + StrToInt(utiles.getHoras);
      tothoras[2] := tothoras[2] + StrToInt(utiles.getMinutos);
      tothoras[3] := tothoras[3] + StrToInt(utiles.getSegundos);
    end;
    if (Length(Trim(entsalida[1, 3])) > 0) and (Length(Trim(entsalida[1, 4])) > 0) then Begin
      utiles.difHoras(entsalida[1, 3], entsalida[1, 4]);
      tothoras[1] := tothoras[1] + StrToInt(utiles.getHoras);
      tothoras[2] := tothoras[2] + StrToInt(utiles.getMinutos);
      tothoras[3] := tothoras[3] + StrToInt(utiles.getSegundos);
    end;
  end;
end;

procedure TTPlanillaHorariosPersonal.listResumen(salida: char);
// Objetivo...: Listar Resumen de horas
Begin
  if totdias > 0 then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Horas trabajadas:  ' + utiles.sLlenarIzquierda(IntToStr(tothoras[1]), 2, '0') + ':' + utiles.sLlenarIzquierda(IntToStr(tothoras[2]), 2, '0') + ':' + utiles.sLlenarIzquierda(IntToStr(tothoras[3]), 2, '0'), 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(40, list.Lineactual, 'Días trabajados: ', 2, 'Arial, negrita, 8', salida, 'N');
    list.importe(60, list.Lineactual, '####', StrToFloat(IntToStr(totdias)), 3, 'Arial, negrita, 8');
    list.Linea(97, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
  end;
end;

procedure TTPlanillaHorariosPersonal.ListarPlanillaResumen(xdfecha, xhfecha: String; perSel: TStringList; salida: Char);
// Objetivo...: Listar Planilla Resumen
var
  fechaanter: String;
  j, k: Integer;
  r, t: TQuery;
  vhora, vminuto, vsegundo: Real;
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Resumen de Horas Trabajadas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nro.Doc.', 1, 'Arial, cursiva, 8');
  List.Titulo(12, list.Lineactual, 'Nombre', 2, 'Arial, cursiva, 8');
  List.Titulo(55, list.Lineactual, 'Hs.Trab.', 3, 'Arial, cursiva, 8');
  List.Titulo(67, list.Lineactual, 'Días Trab.', 4, 'Arial, cursiva, 8');
  List.Titulo(92, list.Lineactual, 'Importe', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  conectar;
  horarios.IndexFieldNames := 'Nrodoc;Fecha';

  r := personal.setPersonalAlf;
  r.Open;
  while not r.Eof do Begin
    if utiles.verificarItemsLista(perSel, r.FieldByName('nrodoc').AsString) then Begin
      t := datosdb.tranSQL('select * from horarios where nrodoc = ' + '"' + r.FieldByName('nrodoc').AsString + '"' + ' AND fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"');
      t.Open;
      t.First; totdias := 0; tothoras[1] := 0; tothoras[2] := 0; tothoras[3] := 0; entsalida[1, 1] := ''; entsalida[1, 2] := ''; entsalida[1, 3] := ''; entsalida[1, 4] := '';
      fechaanter := t.FieldByName('fecha').AsString;
      while not t.EOF do Begin
        if t.FieldByName('fecha').AsString <> fechaanter then Begin
          listLinea(fechaanter, 'X');
          For j := 1 to elementos do
            For k := 1 to 4 do entsalida[j, k] := '';
          fechaanter := t.FieldByName('fecha').AsString;
        end;

        if t.FieldByName('turno').AsString = 'M' then Begin
          entsalida[1, 1] := t.FieldByName('entrada').AsString;
          entsalida[1, 2] := t.FieldByName('salida').AsString;
        end;
        if t.FieldByName('turno').AsString = 'T' then Begin
          entsalida[1, 3] := t.FieldByName('entrada').AsString;
          entsalida[1, 4] := t.FieldByName('salida').AsString;
        end;

        t.Next;

      end;

      listLinea(fechaanter, 'X');

      personal.getDatos(r.FieldByName('nrodoc').AsString);
      vhora    := personal.salario;
      vminuto  := vhora / 60;
      vsegundo := vminuto / 60;

      utiles.ArreglarHora(inttostr(tothoras[1]) + ':' + inttostr(tothoras[2]) + ':' + inttostr(tothoras[3]));

      list.Linea(0, 0, r.FieldByName('nrodoc').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(12, list.Lineactual,  personal.nombre, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(55, list.Lineactual, IntToStr(utiles.totHoras) + ':' + IntToStr(utiles.totMinutos) + ':' + IntToStr(utiles.totSegundos) , 3, 'Arial, negrita, 8', salida, 'N');
      list.importe(72, list.Lineactual, '####', StrToFloat(IntToStr(totdias)), 4, 'Arial, negrita, 8');
      list.importe(97, list.Lineactual, '', ((utiles.totHoras * vhora) + (utiles.totMinutos * vminuto) + (utiles.totSegundos * vsegundo)), 5, 'Arial, negrita, 8');
      list.Linea(98, list.Lineactual, ' ', 6, 'Arial, negrita, 8', salida, 'S');

      t.Close; t.Free;
    end;

    r.Next;
  end;

  desconectar;
  list.FinList;
end;

function  TTPlanillaHorariosPersonal.DetalleRegistro(xnrodoc, xperiodo: String): TQuery;
// Objetivo...: Devolver un detalle con las llamadas registradas
var
  di, df: String;
Begin
  di := Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '01';
  df := utiles.ultFechaMes(Copy(xperiodo, 1, 2), Copy(xperiodo, 4, 4));
  Result := datosdb.tranSQL('SELECT * FROM horarios WHERE nrodoc = ' + '"' + xnrodoc + '"' + ' AND fecha >= ' + '"' + di + '"' + ' AND fecha <= ' + '"' + df + '"');
end;

procedure TTPlanillaHorariosPersonal.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then
    if not horarios.Active then horarios.Open;
  Inc(conexiones);
  personal.conectar;
end;

procedure TTPlanillaHorariosPersonal.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then
    datosdb.closeDB(horarios);
  personal.desconectar;
end;

{===============================================================================}

function horario: TTPlanillaHorariosPersonal;
begin
  if xhorario = nil then
    xhorario := TTPlanillaHorariosPersonal.Create;
  Result := xhorario;
end;

{===============================================================================}

initialization

finalization
  xhorario.Free;

end.
