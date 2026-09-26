object FrmVendas: TFrmVendas
  Left = 0
  Top = 0
  Caption = 'Vendas'
  ClientHeight = 640
  ClientWidth = 980
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
    Width = 980
    Height = 78
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 978
    object LblTitle: TLabel
      Left = 24
      Top = 16
      Width = 106
      Height = 25
      Caption = 'Nova venda'
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
      Width = 262
      Height = 13
      Caption = 'Informe o cliente e adicione os produtos da venda.'
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
    Width = 980
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Color = 2368548
    ParentBackground = False
    TabOrder = 1
    ExplicitWidth = 978
    object LblConn: TLabel
      Left = 780
      Top = 17
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
  end
  object PnlInput: TPanel
    Left = 0
    Top = 126
    Width = 980
    Height = 138
    Align = alTop
    BevelOuter = bvNone
    Color = 2467481
    ParentBackground = False
    TabOrder = 2
    ExplicitWidth = 978
    object LblCliente: TLabel
      Left = 24
      Top = 12
      Width = 39
      Height = 17
      Caption = 'Cliente'
    end
    object BtnSelecionarCliente: TSpeedButton
      Left = 644
      Top = 33
      Width = 32
      Height = 29
      Hint = 'Localizar cliente'
      Caption = #55357#56589
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -13
      Font.Name = 'Segoe UI Symbol'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = BtnSelecionarClienteClick
    end
    object LblProdutoID: TLabel
      Left = 24
      Top = 78
      Width = 63
      Height = 17
      Caption = 'Produto ID'
    end
    object LblProduto: TLabel
      Left = 128
      Top = 78
      Width = 47
      Height = 17
      Caption = 'Produto'
    end
    object BtnSelecionarProduto: TSpeedButton
      Left = 629
      Top = 98
      Width = 32
      Height = 29
      Hint = 'Localizar produto'
      Caption = #55357#56589
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -13
      Font.Name = 'Segoe UI Symbol'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = BtnSelecionarProdutoClick
    end
    object LblQtd: TLabel
      Left = 690
      Top = 78
      Width = 68
      Height = 17
      Caption = 'Quantidade'
    end
    object BtnAdicionarItem: TSpeedButton
      Left = 800
      Top = 98
      Width = 34
      Height = 29
      Hint = 'Adicionar item'
      Caption = '+'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = BtnAdicionarItemClick
    end
    object EdtCliente: TEdit
      Left = 24
      Top = 34
      Width = 620
      Height = 25
      Enabled = False
      TabOrder = 0
    end
    object EdtProdutoID: TEdit
      Left = 24
      Top = 99
      Width = 90
      Height = 25
      TabOrder = 1
      OnExit = EdtProdutoIDExit
      OnKeyPress = EdtProdutoIDKeyPress
    end
    object EdtProduto: TEdit
      Left = 128
      Top = 99
      Width = 500
      Height = 25
      Enabled = False
      TabOrder = 2
    end
    object EdtQtd: TEdit
      Left = 690
      Top = 99
      Width = 100
      Height = 25
      TabOrder = 3
      OnKeyPress = EdtQtdKeyPress
    end
  end
  object PnlGrid: TPanel
    Left = 0
    Top = 264
    Width = 980
    Height = 326
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 3
    ExplicitWidth = 978
    ExplicitHeight = 318
    object LblTotal: TLabel
      Left = 846
      Top = 275
      Width = 114
      Height = 25
      Alignment = taRightJustify
      Caption = 'Total: R$ 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Grid: TStringGrid
      Left = 0
      Top = 0
      Width = 980
      Height = 245
      Align = alTop
      ColCount = 4
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2763306
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
      ParentFont = False
      TabOrder = 0
      OnDblClick = GridDblClick
      ExplicitWidth = 978
    end
  end
  object PnlFooter: TPanel
    Left = 0
    Top = 590
    Width = 980
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 4
    ExplicitTop = 582
    ExplicitWidth = 978
    object BtnLimpar: TButton
      Left = 16
      Top = 8
      Width = 90
      Height = 34
      Caption = 'Limpar'
      TabOrder = 0
      OnClick = BtnLimparClick
    end
    object BtnCancelar: TButton
      Left = 704
      Top = 8
      Width = 90
      Height = 34
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = BtnCancelarClick
    end
    object BtnGravar: TButton
      Left = 804
      Top = 8
      Width = 90
      Height = 34
      Caption = 'Gravar venda'
      Default = True
      TabOrder = 2
      OnClick = BtnGravarClick
    end
    object BtnFechar: TButton
      Left = 904
      Top = 8
      Width = 60
      Height = 34
      Caption = 'Fechar'
      TabOrder = 3
      OnClick = BtnFecharClick
    end
  end
end
