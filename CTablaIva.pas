unit CTablaIva;

interface

uses SysUtils, DB, DBTables, cbdt, CIDBFM, CUtiles;

type

TTTablaIVA = class(TObject)            // Superclase
  codiva, Descrip, AC, AV, codsopmag: string;
  ivari, ivarni, coeinverso, alicuota: real;
  tabliva : TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodiva, xdescrip, xAC, xAV, xCodsopmag: string; xivari, xivarni, xcoeinverso: real);
  procedure   Borrar(xcodiva: string);
  function    Buscar(xcodiva: string): boolean;
  function    ExtraerCoeinverso: real;
  procedure   getDatos(xcodiva: string);
  function    setNetos: TQuery;

  procedure   GuardarAlicuotaBase(xalicuota: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  archivo: TextFile;
end;

function tabliva: TTTablaIVA;

implementation

var
  xtabliva: TTTablaIVA = nil;

constructor TTTablaIVA.Create;
begin
  inherited Create;
  tabliva := datosdb.openDB('tabliva', 'codiva');
end;

destructor TTTablaIVA.Destroy;
begin
  inherited Destroy;
end;

procedure TTTablaIVA.Grabar(xcodiva, xdescrip, xAC, xAV, xCodsopmag: string; xivari, xivarni, xcoeinverso: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodiva) then tabliva.Edit else tabliva.Append;
  tabliva.FieldByName('codiva').AsString    := xcodiva;
  tabliva.FieldByName('descrip').AsString   := xdescrip;
  tabliva.FieldByName('AC').AsString        := xAC;
  tabliva.FieldByName('AV').AsString        := xAV;
  tabliva.FieldByName('iva_n').AsFloat      := xIvari;
  tabliva.FieldByName('iva_rec').AsFloat    := xIvarni;
  tabliva.FieldByName('coeinverso').AsFloat := xCoeinverso;
  tabliva.FieldByName('codsopmag').AsString := xCodsopmag;
  try
    tabliva.Post;
  except
    tabliva.Cancel;
  end;
end;

procedure TTTablaIVA.Borrar(xcodiva: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodiva) then
    begin
      tabliva.Delete;
      getDatos(tabliva.FieldByName('codiva').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTTablaIVA.Buscar(xcodiva: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if conexiones = 0 then conectar;
  if tabliva.Filtered then tabliva.Filtered := False;
  if tabliva.FindKey([xcodiva]) then Result := True else Result := False;
end;

procedure  TTTablaIVA.getDatos(xcodiva: string);
// Objetivo...: Retornar/Iniciar Atributos
var
  a: String;
begin
  if Buscar(xcodiva) then
    begin
      codiva     := tabliva.FieldByName('codiva').AsString;
      descrip    := tabliva.FieldByName('descrip').AsString;
      ac         := tabliva.FieldByName('ac').AsString;
      av         := tabliva.FieldByName('av').AsString;
      ivari      := tabliva.FieldByName('iva_n').AsFloat;
      ivarni     := tabliva.FieldByName('iva_rec').AsFloat;
      coeinverso := tabliva.FieldByName('coeinverso').AsFloat;
      codsopmag  := tabliva.FieldByName('codsopmag').AsString;
    end
   else
    begin
      codiva := ''; descrip := ''; ac := ''; av := ''; ivari := 0; ivarni := 0; coeinverso := 0; codsopmag := '';
    end;

  if FileExists(dbs.DirSistema + '\alicuota.dat') then Begin
    AssignFile(archivo, dbs.DirSistema + '\alicuota.dat');
    Reset(archivo);
    ReadLn(archivo, a);
    a := utiles.FormatearNumero(a);
    alicuota := StrToFloat(a);
    closeFile(archivo);
  end;
end;

function TTTablaiva.ExtraerCoeinverso: real;
// Objetivo...: buscar y devolver el coeficiente Invereso
begin
  tabliva.Filtered := False;
  tabliva.First;
  Result := 0;
  while not tabliva.EOF do
    begin
      if tabliva.FieldByName('coeinverso').AsFloat > 0 then
        begin
          Result := tabliva.FieldByName('coeinverso').AsFloat;
          Break;
        end;
      tabliva.Next;
    end;
end;

function TTTablaiva.setNetos: TQuery;
// Objetivo...: devolver un set con los netos
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabliva.TableName);
end;

procedure  TTTablaIVA.GuardarAlicuotaBase(xalicuota: String);
// Ojetivo...: Recuperar Alicuota Base
Begin
  AssignFile(archivo, dbs.DirSistema + '\alicuota.dat');
  Rewrite(archivo);
  WriteLn(archivo, xalicuota);
  closeFile(archivo);
end;

procedure TTTablaIVA.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabliva.Active then tabliva.Open;
    tabliva.FieldByName('codiva').DisplayLabel := 'Cód'; tabliva.FieldByName('descrip').DisplayLabel := 'Descripción';
    tabliva.FieldByName('iva_n').DisplayLabel := 'I.V.A.'; tabliva.FieldByName('iva_rec').DisplayLabel := 'I.V.A. Rec.';
    tabliva.FieldByName('coeinverso').DisplayLabel := 'Coef. Inverso'; tabliva.FieldByName('codsopmag').DisplayLabel := 'Cód. Sop. Mag.';
  end;
  Inc(conexiones);
end;

procedure TTTablaIVA.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabliva);
end;

{===============================================================================}

function tabliva: TTTablaIVA;
begin
  if xtabliva = nil then
    xtabliva := TTTablaIVA.Create;
  Result := xtabliva;
end;

{===============================================================================}

initialization

finalization
  xtabliva.Free;

end.
