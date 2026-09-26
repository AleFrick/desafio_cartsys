object FrmClientes: TFrmClientes
  Left = 0
  Top = 0
  Caption = 'Clientes'
  ClientHeight = 632
  ClientWidth = 978
  Color = 2467481
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 2763306
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 17
  object PnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 978
    Height = 78
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object LblTitle: TLabel
      Left = 24
      Top = 16
      Width = 69
      Height = 25
      Caption = 'Clientes'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblHint: TLabel
      Left = 24
      Top = 47
      Width = 232
      Height = 13
      Caption = 'Consulte, cadastre e edite os clientes do ERP.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object PnlToolbar: TPanel
    Left = 0
    Top = 78
    Width = 978
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    Color = 2368548
    ParentBackground = False
    TabOrder = 1
    object LblFiltro: TLabel
      Left = 16
      Top = 20
      Width = 52
      Height = 13
      Caption = 'Pesquisar:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LblConn: TLabel
      Left = 780
      Top = 20
      Width = 107
      Height = 13
      Caption = 'Banco desconectado'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object EdtFiltro: TEdit
      Left = 78
      Top = 12
      Width = 300
      Height = 25
      Hint = 'Digite para pesquisar em qualquer campo'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = EdtFiltroChange
    end
    object BtnNovo: TButton
      Left = 394
      Top = 12
      Width = 90
      Height = 32
      Caption = 'Novo'
      TabOrder = 1
      OnClick = BtnNovoClick
    end
    object BtnInativar: TButton
      Left = 492
      Top = 12
      Width = 90
      Height = 32
      Caption = 'Inativar'
      TabOrder = 2
      OnClick = BtnInativarClick
    end
  end
  object PnlGrid: TPanel
    Left = 0
    Top = 134
    Width = 978
    Height = 498
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object Grid: TDBGrid
      Left = 0
      Top = 0
      Width = 980
      Height = 506
      Align = alClient
      BorderStyle = bsNone
      DataSource = DS
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect]
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = 2763306
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = [fsBold]
      OnDblClick = GridDblClick
    end
  end
  object DS: TDataSource
    OnDataChange = DSDataChange
    Left = 928
    Top = 146
  end
end
