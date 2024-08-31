unit CCodpostDBExpress;

interface

uses SysUtils, CProvinDBExpress, CListar, CUtiles, DBClient, CdbExpressBase;

type

TTCodpost = class(TObject)            // Superclase
  cp, orden, localidad, codprovin, desprovin, calle, altura: string;
  tabla: TClientDataSet;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcp, xorden, xlocalidad, xcodprovin, xcalle, xaltura: string);
  procedure   Borrar(xcp, xorden: string);
  function    Buscar(xcp, xorden: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcp, xorden: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorLocalidad(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   list_linea(salida: char);
end;

function cpost: TTCodpost;

implementation

var
  xcpost: TTCodpost = nil;

constructor TTCodpost.Create;
begin
  inherited Create;
  tabla := dbEx.conn.InstanciarTabla('codpost');
end;

destructor TTCodpost.Destroy;
begin
  inherited Destroy;
end;

procedure TTCodpost.Grabar(xcp, xorden, xlocalidad, xcodprovin, xcalle, xaltura: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcp, xorden) then tabla.Edit else tabla.Append;
  tabla.FieldByName('cp').Value        := xcp;
  tabla.FieldByName('orden').Value     := xorden;
  tabla.FieldByName('localidad').Value := xlocalidad;
  tabla.FieldByName('codprovin').Value := xcodprovin;
  tabla.FieldByName('calle').Value     := xcalle;
  tabla.FieldByName('altura').Value    := xaltura;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  tabla.ApplyUpdates(-1);
end;

procedure TTCodpost.Borrar(xcp, xorden: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcp, xorden) then
    begin
      tabla.Delete;
      tabla.ApplyUpdates(-1);
      getDatos(tabla.FieldByName('cp').AsString, tabla.FieldByName('orden').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTCodpost.Buscar(xcp, xorden: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if conexiones = 0 then conectar;
  if tabla.IndexFieldNames <> 'cp;orden' then tabla.IndexFieldNames := 'cp;orden';
  Result := dbEx.conn.Buscar(tabla, 'cp', 'orden', xcp, xorden);
end;

procedure  TTCodpost.getDatos(xcp, xorden: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcp, xorden) then
    begin
      cp        := tabla.FieldByName('cp').AsString;
      orden     := tabla.FieldByName('orden').AsString;
      localidad := tabla.FieldByName('localidad').AsString;
      codprovin := tabla.FieldByName('codprovin').AsString;
      calle     := tabla.FieldByName('calle').AsString;
      altura    := tabla.FieldByName('altura').AsString;

      provincia.getDatos(codprovin);    // Instaciamos los Atributos de la Clase Provincia
      desprovin := provincia.Provincia;
    end
   else
    begin
      cp := ''; orden := ''; localidad := ''; codprovin := ''; calle := ''; altura := ''; desprovin := '';
    end;
end;

function TTCodPost.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla.Last;
  Result := IntToStr(tabla.FieldByName('cp').AsInteger + 1);
end;

procedure TTCodpost.list_linea(salida: char);
// Objetivo...: Linea de Impresión
begin
  List.Linea(0, 0, tabla.FieldByName('cp').AsString + ' ' + tabla.FieldByName('orden').AsString + '   ' + tabla.FieldByName('localidad').AsString, 1, 'Courier New, normal, 8', salida, 'S');
  List.Linea(45, List.lineactual, tabla.FieldByName('codprovin').AsString + ' ' + provincia.Provincia, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(66, List.lineactual, tabla.FieldByName('calle').AsString, 3, 'Courier New, normal, 8', salida, 'N');
  List.Linea(93, List.lineactual, tabla.FieldByName('altura').AsString, 4, 'Courier New, normal, 8', salida, 'S');
end;

procedure TTCodpost.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Códigos Postales', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód. Orden' + utiles.espacios(2) +  'Localidad', 1, 'Courier New, cursiva, 8');
  List.Titulo(45, List.lineactual, 'CP Provincia', 2, 'Courier New, cursiva, 8');
  List.Titulo(66, List.lineactual, 'Calle', 3, 'Courier New, cursiva, 8');
  List.Titulo(93, List.lineactual, 'Altura', 2, 'Courier New, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      if provincia.Buscar(tabla.FieldByName('codprovin').AsString) then provincia.getDatos(tabla.FieldByName('codprovin').AsString);
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('cp').AsString >= iniciar) and (tabla.FieldByName('cp').AsString <= finalizar) then list_linea(salida);

      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('cp').AsString < iniciar) or (tabla.FieldByName('cp').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('localidad').AsString >= iniciar) and (tabla.FieldByName('localidad').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('localidad').AsString < iniciar) or (tabla.FieldByName('localidad').AsString > finalizar) then List_linea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCodpost.BuscarPorCodigo(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'cp;orden' then tabla.IndexFieldNames := 'cp;orden';
  dbEx.conn.BuscarEnFormaContextual(tabla, 'cp', 'orden', Copy(xexpr, 1, 4), Copy(xexpr, 5, 3));
end;

procedure TTCodpost.BuscarPorLocalidad(xexpr: string);
begin
  tabla.IndexFieldNames := 'Localidad';
  tabla.FindNearest([xexpr]);
end;

procedure TTCodpost.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  provincia.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('cp').DisplayLabel := 'CP'; tabla.FieldByName('orden').DisplayLabel := 'Orden'; tabla.FieldByName('localidad').DisplayLabel := 'Localidad'; tabla.FieldByName('codprovin').DisplayLabel := 'CP'; tabla.FieldByName('calle').DisplayLabel := 'Calle'; tabla.FieldByName('altura').DisplayLabel := 'Altura';
  end;
  Inc(conexiones);
end;

procedure TTCodpost.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  provincia.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then dbEx.conn.closeDB(tabla);
end;

{===============================================================================}

function cpost: TTCodpost;
begin
  if xcpost = nil then
    xcpost := TTCodpost.Create;
  Result := xcpost;
end;

{===============================================================================}

initialization

finalization

  xcpost.Free;

end.
