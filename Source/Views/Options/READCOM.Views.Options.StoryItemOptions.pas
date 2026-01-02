unit READCOM.Views.Options.StoryItemOptions;

interface

uses
  System.SysUtils, System.Types,
  System.UITypes, //for TOpenOption
  System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts,
  FMX.Controls.Presentation, System.ImageList,
  FMX.ImgList, System.Actions, FMX.ActnList, FMX.Edit,
  FMX.Objects,
  //
  READCOM.Resources.Icons, //for Icons.SVGIconImageList
  READCOM.Models.Stories; //for IStoryItemOptions

resourcestring
  STR_ID = 'ID';
  STR_URL_ACTION = 'URL Action';
  STR_URL_ACTION_TARGET = 'URL Action Target';
  STR_FACTORY_CAPACITY = 'Factory Capacity';
  STR_TAGS = 'Tags';
  STR_COLLECTABLE_TARGET = 'Collectable Target';

type
  TStoryItemOptions = class(TFrame, IStoryItemOptions)
    LayoutStoryItemButtons: TFlowLayout;
    ActionList: TActionList;
    actionLoad: TAction;
    actionSave: TAction;
    actionAdd: TAction;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    AddDialog: TOpenDialog;
    btnToggleVisible: TSpeedButton;
    txtID: TEdit;
    btnToggleHome: TSpeedButton;
    btnToggleStoryPoint: TSpeedButton;
    btnToggleCollectable: TSpeedButton;
    btnToggleAnchored: TSpeedButton;
    btnToggleTags: TSpeedButton;
    btnToggleUrlAction: TSpeedButton;
    btnToggleFactory: TSpeedButton;
    btnLoad: TSpeedButton;
    btnSave: TSpeedButton;
    Background: TRectangle;
    btnToggleSnapping: TSpeedButton;
    Layout: TFlowLayout;
    LayoutStoryItemBreak: TFlowLayoutBreak;
    LayoutStoryItemMain: TFlowLayout;
    btnClose: TSpeedButton;
    procedure actionToggleVisibleExecute(Sender: TObject);
    procedure txtIDChange(Sender: TObject);
    procedure actionToggleHomeExecute(Sender: TObject);
    procedure actionToggleStoryPointExecute(Sender: TObject);
    procedure actionToggleCollectableExecute(Sender: TObject);
    procedure actionToggleSnappingExecute(Sender: TObject);
    procedure actionToggleAnchoredExecute(Sender: TObject);
    procedure actionChangeTagsExecute(Sender: TObject);
    procedure actionChangeUrlActionExecute(Sender: TObject);
    procedure actionChangeFactoryCapacityExecute(Sender: TObject);
    procedure actionLoadExecute(Sender: TObject);
    procedure actionSaveExecute(Sender: TObject);
    procedure txtIDKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

    //Note: not using a btnCloseClick handler, but using btnClose.ModalResult := mrClose so that it can also handle the ESC key to close the popup (before the app catches it)

  protected
    FStoryItem: IStoryItem;
    FPopup: TPopup;
    procedure CheckCreatePopup;

    {StoryItem}
    function GetStoryItem: IStoryItem;
    procedure SetStoryItem(const Value: IStoryItem); virtual;

    {View}
    function GetView: TControl;

  public
    destructor Destroy; override;

    procedure ShowPopup; //TODO: use PopupVisible boolean property instead
    procedure HidePopup;

    procedure ActChangeCollectableTarget;
    procedure ActChangeTags;
    procedure ActChangeUrlAction;
    procedure ActChangeFactoryCapacity;
    function ActAdd: Boolean;
    function ActLoad_GetFilename: String;
    function ActLoad: Boolean;
    function ActSave: Boolean;

    property Popup: TPopup read FPopup write FPopup stored false;

  published
    property View: TControl read GetView stored false;
    property StoryItem: IStoryItem read GetStoryItem write SetStoryItem stored false;
  end;

implementation
  uses
    FMX.DialogService.Async, //for TDialogServiceAsync
    READCOM.Models; //for EXT_READCOM

{$R *.fmx}

{TStoryItemOptions}

{$REGION 'LIFETIME MANAGEMENT'}

destructor TStoryItemOptions.Destroy;
begin
  if Assigned(FPopup) then
    FPopup.RemoveObject(Self); //must do before FreeAndNil(FPopup) else it fails when we call "inherited" below (the popup seems to kill us though it wasn't our owner, we were just its child/content)

  FreeAndNil(FPopup);

  inherited; //do last
end;

{$ENDREGION}

{$REGION 'PROPERTIES'}

{$region 'StoryItem'}

function TStoryItemOptions.GetStoryItem: IStoryItem;
begin
  result := FStoryItem;
end;

procedure TStoryItemOptions.SetStoryItem(const Value: IStoryItem);
begin
  FStoryItem := Value;

  with FStoryItem do
  begin
    btnToggleVisible.IsPressed := not Hidden;
    txtID.Text := ID;
    btnToggleHome.IsPressed := Home;
    btnToggleStoryPoint.IsPressed := StoryPoint;
    btnToggleCollectable.IsPressed := (CollectableTarget <> '');
    btnToggleSnapping.IsPressed := Snapping;
    btnToggleAnchored.IsPressed := Anchored;
    btnToggleTags.IsPressed := (Tags <> '');
    btnToggleUrlAction.IsPressed := (UrlAction <> '') or (UrlActionTarget <> '');
    btnToggleFactory.IsPressed := (FactoryCapacity <> 0);

    {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    btnLoad.Visible := false; //TODO: implement some simple Load file dialog for mobile devices (flat list of documents). Should have some button to delete files too
    btnSave.Visible := false; //TODO: implement a dialog to ask for a filename (and ask if want to replace if exists)
    {$ENDIF}
  end;
end;

{$endregion}

{$region 'View'}

function TStoryItemOptions.GetView: TControl;
begin
  result := Self;
end;

{$endregion}

{$ENDREGION PROPERTIES}

{$region 'Actions'}

//--- Visible (Hidden) ---

procedure TStoryItemOptions.actionToggleVisibleExecute(Sender: TObject);
begin
  StoryItem.Hidden := not btnToggleVisible.IsPressed;
  if StoryItem.Hidden and Assigned(FPopup) then
    HidePopup;
end;

//--- ID ---

procedure TStoryItemOptions.txtIDChange(Sender: TObject);
begin
  StoryItem.ID := txtID.Text;
end;

//--- Home ---

procedure TStoryItemOptions.actionToggleHomeExecute(Sender: TObject);
begin
  StoryItem.Home := btnToggleHome.IsPressed;
end;

//--- StoryPoint ---

procedure TStoryItemOptions.actionToggleStoryPointExecute(Sender: TObject);
begin
  StoryItem.StoryPoint := btnToggleStoryPoint.IsPressed;
end;

//--- CollectableTarget ---

procedure TStoryItemOptions.ActChangeCollectableTarget;
begin
  TDialogServiceAsync.InputQuery(STR_COLLECTABLE_TARGET, [STR_COLLECTABLE_TARGET], [StoryItem.GetCollectableTarget],
    procedure(const AResult: TModalResult; const AValues: array of string)
    begin
      if (AResult = mrOk) then
      begin
        var LCollectableTarget := Trim(AValues[0]);
        StoryItem.CollectableTarget := LCollectableTarget;
        btnToggleCollectable.IsPressed := (LCollectableTarget <> '');
      end;
    end
  );
end;

procedure TStoryItemOptions.actionToggleCollectableExecute(Sender: TObject);
begin
  ActChangeCollectableTarget;
end;

//--- Anchored (non Moveable) ---

procedure TStoryItemOptions.actionToggleAnchoredExecute(Sender: TObject);
begin
  StoryItem.Anchored := btnToggleAnchored.IsPressed;
end;

//--- Snapping (Magnet) ---

procedure TStoryItemOptions.actionToggleSnappingExecute(Sender: TObject);
begin
  StoryItem.Snapping := btnToggleSnapping.IsPressed;
end;

//--- Tags ---

procedure TStoryItemOptions.ActChangeTags;
begin
  TDialogServiceAsync.InputQuery(STR_TAGS, [STR_TAGS], [StoryItem.GetTags],
    procedure(const AResult: TModalResult; const AValues: array of string)
    begin
      if (AResult = mrOk) then
      begin
        var LTags := Trim(AValues[0]);
        StoryItem.Tags := LTags;
        btnToggleTags.IsPressed := (LTags <> '');
      end;
    end
  );
end;

procedure TStoryItemOptions.actionChangeTagsExecute(Sender: TObject);
begin
  actChangeTags;
end;

//--- UrlAction ---

procedure TStoryItemOptions.ActChangeUrlAction;
begin
  TDialogServiceAsync.InputQuery(STR_URL_ACTION, [STR_URL_ACTION], [StoryItem.GetUrlAction],
    procedure(const AResult: TModalResult; const AValues: array of string)
    begin
      if (AResult = mrOk) then
      begin
        var LUrlAction := Trim(AValues[0]);
        StoryItem.SetUrlAction(LUrlAction);

        TDialogServiceAsync.InputQuery(STR_URL_ACTION_TARGET, [STR_URL_ACTION_TARGET], [StoryItem.GetUrlActionTarget],
          procedure(const AResult: TModalResult; const AValues: array of string)
          begin
            if (AResult = mrOk) then
            begin
              var LUrlActionTarget := Trim(AValues[0]);
              StoryItem.SetUrlActionTarget(LUrlActionTarget);
              btnToggleUrlAction.IsPressed := (LUrlAction <> '') or (LUrlActionTarget <> ''); //a target with an empty action should mean to remove the target item
            end;
          end
        );

      end;
    end
  );
end;

procedure TStoryItemOptions.actionChangeUrlActionExecute(Sender: TObject);
begin
  actChangeUrlAction;
end;

//--- Factory Capacity ---

procedure TStoryItemOptions.ActChangeFactoryCapacity;
begin
  TDialogServiceAsync.InputQuery(STR_FACTORY_CAPACITY, [STR_FACTORY_CAPACITY], [StoryItem.GetFactoryCapacity.ToString],
    procedure(const AResult: TModalResult; const AValues: array of string)
    begin
      if (AResult = mrOk) then
      begin
        var LFactoryCapacity: Integer := 0;
        TryStrToInt(AValues[0], LFactoryCapacity); //ignoring any parsing error, will default to 0 (non-factory behaviour)
        StoryItem.SetFactoryCapacity(LFactoryCapacity);
        btnToggleFactory.IsPressed := (LFactoryCapacity <> 0);
      end;
    end
  );
end;

procedure TStoryItemOptions.actionChangeFactoryCapacityExecute(Sender: TObject);
begin
  actChangeFactoryCapacity;
end;

//--- Add FileDialog ---

function TStoryItemOptions.ActAdd: Boolean;
begin
  with AddDialog do
  begin
    DefaultExt := EXT_READCOM;
    Filter := StoryItem.GetAddFilesFilter;
    //Options := Options + [TOpenOption.ofAllowMultiSelect]; //Multi-selection (set in designer)
    result := Execute; //TODO: see if supported on Android (https://stackoverflow.com/questions/69138504/why-does-fmx-topendialog-not-work-in-android)
    if result then
      StoryItem.Add(Files.ToStringArray);
  end;
end;


//--- Load FileDialog ---

function TStoryItemOptions.ActLoad_GetFilename: String;
begin
  with OpenDialog do
  begin
    DefaultExt := EXT_READCOM;
    Filter := StoryItem.GetLoadFilesFilter;
    //Options := Options - [TOpenOption.ofAllowMultiSelect]; //Single-selection (set in designer)
    if Execute then //TODO: see if supported on Android and iOS, also see Kastri (https://stackoverflow.com/questions/69138504/why-does-fmx-topendialog-not-work-in-android)
      result := Filename
    else
      result := '';
  end;
end;

function TStoryItemOptions.ActLoad: Boolean;
begin
  var Filename := ActLoad_GetFilename;
  result := (Filename <> '');
  if result then
    result := Assigned(StoryItem.Load(Filename)); //TODO: seems to cause error (on MouseUp at Form) due to MouseCapture (probably from the popup) not having been released for some (child?) item that gets freed. Should try to get the Root (the form) and do SetCapture(nil) on it or similar, or try to get Capture to us here and release immediately (OR MAYBE THERE IS SOME OTHER ERROR AND WE SHOULD TRY TO REPLACE THE WHOLE ITEM VIA ITS PARENT INSTEAD OF LOADING CONTENT IN IT REMOVING ITS CHILDREN FIRST - THAT WAY WE'LL BE ABLE TO REPLACE AN ITEM WITH ANY OTHER ITEM)
end; //TODO: need to change ActLoad to load any file and replace the current one (if not the RootStoryItem should maybe resize to take current bounds), then return the StoryItem instance that was created from that file info (not assume it's same class of StoryItem, TPanelStoryItem in the case of the story [want to load any StoryItem as root - also make sure when RootStoryItem changes the old one is released to not leak]). Can pass true to 2nd optional parameter of load, but need to return the storyitem instead of boolean (can return nil on fail/cancel - also add try/catch maybe?)

procedure TStoryItemOptions.actionLoadExecute(Sender: TObject);
begin
  actLoad;
end;

//--- Save FileDialog ---

function TStoryItemOptions.ActSave: Boolean;
begin
  with SaveDialog do
  begin
    DefaultExt := EXT_READCOM;
    Filter := StoryItem.GetSaveFilesFilter;
    result := Execute; //TODO: need a file dialog for mobile (https://stackoverflow.com/questions/69138504/why-does-fmx-topendialog-not-work-in-android)
    if result then
      StoryItem.Save(Filename);
  end;
end;

procedure TStoryItemOptions.actionSaveExecute(Sender: TObject);
begin
  actSave;
end;

{$endregion}

{$region 'Popup'}

procedure TStoryItemOptions.CheckCreatePopup;
begin
  if not Assigned(FPopup) then
  begin
    var popup := TPopup.Create(Application.MainForm); //don't set StoryItem.View as owner, seems to always store it (irrespective of "Stored := false") //can't set Self as owner either, makes a circular reference
    var options := Self;
    with popup do
    begin
      Width := options.Width;
      Height := options.Height;
      options.Align := TAlignLayout.Client;
      AddObject(options);
      PlacementTarget := FStoryItem.View;
      Placement := TPlacement.Center; //show to center of form
      //DragWithParent := true; //don't use, will move with cursor (at Delphi 11)
      //PlacementTarget := (component as TControl);
      //PlacementRectangle:= TBounds.Create(RectF(0, 0, Width, Height));
    end;
    FPopup := popup;
  end;
end;

procedure TStoryItemOptions.ShowPopup;
begin
  CheckCreatePopup;

  if Assigned(FPopup) then
    begin
    //FPopup.IsOpen := true; //don't use - autocloses on popup click
    FPopup.Popup(true); //don't autoclose - this allows the popup to receive focus
    StoryItem := StoryItem; //cause re-init of toggle buttons //Note: Have to do it after opening the popup else SpeedButtons that had StaysPressed=true and Pressed=true don't appear pressed till one of them is clicked
    end;
end;

procedure TStoryItemOptions.HidePopup;
begin
  if Assigned(FPopup) then
  begin
    FPopup.IsOpen := false;
    //FreeAndNil(FPopup); //TODO: maybe should do to save resources
  end;
end;

procedure TStoryItemOptions.txtIDKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    HidePopup;
    Key := 0;
    KeyChar := #0;
  end;
end;

{$endregion}

end.
