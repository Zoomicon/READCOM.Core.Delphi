//Description: Global constants and variables
//Author: George Birbilis (http://zoomicon.com)

unit READCOM.App.Messages;

interface

//Localizable
resourcestring
  STR_COMPATIBILITY_MODE = '[Compatibility mode]';
  ERR_DOWNLOAD = 'Download failed (%s)';

//Replaceable by custom apps
var
  STR_APP_TITLE: String = 'READ-COM: Reading Communities';

  URL_HELP: String = 'https://github.com/Zoomicon/READCOM_App/wiki';
  URL_READCOM: String = 'https://www.read-com-eu.uma.es';

  SAVED_STATE_FILENAME: String = 'SavedState.readcom';
  BACKPACK_FILENAME: String= 'Backpack.readcom';

implementation

end.
