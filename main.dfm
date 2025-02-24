object MainForm: TMainForm
  Left = 624
  Height = 330
  Top = 127
  Width = 760
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsNone
  Caption = 'MK85'
  ClientHeight = 330
  ClientWidth = 760
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  KeyPreview = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  OnShow = FormShow
  Position = poScreenCenter
  LCLVersion = '2.2.6.0'
  object FaceImage: TImage
    Left = 0
    Height = 330
    Top = 0
    Width = 760
    OnMouseDown = FaceMouseDown
    OnMouseMove = FaceMouseMove
    OnMouseUp = FaceMouseUp
  end
  object LcdImage: TImage
    Left = 70
    Height = 51
    Top = 41
    Width = 227
  end
  object lbClose: TLabel
    Left = -1
    Height = 16
    Hint = 'Close'
    Top = 8
    Width = 26
    Caption = '  X  '
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = lbCloseClick
  end
  object RefreshTimer: TTimer
    Enabled = False
    Interval = 32
    OnTimer = OnRefreshTimer
    Left = 32
    Top = 8
  end
  object CursorTimer: TTimer
    Enabled = False
    Interval = 400
    OnTimer = OnCursorTimer
    Left = 32
    Top = 64
  end
  object RunTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = OnRunTimer
    Left = 32
    Top = 120
  end
  object AutoRunTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = AutoRunTimerTimer
    Left = 32
    Top = 176
  end
  object TeleTypeTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TeleTypeTimerTimer
    Left = 133
    Top = 172
  end
end
