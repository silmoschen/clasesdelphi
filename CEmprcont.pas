unit CEmprcont;

interface

uses CDefViasCont, CVias, SysUtils, DB, DBTables, CBDT, CIDBFM, DepurarVias, Forms, FileCtrl, CUtiles;

type

TTDefEmprCont = class(TObject)            // Superclase
  nomvia, rsocial, clave: string;
  emprcont, selempr: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xvia: string): boolean;
  procedure   Grabar(xvia, xrsocial, xclave: string); overload;
  procedure   Borrar(xvia: string); overload;
  procedure   getDatos(xvia: string);
  procedure   Depurar(tipo: char; xdir: string);
  function    setEmprCont: TQuery;

  procedure   HabilitarSel;
  procedure   QuitarSel;

  procedure   Grabar(xcodemp, xclave, xrsocial1, xnomvia, xcuit, xcodpfis: string); overload;
  procedure   Borrar; overload;

  procedure   conectar;
  procedure   desconectar;
private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function defemprcont: TTDefEmprCont;

implementation

var
  xdefemprcont: TTDefEmprCont = nil;

constructor TTDefEmprCont.Create;
begin
  emprcont := datosdb.openDB('emprcont', 'via');
  selempr := datosdb.openDB('elemcont', '');
end;

destructor TTDefEmprCont.Destroy;
begin
  inherited Destroy;
end;

function TTDefEmprCont.Buscar(xvia: string): boolean;
// Objetivo...: Buscar una empresa
begin
  if emprcont.FindKey([xvia]) then Result := True else Result := False;
end;

procedure TTDefEmprCont.Borrar(xvia: string);
// Objetivo...: Borrar empresa
begin
  emprcont.Delete;
end;

procedure TTDefEmprCont.Grabar(xvia, xrsocial, xclave: string);
// Objetivo...: Grabar atributos
begin
  if Buscar(xvia) then emprcont.Edit else emprcont.Append;
  emprcont.FieldByName('via').AsString     := xvia;
  emprcont.FieldByName('rsocial').AsString := xrsocial;
  emprcont.FieldByName('clave').AsString   := xclave;
  try
    emprcont.Post;
  except
    emprcont.Cancel;
  end;
end;

procedure TTDefEmprCont.getDatos(xvia: string);
// Objetivo...: Recuperar los atributos para una empresa dada
begin
  if Buscar(xvia) then
    begin
      nomvia  := emprcont.FieldByName('via').AsString;
      rsocial := emprcont.FieldByName('rsocial').AsString;
      clave   := emprcont.FieldByName('clave').AsString;
    end
  else
    begin
      nomvia := ''; rsocial := ''; clave := '';
    end;
end;

procedure TTDefEmprCont.Depurar(tipo: char; xdir: string);
// Objetivo...: Eliminar la Información de una Empresa (Directorio)
var
  directorio, archivo: string; j, limite: integer; F: File; dd: boolean;
begin
  via.conectar; dd := False;
  directorio := via.getVia1 + '\' + xdir;
  // Activamos los Archivos del Directorio de la Vía Seleccionada
  if DirectoryExists(directorio) then Begin
    fmDepurarVias.FileListBox1.Directory := directorio;

    // Eliminamos los Archivos
    limite := fmDepurarVias.FileListBox1.Items.Count;
    For j := 1 to limite do
      begin
        archivo := directorio + '\' + fmDepurarVias.FileListBox1.Items[j - 1];
        if FileExists(archivo) then
          begin
            AssignFile(F, archivo);
            Reset(F);
            CloseFile(F);
            Erase(F);
            dd := True;
          end;
      end;

      // Si el Usuario Seleccionó Eliminar la Vía procedemos ...
      if (tipo = 'T') and (dd) then
        begin
          // Subimos un Nivel para Eliminar el Directorio ...
          fmDepurarVias.FileListBox1.Directory := '..';

          ChDir('\');
          RmDir(directorio);          // Eliminamos el Directorio - Vía

          defviacont.Borrar(xdir);
        end
      else
        defviacont.DesocuparVia(xdir);
    end;

  if (tipo = 'T') and (dd) then defviacont.Borrar(xdir) else defviacont.DesocuparVia(xdir);
  Borrar(xdir);
  if selempr.FieldByName('codemp').AsString = xdir then selempr.Delete;
end;

procedure TTDefEmprCont.HabilitarSel;
// Objetivo...: Activar campo sel
begin
  emprcont.FieldByName('Sel').Visible := True;
end;

procedure TTDefEmprCont.QuitarSel;
// Objetivo...: Desactivar campo sel
begin
  emprcont.FieldByName('Sel').Visible := False;
end;

function TTDefEmprCont.setEmprCont: TQuery;
// Objetivo...: Retornar un set con las empresas definidas
begin
  Result := datosdb.tranSQL('SELECT * FROM emprcont');
end;

// Rutinas que manejan la elección de la empresa
procedure TTDefEmprCont.Grabar(xcodemp, xclave, xrsocial1, xnomvia, xcuit, xcodpfis: string);
begin
  if selempr.RecordCount > 0 then selempr.Edit else selempr.Append;
  selempr.FieldByName('codemp').AsString   := xcodemp;
  selempr.FieldByName('clave').AsString    := xclave;
  selempr.FieldByName('rsocial1').AsString := xrsocial1;
  selempr.FieldByName('nomvia').AsString   := xnomvia;
  selempr.FieldByName('cuit').AsString     := xcuit;
  selempr.FieldByName('codpfis').AsString  := xcodpfis;
  try
    selempr.Post;
  except
    selempr.Cancel;
  end;
end;

procedure TTDefEmprCont.Borrar;
// Objetivo...: borrar atributo(s)
begin
  if selempr.RecordCount > 0 then selempr.Delete;
end;


procedure TTDefEmprCont.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    defviacont.conectar;
    if not emprcont.Active then emprcont.Open;
    emprcont.FieldByName('via').DisplayLabel := 'Vía'; emprcont.FieldByName('rsocial').DisplayLabel := 'Empresa';
    emprcont.FieldByName('seleccion').Visible := False;
    emprcont.FieldByName('clave').Visible := False;
    if not selempr.Active then selempr.Open;
    nomvia   := selempr.FieldByName('nomvia').AsString;
    getDatos(nomvia);
  end;
  Inc(conexiones);
end;

procedure TTDefEmprCont.desconectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    defviacont.desconectar;
    datosdb.closeDB(emprcont);
    datosdb.closeDB(selempr);
  end;
end;

{===============================================================================}

function defemprcont: TTDefEmprCont;
begin
  if xdefemprcont = nil then
    xdefemprcont := TTDefEmprCont.Create;
  Result := xdefemprcont;
end;

{===============================================================================}

initialization

finalization
  xdefemprcont.Free;

end.