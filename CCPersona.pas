unit CCPersona;

interface

uses SysUtils, DB, DBTables;

type

//******************************************************************************
TTPersona = class            // Superclase
  codigo, nombre, domicilio, codpost, orden: string;
 public
  { Declaraciones Públicas }
  constructor Crear(xcodigo, xnombre, xdomicilio, xcp, xorden: string);
  function    getCodigo: string;
  function    getNombre: string;
  function    getDomicilio: string;
  function    getCodpost: string;
  function    getOrden: string;
 private
  { Declaraciones Privadas }
  function  Grabar(tabla: TTable): boolean;
  function  Borrar(tabla: TTable; cod: string): boolean;
  function  Buscar(tabla: TTable; cod: string): boolean;
  function  Nuevo(tabla: TTable): string;
  procedure getDatos(tabla: TTable; cod: string);
end;

TTProveedor = class(TTPersona)           // Clase TTProveedor Heredada de Persona
  condiva, nrocuit, telefono: string;
 public
  constructor Crear(cod, nom, dom, cp, ord, cuit, tel, iva: string);
  function getCondiva: string;
  function getNrocuit: string;
end;

TTCliente = class(TTPersona)           // Clase TTCliente Heredada de Persona
  nrocuit   : string;
 public
  constructor Crear(cod, nom, dom, cp, ord, cuit: string);
  function getNrocuit: string;
end;

TTVendedor = class(TTPersona)          // Clase TVendedor Heredada de Persona
  telefono, categoria: string;
  tabla1, tabla2     : TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Crear(t1, t2: TTable; cod, nom, dom, cp, ord, tel, cat: string);
  function  Grabar: boolean;
  function  Borrar(cod: string): boolean;
  function  Buscar(cod: string): boolean;
  procedure getDatos(cod: string);
  function  Nuevo: string;

  function  getTelefono: string;
  function  getCategoria: string;
 private
  { Declaraciones Privadas }
  conexiones: integer;            // Control de conexiones Abiertas
end;

//******************************************************************************
TTArticulo = class            // Superclase
  codart, descrip, codrubro, codmarca, codmedida, un_bulto, cant_bulto, cant_sueltas, nropartida, compuesto, graviva: string;
  puntorep: real;
  Obj_art : TTable;
 public
  { Declaraciones Públicas }
  constructor Crear(tabla: TTable; xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep: real);
  function    getCodart: string;
  function    getDescrip: string;
  function    getCodmedida: string;
  function    getUn_bulto: string;
  function    getCant_bulto: string;
  function    getCant_Sueltas: string;
  function    getNropartida: string;
  function    getCompuesto: string;
  function    getGraviva: string;
  function    getPuntorep: real;

  function  Grabar: boolean;
  function  Borrar(codart: string): boolean;
  function  Buscar(codart: string): boolean;
  function  Nuevo: string;
  procedure getDatos(codart: string);
 private
  { Declaraciones Privadas }
  conexiones: integer;
end;

//******************************************************************************

TTPedido = class                       // Superclase
  nropedido, fecha, codvend, codart: string;
  cantidad: real;
  cPedido, dPedido, Det_Pedido: TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Crear(cPedido, dPedido: TTable; xnropedido, xfecha, xcodvend, xcodart: string; xcantidad: real);
  function  Grabar_Pedido: boolean;
  function  Grabar_Detalle: boolean;
  function  Borrar_Pedido(nrop: string): boolean;
  function  Borrar_Articulo(nrop, codart: string): boolean;
  function  Buscar_Pedido(nrop: string): boolean;
  function  Buscar_Articulo(nrop, codart: string): boolean;

  procedure getDatos_Pedido(nrop: string);
  function  getPedido_Detalle(nrop: string): TTable;
  //function  Nuevo: string;}

  function  getNropedido: string;
  function  getFecha: string;
  function  getCodvend: string;
  function  getCodart: string;
  function  getCantidad: real;
 private
  { Declaraciones Privadas }
  conexiones: integer;            // Control de conexiones Abiertas
end;

implementation

{==============================================================================}
// IMPLEMENTACION de los C O N S T R U C T O R E S de Clase
constructor TTPersona.Crear(xcodigo, xnombre, xdomicilio, xcp, xorden: string);
// Persona - Superclase
begin
  codigo    := xcodigo;
  nombre    := xnombre;
  domicilio := xdomicilio;
  codpost   := xcp;
  orden     := xorden;
end;

constructor TTProveedor.Crear(cod, nom, dom, cp, ord, cuit, tel, iva: string);
// Proveedor - Heredada de Persona
begin
  inherited Crear(cod, nom, dom, cp, ord);  // Constructor de la Superclase
  nrocuit   := cuit;
  telefono  := tel;
  condiva   := iva;
end;

constructor TTCliente.Crear(cod, nom, dom, cp, ord, cuit: string);
// Cliente - Heredada de Persona
begin
  inherited Crear(cod, nom, dom, cp, ord);  // Constructor de la Superclase
  nrocuit   := cuit;
end;

constructor TTVendedor.Crear(t1, t2: TTable; cod, nom, dom, cp, ord, tel, cat: string);
// Vendedor - Heredada de Persona
begin
  inherited Crear(cod, nom, dom, cp, ord);  // Constructor de la Superclase
  telefono  := tel;
  categoria := cat;

  tabla1    := t1;
  tabla2    := t2;
  if conexiones = 0 then
    begin
      tabla1.Open;  // Tablas de Persistencia
      tabla2.Open;
    end;
  Inc(conexiones);  // Control de Conexiones Activas
end;

//******************************************************************************
constructor TTArticulo.Crear(tabla: TTable; xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep: real);
begin
  Obj_art      := tabla;
  codart       := xcodart;
  descrip      := xdescrip;
  codrubro     := xcodrubro;
  codmarca     := xcodmarca;
  codmedida    := xcodmedida;
  un_bulto     := xun_bulto;
  cant_bulto   := xcant_bulto;
  cant_sueltas := xcant_sueltas;
  nropartida   := xnropartida;
  compuesto    := xcompuesto;
  graviva      := xgraviva;
  puntorep     := xpuntorep;

  if conexiones = 0 then tabla.Open;
  Inc(conexiones);
end;

//******************************************************************************
constructor TTPedido.Crear(cPedido, dPedido: TTable; xnropedido, xfecha, xcodvend, xcodart: string; xcantidad: real);
begin
  nropedido := xnropedido;
  fecha     := xfecha;
  codvend   := xcodvend;
  codart    := xcodart;
  cantidad  := xcantidad;

  if conexiones = 0 then
    begin
      cPedido.Open;
      dPedido.Open;
    end;
  Inc(conexiones);
end;

{==============================================================================}

// Metodos de la Superclase Persona
//------------------------------------------------------------------------------
function TTPersona.getCodigo: string;
begin
  Result := codigo;
end;

function TTPersona.getNombre: string;
begin
  Result := nombre;
end;

function TTPersona.getDomicilio: string;
begin
  Result := domicilio;
end;

function TTPersona.getCodpost: string;
begin
  Result := codpost;
end;

function TTPersona.getOrden: string;
begin
  Result := orden;
end;

function TTPersona.Grabar(tabla: TTable): boolean;
// Objetivo...: Grabar Atributos Persona
begin
  try
    if Buscar(tabla, codigo) then tabla.Edit else tabla.Append;
    tabla.Fields[0].Value := codigo;
    tabla.Fields[1].Value := nombre;
    tabla.Fields[2].Value := domicilio;
    tabla.Fields[3].Value := codpost;
    tabla.Fields[4].Value := orden;
    tabla.Post;
    Result := True;
  except
    Result := False;
  end;
end;

function TTPersona.Borrar(tabla: TTable; cod: string): boolean;
//Objetivo...: Eliminar un Objeto de la Superclase Persona
begin
  try
    if Buscar(tabla, cod) then
      begin
        tabla.Delete;
        Result := True;
      end
    except
      Result := False;
    end;
end;

function TTPersona.Buscar(tabla: TTable; cod: string): boolean;
//Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.FindKey([cod]) then Result := True else Result := False;
end;

procedure  TTPersona.getDatos(tabla: TTable; cod: string);
// Objetivo...: Cargar/Inicializar los Atributos de la Superclase
begin
  if Buscar(tabla, cod) then
    begin
      codigo    := tabla.Fields[0].Value;
      nombre    := tabla.Fields[1].Value;
      domicilio := tabla.Fields[2].Value;
      codpost   := tabla.Fields[3].Value;
      orden     := tabla.Fields[4].Value;
    end
   else
    begin
      codigo := ''; nombre := ''; domicilio := ''; codpost := ''; orden := '';
    end;
end;

function TTPersona.Nuevo(tabla: TTable): string;
begin
  tabla.Last;
  Result := IntToStr(tabla.Fields[0].AsInteger + 1);
end;

//------------------------------------------------------------------------------

// Metodos de la Clase Proveedor
//------------------------------------------------------------------------------
function TTProveedor.getNrocuit: string;
begin
  Result := nrocuit;
end;

function TTProveedor.getCondiva: string;
begin
  Result := condiva;
end;

// Métodos de la Clase Cliente
//------------------------------------------------------------------------------

function TTCliente.getNrocuit: string;
begin
  Result := nrocuit;
end;

// Metodos de la Clase Vendedores
//------------------------------------------------------------------------------

function TTVendedor.Grabar: boolean;
// Objetivo...: Grabar Atributos de Vendedores
begin
  try
    if Buscar(codigo) then tabla2.Edit else tabla2.Append;
    tabla2.Fields[0].Value := codigo;
    tabla2.Fields[1].Value := telefono;
    tabla2.Fields[2].Value := categoria;
    tabla2.Post;
    // Actualizamos los Atributos de la Clase Persona
    if inherited Grabar(tabla1) then  //* Metodo de la Superclase
      Result := True;
  except
      Result := False;
  end;
end;

procedure  TTVendedor.getDatos(cod: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  inherited getDatos(tabla1, cod);  // Heredamos de la Superclase
  if Buscar(cod) then
    begin
      telefono  := tabla2.Fields[1].Value;
      categoria := tabla2.Fields[2].Value;
    end
  else
    begin
      telefono := ''; categoria := '';
    end;
end;

function TTVendedor.Borrar(cod: string): boolean;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(cod) then
      begin
        inherited Borrar(tabla1, cod);  // Metodo de la Superclase Persona
        tabla2.Delete;
        Result := True;
      end;
  except
    Result := False;
  end;
end;

function TTVendedor.Buscar(cod: string): boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  try
    if tabla2.FindKey([cod]) then
      begin
        if inherited Buscar(tabla1, cod) then Result := True;  // Método de la Superclase (Sincroniza los Valores de las Tablas)
      end
    else
      Result := False;
  except
    Result := False;
  end;
end;

function TTVendedor.Nuevo: string;
begin
  Result := inherited Nuevo(tabla1);
end;

function TTVendedor.getTelefono: string;
begin
  Result := telefono;
end;

function TTVendedor.getCategoria: string;
begin
  Result := categoria;
end;

// Métodos de la clase Articulo
//------------------------------------------------------------------------------
function TTArticulo.Grabar: boolean;
// Objetivo...: Grabar Atributos de Vendedores
begin
  try
    if Buscar(codart) then Obj_art.Edit else Obj_art.Append;
    Obj_art.Fields[0].Value := codart;
    Obj_art.Fields[1].Value := descrip;
    Obj_art.Fields[2].Value := codrubro;
    Obj_art.Fields[3].Value := codmarca;
    Obj_art.Fields[4].Value := codmedida;
    Obj_art.Fields[5].Value := un_bulto;
    Obj_art.Fields[6].Value := cant_bulto;
    Obj_art.Fields[7].Value := cant_sueltas;
    Obj_art.Fields[8].Value := nropartida;
    Obj_art.Fields[9].Value := compuesto;
    Obj_art.Fields[10].Value := graviva;
    Obj_art.Fields[11].Value := puntorep;
    Obj_art.Post;
    Result := True;
  except
      Result := False;
  end;
end;

procedure TTArticulo.getDatos(codart: string);
// Objetivo...: Cargar/Inicializar los Atributos de la Superclase
begin
  if Buscar(codart) then
    begin
    codart       := Obj_art.Fields[0].Value;
    descrip      := Obj_art.Fields[1].Value;
    codrubro     := Obj_art.Fields[2].Value;
    codmarca     := Obj_art.Fields[3].Value;
    codmedida    := Obj_art.Fields[4].Value;
    un_bulto     := Obj_art.Fields[5].Value;
    cant_bulto   := Obj_art.Fields[6].Value;
    cant_sueltas := Obj_art.Fields[7].Value;
    nropartida   := Obj_art.Fields[8].Value;
    compuesto    := Obj_art.Fields[9].Value;
    graviva      := Obj_art.Fields[10].Value;
    puntorep     := Obj_art.Fields[11].Value;
    end
   else
    begin
      codart := ''; descrip := ''; codrubro := ''; codmarca := ''; codmedida := ''; un_bulto := ''; cant_bulto := ''; cant_sueltas := ''; nropartida := ''; compuesto := ''; graviva := ''; puntorep := 0;
    end;
end;

function  TTArticulo.Buscar(codart: string): boolean;
// Objetivo...: Verificar si Existe el Arítuculo Buscado
begin
  if Obj_art.FindKey([codart]) then Result := True else Result := False;
end;

function TTArticulo.Borrar(codart: string): boolean;
// Objetivo...: Eliminar un Instancia de Articulo
begin
  try
    if Buscar(codart) then
      begin
        Obj_art.Delete;
        Result := True;
      end
  except
    Result := False;
  end;
end;

function TTArticulo.Nuevo: string;
// Objetivo...: Crear un Nuevo Artículo
begin
  Obj_art.Last;
  Result := IntToStr(Obj_art.Fields[0].AsInteger + 1);
end;

function TTArticulo.getCodart: string;
begin
  Result := codart;
end;

function TTArticulo.getDescrip: string;
begin
  Result := descrip;
end;

function TTArticulo.getCodmedida: string;
begin
  Result := codmedida;
end;

function TTArticulo.getUn_bulto: string;
begin
  Result := un_bulto;
end;

function TTArticulo.getCant_bulto: string;
begin
  Result := cant_bulto;
end;

function TTArticulo.getCant_Sueltas: string;
begin
  Result := cant_sueltas;
end;

function  TTArticulo.getNropartida: string;
begin
  Result := nropartida;
end;

function TTArticulo.getCompuesto: string;
begin
  Result := compuesto;
end;

function TTArticulo.getGraviva: string;
begin
  Result := graviva;
end;

function TTArticulo.getPuntorep: real;
begin
  Result := puntorep;
end;

// Métodos de la clase Pedido
//------------------------------------------------------------------------------
function TTPedido.Buscar_Pedido(nrop: string): boolean;
// Objetivo...: Verificar un Pedido
begin
  if cPedido.FindKey([nrop]) then Result := True else Result := False;
end;

function TTPedido.Buscar_Articulo(nrop, codart: string): boolean;
// Objetivo...: Verificar un Pedido
begin
  dPedido.SetKey;
  dPedido.Fields[0].Value := nrop;
  dPedido.Fields[1].Value := codart;
  if dPedido.GotoKey then Result := True else Result := False;
end;

function TTPedido.Grabar_Pedido: boolean;
// Objetivo...: Grabar los Atributos de Cabecera de un Pedido
begin
  try
    if Buscar_Pedido(nropedido) then cPedido.Edit else cPedido.Append;
    cPedido.Fields[0].Value := nropedido;
    cPedido.Fields[1].Value := fecha;
    cPedido.Fields[2].Value := codvend;
    cPedido.Post;
    Result := True;
  except
    Result := False;
  end;
end;

function TTPedido.Grabar_Detalle: boolean;
// Objetivo...: Grabar los Atributos de Detalle de un Pedido
begin
  try
    if Buscar_Articulo(nropedido, codart) then dPedido.Edit else dPedido.Append;
    dPedido.Fields[0].Value := nropedido;
    dPedido.Fields[1].Value := codart;
    dPedido.Fields[2].Value := cantidad;
    dPedido.Post;
    Result := True;
  except
    Result := False;
  end;
end;

function TTPedido.Borrar_Pedido(nrop: string): boolean;
// Objetivo...: Borrar el Pedido Indicado
var
  trSQL: TQuery;
begin
  try
    if Buscar_Pedido(nrop) then
      begin
        cPedido.Delete;   // Cabecera
        trSQL.Close;      // Detalle
        trSQL.SQL.Clear;
        trSQL.SQL.Add('DELETE FROM dPedido WHERE nropedido = ' + '''' + nrop + '''');
        trSQL.ExecSQL;
        trSQL.Close;
        trSQL.Free;
        Result := True;
      end;
  except
    Result := False;
  end;
end;

function TTPedido.Borrar_Articulo(nrop, codart: string) : boolean;
// Objetivo...: Eliminar un Artículo del Pedido
begin
  try
    if Buscar_Articulo(nrop, codart) then dPedido.Delete;
    Result := True;
  except
    Result := False;
  end;
end;

procedure TTPedido.getDatos_Pedido(nrop: string);
// Objetivo...: Preparar los Atributos de Cabecera
begin
  if Buscar_Pedido(nrop) then
    begin
      nropedido := cPedido.Fields[0].Value;
      fecha     := cPedido.Fields[1].Value;
      codvend   := cPedido.Fields[2].Value;
    end
  else
    begin
      nropedido := ''; fecha := ''; codvend := '';
    end;
end;

function TTPedido.getPedido_Detalle(nrop: string): TTable;
// Objetivo...: Preparar los Atributos de Cabecera
begin
  if Buscar_Pedido(nrop) then
    begin
      Det_Pedido := dPedido;
      Result     := Det_Pedido;
    end
  else
    Result := nil;
end;

function TTPedido.getNropedido: string;
begin
  Result := codart;
end;

function TTPedido.getFecha: string;
begin
  Result := fecha;
end;

function TTPedido.getCodvend: string;
begin
  Result := codvend;
end;

function TTPedido.getCodart: string;
begin
  Result := codart;
end;

function TTPedido.getCantidad: real;
begin
  Result := cantidad;
end;

end.
