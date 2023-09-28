inherited DInter: TDInter
  Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1092#1086#1088#1084#1091#1083#1091
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited pnText: TRbPanel
        BevelOuter = bvLowered
      end
      inherited pnObj: TRbPanel
        BevelOuter = bvNone
        Place = rpTop
        object stFml: TRbStatus
          Tag = -1
          Left = 28
          Top = 7
          Width = 467
          Height = 36
          MinSized = False
          ParentSchem = False
          Schem = 'Status'
          Alignment = taLeftJustify
          BevelOuter = bvLowered
        end
        object pnRes: TRbPanel
          Left = 28
          Top = 56
          Width = 474
          Height = 121
          MinSized = False
          ParentSchem = False
          Schem = 'EdTxt'
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 100
          SortMode = smDefault
          SortObj = True
          BevelOuter = bvNone
          HMin = 0
          Place = rpBottom
          SayRight = False
          TabOrder = 1
          WMin = 0
          object stRes: TRbStatus
            Tag = -1
            Left = 14
            Top = 78
            Width = 446
            Height = 36
            MinSized = False
            ParentSchem = False
            Schem = 'Status'
            Alignment = taLeftJustify
            BevelOuter = bvLowered
          end
          object pnRes1: TRbPanel
            Left = 35
            Top = 14
            Width = 396
            Height = 57
            MinSized = False
            ParentSchem = True
            Schem = 'EdTxt'
            CanSize = False
            CanMove = False
            MaxWidth = False
            Header = #1056#1077#1079#1091#1083#1100#1090#1072#1090
            ProcentWnd = 100
            SortMode = smDefault
            SortObj = True
            BevelOuter = bvLowered
            HMin = 0
            Place = rpNone
            SayRight = False
            TabOrder = 1
            WMin = 0
            OnResize = pnRes1Resize
          end
        end
      end
    end
  end
end
