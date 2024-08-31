object Form1: TForm1
  Left = 192
  Top = 107
  Width = 701
  Height = 482
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid: TDBGrid
    Left = 8
    Top = 40
    Width = 681
    Height = 409
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 233
    Height = 21
    TabOrder = 0
    OnChange = Edit1Change
  end
  object IBTable: TIBTable
    Database = IBDatabase1
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    FieldDefs = <
      item
        Name = 'CODPREST'
        DataType = ftString
        Size = 5
      end
      item
        Name = 'NOMBRE'
        DataType = ftString
        Size = 70
      end
      item
        Name = 'DIRECCION'
        DataType = ftString
        Size = 40
      end
      item
        Name = 'CP'
        DataType = ftString
        Size = 4
      end
      item
        Name = 'ORDEN'
        DataType = ftString
        Size = 3
      end>
    IndexDefs = <
      item
        Name = 'PRESTATARIOS0'
        Fields = 'CODPREST'
        Options = [ixUnique]
      end
      item
        Name = 'PRESTATARIOS_NOMBRE'
        Fields = 'NOMBRE'
      end>
    StoreDefs = True
    TableName = 'PRESTATARIOS'
    Left = 504
    Top = 24
  end
  object IBTransaction: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 584
    Top = 24
  end
  object DataSource1: TDataSource
    DataSet = IBTable
    Left = 608
    Top = 80
  end
  object IBDatabase1: TIBDatabase
    DatabaseName = 'C:\sidelphi32\SGen\asociacion\interbase1\ADRRECONQUISTA.GDB'
    Params.Strings = (
      'user_name=sysdba')
    DefaultTransaction = IBTransaction
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 464
    Top = 24
  end
end
