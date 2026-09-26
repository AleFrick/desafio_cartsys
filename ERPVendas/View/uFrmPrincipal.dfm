object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'CARTSYS - ERP de Vendas'
  ClientHeight = 680
  ClientWidth = 1180
  Color = 2467481
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 2763306
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 17
  object PnlMenu: TPanel
    Left = 0
    Top = 92
    Width = 230
    Height = 588
    Align = alLeft
    BevelOuter = bvNone
    Color = 3552822
    ParentBackground = False
    TabOrder = 0
    ExplicitHeight = 580
    object LblLogo: TLabel
      Left = 28
      Top = 30
      Width = 103
      Height = 32
      Caption = 'CARTSYS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblMenuCaption: TLabel
      Left = 30
      Top = 68
      Width = 75
      Height = 13
      Caption = 'ERP de Vendas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 14540253
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object BtnInicio: TButton
      Left = 18
      Top = 125
      Width = 194
      Height = 44
      Caption = 'In'#237'cio'
      TabOrder = 0
      OnClick = BtnInicioClick
    end
    object BtnClientes: TButton
      Left = 18
      Top = 177
      Width = 194
      Height = 44
      Caption = 'Clientes'
      TabOrder = 1
      OnClick = BtnClientesClick
    end
    object BtnProdutos: TButton
      Left = 18
      Top = 231
      Width = 194
      Height = 44
      Caption = 'Produtos'
      TabOrder = 2
      OnClick = BtnProdutosClick
    end
    object BtnVendas: TButton
      Left = 18
      Top = 281
      Width = 194
      Height = 44
      Caption = 'Vendas'
      TabOrder = 3
      OnClick = BtnVendasClick
    end
    object BtnSair: TButton
      Left = 18
      Top = 610
      Width = 194
      Height = 44
      Caption = 'Sair'
      TabOrder = 4
      OnClick = BtnSairClick
    end
  end
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1180
    Height = 92
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    ExplicitWidth = 1178
    object LblPageTitle: TLabel
      Left = 32
      Top = 20
      Width = 105
      Height = 28
      Caption = 'Vis'#227'o geral'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblPageSubtitle: TLabel
      Left = 32
      Top = 54
      Width = 262
      Height = 13
      Caption = 'Acesso r'#65533'pido aos principais m'#65533'dulos do sistema.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LblConnection: TLabel
      Left = 680
      Top = 36
      Width = 73
      Height = 13
      Caption = 'Desconectado'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 180
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnConectar: TButton
      Left = 790
      Top = 29
      Width = 82
      Height = 32
      Caption = 'Conectar'
      TabOrder = 0
      OnClick = BtnConectarClick
    end
    object BtnDesconectar: TButton
      Left = 880
      Top = 29
      Width = 82
      Height = 32
      Caption = 'Desconectar'
      TabOrder = 1
      OnClick = BtnDesconectarClick
    end
  end
  object PnlContent: TPanel
    Left = 230
    Top = 92
    Width = 950
    Height = 588
    Align = alClient
    BevelOuter = bvNone
    Color = 2467481
    ParentBackground = False
    TabOrder = 2
    ExplicitWidth = 948
    ExplicitHeight = 580
    object CardClientes: TPanel
      Left = 32
      Top = 32
      Width = 278
      Height = 150
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object LblCardClientes: TLabel
        Left = 22
        Top = 22
        Width = 76
        Height = 15
        Caption = 'Clientes ativos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object LblClientesValue: TLabel
        Left = 22
        Top = 57
        Width = 11
        Height = 38
        Caption = '-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2763306
        Font.Height = -28
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object CardProdutos: TPanel
      Left = 334
      Top = 32
      Width = 278
      Height = 150
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object LblCardProdutos: TLabel
        Left = 22
        Top = 22
        Width = 82
        Height = 15
        Caption = 'Produtos ativos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object LblProdutosValue: TLabel
        Left = 22
        Top = 57
        Width = 11
        Height = 38
        Caption = '-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2763306
        Font.Height = -28
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object CardVendas: TPanel
      Left = 636
      Top = 32
      Width = 278
      Height = 150
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object LblCardVendas: TLabel
        Left = 22
        Top = 22
        Width = 37
        Height = 15
        Caption = 'Vendas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object LblVendasValue: TLabel
        Left = 22
        Top = 57
        Width = 11
        Height = 38
        Caption = '-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2763306
        Font.Height = -28
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
end
