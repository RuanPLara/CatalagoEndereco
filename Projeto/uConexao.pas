unit uConexao;

interface

uses
  System.SysUtils, System.Classes, Forms, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.Stan.Intf, FireDAC.Stan.Error, FireDAC.Stan.Pool, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI;

type
  TDatabaseConnection = class
  private
    FFDConnection: TFDConnection;
    class var FInstance: TDatabaseConnection;
    class procedure FreeInstance;
    constructor Create;
    destructor Destroy; override;
  public
    class function GetInstance: TDatabaseConnection;
    function GetFDConnection: TFDConnection;
  end;

implementation

{ TDatabaseConnection }

constructor TDatabaseConnection.Create;
begin
  inherited Create;
  FFDConnection := TFDConnection.Create(nil);
  try
    FFDConnection.DriverName := 'FB';
    FFDConnection.Params.DriverID := 'FB';
    FFDConnection.Params.Database := ExtractFilePath(Application.ExeName)+'catalago.fdb';
    FFDConnection.Params.UserName := 'SYSDBA';
    FFDConnection.Params.Password := 'masterkey';
    FFDConnection.LoginPrompt := False;
    FFDConnection.Connected := True;
  except
    on E: Exception do
    begin
      FFDConnection.Free;
      raise;
    end;
  end;
end;

destructor TDatabaseConnection.Destroy;
begin
  FFDConnection.Free;
  inherited Destroy;
end;

class function TDatabaseConnection.GetInstance: TDatabaseConnection;
begin
  if FInstance = nil then
    FInstance := TDatabaseConnection.Create;
  Result := FInstance;
end;

class procedure TDatabaseConnection.FreeInstance;
begin
  FreeAndNil(FInstance);
end;

function TDatabaseConnection.GetFDConnection: TFDConnection;
begin
  Result := FFDConnection;
end;

initialization
  TDatabaseConnection.FInstance := nil;

finalization
  TDatabaseConnection.FreeInstance;

end.

