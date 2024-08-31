unit CStock;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM, CArtSim;

type

TTStock = class(TObject)            // Superclase
  idcompr, tipo, sucursal, numero, clipro, codart, items, tipomovi, fecha: string;
  cantidad, precio: real;
  tstock: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xidcompr, xtipo, xsucursal, xnumero, xclipro, xcodart, xitems, xtipomovi, xfecha: string; xcantidad, xprecio: real);
  destructor  Destroy; override;

  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xclipro, xcodart, xitems, xtipomovi, xfecha: string; xcantidad, xprecio: real);
  procedure   Borrar(xidcompr, xtipo, xsucursal, xnumero, xclipro, xtipomovi: string);
  function    Buscar(xidcompr, xtipo, xsucursal, xnumero, xclipro, xcodart, xitems, xtipomovi: string): boolean;

  procedure   refrescar;
  procedure   vaciarBuffer;
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  stockanter: real;
end;

function stock: TTStock;

implementation

var
  xstock: TTStock = nil;

constructor TTStock.Create(xidcompr, xtipo, xsucursal, xnumero, xclipro, xcodart, xitems, xtipomovi, xfecha: string; xcantidad, xprecio: real);
begin
  inherited Create;
  idcompr  := xidcompr;
  tipo     := xtipo;
  sucursal := xnumero;
  clipro   := xclipro;
  codart   := xcodart;
  tipomovi := xtipomovi;
  items    := xitems;
  fecha    := xfecha;
  cantidad := xcantidad;
  precio   := xprecio;

  tstock   := datosdb.openDB('stock', 'Idcompr;Tipo;Sucursal;Numero;Clipro;Codart;Items;Tipomovi');
end;

destructor TTStock.Destroy;
begin
  inherited Destroy;
end;

procedure TTStock.Grabar(xidcompr, xtipo, xsucursal, xnumero, xclipro, xcodart, xitems, xtipomovi, xfecha: string; xcantidad, xprecio: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  art.getDatos(xcodart);      // Buscamos el artículo asociado
  stockanter := art.Stock; // Extraemos el stock actual

  if Buscar(xidcompr, xtipo, xsucursal, xnumero, xclipro, xcodart, xitems, xtipomovi) then
    begin
      if xtipomovi = '1' then stockanter := stockanter - tstock.FieldByName('cantidad').AsFloat;
      if xtipomovi = '2' then stockanter := stockanter + tstock.FieldByName('cantidad').AsFloat;
      tstock.Edit;
    end
  else
    tstock.Append;
  tstock.FieldByName('idcompr').AsString  := xidcompr;
  tstock.FieldByName('tipo').AsString     := xtipo;
  tstock.FieldByName('sucursal').AsString := xsucursal;
  tstock.FieldByName('numero').AsString   := xnumero;
  tstock.FieldByName('clipro').AsString   := xclipro;
  tstock.FieldByName('codart').AsString   := xcodart;
  tstock.FieldByName('items').AsString    := xitems;
  tstock.FieldByName('tipomovi').AsString := xtipomovi;
  tstock.FieldByName('fecha').AsString    := utiles.sExprFecha(xfecha);
  tstock.FieldByName('cantidad').AsFloat  := xcantidad;
  tstock.FieldByName('precio').AsFloat    := xprecio;
  try
    tstock.Post;
  except
    tstock.Cancel;
  end;

  if xtipomovi = '1' then stockanter := stockanter + xcantidad; // Armamos la existencia actual
  if xtipomovi = '2' then stockanter := stockanter - xcantidad;
  art.ActualizarStock(xcodart, stockanter);
end;

procedure TTStock.Borrar(xidcompr, xtipo, xsucursal, xnumero, xclipro, xtipomovi: string);
// Objetivo...: Eliminar un Objeto
var
  r: TQuery; st: real;
begin
  r := datosdb.tranSQL('SELECT * FROM stock WHERE idcompr = ' + '''' + xidcompr + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''' + ' AND clipro = ' + '''' + xclipro + '''' + ' AND tipomovi = ' + '''' + xtipomovi + '''');  // Extraemos el set de registros para actualizar la existencia
  r.Open; r.First;
  while not r.EOF do
    begin
      art.getDatos(r.FieldByName('codart').AsString);
      st := art.Stock;
      if xtipomovi = '1' then st := st - r.FieldByName('cantidad').AsFloat;
      if xtipomovi = '2' then st := st + r.FieldByName('cantidad').AsFloat;
      art.ActualizarStock(r.FieldByName('codart').AsString, st);
      r.Next;
    end;
  r.Close; r.Free;

  datosdb.tranSQL('DELETE FROM stock WHERE idcompr = ' + '''' + xidcompr + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''' + ' AND clipro = ' + '''' + xclipro + '''' + ' AND tipomovi = ' + '''' + xtipomovi + '''');
end;

function TTStock.Buscar(xidcompr, xtipo, xsucursal, xnumero, xclipro, xcodart, xitems, xtipomovi: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := datosdb.Buscar(tstock, 'idcompr', 'tipo', 'sucursal', 'numero', 'clipro', 'codart', 'items', 'tipomovi', xidcompr, xtipo, xsucursal, xnumero, xclipro, xcodart, xitems, xtipomovi);
end;

procedure TTStock.refrescar;
// Objetivo...: refrescar datos
begin
  datosdb.refrescar(tstock);
end;

procedure TTStock.vaciarBuffer;
// Objetivo...: vaciar el buffer
begin
  datosdb.vaciarBuffer(tstock);
end;

procedure TTStock.conectar;
// Objetivo...: conectar tabla de persistencia
begin
  if conexiones = 0 then Begin
    if not tstock.Active then tstock.Open;
    art.conectar;
  end;
  Inc(conexiones);
end;

procedure TTStock.desconectar;
// Objetivo...: desconectar tabla de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tstock);
    art.desconectar;
  end;
end;

{===============================================================================}

function stock: TTStock;
begin
  if xstock = nil then
    xstock := TTStock.Create('', '', '', '', '', '', '', '', '', 0, 0);
  Result := xstock;
end;

{===============================================================================}

initialization

finalization
  xstock.Free;

end.