//Description: App startup
//Author: George Birbilis (http://zoomicon.com)

unit READCOM.App.Main;

interface
  uses
    System.Classes, //for TNotifyEvent
    System.Math, //for Min
    //
    Zoomicon.Media.FMX.ModalFrame, //for TModalFrameClass
    READCOM.Views.StoryForm; //for TStoryForm, TStoryFormReadyEvent, TStoryLoadedEvent

  procedure Main(const TheAboutFrameClass: TModalFrameClass;
                 const OnStoryFormReady: TStoryFormReadyEvent = nil;
                 const OnStoryLoaded: TStoryLoadedEvent = nil);

  procedure ShowHelp;

  var
    StorySource: String;

    SaveThumbnail: Boolean; //=false
    ThumbnailMaxSize: Integer; //initialized at "ParseCommandLine"

    SaveHTML: Boolean; //=false
    HtmlImageMaxSize: Integer; //initialized at "ParseCommandLine"

implementation
  {$region 'Used units'}
  uses
    System.SysUtils, //for FreeAndNil
    //
    FMX.Dialogs, //for ShowMessage
    FMX.Forms, //for Application
    //
    Zoomicon.Helpers.FMX.Forms.ApplicationHelper, //for TApplication.ExeName, TApplication.OpenURL
    Zoomicon.Introspection.FMX.Debugging, //for CheckSafeMode
    //
    READCOM.Models, //for DEFAULT_THUMB_WIDTH, DEFAULT_THUMB_HEIGHT, DEFAULT_HTML_IMAGE_WIDTH, DEFAULT_HTML_IMAGE_HEIGHT
    READCOM.Views.StoryHUD, //for TStoryHUD.AboutFrameClass
    READCOM.Resources.Icons, //for TIcons
    READCOM.Resources.Themes, //for TThemes
    READCOM.App.Messages;
  {$endregion}

  {$region 'Command-line'}

  procedure ParseCommandLine; //TODO: use https://github.com/gabr42/GpDelphiUnits/blob/master/src/GpCommandLineParser.pas or https://github.com/VSoftTechnologies/VSoft.CommandLineParser instead to parse command-line
  const
    PARAM_THUMB = '-thumb';
    PARAM_HTML = '-html';
  begin
    if (ParamCount <> 0) then
    begin
      var param1 := ParamStr(1);

      if (ParamCount > 1) then
      begin

        if (param1.StartsWith(PARAM_THUMB)) then //optional -thumb switch: save screenshot (after having loaded any given story or last state or default document) and close again
        begin
          SaveThumbnail := true;

          //Bounding box for thumbnail fitting is a square, using default as min of max thumb width and height if not provided
          ThumbnailMaxSize := Min(DEFAULT_THUMB_WIDTH, DEFAULT_THUMB_HEIGHT);
          var LThumbEqLength := PARAM_THUMB.Length + 1;
          if param1.Length > LThumbEqLength then
            ThumbnailMaxSize := param1.Substring(LThumbEqLength).ToInteger;
        end

        else if (param1.StartsWith(PARAM_HTML)) then
        begin
          SaveHTML := true;
          HtmlImageMaxSize := Min(DEFAULT_HTML_IMAGE_WIDTH, DEFAULT_HTML_IMAGE_HEIGHT);
          var LHtmlEqLength := PARAM_HTML.Length + 1;
          if param1.Length > LHtmlEqLength then
            HtmlImageMaxSize := param1.Substring(HtmlImageMaxSize).ToInteger;
        end;

        StorySource := ParamStr(2);
      end
      else
        StorySource := ParamStr(1);
    end;
  end;

  {$endregion}

  var MainForm: TStoryForm; //WARNING: MUST DEFINE THE VARIABLE HERE, NOT INSIDE THE MAIN PROCEDURE

  procedure Main(const TheAboutFrameClass: TModalFrameClass;
                 const OnStoryFormReady: TStoryFormReadyEvent = nil;
                 const OnStoryLoaded: TStoryLoadedEvent = nil);
  begin
    TStoryHUD.AboutFrameClass := TheAboutFrameClass;

    CheckSafeMode; //must do before Application.Initialize //this also configures Graphics settings (e.g. when SHIFT key isn't held down at startup, replaces FMX rendering engine with Skia, disables Skia rasterizer, uses Metal on OS-X/iOS, uses Vulkan on Windows/Android)

    Randomize; //initializes the built-in random number generator with a random value (obtained from the system clock)

    //ApplicationHandleException := //...
    //ApplicationShowException := //...

    Application.Initialize; //FMX app template has this before creation of form(s) - probably the order plays some role

    TStoryForm.OnStoryFormReady := OnStoryFormReady; //called when main form is ready //TODO: do check that the form is equal to Application.MainForm or has flag to be MainForm (if there are issues on mobile platforms)
    TStory.OnStoryLoaded := OnStoryLoaded; //called (each time) after new root content has been set

    Icons := TIcons.Create(Application); //must create before StoryForm, it's a DataModule it uses - don't use Application.CreateForm since Delphi 12.3 sets the 1st one (even if it's a DataModule!) as MainForm internally
    Themes := TThemes.Create(Application); //must create before StoryForm, it's a DataModule it uses - don't use Application.CreateForm since Delphi 12.3 sets the 1st one (even if it's a DataModule!) as MainForm internally

    {var} MainForm{: TStoryForm} := nil; //WARNING: MUST NOT DEFINE THE VARIABLE INSIDE THE MAIN PROCEDURE, NEED TO DEFINE IT OUTSIDE, ELSE Delphi12.3 SHOWS BLANK SCREEN ON ANDROID AND MAY ALSO THROW EXCEPTION INTERNALLY AT SETVISIBLE(TRUE) WHEN IT CALLS CANSHOW
    //IMPORTANT: first call to Application.CreateForm defines the Application.MainForm, if DataModules above use it Delphi 12.3 internally sets 1st one as the Application.MainForm, causing various issues...
    Application.CreateForm(TStoryForm, MainForm); //note that CreateForm doesn't immediately create and assign the form object to the variable (depends on platform, may delay till Application.Run)
    //IMPORTANT: ...we couldn't just set Application.MainForm := MainForm here, since on some mobile platforms (e.g. Android) Application.CreateForm returns immediately and the instance of the form is created later on and assigned to the variable we passed a reference to

    //TODO: move from StoryForm the InitObjectDebugger call into a local event handler for StoryFormReady and do only if Sender is the Application.MainForm or if MainForm=nil. And always delegate to the event handler we were passed above as parameter

    try
      ParseCommandLine;
      Application.Run; //TODO: should nest in try/catch with raise and in case the error is related to DirectX not supported (need to check which exceptions are thrown, say DXCanvas or something not being possible to create), Show message that user can use SHIFT key on start, then terminate the app - SEE THOUGH IF MAIN FORM'S INITIAL METHODS THAT TRY TO LOAD DEFAULT STORY ETC. ARE THE ONE'S THAT CATCH AND SHOW THE ERROR AND MAKE SURE THERE IT'S RAISED AGAIN
    finally
      FreeObjectDebugger; //must free here and not in "finalization" section of READCOM.App.Debugging to not see leaks upon exiting
    end;
  end;

  procedure ShowHelp;
  begin
    Application.OpenURL(URL_HELP);
  end;

end.
