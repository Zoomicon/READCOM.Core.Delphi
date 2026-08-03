# Dependencies

+ GetIt Packages (install via GetIt Package Manager, included in Delphi IDE):
    - SVGIconImageList (if not available on GetIt, download and install from https://github.com/EtheaDev/SVGIconImageList/releases)
    - Boss Experts (optional, available for Delphi 12 but not Delphi 13 yet)

+ Boss Packages (can install via command-line with Boss Package Manager update command [or place boss.exe in PATH and use Boss Experts from IDE] - configuration is in boss.json):
    - Zoomicon.Generics
    - Zoomicon.Helpers.RTL
    - Zoomicon.Helpers.FMX (also a design-time package)
    - Zoomicon.Introspection.FMX (also a design-time package)
    - Zoomicon.Manipulation.FMX (also a design-time package)
    - Zoomicon.Media.FMX (also a design-time package)
    - Zoomicon.ZUI.FMX (also a design-time package)
    - Object-Debugger-for-Firemonkey (autodownloaded as child dependency of Zoomicon.Introspection.FMX)

+ Boss IDE add-on (https://github.com/hashload/boss-ide)
  ...else need to open each design-time package, right-click and Install, from modules folder that "BOSS update" generates:

Notes:
- at Build/Compiler/Search path/All configurations - All platforms, using relative search paths to respective Boss cache folders (see App/modules folder)
- may need to open and right-click / install the BOSS packages that are for design-time too (see modules subfolder that boss creates) if BOSS doesn't install them as design packages

