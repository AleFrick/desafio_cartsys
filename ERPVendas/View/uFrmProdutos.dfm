object FrmProdutos: TFrmProdutos
  Left = 0
  Top = 0
  Caption = 'Produtos'
  ClientHeight = 640
  ClientWidth = 980
  Color = 2467481
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 2763306
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 16
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  object PnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 980
    Height = 78
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object LblTitle: TLabel
      Left = 24
      Top = 16
      Width = 300
      Height = 28
      Caption = 'Produtos'
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
      Width = 430
      Height = 18
      Caption = 'Cadastre e mantenha o catálogo de produtos.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421504
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object PnlToolbar: TPanel
    Left = 0
    Top = 78
    Width = 980
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Color = 2368548
    ParentBackground = False
    TabOrder = 1
    object LblFiltro: TLabel
      Left = 16
      Top = 17
      Width = 52
      Height = 17
      Caption = 'Pesquisar:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object EdtFiltro: TEdit
      Left = 74
      Top = 9
      Width = 280
      Height = 30
      TabOrder = 0
      OnChange = EdtFiltroChange
    end
    object BtnNovo: TButton
      Left = 370
      Top = 8
      Width = 90
      Height = 32
      Caption = 'Novo'
      TabOrder = 1
      OnClick = BtnNovoClick
    end
    object BtnInativar: TButton
      Left = 468
      Top = 8
      Width = 90
      Height = 32
      Caption = 'Inativar'
      TabOrder = 2
      OnClick = BtnInativarClick
    end
    object LblConn: TLabel
      Left = 780
      Top = 17
      Width = 150
      Height = 18
      Caption = 'Banco desconectado'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421504
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object PnlGrid: TPanel
    Left = 0
    Top = 126
    Width = 980
    Height = 514
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object Grid: TDBGrid
      Left = 16
      Top = 12
      Width = 948
      Height = 490
      Align = alClient
      BorderStyle = bsNone
      DataSource = DS
      OnDblClick = GridDblClick
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
    end
  end
  object DS: TDataSource
    Left = 928
    Top = 146
    OnDataChange = DSDataChange
  end
end
