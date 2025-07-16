unit READCOM.Core.Registration;

interface

  procedure Register;

implementation
  {$region 'Used units'}
  uses
    //DesignIntf, //for ForceDemandLoadState
    System.Classes, //for RegisterComponents
    READCOM.Views.StoryItems.ImageStoryItem, //for TImageStoryItem
    READCOM.Views.StoryItems.AudioStoryItem, //for TAudioStoryItem
    READCOM.Views.StoryItems.TextStoryItem; //for TTextStoryItem
  {$endregion}

  procedure Register; //only called by IDE on installed package
  begin
    RegisterComponents('READCOM', [{TStoryItem, } TImageStoryItem, TAudioStoryItem, TTextStoryItem]); //Not registering TStoryItem on the IDE palette, only descendant classes

    //ForceDemandLoadState(dlDisable); //disable lazy-loading of package (this would need reference to DesignIntf though) //TODO: may be needed (or in Zoomicon.Manipulation package)
  end;

end.
