unit TelegramTransport;

interface

USES
   System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient;

type
   ITelegramTransport = Interface
    ['{AC484B5E-67DE-4827-9FA2-5A685739A71C}']
    function BaseURL(const URL: String): ITelegramTransport;
    function ChatID(AChatID: Int64): ITelegramTransport; overload;
    function ChatID(AChatID: string): ITelegramTransport; overload;
    function DeleteTelegramMessage: Boolean;
    function GetMessageId: int64;
    function JSONValue(const AEncoding: TEncoding): TJSONValue; overload;
    function JSONValue: TJSONValue; overload;
    function MessageID(AMessageID: Int64): ITelegramTransport; overload;
    function MessageID(AMessageID: String): ITelegramTransport; overload;
    function MessageText(const AMessage: string): ITelegramTransport;
    function ResponseContent: string;
    function SendTelegramMessage: Int64;
    function StatusCode: Integer;
    function Token(const AToken: string): ITelegramTransport;
    function ExceptionMessage: string;
    function Params: TStringList;
    function AddParam(const AName, AValue: string): ITelegramTransport;
    procedure DeleteParam(const ParamName: string);
  end;

  TTelegramTransport = class(TInterfacedObject, ITelegramTransport)
  private
    FHTTPClient: THTTPClient;
    FHTTPResponse: IHTTPResponse;
    FURL: string;
    FToken: String;
    //FChatID: String;
    //FMessageID: String;
    FParams: TStringList;
    //FMessage: String;
    FLastResult: Boolean;
    FRespString: String;
    FStatusCode: integer;
    FExceptionMessage: string;
    FJSONValue: TJSONValue;
    function AddParam(const AName, AValue: string): ITelegramTransport;
    function GetMessageID: int64;
    function GetJSONValue<T>(const ValueName: string; JSV: TJSONValue): T;
    function Params: TStringList;
    procedure DeleteParam(const ParamName: string);
    function ExceptionMessage: string;
    function BaseURL(const URL: String): ITelegramTransport;
    function Token(const AToken: string): ITelegramTransport;
    function ChatID(AChatID: Int64): ITelegramTransport; overload;
    function ChatID(AChatID: string): ITelegramTransport; overload;
    function MessageID(AMessageID: Int64): ITelegramTransport; overload;
    function MessageID(AMessageID: String): ITelegramTransport; overload;
    function MessageText(const  AMessage: string): ITelegramTransport;
    function DeleteTelegramMessage: Boolean;
    function SendTelegramMessage: int64;
    function JSONValue: TJSONValue; overload;
    function JSONValue(const AEncoding: TEncoding): TJSONValue; overload;
    function StatusCode: Integer;
    function ResponseContent: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: ITelegramTransport;
  end;

  TTeleTransport = class
    class function New: ITelegramTransport;
  end;

implementation

function TTelegramTransport.AddParam(const AName,
  AValue: string): ITelegramTransport;
begin
  Result := self;
  if (AName.Trim.IsEmpty) or (AValue.Trim.IsEmpty) then
    Exit;
  var pos := FParams.IndexOf(AName);
  if pos = -1 then
    FParams.AddPair(AName.Trim, AValue)
  else
  begin
    FParams.Delete(pos);
    FParams.AddPair(AName.Trim, AValue);
  end;
end;

{ TTelegramTranport }

function TTelegramTransport.BaseURL(const URL: String): ITelegramTransport;
begin
  Result := self;
  FURL := URL;
end;

function TTelegramTransport.ChatID(AChatID: Int64): ITelegramTransport;
begin
  Result := Self;
  AddParam('chat_id', AChatID.ToString);
end;

function TTelegramTransport.ChatID(AChatID: string): ITelegramTransport;
begin
  Result := Self;
  AddParam('chat_id', AChatID);
end;

constructor TTelegramTransport.Create;
begin
  inherited Create;
  FJSONValue := Nil;
  FParams := TStringList.Create;
  FHTTPClient := THTTPClient.Create;
  FHTTPClient.ResponseTimeout := 2000;
end;

function TTelegramTransport.DeleteTelegramMessage: Boolean;
begin
  Result := false;
  var LURL := Format(FURL, [FToken]);

 // Отправка запроса
  try
    FreeAndNil(FJSONValue);
    FHTTPResponse := FHTTPClient.Post(LURL, FParams);

    // Обработка ответа
    if FHTTPResponse.StatusCode = 200 then
    begin
      var JSONValueResp := JSONValue;
      Result := GetJSONValue<Boolean>('ok', JSONValue);
    end;
  except
    on E: Exception do
      FExceptionMessage := E.Message;
  end;

end;

destructor TTelegramTransport.Destroy;
begin
  FHTTPClient.Free;
  FParams.Free;
  if Assigned(FJSONValue) then
    FJSONValue.Free;
  inherited;
end;

function TTelegramTransport.ExceptionMessage: string;
begin
  Result := FExceptionMessage;
end;

function TTelegramTransport.GetMessageId: int64;
begin
  Result := 0;
  var JSONValueResp := JSONValue;
  if Not Assigned(JSONValueResp) then
    Exit;

  if GetJSONValue<Boolean>('ok', JSONValueResp) then
  begin
    var MsgObj := GetJSONValue<TJSONValue>('result', JSONValueResp);
    Result := GetJSONValue<Int64>('message_id', MsgObj);
  end;
end;

function TTelegramTransport.GetJSONValue<T>(const ValueName: string; JSV: TJSONValue): T;
begin
  if JSV is TJSONObject then
    TJSONObject(JSV).TryGetValue<T>(ValueName, Result);
end;

function TTelegramTransport.Params: TStringList;
begin
  Result := FParams;
end;

procedure TTelegramTransport.DeleteParam(const ParamName: string);
begin
  var x := FParams.IndexOf(ParamName.Trim);
  if x <> -1 then
    FParams.Delete(x);
end;

function TTelegramTransport.StatusCode: integer;
begin
  Result := FHTTPResponse.StatusCode;
end;

function TTelegramTransport.JSONValue(const AEncoding: TEncoding): TJSONValue;
var
  LContent: string;
begin
  if (not Assigned(FJSONValue)) and Assigned(FHTTPResponse) then
  begin
    LContent := FHTTPResponse.ContentAsString.Trim;
    var JSV :=  TJSONObject.ParseJSONValue(AEncoding.GetBytes(LContent), 0);
    if Assigned(JSV) then
      if JSV is TJSONObject then
        FJSONValue := JSV as TJSONObject
      else
      begin
        JSV.Free;
        raise Exception.Create('The return content is not a valid TJSONObject value.');
      end
	else
      raise Exception.Create('The return content is not a valid JSON value.');  
  end;
  Result := FJSONValue;
end;

function TTelegramTransport.JSONValue: TJSONValue;
begin
  Result := Self.JSONValue(TEncoding.UTF8);
end;

function TTelegramTransport.MessageID(AMessageID: Int64): ITelegramTransport;
begin
  Result := Self;
  AddParam('message_id', AMessageID.ToString);
end;

function TTelegramTransport.MessageID(AMessageID: String): ITelegramTransport;
begin
  Result := Self;
  AddParam('message_id', AMessageID);
end;

function TTelegramTransport.MessageText(
  const AMessage: string): ITelegramTransport;
begin
  Result := Self;
  AddParam('text', AMessage);
end;

class function TTelegramTransport.New: ITelegramTransport;
begin
  Result := TTelegramTransport.Create;
end;

function TTelegramTransport.ResponseContent: string;
begin
  if Assigned(FHTTPResponse) then
    Result := FHTTPResponse.ContentAsString()
end;

function TTelegramTransport.SendTelegramMessage: Int64;
begin
  Result := 0;

  // Формируем URL запроса
  var LURL := Format(FURL, [FToken]);

  // Добавляем параметры запроса
  // Можно добавить parse_mode для форматирования:
  // Но не нужно
  // FParams.AddPair('parse_mode', 'MarkdownV2');

  // Отправляем POST-запрос
  try
    FreeAndNil(FJSONValue);
    FHTTPResponse := FHTTPClient.Post(LURL, FParams);

    if FHTTPResponse.StatusCode = 200 then
    begin
      Result := GetMessageID;
      DeleteParam('text');
    end;

  except
    on E: Exception do
      FExceptionMessage := E.Message;
  end;

end;

function TTelegramTransport.Token(const AToken: string): ITelegramTransport;
begin
  Result := Self;
  FToken := AToken;
end;

{ TTeleTransport }

class function TTeleTransport.New: ITelegramTransport;
begin
  Result := TTelegramTransport.New;
end;

end.
