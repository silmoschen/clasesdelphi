object fmListNBU: TfmListNBU
  Left = 173
  Top = 107
  Caption = 'Nomenclador Unico Bioqu'#237'mico'
  ClientHeight = 355
  ClientWidth = 588
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 102
    Width = 588
    Height = 2
    Cursor = crVSplit
    Align = alTop
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 336
    Width = 588
    Height = 19
    Panels = <
      item
        Width = 450
      end
      item
        Width = 50
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 588
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      588
      25)
    object SpeedButton1: TSpeedButton
      Left = 110
      Top = 0
      Width = 43
      Height = 24
      Anchors = [akLeft, akTop, akBottom]
      Caption = '&Nuevo'
      Flat = True
      Layout = blGlyphTop
      Margin = 4
      ParentShowHint = False
      ShowHint = True
      Spacing = 2
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 153
      Top = 0
      Width = 43
      Height = 24
      Anchors = [akLeft, akTop, akBottom]
      Caption = '&Editar'
      Flat = True
      Layout = blGlyphTop
      Margin = 4
      ParentShowHint = False
      ShowHint = True
      Spacing = 2
      OnClick = SpeedButton2Click
    end
    object SpeedButton3: TSpeedButton
      Left = 196
      Top = 0
      Width = 43
      Height = 24
      Anchors = [akLeft, akTop, akBottom]
      Caption = '&Borrar'
      Flat = True
      Layout = blGlyphTop
      Margin = 4
      ParentShowHint = False
      ShowHint = True
      Spacing = 2
      OnClick = SpeedButton3Click
    end
    object SpeedButton4: TSpeedButton
      Left = 239
      Top = 0
      Width = 43
      Height = 24
      Anchors = [akLeft, akTop, akBottom]
      Caption = '&Listar'
      Flat = True
      Layout = blGlyphTop
      Margin = 4
      ParentShowHint = False
      ShowHint = True
      Spacing = 2
      OnClick = SpeedButton4Click
    end
    object SpeedButton5: TSpeedButton
      Left = 282
      Top = 0
      Width = 17
      Height = 24
      Hint = 'Sincronizar C'#243'digos con Nomenclaturas INOS'
      Anchors = [akLeft, akTop, akBottom]
      Caption = '&S'
      Flat = True
      Layout = blGlyphTop
      Margin = 4
      ParentShowHint = False
      ShowHint = True
      Spacing = 2
      OnClick = SpeedButton5Click
    end
    object DBNavigator: TDBNavigator
      Left = 0
      Top = 0
      Width = 110
      Height = 24
      DataSource = DTS
      VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbRefresh]
      Flat = True
      Hints.Strings = (
        'Primer Registro'
        'Registro Anterior'
        'Registro Siguiente'
        'Ultimo Registro'
        'Refrescar')
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object Panel7: TPanel
      Left = 328
      Top = 0
      Width = 260
      Height = 25
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object Label1: TLabel
        Left = 8
        Top = 4
        Width = 35
        Height = 13
        Caption = 'Criterio:'
      end
      object Label2: TLabel
        Left = 130
        Top = 4
        Width = 27
        Height = 13
        Caption = 'Expr.:'
      end
      object criterio: TComboBox
        Left = 46
        Top = 1
        Width = 81
        Height = 21
        ItemHeight = 13
        TabOrder = 0
        Text = 'Descripci'#243'n'
        OnChange = criterioChange
        OnClick = criterioClick
        Items.Strings = (
          'Descripci'#243'n'
          'C'#243'digo'
          'C'#243'digo N.N.N.')
      end
      object expresion: TMaskEdit
        Left = 160
        Top = 1
        Width = 95
        Height = 21
        TabOrder = 1
        OnChange = expresionChange
        OnKeyDown = expresionKeyDown
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 104
    Width = 588
    Height = 232
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    OnResize = Panel2Resize
    object DBGrid: TDBGrid
      Left = 0
      Top = 0
      Width = 588
      Height = 232
      Align = alClient
      BorderStyle = bsNone
      DataSource = DTS
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnDblClick = SpeedButton2Click
      OnKeyDown = DBGridKeyDown
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 25
    Width = 588
    Height = 77
    Align = alTop
    BevelOuter = bvNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Visible = False
    object Label3: TLabel
      Left = 5
      Top = 5
      Width = 107
      Height = 13
      Caption = 'Orden - Tipo de salida:'
    end
    object Label4: TLabel
      Left = 147
      Top = 6
      Width = 59
      Height = 13
      Alignment = taRightJustify
      Caption = 'Filtro Desde:'
    end
    object Label5: TLabel
      Left = 175
      Top = 28
      Width = 31
      Height = 13
      Caption = 'Hasta:'
    end
    object Label6: TLabel
      Left = 339
      Top = 11
      Width = 99
      Height = 13
      Caption = 'Dispositivo de salida:'
    end
    object desde: TMaskEdit
      Left = 209
      Top = 3
      Width = 128
      Height = 21
      TabOrder = 0
      OnClick = desdeClick
      OnKeyDown = desdeKeyDown
    end
    object hasta: TMaskEdit
      Left = 209
      Top = 26
      Width = 128
      Height = 21
      TabOrder = 1
      OnClick = hastaClick
      OnKeyDown = hastaKeyDown
    end
    object dispositivo: TComboBox
      Left = 343
      Top = 26
      Width = 135
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Text = 'Presentaci'#243'n Preliminar'
      OnKeyDown = dispositivoKeyDown
      Items.Strings = (
        'Presentaci'#243'n Preliminar'
        'Impresora')
    end
    object Panel4: TPanel
      Left = 512
      Top = 0
      Width = 76
      Height = 50
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 3
      object emitir: TBitBtn
        Left = 1
        Top = 2
        Width = 71
        Height = 22
        Caption = '&Emitir'
        TabOrder = 0
        OnClick = emitirClick
      end
      object cerrar: TBitBtn
        Left = 1
        Top = 26
        Width = 71
        Height = 21
        Caption = '&Cerrar'
        TabOrder = 1
        OnClick = cerrarClick
      end
    end
    object Panel5: TPanel
      Left = 5
      Top = 18
      Width = 135
      Height = 18
      BevelOuter = bvNone
      TabOrder = 4
      object codigo: TRadioButton
        Left = 0
        Top = 0
        Width = 55
        Height = 17
        Caption = '&C'#243'digo'
        TabOrder = 0
        OnClick = codigoClick
        OnKeyDown = codigoKeyDown
      end
      object alfabetico: TRadioButton
        Left = 64
        Top = 0
        Width = 70
        Height = 17
        Caption = '&Alfab'#233'tico'
        TabOrder = 1
        OnClick = alfabeticoClick
        OnKeyDown = alfabeticoKeyDown
      end
    end
    object Panel6: TPanel
      Left = 5
      Top = 34
      Width = 135
      Height = 17
      BevelOuter = bvNone
      TabOrder = 5
      object entorno: TRadioButton
        Left = 0
        Top = 0
        Width = 55
        Height = 17
        Caption = '&Entorno'
        TabOrder = 0
      end
      object exclusion: TRadioButton
        Left = 64
        Top = 0
        Width = 70
        Height = 17
        Caption = 'E&xclusi'#243'n'
        TabOrder = 1
      end
    end
    object Panel8: TPanel
      Left = 0
      Top = 50
      Width = 588
      Height = 27
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 6
      object RadioButton1: TRadioButton
        Left = 69
        Top = 5
        Width = 188
        Height = 17
        Caption = '&Listar N'#243'mina de Determinaciones'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object RadioButton2: TRadioButton
        Left = 265
        Top = 5
        Width = 188
        Height = 17
        Caption = 'Listar &Detalle de Equivalencias'
        TabOrder = 1
      end
    end
  end
  object DTS: TDataSource
    Left = 472
    Top = 57
  end
end
