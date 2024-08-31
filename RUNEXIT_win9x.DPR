program Runexit;

{$D-,I-,L-,R-,S-,Y-}

uses
  Forms, ShellApi, SysUtils, WinProcs;

var
  pathName: String;
  fileName: String;
  cmdLine: String;
  i, num: Integer;
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;

begin
  { Split first parameter into path and filename }
  i := Pos ('\', ParamStr (1));
  if (i > 0) then
  begin
    { Make it a path, find last occurrence of directory separator }
    pathName := ParamStr (1);
    i := (StrRScan (@pathName [1], '\') - @pathName [1]) + 1;
    fileName := Copy (pathName, i + 1, Length (pathName) - i);
    pathName := Copy (pathName, 1, i - 1);
  end else begin
    fileName := ParamStr (1);
  end;

  { Concatenate any remaining parameters }
  cmdLine := ParamStr (1);
  num := ParamCount;
  for i := 2 to num do
  begin
    cmdLine := cmdLine + ' ';
    cmdLine := cmdLine + ParamStr (i);
  end;

  { Add trailing NUL bytes }
  fileName := fileName + #0;
  pathName := pathName + #0;
  cmdLine := cmdLine + #0;

  FillChar(tmpStartupInfo, SizeOf(tmpStartupInfo), 0);
  with tmpStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    // wShowWindow := SW_HIDE;
  end;
  FillChar(tmpProcessInformation, SizeOf(tmpProcessInformation), 0);

  if CreateProcess(nil, @cmdLine [1], nil, nil, false, 0,
    nil, @pathName [1], tmpStartupInfo, tmpProcessInformation) then
  begin
    // loop every 10 ms
    while WaitForSingleObject(tmpProcessInformation.hProcess, 10) > 0 do
    begin
      Application.ProcessMessages;
    end;
    CloseHandle(tmpProcessInformation.hProcess);
    CloseHandle(tmpProcessInformation.hThread);
  end;
    ShellExecute(0, 'open', 'RUNDLL', 'USER.EXE,ExitWindows', nil, 0);
end.
