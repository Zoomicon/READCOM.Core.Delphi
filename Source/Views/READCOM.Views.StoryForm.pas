//Description: READ-COM Main (Story) View
//Author: George Birbilis (http://zoomicon.com)

{-$DEFINE NOSTYLE}

//WARNING: if Delphi corrupts the form (sometimes it fails to load the StoryHUD frame first), revert only the StoryForm.fmx file from version control

unit READCOM.Views.StoryForm;

interface
  {$region 'Used units'}
  uses
    System.Actions, System.SysUtils, System.Types, System.UITypes,
    System.Classes, System.Variants,
    //
    FMX.Objects, FMX.Controls, FMX.Controls.Presentation, FMX.StdCtrls,
    FMX.Types, //for TLang
    FMX.Forms, FMX.Graphics, FMX.Dialogs,
    FMX.Layouts,
    FMX.ActnList,
    //
    Zoomicon.Generics.Collections, //for TObjectListEx
    Zoomicon.Introspection.FMX.StructureView, //for TStructureView
    Zoomicon.ZUI.FMX.ZoomFrame, //for TZoomFrame
    //
    READCOM.Models.Stories, //for IStory, IStoryItem
    READCOM.Views.StoryItems.StoryItem, //for TStoryItem
    READCOM.Views.StoryHUD; //for TStoryHUD
  {$endregion}

  const
    OPENLOCK_DELAY = 800; //msec

  type
    TStoryForm = class; //forward declaration needed, since TStory keeps a reference to TStoryForm

    {$region 'TStory'}

    TStory = class; //forward declaration

    TStoryLoadedEvent = procedure(const Story: TStory) of object;

    TStory = class(TComponent, IStory)
    protected
      var
        UI: TStoryForm;
        //
        FStoryMode: TStoryMode;

      class var
        FOnStoryLoaded: TStoryLoadedEvent;

    public
      {Initialization}
      constructor Create(AUI: TStoryForm); reintroduce; //hiding ancestor constructor

      {Refresh any structure view}
      procedure RefreshStructure;

      {Zooming}
      procedure ZoomTo(const StoryItem: IStoryItem = nil); //ZoomTo(nil) zooms to all content
      procedure ZoomToActiveStoryPointOrHome;

      {RootStoryItem}
      function GetRootStoryItem: IStoryItem;
      procedure SetRootStoryItem(const Value: IStoryItem);

      {HomeStoryItem}
      function GetHomeStoryItem: IStoryItem;
      procedure SetHomeStoryItem(const Value: IStoryItem);

      {Navigation}
      function GetFirstStoryPoint: IStoryItem;
      function GetPreviousStoryPoint: IStoryItem;
      function GetNextStoryPoint: IStoryItem;

      {Tags}
      function CheckTagsMatched(const TagsMatching: TTagsMatching = TagsMatching_Default): Boolean;

      {URLs}
      procedure DoUrlAction(const UrlAction: String);

      {ActiveStoryItem}
      function GetActiveStoryItem: IStoryItem;
      procedure SetActiveStoryItem(const Value: IStoryItem);
      //
      procedure ActivateHomeStoryItem(const TagsMatching: TTagsMatching = TagsMatching_Default);
      procedure ActivateRootStoryItem;
      procedure ActivateParentStoryItem;
      //
      procedure ActivateAncestorStoryPoint;
      procedure ActivatePreviousStoryPoint(const TagsMatching: TTagsMatching = TagsMatching_Default);
      procedure ActivateNextStoryPoint(const TagsMatching: TTagsMatching = TagsMatching_Default);
      //
      procedure ActivateUrl(const Url:string; const TagsMatching: TTagsMatching = TagsMatching_Default); //open new story when ending in .readcom, else open url in browser

      {StoryMode}
      function GetStoryMode: TStoryMode;
      procedure SetStoryMode(const Value: TStoryMode);

    public
      class property OnStoryLoaded: TStoryLoadedEvent read FOnStoryLoaded write FOnStoryLoaded;

    published
      property StoryMode: TStoryMode read GetStoryMode write SetStoryMode stored false;
      //
      property RootStoryItem: IStoryItem read GetRootStoryItem write SetRootStoryItem stored false;
      property HomeStoryItem: IStoryItem read GetHomeStoryItem write SetHomeStoryItem stored false;
      property ActiveStoryItem: IStoryItem read GetActiveStoryItem write SetActiveStoryItem stored false;
      //
      property FirstStoryPoint: IStoryItem read GetFirstStoryPoint stored false;
      property PreviousStoryPoint: IStoryItem read GetPreviousStoryPoint stored false;
      property NextStoryPoint: IStoryItem read GetNextStoryPoint stored false;
    end;

    {$endregion}

    {$region 'TEditableStory'}

    TEditableStory = class(TStory, IStory, IStoryEditor)
    public
      procedure NewRootStoryItem;
      procedure AddChildStoryItem(const TheStoryItemClass: TClass; const TheName: String); //assuming TStoryItemClass is passed
      //
      procedure DeleteActiveStoryItem;
      procedure CutActiveStoryItem;
      procedure CopyActiveStoryItem;
      procedure PasteInActiveStoryItem;
    end;

    {$endregion}

    {$region 'TStoryForm'}

    TStoryFormReadyEvent = procedure(const StoryForm: TStoryForm) of object; //there is a forward declaration for TStoryForm higher above

    TStoryForm = class(TForm)
      HUD: TStoryHUD;
      ZoomFrame: TZoomFrame;
      StoryTimer: TTimer;

      //Initialiation
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure FormShow(Sender: TObject);

      //State saving
      procedure FormSaveState(Sender: TObject);

      //Keyboard
      procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);

      //File actions
      procedure HUDactionNewExecute(Sender: TObject);
      procedure HUDactionLoadExecute(Sender: TObject);
      procedure HUDactionSaveExecute(Sender: TObject);

      //Light-Dark mode
      procedure HUDactionNextThemeExecute(Sender: TObject);

      //Navigation actions
      procedure HUDactionHomeExecute(Sender: TObject);
      procedure HUDactionPreviousExecute(Sender: TObject);
      procedure HUDactionNextExecute(Sender: TObject);
      procedure StoryTimerTimer(Sender: TObject);

      //Add actions
      procedure HUDactionAddExecute(Sender: TObject);
      procedure HUDactionAddImageStoryItemExecute(Sender: TObject);
      procedure HUDactionAddTextStoryItemExecute(Sender: TObject);

      //Edit actions
      procedure HUDactionDeleteExecute(Sender: TObject);
      procedure HUDactionCutExecute(Sender: TObject);
      procedure HUDactionCopyExecute(Sender: TObject);
      procedure HUDactionPasteExecute(Sender: TObject);

      //Flip actions
      procedure HUDactionFlipHorizontallyExecute(Sender: TObject);
      procedure HUDactionFlipVerticallyExecute(Sender: TObject);

      //Color actions
      procedure HUDcomboForeColorChange(Sender: TObject);
      procedure HUDcomboBackColorChange(Sender: TObject);

      //Options action
      procedure HUDactionOptionsExecute(Sender: TObject);

      //Scaling
      procedure FormResize(Sender: TObject);

      //Keyboard
      procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

    protected
      FStory: TEditableStory;
      FStructureView: TStructureView;
      FShiftDown: Boolean; //set by event handlers for OnFormKeyDown, OnFormKeyUp to monitor SHIFT key standalone presses
      FShortcutCut, FShortcutCopy, FShortcutPaste: TShortCut;
      FTimerStarted: Boolean;
      FCheckedCommandLineActions: Boolean;

      {Zooming}
      procedure StartInitialZoomTimer(const Delay: Cardinal = 100);

      {Idle}
      procedure Idle(Sender: TObject; var Done: Boolean);

      {Loading / SavedState}
      procedure LoadAtStartup;
      function LoadFromStream(const Stream: TStream; const ActivateHome: Boolean = True): Boolean;
      function LoadFromFile(const Filepath: String): Boolean;
      function LoadFromUrl(const Url: String): Boolean;
      function LoadFromFileOrUrl(const PathOrUrl: String): Boolean;
      function LoadCommandLineParameter: Boolean;
      function LoadDefaultDocument: Boolean;

      function GetSavedStateName: String;
      function GetSavedStateStoragePath: String;
      function LoadSavedState: Boolean;
      procedure SaveCurrentState;

      procedure CheckCommandLineActions;
      procedure CheckReplaceStoryAllText;

      {RootStoryItemStoryView}
      function GetRootStoryItemView: TStoryItem;
      procedure SetRootStoryItemView(const Value: TStoryItem);

      {ActiveStoryItem}
      procedure SetActiveStoryItemIfAssigned(const Value: IStoryItem);
      procedure HandleActiveStoryItemChanged(Sender: TObject);
      procedure NavigateUp;

      {Orientation}
      procedure CheckProperOrientation;

      {Scaling}
      procedure RootStoryItemViewResized(Sender: TObject);

      {Options}
      procedure ShowActiveStoryItemOptions;

      {StructureView}
      function GetStructureView: TStructureView;
      procedure SetStructureView(const Value: TStructureView);
      procedure StructureViewShowFilter(Sender: TObject; const TheObject: TObject; var ShowObject: Boolean);
      procedure StructureViewSelection(Sender: TObject; const Selection: TObject);
      procedure StructureViewContextMenu(Sender: TObject; const Selection: TObject);
      procedure UpdateStructureView;

      {HUD}
      procedure HUDEditModeChanged(Sender: TObject; const Value: Boolean);
      procedure HUDStructureVisibleChanged(Sender: TObject; const Value: Boolean);
      procedure HUDTargetsVisibleChanged(Sender: TObject; const Value: Boolean);
      procedure HUDUseStoryTimerChanged(Sender: TObject; const Value: Boolean);

      class var
        FOnStoryFormReady: TStoryFormReadyEvent;

    public
      property Story: TEditableStory read FStory write FStory stored false;
      property StructureView: TStructureView read GetStructureView write SetStructureView stored false;

      class property OnStoryFormReady: TStoryFormReadyEvent read FOnStoryFormReady write FOnStoryFormReady;

    published
      property RootStoryItemView: TStoryItem read GetRootStoryItemView write SetRootStoryItemView stored false;
    end;

    {$endregion}

  resourcestring
    MSG_CONFIRM_CLEAR_STORY = 'Clearing Story: are you sure?';
    MSG_CONFIRM_DELETION = 'Deleting ActiveStoryItem: are you sure?';

implementation
  {$region 'Used units'}
  uses
    System.Contnrs, //for TClassList
    System.IOUtils, //for TPath
    System.Math, //for Max
    System.Net.HttpClient, //for HTTP/HTTPS url scheme support in TURLStream (Delphi 11.1+)
    System.Net.URLClient, //for TURLStream (Delphi 11.1+)
    //
    Fmx.Memo, //for TMemo
    //
    Zoomicon.Helpers.RTL.ClassListHelpers, //for TClassList.Create(TClassArray)
    Zoomicon.Helpers.FMX.ActnList, //for SafeTextToShortcut
    Zoomicon.Helpers.FMX.Controls.ControlHelper, //for TControl.Orientation, TControl.FlipHorizontally, TControl.FlipVertically
    Zoomicon.Helpers.FMX.Forms.ApplicationHelper, //for TApplication.Confirm, TApplication.OpenURL, IsURI
    Zoomicon.Helpers.FMX.Forms.FormHelper, //for TForm.Orientation
    Zoomicon.Helpers.FMX.Memo.MemoHelpers, //for TMemo.DisableFontSizeToFit
    Zoomicon.Introspection.FMX.Debugging, //for ToggleObjectDebuggerVisibility
    //
    READCOM.Models, //for EXT_READCOM
    READCOM.App.Main, //for StorySource
    READCOM.App.Messages,
    READCOM.Resources.Themes, //for Themes.LightTheme, Themes.DarkTheme
    READCOM.Views.StoryItems.ImageStoryItem, //for TImageStoryItem (for AddImageStoryItem action)
    READCOM.Views.StoryItems.TextStoryItem, //for TTextStoryItem (for AddTextStoryItem action)
    READCOM.Views.StoryItems.AudioStoryItem, //for TAudioStoryItem (needed so that custom apps don't need to use this unit explicitly)
    READCOM.Views.Dialogs.AllText, //for TAllTextFrame
    READCOM.Views.Prompts.Wait, //for TWaitFrame
    READCOM.Views.Prompts.Lock, //for TLockFrame
    READCOM.Views.Prompts.Rotate; //for TRotateFrame
  {$endregion}

  {$R *.fmx}

  {$REGION 'TStory' -----------------------------------------------------------}

  constructor TStory.Create(AUI: TStoryForm);
  begin
    inherited Create(AUI); //the form is the owner for life-time management of the Story object
    Name := 'Story'; //displayed in Object Debugger
    UI := AUI;
  end;

  {$region 'Refresh any structure view'}

  procedure TStory.RefreshStructure;
  begin
    UI.UpdateStructureView;
  end;

  {$endregion}

  {$region 'Zooming'}

  procedure TStory.ZoomTo(const StoryItem: IStoryItem);
  begin
    if Assigned(StoryItem) then
      UI.ZoomFrame.ZoomTo(StoryItem.View)
    else
      UI.ZoomFrame.ZoomTo; //Zoom to all content
  end;

  procedure TStory.ZoomToActiveStoryPointOrHome;
  begin
    var Value := ActiveStoryItem;
    if Assigned(Value) then
    begin
      if not (Value.StoryPoint or Value.Home) then //not zooming down to items that are not StoryPoints or Home //must do last before the ZoomTo since we change the "Value" local variable
        Value := Value.GetAncestorStoryPoint; //if it returns nil it will result in zooming to the RootStoryPoint
      ZoomTo(Value);
    end;
  end;

  {$endregion}

  {$region 'RootStoryItem'}

  function TStory.GetRootStoryItem: IStoryItem;
  begin
    result := UI.RootStoryItemView as IStoryItem;
  end;

  procedure TStory.SetRootStoryItem(const Value: IStoryItem);
  begin
    UI.RootStoryItemView := Value.GetView as TStoryItem; //Important: don't keep any more logic here, keeping all in SetRootStoryItemView

    if Assigned(FOnStoryLoaded) then
      FOnStoryLoaded(Self); //passing the TStory instance to the event handler
  end;

  {$endregion}

  {$region 'HomeStoryItem'}

  function TStory.GetHomeStoryItem: IStoryItem;
  begin
    result := TStoryItem.HomeStoryItem;
  end;

  procedure TStory.SetHomeStoryItem(const Value: IStoryItem);
  begin
    TStoryItem.HomeStoryItem := Value;
  end;

  {$endregion}

  {$region 'Navigation'}

  function TStory.GetFirstStoryPoint: IStoryItem;
  begin
    var LHome := HomeStoryItem;
    if (LHome.StoryPoint) then
      result := LHome
    else
      result := HomeStoryItem.GetFirstChildStoryPoint;
  end;

  function TStory.GetPreviousStoryPoint;
  begin
    var LActiveItem := ActiveStoryItem;
    if Assigned(LActiveItem) then
      result := LActiveItem.PreviousStoryPoint
    else
      result := nil;
  end;

  function TStory.GetNextStoryPoint;
  begin
    var LActiveItem := ActiveStoryItem;
    if Assigned(LActiveItem) then
      result := LActiveItem.NextStoryPoint
    else
      result := nil;
  end;

  {$endregion}

  {$region 'Tags'}

  function TStory.CheckTagsMatched(const TagsMatching: TTagsMatching = TagsMatching_Default): Boolean; //used to check (informing user they can or can't proceed) if tags are matched
  begin
    var activeItem := ActiveStoryItem;
    result :=
      Assigned(activeItem)
      and ( (TagsMatching = TagsMatching_Skip) or //skip Tags Matching
            ((StoryMode = EditMode) and UI.FShiftDown) or //in Edit mode only, SHIFT key held down bypasses tags-matched check and forces proceeding to NextStoryPoint
            (activeItem.TagsMatched) ); //also checking if Tags are matched (all moveables with Tags are over non-moveables with same Tags and vice-versa) to proceed

    if (TagsMatching <> TagsMatching_Skip) and //not showing prompt if skipped Tags Matching
       (TagsMatching <> TagsMatching_Silent_Prompt) and //not showing prompt if set to Silent prompting
       ((not result) or (TagsMatching = TagsMatching_OkFail_Prompt)) //showing prompt by default only if failed to match tags, or if set to show open/close lock
    then
      begin
      TLockFrame.ShowModal(UI); //warn user that they can't proceed (till Tags are matched)
      TLockFrame.Locked_Modal := (not result); //set lock image based on result
      end;
  end;

  {$endregion}

  {$region 'URLs'}

  procedure TStory.DoUrlAction(const UrlAction: String);
  begin
    if UrlAction = '' then exit;

    var LUrl := UrlAction;

    var TagsMatching := TagsMatching_Default;

    //--- Check for ! prefix to skip Tags Matching ---
    if LUrl.StartsWith('!') then
    begin
      Delete(LUrl, 1, 1); //remove first letter (the !) from LUrl parameter
      TagsMatching := TagsMatching_Skip;
    end;

    //--- Check for ?/??/??? prefix to force Tags Matching and show just closed (?) or open/closed (???) lock prompt or with no prompt / silent (???). Overrides any earlier !

    if LUrl.StartsWith('?') then
    begin
      Delete(LUrl, 1, 1); //remove first letter (the ?) from LUrl parameter
      TagsMatching := TagsMatching_Fail_Prompt;

      if LUrl.StartsWith('?') then //check if 2nd ? follows
      begin
        Delete(LUrl, 1, 1); //remove first letter (the ?) from LUrl parameter
        TagsMatching := TagsMatching_OkFail_Prompt;
      end;

      if (LUrl = '') then //we just have ? or ?? with nothing following
      begin
        CheckTagsMatched(TagsMatching); //ignore result, just show Tags Matching prompt to user
        exit;
      end;

      if LUrl.StartsWith('?') then //check if 3rd ? follows
      begin
        Delete(LUrl, 1, 1); //remove first letter (the ?) from LUrl parameter
        TagsMatching := TagsMatching_Silent_Prompt;
      end;
    end;

    //--- In-Story Navigation URLs (with Tags Matching is set to do so, or for + [NextStoryPoint] by default [unless + tag matching is bypassed with ! prefix]) ---

    if LUrl = '-' then
    begin
      ActivatePreviousStoryPoint(TagsMatching); //?-, ??-, ???- will do tags matching
      exit;
    end;

    if LUrl = '+' then
    begin
      ActivateNextStoryPoint(TagsMatching); //!+ will skip tags matching
      exit;
    end;

     if LUrl = '0' then
    begin
      ActivateHomeStoryItem(TagsMatching); //?0, ??0, ???0 will do tags matching
      exit;
    end;

    //TODO: check for other StoryPoint reference to Activate that, needed to be able to make Stories with alternative flows
    //(e.g. "1.3" [if root is storypoint] or "3" in the flattened StructureView tree of non-Edit mode)

    //--- Resource URLs - including navigation to other .readcom story (with Tags Matching checking if not bypassed with "!" prefix and only if explicitly asked for with "+" prefix) ---

    ActivateUrl(LUrl, TagsMatching);
  end;

  {$endregion}

  {$region 'ActiveStoryItem'}

  function TStory.GetActiveStoryItem: IStoryItem;
  begin
    result := TStoryItem.ActiveStoryItem;
  end;

  procedure TStory.SetActiveStoryItem(const Value: IStoryItem);
  begin
    TStoryItem.ActiveStoryItem := Value;
  end;

  procedure TStory.ActivateRootStoryItem;
  begin
    ActiveStoryItem := RootStoryItem; //there's always a RootStoryItem
  end;

  procedure TStory.ActivateParentStoryItem;
  begin
    var activeItem := ActiveStoryItem;
    if Assigned(activeItem) then
      activeItem.ActivateParentStoryItem; //this checks if ParentStoryItem is nil and does nothing in that case
  end;

  procedure TStory.ActivateHomeStoryItem(const TagsMatching: TTagsMatching = TagsMatching_Default);
  begin
     if (TagsMatching = TagsMatching_Default) or //skip tags matching by default for HomeStoryItem
       CheckTagsMatched(TagsMatching) //pass it to CheckTagsMatched to do close-only or open/close lock prompting and return matching state
    then
    begin
      ActiveStoryItem := HomeStoryItem; //there's always a HomeStoryItem (code that loads the story takes care of that if none found, setting the RootStoryItem as HomeStoryItem)

      if (TagsMatching = TagsMatching_OkFail_Prompt) then
        TLockFrame.Hide_Modal(OPENLOCK_DELAY);
    end;
  end;

  procedure TStory.ActivateAncestorStoryPoint;
  begin
    var activeItem := ActiveStoryItem;
    if Assigned(activeItem) then
      UI.SetActiveStoryItemIfAssigned(activeItem.GetAncestorStoryPoint);
  end;

  procedure TStory.ActivatePreviousStoryPoint(const TagsMatching: TTagsMatching = TagsMatching_Default);
  begin
    if (TagsMatching = TagsMatching_Default) or //skip tags matching by default for PreviousStoryPoint
       CheckTagsMatched(TagsMatching) //pass it to CheckTagsMatched to do close-only or open/close lock prompting and return matching state
    then
    begin
      UI.SetActiveStoryItemIfAssigned(PreviousStoryPoint);

      if (TagsMatching = TagsMatching_OkFail_Prompt) then
        TLockFrame.Hide_Modal(OPENLOCK_DELAY);
    end;
  end;

  procedure TStory.ActivateNextStoryPoint(const TagsMatching: TTagsMatching = TagsMatching_Default);
  begin
    if //(TagsMatching = TagsMatching_Default) or //commented out, default for NextStoryPoint is to do tags matching
       CheckTagsMatched(TagsMatching) //pass it to CheckTagsMatched to do close-only or open/close lock prompting and return matching state
    then
    begin
      UI.SetActiveStoryItemIfAssigned(NextStoryPoint); //either bypassing Tags Matcing, or Tags are Matched, advance to NextStoryPoint

      if (TagsMatching = TagsMatching_OkFail_Prompt) then
        TLockFrame.Hide_Modal(OPENLOCK_DELAY);
    end;
  end;

  procedure TStory.ActivateUrl(const Url:string; const TagsMatching: TTagsMatching = TagsMatching_Default); //open new story when ending in .readcom, else open url in browser
  begin
    if (TagsMatching = TagsMatching_Default) or //skip tags matching by default for URLs
       CheckTagsMatched(TagsMatching) //pass it to CheckTagsMatched to do close-only or open/close lock prompting and return matching state
    then
    begin
      if Url.EndsWith(EXT_READCOM, True) then //if it's a LUrl to a .readcom file (case-insensitive comparison)
        UI.LoadFromUrl(Url) //either bypassing Tags Matcing, or Tags are Matched, advance to LUrl
      else
        Application.OpenUrl(Url); //else open in system browser

      if (TagsMatching = TagsMatching_OkFail_Prompt) then
        TLockFrame.Hide_Modal(OPENLOCK_DELAY);
    end;
  end;

  {$endregion}

  {$region 'StoryMode'}

  function TStory.GetStoryMode: TStoryMode;
  begin
    result := FStoryMode;
  end;

  procedure TStory.SetStoryMode(const Value: TStoryMode);
  begin
    FStoryMode := Value;
    var isEditMode := (Value = EditMode);

    if Assigned(ActiveStoryItem) then
    begin
      var view := ActiveStoryItem.View as TStoryItem;
      if Assigned(view) then
      begin
        view.EditMode := isEditMode; //TODO: should add an EditMode property to the Story?
        ZoomToActiveStoryPointOrHome; //keep the Active StoryPoint or Home in view //TODO: should we always ZoomTo when switching story mode? (e.g. entering or exiting EditMode? this is useful after having autoloaded saved state)
      end;
    end;

    if Assigned(UI.FStructureView) then //Note: don't use StructureView property here, will allocate FStructureView if not assigned
      with UI.FStructureView do
      begin
        DragDropReorder := isEditMode; //allow moving items in the structure view to change parent or add to same parent again to change their Z-order
        DragDropReparent := isEditMode; //allow reparenting //TODO: should do after listening to some event so that the control is scaled/repositioned to show in their parent (note that maybe we should also have parent story items clip their children, esp if their panels)
        RefreshStructure; //must refresh StructureView contents since we change the FilterMode based on isEditMode //TODO: shouldn't the StructureView autoupdate in this case? (RefreshStructure calls UI.UpdateStructureView which seems to do a lot of things though)
      end;

    if (not isEditMode) and Assigned(ActiveStoryItem) and (not ActiveStoryItem.StoryPoint) then //if current ActiveStoryItem isn't a StoryPoint, then when exiting Edit mode...
    begin
      var ancestor := ActiveStoryItem.GetAncestorStoryPoint; //...try to activeate an ancestor StoryPoint
      if Assigned(ancestor) then
        ActiveStoryItem := ancestor
      else
        ActiveStoryItem := RootStoryItem; //...making sure we always end up with an ActiveStoryItem (the RootStoryItem) when no StoryPoints have been defined
    end;
  end;

  {$endregion}

  {$ENDREGION .................................................................}

  {$REGION 'TEditableStory' ---------------------------------------------------}

  procedure TEditableStory.NewRootStoryItem; //Note: make sure any keyboard actions call the action event handlers since only those do confirmation
  begin
    with UI do
    begin
      RootStoryItemView := nil; //must do first to free the previous one (to avoid naming clashes)
      var newRootStoryItemView := TImageStoryItem.Create(Self); //Note: very old versions may expect a TBitmapImageStoryItem instead, ignoring them to keep design clean
      with newRootStoryItemView do
        begin
        //ClipChildren := true; //Empty RootStoryItem should maybe clip its children (not doing at SetRootStoryItem since we may have loaded a template there - anyway commenting out here too in case one wants to design a template from scratch)
        Size.Size := TSizeF.Create(ZoomFrame.Width, ZoomFrame.Height);
        EditMode := HUD.EditMode; //TODO: add EditMode property to IStory or use its originally intended mode one
        end;
      RootStoryItemView := newRootStoryItemView;
    end;
  end;

  procedure TEditableStory.AddChildStoryItem(const TheStoryItemClass: TClass; const TheName: String); //assuming TStoryItemClass is passed
  begin
    if not ((StoryMode = EditMode) and Assigned(ActiveStoryItem)) then exit; //only in Edit mode and when an ActiveStoryItem is assigned

    var OwnerAndParent := ActiveStoryItem.View;

    var StoryItem := TStoryItemClass(TheStoryItemClass).Create(OwnerAndParent, TheName); //TODO: should have separate actions for adding such default items (for prototyping) for various StoryItem classes

    with StoryItem do
    begin
      Align := TAlignLayout.Scale; //IMPORTANT: adjust when parent resizes
      Parent := OwnerAndParent;

      var TheAreaSelector := TStoryItem(OwnerAndParent).AreaSelector; //WARNING: Delphi 11 seems to resolve identifiers against the "with" first and THEN the local variables that were defined inside the with block. Don't name this AreaSelector since StoryItem has such property and accessing the Visible property below will get the wrong result...
      if TheAreaSelector.Visible and (TheAreaSelector.Width <> 0) and (TheAreaSelector.Height <> 0) then //...even worse the IDE introspection during debugging shows the object one was expecting (the one from the local variable), but the one from with would be used instead (checking the wrong "Visible" property value)
      begin
        Size.Size := TheAreaSelector.Size.Size;
        Position.Point := TheAreaSelector.Position.Point; //TODO: assuming the AreaSelector has the same parent, if not (say using a global area selector in the future) should have some way for the AreaSelector to give map the coordinates to the wanted parent
      end
      else
      begin
        var ItemSize := DefaultSize;
        Size.Size := ItemSize; //TODO: StoryItem constructor should have set its DefaultSize
        //Center the new item in its parent...
        Position.Point := PointF(OwnerAndParent.Size.Width/2 - ItemSize.Width/2, OwnerAndParent.Size.Height/2 - ItemSize.Height/2); //not creating TPosition objects to avoid leaking (TPointF is a record)
      end;

      BringToFront; //load as front-most
    end;

    RefreshStructure; //TODO: should instead have some notification from inside a StoryItem towards the StructureView that children were added to it (similar to how StructureView listens for children removal)
  end;

  //

  procedure TEditableStory.DeleteActiveStoryItem; //Note: make sure any keyboard actions call the action event handlers since only those do confirmation
  begin
    if not Assigned(ActiveStoryItem) then exit;

    if ActiveStoryItem.IsRoot then
      NewRootStoryItem //deleting the RootStoryItem via "NewRootStoryItem", but not via "HUD.actionNew.Execute" since that also tries "LoadDefaultDocument" first //RootStoryItem change updates StructureView //note: confirmation is only done at "HUDactionCutExecute"
    else
      ActiveStoryItem.Delete; //this makes ParentStoryItem active (which updates StructureView)
  end;

  procedure TEditableStory.CutActiveStoryItem; //Note: make sure any keyboard actions call the action event handlers since only those do confirmation (e.g. when Root is the ActiveStoryItem)
  begin
    if not Assigned(ActiveStoryItem) then exit;

    if ActiveStoryItem.IsRoot then
      begin
        ActiveStoryItem.Copy; //needed to simulate "Cut"
        NewRootStoryItem; //deleting the RootStoryItem via "NewRootStoryItem", but not via "HUD.actionNew.Execute" since that also tries "LoadDefaultDocument" first //RootStoryItem change updates StructureView //note: confirmation is only done at "HUDactionCutExecute"
      end
    else
      ActiveStoryItem.Cut; //this makes ParentStoryItem active (which updates StructureView)
  end;

  procedure TEditableStory.CopyActiveStoryItem;
  begin
    if not Assigned(ActiveStoryItem) then exit;

    ActiveStoryItem.Copy;
  end;

  procedure TEditableStory.PasteInActiveStoryItem;
  begin
    if not Assigned(ActiveStoryItem) then exit;

    ActiveStoryItem.Paste;

    RefreshStructure; //TODO: should do instead similar to deletion by somehow notifying from inside the StoryItem itself the StructureView that items have been added
  end;

  {$ENDREGION .................................................................}

  {$REGION 'TStoryForm' --------------------------------------------------------}

  {$region 'DoWithWaitPrompt' //TODO: move to a TWaitFrame class method (say TWaitFrame.Do)}

  procedure DoWithWaitPrompt(const Action: TProc; ParentForm: TFmxObject = nil);
  begin
    if ParentForm = nil then
      ParentForm := Application.MainForm;

    TThread.Synchronize(nil, //TODO: move this into ShowModal? (when closing it does ForceQueue, maybe when opening it should always do Thread.Synchrnonize)
      procedure
      begin
        TWaitFrame.ShowModal(ParentForm);
      end
    ); //needed so that the UI refreshes to show the wait prompt

    try
      TThread.Synchronize(nil,
        procedure()
        begin
          Action();
        end
      );

    finally
      TWaitFrame.ShowModal(ParentForm, false); //this is the last command so doesn't need a TThread.Synchronize, UI will refresh after the event handler returns and hide the wait prompt
    end;
  end;

  {$endregion}

  {$REGION 'Init / Destroy'}

  procedure TStoryForm.FormCreate(Sender: TObject);

    procedure InitHUD;
    begin
      with HUD do
      begin
        //keep shortcut keys for Cut/Copy/Paste actions to be able to restore them after disabling them when TextStoryItem is active (to not interfere with text editing)
        FShortcutCut := HUD.actionCut.ShortCut;
        FShortcutCopy := HUD.actionCopy.ShortCut;
        FShortcutPaste := HUD.actionPaste.ShortCut;

        BringToFront;
        BtnMenu.BringToFront;
        layoutButtons.BringToFront;

        EditMode := false;
        StructureVisible := false;
        TargetsVisible := false;

        OnEditModeChanged := HUDEditModeChanged;
        OnStructureVisibleChanged := HUDStructureVisibleChanged;
        OnTargetsVisibleChanged := HUDTargetsVisibleChanged;
        OnUseStoryTimerChanged := HUDUseStoryTimerChanged;

        TStoryItem.OnActiveStoryItemChanged := HandleActiveStoryItemChanged;
      end;
    end;

  begin
    {$IFDEF NOSTYLE}
    StyleBook := nil; //TODO: can we make a style platform agnostic?
    {$ELSE}
    StyleBook := Themes.LightTheme;
    {$ENDIF}

    const StrAppVersion = '(' + Application.AppVersion + ')';
    Caption := STR_APP_TITLE + ' ' + StrAppVersion;

    {$IF DEFINED(MSWINDOWS)}
    if not GlobalUseDX then //GlobalUseDX10 (not using that, using fallback to plain GDI)
      Caption := STR_APP_TITLE + ' ' + STR_COMPATIBILITY_MODE;
    {$ENDIF}

    Story := TEditableStory.Create(Self);
    TStoryItem.Story := Self.Story; //provide a way to StoryItems to influence the Story context

    FTimerStarted := false;
    FCheckedCommandLineActions := false;

    InitHUD;
    InitObjectDebugger(Self); //TODO: should move to Main and do only once for the Application.MainForm

    //ZoomFrame.ScrollBox.AniCalculations.AutoShowing := true; //fade the toolbars when not active //TODO: doesn't work with direct mouse drags near the bottom and right edges (scrollbars do show when scrolling e.g. with mousewheel) since there's other HUD content above them (the navigation and the edit sidebar panes)

    Application.OnIdle := Idle;

    if Assigned(FOnStoryFormReady)
    then
      FOnStoryFormReady(Self); //passing the TStoryForm instance to the event handler //Note: event handler should check if Application.MainForm equals the event parameter or is nil if they want to check if this is the main form (in case multiple ones are made available in the future [to have multiple open Stories])

    DoWithWaitPrompt(
      procedure
      begin
        LoadAtStartup;
      end
    );
  end;

  procedure TStoryForm.FormDestroy(Sender: TObject);
  begin
    //NOP
  end;

  procedure TStoryForm.FormShow(Sender: TObject);
  begin
    //NOP
  end;

  {$ENDREGION}

  {$REGION 'TStory related'}

  {$region 'RootStoryItemView'}

  function TStoryForm.GetRootStoryItemView: TStoryItem;
  begin
    result := TObjectListEx<TControl>.GetFirstClass<TStoryItem>(ZoomFrame.ScaledLayout.Controls)
  end;

  procedure TStoryForm.SetRootStoryItemView(const Value: TStoryItem);
  begin
    //Remove old story
    var TheRootStoryItemView := RootStoryItemView;
    if Assigned(TheRootStoryItemView) and (Value <> TheRootStoryItemView) then //must check that the same one isn't set again to avoid destroying it
    begin
      //TheRootStoryItemView.Parent := nil; //shouldn't be needed
      Story.ActiveStoryItem := nil; //must clear reference to old ActiveStoryItem since all StoryItems will be destroyed
      FreeAndNil(TheRootStoryItemView); //destroy the old RootStoryItem //FREE THE CONTROL, DON'T FREE JUST THE INTERFACE
    end;

    //Add new story, if any
    if Assigned(Value) then //allowing to set the same one to update any zooming/positioning calculations if needed
    begin
      with Value do
      begin
        Position.Point := TPointF.Zero; //ignore any Position value, want to have the RootStoryItem centered in the zoomable container

        Align := TAlignLayout.Center; //IMPORTANT: Center to zoomable container, if it had "Scaled" it would crash on Zoom in/out. Note that at TStoryItem.Add any .readcom content added as children is set to use "Align := TAlignLayout.Scale", so that the children scale as their parent StoryItem resizes

        AutoSize := true; //TODO: the Root StoryItem should be expandable
        OnResized := RootStoryItemViewResized; //listen for resizing to adapt ZoomFrame.ScaledLayout's size //TODO: this doesn't seem to get called

        var newSize := Size.Size;

        (*
        var currentZoomerSize := ZoomFrame.Zoomer.Size.Size; //don't get size of zoomFrame itself
        var newZoomerSize := TSizeF.Create(Max(currentZoomerSize.cx, newSize.cx), Max(currentZoomerSize.cy, newSize.cy));
        ZoomFrame.Zoomer.Size.Size := newZoomerSize; //use the next line instead
        ZoomFrame.SetZoomerSize(newZoomerSize); //must use this since it sets other zoomer params too
        *)

        BeginUpdate; //TODO: move this working code to TZoomFrame
        Parent := nil; //remove from parent first (needed if we're calling this code to adjust for RootStoryItem resize action)
        ZoomFrame.ScaledLayout.Align := TAlignLayout.None;
        ZoomFrame.ScaledLayout.Size.Size := newSize;
        ZoomFrame.ScaledLayout.OriginalWidth := newSize.cx; //needed to reset the ScalingFactor
        ZoomFrame.ScaledLayout.OriginalHeight := newSize.cy; //needed to reset the ScalingFactor
        ZoomFrame.ScaledLayout.Align := TAlignLayout.Fit;
        EndUpdate;

        Parent := ZoomFrame.ScaledLayout; //don't use ZoomFrame as direct parent

        //ClipChildren := true; //Note: not doing here, since if RootStoryItem always clip its children and we load a Template (say a rabbit with its speech bubble), then children of that template will be clipped and when saved the top object in that template will get the ClipChildren=true which is unwanted
      end;

      with Story do
      begin
        if not Assigned(Story.HomeStoryItem) then
          HomeStoryItem := RootStoryItem; //set RootStoryItem as the HomeStoryItem if no such assigned

        if not Assigned(ActiveStoryItem) then
          ActiveStoryItem := RootStoryItem; //set RootStoryItem as the ActiveStoryItem if no such is set (e.g. from loaded state). Note this will also try to ZoomTo it
      end;

      CheckReplaceStoryAllText;

      CheckProperOrientation; //checking proper orientation based on the StoryItem that is active upon the loading of the story (usually it's the HomeStoryItem, but could be the RootStoryItem if there's no Home set, or be other StoryItem if loading from saved state)
    end;

    UpdateStructureView;
  end;

  {$endregion}

  {$region 'ActiveStoryItem'}

  procedure TStoryForm.SetActiveStoryItemIfAssigned(const Value: IStoryItem);
  begin
    if Assigned(Value) then
      Story.SetActiveStoryItem(Value);
  end;

  procedure TStoryForm.HandleActiveStoryItemChanged(Sender: TObject);

    procedure RecursiveClearEditMode(const partialRoot: IStoryItem);
    begin
      if Assigned(partialRoot) then
      begin
        var StoryItem := TStoryItem(partialRoot.View);
        StoryItem.EditMode := false; //TODO: see StoryMode of IStoryItem instead
        StoryItem.Enabled := true; //restore any items that had been left disabled accidentally
        //StoryItem.Enabled := (StoryMode <> EditMode) and (StoryItem <> RootStoryItemView); //TODO: test

        //Do for item's children too if any
        for var ChildStoryItem in partialRoot.StoryItems do
          RecursiveClearEditMode(ChildStoryItem);
      end;
    end;

  begin
    //TODO: in non-EditMode should activate closest parentStoryPoint instead

    RecursiveClearEditMode(RootStoryItemView); //Clear EditMode from all items recursively

    var Value := Story.ActiveStoryItem;

    //Set any current editmode to the newly active item
    if Assigned(Value) then
    begin
      var StoryItem := TStoryItem(Value.View);
      with StoryItem do
      begin
        EditMode := HUD.EditMode; //TODO: see StoryMode of IStoryItem instead (or move that to the IStory)
        //AreaSelector := RootStoryItemView.AreaSelector; //re-use RootStoryItem's AreaSelector (so that we don't get drawing artifacts when resizing area selector and is always on top of everything when extending outside of ActiveStoryItem's bounds - since that can have children that are not inside its area, like a speech bubble for a character) //TODO: not working correctly
      end;

      //Update color pickers
      HUD.comboForeColor.Color := StoryItem.ForegroundColor;
      HUD.comboBackColor.Color := StoryItem.BackgroundColor;

      //Cut-Copy-Paste shortcut keys variation for TextStoryItem //TODO: should maybe disable respective actions in non-Edit mode, even though they do check it to do nothing when not in edit mode
      if (StoryItem is TTextStoryItem) then
      begin
        //Note: don't use plain TextToShortcut, returns -1 on Android at Delphi 11.1, which gives Range Check Error since TCustomAction.Shortcut doesn't accept values <0. Delphi 12.2 seems to have this fixed, returning 0 in that case
        HUD.actionCut.ShortCut := SafeTextToShortCut('Ctrl+Shift+X'); //set alternate shortcut while TTextStoryItem is being edited
        HUD.actionCopy.ShortCut := SafeTextToShortCut('Ctrl+Shift+C'); //set alternate shortcut while TTextStoryItem is being edited
        HUD.actionPaste.ShortCut := SafeTextToShortCut('Ctrl+Shift+V'); //set alternate shortcut while TTextStoryItem is being edited
      end
      else if TAllTextFrame.Shown then //disable editing shortcuts of app when AllTextFrame is shown
      begin
        HUD.actionCut.ShortCut := 0;
        HUD.actionCopy.ShortCut := 0;
        HUD.actionPaste.ShortCut := 0;
      end
      else
      begin
        HUD.actionCut.ShortCut := FShortcutCut; //TextToShortCut('Ctrl+X'); //Note: instead of hardcoding shortcuts here reading them on form statup and keep them to restore here
        HUD.actionCopy.ShortCut := FShortcutCopy; //TextToShortCut('Ctrl+C');
        HUD.actionPaste.ShortCut := FShortcutPaste; //TextToShortCut('Ctrl+V');
      end;

      if HUD.StructureVisible then
        StructureView.SelectedObject := StoryItem; //Change StructureView selection (ONLY WHEN StructureView is visible)
    end
    else
      if HUD.StructureVisible //Clear StructureView selection (ONLY WHEN StructureView is visible)
         and Assigned(StructureView) //when app is getting destroyed this will return nil
      then
        StructureView.SelectedObject := nil;

    //HUD.actionDelete.Visible := (ActiveStoryItem.View <> RootStoryItem.View); //doesn't seem to work (neither HUD.btnDelete.Visible does), but have implemented delete of RootStoryItem as a call to actionNew.Execute instead

    Story.ZoomToActiveStoryPointOrHome;

    //CheckProperOrientation; //don't do here, it gets annoying to show rotation modal popup upon navigation, plus some Stories may have StoryItems that are designed to be partially appear side-by-side to appear as books
  end;

  procedure TStoryForm.NavigateUp;
  begin
    with Story do
      if (StoryMode <> EditMode) then //if not in Edit mode...
        ActivateAncestorStoryPoint //go to (nearest) AncestorStoryPoint, if any
      else //if in Edit mode...
        if FShiftDown then //if SHIFT pressed, go to RootStoryItem
          ActivateRootStoryItem
        else
          ActivateParentStoryItem //go to ParentStoryItem
  end;

  {$endregion}

  {$region 'Zooming'}

  procedure TStoryForm.StartInitialZoomTimer(const Delay: Cardinal = 100);
  begin
    with StoryTimer do
    begin
      Enabled := false;
      FTimerStarted := false; //used for timer to detect this is a special case
      Interval := Delay;
      Enabled := true; //used to zoom to Active or Home StoryItem after the form has fully sized (FormShow event doesn't do this properly)
    end;
  end;

  {$endregion}

  {$ENDREGION}

  {$REGION 'Events'}

  {$region 'File actions'}

  procedure TStoryForm.HUDactionNewExecute(Sender: TObject);
  begin
    TApplication.Confirm(MSG_CONFIRM_CLEAR_STORY, //confirmation done only at the action level //Note: could also use Application.Confirm since Confirm is defined as a class function in ApplicationHelper (and those can be called on object instances of the respective class too)
      procedure(Confirmed: Boolean)
      begin
        if Confirmed and (not LoadDefaultDocument) then
          Story.NewRootStoryItem;
      end
    );
  end;

  procedure TStoryForm.HUDactionLoadExecute(Sender: TObject);
  begin
    DoWithWaitPrompt(
      procedure
      begin
        //HUD.actionLoadExecute(Sender);

        var TempStoryItem := TStoryItem.Create(nil); //using TempStoryItem of TStoryItem type to show generic file dialog filter
        try
          var Filename := TempStoryItem.Options.ActLoad_GetFilename; //assuming this is blocking action
          if (Filename <> '') then
            begin
              if LoadFromFile(Filename) then //Note: just doing RootStoryItemView := TStoryItem.LoadNew(Filename) wouldn't work do font resizing since that won't do StartInitialZoomTimer
                Story.ActivateHomeStoryItem; //set the HomeStoryItem (if not any the RootStoryItem will have been set as such by SetRootStoryView) to active (not doing this when loading saved app state)

              //TODO: OLD-CODE-LINE-REMOVE? //RootStoryItemView := RootStoryItemView; //repeat calculations to adapt ZoomFrame.ScaledLayout size //TODO: when RootStoryItemViewResized starts working this shouldn't be needed here anymore
            end;
        finally
          FreeAndNil(TempStoryItem);
        end;
      end
    );
  end;

  procedure TStoryForm.HUDactionSaveExecute(Sender: TObject);
  begin
    DoWithWaitPrompt(
      procedure
      begin
        //HUD.actionSaveExecute(Sender);
        Story.RootStoryItem.Options.ActSave; //this shows a file dialog
      end
    );
  end;

  {$endregion}

  {$region 'Edit-mode actions'}

  procedure TStoryForm.HUDEditModeChanged(Sender: TObject; const Value: Boolean);
  begin
    with Story do
      if Value then
        StoryMode := EditMode
      else
        StoryMode := TStoryMode.InteractiveStoryMode; //TODO: should remember previous mode to restore or make EditMode a separate situation
  end;

  {$region 'Add actions'}

  procedure TStoryForm.HUDactionAddExecute(Sender: TObject);
  begin
    with Story do
    begin
      if not ((StoryMode = EditMode) and Assigned(ActiveStoryItem)) then exit; //only in Edit mode and when an ActiveStoryItem is assigned

      ActiveStoryItem.Options.ActAdd;
      UpdateStructureView; //TODO: should instead have some notification from inside a StoryItem towards the StructureView that children were added to it (similar to how StructureView listens for children removal)
    end;
  end;

  procedure TStoryForm.HUDactionAddImageStoryItemExecute(Sender: TObject); //TODO: should change to add a VisualStoryItem that will support any kind of visual item
  begin
    with Story do
    begin
      if not ((StoryMode = EditMode) and Assigned(Story.ActiveStoryItem)) then exit; //only in Edit mode and when an ActiveStoryItem is assigned

      AddChildStoryItem(TImageStoryItem, 'ImageStoryItem'); //will also update the StructureView //Note: very old versions may expect a TBitmapImageStoryItem instead, ignoring them to keep design clean
      //problem is they don't show border when in non-Edit mode, but could have option to show border for any StoryItem and/or style the border color/width, clip children etc. to make like older PanelStoryItem
    end;
  end;

  procedure TStoryForm.HUDactionAddTextStoryItemExecute(Sender: TObject);
  begin
    with Story do
    begin
      if not ((StoryMode = EditMode) and Assigned(Story.ActiveStoryItem)) then exit; //only in Edit mode and when an ActiveStoryItem is assigned

      Story.AddChildStoryItem(TTextStoryItem, 'TextStoryItem'); //will also update the StructureView
    end;
  end;

  {$endregion}

  {$region 'Edit actions'}

  procedure TStoryForm.HUDactionDeleteExecute(Sender: TObject);
  begin
    with Story do
    begin
      if not ((StoryMode = EditMode) and Assigned(Story.ActiveStoryItem)) then exit; //only in Edit mode (plus safety check for ActiveStoryItem before prompting user)

      var msg: String;
      if ActiveStoryItem.IsRoot then
        msg := MSG_CONFIRM_CLEAR_STORY
      else
        msg := MSG_CONFIRM_DELETION;

      //Always confirming for destructive actions like deletion
      TApplication.Confirm(msg, //confirmation done only at the action level //Note: could also use Application.Confirm since Confirm is defined as a class function in ApplicationHelper (and those can be called on object instances of the respective class too)
        procedure(Confirmed: Boolean)
        begin
          if Confirmed then
           DeleteActiveStoryItem;
        end
      );
    end;
  end;

  procedure TStoryForm.HUDactionCutExecute(Sender: TObject);
  begin
    if FShiftDown then //if Shift key is pressed...
    begin
      HUDactionDeleteExecute(Sender); //...do Delete instead of Cut
      exit;
    end;

    with Story do
    begin
      if not ((StoryMode = EditMode) and Assigned(Story.ActiveStoryItem)) then exit; //only in Edit mode (plus safety check for ActiveStoryItem before prompting user)

      //Not considering Cut a destructive action since one can Paste back. However when cutting the RootStoryItem, since it has no parent to be activated and a new RootStoryItem will be created, paste back means it will become a child of the new RootStoryItem, so asking for confirmation only when cutting the RootStoryItem
      if ActiveStoryItem.IsRoot then
        TApplication.Confirm(MSG_CONFIRM_CLEAR_STORY, //confirmation done only at the action level //Note: could also use Application.Confirm since Confirm is defined as a class function in ApplicationHelper (and those can be called on object instances of the respective class too)
          procedure(Confirmed: Boolean)
          begin
            if Confirmed then
              CutActiveStoryItem;
          end
        )
      else
        CutActiveStoryItem; //no confirmation needed for cutting non-Root StoryItems
    end;
  end;

  procedure TStoryForm.HUDactionCopyExecute(Sender: TObject);
  begin
    with Story do
      if (StoryMode = EditMode) then //only in Edit mode
        CopyActiveStoryItem; //will check if ActiveStoryItem is assigned
   end;

  procedure TStoryForm.HUDactionPasteExecute(Sender: TObject);
  begin
    with Story do
      if (StoryMode = EditMode) then //only in Edit mode
        PasteInActiveStoryItem; //will check if ActiveStoryItem is assigned
  end;

  {$endregion}

  {$region 'Flip actions'}

  procedure TStoryForm.HUDactionFlipHorizontallyExecute(Sender: TObject);
  begin
    with Story do
    begin
      if not ((StoryMode = EditMode) and Assigned(ActiveStoryItem)) then exit; //only in Edit mode and when an ActiveStoryItem is assigned

      ActiveStoryItem.FlippedHorizontally := not ActiveStoryItem.FlippedHorizontally;
      UpdateStructureView; //TODO: should maybe only update the tree of thumbs from the ActiveStoryItem up to the root by somehow notifying from inside the StoryItem itself the StructureView our graphics have changed
    end;
  end;

  procedure TStoryForm.HUDactionFlipVerticallyExecute(Sender: TObject);
  begin
    with Story do
    begin
      if not ((StoryMode = EditMode) and Assigned(ActiveStoryItem)) then exit; //only in Edit mode and when an ActiveStoryItem is assigned

      ActiveStoryItem.FlippedVertically := not ActiveStoryItem.FlippedVertically;
      UpdateStructureView; //TODO: should maybe only update the tree of thumbs from the ActiveStoryItem up to the root by somehow notifying from inside the StoryItem itself the StructureView our graphics have changed
    end;
  end;

  {$endregion}

  {$region 'Color actions'}

  procedure TStoryForm.HUDcomboForeColorChange(Sender: TObject);
  begin
    var LActive := Story.ActiveStoryItem;
    if not Assigned(LActive) then exit;

    LActive.ForegroundColor := HUD.comboForeColor.Color; //TODO: could check for some interface (IForegroundColor interface)
  end;

  procedure TStoryForm.HUDcomboBackColorChange(Sender: TObject);
  begin
    var LActive := Story.ActiveStoryItem;
    if not Assigned(LActive) then exit;

    LActive.BackgroundColor := HUD.comboBackColor.Color; //TODO: could check for some interface (IBackgroundColor interface)
  end;

  {$endregion}

  {$region 'Options action'}

  procedure TStoryForm.ShowActiveStoryItemOptions;
  begin
    with Story do
      if Assigned(ActiveStoryItem) and (StoryMode = EditMode) then
        ActiveStoryItem.Options.ShowPopup;
    end;

  procedure TStoryForm.HUDactionOptionsExecute(Sender: TObject);
  begin
    ShowActiveStoryItemOptions;
  end;

  {$endregion}

  {$endregion}

  {$region 'View actions'}

  procedure TStoryForm.UpdateStructureView;
  begin
    Log('UpdateStructureView');
    StartTiming; //doing nothing in non-DEBUG builds

    if not HUD.StructureVisible then
      Log('Ignoring UpdateStructureView, currently hidden')
    else
    with StructureView do
      begin
        if (Story.StoryMode <> EditMode) then
          FilterMode := tfFlatten
        else
          FilterMode := tfPrune;

        GUIRoot := RootStoryItemView;

        var LActiveStoryItem := Story.ActiveStoryItem;
        if Assigned(LActiveStoryItem) then
          SelectedObject := LActiveStoryItem.View;
      end;

    StopTiming_msec; //this will Log elapsed msec at DEBUG builds
  end;

  //

  procedure TStoryForm.HUDStructureVisibleChanged(Sender: TObject; const Value: Boolean);
  begin
    if Value then
      UpdateStructureView;

    with FStructureView do //TODO: see why we need those for the hidden StructureView to not grab mouse events from the area it was before collapse on the form (Probably a MultiView bug with or without the combination of TFrameStand to put a frame at the side tray)
    begin
      Visible := Value;
      Enabled := Value;
      HitTest := Value;
    end;
  end;

  procedure TStoryForm.HUDTargetsVisibleChanged(Sender: TObject; const Value: Boolean);
  begin
    if HUD.TargetsVisible then
      with Story do
        if Assigned(ActiveStoryItem) then
          ActiveStoryItem.TargetsVisible := Value;
    end;

  {$endregion}

  {$region 'Light-Dark mode actions'}

  procedure TStoryForm.HUDactionNextThemeExecute(Sender: TObject);
  begin
    if not Assigned(Themes) then exit; //Note: safety check (useful when debugging with loading of Themes data module commented-out [had some issues loading the main form on Android when that was loaded too])

    var switchToLightMode: Boolean;
    with Themes do
    begin
      switchToLightMode := DarkTheme.UseStyleManager; //don't use "LightTheme.UseStyleManager" this seems to return false, even though it's set to true in the designer (the default style is white)
      LightTheme.UseStyleManager := switchToLightMode;
      DarkTheme.UseStyleManager := not switchToLightMode;
    end;

    if switchToLightMode then //the code above isn't enough to switch theme, so switching the form's theme directly //TODO: this won't work for extra forms, try TStyleManager instead
      StyleBook := Themes.LightTheme
    else
      StyleBook := Themes.DarkTheme;
  end;

  {$endregion}

  {$region 'StructureView'}

  // Get or Create StructureView
  // note: when app is getting destroyed this will return nil
  function TStoryForm.GetStructureView: TStructureView;
  begin
    if not Assigned(FStructureView) then
      StructureView := TStructureView.Create(Self);

    result := FStructureView;
  end;

  procedure TStoryForm.SetStructureView(const Value: TStructureView);
  begin
    FStructureView := Value;
    with Value do
      begin
        ShowOnlyClasses := TClassList.Create([TStoryItem]); //TStructureView's destructor will FreeAndNil that TClassList instance
        ShowNames := false;
        ShowTypes := false;

        var isEditMode := (Story.StoryMode = EditMode);

        if (isEditMode) then
          FilterMode := tfPrune //if in edit mode then prune the tree (e.g. remove hidden StoryItems like AudioStoryItems)
        else
          FilterMode := tfFlatten; //if not in edit mode then flatten the tree (show only StoryPoints)

        DragDropReorder := isEditMode; //allow moving items in the structure view to change parent or add to same parent again to change their Z-order
        DragDropReparent := isEditMode; //allow reparenting //TODO: should do after listening to some event so that the control is scaled/repositioned to show in their parent (note that maybe we should also have parent story items clip their children, esp if their panels)
        DragDropSelectTarget := true; //always select (make active / zoom to) the Target StoryItem after a drag-drop operation in the structure view

        OnSelection := StructureViewSelection;
        OnContextMenu := StructureViewContextMenu;
        OnShowFilter := StructureViewShowFilter;

        Parent := HUD.MultiView;
        Align := TAlignLayout.Client;
      end;
  end;

  procedure TStoryForm.StructureViewShowFilter(Sender: TObject; const TheObject: TObject; var ShowObject: Boolean);
  begin
    if (Story.StoryMode <> EditMode) and
       (TheObject is TStoryItem) then //when in non-Edit mode...
      with TStoryItem(TheObject) do
        ShowObject := StoryPoint or Home; //...only show StoryPoints and Home //IMPORTANT: assuming StructureView's FilterMode=tfFlatten since we're in non-Edit mode
  end;

  procedure TStoryForm.StructureViewSelection(Sender: TObject; const Selection: TObject);
  begin
    Story.ActiveStoryItem := TStoryItem(Selection); //Make active (may also zoom to it) - assuming this is a TStoryItem since StructureView was filtering for such class //also accepts "nil" (for no selection)
  end;

  procedure TStoryForm.StructureViewContextMenu(Sender: TObject; const Selection: TObject);
  begin
    if Assigned(Selection) then
    begin
      Story.ActiveStoryItem := TStoryItem(Selection); //Make active (may also zoom to it) - assuming this is a TStoryItem since StructureView was filtering for such class //also accepts "nil" (for no selection)
      //TODO: check that ContextMenu event is indeed called before Selection, in which case it is indeed best to make the item active first
      ShowActiveStoryItemOptions;
    end;
  end;

  {$endregion}

  {$region 'Timer'}

  procedure TStoryForm.HUDUseStoryTimerChanged(Sender: TObject; const Value: Boolean);
  begin
    with StoryTimer do
    begin
      FTimerStarted := Value;
      Enabled := Value;
      Interval := 8000; //proceed ever 8sec (TODO: should be easily adjustable)
    end;
  end;

  procedure TStoryForm.StoryTimerTimer(Sender: TObject); //TODO: should show some timer animation at top-right when the story timer is enabled (AnimatedStoryMode)
  begin
    //special case used at app startup
    if not FTimerStarted then //TODO: should check if we loaded from saved state and remember if we were playing the timer and continue [see CCR.PrefsIniFile github repo maybe to keep app settings])
    begin
      StoryTimer.Enabled := false;

      with Story do
      begin
        ZoomTo; //TODO: temp fix, else showing some undrawn text when loading from temp state and till one [un]zooms or resizes (seems 0.3.1 didn't have the issue this fixes, but 0.3.0 and 0.3.2+ had it)
        ZoomToActiveStoryPointOrHome; //needed upon app first loading to ZoomTo Active StoryPoint or Home from loaded saved state
        //ActivateHomeStoryItem; //apply the home //TODO: text doesn't render yet at this point
      end;

      //CheckCommandLineActions;

      exit;
    end;

    with Story do
    begin
      ActivateNextStoryPoint;

      if Assigned(ActiveStoryItem) and ActiveStoryItem.Home then
        HUD.UseStoryTimer := false; //TODO: should instead define EndStoryPoint(s) and stop the timer once the end is reached
    end;
  end;

  {$endregion}

  {$region 'Navigation actions'}

  procedure TStoryForm.HUDactionHomeExecute(Sender: TObject);
  begin
    Story.ActivateHomeStoryItem;
  end;

  procedure TStoryForm.HUDactionPreviousExecute(Sender: TObject);
  begin
    Story.ActivatePreviousStoryPoint;
  end;

  procedure TStoryForm.HUDactionNextExecute(Sender: TObject);
  begin
    Story.ActivateNextStoryPoint;
  end;

  {$endregion}

  {$region 'Scaling'}

  procedure TStoryForm.FormResize(Sender: TObject);
  begin
    Story.ZoomToActiveStoryPointOrHome; //keep the Active StoryPoint or Home in view
    CheckProperOrientation;
  end;

  procedure TStoryForm.RootStoryItemViewResized(Sender: TObject); //TODO: this doesn't seem to get called (needed for AutoSize of RootStoryItemView to work)
  begin
    RootStoryItemView := RootStoryItemView; //repeat calculations to adapt ZoomFrame.ScaledLayout size (this keeps the zoom to fit the new size of the RootStoryItem, plus updates StructureView if open)
    //ZoomTo; //Zoom to the root //doesn't seem to do it
  end;

  {$endregion}

  {$region 'Rotation'}

  procedure TStoryForm.CheckProperOrientation;
  begin
    var activeItem := Story.ActiveStoryItem;
    if Assigned(activeItem) then
      TRotateFrame.ShowModal(Self, (Orientation <> activeItem.View.Orientation)); //Show or Hide rotation prompt based on our orientation difference compared to ActiveStoryItem.View
  end;

  {$endregion}

  {$region 'Keyboard'}

  procedure TStoryForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState); //also see HUD Actions' shortcuts
  begin
    case Key of
      vkSHIFT:
        FShiftDown := True;

      vkEscape:
        NavigateUp;

      vkPrior, vkLeft, vkUp:     //go to PreviousStoryPoint
        Story.ActivatePreviousStoryPoint;

      vkNext, vkRight, vkDown:   //go to NextStoryPoint
        Story.ActivateNextStoryPoint;

      vkHome: //go to HomeStoryItem
        Story.ActivateHomeStoryItem;

      (* //Unsafed, not used - if user is trying to type in TextStoryItem they might remove it altogether by mistake (wrong focus)
      vkDelete:
        DeleteActiveStoryItem;
      *)

      (*
      vkEnd:
        ActivateEnd; //TODO: for cheaters, go to EndStoryPoint - HOWEVER MAY WANT TO HAVE MULTIPLE ENDSTORYPOINTS, THEIR NEXTSTORYPOINT WOULD ALWAYS BE HOMESTORYITEM [Home may not be a StoryPoint but End always is else it wouldn't be reachable]? (which is the EndStoryItem should we be able to set such?)
      *)

      vkF1:
        ShowHelp; //needed since the Help key (that has the F1 key accelerator) was moved into About box to save toolbar space on small screens

      vkF2:
        HUDactionSaveExecute(Self);

      vkF3:
        HUDactionLoadExecute(Self);

      vkF4:
        HUDactionNewExecute(Self);

      vkF5:
        HUD.UseStoryTimer := not HUD.UseStoryTimer; //toggle StoryTimer

      vkF6:
        HUD.StructureVisible := not HUD.StructureVisible; //toggle StructureView visibility

      vkF7:
        HUD.EditMode := not HUD.EditMode; //toggle EditMode

      vkF8:
        if ssCtrl in Shift then //Ctrl+F8 - making sure users don't press this by mistake since it will also close the app
        begin
          Story.ActivateRootStoryItem;
          ShowMessage('Exporting to HTML and exiting'); //this seems to be needed (TThread.Queue doesn't do the trick) to always save TextStoryItem text in exported images
          TThread.Queue(nil, procedure
            begin
              Story.RootStoryItem.SaveHTML(StorySource + '.html');
              Application.Terminate;
            end
          )
        end;

      vkF9:
        TAllTextFrame.ShowModal(Self, Story.ActiveStoryItem); //has [X] button to close itself //Note: to see all text of the Story can 1st navigate to RootStoryItem in EditMode

      vkF10:
        HUD.BtnMenu.Action.Execute; //toggle buttons visibility

      vkF11:
        ToggleObjectDebuggerVisibility; //only available for DEBUG builds

      //vkF12: //don't use F12 key, when debugging with Delphi IDE it breaks into the debugger

    end;
  end;

  procedure TStoryForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  begin
    case Key of
      vkSHIFT:
        FShiftDown := False;
    end;
  end;

{$endregion}

  {$region 'Idle'}

  procedure TStoryForm.Idle(Sender: TObject; var Done: Boolean); //only process command-line actions after app enters idle mode (to be sure its GUI is ready to capture screenshots) //TODO: probably there exists other better event, sometimes have to move the mouse for command-line processing to occur
  begin
    if not FCheckedCommandLineActions then
    begin
      FCheckedCommandLineActions := true; //should process command-line once
      CheckCommandLineActions; //do the processing
    end;
  end;

  {$endregion}

  {$ENDREGION}

  {$region 'Loading / SavedState'}

  procedure TStoryForm.LoadAtStartup;
  begin
    //assuming short-circuit boolean evaluation below
    if (not LoadCommandLineParameter) and
       (not LoadSavedState) and
       (not LoadDefaultDocument) then //Note: if it keeps on failing at load comment out the if check for one run of NewRootStoryItem //TODO: shouldn't need to do that
      Story.NewRootStoryItem;
  end;

  function TStoryForm.LoadFromStream(const Stream: TStream; const ActivateHome: Boolean = True): Boolean;
  begin
    result := false;
    if Stream.Size > 0 then
    begin
      try
        RootStoryItemView := TStoryItem.LoadNew(Stream, EXT_READCOM); //a new instance of the TStoryItem descendent serialized in the Stream will be created //only set RootStoryItemView (this affects RootStoryItem too)

        if ActivateHome then
          Story.ActivateHomeStoryItem;

        StartInitialZoomTimer(100); //TODO: maybe the timer value is low //TODO: this still won't fix the font autosizing when story is loaded from saved state with Active=true at some of its StoryPoints

        result := true;
      except
        on E: Exception do
          begin
          //Stream.Clear; //clear stream if causes loading error //TODO: instead of Clear which doesn't seem to work, try saving instead a new instance of TPanelStoryItem
          Log(E);
          ShowException(E, @TStoryForm.LoadFromStream);
          end;
      end;
    end;
  end;

  function TStoryForm.LoadFromFile(const Filepath: string): Boolean;
  begin
    var InputFileStream := TFileStream.Create(Filepath,  fmOpenRead {or fmShareDenyNone}); //TODO: fmShareDenyNote probably needed for Android
    try
      result := LoadFromStream(InputFileStream);
      StorySource := Filepath;
    finally
      FreeAndNil(InputFileStream);
    end;
  end;

  function TStoryForm.LoadFromUrl(const Url: String): Boolean; //TODO: should add LoadFromUrl and AddFromUrl to TStoryItem too
  begin
    try
      TWaitFrame.ShowModal(Self);

      TURLStream.Create(Url,
        procedure(AStream: TStream) //assuming this gets called while downloading, not AFTER download. Else need to show Wait frame beforehand
        begin
          try
            Log('Started download');
            LoadFromStream(AStream); //probably it can start loading while the content is coming
            Log('Finished download');
          finally
            TWaitFrame.ShowModal(Self, false);
          end;
          StorySource := Url;
        end,
        true, //ASynchronizeProvide: call the anonymous proc (AProvider parameter) in the context of the main thread //IMPORTANT (if not done various AV errors occur later: we shouldn't touch the UI from other than the main thread)
        true //free on completion
      );

      result := true; //assuming download will progress fine
    except
      on e: Exception do
      begin
        TWaitFrame.ShowModal(Self, false);
        ShowMessageFmt(ERR_DOWNLOAD, [e.Message]);
        Log(e);
        result := false; //probably no network connection etc.
      end;
    end;
  end;

  function TStoryForm.LoadFromFileOrUrl(const PathOrUrl: String): Boolean;
  begin
    if IsURI(PathOrUrl) then
      result := LoadFromUrl(PathOrUrl)
    else
      result := LoadFromFile(PathOrUrl);
  end;

  function TStoryForm.LoadCommandLineParameter: Boolean;
  begin
    result := (StorySource <> '') and LoadFromFileOrUrl(StorySource); //assuming short-circuit boolean evaluation
  end;

  function TStoryForm.LoadDefaultDocument: Boolean;
  begin
    result := false; //don't place inside the try, else you get warning that result might be undefined
    try
      var Stream := TResourceStream.Create(HInstance, 'DefaultDocument', RT_RCDATA); //TODO: added via Project/Deployment, but not sure where the "DefaultDocument" resource name was defined (isn't shown there)
      try
        if Stream.Size > 0 then
        begin
          try
            //TODO: why not use LoadFromStream?
            RootStoryItemView := TStoryItem.LoadNew(Stream, EXT_READCOM); //a new instance of the TStoryItem descendent serialized in the Stream will be created //only set RootStoryItemView (this affects RootStoryItem too)
            result := true;
          except
            on E: Exception do
              begin
              Log(E);
              ShowException(E, @TStoryForm.LoadDefaultDocument);
              end;
          end;
        end;
      finally
        Stream.Free;
      end;
    except
      //NOP
    end;
  end;

  {$region 'SavedState'}

  function GetFileNameWithoutExt(const FullPath: string): string; //TODO: move to some utilities package
  begin
    result := ChangeFileExt(ExtractFileName(FullPath), '');
  end;

  function TStoryForm.GetSavedStateName: String;
  begin
    result := 'SavedState.readcom';
  end;

  function TStoryForm.GetSavedStateStoragePath: String;
  begin
    var LHomePath := TPath.GetHomePath;
    var LSavedStatePath := TPath.Combine(LHomePath, GetFileNameWithoutExt(Application.ExeName));

    if ForceDirectories(LSavedStatePath) then //will try to create subpaths as needed
      result := LSavedStatePath
    else
      result := LHomePath; //if we fail to create subdirectory under home path for the app, use the home path instead
  end;

  function TStoryForm.LoadSavedState: Boolean;
  begin
    Log('LoadSavedState');

    With SaveState do
    begin
      Name := GetSavedStateName;
      StoragePath := GetSavedStateStoragePath;
      result := LoadFromStream(Stream, false); //don't ActivateHome, keep last Active one (needed in case the OS brought down the app and need to continue from where we were from saved state)
      StorySource := StoragePath;
    end;
  end;

  procedure TStoryForm.SaveCurrentState;
  begin
    Log('SaveCurrentState');

    with SaveState do
    begin
      Name := GetSavedStateName;
      StoragePath := GetSavedStateStoragePath;

      Stream.Clear;

      var TheRootStoryItemView := RootStoryItemView;
      if Assigned(TheRootStoryItemView) then
        try
          TheRootStoryItemView.Save(Stream); //default file format is EXT_READCOM //Note: saves .readcom in binary (instead of text) format unless SHIFT key is being pressed
        except
          on E: Exception do
            begin
            Stream.Clear; //clear stream in case it got corrupted
            Log(E);
            ShowException(E, @TStoryForm.SaveCurrentState);
            end;
        end
    end;
  end;

  procedure TStoryForm.FormSaveState(Sender: TObject);
  begin
    //DoWithWaitPrompt( //TODO: causes error, not using for now
      //procedure
      begin
        HUD.EditMode := false; //make sure we exit EditMode, else child items of ActiveStoryItem are saved as disabled
        SaveCurrentState;
      end
    //);
  end;

  {$endregion}

  {$endregion}

  {$region 'Command-line'}

  procedure TStoryForm.CheckCommandLineActions;

    procedure CheckSaveThumbnail;
    begin
      if SaveThumbnail and (StorySource <> '') then
      begin
        var ThumbPath: String;
        if IsURI(StorySource) then
          ThumbPath := 'Thumb.png' //save in current folder
        else
          ThumbPath := StorySource + '.png';

        Story.ActiveStoryItem.SaveThumbnail(ThumbPath, ThumbnailMaxSize, ThumbnailMaxSize); //bounding box for thumbnail fitting is a square
        Application.Terminate; //close the app after saving the thumb
      end;
    end;

    procedure CheckSaveHtml;
    begin
      if SaveHtml and (StorySource <> '') then
      begin
        var HtmlPath: String;
        if IsURI(StorySource) then
          HtmlPath := 'Story.html' //save in current folder
        else
          HtmlPath := StorySource + '.html';

        Story.RootStoryItem.SaveHtml(HtmlPath, HtmlImageMaxSize, HtmlImageMaxSize); //bounding box for HTML image fitting is a square
        Application.Terminate; //close the app after saving the HTML
      end;
    end;

  begin
    TMemo.DisableFontSizeToFit := true; //don't do font fitting, seems to result in some TextStoryItems not rendering in resulting snapshot images
    CheckSaveThumbnail;
    CheckSaveHtml;
  end;

  procedure TStoryForm.CheckReplaceStoryAllText; //TODO: what's this for?
  begin
    (* //TODO
    if LoadAllText or SaveAllText and (StorySource <> '') then
    begin
      var CaptionsPath: String;
      if IsURI(StorySource) then
        CaptionsPath := 'Captions.txt' //save in current folder
      else
        CaptionsPath := StorySource + '.txt';

      if LoadAllText then
        ActiveStoryItem.LoadAllText(CaptionsPath)
      else if SaveAllText then
        ActiveStoryItem.SaveAllText(CaptionsPath);
      //TODO: add actions and parameters to localize to TARGET language (ideally should autodetect source or allow to define what the SOURCE is)
    end;
    *)
  end;

  {$endregion}

  {$ENDREGION .................................................................}

end.