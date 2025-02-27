object DebugForm: TDebugForm
  Left = 473
  Height = 486
  Top = 139
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
  OnDestroy = DebugDestroy
  OnHide = DebugHide
  OnResize = FormResize
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
    Left = 392
    Height = 184
    Top = 288
    Width = 488
    Anchors = [akRight, akBottom]
    Caption = ' Binary Editor (RAM)'
    ClientHeight = 166
    ClientWidth = 484
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
      Width = 468
      Anchors = [akTop, akLeft, akRight, akBottom]
      BevelOuter = bvNone
      ClientHeight = 148
      ClientWidth = 468
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
        Width = 454
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
        Left = 454
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
      Left = 32
      Top = 0
      Action = aAnimate
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton3: TToolButton
      Left = 120
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
      Left = 64
      Top = 0
      Action = aAddBreakPoint
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton6: TToolButton
      Left = 56
      Height = 23
      Top = 0
      Caption = 'ToolButton6'
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 152
      Top = 0
      Action = aByteWordToogle
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton7: TToolButton
      Left = 112
      Height = 23
      Top = 0
      Caption = 'ToolButton7'
      Style = tbsSeparator
    end
    object ToolButton8: TToolButton
      Left = 184
      Top = 0
      Action = aCopyAddr
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton9: TToolButton
      Left = 176
      Height = 23
      Top = 0
      Caption = 'ToolButton9'
      Style = tbsSeparator
    end
    object ToolButton10: TToolButton
      Left = 88
      Top = 0
      Action = aRunForBreakPoint
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton11: TToolButton
      Left = 144
      Height = 23
      Top = 0
      Caption = 'ToolButton11'
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
  object GroupBox1: TGroupBox
    Left = 16
    Height = 184
    Top = 288
    Width = 361
    Anchors = [akLeft, akRight, akBottom]
    Caption = ' Break points '
    ClientHeight = 166
    ClientWidth = 357
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    object lwBreakPoint: TListView
      Left = 8
      Height = 154
      Top = 4
      Width = 338
      Anchors = [akTop, akLeft, akRight, akBottom]
      Columns = <      
        item
          Caption = 'Addres'
          Width = 69
        end      
        item
          Caption = 'Rem'
          Width = 400
        end>
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Pitch = fpFixed
      Font.Style = [fsBold]
      Items.LazData = {
        4E00000002000000FFFFFFFFFFFFFFFFFFFFFFFF000000000F000000D0ADD0BB
        D0B5D0BCD0B5D0BDD18230FFFFFFFFFFFFFFFFFFFFFFFF000000000F000000D0
        ADD0BBD0B5D0BCD0B5D0BDD18231
      }
      ParentFont = False
      PopupMenu = ppBreakPoint
      ReadOnly = True
      RowSelect = True
      ScrollBars = ssVertical
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lwBreakPointDblClick
    end
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
      ImageIndex = 6
      OnExecute = aNumberOfStepExecute
    end
    object aByteWordToogle: TAction
      Caption = 'Byte/Word'
      Hint = 'Byte/Word'
      ImageIndex = 4
      OnExecute = aByteWordToogleExecute
    end
    object aRunForBreakPoint: TAction
      Caption = 'Run'
      Hint = 'Run'
      ImageIndex = 1
      OnExecute = aRunForBreakPointExecute
    end
    object aDeleteBreakPoint: TAction
      Caption = 'Delete'
      Hint = 'Delete break point'
      OnExecute = aDeleteBreakPointExecute
    end
    object aEditBreakPoint: TAction
      Caption = 'Edit...'
      Hint = 'Edit break point'
      OnExecute = aEditBreakPointExecute
    end
    object aAddBreakPoint: TAction
      Caption = 'Add...'
      Hint = 'Add break point'
      ImageIndex = 3
      OnExecute = aAddBreakPointExecute
    end
  end
  object ilEnabledButtonIcon: TImageList
    Left = 376
    Top = 64
    Bitmap = {
      4C7A070000001000000010000000970100000000000078DAED98CD4A033110C7
      17FA48DE7D013DF8143E80A77D015F454F3D8914443D8B7A2A5EFCA050104ADB
      83ABA5DA93A373C812433E6632B36D852CFCD9CDEEFC2699D90C09692AA89A35
      E9F70223099BE323C5C7FC725854AFEA8184D7F82E8D4F2BBF549F213BE9B8B8
      F32EF40FD73147A535B2ED2AF5BFB9FAE7E6C6E58FFB7B609453FF291FD4B1A7
      C611B3F72955FF1C9EF20F387994C6AEC596FAD7A97FBBCDF58FF7B37A1750B9
      EB77577C2C06DBDEE5EDE750DF36137A8EC9D8854459FFB96C2C8ED4B873F3AF
      157FA9FFED5BFFA5EBF7CEFE3DB8A2F23E96E223C5BA3EA4BC4F39BCA47F8DF1
      E7E69F9B872EEB9CBAD7D2D8AF71D8980F2A1BF2617FBB7E3885BBE741DBBE7D
      3A87ABE10999FF5CAC00BEA16DE3F5F1B624F3E3D717582DBFDAF6E2BD81E97C
      42E65137C38B3FEDD1F891C577F90FA473A0EB39ACB9EFDEE47E5DA2BAAEC156
      CAFEE8720E878319F858DB07DAA0ADCBE37BC3C714B233EFA92A7CE135798E8F
      72FE57CEFFFED3F97FE8DC837AFE77D09F00CA7DA6C8D8FB443DFFA7F6EF8B21
      B77F3B0792F853FA016F2B7710
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
      Action = aAddBreakPoint
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
  object ppBreakPoint: TPopupMenu
    OnPopup = ppBreakPointPopup
    Left = 200
    Top = 362
    object MenuItem10: TMenuItem
      Action = aRunForBreakPoint
    end
    object Separator4: TMenuItem
      Caption = '-'
    end
    object MenuItem7: TMenuItem
      Action = aAddBreakPoint
    end
    object MenuItem8: TMenuItem
      Action = aEditBreakPoint
    end
    object MenuItem9: TMenuItem
      Action = aDeleteBreakPoint
    end
  end
end
