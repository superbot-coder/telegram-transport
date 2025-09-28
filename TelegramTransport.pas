unit TelegramTransport;

interface

USES
   System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient;

type
   ITelegramTransport = Interface
    ['{AC484B5E-67DE-4827-9FA2-5A685739A71C}']
    function BaseURL(const URL: String): ITelegramTransport;
    function ChatID(AChatID: Int64): ITelegramTransport;
    function DeleteTelegramMessage: Boolean;
    function GetExceptionMessage: string;
    function GetMessageId: int64;
    function GetParam: TStringList;
    function JSONValue(const AEncoding: TEncoding): TJSONValue; overload;
    function JSONValue: TJSONValue; overload;
    function MessageID(MessageID: Int64): ITelegramTransport;
    function MessageText(const  AMessage: string): ITelegramTransport;
    function ResponseContent: string;
    function SendTelegramMessage: Int64;
    function StatusCode: Integer;
    function Token(const AToken: string): ITelegramTransport;
    procedure SetMessageID(AMessageID: Int64);
    property ExceptionMessage: string read GetExceptionMessage;
    property Params: TStringList read GetParam;
  end;

  TTelegramTransport = class(TInterfacedObject, ITelegramTransport)
  private
    FHTTPClient: THTTPClient;
    FHTTPResponse: IHTTPResponse;
    FURL: string;
    FToken: String;
    FChatID: Int64;
    FParams: TStringList;
    FMessageID: Int64;
    FMessage: String;
    FLastResult: Boolean;
    FRespString: String;
    FStatusCode: integer;
    FExceptionMessage: string;
    FJSONValue: TJSONValue;
    function GetMessageId: int64;
    procedure SetMessageID(AMessageID: Int64);
    function GetMessageValue<T>(const ValueName: string; JSV: TJSONValue): T;
    function GetParam: TStringList;
    function GetExceptionMessage: string;
    function BaseURL(const URL: String): ITelegramTransport;
    function Token(const AToken: string): ITelegramTransport;
    function ChatID(ChatID: Int64): ITelegramTransport;
    function MessageID(MessageID: Int64): ITelegramTransport;
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

{ TTelegramTranport }

function TTelegramTransport.BaseURL(const URL: String): ITelegramTransport;
begin
  Result := self;
  FURL := URL;
end;

function TTelegramTransport.ChatID(ChatID: Int64): ITelegramTransport;
begin
  Result := Self;
  FChatID := ChatID;
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

  // Параметры запроса
  FParams.Clear;
  FParams.AddPair('chat_id', FChatID.ToString);
  FParams.AddPair('message_id', FMessageID.ToString);

  // Отправка запроса
  try
    FreeAndNil(FJSONValue);
    FHTTPResponse := FHTTPClient.Post(LURL, FParams);
    // Обработка ответа

    if FHTTPResponse.StatusCode = 200 then
    begin
      var JSONResponse := Self.JSONValue;
      GetMessageValue<Boolean>('ok', JSONResponse);
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
  if Assigned(FJSONValue) then FJSONValue.Free;
  inherited;
end;

function TTelegramTransport.GetExceptionMessage: string;
begin
  Result := FExceptionMessage;
end;

function TTelegramTransport.GetMessageId: int64;
begin
  Result := FMessageID;
end;

function TTelegramTransport.GetMessageValue<T>(const ValueName: string; JSV: TJSONValue): T;
begin
  if JSV is TJSONObject then
    TJSONObject(JSV).TryGetValue<T>(ValueName, Result);
end;

function TTelegramTransport.GetParam: TStringList;
begin
  Result := FParams;
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
    if Assigned(FHTTPResponse) then
      LContent := FHTTPResponse.ContentAsString.Trim;
    if LContent.StartsWith('{') then
      FJSONValue := (TJSONObject.ParseJSONValue(AEncoding.GetBytes(LContent), 0) as TJSONObject)
    else if LContent.StartsWith('[') then
      FJSONValue := (TJSONObject.ParseJSONValue(AEncoding.GetBytes(LContent), 0) as TJSONArray)
    else
      raise Exception.Create('The return content is not a valid JSON value.');
  end;
  Result := FJSONValue;
end;

function TTelegramTransport.JSONValue: TJSONValue;
begin
  Result := Self.JSONValue(TEncoding.UTF8);
end;

function TTelegramTransport.MessageID(MessageID: Int64): ITelegramTransport;
begin
  Result := Self;
  FMessageID := MessageID;
end;

function TTelegramTransport.MessageText(
  const AMessage: string): ITelegramTransport;
begin
  Result := Self;
  FMessage := AMessage;
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
  FParams.Clear;
  FParams.AddPair('chat_id', FChatID.ToString);
  FParams.AddPair('text', FMessage);
  // Можно добавить parse_mode для форматирования:
  FParams.AddPair('parse_mode', 'MarkdownV2');

  // Отправляем POST-запрос
  try
    FreeAndNil(FJSONValue);
    FHTTPResponse := FHTTPClient.Post(LURL, FParams);
    var JSONResponse := self.JSONValue;

    if GetMessageValue<Boolean>('ok', JSONResponse) then
    begin
      var MessageObj := GetMessageValue<TJSONValue>('result', JSONResponse);
      FMessageID := GetMessageValue<Int64>('message_id', MessageObj);
      Result := FMessageID;
    end;

  except
    on E: Exception do
      FExceptionMessage := E.Message;
  end;

end;

procedure TTelegramTransport.SetMessageID(AMessageID: Int64);
begin
  FMessageID := AMessageID;
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
