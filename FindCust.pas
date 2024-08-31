unit FindCust;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, StdCtrls, Buttons, Mask, ExtCtrls, DB, DBTables, ComCtrls,
  DBCtrls;

type
  TfmFindCust = class(TForm)
    Hojeador: TDBGrid;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    cbUseFilter: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Indice1: TLabel;
    Indice2: TLabel;
    cbDesactivarFiltro: TCheckBox;
    Tabla: TTable;
    IdxOriginal: TLabel;
    MensajeError: TLabel;
    ClaveMult: TLabel;
    IdxClaveMultiple: TLabel;
    Navegador: TDBNavigator;
    Animacion: TAnimate;
    DataSource1: TDataSource;
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbDesactivarFiltroClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HojeadorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BuscarClave(Sender: TObject);
    procedure AlternarColumnas(Sender: TObject);
    procedure SeleccionarIndiceActivo(Sender: TObject; Tabla: TTable);
    procedure FormCreate(Sender: TObject);

    private
      FiltroOriginal, cp_idxoriginal: string;
      ClaveMultiple : Boolean;
      ExisteClave   : byte;
      {ExpresionClave: array[1..3] of string;}
  end;

var
  fmFindCust: TfmFindCust;
  ExpresionClave: array[1..3] of string;

implementation

uses FormarExpresionesIndices;

{$R *.DFM}

procedure TfmFindCust.ComboBox1Change(Sender: TObject);
begin
  MensajeError.Caption := '';
  Animacion.Active := False;

  { Señala el Campo que se está utilizando para la Búsqueda }
  if Copy(ComboBox1.Text, 1, 1) <> '' then AlternarColumnas(Sender);
  { Alterna en los Posibles Indices que puedan exixtir en la Tabla }

  SeleccionarIndiceActivo(Sender, Tabla);

  { ... o la selección se puede dar a través de campos que no sean Indices }
  cbUseFilter.Enabled := AnsiPos('|'+ComboBox1.Text+'|','|'+Indice2.Caption+'|'+Indice1.Caption+'|') = 0;
  if cbUseFilter.Enabled then
    cbUseFilter.SetFocus
   else
    Edit1.SetFocus;
  {Desactivamos Filtro para Realizar Nueva Búsqueda}
  Tabla.Filtered := False;
  cbDesactivarFiltro.Enabled := True;
  cbDesactivarFiltro.Checked := True;
  {Si existe un Filtro Nativo, lo fijamos ...}
  if Length(FiltroOriginal) > 0 then
    begin
      Tabla.Filter   := FiltroOriginal;
      Tabla.Filtered := True;
    end;
  Edit1.Text    := '';
  ActiveControl := Edit1;
end;

procedure TfmFindCust.Edit1Change(Sender: TObject);
var
  mb: Boolean;
begin
  Animacion.Active := True;
  {Verifico que el Campo Seleccionado no sea Calculado}
  if (Tabla.Fieldbyname(Combobox1.Text).Calculated) or
    not (Tabla.Fieldbyname(Combobox1.Text).Visible) then
    MensajeError.Caption := 'Imposible Buscar en este Campo'
  else
    //Verifico si el campo seleccionado coincide con alguno de los Indices disponibles ...
    ExisteClave := 0;
    if (Pos(ComboBox1.Text, ExpresionClave[1]) <> 0) or (ComboBox1.Text = ExpresionClave[1]) then ExisteClave := 1;
    if (Pos(ComboBox1.Text, ExpresionClave[2]) <> 0) or (ComboBox1.Text = ExpresionClave[2]) then ExisteClave := 1;
    if (Pos(ComboBox1.Text, ExpresionClave[3]) <> 0) or (ComboBox1.Text = ExpresionClave[3]) then ExisteClave := 1;
    // Si se trata de una Clave Pardox No existe el Nombre del Indice pero si la Clave
    if (ExisteClave = 0) and (IdxClaveMultiple.Caption = 'XX00') then ExisteClave := 1;

    //... si existe, procedo a la Búsqueda Directa por Aproximación ...
    if ExisteClave <> 0 then cbUseFilter.Checked := False;
    if ExisteClave <> 0 then BuscarClave(Sender)

    else
      //... caso contrario, realizo la búsqueda por Filtro ...
      begin
        if ExisteClave = 0 then
          begin
           mb := (Tabla.Locate(ComboBox1.Text, Edit1.Text,[loCaseInsensitive,
                loPartialKey])) {and (cbUseFilter.Checked)};
           if mb then
              begin
               {Inactiva/Activa los casilleros correspondientes}
               cbUseFilter.Checked        := True;
               cbDesactivarFiltro.Checked := False;
               { Comienza a Filtrar pos la Clave Seleccionada }
               Tabla.Filter := ComboBox1.Text + ' = ' + '''' + Edit1.Text + '''';
               Tabla.Filtered := True;
               if Tabla.RecordCount = 0 then {Filter is possibly too restrictive}
                 Tabla.Filter := ComboBox1.Text + ' >= ' + '''' + Edit1.Text + '''';
              end
           else
             Tabla.Filtered := False;
         end;
       Refresh;
   end;
end;

procedure TfmFindCust.FormActivate(Sender: TObject);
begin
  DataSource1.DataSet := tabla;
  Hojeador.datasource := DataSource1;

  cp_idxoriginal := Tabla.IndexFieldNames;
  // Vuelco los Campos a ComboBox1
  Tabla.GetFieldNames(ComboBox1.Items);
  // Conexión para los SpeedButton Primero, Anterior, Siguiente, Ultimo

  if length(trim(indice1.Caption + indice2.Caption + idxClaveMultiple.Caption)) > 0 then
   begin
    Edit1.Text     := '';
    FiltroOriginal := Tabla.Filter;
    if Tabla.Active then
      // Recupero el Indice Original
      IdxOriginal.Caption := Tabla.IndexName;

      //Extraemos las Expresiones que componen la Clave para ir alternando entre los Indices
      //Para el Indice Nro. 1
      ExpresionClave[1] := '';
      ExpresionClave[2] := '';
      ExpresionClave[3] := '';
      if Length(Indice1.Caption) > 0 then
        begin
          Tabla.IndexName   := Indice1.Caption;
          if indice1.Caption <> IdxClaveMultiple.Caption then ExpresionClave[1] := FormarExpresionClave(Tabla);
        end;
      // Para el Indice Nro. 2
      if Length(Indice2.Caption) > 0 then
        begin
          Tabla.IndexName   := Indice2.Caption;
          ExpresionClave[2] := FormarExpresionClave(Tabla);
        end;
      // Para las claves Múltiples / XX00 - Indice Compuesto para tablas Paradox
      if (Length(IdxClaveMultiple.Caption) > 0) and (IdxClaveMultiple.Caption <> 'XX00') then
        begin
          Tabla.IndexName   := IdxClaveMultiple.Caption;
          ExpresionClave[3] := FormarExpresionClave(Tabla);
        end;

      // Selecciona el Indice Prefijado
      SeleccionarIndiceActivo(Sender, Tabla);

     // Cargamos los datos necesarios para las búsquedas
     Expresion(Tabla, Tabla.IndexName);
    end;

    ActiveControl := Edit1;
end;

procedure TfmFindCust.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then
    begin
      if not Tabla.EOF then Tabla.Next;
      ActiveControl := Hojeador;
    end;
  if Key = VK_UP then
    begin
      if not Tabla.BOF then Tabla.Prior;
      ActiveControl := Hojeador;
    end;
end;

procedure TfmFindCust.cbDesactivarFiltroClick(Sender: TObject);
begin
  Tabla.Filtered := False;
end;

procedure TfmFindCust.FormClose(Sender: TObject; var Action: TCloseAction);
var
 i, x : integer;
begin
 x := Tabla.FieldCount;
 For i := 1 to x do   {Restablecemos el Orden de los Campos}
  Tabla.FieldByName(ComboBox1.Items[i-1]).Index  := i-1;
 Animacion.Active := False;
 Hojeador.DataSource  := nil;
 Navegador.DataSource := nil;
end;

procedure TfmFindCust.HojeadorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_UP) and (Tabla.BOF) then ActiveControl := Edit1;
  Animacion.Active := True;
end;

procedure TfmFindCust.BuscarClave(Sender: TObject);
var
  x: byte;
begin
  with Tabla do
    begin
      SetKey;
      {Completamos los Campos con los Valores de Búsqueda ...}
      {... y las extracciones necesarias para Transferir los valores correspondientes
       ... alojadas en el array posisubstr}
      For x := 1 to cClaves do Fields[x-1].AsString := Copy(Edit1.Text, posisubstr[x, 1], posisubstr[x, 2]);
      GotoNearest;
    end;
end;

procedure TfmFindCust.AlternarColumnas(Sender: TObject);
var
  largo, posini, i, a, t, s: integer;
begin
  {Arma las Columnas teniendo en Cuenta la Clave Múltiple}
  if (ClaveMultiple) and (Pos(ComboBox1.Text, ClaveMult.Caption) > 0) then
    begin
      ClaveMult.Caption:= ExpresionClave[3];
      largo  := Length(ClaveMult.Caption);
      posini := 0;
      a      := 0;
      t      := 0;
      s      := 1;

      For i := 1 to largo do
        begin
          if (Copy(ClaveMult.Caption, i, 1) = '+') or (Copy(ClaveMult.Caption, i, 1) = ';') then
            begin
              if Tabla.FieldByName(Copy(ClaveMult.Caption, posini, a)).Visible then Tabla.FieldByName(Copy(ClaveMult.Caption, posini, a)).Index := t else t := t - 1;
              s := s + 1;
              posini := s;
              t := t + 1;
              a := 0;
            end
           else
            begin
              a := a + 1;
              s := s + 1;
            end;
        end;
      Tabla.FieldByName(Copy(ClaveMult.Caption, posini, a)).Index := t
    end;
    {Selecciona la Columna elegida cuando no existe Clave Múltiple}
    if (Pos(ComboBox1.Text, ClaveMult.Caption) = 0) then Tabla.FieldByName(ComboBox1.Text).Index := 0;
    Expresion(Tabla, Tabla.IndexName);
end;

procedure TfmFindCust.SeleccionarIndiceActivo(Sender: TObject; Tabla: TTable);
begin
  Tabla.IndexFieldNames := cp_idxoriginal;   //Por omisión toma el campo de la clave Principal - en Paradox

  {Para claves simples ...}
  if Copy(UpperCase(ComboBox1.Text), 1, 4) = Copy(Uppercase(Indice1.Caption), 1, 4) then
    Tabla.IndexName := Indice1.Caption;
  if (Copy(UpperCase(ComboBox1.Text), 1, 4) = Copy(Uppercase(Indice2.Caption), 1, 4)) and (Copy(Indice2.Caption, 1, 4) <> '') then
    Tabla.IndexName := Indice2.Caption;
  {Determinamos si se trata de una Clave Múltiple o Simple}
  if Length(Tabla.IndexDefs.Items[DeterminarIndiceActivo(Tabla)].Expression) > 0 then ClaveMultiple := True else ClaveMultiple := False;

  {Si el campo seleccionado consiste con el primer campo de la clave Múltiple}
  if UpperCase(ComboBox1.Text) = Uppercase(Copy(ExpresionClave[3], 1, Length(ComboBox1.Text))) then ClaveMultiple := True;

  {Para claves múltiples}
  if ClaveMultiple then
    begin
      Tabla.IndexName   := IdxClaveMultiple.Caption;
      ClaveMult.Caption := Tabla.IndexDefs.Items[DeterminarIndiceActivo(Tabla)].Expression;
    end;

  {Invocamos a la Función para determinar Campos Claves y su ubicación dentro de la Tabla}
  AlternarColumnas(Sender);
  Expresion(Tabla, Tabla.IndexName);
end;

procedure TfmFindCust.FormCreate(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
end;

end.
