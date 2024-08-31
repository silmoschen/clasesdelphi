unit CFabrica;

interface

uses SysUtils, DB, DBTables, tablas,
     CPersona, CVendedor;

type

//******************************************************************************
TTFabrica = class(TObject)            // Superclase
  Fabrica : string;
 public
  { Declaraciones Públicas }
  vendedor: TTVendedor;
  constructor Crear;
  procedure   CrearVendedor;

  {function    getCodigo: string;
  function    getNombre: string;
  function    getDomicilio: string;
  function    getCodpost: string;
  function    getOrden: string;

  function    Grabar(tabla: TTable): boolean;
  function    Borrar(tabla: TTable; cod: string): boolean;
  function    Buscar(tabla: TTable; cod: string): boolean;
  function    Nuevo(tabla: TTable): string;
  procedure   getDatos(tabla: TTable; cod: string);}
 private
  { Declaraciones Privadas }
end;

implementation

constructor TTFabrica.Crear;
begin
  Fabrica  := 'Fabrica';
end;

procedure TTFabrica.CrearVendedor;
begin
  vendedor := TTVendedor.Crear('', '', '', '', '', '', '');
end;

end.
