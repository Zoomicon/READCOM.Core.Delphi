unit READCOM.Core.Registration;

interface

  procedure Register;

implementation
  {$region 'Used units'}
  uses
    //DesignIntf, //for ForceDemandLoadState
    System.Classes, //for RegisterComponents
    //
    //READCOM.Views.StoryItems.StoryItem, //for TStoryItem
    READCOM.Views.StoryItems.ImageStoryItem, //for TImageStoryItem
    READCOM.Views.StoryItems.AudioStoryItem, //for TAudioStoryItem
    READCOM.Views.StoryItems.TextStoryItem, //for TTextStoryItem
    //
    READCOM.Views.Options.StoryItemOptions, //for TStoryItemOptions
    READCOM.Views.Options.ImageStoryItemOptions, //for TImageStoryItemOptions
    //READCOM.Views.Options.AudioStoryItemOptions, //for TAudioStoryItemOptions
    READCOM.Views.Options.TextStoryItemOptions; //for TTextStoryItemOptions
  {$endregion}

  procedure Register; //only called by IDE on installed package
  begin
    RegisterComponents('READCOM', [
      {TStoryItem, } //TImageStoryItem should be preferred, no need to expose base StoryItem to component palette
      TImageStoryItem,
      TAudioStoryItem,
      TTextStoryItem,
      //
      TStoryItemOptions, //the base options that are common for all StoryItems
      TImageStoryItemOptions,
      //TAudioStoryItemOptions,
      TTextStoryItemOptions
    ]); //Not registering TStoryItem on the IDE palette, only descendant classes

    //ForceDemandLoadState(dlDisable); //disable lazy-loading of package (this would need reference to DesignIntf though) //TODO: may be needed (or in Zoomicon.Manipulation package)
  end;

end.
