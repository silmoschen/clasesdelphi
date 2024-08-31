unit CPreverCostos;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTCostosPrever = class
   Desde, Hasta, Descrip, Carencia: String;
   Costo, Plus, Adicional, Estudiantes: Real;
   tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xdesde: String): Boolean;
  procedure   Guardar(xdesde, xhasta, xdescrip, xcarencia: String; xcosto, xplus, xestudiantes, xadicional: Real);
  procedure   getDatos(xdesde: String);
  procedure   Borrar(xdesde: String);

  procedure   BuscarPorCodigo(xexpresion: String);
  procedure   BuscarPorNombre(xexpresion: String);

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

   function   setMontoAPagar(xedad: String): Real;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function costogrupo: TTCostosPrever;

implementation

var
  xcostogrupo: TTCostosPrever = nil;

constructor TTCostosPrever.Create;
begin
  tabla := datosdb.openDB('costos', '', '', dbs.DirSistema + '\sepelio')
end;

function  TTCostosPrever.Buscar(xdesde: String): Boolean;
// Objetivo...: Buscar una Instancia
Begin
  if tabla.IndexFieldNames <> 'Desde' then tabla.IndexFieldNames := 'Desde';
  Result := tabla.FindKey([xdesde]);
end;

procedure TTCostosPrever.Guardar(xdesde, xhasta, xdescrip, xcarencia: String; xcosto, xplus, xestudiantes, xadicional: Real);
// Objetivo...: Guardar una Instancia
Begin
  if Buscar(xdesde) then tabla.Edit else tabla.Append;
  tabla.FieldByName('desde').AsString      := xdesde;
  tabla.FieldByName('hasta').AsString      := xhasta;
  tabla.FieldByName('descrip').AsString    := xdescrip;
  tabla.FieldByName('carencia').AsString   := xcarencia;
  tabla.FieldByName('costo').AsFloat       := xcosto;
  tabla.FieldByName('plus').AsFloat        := xplus;
  tabla.FieldByName('plus').AsFloat        := xplus;
  tabla.FieldByName('estudiantes').AsFloat := xestudiantes;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTCostosPrever.getDatos(xdesde: String);
// Objetivo...: Recuperar una Instancia
Begin
  if Buscar(xdesde) then Begin
    desde       := tabla.FieldByName('desde').AsString;
    hasta       := tabla.FieldByName('hasta').AsString;
    descrip     := tabla.FieldByName('descrip').AsString;
    carencia    := tabla.FieldByName('carencia').AsString;
    costo       := tabla.FieldByName('costo').AsFloat;
    plus        := tabla.FieldByName('plus').AsFloat;
    adicional   := tabla.FieldByName('adicional').AsFloat;
    estudiantes := tabla.FieldByName('estudiantes').AsFloat;
  end else Begin
    desde := ''; hasta := ''; descrip := ''; carencia := ''; costo := 0; plus := 0; adicional := 0; estudiantes := 0;
  end;
end;

procedure TTCostosPrever.Borrar(xdesde: String);
Begin
  if Buscar(xdesde) then tabla.Delete;
  datosdb.refrescar(tabla);
end;

destructor TTCostosPrever.Destroy;
begin
  inherited Destroy;
end;

procedure TTCostosPrever.BuscarPorCodigo(xexpresion: String);
Begin
  if tabla.IndexFieldNames <> 'Desde' then tabla.IndexFieldNames := 'Desde';
  tabla.FindNearest([xexpresion]);
end;

procedure TTCostosPrever.BuscarPorNombre(xexpresion: String);
Begin
  if tabla.IndexFieldNames <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpresion]);
end;

procedure TTCostosPrever.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  {if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;
  list_Tit(salida);

  tabla.First;
  while not tabla.EOF do Begin
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('idtitular').AsString >= iniciar) and (tperso.FieldByName('idtitular').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('idtitular').AsString < iniciar) or (tperso.FieldByName('idtitular').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;}
end;

function TTCostosPrever.setMontoAPagar(xedad: String): Real;
// Objetivo...: Devolver el monto a pagar
Begin
  tabla.First; Result := 0; Plus := 0;
  while not tabla.Eof do Begin
    if (xedad >= tabla.FieldByName('desde').AsString) and (xedad <= tabla.FieldByName('hasta').AsString) then Begin
      Result      := tabla.FieldByName('costo').AsFloat;
      Plus        := tabla.FieldByName('plus').AsFloat;
      Adicional   := tabla.FieldByName('adicional').AsFloat;
      Estudiantes := tabla.FieldByName('estudiantes').AsFloat;
      Break;
    end;
    tabla.Next;
  end;
end;

procedure TTCostosPrever.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('adicional').DisplayLabel := 'M.21(NE)'; tabla.FieldByName('estudiantes').DisplayLabel := 'Estudiantes';
  end;
  Inc(conexiones);
end;

procedure TTCostosPrever.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    if tabla.Active then tabla.Close;
  end;
end;

{===============================================================================}

function costogrupo: TTCostosPrever;
begin
  if xcostogrupo = nil then
    xcostogrupo := TTCostosPrever.Create;
  Result := xcostogrupo;
end;

{===============================================================================}

initialization

finalization
  xcostogrupo.Free;

end.
