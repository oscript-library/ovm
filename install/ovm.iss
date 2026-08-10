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

// Удаляет завершающий обратный слеш из пути, если он есть
function NormalizePath(Path: string): string;
begin
  Result := Path;
  if (Length(Result) > 0) and (Result[Length(Result)] = '\') then
    Result := Copy(Result, 1, Length(Result) - 1);
end;

// Проверяет, существует ли путь в переменной PATH
// Учитывает варианты с завершающим слешем и без него
function PathExistsInEnv(Path: string): Boolean;
var
  EnvPath: string;
  NormalizedPath: string;
  SearchIn: string;
begin
  Result := False;
  
  // Нормализуем ВХОДНОЙ путь для единообразия
  NormalizedPath := NormalizePath(Path);
  
  // Получаем PATH из реестра (НЕ нормализуем — там могут быть пути с backslash)
  if not RegQueryStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', EnvPath) then
    exit;
  
  // Добавляем разделители по краям для корректного поиска подстроки
  SearchIn := ';' + Uppercase(EnvPath) + ';';
  
  // Ищем путь в EnvPath в двух вариантах:
  // 1. Без trailing backslash (C:\MyApp)
  // 2. С trailing backslash (C:\MyApp\) — на случай, если так записано в реестре
  if Pos(';' + Uppercase(NormalizedPath) + ';', SearchIn) > 0 then
    Result := True
  else if Pos(';' + Uppercase(NormalizedPath) + '\;', SearchIn) > 0 then
    Result := True;
end;

// Добавляет путь в переменную окружения PATH
// Возвращает True при успешном добавлении
function AddToPath(Path: string): Boolean;
var
  EnvPath: string;
  NewPath: string;
  NormalizedPath: string;
begin
  Result := False;
  NormalizedPath := NormalizePath(Path);
  
  // Проверяем, есть ли путь уже в PATH
  if PathExistsInEnv(NormalizedPath) then
  begin
    Log('Путь уже существует в PATH: ' + NormalizedPath);
    Result := True;
    exit;
  end;
  
  // Получаем текущее значение PATH
  if RegQueryStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', EnvPath) then
  begin
    // Добавляем разделитель, если PATH не заканчивается на него
    if Length(EnvPath) = 0 then
      NewPath := NormalizedPath
    else if EnvPath[Length(EnvPath)] = ';' then
      NewPath := EnvPath + NormalizedPath
    else
      NewPath := EnvPath + ';' + NormalizedPath;
  end
  else
  begin
    // PATH не существует, создаём новый
    NewPath := NormalizedPath;
  end;
  
  // Записываем обновлённый PATH в реестр
  if RegWriteStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', NewPath) then
  begin
    Log('Добавлено в PATH: ' + NormalizedPath);
    Result := True;
  end
  else
    Log('Ошибка при добавлении в PATH: ' + NormalizedPath);
end;

// Удаляет путь из переменной окружения PATH
// Использует TStringList для парсинга и ручную сборку строки для записи,
// чтобы избежать проблемы с кавычками вокруг путей с пробелами
function RemoveFromPath(Path: string): Boolean;
var
  EnvPath: string;
  NewPath: string;
  NormalizedPath: string;
  PathList: TStringList;
  PathItem: string;
  NormalizedItem: string;
  i: Integer;
  Removed: Boolean;
begin
  Result := False;
  Removed := False;
  NormalizedPath := NormalizePath(Path);
  
  // Получаем текущее значение PATH
  if not RegQueryStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', EnvPath) then
  begin
    Log('PATH не найден в реестре');
    exit;
  end;
  
  PathList := TStringList.Create;
  try
    // Разбираем PATH на элементы
    PathList.Delimiter := ';';
    PathList.StrictDelimiter := True;
    PathList.DelimitedText := EnvPath;
    
    // Удаляем наш путь и пустые элементы
    for i := PathList.Count - 1 downto 0 do
    begin
      PathItem := PathList[i];
      
      // Удаляем пустые элементы (защита от ";;" в PATH)
      if Trim(PathItem) = '' then
      begin
        PathList.Delete(i);
        Continue;
      end;
      
      // Нормализуем для сравнения (убираем завершающий слеш)
      NormalizedItem := NormalizePath(PathItem);
      
      // Сравниваем без учёта регистра
      if Uppercase(NormalizedItem) = Uppercase(NormalizedPath) then
      begin
        Log('Удалено из PATH: ' + PathItem);
        PathList.Delete(i);
        Removed := True;
      end;
    end;
    
    // Собираем строку вручную, чтобы избежать добавления кавычек
    // (TStringList.DelimitedText добавляет кавычки к путям с пробелами)
    NewPath := '';
    for i := 0 to PathList.Count - 1 do
    begin
      if i > 0 then
        NewPath := NewPath + ';';
      NewPath := NewPath + PathList[i];
    end;
    
    // Записываем обновлённый PATH в реестр
    if RegWriteStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', NewPath) then
    begin
      if Removed then
        Log('PATH успешно обновлён')
      else
        Log('Путь не найден в PATH: ' + NormalizedPath);
      Result := True;
    end
    else
      Log('Ошибка при обновлении PATH');
  finally
    PathList.Free;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  AppPath: string;
begin
  if CurStep = ssPostInstall then
  begin
    AppPath := ExpandConstant('{app}');
    AddToPath(AppPath);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  AppPath: string;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    AppPath := ExpandConstant('{app}');
    RemoveFromPath(AppPath);
  end;
end;

