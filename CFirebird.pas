
unit CFirebird;

interface

uses SysUtils, IBDatabase, IBCustomDataSet, IBTable, IBQuery,
     DB, Variants, IB, CUtiles, CBDT, Classes;

const
  it = 20;

type

TTFirebird = class
  IBDatabase: TIBDatabase;
  IBTable: TIBTable;
  IBTransaction: TIBTransaction;
  Modulo, Host, Usuario, Password, Dir_Remoto, Dir_Remoto1: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function   Conectar(xbasedatos, xusuario, xpassword: String): Boolean;
  procedure  Desconectar; overload;
  procedure  Desconectar(xdatabase: TIBDataBase); overload;

  function   InstanciarTabla(xtabla: String): TIBTable; overload;
  procedure  closeDB(xtabla: TIBTable);

  function   Buscar(xibtable: TIBTable; xcampo, xvalor1: String): boolean; overload;
  function   Buscar(xibtable: TIBTable; xcampos, xvalor1, xvalor2: String): boolean; overload;
  function   Buscar(xibtable: TIBTable; xcampos, xvalor1, xvalor2, xvalor3: String): Boolean; overload;
  function   Buscar(xibtable: TIBTable; xcampos, xvalor1, xvalor2, xvalor3, xvalor4: String): Boolean; overload;
  function   Buscar(xibtable: TIBTable; xcampos, xvalor1, xvalor2, xvalor3, xvalor4, xvalor5: String): Boolean; overload;

  function   BuscarContextualmente(xibtable: TIBTable; xcampo, xvalor1: String): boolean; overload;
  function   BuscarContextualmente(xibtable: TIBTable; xcampos, xvalor1, xvalor2: String): boolean; overload;

  procedure  Filtrar(xibtable: TIBTable; xfiltro: String);
  procedure  QuitarFiltro(xibtable: TIBTable);

  procedure  TransacSQL(xsql: String);
  function   getTransacSQL(xsql: String): TIBQuery;

  procedure  TransacSQLBatch(xsql: TStringList); overload;
  procedure  TransacSQLBatch(xsql, xparams: TStringList); overload;

  procedure  RegistrarTransaccion(xibtable: TIBTable);
  procedure  getModulo(xmodulo: String);

  function   verificarSiExisteCampo(tabla: TIBTable; campo:String): Boolean;
 private
  { Declaraciones Privadas }
  modulos: array[1..it, 1..6] of String;
  it: Integer;
  procedure CargarModulos;
end;

function firebird: TTFirebird;

implementation

var
  xfirebird: TTFirebird = nil;

constructor TTFirebird.Create;
begin
  //CargarModulos;
end;

destructor TTFirebird.Destroy;
begin
  inherited Destroy;
end;

function TTFirebird.Conectar(xbasedatos, xusuario, xpassword: String): Boolean;
var
  E: Integer;
Begin
  if (IBDatabase <> Nil) then begin
    utiles.msgError(IBDatabase.DatabaseName + ' - ' + xbasedatos );
  end;

  if IBDatabase = Nil then Begin
    IBDatabase := TIBDatabase.Create(Nil);
    IBDatabase.DatabaseName := xbasedatos;
    IBDatabase.Params.Add('user_name=' + xusuario);
    IBDatabase.Params.Add('password=' + xpassword);
    IBDatabase.TraceFlags := [];
    IBDatabase.IdleTimer := 1;
    IBDatabase.LoginPrompt := False;
    IBDatabase.IdleTimer := 0;
    try
      IBDatabase.Open;
      //utiles.msgError('open');
      //IBDatabase.Connected := true;
    except
      on E:EIBError do utiles.msgError(E.Message + ' ' + IntToStr(E.IBErrorCode));
    end;

    IBTransaction := TIBTransaction.Create(Nil);
    IBTransaction.Params.Add('read_committed');
    IBTransaction.Params.Add('rec_version');
    IBTransaction.Params.Add('nowait');

    IBDatabase.DefaultTransaction := IBTransaction;

    IBTransaction.Active := true;
    //utiles.msgError(xbasedatos);
  end;

  Result := IBDatabase.Connected;
end;

procedure TTFirebird.Desconectar;
var
  i: integer;
Begin
  //if (IBDatabase = nil) then utiles.msgError('0');
  if (IBDatabase = nil) then exit;  // 29/05/2020
  if IBDatabase <> Nil then begin
    //if IBDatabase.Connected then Begin
      // 01/05/2014
      for i := IBDatabase.TransactionCount - 1 downto 0 do begin
        if (IBDatabase.Transactions[i].Active) then begin
          IBDatabase.Transactions[i].Rollback;
          IBDatabase.Transactions[i].Active := false;
        end;
      end;
      IBTransaction.Destroy;
      IBDatabase.RemoveTransactions;
      IBDatabase.CloseDataSets;
      IBDatabase.ForceClose;
      IBDatabase.Destroy;
      IBDatabase := Nil;
      //UTILES.msgError('CERRADA');
    //end;
  end;
end;

procedure  TTFirebird.Desconectar(xdatabase: TIBDataBase);
var
  i: integer;
Begin
  if xdatabase <> Nil then
    if xdatabase.Connected then Begin
      // 23/08/2014
      for i := xdatabase.TransactionCount - 1 downto 0 do begin
        if (xdatabase.Transactions[i].Active) then begin
          xdatabase.Transactions[i].Rollback;
          xdatabase.Transactions[i].Active := false;
        end;
      end;
      //xdatabase.Connected := False;
      //xdatabase.Destroy;

      utiles.msgError('cierre2');

      xdatabase.RemoveTransactions;
      xdatabase.CloseDataSets;
      xdatabase.ForceClose;
      xdatabase.Destroy;
      xdatabase := Nil;
    end;
end;

function  TTFirebird.InstanciarTabla(xtabla: String): TIBTable;
// Objetivo...: Creamos una Instancia Nueva
var
  tabla: TIBTable;
Begin
  tabla               := TIBTable.Create(Nil);
  tabla.CachedUpdates := False;
  tabla.Transaction   := IBTransaction;
  tabla.TableName     := UpperCase(xtabla);
  Result              := tabla;
end;

procedure  TTFirebird.closeDB(xtabla: TIBTable);
// Objetivo...: Cerramos tabla
Begin
  if xtabla.Active then Begin
    if (xtabla.CachedUpdates) then xtabla.ApplyUpdates;
    xtabla.Close; xtabla := Nil;
  end;
end;

function   TTFirebird.Buscar(xibtable: TIBTable; xcampo, xvalor1: String): boolean;
// Objetivo...: Busqueda Exacta
var
  A: Variant;
Begin
  if not xibtable.Active then xibtable.Open;
  if xibtable.IndexFieldNames <> UpperCase(xcampo) then xibtable.IndexFieldNames := UpperCase(xcampo);
  A := VarArrayCreate([0, 2], varVariant);
  A[0] := VarArrayOf([TrimRight(xvalor1)]);
  Result := xibtable.Locate(UpperCase(xcampo), A[0], [loCaseInsensitive]);
end;

function   TTFirebird.Buscar(xibtable: TIBTable; xcampos, xvalor1, xvalor2: String): boolean;
// Objetivo...: Busqueda Exacta
var
  A: Variant;
Begin
  if not xibtable.Active then xibtable.Open;
  if xibtable.IndexFieldNames <> UpperCase(xcampos) then xibtable.IndexFieldNames := UpperCase(xcampos);
  A := VarArrayCreate([0, 2], varVariant);
  A[0] := VarArrayOf([TrimRight(xvalor1), TrimRight(xvalor2)]);
  Result := xibtable.Locate(UpperCase(xcampos), A[0], [loPartialKey]); // [loCaseInsensitive]);
  if ( Trim(xvalor1 + xvalor2)) = (Trim(xibtable.Fields[0].AsString + xibtable.Fields[1].AsString) ) then Result := True else Result := False;
end;

function   TTFirebird.Buscar(xibtable: TIBTable; xcampos, xvalor1, xvalor2, xvalor3: String): boolean;
// Objetivo...: Busqueda Exacta
var
  A: Variant;
Begin
  if not xibtable.Active then xibtable.Open;
  if xibtable.IndexFieldNames <> UpperCase(xcampos) then xibtable.IndexFieldNames := UpperCase(xcampos);
  A := VarArrayCreate([0, 2], varVariant);
  A[0] := VarArrayOf([xvalor1, xvalor2, xvalor3]);
  Result := xibtable.Locate(UpperCase(xcampos), A[0], [loCaseInsensitive]);
  if ( Trim(xvalor1 + xvalor2 + xvalor3)) = (Trim(xibtable.Fields[0].AsString + xibtable.Fields[1].AsString + xibtable.Fields[2].AsString) ) then Result := True else Result := False;
end;

function   TTFirebird.Buscar(xibtable: TIBTable; xcampos, xvalor1, xvalor2, xvalor3, xvalor4: String): boolean;
// Objetivo...: Busqueda Exacta
var
  A: Variant;
Begin
  if not xibtable.Active then xibtable.Open;
  if xibtable.IndexFieldNames <> UpperCase(xcampos) then xibtable.IndexFieldNames := UpperCase(xcampos);
  A := VarArrayCreate([0, 2], varVariant);
  A[0] := VarArrayOf([xvalor1, xvalor2, xvalor3, xvalor4]);
  Result := xibtable.Locate(UpperCase(xcampos), A[0], [loCaseInsensitive]);
  if ( Trim(xvalor1 + xvalor2 + xvalor3 + xvalor4)) = (Trim(xibtable.Fields[0].AsString + xibtable.Fields[1].AsString + xibtable.Fields[2].AsString + xibtable.Fields[3].AsString) ) then Result := True else Result := False;
end;

function   TTFirebird.Buscar(xibtable: TIBTable; xcampos, xvalor1, xvalor2, xvalor3, xvalor4, xvalor5: String): boolean;
// Objetivo...: Busqueda Exacta
var
  A: Variant;
Begin
  if not xibtable.Active then xibtable.Open;
  if xibtable.IndexFieldNames <> UpperCase(xcampos) then xibtable.IndexFieldNames := UpperCase(xcampos);
  A := VarArrayCreate([0, 2], varVariant);
  A[0] := VarArrayOf([xvalor1, xvalor2, xvalor3, xvalor4, xvalor5]);
  Result := xibtable.Locate(UpperCase(xcampos), A[0], [loCaseInsensitive]);
  if ( Trim(xvalor1 + xvalor2 + xvalor3 + xvalor4 + xvalor5)) = (Trim(xibtable.Fields[0].AsString + xibtable.Fields[1].AsString + xibtable.Fields[2].AsString + xibtable.Fields[3].AsString + xibtable.Fields[4].AsString) ) then Result := True else Result := False;
end;

function   TTFirebird.BuscarContextualmente(xibtable: TIBTable; xcampo, xvalor1: String): boolean;
// Objetivo...: Busqueda contextual
var
  A: Variant;
Begin
  if not xibtable.Active then xibtable.Open;
  if xibtable.IndexFieldNames <> UpperCase(xcampo) then xibtable.IndexFieldNames := UpperCase(xcampo);
  if Length(Trim(xvalor1)) = 0 then Begin
    xibtable.First;
    Result := False;
  end else Begin
    A := VarArrayCreate([0, 2], varVariant);
    A[0] := VarArrayOf([xvalor1]);
    Result := xibtable.Locate(UpperCase(xcampo), A[0], [loPartialKey]);
  end;
end;

function   TTFirebird.BuscarContextualmente(xibtable: TIBTable; xcampos, xvalor1, xvalor2: String): boolean;
// Objetivo...: Busqueda contextual
var
  A: Variant;
Begin
  if not xibtable.Active then xibtable.Open;
  if (Length(Trim(xvalor1)) = 0) or (Length(Trim(xvalor2)) = 0) then Begin
    xibtable.First;
    Result := False;
  end else Begin
    A := VarArrayCreate([0, 2], varVariant);
    A[0] := VarArrayOf([xvalor1, xvalor2]);
    Result := xibtable.Locate(UpperCase(xcampos), A[0], [loPartialKey]);
  end;
end;

procedure TTFirebird.Filtrar(xibtable: TIBTable; xfiltro: String);
// Objetivo...: aplicar filtro en tablas
Begin
  if not xibtable.Active then xibtable.Open;
  xibtable.Filter   := xfiltro;
  xibtable.Filtered := True;
end;

procedure TTFirebird.QuitarFiltro(xibtable: TIBTable);
// Objetivo...: uitar filtro en tablas
Begin
  if (xibtable <> nil) then xibtable.Filtered := False;
end;

procedure TTFirebird.RegistrarTransaccion(xibtable: TIBTable);
// Objetivo...: reflejamos la transsacción en forma definitiva
Begin
  if (xibtable.Active) then begin
    IBTransaction.CommitRetaining;
    IBTransaction.AutoStopAction := SACommit;
    xibtable.Close; xibtable.Open;
  end;
end;

procedure TTFirebird.TransacSQL(xsql: String);
// Objetivo...: Disparar una sentencia sql
var
  rsql: TIBQuery;
Begin
  if not (IBDatabase.Connected) then begin
    IBDatabase.Connected := true;
    IBDatabase.DefaultTransaction := IBTransaction;
    IBTransaction.Active := true;
  end;

  try
    if not (IBTransaction.Active) then IBTransaction.Active := true;
    rsql := TIBQuery.Create(Nil);
    rsql.Transaction := IBTransaction;
    rsql.SQL.Add(xsql);
    rsql.ExecSQL;
    IBTransaction.CommitRetaining;
    IBTransaction.AutoStopAction := SACommit;
  except
    IBTransaction.RollbackRetaining;
    utiles.msgError(xsql);
  end;
end;

function TTFirebird.getTransacSQL(xsql: String): TIBQuery;
// Objetivo...: Disparar una sentencia sql
var
  rsql: TIBQuery;
  strdb: string;
Begin
 if not (IBDatabase.Connected) then begin
    IBDatabase.Open;

    //utiles.msgError('1 ' + IBDatabase.DatabaseName);
    //IBDatabase.Open;
    //IBDatabase.Connected := true;
    //IBDatabase.DefaultTransaction := IBTransaction;
    //IBTransaction.Active := true;                 x
    //utiles.msgError('s');

    //utiles.msgError('2');
    //IBTransaction := TIBTransaction.Create(Nil);
    //IBTransaction.Params.Add('read_committed');
    //IBTransaction.Params.Add('rec_version');
    //IBTransaction.Params.Add('nowait');
    //IBDatabase.DefaultTransaction := IBTransaction;
    //utiles.msgError('3');

    //IBTransaction.StartTransaction;
    //utiles.msgError('4');
  end;

  try
    //if not (IBTransaction.Active) then IBTransaction.Active := true;
    rsql := TIBQuery.Create(Nil);
    //rsql.Transaction := IBTransaction;
    rsql.Database := IBDatabase;
    rsql.SQL.Add(xsql);
    //utiles.msgError('2 ' + IBDatabase.DatabaseName);
    result := rsql;
  except
    //IBTransaction.RollbackRetaining;
    utiles.msgError('error: ' + xsql);
  end;
end;


procedure TTFirebird.TransacSQLBatch(xsql: TStringList);
// Objetivo...: Disparar una sentencia sql
var
  rsql: TIBQuery;
  i: integer;
Begin
  if not (IBDatabase.Connected) then begin
    IBDatabase.Connected := true;
    IBDatabase.DefaultTransaction := IBTransaction;
    IBTransaction.Active := true;
  end;

  if not (IBTransaction.Active) then IBTransaction.Active := true;
  rsql := TIBQuery.Create(Nil);
  rsql.Transaction := IBTransaction;
  for i := 1 to xsql.Count do begin
    rsql.SQL.Add(xsql[i-1]);
    try
      rsql.ExecSQL;
      rsql.SQL.Clear;
    except
      utiles.msgError(xsql[i-1]);
      exit;
    end;
  end;
  IBTransaction.CommitRetaining;
  IBTransaction.AutoStopAction := SACommit;
  xsql.Clear;

end;

procedure TTFirebird.TransacSQLBatch(xsql, xparams: TStringList);
// Objetivo...: Disparar una sentencia sql
var
  rsql: TIBQuery;
  i: integer;
Begin
  rsql := TIBQuery.Create(Nil);
  rsql.Transaction := IBTransaction;
  for i := 1 to xsql.Count do begin
    rsql.SQL.Add(xsql[i-1]);
    //rsql.Params.AssignValues(xparams[i-1]);
    try
      rsql.ExecSQL;
      rsql.SQL.Clear;
    except
      utiles.msgError(xsql[i-1])
    end;
  end;
  IBTransaction.CommitRetaining;
  IBTransaction.AutoStopAction := SACommit;
  xsql.Clear;
end;

//------------------------------------------------------------------------------

procedure TTFirebird.CargarModulos;
// Objetivo...: Cargar Módulos
var
  tabla: TIBTable;
  i: Integer;
  arch: TextFile;
  p1, p2, p3, p4, p5, p6: string;
Begin


  if (FileExists(dbs.DirSistema + '\firebird.cfg')) then begin
    i := 1;
    it := 1;
    AssignFile(arch, dbs.DirSistema + '\firebird.cfg');
    ReSet(arch);

    ReadLn(arch, p1);
    modulos[i, 1] := p1;
    ReadLn(arch, p2);
    modulos[i, 2] := p2;
    ReadLn(arch, p3);
    modulos[i, 3] := p3;
    ReadLn(arch, p4);
    modulos[i, 4] := p4;
    ReadLn(arch, p5);
    modulos[i, 5] := p5;
    ReadLn(arch, p6);
    modulos[i, 6] := p6;

    closeFile(arch);

    exit;
  end;

  if not (FileExists(dbs.DirSistema + '\firebird.gdb')) then exit;
  if (modulos[1, 1] <> '') then exit;


  //utiles.msgError('localhost:' + dbs.DirSistema + '\firebird.gdb');

  conectar('localhost:' + dbs.DirSistema + '\firebird.gdb', 'sysdba', 'masterkey');
  tabla := InstanciarTabla('firebird');
  tabla.Open; i := 0;
  while not tabla.Eof do Begin
    Inc(i); it := i;
    modulos[i, 1] := tabla.FieldByName('MODULO').AsString;
    modulos[i, 2] := tabla.FieldByName('HOST').AsString;
    modulos[i, 3] := tabla.FieldByName('USUARIO').AsString;
    modulos[i, 4] := tabla.FieldByName('PASS').AsString;
    if verificarSiExisteCampo(tabla, 'dir_remoto') then
      modulos[i, 5] := tabla.FieldByName('DIR_REMOTO').AsString
    else
      modulos[i, 5] := 'N';
    if verificarSiExisteCampo(tabla, 'dir_remoto1') then
      modulos[i, 6] := tabla.FieldByName('DIR_REMOTO1').AsString
    else
      modulos[i, 6] := 'N';

    tabla.Next;
  end;
  closeDB(tabla);
  desconectar;
end;

procedure TTFirebird.getModulo(xmodulo: String);
// Objetivo...: Obtener un módulo
var
  i: Integer;
Begin
  {if (Trim(Lowercase(xmodulo)) = 'facturacion') then begin
    host := 'localhost:c:/shmsoft/factIB/';
    usuario := 'sysdba';
    password := 'masterkey';
    exit;
  end;

  if (Trim(Lowercase(xmodulo)) = 'distribucion') then begin
    host := 'localhost:c:/shmsoft/factIB/';
    usuario := 'sysdba';
    password := 'masterkey';
    exit;
  end;}

  if it = 0 then CargarModulos;
  modulo := ''; host := ''; usuario := ''; password := '';

  For i := 1 to it do Begin
    if Trim(Lowercase(modulos[i, 1])) = Trim(Lowercase(xmodulo)) then Begin
      modulo      := modulos[i, 1];
      host        := modulos[i, 2];
      usuario     := modulos[i, 3];
      password    := modulos[i, 4];
      dir_remoto  := modulos[i, 5];
      dir_remoto1 := modulos[i, 6];
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TTFirebird.verificarSiExisteCampo(tabla: TIBTable; campo: String): Boolean;
// Objetivo...: verificar si existe campo
var
  i: Integer;
begin
  Result := False;
  for i := 0 to tabla.FieldCount - 1 do Begin
    if lowercase(tabla.FieldDefs[i].Name) = lowercase(campo) then Begin
      Result := True;
      Break;
    end;
  end;
end;

{===============================================================================}

function firebird: TTFirebird;
begin
  if xfirebird = nil then
    xfirebird := TTFirebird.Create;
  Result := xfirebird;
end;

{===============================================================================}

initialization

finalization
  xfirebird.Free;

end.
