//Description: READ-COM App Models for Stories
//Author: George Birbilis (http://zoomicon.com)

unit READCOM.Models.Stories;

interface
  {$region 'Used units'}
  uses
    System.Classes, //for TStream
    System.Generics.Collections, //for TList
    System.UITypes, //for TAlphaColor
    System.SysUtils, //for TBytes
    //
    FMX.Clipboard, //for IFMXExtendedClipboardService
    FMX.Controls, //for TControl
    FMX.Graphics, //for TFont
    FMX.Objects, //for TImage
    FMX.Surfaces, //for TBitmapSurface
    FMX.Types, //for TTextAlign
    //
    Zoomicon.Generics.Collections, //for TListEx
    Zoomicon.Generics.Factories, //for IFactory, IFactoryRegistry
    Zoomicon.Media.FMX.Models, //for IMediaPlayer
    //
    READCOM.Models; //for IClipboardEnabled, IStoreable
  {$endregion}

  type

    //forward declarations
    IStoryItem = interface;
    IImageStoryItem = interface;
    IAudioStoryItem = interface;
    ITextStoryItem = interface;
    IStoryItemOptions = interface;

    TIStoryItemList = TListEx<IStoryItem>;
    TIImageStoryItemList = TListEx<IImageStoryItem>;
    TIAudioStoryItemList = TListEx<IAudioStoryItem>;
    TITextStoryItemList = TListEx<ITextStoryItem>;

    TStoryMode = (AnimatedStoryMode, InteractiveStoryMode, GuidedInteractiveStoryMode, EditMode);
    TTagsMatching = (TagsMatching_Default, TagsMatching_Skip, TagsMatching_Silent_Prompt, TagsMatching_Fail_Prompt, TagsMatching_OkFail_Prompt);

    {$region 'IStoryItemFactory'}

    IStoryItemFactory = IFactory<IStoryItem>;
    IStoryItemFactoryRegistry = IFactoryRegistry<String, IStoryItem>;

    {$endregion}

    {$region 'IStoryItem'}

    IStoryItem = interface(IStoreable)
      ['{238909DD-45E6-463A-9698-C7C6DC1A6DFE}']

      {$region '--- Methods ---'}

      {Lifetime management}
      procedure Reset;

      {ID}
      function GetID: String;
      procedure SetID(const Value: String);

      {Audio}
      function HasAudioStoryItems: boolean;
      procedure PlayRandomAudioStoryItem;

      {View}
      function GetView: TControl;

      {ParentStoryItem}
      function GetParentStoryItem: IStoryItem;
      procedure SetParentStoryItem(const Value: IStoryItem);

      {StoryItems}
      function GetStoryItems: TIStoryItemList;
      procedure SetStoryItems(const Value: TIStoryItemList);
      //
      function GetStoryItem(const Index: Integer): IStoryItem; overload;
      function GetStoryItem(const ID: String; const HomeOrStoryPoint: Boolean = false): IStoryItem; overload; //ID can be a path of IDs, / meaning Story.RootStoryItem, ~ meaning Story.HomeStoryItem, empty or . meaning current StoryItem and .. ParentStoryItem //if HomeOrStoryPoint=true behavior is that of GetStoryPoint(ID)

      {ImageStoryItems}
      function GetImageStoryItems: TIImageStoryItemList;

      {AudioStoryItems}
      function GetAudioStoryItems: TIAudioStoryItemList;

      {TextStoryItems}
      function GetTextStoryItems: TITextStoryItemList;

      {Active}
      function IsActive: Boolean;
      procedure SetActive(const Value: Boolean);
      procedure ActivateParentStoryItem;

      {EditMode}
      function IsEditMode: Boolean;
      procedure SetEditMode(const Value: Boolean);

      {ParentEditMode}
      function IsParentEditMode: Boolean;

      {BorderVisible}
      function IsBorderVisible: Boolean;
      procedure SetBorderVisible(const Value: Boolean);

      {Root}
      function IsRoot: Boolean;

      {Home}
      function IsHome: Boolean; //note: a Home StoryItem doesn't have to be StoryPoint, could be just the startup instructions that are shown once and not when looping through the StoryPoints
      procedure SetHome(const Value: Boolean);

      {StoryPoint}
      function IsStoryPoint: boolean;
      procedure SetStoryPoint(const Value: boolean);

      {CollectableTarget}
      function GetCollectableTarget: String;
      procedure SetCollectableTarget(const Value: String);
      function GetCollectableTargetStoryItem: IStoryItem;

      {StoryPoints}
      function GetStoryPoint(const ID: String): IStoryItem; //ID can be a path of IDs, / meaning Story.HomeStoryItem, ~ meaning Story.HomeStoryItem, empty or . meaning current StoryItem if it is a StoryPoint or Home (else AncestorStoryPoint) and .. meaning AncestorStoryPoint
      //
      function GetPreviousStoryPoint: IStoryItem;
      function GetNextStoryPoint: IStoryItem;
      //
      function GetAncestorStoryPoint: IStoryItem;
      function GetFirstChildStoryPoint: IStoryItem;
      function GetLastChildStoryPoint: IStoryItem;
      function GetPreviousSiblingStoryPoint: IStoryItem;
      function GetNextSiblingStoryPoint: IStoryItem;

      {Content}
      function GetContent: TBytes;
      procedure SetContent(const Value: TBytes);

      {ContentExt}
      function GetContentExt: String;
      procedure SetContentExt(const Value: String);

      {AllText}
      function GetAllText: TStrings;
      procedure SetAllText(const Value: TStrings);

      {ForegroundColor}
      function GetForegroundColor: TAlphaColor;
      procedure SetForegroundColor(const Value: TAlphaColor);

      {BackgroundColor}
      function GetBackgroundColor: TAlphaColor;
      procedure SetBackgroundColor(const Value: TAlphaColor);

      {FlippedHorizontally}
      function IsFlippedHorizontally: Boolean;
      procedure SetFlippedHorizontally(const Value: Boolean);

      {FlippedVertically}
      function IsFlippedVertically: Boolean;
      procedure SetFlippedVertically(const Value: Boolean);

      {Hidden}
      function IsHidden: Boolean;
      procedure SetHidden(const Value: Boolean);

      {Snapping}
      function IsSnapping: Boolean;
      procedure SetSnapping(const Value: Boolean);
      procedure DoSnapping;

      {Anchored}
      function IsAnchored: Boolean;
      procedure SetAnchored(const Value: Boolean);

      {Tags}
      function GetTags: String;
      procedure SetTags(const Value: String);
      function AreTagsMatched: Boolean;

      {UrlAction}
      function GetUrlAction: String;
      procedure SetUrlAction(const Value: String);

      {UrlActionTarget}
      function GetUrlActionTarget: String;
      procedure SetUrlActionTarget(const Value: String);

      {FactoryCapacity}
      function GetFactoryCapacity: Integer;
      procedure SetFactoryCapacity(const Value: Integer);

      {TargetsVisible}
      function GetTargetsVisible: Boolean;
      procedure SetTargetsVisible(const Value: Boolean);

      {Options}
      function GetOptions: IStoryItemOptions;

      {IStoreable extensions}
      procedure Add(const StoryItem: IStoryItem); overload;
      function LoadReadCom(const Stream: TStream; const CreateNew: Boolean = false): IStoryItem;
      function LoadReadComBin(const Stream: TStream; const CreateNew: Boolean = false): IStoryItem;
      procedure SaveReadCom(const Stream: TStream);
      procedure SaveReadComBin(const Stream: TStream);

      {$endregion}

      {$region '--- Properties ---'}

      property Hidden: Boolean read IsHidden write SetHidden; //default false
      property ID: String read GetID write SetID; //default ''
      property Active: Boolean read IsActive write SetActive; //default false
      property Home: Boolean read IsHome write SetHome; //default false
      property StoryPoint: Boolean read IsStoryPoint write SetStoryPoint; //default false
      property CollectableTarget: String read GetCollectableTarget write SetCollectableTarget; //default ''
      property Snapping: Boolean read IsSnapping write SetSnapping; //default false
      property Anchored: Boolean read IsAnchored write SetAnchored; //default true
      property Tags: String read GetTags write SetTags; //default ''
      property UrlAction: String read GetUrlAction write SetUrlAction; //default ''
      property UrlActionTarget: String read GetUrlActionTarget write SetUrlActionTarget; //default ''
      property FactoryCapacity: Integer read GetFactoryCapacity write SetFactoryCapacity; //default 0
      property Content: TBytes read GetContent write SetContent; //default nil
      property ContentExt: String read GetContentExt write SetContentExt; //default ''
      property Options: IStoryItemOptions read GetOptions; //stored false //TODO: currently to be as PUBLIC, NOT PUBLISHED
      //
      property FlippedHorizontally: Boolean read IsFlippedHorizontally write setFlippedHorizontally; //stored false //default false //Scale.X stores related info
      property FlippedVertically: Boolean read IsFlippedVertically write setFlippedVertically; //stored false //default false //Scale.Y stores related info
      property ForegroundColor: TAlphaColor read GetForegroundColor write SetForegroundColor; //default TAlphaColorRec.Null
      property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor; //default TAlphaColorRec.Null
      //
      property View: TControl read GetView;
      property EditMode: Boolean read IsEditMode write SetEditMode; //stored false //default false
      property ParentEditMode: Boolean read IsParentEditMode; //stored false
      property TargetsVisible: Boolean read GetTargetsVisible write SetTargetsVisible; //default false //TODO: Hint on Tags Matching?
      property BorderVisible: Boolean read IsBorderVisible write SetBorderVisible; //stored false default false
      //
      property ParentStoryItem: IStoryItem read GetParentStoryItem write SetParentStoryItem; //stored false //default nil
      property StoryItems: TIStoryItemList read GetStoryItems write SetStoryItems; //stored false
      property ImageStoryItems: TIImageStoryItemList read GetImageStoryItems; //stored false
      property AudioStoryItems: TIAudioStoryItemList read GetAudioStoryItems; //stored false
      property TextStoryItems: TITextStoryItemList read GetTextStoryItems; //stored false
      //
      property PreviousStoryPoint: IStoryItem read GetPreviousStoryPoint; //stored false
      property NextStoryPoint: IStoryItem read GetNextStoryPoint; //stored false
      property AncestorStoryPoint: IStoryItem read GetAncestorStoryPoint; //stored false
      //
      property CollectableTargetStoryItem: IStoryItem read GetCollectableTargetStoryItem; //stored false
      //
      property TagsMatched: Boolean read AreTagsMatched;
      property AllText: TStrings read GetAllText write SetAllText; //stored false //Note: used to replace Text at applicable items in StoryItem's whole subtree (to be used recursively)

      {$endregion}
    end;

    IStoryItemOptions = interface
      ['{1AEC7512-1E1D-4720-9D74-9A5411A64377}']

      {$region '--- Methods ---'}

      {View}
      function GetView: TControl;

      {StoryItem}
      function GetStoryItem: IStoryItem;
      procedure SetStoryItem(const Value: IStoryItem);

      {Popup}
      procedure ShowPopup;
      procedure HidePopup;

      {File}
      function ActAdd: Boolean;
      function ActLoad_GetFilename: String;
      function ActLoadUrl: Boolean;
      function ActLoad: Boolean;
      function ActSave: Boolean;

      {$endregion}

      {$region '--- Properties ---'}

      property View: TControl read GetView; //stored false
      property StoryItem: IStoryItem read GetStoryItem write SetStoryItem; //stored false

      {$endregion}
    end;

    {$endregion}

    {$region 'IImageStoryItem'}

    IImageStoryItem = interface(IStoryItem)
      ['{26111D6E-A587-4AB5-8CC9-84269C2719DC}']

      //--- Methods ---
      {Image}
      function GetImage: TImage;
      procedure SetImage(const Value: TImage); overload;
      procedure SetImage(const Value: TBitmap); overload;
      procedure SetImage(const Value: TBitmapSurface); overload;

      {SVGText}
      function GetSVGText: String;
      procedure SetSVGText(const Value: String);

      //--- Properties ---
      property Image: TImage read GetImage write SetImage; //stored StoreBitmap //default nil
      property SVGText: String read GetSVGText write SetSVGText; //stored FStoreSVG;
    end;

    IImageStoryItemOptions = interface(IStoryItemOptions)
      ['{DA637418-9648-48C7-A0CB-7475CAFECBAE}']

      {ImageStoryItem}
      function GetImageStoryItem: IImageStoryItem;
      procedure SetImageStoryItem(const Value: IImageStoryItem);

      //-- Properties --
      property ImageStoryItem: IImageStoryItem read GetImageStoryItem write SetImageStoryItem; //stored false
    end;

    {$endregion}

    {$region 'IAudioStoryItem'}

    IAudioStoryItem = interface(IStoryItem)
      ['{5C29ED8A-C6D1-47C2-A8F8-F41249C5846B}']

      //--- Methods ---
      procedure Play;

      {Muted}
      function IsMuted: Boolean;
      procedure SetMuted(const Value: Boolean);

      {AutoPlaying}
      function IsAutoPlaying: Boolean;
      procedure SetAutoPlaying(const Value: Boolean);

      {Looping}
      function IsLooping: Boolean;
      procedure SetLooping(const Value: Boolean);

      {PlayOnce}
      function IsPlayOnce: Boolean;
      procedure SetPlayOnce(const Value: Boolean);

      {Audio}
      function GetAudio: IMediaPlayer;
      procedure SetAudio(const Value: IMediaPlayer);

      //--- Properties ---
      property Muted: Boolean read IsMuted write SetMuted;
      property AutoPlay: Boolean read IsAutoPlaying write SetAutoPlaying;
      property PlayOnce: Boolean read IsPlayOnce write SetPlayOnce;
      property Audio: IMediaPlayer read GetAudio write SetAudio; //stored false
    end;

    {$endregion}

    {$region 'ITextStoryItem'}

    ITextStoryItem = interface(IStoryItem)
    ['{A05D85F0-F7F6-4EA1-8D4F-0C6FF7BEA572}']

    //--- Methods ---
    {Text}
    function GetText: String;
    procedure SetText(const Value: String);

    {SelectedText}
    function GetSelectedText: String;

    {Editable}
    function IsEditable: Boolean;
    procedure SetEditable(const Value: Boolean);

    {InputPrompt}
    function GetInputPrompt: String;
    procedure SetInputPrompt(const Value: String);

    {Font}
    function GetFont: TFont;
    procedure SetFont(const Value: TFont);

    {HorzAlign}
    function GetHorzAlign: TTextAlign;
    procedure SetHorzAlign(const Value: TTextAlign);

    //--- Properties ---
    property Text: String read GetText write SetText; //default ''
    property SelectedText: String read GetSelectedText; //stored false
    property Editable: Boolean read IsEditable write SetEditable; //default false
    property InputPrompt: String read GetInputPrompt write SetInputPrompt; //TODO: (maybe remove and just add filterchar String like in TEdit) //???
    property Font: TFont read GetFont write SetFont; //sets font size, font family (typeface), font style (bold, italic, underline, strikeout)
    property HorzAlign: TTextAlign read GetHorzAlign write SetHorzAlign; //default TTextAlign.Center
  end;

    ITextStoryItemOptions = interface(IStoryItemOptions)
      ['{EF0EF86E-7050-435F-81DC-4828A9FD8101}']

      {TextStoryItem}
      function GetTextStoryItem: ITextStoryItem;
      procedure SetTextStoryItem(const Value: ITextStoryItem);

      //-- Properties --
      property TextStoryItem: ITextStoryItem read GetTextStoryItem write SetTextStoryItem; //stored false
    end;

    {$endregion}

    {$region 'IStory'}

    IStory = interface
      ['{3A6CAD51-3787-4D18-9DA7-A07895BC4661}']

      {$region '--- Methods ---'}

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

      {Collectables}
      procedure Collect(const StoryItem: IStoryItem);

      {Tags}
      function CheckTagsMatched(const TagsMatching: TTagsMatching = TagsMatching_Default): Boolean;

      {URLs}
      procedure DoUrlAction(const UrlAction: String; const UrlTarget: String; const BaseStoryItem: IStoryItem = nil);

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
      procedure ActivateUrl(const Url: String; const UrlTarget: String; const BaseStoryItem: IStoryItem = nil; const TagsMatching: TTagsMatching = TagsMatching_Default); //open new story when ending in .readcom, else open url in browser

      {StoryMode}
      function GetStoryMode: TStoryMode;
      procedure SetStoryMode(const Value: TStoryMode);

      {$endregion}

      {$region '--- Properties ---'}

      property StoryMode: TStoryMode read GetStoryMode write SetStoryMode;
      //
      property RootStoryItem: IStoryItem read GetRootStoryItem write SetRootStoryItem;
      property HomeStoryItem: IStoryItem read GetHomeStoryItem write SetHomeStoryItem;
      property ActiveStoryItem: IStoryItem read GetActiveStoryItem write SetActiveStoryItem;
      //
      property FirstStoryPoint: IStoryItem read GetFirstStoryPoint;
      property PreviousStoryPoint: IStoryItem read GetPreviousStoryPoint;
      property NextStoryPoint: IStoryItem read GetNextStoryPoint;

      {$endregion}
    end;

    {$endregion}

    {$region 'IStoryEditor'}

    IStoryEditor = interface
    ['{DCBA41A5-0E65-421B-AA51-07EF149BBC78}']

      procedure NewRootStoryItem;
      procedure AddChildStoryItem(const TheStoryItemClass: TClass; const TheName: String);
      procedure DeleteActiveStoryItem;
      procedure CutActiveStoryItem;
      procedure CopyActiveStoryItem;
      procedure PasteInActiveStoryItem;
    end;

    {$endregion}

implementation

end.
