object fmDiagnosticoNutricional: TfmDiagnosticoNutricional
  Left = 298
  Top = 238
  Width = 376
  Height = 136
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Diagn'#243'stico Nutricional'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 90
    Width = 368
    Height = 19
    Panels = <
      item
        Width = 300
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object Panel5: TPanel
    Left = 0
    Top = 22
    Width = 368
    Height = 68
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    TabOrder = 1
    OnResize = Panel5Resize
    object Label5: TLabel
      Left = 10
      Top = 37
      Width = 59
      Height = 13
      Caption = 'Descripci'#243'n:'
    end
    object Label1: TLabel
      Left = 41
      Top = 12
      Width = 28
      Height = 13
      Alignment = taRightJustify
      Caption = 'Items:'
    end
    object descrip: TMaskEdit
      Left = 72
      Top = 35
      Width = 278
      Height = 21
      TabOrder = 0
      OnKeyDown = descripKeyDown
    end
    object items: TMaskEdit
      Left = 72
      Top = 11
      Width = 30
      Height = 21
      TabOrder = 1
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 368
    Height = 22
    Caption = 'ToolBar1'
    EdgeBorders = []
    Flat = True
    Images = contenedorImg.ImagenesForms
    TabOrder = 2
    object DBNavigator: TDBNavigator
      Left = 0
      Top = 0
      Width = 96
      Height = 22
      DataSource = DTS
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
      OnClick = DBNavigatorClick
    end
    object Alta: TToolButton
      Left = 96
      Top = 0
      Hint = 'Agregar Registro'
      Caption = 'Alta'
      ImageIndex = 4
      ParentShowHint = False
      ShowHint = True
      OnClick = AltaClick
    end
    object Baja: TToolButton
      Left = 119
      Top = 0
      Hint = 'Eliminar Registro'
      Caption = 'Baja'
      ImageIndex = 5
      ParentShowHint = False
      ShowHint = True
    end
    object Modificar: TToolButton
      Left = 142
      Top = 0
      Hint = 'Modificar Datos'
      Caption = 'Modificar'
      ImageIndex = 6
      ParentShowHint = False
      ShowHint = True
    end
    object Buscar: TToolButton
      Left = 165
      Top = 0
      Hint = 'Buscar ...'
      Caption = 'Buscar'
      ImageIndex = 7
      ParentShowHint = False
      ShowHint = True
    end
    object Deshacer: TToolButton
      Left = 188
      Top = 0
      Hint = 'Deshacer'
      Caption = 'Deshacer'
      ImageIndex = 8
      ParentShowHint = False
      ShowHint = True
    end
    object Salir: TToolButton
      Left = 211
      Top = 0
      Caption = 'Salir'
      ImageIndex = 9
      OnClick = SalirClick
    end
  end
  object DTS: TDataSource
    Left = 296
    Top = 8
  end
end
