object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Cat'#225'logo de endere'#231'os'
  ClientHeight = 648
  ClientWidth = 1006
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    1006
    648)
  TextHeight = 15
  object ListarTodos: TButton
    Left = 480
    Top = 264
    Width = 185
    Height = 25
    Caption = 'Listar todos cadastrados'
    TabOrder = 0
    OnClick = ListarTodosClick
  end
  object EdCep: TLabeledEdit
    Left = 8
    Top = 48
    Width = 449
    Height = 23
    EditLabel.Width = 21
    EditLabel.Height = 15
    EditLabel.Caption = 'Cep'
    MaxLength = 8
    NumbersOnly = True
    TabOrder = 1
    Text = ''
  end
  object edEstado: TLabeledEdit
    Left = 8
    Top = 96
    Width = 449
    Height = 23
    CharCase = ecUpperCase
    EditLabel.Width = 35
    EditLabel.Height = 15
    EditLabel.Caption = 'Estado'
    MaxLength = 2
    TabOrder = 2
    Text = ''
  end
  object EdCidade: TLabeledEdit
    Left = 8
    Top = 144
    Width = 449
    Height = 23
    EditLabel.Width = 37
    EditLabel.Height = 15
    EditLabel.Caption = 'Cidade'
    TabOrder = 3
    Text = ''
  end
  object EdLogradouro: TLabeledEdit
    Left = 8
    Top = 200
    Width = 449
    Height = 23
    EditLabel.Width = 62
    EditLabel.Height = 15
    EditLabel.Caption = 'Logradouro'
    TabOrder = 4
    Text = ''
  end
  object btBuscarCep: TButton
    Left = 480
    Top = 47
    Width = 185
    Height = 25
    Caption = 'Buscar Endereco Por Cep'
    TabOrder = 5
    OnClick = btBuscarCepClick
  end
  object btBuscaCep: TButton
    Left = 480
    Top = 199
    Width = 185
    Height = 25
    Caption = 'Buscar Cep por Endere'#231'o'
    TabOrder = 6
    OnClick = btBuscaCepClick
  end
  object RgFormato: TRadioGroup
    Left = 8
    Top = 229
    Width = 449
    Height = 60
    Caption = 'Configura'#231#227'o para formato de dados'
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'JSON'
      'XML')
    TabOrder = 7
  end
  object PgResponse: TPageControl
    Left = 8
    Top = 295
    Width = 990
    Height = 322
    ActivePage = TsDados
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 8
    object TsDados: TTabSheet
      Caption = 'MetaDados'
      object mmResult: TMemo
        Left = 0
        Top = 0
        Width = 982
        Height = 292
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object TsGrid: TTabSheet
      Caption = 'Dados'
      ImageIndex = 1
      object GdDados: TDBGrid
        Left = 0
        Top = 0
        Width = 982
        Height = 292
        Align = alClient
        DataSource = dsDadosEndereco
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
  object BtDeletar: TButton
    Left = 671
    Top = 264
    Width = 185
    Height = 25
    Caption = 'Deletar todos cadastrados'
    TabOrder = 9
    OnClick = BtDeletarClick
  end
  object cdsDadosEndereco: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 736
    Top = 136
  end
  object dsDadosEndereco: TDataSource
    DataSet = cdsDadosEndereco
    Left = 736
    Top = 200
  end
  object ViaCepWS: TViaCepWS
    Left = 736
    Top = 64
  end
end
