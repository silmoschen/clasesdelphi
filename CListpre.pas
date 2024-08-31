unit CListpre;

interface

//uses CListpsimples,
uses CArtic, CContArc, CVias, SysUtils, DB, DBTables, CIDBFM;

type

TTNominaListPre = class(TObject)            // Superclase
  lista, estado, precio1, precio2, precio3, precio4, precio5, precio6, precio7: string;
  interes, intplista: real;
  ref1, ref11: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xlista, xestado: string);
  destructor  Destroy; override;

  function    getLista: string;
  function    getEstado: string;
  function    getPrecio1: string;
  function    getPrecio2: string;
  function    getPrecio3: string;
  function    getPrecio4: string;
  function    getPrecio5: string;
  function    getPrecio6: string;
  function    getPrecio7: string;
  function    getInteres: real;
  function    getIntPlista: real;

  procedure   GrabarRL(xlista, xestado: string);
  procedure   BorrarRL(xlista: string);
  function    BuscarRL(xlista: string): boolean;
  procedure   getDatosRL(xlista: string);
  function    setListasRL: TQuery;
  procedure   BajaListaRL(arch: string);
  function    VerificarListaRL(lista: string): string;
  function    FormarNombreListaRL(s: string): string;
  function    CopiarListaRL(l1, l2: string): string;
  procedure   FijarIdNombrePreciosRL(xlista, xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: string);
  procedure   FijarInteresRL(xlista: string; xinteres1: real);
  procedure   FijarIntplistaRL(xlista: string; xintplista: real);
  function    ActivarListaRL(lista: string): string;
 private
  { Declaraciones Privadas }
end;

function nlist: TTNominaListPre;

implementation

var
  xnlist: TTNominaListPre = nil;

constructor TTNominaListPre.Create(xlista, xestado: string);
begin
  Inherited Create;
  lista  := xlista;
  estado := xestado;
end;

destructor TTNominaListPre.Destroy;
begin
  Inherited Destroy;
end;

function TTNominaListPre.getLista: string;
// Objetivo....: Retornar Cod. marca
begin
  Result := lista;
end;

function TTNominaListPre.getPrecio1: string;
begin
  Result := precio1;
end;

function TTNominaListPre.getPrecio2: string;
begin
  Result := precio2;
end;

function TTNominaListPre.getPrecio3: string;
begin
  Result := precio3;
end;

function TTNominaListPre.getPrecio4: string;
begin
  Result := precio4;
end;

function TTNominaListPre.getPrecio5: string;
begin
  Result := precio5;
end;

function TTNominaListPre.getPrecio6: string;
begin
  Result := precio6;
end;

function TTNominaListPre.getPrecio7: string;
begin
  Result := precio7;
end;

function TTNominaListPre.getInteres: real;
begin
  Result := interes;
end;

function TTNominaListPre.getIntPLista: real;
begin
  Result := intplista;
end;

function TTNominaListPre.setListasRL: TQuery;
// Objetivo....: Retornar un recordSet con las Listas Definidas
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + ref1.TableName);
end;

function TTNominaListPre.getEstado: string;
// Objetivo...: Retornar Descripción
begin
  Result := estado;
end;

procedure TTNominaListPre.GrabarRL(xlista, xestado: string);
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
end;

procedure TTNominaListPre.BorrarRL(xlista: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarRL(xlista) then
    begin
      ref1.Delete;
      getDatosRL(ref1.FieldByName('lista').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTNominaListPre.BuscarRL(xlista: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if ref1.FindKey([xlista]) then Result := True else Result := False;
end;

procedure  TTNominaListPre.getDatosRL(xlista: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarRL(xlista) then
    begin
      lista     := ref1.FieldByName('lista').AsString;
      estado    := ref1.FieldByName('estado').AsString;
      precio1   := ref1.FieldByName('precio1').AsString;
      precio2   := ref1.FieldByName('precio2').AsString;
      precio3   := ref1.FieldByName('precio3').AsString;
      precio4   := ref1.FieldByName('precio4').AsString;
      precio5   := ref1.FieldByName('precio5').AsString;
      precio6   := ref1.FieldByName('precio6').AsString;
      precio7   := ref1.FieldByName('precio7').AsString;
      interes   := ref1.FieldByName('interes').AsFloat;
      intPlista := ref1.FieldByName('intplista').AsFloat;
    end
   else
    begin
      lista := ''; estado := ''; precio1 := ''; precio2 := ''; precio3 := ''; precio4 := ''; precio5 := ''; precio6 := ''; precio7 := ''; interes := 0; intplista := 0;
    end;
end;

procedure TTNominaListPre.BajaListaRL(arch: string);
//Objetivo...: Baja de Listas de Precios, id y ref1 asociada
var
  v, l, t: string;
begin
  v := via.getVia1;      // Path de ref1s
  l := arch;
  arch := FormarNombreListaRL(arch);
  if FileExists(v + '\arch\' + arch + '.*') then
    begin
      t    := arch;
      arch := arch + '.db';
      datosdb.tranSQL('DROP INDEX ' + '''' + t + '''' + '.descrip');
      datosdb.tranSQL('DROP INDEX ' + '''' + t + '''' + '.PRIMARY');
      datosdb.tranSQL('DROP TABLE ' + '''' + arch + '''');
    end;
    BorrarRL(l);
end;

function TTNominaListPre.VerificarListaRL(lista: string): string;
var
  v, l: string;
begin
  v := via.getVia1;      // Path de ref1s
  l := lista;
  Lista := FormarNombreListaRL(lista);
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

function TTNominaListPre.FormarNombreListaRL(s: string): string;
// Objetivo...: Formar un Nombre de Archivo
var
  n: string;
  i: integer;
begin
  For i := 1 to Length(s) do
     if Length(trim(Copy(s, i, 1))) > 0 then n := n + Copy(s, i, 1) else n := n + '_';
  Result := n;
end;

function TTNominaListPre.CopiarListaRL(l1, l2: string): string;
// Objetivo...: Duplicar Listas
begin
end;

procedure TTNominaListPre.FijarIdNombrePreciosRL(xlista, xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: string);
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
end;

function TTNominaListPre.ActivarListaRL(lista: string): string;
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

procedure TTNominaListPre.FijarInteresRL(xlista: string; xinteres1: real);
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
end;

procedure TTNominaListPre.FijarIntplistaRL(xlista: string; xintplista: real);
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
end;

{===============================================================================}

function nlist: TTNominaListPre;
begin
  if xnlist = nil then
    xnlist := TTNominaListPre.Create('', '');
  Result := xnlist;
end;

{===============================================================================}

initialization

finalization
  xnlist.Free;

end.
