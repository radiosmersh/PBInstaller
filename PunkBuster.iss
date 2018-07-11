[Setup]
AppVerName=PunkBuster for Battlefield 1942                   
AppName=PunkBuster for Battlefield 1942
AppVersion=0.994
DefaultDirName={code:GetPath}
DefaultGroupName=PunkBuster for Battlefield 1942
AppendDefaultDirName=no
AllowNoIcons=yes
SetupIconFile=res\pb.ico
DisableReadyPage=yes
PrivilegesRequired=admin
DirExistsWarning=No
Compression=lzma2/max 
OutputBaseFilename=pbsetup
Uninstallable=no

[Files]
Source: "files\*.dll"; DestDir: "{app}"; Flags: ignoreversion; MinVersion: 6.1; Check: not UnderWine;
Source: "files\pb\*.*"; DestDir: "{app}\pb"; Flags: ignoreversion recursesubdirs
Source: "files\pbsvc.exe"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "files\PBClient.con"; DestDir: "{tmp}"; Flags: ignoreversion

[Languages]
Name: "en"; MessagesFile: "res\Default.isl"

[CustomMessages]
SetupTask=Setup - %1

[Run]
Filename: "{tmp}\pbsvc.exe"; Parameters: /i --no-prompts --no-errors-pba --i-accept-the-pb-eula; Description: "{cm:SetupTask,PunkPuster}"; StatusMsg: "{cm:SetupTask, PunkPuster}"; Flags: runascurrentuser

[UninstallDelete]
Type: filesandordirs; Name: "{app}\pb"

[UninstallRun]
Filename: "{syswow64}\pbsvc.exe"; Parameters: "-u"; Check: isWin64; Flags: runascurrentuser
Filename: "{sys}\pbsvc.exe"; Parameters: "-u"; Check: not isWin64; Flags: runascurrentuser

[Code]
function GetPath(Param: String): String;
var temp: String;
begin
    if RegQueryStringValue(HKLM32, 'Software\EA GAMES\Battlefield 1942', 'GAMEDIR', temp) then
    Result := temp
      else RegQueryStringValue(HKLM32, 'Software\Origin\Battlefield 1942', 'GAMEDIR', Result);
end;

procedure ListFolders(const Directory: string; Files: TStringList);
var
  FindRec: TFindRec;
begin
  if FindFirst(ExpandConstant(Directory + '*'), FindRec) then
  try
    repeat
      if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0 then
        case FindRec.Name of
          '.', '..', 'Default' : ;
        else
          Files.Add(FindRec.Name);
        end;
    until
      not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
	Folders: TStringList;
	i: Integer;
  WorkDir: String;
begin
	if CurStep = ssPostInstall then
	begin
		WorkDir := ExpandConstant('{app}') + '\Mods\bf1942\Settings\Profiles\';
    Folders := TStringList.Create;
		ListFolders(WorkDir, Folders);
		Log('Installing files');
		for i := 0 to Folders.Count - 1 do
		begin
			if FileCopy(ExpandConstant('{tmp}\PBClient.con'), WorkDir + Folders[i] + '\PBClient.con', False) then
				begin
					Log('File ' + ExpandConstant('{tmp}\PBClient.con') + ' installed into ' + WorkDir + Folders[i]);
				end
			else
				begin
					Log('Failed to install file ' + ExpandConstant('{tmp}\PBClient.con') + ' into ' + WorkDir + Folders[i]);
				end;
		end;
    Folders.Free;
	end;
end;


function UnderWine:Boolean;
    begin
       if RegKeyExists(HKEY_LOCAL_MACHINE, 'Software\Wine\Wine\Config') then
        Result := True
       else
        Result := False;
    end;
