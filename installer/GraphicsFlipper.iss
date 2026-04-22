[Setup]
AppName=Graphics Flipper
AppVersion=1.0.0
AppPublisher=aoroudjev
AppPublisherURL=https://github.com/aoroudjev/GraphicsFlipperExtension
AppSupportURL=https://github.com/aoroudjev/GraphicsFlipperExtension/issues
DefaultDirName={localappdata}\GraphicsFlipper
DisableDirPage=yes
DisableProgramGroupPage=yes
OutputDir=..\dist
OutputBaseFilename=GraphicsFlipper-Setup
Compression=lzma
SolidCompression=yes
; No UAC prompt — installs to LOCALAPPDATA and HKCU only
PrivilegesRequired=lowest
UninstallDisplayName=Graphics Flipper
UninstallDisplayIcon={app}\NativeHost.exe

[Files]
Source: "..\companion\NativeHost.exe"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
; Register native messaging host for Edge
Root: HKCU; Subkey: "Software\Microsoft\Edge\NativeMessagingHosts\com.gpuflip.toggle"; \
  ValueType: string; ValueName: ""; ValueData: "{app}\gpu_toggle.json"; Flags: uninsdeletekey

; Register native messaging host for Chrome
Root: HKCU; Subkey: "Software\Google\Chrome\NativeMessagingHosts\com.gpuflip.toggle"; \
  ValueType: string; ValueName: ""; ValueData: "{app}\gpu_toggle.json"; Flags: uninsdeletekey

[UninstallDelete]
Type: files; Name: "{app}\gpu_toggle.json"

[Code]
{ Generate gpu_toggle.json with the correct absolute path after install }
procedure CreateManifest();
var
  ExePath:      string;
  ManifestPath: string;
  JsonContent:  string;
  EscapedPath:  string;
begin
  ExePath      := ExpandConstant('{app}\NativeHost.exe');
  ManifestPath := ExpandConstant('{app}\gpu_toggle.json');

  EscapedPath  := ExePath;
  StringChangeEx(EscapedPath, '\', '\\', True);

  JsonContent :=
    '{' + #13#10 +
    '  "name": "com.gpuflip.toggle",' + #13#10 +
    '  "description": "GPU Acceleration Toggle - Native Messaging Host",' + #13#10 +
    '  "path": "' + EscapedPath + '",' + #13#10 +
    '  "type": "stdio",' + #13#10 +
    '  "allowed_origins": [' + #13#10 +
    '    "chrome-extension://nfloihcfmeeelbfgocljfndbngbjngie/",' + #13#10 +
    '    "chrome-extension://ghmnblflimkddhmfgjohhjkfiflfedmk/"' + #13#10 +
    '  ]' + #13#10 +
    '}';

  SaveStringToFile(ManifestPath, JsonContent, False);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    CreateManifest();
end;
