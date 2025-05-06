//Description: READ-COM Core Demo App
//Source: https://github.com/Zoomicon/READCOM.Core.Delphi
//Author: George Birbilis (https://zoomicon.com)

//Has dependencies set for debugging READCOM.Core (same BOSS package dependencies at boss.json as READCOM.Core and extra unit search paths pointing directly to READCOM.Core Source folder)
//For dependencies in custom apps see READCOM_App GitHub repository instead (they just need a boss.json that points to READCOME.Core.Delphi repository)

program READCOM.Core.Demo;

  {$R *.dres} //for Windows resources added via Resources and Images (includes 'Default.readcom' startup story document)

  {$region 'Used units'} //Note: D12.3 can't fold/expand regions in .dpr files
  uses
    System.StartUpCopy,
    READCOM.App.Main,
    READCOM.Core.Demo.Messages in 'READCOM.Core.Demo.Messages.pas',
    READCOM.Core.Demo.Views.Dialogs.About in 'Views\Dialogs\READCOM.Core.Demo.Views.Dialogs.About.pas' {AboutFrame: TFrame},
    Zoomicon.Media.FMX.ModalFrame in 'modules\zoomicon.media.fmx.delphi\Source\Zoomicon.Media.FMX.ModalFrame.pas' {ModalFrame: TFrame};
  {$endregion}

  {$R *.res} //for Windows App metadata defined via Project Options (App Icon, Versioning Info)

begin
  Main(TAboutFrame);
end.


