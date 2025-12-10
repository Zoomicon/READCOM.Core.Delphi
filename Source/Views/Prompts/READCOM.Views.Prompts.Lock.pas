//Description: READ-COM Lock prompt
//Author: George Birbilis (http://zoomicon.com)

unit READCOM.Views.Prompts.Lock;

interface
  {$region 'Used units'}
  uses
    System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
    //
    FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
    FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation,
    FMX.Objects, FMX.SVGIconImage, FMX.ImgList, FMX.Layouts,
    FMX.ActnList,
    //
    Zoomicon.Media.FMX.ModalFrame; //for TModalFrame
  {$endregion}

const
  IMAGES_LOCKED = 32;
  IMAGES_UNLOCKED = 33;

type
  TLockFrame = class(TModalFrame)

  protected
    const
      DEFAULT_LOCKED = true;

    class function GetLockFrame: TLockFrame; static;

    {Locked}
    class function IsLocked_Modal: Boolean; static;
    class procedure SetLocked_Modal(const Value: Boolean); static;

    function IsLocked: Boolean;
    procedure SetLocked(const Value: Boolean);

  public
    constructor Create(AOwner: TComponent); override;

    class property LockFrame: TLockFrame read GetLockFrame;
    class property Locked_Modal: Boolean read IsLocked_Modal write SetLocked_Modal default DEFAULT_LOCKED;

  published
    property Locked: Boolean read IsLocked write SetLocked default DEFAULT_LOCKED;
  end;

implementation

{$R *.fmx}

  {$region 'Initialization'}

  constructor TLockFrame.Create(AOwner: TComponent);
  begin
    inherited;
    Locked := DEFAULT_LOCKED;
  end;

  {$endregion}

  {$region 'Properties'}

  {$region 'Locked_Modal'}

  class function TLockFrame.IsLocked_Modal: Boolean;
  begin
    result := LockFrame.IsLocked;
  end;

  class procedure TLockFrame.SetLocked_Modal(const Value: Boolean);
  begin
    LockFrame.SetLocked(Value);
  end;

  {$endregion}

  {$region 'Locked'}

  function TLockFrame.IsLocked: Boolean;
  begin
    result := (GlyphIcon.ImageIndex = IMAGES_LOCKED);
  end;

  procedure TLockFrame.SetLocked(const Value: Boolean);
  var
    LImageIndex: Integer;
  begin
    if Value then
      LImageIndex := IMAGES_LOCKED
    else
      LImageIndex := IMAGES_UNLOCKED;

    GlyphIcon.ImageIndex := LImageIndex;
  end;

  {$endregion}

  {$endregion}

  {$region 'Methods'}

  class function TLockFrame.GetLockFrame: TLockFrame;
  begin
    result := (Frame as TLockFrame);
  end;

  {$endregion'}

end.