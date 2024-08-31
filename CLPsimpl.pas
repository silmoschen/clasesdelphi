unit CLPsimpl;

interface

uses CArtic, CLPrecio, SysUtils, DB, DBTables, CIDBFM;

type

TTLPreciosSimples = class(TTListaPrecios)            // Superclase
  constructor Create(xcodart, xdescrip: string; xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: real);
  destructor  Destroy; override;

  procedure   Listar_r(orden, iniciar, finalizar, ent_excl: string; salida: char; lp, tit: string);
  procedure   Listar_m(orden, iniciar, finalizar, ent_excl: string; salida: char; lp, tit: string);

  function    getTArticulo: TTable;
  procedure   CambiarLista(l: string);
 private
  { Declaraciones Privadas }
end;

function presimples: TTLPreciosSimples;

implementation

var
  xprecios: TTLPreciosSimples = nil;

constructor TTLPreciosSimples.Create(xcodart, xdescrip: string; xprecio1, xprecio2, xprecio3, xprecio4, xprecio5, xprecio6, xprecio7: real);
begin
  inherited Create;
  tabla := datosdb.openDB('precios', 'codart');
  ref1  := datosdb.openDB('listprec', 'lista');
  ref11 := datosdb.openDB('precios', 'codart');
end;

destructor TTLPreciosSimples.Destroy;
begin
  inherited Destroy;
end;

procedure TTLPreciosSimples.CambiarLista(l: string);
// Objetivo...: cambiar la lista de precios
begin
  tabla.Close;
  tabla.TableName := l;
  tabla.Open;
end;

procedure TTLPreciosSimples.Listar_r(orden, iniciar, finalizar, ent_excl: string; salida: char; lp, tit: string);
// Objetivo...: Listar Articulos con Nivel de Ruptura por Rubro
begin
  if orden = 'C' then
    r := datosdb.tranSQL('SELECT ' + lp + '.Codart, articulo.articulo, articulo.codrubro, rubros.descrip, codmarca, Precio1, Precio2, Precio3, Precio4, Precio5, Precio6, Precio7 FROM ' + lp + ' , articulo, rubros WHERE articulo.Codrubro = rubros.Codrubro AND ' + lp + '.Codart ' + ' = articulo.Codart ORDER BY articulo.codrubro, articulo.articulo, articulo.codmarca')
  else
    r := datosdb.tranSQL('SELECT ' + lp + '.codart, articulo.articulo, articulo.codrubro, rubros.descrip, codmarca, precio1, precio2, precio3, precio4, precio5, precio6, precio7 FROM ' + lp + ' , articulo, rubros WHERE articulo.codrubro = rubros.codrubro AND ' + lp + '.codart ' + ' = articulo.codart ORDER BY rubros.descrip, articulo.articulo, articulo.codmarca');
  inherited Listar_r(orden, iniciar, finalizar, ent_excl, salida, lp, tit);
end;

procedure TTLPreciosSimples.Listar_m(orden, iniciar, finalizar, ent_excl: string; salida: char; lp, tit: string);
// Objetivo...: Listar Precios con Nivel de Ruptura por Marca
begin
  if orden = 'C' then
    r := datosdb.tranSQL('SELECT ' + lp + '.Codart, articulo.Articulo, articulo.Codmarca, marcas.Descrip, precio1, precio2, precio3, precio4, precio5, precio6, precio7 FROM ' + lp + ' , articulo, marcas WHERE articulo.Codmarca = marcas.Codmarca AND ' + lp + '.Codart ' + ' = articulo.Codart ORDER BY articulo.Codmarca, articulo.Articulo')
  else
    r := datosdb.tranSQL('SELECT ' + lp + '.Codart, articulo.Articulo, articulo.Codmarca, marcas.Descrip, precio1, precio2, precio3, precio4, precio5, precio6, precio7 FROM ' + lp + ' , articulo, marcas WHERE articulo.Codmarca = marcas.Codmarca AND ' + lp + '.Codart ' + ' = articulo.Codart ORDER BY marcas.Descrip, articulo.Articulo');
    inherited Listar_m(orden, iniciar, finalizar, ent_excl, salida, lp, tit);
end;

function TTLPreciosSimples.getTArticulo: TTable;
// Objetivo...: Devolver la tabla de Artículos
begin
  Result := artic.tabla;
end;

{===============================================================================}

function presimples: TTLPreciosSimples;
begin
  if xprecios = nil then
    xprecios := TTLPreciosSimples.Create('', '', 0, 0, 0, 0, 0, 0, 0);
  Result := xprecios;
end;

{===============================================================================}

initialization

finalization
  xprecios.Free;

end.
