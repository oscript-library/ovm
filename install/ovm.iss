; Inno Setup script for OVM (OneScript Version Manager)
; Installs ovm.exe to %LOCALAPPDATA%\ovm and adds it to user PATH

#define MyAppName "OneScript Version Manager"
; MyAppVersion is passed from GitHub Actions via /D flag, extracting from packagedef
; Default value is used for local builds
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#define MyAppPublisher "oscript-library"
#define MyAppURL "https://github.com/oscript-library/ovm"
#define MyAppExeName "ovm.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
AppId={{8E5F4A2B-9C3D-4F1E-A6B8-2D7C9E4F1A3B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\ovm
DisableProgramGroupPage=yes
OutputDir=..\dist
OutputBaseFilename=ovm-setup
Compression=lzma
SolidCompression=yes
; Per-user installation (no admin rights required)
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=commandline
; Notify Windows about environment changes
ChangesEnvironment=yes
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
Source: "..\ovm.exe"; DestDir: "{app}"; Flags: ignoreversion

[Code]
const
  EnvironmentKey = 'Environment';

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
  ParamExpanded: string;
begin
  ParamExpanded := ExpandConstant(Param);
  if not RegQueryStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', OrigPath) then
  begin
    Result := True;
    exit;
  end;
  // Check if our path already exists in PATH (case insensitive)
  // Check without trailing backslash
  Result := Pos(';' + Uppercase(ParamExpanded) + ';', ';' + Uppercase(OrigPath) + ';') = 0;
  // Also check with trailing backslash variant
  if Result = True then
     Result := Pos(';' + Uppercase(ParamExpanded) + '\' + ';', ';' + Uppercase(OrigPath) + ';') = 0; 
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  OrigPath: string;
  NewPath: string;
  AppPath: string;
begin
  if CurStep = ssPostInstall then
  begin
    AppPath := ExpandConstant('{app}');
    if NeedsAddPath(AppPath) then
    begin
      if RegQueryStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', OrigPath) then
      begin
        // Add semicolon separator if PATH doesn't already end with one
        if (Length(OrigPath) > 0) and (OrigPath[Length(OrigPath)] = ';') then
          NewPath := OrigPath + AppPath
        else
          NewPath := OrigPath + ';' + AppPath;
        
        if RegWriteStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', NewPath) then
          Log('Added to PATH: ' + AppPath)
        else
          Log('Failed to add to PATH');
      end
      else
      begin
        // PATH doesn't exist, create it
        if RegWriteStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', AppPath) then
          Log('Created PATH with: ' + AppPath)
        else
          Log('Failed to create PATH');
      end;
    end
    else
      Log('Path already in PATH, skipping');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  OrigPath: string;
  NewPath: string;
  AppPath: string;
  PathList: TStringList;
  PathItem: string;
  i: Integer;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    AppPath := ExpandConstant('{app}');
    if RegQueryStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', OrigPath) then
    begin
      PathList := TStringList.Create;
      try
        PathList.Delimiter := ';';
        PathList.StrictDelimiter := True;
        PathList.DelimitedText := OrigPath;
        
        // Remove our path from the list (both with and without trailing backslash)
        // Also remove empty entries to avoid ";;" in PATH
        for i := PathList.Count - 1 downto 0 do
        begin
          PathItem := PathList[i];
          
          // Remove empty entries
          if Trim(PathItem) = '' then
          begin
            PathList.Delete(i);
            Continue;
          end;
          
          // Normalize by removing trailing backslash for comparison
          if PathItem[Length(PathItem)] = '\' then
            PathItem := Copy(PathItem, 1, Length(PathItem) - 1);
            
          if Uppercase(PathItem) = Uppercase(AppPath) then
          begin
            Log('Removed from PATH: ' + PathList[i]);
            PathList.Delete(i);
          end;
        end;
        
        NewPath := PathList.DelimitedText;
        RegWriteStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', NewPath);
      finally
        PathList.Free;
      end;
    end;
  end;
end;

