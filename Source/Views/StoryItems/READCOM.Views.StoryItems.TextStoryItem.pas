//Description: READ-COM TextStoryItem View
//Author: George Birbilis (http://zoomicon.com)

unit READCOM.Views.StoryItems.TextStoryItem;

interface
  {$region 'Used units'}
  uses
    System.SysUtils,
    System.Types,
    System.UITypes,
    System.Classes,
    System.Variants,
    //
    FMX.Types,
    FMX.Graphics,
    FMX.Controls,
    FMX.Forms,
    FMX.Dialogs,
    FMX.StdCtrls,
    FMX.Objects,
    FMX.SVGIconImage,
    FMX.ExtCtrls,
    FMX.Controls.Presentation,
    FMX.ScrollBox,
    FMX.Memo,
    FMX.Memo.Types,
    FMX.Layouts,
    FMX.Clipboard, //for IFMXExtendedClipboardService
    //
    Zoomicon.Media.FMX.Models, //for IClipboardEnabled
    Zoomicon.Media.FMX.MediaDisplay, //for TMediaDisplay (Glyph)
    //
    READCOM.Models, //for IClipboardEnabled, IStoreable, EXT_READCOM
    READCOM.Models.Stories, //for IStoryItem, ITextStoryItem
    READCOM.Views.StoryItems.StoryItem; //for TStoryItem
    {$endregion}

  const
    EXT_TXT = '.txt';
    FILTER_TEXT_TITLE = 'Text (*.txt)';
    FILTER_TEXT_EXTS = '*' + EXT_TXT;
    FILTER_TEXT = FILTER_TEXT_TITLE + '|' + FILTER_TEXT_EXTS;

  resourcestring
    DEFAULT_TEXT = '......' + sLineBreak + '......';

  type

    {$REGION 'TTextStoryItem' ----------------------------------------------------------}

    TTextStoryItem = class(TStoryItem, ITextStoryItem, IStoryItem, IClipboardEnabled, IStoreable)
      Memo: TMemo;
      procedure MemoApplyStyleLookup(Sender: TObject);

    //--- Methods ---

    protected
      FEditable: Boolean;
      FLastMemoSize: TSizeF;
      //FLastFontSize: Single;

      //procedure Loaded; override;
      procedure MemoResized(Sender: TObject);
      procedure MemoChangeTracking(Sender: TObject);
      procedure ForceRenderMemoOutlineToImage;

      {Z-Order}
      function GetBackIndex: Integer; override;
      procedure SetMemoZorder;

      {DefaultSize}
      function GetDefaultSize: TSizeF; override;

      {Active}
      procedure SetActive(const Value: Boolean); override;

      {EditMode}
      procedure SetEditMode(const Value: Boolean); override;

      {Text}
      function GetText: String;
      procedure SetText(const Value: String);

      {SelectedText}
      function GetSelectedText: String;

      {Editable}
      function IsEditable: Boolean;
      procedure SetEditable(const Value: Boolean);
      procedure UpdateMemoReadOnly;

      {InputPrompt}
      function GetInputPrompt: String;
      procedure SetInputPrompt(const Value: String);

      {Font}
      function GetFont: TFont;
      procedure SetFont(const Value: TFont);

      {HorzAlign}
      function GetHorzAlign: TTextAlign;
      procedure SetHorzAlign(const Value: TTextAlign);

      {Color}
      function GetForegroundColor: TAlphaColor; override;
      procedure SetForegroundColor(const Value: TAlphaColor); override;

      {Options}
      function GetOptions: IStoryItemOptions; override;

    public
      constructor Create(AOnwer: TComponent); override;
      //procedure SetBounds(X, Y, AWidth, AHeight: Single); override; //note this is called also when the control is moved //TODO: see if we can get first display and subsequent resizes instead
      procedure Painting; override;
      //procedure Resize; override;
      //procedure DoResized; override;

      {$region 'IStoreable'}
      function GetLoadFilesFilter: String; override;
      function LoadFromStream(const Stream: TStream; const ContentFormat: String = EXT_READCOM; const CreateNew: Boolean = false): TObject; overload; override;
      function LoadTXT(const Stream: TStream): TObject; virtual;
      function LoadFromClipboard(const Clipboard: IFMXExtendedClipboardService; const CreateNew: Boolean = false): TObject; overload; override;
      //TODO: add SaveTXT and Save override
      {$endregion}

    //--- Properties ---

    published
      const
        DEFAULT_EDITABLE = false;
        DEFAULT_HORZ_ALIGN = TTextAlign.Center;
        DEFAULT_FOREGROUND_COLOR = TAlphaColorRec.Black;

      property Text: String read GetText write SetText;
      property SelectedText: String read GetSelectedText stored false;
      property Editable: Boolean read IsEditable write SetEditable default DEFAULT_EDITABLE;
      property InputPrompt: String read GetInputPrompt write SetInputPrompt;
      property Font: TFont read GetFont write SetFont; //sets font size, font family (typeface), font style (bold, italic, underline, strikeout)
      property HorzAlign: TTextAlign read GetHorzAlign write SetHorzAlign default DEFAULT_HORZ_ALIGN;
      property TextColor: TAlphaColor read GetForegroundColor write SetForegroundColor stored false; //DEPRECATED, remaped to and storing ForegroundColor instead
      property ForegroundColor: TAlphaColor read GetForegroundColor write SetForegroundColor default DEFAULT_FOREGROUND_COLOR; //redefining default instead of claNull that was in TStoryItem
    end;

    {$ENDREGION ........................................................................}

    {$REGION 'TTextStoryItemFactory' ---------------------------------------------------}

    TTextStoryItemFactory = class(TInterfacedObject, IStoryItemFactory)
      function New(const AOwner: TComponent = nil): IStoryItem;
    end;

    {$ENDREGION ........................................................................}

implementation
  {$region 'Used units'}
  uses
    IOUtils, //for TFile
    System.Math, //for EnsureRange
    //
    FMX.Styles.Objects, //for TActiveStyleObject //TODO: move the transparency setting code to FMX.Helpers
    FMX.TextLayout, //for TTextLayoutManager
    //
    //Zoomicon.Helpers.RTL.StreamHelpers, //for TStream.RealAllText
    Zoomicon.Helpers.FMX.Memo.MemoHelpers, //for TMemo.SetFontSizeToFit
    Zoomicon.Introspection.FMX.Debugging, //for Log
    //
    READCOM.Views.Options.TextStoryItemOptions, //for TTextStoryItemOptions
    READCOM.Factories.StoryItemFactory; //for StoryItemFactories, AddStoryItemFileFilter
    {$endregion}

  {$R *.fmx}

  {$REGION 'TTextStoryItem'}

  {$region 'Lifetime management'}

  constructor TTextStoryItem.Create(AOnwer: TComponent);

    procedure InitMemo;
    begin
      if Assigned(Memo) then
        with Memo do
        begin
          Stored := false; //don't store state, should use state from designed .FMX resource
          SetSubComponent(true);
          Align := TAlignLayout.Contents;
          SetMemoZOrder;

          //text layout
          WordWrap := true; //first wrap, then resize font if can't fit height (TODO: SKIA wraps per letter I think, not per word, so don't use)
          TextAlign := DEFAULT_HORZ_ALIGN;

          //no scrolling
          DisableMouseWheel := true;
          EnabledScroll := false;
          ShowScrollBars := false;

          //needed for font etc.
          StyledSettings := []; //don't overload any TextSetting with those from Style

          //TextStoryItem-related
          ReadOnly := not DEFAULT_EDITABLE;

          //Listeners//
          OnResized := MemoResized;
          OnChangeTracking := MemoChangeTracking;
        end;

      //FLastFontSize := Memo.Font.Size;
    end;

  begin
    inherited;
    InitMemo;
    Text := DEFAULT_TEXT;
    ForegroundColor := DEFAULT_FOREGROUND_COLOR;
  end;

  procedure SetFontSizeToFit(const AMemo: TMemo; var LastFontFitSize: TSizeF); //TODO: add logging
  //const
    //Offset = 0; //The diference between ContentBounds and ContentLayout //TODO: info coming from https://stackoverflow.com/a/21993017/903783 - need to verify
  begin
    //TODO// if DisableMemoFontSizeToFit then exit;

    //AMemo.AutoCalculateContentSize := true; //don't use

    {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    AMemo.UpdateContentSize; //Recalculates content bounds of a scroll box. Does not calculate content bounds if AutoCalculateContentSize is False or if the state of the scroll box is csLoading or csDestroying
    {$ENDIF}

    var Offset := 10 {* AMemo.AbsoluteScale.Y}; //TODO: not very good
    var LHeight := AMemo.Height;
    if (LHeight = 0) {or (AMemo.Size.Size = LastFontFitSize)} then
      exit; //don't calculate font autofit based on probably not yet available height information, nor when AMemo.Height didn't change from last calculation

    //AMemo.Font.Size := 12; //Don't set initial font size, use the current one (which may be from a previous calculation - this speeds up when resizing and also fixes glitches when loading saved state if recalculation isn't done for some reason after loading)

    var LContentBoundsHeight := AMemo.ContentBounds.Height;
    if (LContentBoundsHeight = 0) then //must check, else first while will loop for ever since ContentBounds.Height is 0 on load
      exit;

    var LFontSize := AMemo.Font.Size;
    LastFontFitSize := AMemo.Size.Size;

    //make font bigger
    while (LContentBoundsHeight + Offset < LHeight) do //using WordWrap, not checking for Width
    begin
      LFontSize := LFontSize + 1;
      AMemo.Font.Size := LFontSize;

      var LContentBoundsNewHeight := AMemo.ContentBounds.Height;
      if LContentBoundsNewHeight = LContentBoundsHeight then
      begin
        AMemo.Font.Size := LFontSize - 1; //undo font size increase since it had no effect
        exit; //TODO: See why changing Font.Size doesn't affect ContentBounds in Android implementation so we get an infinite loop (Height is never reached)
      end;
      LContentBoundsHeight := LContentBoundsNewHeight;
    end;

    //make font smaller
    while (LContentBoundsHeight + Offset > LHeight) do //using WordWrap, not checking for Width
    begin
      LFontSize := LFontSize - 1;
      AMemo.Font.Size := LFontSize;

      var LContentBoundsNewHeight := AMemo.ContentBounds.Height;
      if LContentBoundsNewHeight = LContentBoundsHeight then
      begin
        AMemo.Font.Size := LFontSize + 1; //undo font size decrease since it had no effect
        exit; //TODO: See why changing Font.Size doesn't affect ContentBounds in Android implementation so we get an infinite loop (Height is never reached)
      end;
      LContentBoundsHeight := LContentBoundsNewHeight;
    end;

  end;

procedure SetFontSizeToFit0(const AMemo: TMemo);
const
  Offset = 4; //The diference between ContentBounds and ContentLayout //TODO: info coming from https://stackoverflow.com/a/21993017/903783 - need to verify
begin
  with AMemo do
  begin
    //set default font size
    Font.Size := 12;

    if (ContentBounds.Height <> 0) then //must check, else first while will loop for ever since ContentBounds.Height is 0 on load
    begin
      //make font bigger
      while (ContentBounds.Height + Offset < Height) do //using WordWrap, not checking for Width
        with Font do
          Size := Size + 1;

      //make font smaller
      while (ContentBounds.Height + Offset > Height) do //using WordWrap, not checking for Width
        with Font do
          Size := Size - 1;
    end;
  end;
end;

procedure SetFontSizeToFit3(const Memo: TMemo);
const
  Margin = 5.0;  // Padding for better fitting
  InitStep = 1.0;
  MinStep = 0.05;
  MaxStep = 10.0;
  InitStepAdjust = 0.1;
  MinStepAdjust = 0.05;
  MaxStepAdjust = 0.2;
begin
  Log('SetFontSizeToFit %p', [@Memo]);

  try
    Memo.RecalcEnabled;
    if Memo.Text = '' then Exit;

    var MaxWidth := Memo.AbsoluteWidth;
    var MaxHeight := Memo.AbsoluteHeight;

    var TestFontSize := Memo.Font.Size;
    var Step := InitStep;
    var IsFirstLoop := True;
    var PrevDirection := 0;
    var PrevHeightDiff := 0.0;

    while True do
    begin
      // Temporarily set the test font size
      Memo.Font.Size := TestFontSize;

      // Measure text dimensions using Memo's ContentBounds
      var TextWidth := Memo.ContentBounds.Width;
      var TextHeight := Memo.ContentBounds.Height;

      Log('Measured Text: Width=%.2f, Height=%.2f | MaxWidth=%.2f, MaxHeight=%.2f',
          [TextWidth, TextHeight, MaxWidth, MaxHeight]);

      // Check if text fits within bounds
      var HeightDiff := Abs(TextHeight - MaxHeight);
      var Direction: Integer;
      if TextHeight > MaxHeight then
        Direction := -1  // Shrink font size
      else if TextHeight < (MaxHeight - Margin) then
        Direction := +1  // Increase font size
      else
        Break; // Stop when within margin range

      // Adjust font size step
      TestFontSize := TestFontSize + (Step * Direction);

      // Step adjustment logic
      if IsFirstLoop then
        IsFirstLoop := False
      else
      begin
        var StepAdjust := EnsureRange(HeightDiff / MaxHeight, MinStepAdjust, MaxStepAdjust);
        if PrevDirection <> Direction then
        begin
          Step := Step * (1.0 - StepAdjust);
          if Step < MinStep then Break;
        end
        else if (HeightDiff >= PrevHeightDiff) and (Step < MaxStep) then
          Step := Min(Step * (1.0 + StepAdjust), MaxStep);
      end;

      // Update previous values
      PrevDirection := Direction;
      PrevHeightDiff := HeightDiff;
    end;

    //Memo.Font.Size := TestFontSize;  // Apply final font size

  finally
    Log('SetFontSizeToFit %p EXIT', [@Memo]);
  end;
end;

procedure SetFontSizeToFit2(const Memo: TMemo);
const
  Margin = Single(5.0);
  InitStep = Single(1.0);
  MinStep = Single(0.05);
  MaxStep = Single(10.0);
  InitStepAdjust = Single(0.1);
  MinStepAdjust = Single(0.05);
  MaxStepAdjust = Single(0.2);
begin
  Log('SetFontSizeToFit %p', [@Memo]);

  try
    if Memo.Text = '' then
      Exit;

    var MaxWidth := Memo.Width; //TODO: should we use Memo.Width here?
    var MaxHeight := Memo.Height; //TODO: should we use Memo.Height here?

    // Ensure Memo.Canvas is valid before using it
    if not Assigned(Memo.Canvas) then
    begin
      Log('Memo.Canvas is NIL!');
      Exit;
    end;

    var Layout := TTextLayoutManager.DefaultTextLayout.Create(Memo.Canvas);
    try
      with Layout do
      begin
        BeginUpdate;
        try
          Log('Initializing Layout Font...');

          // Check if Font exists before assignment
          if Assigned(Font) then
          begin
            BeginUpdate;
            Font.Assign(Memo.Font);
            EndUpdate;

            // Explicitly set essential font properties
            //Font.Size := Memo.Font.Size;
            //Font.Family := Memo.Font.Family;
            //Font.Style := Memo.Font.Style;

            Log('Layout Font Assigned: Size=%d, Family=%s',
                [round(Font.Size), String(Font.Family)]);
          end
          else
            Log('Layout.Font is NIL!');

          HorizontalAlign := Memo.TextAlign;
          VerticalAlign := TTextAlign.Center;

          Padding := Memo.Padding;
          MaxSize := PointF(MaxWidth, MaxHeight); // Setting explicit bounds
          WordWrap := Memo.WordWrap;

          Log('Set Text Before Font Assignment...');
          Text := Memo.Text; // Force initialization of layout text
        finally
          EndUpdate;
        end;

        var PrevDirection: Integer := 0;
        var PrevHeightDiff: Single := 0.0;
        var Step: Single := InitStep;
        var IsFirstLoop := true;

        while True do
        begin
          Log('Updating Layout Text...');
          //Text := Memo.Text; // Ensure updates

          var LTextHeight := Layout.TextHeight;
          var HeightDiff := Abs(LTextHeight - MaxHeight);

          Log('Current TextHeight: %.2f, Target MaxHeight: %.2f', [LTextHeight, MaxHeight]);

          // Determine direction based on current height
          var Direction: Integer;
          if LTextHeight > MaxHeight then
            Direction := -1 // Decrease font size
          else if LTextHeight < (MaxHeight - Margin) then
            Direction := +1 // Increase font size
          else
            Break; // Stop when inside range

          // Apply offset using direction
          BeginUpdate;
          Font.Size := Font.Size + (Step * Direction);
          EndUpdate;

          // Step adjustment
          if IsFirstLoop then
            IsFirstLoop := false
          else
          begin
            var StepAdjust := EnsureRange(HeightDiff / MaxHeight, MinStepAdjust, MaxStepAdjust);
            if PrevDirection <> Direction then
            begin
              Step := Step * (1.0 - StepAdjust); // Reduce step to prevent oscillation
              if (Step < MinStep) then
                Break; // Exit if step gets too small
            end
            else if (HeightDiff >= PrevHeightDiff) and (Step < MaxStep) then
              Step := Min(Step * (1.0 + StepAdjust), MaxStep); // Increase step if we're not making enough progress
          end;

          // Update previous values for next iteration
          PrevDirection := Direction;
          PrevHeightDiff := HeightDiff;
        end;
      end;

      Memo.BeginUpdate;
      Memo.Font.Size := Layout.Font.Size;
      Memo.EndUpdate;

    finally
      Layout.Free;
    end;
  finally
    Log('SetFontSizeToFit %p EXIT', [@Memo]);
  end;
end;

//TODO: move into FMX Memo helper - see old method there to replace


  (*
  procedure TTextStoryItem.Loaded; //this gets called multiple times when you have an inherited frame, maybe use SetParent instead
  begin
    {//}Log('TTextStoryItem.Loaded %p', [@Self]);
    inherited;
    //Memo.SetFontSizeToFit(FLastMemoSize);
    SetFontSizeToFit(Memo);
  end;
  *)

  (*
  procedure TTextStoryItem.SetBounds(X, Y, AWidth, AHeight: Single); //Note: also gets called when control is moved //TODO: add Logging, this seems to be called too many times (7 - see stack trace of each case and how they differ, also try to group multiple changes)
  begin
    {//}Log('TTextStoryItem.SetBounds %p', [@Self]);
    inherited;
    Memo.SetFontSizeToFit(FLastMemoSize);
  end;
  *)

  (**)
  procedure TTextStoryItem.Painting;
  begin
    //Log('TTextStoryItem.Painting %p', [@Self]);
    inherited;
    //Memo.SetFontSizeToFit(FLastMemoSize);
    //Memo.SetFontSizeToFit(FLastFontSize);
    SetFontSizeToFit(Memo, FLastMemoSize); //TODO: TOO HEAVY, CALLED TOO OFTEN
  end;
  (**)

  (*
  procedure TTextStoryItem.DoResized; //or "Resize" which is called earlier
  begin
    Log('TTextStoryItem.DoResized');
    inherited;
    try
      Memo.SetFontSizeToFit(FLastMemoSize); //throws exceptions at startup
    Except
      //NOP
    end;
  end;
  *)

  procedure TTextStoryItem.MemoResized(Sender: TObject);
  begin
    {//}Log('TTextStoryItem.MemoResized %p', [@Self]);
    //Memo.SetFontSizeToFit(FLastMemoSize);
    //Memo.SetFontSizeToFit(FLastFontSize);
    SetFontSizeToFit(Memo, FLastMemoSize);

    //ForceRenderMemoOutlineToImage; //TODO: doesn't seem to work
  end;

  procedure TTextStoryItem.MemoChangeTracking(Sender: TObject);
  begin
    {//}Log('TTextStoryItem.MemoChangeTracking %p', [@Self]);
    //Memo.SetFontSizeToFit(FLastMemoSize);
    //Memo.SetFontSizeToFit(FLastFontSize);
    SetFontSizeToFit(Memo, FLastMemoSize);

    //ForceRenderMemoOutlineToImage; //TODO: doesn't seem to work
  end;

  //text outlining effect
  procedure TTextStoryItem.ForceRenderMemoOutlineToImage;
  begin
    // Schedule AFTER memo repaint
    TThread.ForceQueue(nil,
      procedure

        procedure RenderMemoOutlineToImage(AMemo: TMemo; AGlyph: TMediaDisplay;
                                           AOutlineColor: TAlphaColor;
                                           AScale: Single;
                                           AOffset: Single);
        begin
          // 1. Capture memo without caret/selection
          var SavedFocus := AMemo.Root.Focused;
          AMemo.Root.SetFocused(nil);

          var SrcBmp: TBitmap;
          try
            SrcBmp := AMemo.MakeScreenshot;
          finally
            AMemo.Root.SetFocused(SavedFocus);
          end;

          // 2. Scale the screenshot
          var NewW := Round(SrcBmp.Width * AScale);
          var NewH := Round(SrcBmp.Height * AScale);

          var ScaledBmp := TBitmap.Create(NewW, NewH);
          ScaledBmp.BitmapScale := SrcBmp.BitmapScale;
          ScaledBmp.Clear(TAlphaColorRec.Null);

          ScaledBmp.Canvas.BeginScene;
          try
            ScaledBmp.Canvas.DrawBitmap(
              SrcBmp,
              RectF(0, 0, SrcBmp.Width, SrcBmp.Height),
              RectF(0, 0, NewW, NewH),
              1, True
            );
          finally
            ScaledBmp.Canvas.EndScene;
          end;

          // 3. Recolor non-transparent pixels using FMX Map/Unmap
          var Data: TBitmapData;
          if ScaledBmp.Map(TMapAccess.ReadWrite, Data) then
          try
            for var Y := 0 to ScaledBmp.Height - 1 do
              for var X := 0 to ScaledBmp.Width - 1 do
              begin
                var C := Data.GetPixel(X, Y);
                var A := TAlphaColorRec(C).A;
                if A > 0 then
                  Data.SetPixel(X, Y,
                    (A shl 24) or (AOutlineColor and $00FFFFFF));
              end;
          finally
            ScaledBmp.Unmap(Data);
          end;

          // 4. Set Bitmap
          AGlyph.Bitmap := ScaledBmp; //do not use Assign, it needs to create a TImage Presenter first (done at SetBitmap)

          //AGlyph.BringToFront; //TEST: doesn't seem to do anything (say show other color text)

          // 5. Apply offset + scaling behavior
          AGlyph.WrapMode := TImageWrapMode.Stretch;

          with TImage(AGlyph.Presenter).BitmapMargins do
          begin
            Left   := -AOffset;
            Top    := -AOffset;
            Right  := -AOffset;
            Bottom := -AOffset;
          end;

          SrcBmp.Free;
          ScaledBmp.Free;
        end;

      begin
        RenderMemoOutlineToImage(
          Memo,
          Glyph,
          TAlphaColorRec.Black,
          1.12,   // scale
          2.0     // offset
        );
      end);
  end;

  {$endregion}

  {$region 'Z-order'}

  function TTextStoryItem.GetBackIndex: Integer;
  begin
    result := inherited;
    if Assigned(Memo) and Memo.Visible then
      inc(result); //reserve one more place at the bottom for Memo
  end;

  procedure TTextStoryItem.SetMemoZorder;
  begin
    (* //NOT WORKING
    BeginUpdate;
    RemoveObject(Memo);
    InsertObject((inherited GetBackIndex) + 1, Memo);
    EndUpdate;
    *)
    if Assigned(Memo) and Memo.Visible then
      Memo.SendToBack;
  end;

  {$endregion}

  {$region 'Clipboard'}

  function TTextStoryItem.LoadFromClipboard(const Clipboard: IFMXExtendedClipboardService; const CreateNew: Boolean = false): TObject;
  begin
    if Clipboard.HasText then
    begin
      var LText := TrimLeft(Clipboard.GetText); //Left-trimming since we may have pasted an indented object from a .readcom file
      //TODO: Add UTF-8 BOM skip in case it's prepended by mistake
      if not LText.StartsWith('object ') then //if Delphi serialization format (its text-based form) then don't paste as text (let ancestor TStoryItem handle it)
      begin
        Text := LText; //else replace current text
        Exit(Self);
      end;
    end;

    result := inherited; //fallback to ancestor implementation
  end;

  {$endregion}

  {$region 'Helpers'}

  procedure TTextStoryItem.UpdateMemoReadOnly;
  begin
    Memo.ReadOnly := not (IsEditable or IsEditMode);
    Memo.HitTest := not Memo.ReadOnly; //TODO: should maybe have a mode that swiches between Editable, Selectable and Read-Only/Inactive (so that it's draggable)
    //Memo.Enabled := not Memo.ReadOnly; //this greys out the item, don't use
  end;

  {$endregion}

  {$REGION 'PROPERTIES'}

  {$region 'DefaultSize'}

  function TTextStoryItem.GetDefaultSize: TSizeF;
  begin
    Result := TSizeF.Create(50, 30);
  end;

  {$endregion}

  {$region 'Active'}

  procedure TTextStoryItem.SetActive(const Value: Boolean);
  begin
    inherited;

    if Value then
      Memo.SetFocus
    else
      Memo.ResetFocus;
  end;

  {$endregion}

  {$region 'EditMode'}

  procedure TTextStoryItem.SetEditMode(const Value: Boolean);
  begin
    inherited;
    UpdateMemoReadOnly;
  end;

  {$endregion}

  {$region 'Text'}

  function TTextStoryItem.GetText: String;
  begin
    result := Memo.Text;
  end;

  procedure TTextStoryItem.SetText(const Value: String);
  begin
    if Assigned(Memo) then
      Memo.Text := Value;
  end;

  {$endregion}

  {$region 'SelectedText'}

  function TTextStoryItem.GetSelectedText: String;
  begin
    Memo.Model.SelectedText;
  end;

  {$endregion}

  {$region 'Editable'}

  function TTextStoryItem.IsEditable: Boolean;
  begin
    result := FEditable;
  end;

  procedure TTextStoryItem.SetEditable(const Value: Boolean);
  begin
    FEditable := Value;
    UpdateMemoReadOnly;
  end;

  {$endregion}

  {$region 'InputPrompt'}

  function TTextStoryItem.GetInputPrompt: String;
  begin
    //TODO
  end;

  procedure TTextStoryItem.SetInputPrompt(const Value: String);
  begin
    //TODO
  end;

  {$endregion}

  {$region 'Font'}

  function TTextStoryItem.GetFont: TFont;
  begin
    result := Memo.Font;
  end;

  procedure TTextStoryItem.SetFont(const Value: TFont);
  begin
    Memo.Font := Value;
  end;

  {$endregion}

  {$region 'HorzAlign'}

  function TTextStoryItem.GetHorzAlign: TTextAlign;
  begin
    result := Memo.TextSettings.HorzAlign;
  end;

  procedure TTextStoryItem.SetHorzAlign(const Value: TTextAlign);
  begin
    Memo.TextSettings.HorzAlign := Value;
  end;

  {$endregion}

  {$region 'ForegroundColor'}

  function TTextStoryItem.GetForegroundColor: TAlphaColor;
  begin
    result := Memo.FontColor;
  end;

  procedure TTextStoryItem.SetForegroundColor(const Value: TAlphaColor);
  begin
    if (Value = TAlphaColorRec.Null) then //never apply the null color as foreground, keep the default TextStoryItem ForegroundColor instead
      Memo.FontColor := DEFAULT_FOREGROUND_COLOR
    else
      Memo.FontColor := Value;
  end;

  {$endregion}

  {$region 'Options'}

  function TTextStoryItem.GetOptions: IStoryItemOptions;
  begin
    if not Assigned(FOptions) then
      begin
      FOptions := TTextStoryItemOptions.Create(nil); //don't set storyitem as owner, seems to always store it (irrespective of "Stored := false")
      FOptions.StoryItem := Self;
      end;

    result := FOptions;
  end;

  {$endregion}

  {$ENDREGION PROPERTIES}

  {$region 'IStoreable'}

  function TTextStoryItem.GetLoadFilesFilter: String;
  begin
    result := FILTER_TEXT + '|' + inherited;
  end;

  function TTextStoryItem.LoadFromStream(const Stream: TStream; const ContentFormat: String = EXT_READCOM; const CreateNew: Boolean = false): TObject;
  begin
    if (ContentFormat = EXT_TXT) then //load EXT_TXT
      result := LoadTXT(Stream)
    else
      result := inherited; //load EXT_TXT
  end;

  function TTextStoryItem.LoadTXT(const Stream: TStream): TObject;
  begin
    //Text := Stream.ReadAllText; //TODO: doesn't seem to work correctly

    var s := TStringList.Create(#0, #13);
    try
      s.LoadFromStream(Stream);
      Text := s.DelimitedText;

      Size.Size := TSizeF.Create(50, 30); //TODO: judge based on text volume?
    finally
      FreeAndNil(s);
    end;

    result := Self;
  end;

  procedure TTextStoryItem.MemoApplyStyleLookup(Sender: TObject);
  begin
    inherited;

    //make TMemo transparent
    var Obj := Memo.FindStyleResource('background');
    if Assigned(Obj) And (Obj is TActiveStyleObject) Then
       TActiveStyleObject(Obj).Source := Nil;
  end;

  {$endregion}

  {$ENDREGION}

  {$REGION 'TTextStoryItemFactory'}

  function TTextStoryItemFactory.New(const AOwner: TComponent = nil): IStoryItem;
  begin
    result := TTextStoryItem.Create(AOwner);
  end;

  {$ENDREGION}

  {$region 'Registration'}

  procedure RegisterSerializationClasses;
  begin
    RegisterFmxClasses([TTextStoryItem], [TFrame]);
  end;

  {$endregion}

initialization
  StoryItemFactories.Add([EXT_TXT], TTextStoryItemFactory.Create);

  AddStoryItemFileFilter(FILTER_TEXT_TITLE, FILTER_TEXT_EXTS);

  RegisterSerializationClasses; //don't call Register here, it's called by the IDE automatically on a package installation (fails at runtime)

end.
