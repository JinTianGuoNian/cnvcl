object FormDFT: TFormDFT
  Left = 192
  Top = 107
  Width = 955
  Height = 563
  Caption = 
    'DFT - Discrete Fourier Transform & NTT -  Number Theoretic Trans' +
    'form'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object grpDFT: TGroupBox
    Left = 8
    Top = 8
    Width = 913
    Height = 225
    Caption = 'DFT'
    TabOrder = 0
    object btnDFTButterFly: TButton
      Left = 24
      Top = 24
      Width = 89
      Height = 25
      Caption = 'DFT ButterFly'
      TabOrder = 0
      OnClick = btnDFTButterFlyClick
    end
    object edtDftButterFly: TEdit
      Left = 128
      Top = 24
      Width = 753
      Height = 21
      TabOrder = 1
    end
    object btnTwiddleFactors: TButton
      Left = 24
      Top = 72
      Width = 89
      Height = 25
      Caption = 'Twiddle Factors'
      TabOrder = 2
      OnClick = btnTwiddleFactorsClick
    end
    object edtTwiddleFactors: TEdit
      Left = 128
      Top = 72
      Width = 753
      Height = 21
      TabOrder = 3
    end
    object btnTestDFT: TButton
      Left = 24
      Top = 120
      Width = 89
      Height = 25
      Caption = 'Test FFT && IFFT'
      TabOrder = 4
      OnClick = btnTestDFTClick
    end
    object edtFFT: TEdit
      Left = 128
      Top = 120
      Width = 753
      Height = 21
      TabOrder = 5
    end
    object edtIFFT: TEdit
      Left = 128
      Top = 168
      Width = 753
      Height = 21
      TabOrder = 6
    end
  end
  object grpNTT: TGroupBox
    Left = 8
    Top = 240
    Width = 913
    Height = 273
    Caption = 'NTT'
    TabOrder = 1
    object btnNTTButterFly: TButton
      Left = 24
      Top = 24
      Width = 89
      Height = 25
      Caption = 'NTT ButterFly'
      TabOrder = 0
      OnClick = btnNTTButterFlyClick
    end
    object edtNttButterFly: TEdit
      Left = 128
      Top = 24
      Width = 753
      Height = 21
      TabOrder = 1
    end
    object btnNttFactors: TButton
      Left = 24
      Top = 72
      Width = 89
      Height = 25
      Caption = 'Ntt Factors'
      TabOrder = 2
      OnClick = btnNttFactorsClick
    end
    object edtNttFactors: TEdit
      Left = 128
      Top = 72
      Width = 753
      Height = 21
      TabOrder = 3
    end
    object btnTestNtt: TButton
      Left = 24
      Top = 120
      Width = 89
      Height = 25
      Caption = 'Test NTT && INTT'
      TabOrder = 4
      OnClick = btnTestNttClick
    end
    object edtNTT: TEdit
      Left = 128
      Top = 120
      Width = 753
      Height = 21
      TabOrder = 5
    end
    object edtINTT: TEdit
      Left = 128
      Top = 168
      Width = 753
      Height = 21
      TabOrder = 6
    end
  end
end
