# Exsample telegram-transport 
Telegram Transport
##### [RU] Это unit TelegramTransport.pas в котором реализованы два метода для телеграмм бота **SendTelegramMessage** и **DeleteTelegramMessage** отправка сообщения и удаление сообщения. Идея в том чтобы эти методы реализовать в виде интерфейса (Interface)

##### [EN] Telegram Transport is a unit of TelegramTransport.pas, which implements two methods for telegram bots SendTelegramMessage and DeleteTelegramMessage sending a message and deleting a message. The idea is to implement these methods in the Interface view. 

Использовал / Using: Delphi RAD 12.1

## Пример использования:
```pascal
  var UrlDelete := 'https://api.telegram.org/bot%s/deleteMessage';
  var UrlSendMessage := 'https://api.telegram.org/bot%s/sendMessage';

  var ITelegaTransport := TTeleTransport.New
                          .BaseURL(UrlSendMessage)
                          .Token('qweqwewerwerwe')
                          .ChatID('1233456')
                          .MessageText('Hello word');

  var MsgID := ITelegaTransport.SendTelegramMessage;

  Show('MessageID: ' + MsgID.ToString);
  show('Response: ' + ITelegaTransport.ResponseContent);
  show('StatusCode: ' + ITelegaTransport.StatusCode.ToString);
  show('ExceptionMessage: ' + ITelegaTransport.ExceptionMessage);
  show('------------------------------------------------------------');
  
  // Удаление сообщения / Delete Telegram Message
  // Обратите внимание, что Token и ChatID уже добавлены
  // Please note that the Token and ChatId have already been added.
  
  if ITelegaTransport.BaseURL(UrlDelete)
                     .MessageID(MsgID)
                     .DeleteTelegramMessage 
  then
    Show('DeleteTe legram Message Result = true')
  else
    Show('DeleteTe legram Message Result = false');

  show('Response: ' + ITelegaTransport.ResponseContent);
  show('StatusCode: ' + ITelegaTransport.StatusCode.ToString);
  show('ExceptionMessage: ' + ITelegaTransport.ExceptionMessage);
  show('params: ' + ITelegaTransport.Params.Text);
  if Assigned(ITelegaTransport.JSONValue) then
    show('JSON: ' + ITelegaTransport.JSONValue.ToString);
```
##### Telegram channel: https://t.me/delphi_solutions
##### Telegram chat: https://t.me/delphi_solutions_chat
##### Telegram video: https://t.me/delphi_solutions_video
