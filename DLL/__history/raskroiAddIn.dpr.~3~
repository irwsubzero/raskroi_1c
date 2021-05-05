library RaskroiAddIn;

uses
  ComServ,
  Windows,
  AddInLib in 'AddInLib.pas',
  AddInObj in 'AddInObj.pas',
  u_main in 'u_main.pas' {frm_main},
  uClasses in 'uClasses.pas';

{$E dll}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;    //http://mirsovetov.net/show-memory-leek.html

end.
