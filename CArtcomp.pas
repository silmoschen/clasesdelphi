unit CArtcomp;

interface

uses CArtic, SysUtils, DB, DBTables, CIDBFM, CListar, CUtiles;

type

TTArtcomp = class(TTArticulos)            // Superclase
  codartcomp, codartindi, Descrip, codrubro, codmarca: string;
  tabla1, tabla2: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodartcomp, xdescrip, xcodrubro, xcodmarca: string);
  destructor  Destroy; override;

  function    getCodartcomp: string;
  function    getDescrip   : string;
  function    getCodrubro  : string;
  function    getCodmarca  : string;

  procedure   Grabar(xcodartcomp, xDescrip, xcodrubro, xcodmarca: string);
  procedure   GrabarSet(xcodartcomp, xcodartindi: string);
  procedure   BorrarArt(xcodartcomp: string);
  function    BuscarArt(xcodartcomp: string): boolean;
  function    BuscarArtindi(xcodartcomp, xcodartpack: string): boolean;
  function    BorrarArtindi(xcodartcomp, xcodartpack: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcodartcomp: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida, tl: char);
  procedure   conectar;
  procedure   desconectar;

  function    rSetPack(xcodartcomp: string): TQuery;
 private
  { Declaraciones Privadas }
  procedure ListLinea(salida, tlist: char);
end;

function artcomp: TTArtcomp;

implementation

var
  xartcomp: TTArtcomp = nil;

constructor TTArtcomp.Create(xcodartcomp, xdescrip, xcodrubro, xcodmarca: string);
begin
  inherited Create('',  '', '', '', '', '', '', '', '', '', '', 0);
  codartcomp := xcodartcomp;
  descrip    := xdescrip;
  codrubro   := xcodrubro;
  codmarca   := xcodmarca;
  codrubro   := xcodrubro;
  codmarca   := xcodmarca;
  tabla1     := datosdb.openDB('artcomp.DB', 'codartcomp');
  tabla2     := datosdb.openDB('setartic.DB', 'Codartcomp;Codartindi');
end;

destructor TTArtcomp.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTArtcomp.getCodartcomp: string;
begin
  Result := codartcomp;
end;

function TTArtcomp.getDescrip: string;
begin
  Result := descrip;
end;

function TTArtcomp.getCodrubro: string;
begin
  Result := codrubro;
end;

function TTArtcomp.getCodmarca: string;
begin
  Result := codmarca;
end;

procedure TTArtcomp.Grabar(xcodartcomp, xdescrip, xcodrubro, xcodmarca: string);
begin
  if BuscarArt(xcodartcomp) then tabla1.Edit else tabla1.Append;
  tabla1.FieldByName('codartcomp').Value := xcodartcomp;
  tabla1.FieldByName('descrip').Value    := xdescrip;
  tabla1.FieldByName('codrubro').Value   := xcodrubro;
  tabla1.FieldByName('codmarca').Value   := xcodmarca;
  try
    tabla1.Post;
  except
    tabla1.Cancel;
  end;
end;

procedure TTArtcomp.GrabarSet(xcodartcomp, xcodartindi: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarArtIndi(xcodartcomp, xcodartindi) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('codartcomp').Value := xcodartcomp;
  tabla2.FieldByName('codartindi').Value := xcodartindi;
  try
    tabla2.Post;
  except
    tabla2.Cancel;
  end;
end;

procedure TTArtcomp.BorrarArt(xcodartcomp: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarArt(xcodartcomp) then
    begin
      tabla1.Delete;       // Articulo
      datosdb.tranSQL('DELETE FROM setartic.DB WHERE codartcomp = ' + '''' + xcodartcomp + '''');
      getDatos(tabla1.FieldByName('codartcomp').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTArtcomp.BorrarArtindi(xcodartcomp, xcodartpack: string): boolean;
// Objetivo...: Borrar un Artículo de la Lista
begin
  if BuscarArtindi(xcodartcomp, xcodartpack) then
    begin
      tabla2.Delete;
      Result := True;
    end
  else
    Result := False;
end;

function TTArtcomp.BuscarArt(xcodartcomp: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla1.FindKey([xcodartcomp]) then Result := True else Result := False;
end;

function TTArtcomp.BuscarArtindi(xcodartcomp, xcodartpack: string): boolean;
// Objetivo...: Buscar Artículo Individual
begin
  Result := datosdb.Buscar(tabla2, 'codartcomp', 'codartindi', xcodartcomp, xcodartpack);
end;

procedure  TTArtcomp.getDatos(xcodartcomp: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarArt(xcodartcomp) then
    begin
      codartcomp := tabla1.FieldByName('codartcomp').AsString;
      descrip    := tabla1.FieldByName('descrip').AsString;
      codrubro   := tabla1.FieldByName('codrubro').AsString;
      codmarca   := tabla1.FieldByName('codmarca').AsString;
    end
   else
    begin
      codartcomp := ''; descrip := ''; codrubro := ''; codmarca := '';
    end;
end;

function TTArtcomp.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla1.Last;
  Result := IntToStr(tabla1.FieldByName('codartcomp').AsInteger + 1);
end;

procedure TTArtcomp.conectar;
// Objetivo...: conectar tabla1s de persistencia
begin
  inherited conectar;
  if not tabla1.Active then tabla1.Open;
  tabla1.FieldByName('codartcomp').DisplayLabel := 'Cód.'; tabla1.FieldByName('descrip').DisplayLabel := 'Descripción';
  if not tabla2.Active then tabla2.Open;
end;

procedure TTArtcomp.desconectar;
// Objetivo...: desconectar tabla1s de persistencia
begin
  inherited desconectar;
  if tabla1.Active then
    begin
      tabla1.Refresh; tabla1.Close;
    end;
  if tabla2.Active then
    begin
      tabla2.Refresh; tabla2.Close;
    end;
end;

function TTArtcomp.rSetPack(xcodartcomp: string): TQuery;
// Objetivo...: Devolver el Set de Artículos que componen el Pack
begin
  datosdb.tranSQL('SELECT codartindi, articulo FROM setartic.DB, articulo.DB WHERE Codartcomp = ' + '''' + xcodartcomp + '''' + ' AND codartindi = codart');
  datosdb.setSQL.Open;
  datosdb.setSQL.FieldByName('codartindi').DisplayLabel := 'Cód. Art.'; datosdb.setSQL.FieldByName('articulo').DisplayLabel := 'Descripción';
  Result := datosdb.setSQL;
end;

procedure TTArtcomp.Listar(orden, iniciar, finalizar, ent_excl: string; salida, tl: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla1.IndexName := tabla1.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Artículos Compuestos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód. Art.' + utiles.espacios(10) +  'Artículo', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla1.First;
  while not tabla1.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla1.FieldByName('codartcomp').AsString >= iniciar) and (tabla1.FieldByName('codartcomp').AsString <= finalizar) then ListLinea(salida, tl);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla1.FieldByName('codartcomp').AsString < iniciar) or (tabla1.FieldByName('codartcomp').AsString > finalizar) then ListLinea(salida, tl);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla1.FieldByName('descrip').AsString >= iniciar) and (tabla1.FieldByName('descrip').AsString <= finalizar) then ListLinea(salida, tl);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla1.FieldByName('descrip').AsString < iniciar) or (tabla1.FieldByName('descrip').AsString > finalizar) then ListLinea(salida, tl);

      tabla1.Next;
    end;
    List.FinList;

    tabla1.IndexFieldNames := tabla1.IndexFieldNames;
    tabla1.First;
end;

procedure TTArtcomp.ListLinea(salida, tlist: char);
// Objetivo...: Listar Datos de Provincias
var
  r: TQuery; f: string; i: integer;
begin
  if tlist = '1' then f := 'Arial, negrita, 9' else f := 'Arial, normal, 8';
  List.Linea(0, 0, tabla1.FieldByName('codartcomp').AsString, 1, f, salida, 'N');
  List.Linea(10, list.lineactual, tabla1.FieldByName('descrip').AsString, 2, f, salida, 'S');
  if tlist = '1' then   // Incluye detalle del articulo compuestos
    begin               // Emisión del detalle
      r := rSetPack(tabla1.FieldByName('codartcomp').AsString);
      r.Open; r.First; i := 0;
      while not r.EOF do
        begin
          List.Linea(0, 0, '     ' + r.FieldByName('codartindi').AsString, 1, 'Arial, normal, 8', salida, 'N');
          List.Linea(20, list.lineactual, r.FieldByName('articulo').AsString, 2, 'Arial, normal, 8', salida, 'S');
          Inc(i);
          r.Next;
        end;
      r.Close; r.Free;
      List.Linea(0, 0, '   ', 1, 'Arial, normal, 5', salida, 'S');
      List.Linea(0, 0, 'Centidad de Artículos :  ' + IntToStr(i), 1, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, '   ', 1, 'Arial, normal, 5', salida, 'S');
    end;
end;

{===============================================================================}

function artcomp: TTArtcomp;
begin
  if xartcomp = nil then
    xartcomp := TTArtcomp.Create('', '', '', '');
  Result := xartcomp;
end;

{===============================================================================}

initialization

finalization
  xartcomp.Free;

end.
