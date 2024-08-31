object fmPresupuesto: TfmPresupuesto
  Left = 223
  Top = 129
  Width = 458
  Height = 356
  Caption = 'Presupuesto'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 450
    Height = 22
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object ToolBar1: TToolBar
      Left = 0
      Top = 0
      Width = 450
      Height = 22
      ButtonWidth = 25
      Caption = 'ToolBar1'
      EdgeBorders = []
      Flat = True
      Images = contenedorImg.ImagenesForms
      TabOrder = 0
      object DBNavigator: TDBNavigator
        Left = 0
        Top = 0
        Width = 96
        Height = 22
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast]
        Flat = True
        Hints.Strings = (
          'Primer Registro'
          'Registro Anterior'
          'Registro Siguiente'
          'Ultimo Registro')
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object Alta: TToolButton
        Left = 96
        Top = 0
        Hint = 'Agregarb Registro'
        Caption = 'Alta'
        ImageIndex = 4
        ParentShowHint = False
        ShowHint = True
      end
      object Baja: TToolButton
        Left = 121
        Top = 0
        Hint = 'Eliminar Registro'
        Caption = 'Baja'
        ImageIndex = 5
        ParentShowHint = False
        ShowHint = True
      end
      object Modificar: TToolButton
        Left = 146
        Top = 0
        Hint = 'Modificar Datos'
        Caption = 'Modificar'
        ImageIndex = 6
        ParentShowHint = False
        ShowHint = True
      end
      object Buscar: TToolButton
        Left = 171
        Top = 0
        Hint = 'Buscar ...'
        Caption = 'Buscar'
        ImageIndex = 7
        ParentShowHint = False
        ShowHint = True
      end
      object Deshacer: TToolButton
        Left = 196
        Top = 0
        Hint = 'Deshacer'
        Caption = 'Deshacer'
        ImageIndex = 8
        ParentShowHint = False
        ShowHint = True
      end
      object Salir: TToolButton
        Left = 221
        Top = 0
        Hint = 'Salir'
        Caption = 'Salir'
        ImageIndex = 9
        ParentShowHint = False
        ShowHint = True
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 310
    Width = 450
    Height = 19
    Panels = <
      item
        Width = 380
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 22
    Width = 450
    Height = 288
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    TabOrder = 2
    object Panel2: TPanel
      Left = 6
      Top = 6
      Width = 438
      Height = 146
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 4
        Top = 6
        Width = 50
        Height = 13
        Alignment = taRightJustify
        Caption = 'Nro. Pres.:'
      end
      object Label2: TLabel
        Left = 244
        Top = 6
        Width = 33
        Height = 13
        Alignment = taRightJustify
        Caption = 'Fecha:'
      end
      object Label3: TLabel
        Left = 18
        Top = 29
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = 'Cliente:'
      end
      object nombre: TLabel
        Left = 127
        Top = 23
        Width = 35
        Height = 13
        Caption = 'nombre'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object direccion: TLabel
        Left = 127
        Top = 36
        Width = 35
        Height = 13
        Caption = 'nombre'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label4: TLabel
        Left = 284
        Top = 35
        Width = 29
        Height = 13
        Caption = 'I.V.A.:'
      end
      object Label5: TLabel
        Left = 317
        Top = 35
        Width = 35
        Height = 13
        Caption = 'nombre'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 26
        Top = 54
        Width = 29
        Height = 13
        Alignment = taRightJustify
        Caption = 'Plazo:'
      end
      object Label7: TLabel
        Left = 232
        Top = 48
        Width = 44
        Height = 13
        Alignment = taRightJustify
        Caption = 'Orden de'
      end
      object Label8: TLabel
        Left = 237
        Top = 59
        Width = 39
        Height = 13
        Alignment = taRightJustify
        Caption = 'Compra:'
      end
      object nropres: TMaskEdit
        Left = 56
        Top = 3
        Width = 63
        Height = 21
        EditMask = '99999999;1; '
        MaxLength = 8
        TabOrder = 0
        Text = '        '
      end
      object fecha: TMaskEdit
        Left = 280
        Top = 3
        Width = 62
        Height = 21
        EditMask = '99/99/99;1; '
        MaxLength = 8
        TabOrder = 1
        Text = '  /  /  '
      end
      object codcli: TMaskEdit
        Left = 56
        Top = 26
        Width = 44
        Height = 21
        EditMask = '9999;1; '
        MaxLength = 4
        TabOrder = 2
        Text = '    '
      end
      object selprov: TBitBtn
        Left = 103
        Top = 26
        Width = 20
        Height = 23
        Hint = 'Buscar Proveedor'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
          FFFFFFFFFFF000FFFFFFFFFFFF0BB00FFFFFFFFFFF0BB00FFFFFFFFFFFF00FFF
          FFFFFFFFFF0B00FFFFFFFFFFFF0B00FFFFFFFFFFFF0B00FFFFFFFFFFFF0BB00F
          FFFFFFFF00F0BB00FFFFFFF0B00F0BB00FFFFFF0B00FF0B00FFFFFF0BB000BB0
          0FFFFFFF0BBBBB00FFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFF}
      end
      object plazo: TMaskEdit
        Left = 56
        Top = 51
        Width = 147
        Height = 21
        MaxLength = 30
        TabOrder = 4
      end
      object orden: TMaskEdit
        Left = 281
        Top = 51
        Width = 152
        Height = 21
        MaxLength = 30
        TabOrder = 5
      end
      object GroupBox1: TGroupBox
        Left = 5
        Top = 73
        Width = 428
        Height = 69
        Caption = ' Detalle del Presupuesto '
        TabOrder = 6
        object Label9: TLabel
          Left = 8
          Top = 20
          Width = 44
          Height = 13
          Alignment = taRightJustify
          Caption = 'C'#243'd. Art.:'
        end
        object descrip: TLabel
          Left = 165
          Top = 21
          Width = 35
          Height = 13
          Caption = 'nombre'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label11: TLabel
          Left = 5
          Top = 44
          Width = 45
          Height = 13
          Alignment = taRightJustify
          Caption = 'Cantidad:'
        end
        object Label12: TLabel
          Left = 240
          Top = 44
          Width = 33
          Height = 13
          Alignment = taRightJustify
          Caption = 'Precio:'
        end
        object MaskEdit1: TMaskEdit
          Left = 54
          Top = 17
          Width = 83
          Height = 21
          EditMask = '9999;1; '
          MaxLength = 4
          TabOrder = 0
          Text = '    '
        end
        object BitBtn1: TBitBtn
          Left = 141
          Top = 17
          Width = 20
          Height = 23
          Hint = 'Buscar Proveedor'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          Glyph.Data = {
            F6000000424DF600000000000000760000002800000010000000100000000100
            0400000000008000000000000000000000001000000010000000000000000000
            8000008000000080800080000000800080008080000080808000C0C0C0000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
            FFFFFFFFFFF000FFFFFFFFFFFF0BB00FFFFFFFFFFF0BB00FFFFFFFFFFFF00FFF
            FFFFFFFFFF0B00FFFFFFFFFFFF0B00FFFFFFFFFFFF0B00FFFFFFFFFFFF0BB00F
            FFFFFFFF00F0BB00FFFFFFF0B00F0BB00FFFFFF0B00FF0B00FFFFFF0BB000BB0
            0FFFFFFF0BBBBB00FFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFF}
        end
        object cantidad: TEditValid
          Left = 54
          Top = 40
          Width = 57
          Height = 21
          TabOrder = 2
          Valid = tvDecimalPos
        end
        object EditValid1: TEditValid
          Left = 277
          Top = 40
          Width = 84
          Height = 21
          TabOrder = 3
          Valid = tvDecimalPos
        end
      end
      object btnRegistrar: TButton
        Left = 380
        Top = 3
        Width = 52
        Height = 22
        Caption = '&Registrar'
        TabOrder = 7
      end
      object btnCancelar: TButton
        Left = 380
        Top = 26
        Width = 52
        Height = 22
        Caption = '&Cancelar'
        TabOrder = 8
      end
    end
    object Panel3: TPanel
      Left = 6
      Top = 152
      Width = 438
      Height = 130
      Align = alClient
      BevelInner = bvLowered
      TabOrder = 1
      object S: TStringGrid
        Left = 2
        Top = 2
        Width = 434
        Height = 126
        Align = alClient
        BorderStyle = bsNone
        ColCount = 6
        DefaultRowHeight = 15
        FixedCols = 0
        RowCount = 500
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
        ColWidths = (
          29
          45
          76
          132
          64
          64)
      end
    end
  end
end
