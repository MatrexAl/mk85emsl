object DebugForm: TDebugForm
  Left = 676
  Height = 486
  Top = 164
  Width = 895
  Anchors = [akTop, akRight]
  Caption = 'Debug Window'
  ClientHeight = 486
  ClientWidth = 895
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Pitch = fpFixed
  OnCreate = DebugCreate
  OnHide = DebugHide
  OnShow = DebugShow
  Position = poDefault
  LCLVersion = '2.2.6.0'
  object cbDisassemply: TGroupBox
    Left = 216
    Height = 222
    Top = 48
    Width = 664
    Anchors = [akTop, akLeft, akRight, akBottom]
    Caption = ' Disassembly (ROM) '
    ClientHeight = 204
    ClientWidth = 660
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object ListPanel: TPanel
      Left = 8
      Height = 189
      Top = 8
      Width = 644
      Anchors = [akTop, akLeft, akRight, akBottom]
      BevelOuter = bvNone
      ClientHeight = 189
      ClientWidth = 644
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Pitch = fpFixed
      ParentFont = False
      TabOrder = 0
      OnClick = ListPanelClick
      object ListPaintBox: TPaintBox
        Left = 0
        Height = 189
        Top = 0
        Width = 628
        Align = alClient
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier'
        Font.Pitch = fpFixed
        ParentFont = False
        PopupMenu = ppPopupMenu
        OnMouseDown = ListPaintBoxMouseDown
        OnPaint = ListPaintBoxPaint
      end
      object ListScrollBar: TScrollBar
        Left = 628
        Height = 189
        Top = 0
        Width = 16
        Align = alRight
        Kind = sbVertical
        PageSize = 0
        TabOrder = 1
        TabStop = False
        OnScroll = ListBoxScroll
      end
      object ListEdit: TEdit
        Left = 16
        Height = 13
        Top = 10
        Width = 40
        BorderStyle = bsNone
        Color = clYellow
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier'
        Font.Pitch = fpFixed
        MaxLength = 4
        OnChange = ListEditChange
        OnKeyDown = ListEditKeyDown
        ParentFont = False
        TabStop = False
        TabOrder = 0
      end
    end
  end
  object cbRegisters: TGroupBox
    Left = 16
    Height = 222
    Top = 48
    Width = 185
    Anchors = [akTop, akLeft, akBottom]
    Caption = ' Registers '
    ClientHeight = 204
    ClientWidth = 181
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object RegPanel: TPanel
      Left = 8
      Height = 189
      Top = 8
      Width = 164
      Anchors = [akTop, akLeft, akRight, akBottom]
      BevelOuter = bvNone
      ClientHeight = 189
      ClientWidth = 164
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Pitch = fpFixed
      ParentFont = False
      TabOrder = 0
      OnClick = RegPanelClick
      object RegPaintBox: TPaintBox
        Left = 0
        Height = 189
        Top = 0
        Width = 150
        Align = alClient
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier'
        Font.Pitch = fpFixed
        ParentFont = False
        PopupMenu = ppPopupMenu
        OnMouseDown = RegPaintBoxMouseDown
        OnPaint = RegPaintBoxPaint
      end
      object RegScrollBar: TScrollBar
        Left = 150
        Height = 189
        Top = 0
        Width = 14
        Align = alRight
        Kind = sbVertical
        Max = 0
        PageSize = 0
        TabOrder = 1
        TabStop = False
        OnScroll = RegBoxScroll
      end
      object RegEdit: TEdit
        Left = 16
        Height = 13
        Top = 10
        Width = 40
        BorderStyle = bsNone
        CharCase = ecUppercase
        Color = clYellow
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier'
        Font.Pitch = fpFixed
        MaxLength = 4
        OnChange = RegEditChange
        OnKeyDown = RegEditKeyDown
        ParentFont = False
        TabStop = False
        TabOrder = 0
      end
    end
  end
  object gbBinEditor: TGroupBox
    Left = 16
    Height = 184
    Top = 288
    Width = 864
    Anchors = [akLeft, akRight, akBottom]
    Caption = ' Binary Editor (RAM)'
    ClientHeight = 166
    ClientWidth = 860
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    object BinPanel: TPanel
      Left = 8
      Height = 148
      Top = 8
      Width = 844
      Anchors = [akTop, akLeft, akRight, akBottom]
      BevelOuter = bvNone
      ClientHeight = 148
      ClientWidth = 844
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Pitch = fpFixed
      ParentFont = False
      TabOrder = 0
      OnClick = BinPanelClick
      object BinPaintBox: TPaintBox
        Left = 0
        Height = 148
        Top = 0
        Width = 830
        Align = alClient
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier'
        Font.Pitch = fpFixed
        ParentFont = False
        PopupMenu = ppPopupMenu
        OnMouseDown = BinPaintBoxMouseDown
        OnPaint = BinPaintBoxPaint
      end
      object BinScrollBar: TScrollBar
        Left = 830
        Height = 148
        Top = 0
        Width = 14
        Align = alRight
        Kind = sbVertical
        PageSize = 0
        TabOrder = 1
        TabStop = False
        OnScroll = BinBoxScroll
      end
      object BinEdit: TEdit
        Left = 16
        Height = 13
        Top = 16
        Width = 40
        BorderStyle = bsNone
        Color = clYellow
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier'
        Font.Pitch = fpFixed
        MaxLength = 4
        OnChange = BinEditChange
        OnKeyDown = BinEditKeyDown
        ParentFont = False
        TabStop = False
        TabOrder = 0
      end
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Height = 29
    Top = 6
    Width = 895
    ButtonHeight = 23
    ButtonWidth = 24
    Caption = 'ToolBar1'
    EdgeBorders = []
    Images = ilEnabledButtonIcon
    TabOrder = 3
    object ToolButton1: TToolButton
      Left = 8
      Top = 0
      Action = aStep
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton2: TToolButton
      Left = 88
      Top = 0
      Action = aAnimate
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton3: TToolButton
      Left = 32
      Top = 0
      Action = aNumberOfStep
      ParentShowHint = False
      ShowHint = True
    end
    object Panel1: TPanel
      Left = 1
      Height = 23
      Top = 0
      Width = 7
      BevelOuter = bvNone
      TabOrder = 0
    end
    object ToolButton5: TToolButton
      Left = 56
      Top = 0
      Action = aBreakPoint
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton6: TToolButton
      Left = 112
      Height = 23
      Top = 0
      Caption = 'ToolButton6'
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 120
      Top = 0
      Action = aByteWordToogle
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton7: TToolButton
      Left = 80
      Height = 23
      Top = 0
      Caption = 'ToolButton7'
      Style = tbsSeparator
    end
    object ToolButton8: TToolButton
      Left = 152
      Top = 0
      Action = aCopyAddr
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton9: TToolButton
      Left = 144
      Height = 23
      Top = 0
      Caption = 'ToolButton9'
      Style = tbsSeparator
    end
  end
  object Bevel1: TBevel
    Left = 0
    Height = 3
    Top = 35
    Width = 895
    Align = alTop
    Shape = bsTopLine
  end
  object Bevel2: TBevel
    Left = 0
    Height = 6
    Top = 0
    Width = 895
    Align = alTop
    Shape = bsSpacer
  end
  object AutoRunTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = AutoRunTimerTimer
    Left = 536
  end
  object alActionList: TActionList
    Left = 320
    Top = 64
    object aCopyAddr: TAction
      Caption = 'Copy now addres (OCT)'
      Hint = 'Copy now addres (OCT)'
      ImageIndex = 5
      OnExecute = aCopyAddrExecute
    end
    object aStep: TAction
      Caption = 'Step'
      Hint = 'Step'
      ImageIndex = 0
      OnExecute = aStepExecute
      ShortCut = 119
    end
    object aAnimate: TAction
      Caption = 'Animate'
      Hint = 'Animate'
      ImageIndex = 2
      OnExecute = aAnimateExecute
    end
    object aNumberOfStep: TAction
      Caption = 'Number of step...'
      Hint = 'Number of step'
      ImageIndex = 1
      OnExecute = aNumberOfStepExecute
    end
    object aBreakPoint: TAction
      Caption = 'Breakpoint address...'
      Hint = 'Breakpoint address'
      ImageIndex = 3
      OnExecute = aBreakPointExecute
    end
    object aByteWordToogle: TAction
      Caption = 'Byte/Word'
      Hint = 'Byte/Word'
      ImageIndex = 4
      OnExecute = aByteWordToogleExecute
    end
  end
  object ilEnabledButtonIcon: TImageList
    Left = 376
    Top = 64
    Bitmap = {
      4C7A0600000010000000100000006F0100000000000078DAED96C16A02311086
      177CA4DEFB02F639FA009EF605FA2A7AEAA91441B4E7A23D8917DB521004510F
      6E2BB69E1C9B43961836C94C66563D64E16737BBF3FD9B4C32244506597126FD
      5FA0C561633C42BCCF97C22A35B206707889EFDCF149E517EBE98AE3F68BBAEE
      5C73788E35CAAD916B57AAFFCBD53F353736FFF0D804AD98FA0F7960FB1EEA87
      2FBE4AA1FAA7F09839A0E4913B762936D5BF4CFD9B6DAABFBA3FE5B7A014BB7F
      D7C5FBC660C6DBBCF9ECFAB7C9B89E7DD2712E61F67F2AEB1B47A8DFB1F9971A
      7FAAFFEBDBFFB9FBF7CDDD1BD8C2F2552CC623C4DA1E5CBE4A313CE7FF12FD8F
      CD3F350F75D639F6AC25715EA3B03E0F2CEBF230BFBD4C3A30FAE896EDE1FB33
      0CC66D34FFBBDD031CA06CABEB67B343F3B3F927EC777F657BFB5DC072BD40F3
      4AAFE3DE49FB6B3625F175CE01770DD4BD8625CFDD973CAF7394E739980AC5B7
      FA6BB8EFAEA08A353D548C8AB579F55EF33EB9E2F47BAC129F78499EE22159A7
      477457B74E
    }
  end
  object ppPopupMenu: TPopupMenu
    Left = 322
    Top = 165
    object MenuItem1: TMenuItem
      Action = aStep
    end
    object MenuItem2: TMenuItem
      Action = aNumberOfStep
    end
    object MenuItem3: TMenuItem
      Action = aBreakPoint
    end
    object Separator1: TMenuItem
      Caption = '-'
    end
    object MenuItem4: TMenuItem
      Action = aAnimate
    end
    object Separator2: TMenuItem
      Caption = '-'
    end
    object MenuItem5: TMenuItem
      Action = aByteWordToogle
    end
    object Separator3: TMenuItem
      Caption = '-'
    end
    object MenuItem6: TMenuItem
      Action = aCopyAddr
    end
  end
end
