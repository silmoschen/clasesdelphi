unit CControlCtasCtes_Copetti;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTControlCtasCtes = class
  Idtitular, Clavecta, Items, Controlo, Fecha, TipoMov, Intermediario, Operatoria, Observacion: String; Importe, Interes: Real; Existe: Boolean;
  audit_ctasctes: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidtitular, xclavecta, xfecha, xitems: String): Boolean;
  procedure   RegistrarControl(xidtitular, xclavecta, xfecha, xcontrolo, xintermediario, xoperatoria, xobservacion: String; ximporte, xinteres: Real);
  procedure   CorregirControl(xidtitular, xclavecta, xfechamod, xfecha, xcontrolo, xintermediario, xoperatoria, xobservacion: String; ximporte, xinteres: Real);
  procedure   Borrar(xidtitular, xclavecta, xfecha, xitems: String);
  procedure   getDatos(xidtitular, xclavecta, xfecha, xitems: String);

  procedure   RegistrarPago(xidtitular, xclavecta, xfecha, xitems: String; ximporte, xinteres: Real);

  function    setControles(xidtitular, xclavecta: String): TQuery;
  function    setPagos(xidtitular, xclavecta: String): TQuery;

  procedure   ListarInformeControl(xtitulo, xdf, xhf: String; salida: char);

  procedure   Depurar(xidtitular, xclavecta: String);

  procedure   conectar;
  procedure   desconectar;
 protected
  Titular: String;
  procedure   DatosTitularCtaCte(xidtitular: String); virtual;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  r: TQuery;
  procedure   ListarDatosControl(xidtitular: String; salida: char);
end;

function controlc: TTControlCtasCtes;

implementation

var
  xcontrolc: TTControlCtasCtes = nil;

constructor TTControlCtasCtes.Create;
begin
end;

destructor TTControlCtasCtes.Destroy;
begin
  inherited Destroy;
end;

function  TTControlCtasCtes.Buscar(xidtitular, xclavecta, xfecha, xitems: String): Boolean;
begin
  if audit_ctasctes.IndexFieldNames <> 'Idtitular;Clavecta;Fecha;Items' then audit_ctasctes.IndexFieldNames := 'Idtitular;Clavecta;Fecha;Items';
  if Copy(xfecha, 3, 1) = '/' then Existe := datosdb.Buscar(audit_ctasctes, 'Idtitular', 'Clavecta', 'Fecha', 'Items', xidtitular, xclavecta, utiles.sExprFecha2000(xfecha), xitems) else
    Existe := datosdb.Buscar(audit_ctasctes, 'Idtitular', 'Clavecta', 'Fecha', 'Items', xidtitular, xclavecta, xfecha, xitems);
  Result := Existe;
end;

procedure TTControlCtasCtes.RegistrarControl(xidtitular, xclavecta, xfecha, xcontrolo, xintermediario, xoperatoria, xobservacion: String; ximporte, xinteres: Real);
begin
  if Buscar(xidtitular, xclavecta, xfecha, '000') then audit_ctasctes.Edit else audit_ctasctes.Append;
  audit_ctasctes.FieldByName('idtitular').AsString     := xidtitular;
  audit_ctasctes.FieldByName('clavecta').AsString      := xclavecta;
  audit_ctasctes.FieldByName('fecha').AsString         := utiles.sExprFecha2000(xfecha);
  audit_ctasctes.FieldByName('items').AsString         := '000';
  audit_ctasctes.FieldByName('controlo').AsString      := xcontrolo;
  audit_ctasctes.FieldByName('tipomov').AsString       := 'C';
  audit_ctasctes.FieldByName('intermediario').AsString := xintermediario;
  audit_ctasctes.FieldByName('operatoria').AsString    := xoperatoria;
  audit_ctasctes.FieldByName('observacion').AsString   := xobservacion;
  audit_ctasctes.FieldByName('importe').AsFloat        := ximporte;
  audit_ctasctes.FieldByName('interes').AsFloat        := xinteres;
  try
    audit_ctasctes.Post
   except
    audit_ctasctes.Cancel
  end;
  datosdb.refrescar(audit_ctasctes);
end;

procedure TTControlCtasCtes.CorregirControl(xidtitular, xclavecta, xfechamod, xfecha, xcontrolo, xintermediario, xoperatoria, xobservacion: String; ximporte, xinteres: Real);
begin
  if Buscar(xidtitular, xclavecta, xfechamod, '000') then audit_ctasctes.Edit else audit_ctasctes.Append;
  audit_ctasctes.FieldByName('idtitular').AsString     := xidtitular;
  audit_ctasctes.FieldByName('clavecta').AsString      := xclavecta;
  audit_ctasctes.FieldByName('fecha').AsString         := utiles.sExprFecha2000(xfecha);
  audit_ctasctes.FieldByName('items').AsString         := '000';
  audit_ctasctes.FieldByName('controlo').AsString      := xcontrolo;
  audit_ctasctes.FieldByName('tipomov').AsString       := 'C';
  audit_ctasctes.FieldByName('intermediario').AsString := xintermediario;
  audit_ctasctes.FieldByName('operatoria').AsString    := xoperatoria;
  audit_ctasctes.FieldByName('observacion').AsString   := xobservacion;
  audit_ctasctes.FieldByName('importe').AsFloat        := ximporte;
  audit_ctasctes.FieldByName('interes').AsFloat        := xinteres;
  try
    audit_ctasctes.Post
   except
    audit_ctasctes.Cancel
  end;
  datosdb.refrescar(audit_ctasctes);
end;

procedure TTControlCtasCtes.Borrar(xidtitular, xclavecta, xfecha, xitems: String);
begin
  datosdb.tranSQL('delete from ' + audit_ctasctes.TableName + ' where idtitular = ' + '"' + xidtitular + '"' + ' and clavecta = ' + '"' + xclavecta + '"' + ' and fecha = ' + '"' + utiles.sExprFecha2000(xfecha) + '"' + ' and items = ' + '"' + xitems + '"');
end;

procedure TTControlCtasCtes.getDatos(xidtitular, xclavecta, xfecha, xitems: String);
begin
  if Buscar(xidtitular, xclavecta, xfecha, '000') then Begin
    Idtitular     := audit_ctasctes.FieldByName('idtitular').AsString;
    clavecta      := audit_ctasctes.FieldByName('clavecta').AsString;
    fecha         := utiles.sFormatoFecha(audit_ctasctes.FieldByName('fecha').AsString);
    Items         := audit_ctasctes.FieldByName('items').AsString;
    controlo      := audit_ctasctes.FieldByName('controlo').AsString;
    TipoMov       := audit_ctasctes.FieldByName('tipomov').AsString;
    Importe       := audit_ctasctes.FieldByName('importe').AsFloat;
    Intermediario := audit_ctasctes.FieldByName('intermediario').AsString;
    Operatoria    := audit_ctasctes.FieldByName('operatoria').AsString;
    Observacion   := audit_ctasctes.FieldByName('observacion').AsString;
    Importe       := audit_ctasctes.FieldByName('importe').AsFloat;
    Interes       := audit_ctasctes.FieldByName('interes').AsFloat;
  end else Begin
    Idtitular := ''; clavecta := ''; fecha := ''; items := ''; controlo := ''; tipomov := ''; importe := 0; Observacion := ''; Intermediario := ''; Operatoria := ''; interes := 0; 
  end;
end;

procedure TTControlCtasCtes.RegistrarPago(xidtitular, xclavecta, xfecha, xitems: String; ximporte, xinteres: Real);
// Objetivo...: Registrar Pago
begin
  conectar;
  audit_ctasctes.IndexFieldNames := 'Idtitular;Clavecta';    // Verificamos que la cuenta este marcada
  if datosdb.Buscar(audit_ctasctes, 'Idtitular', 'Clavecta', xidtitular, xclavecta) then Begin
    if Buscar(xidtitular, xclavecta, xfecha, xitems) then audit_ctasctes.Edit else audit_ctasctes.Append;
    audit_ctasctes.FieldByName('idtitular').AsString := xidtitular;
    audit_ctasctes.FieldByName('clavecta').AsString  := xclavecta;
    audit_ctasctes.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
    audit_ctasctes.FieldByName('items').AsString     := xitems;
    audit_ctasctes.FieldByName('tipomov').AsString   := 'P';
    audit_ctasctes.FieldByName('importe').AsFloat    := ximporte;
    audit_ctasctes.FieldByName('interes').AsFloat    := xinteres;
    try
      audit_ctasctes.Post
     except
      audit_ctasctes.Cancel
    end;
    datosdb.refrescar(audit_ctasctes);
  end;
  desconectar;
end;

function TTControlCtasCtes.setControles(xidtitular, xclavecta: String): TQuery;
begin
  Result := datosdb.tranSQL('select * from ' + audit_ctasctes.TableName + ' where idtitular = ' + '"' + xidtitular + '"' + ' and clavecta = ' + '"' + xclavecta + '"' + ' and tipomov = ' + '"' + 'C' + '"' + ' order by fecha');
end;

function TTControlCtasCtes.setPagos(xidtitular, xclavecta: String): TQuery;
begin
  Result := datosdb.tranSQL('select * from ' + audit_ctasctes.TableName + ' where idtitular = ' + '"' + xidtitular + '"' + ' and clavecta = ' + '"' + xclavecta + '"' + ' and tipomov = ' + '"' + 'P' + '"' + ' order by fecha');
end;

procedure TTControlCtasCtes.ListarInformeControl(xtitulo, xdf, xhf: String; salida: char);
// Objetivo...: Listar Informe control
var
  c1, i, j: Integer;
Begin
  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Titular', 1, 'Arial, cursiva, 8');
  list.Titulo(30, list.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
  list.Titulo(45, list.Lineactual, 'Intermediario', 3, 'Arial, cursiva, 8');
  list.Titulo(60, list.Lineactual, 'Operatoria', 4, 'Arial, cursiva, 8');
  list.Titulo(73, list.Lineactual, 'Importe', 5, 'Arial, cursiva, 8');
  list.Titulo(85, list.Lineactual, 'Interes', 6, 'Arial, cursiva, 8');
  list.Titulo(91, list.Lineactual, 'Observación', 7, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');

  r := datosdb.tranSQL('select * from ' + audit_ctasctes.TableName + ' where fecha >= ' + '"' + utiles.sExprFecha2000(xdf) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhf) + '"' + ' order by idtitular, clavecta, fecha, tipomov');
  r.Open; i := 0; c1 := 1; j := 0;
  while not r.Eof do Begin
    if r.FieldByName('tipomov').AsString = 'C' then Begin
      ListarDatosControl(r.FieldByName('idtitular').AsString, salida);
      j := 5;
    end else Begin
      if j > 2 then Begin
        i := 0; c1 := 3; j := 0;
        list.Linea(0, 0, '', i+1, 'Arial, normal, 8', salida, 'N');
      end;

      list.Linea(c1, list.Lineactual, utiles.sFormatoFecha(r.FieldByName('fecha').AsString), i+2, 'Arial, normal, 8', salida, 'N');
      list.importe(c1+18, list.Lineactual, '', r.FieldByName('importe').AsFloat, i+3, 'Arial, normal, 8');
      list.importe(c1+25, list.Lineactual, '', r.FieldByName('interes').AsFloat, i+4, 'Arial, normal, 8');
      i := i + 4; c1 := c1 + 30;
      Inc(j);
    end;

    r.Next;
  end;
  r.Close; r.Free;
  list.FinList;
end;

procedure TTControlCtasCtes.Depurar(xidtitular, xclavecta: String);
// Objetivo.... Depurar Movimirento
Begin
  datosdb.tranSQL('delete from ' + audit_ctasctes.TableName + ' where idtitular = ' + '"' + xidtitular + '"' + ' and clavecta = ' + '"' + xclavecta + '"');
end;

procedure TTControlCtasCtes.DatosTitularCtaCte(xidtitular: String);
Begin
end;

procedure TTControlCtasCtes.ListarDatosControl(xidtitular: String; salida: char);
// Objetivo...: Listar datos de cuentas corrientes
Begin
  DatosTitularCtaCte(xidtitular);
  //list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, titular, 1, 'Arial, normal, 8, clNavy', salida, 'N');
  list.Linea(30, list.Lineactual, utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 2, 'Arial, normal, 8, clNavy', salida, 'N');
  list.Linea(45, list.Lineactual, r.FieldByName('intermediario').AsString, 3, 'Arial, normal, 8, clNavy', salida, 'N');
  list.Linea(60, list.Lineactual, r.FieldByName('operatoria').AsString, 4, 'Arial, normal, 8, clNavy', salida, 'N');
  list.importe(78, list.Lineactual, '', r.FieldByName('importe').AsFloat, 5, 'Arial, normal, 8, clNavy');
  list.importe(90, list.Lineactual, '', r.FieldByName('interes').AsFloat, 6, 'Arial, normal, 8, clNavy');
  list.Linea(91, list.Lineactual, r.FieldByName('observacion').AsString, 7, 'Arial, normal, 8, clNavy', salida, 'S');
end;

procedure TTControlCtasCtes.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not audit_ctasctes.Active then audit_ctasctes.Open;
  end;
  Inc(conexiones);
end;

procedure TTControlCtasCtes.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(audit_ctasctes);
  end;
end;

{===============================================================================}

function controlc: TTControlCtasCtes;
begin
  if xcontrolc = nil then
    xcontrolc := TTControlCtasCtes.Create;
  Result := xcontrolc;
end;

{===============================================================================}

initialization

finalization
  xcontrolc.Free;

end.
