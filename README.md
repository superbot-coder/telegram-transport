# telegram-transport
Telegram Transport
Это unit TelegramTransport.pas В котором реализованы два метода для телеграмм бота SendTelegramMessage и DeleteTelegramMessage отправка сообщени и удаление сообщения
Идея в том чтобы эти методы реализовать в ввиде интерфейса (Interface)
Использовал: Delphi RAD 12.1

## Пример использования:
```pascal
  var UrlDelete := 'https://api.telegram.org/bot%s/deleteMessage';
  var UrlSemdMessage := 'https://api.telegram.org/bot%s/sendMessage';

  var ITelegaTransport := TTeleTransport.New
                          .BaseURL(UrlSemdMessage)
                          .Token('qweqwewerwerwe')
                          .ChatID(1233456)
                          .MessageText('Hello word');

  var MsgID := ITelegaTransport.SendTelegramMessage;

  Show('MessageID: ' + MsgID.ToString);
  show('Response: ' + ITelegaTransport.ResponseContent);
  show('StatusCode: ' + ITelegaTransport.StatusCode.ToString);
  show('ExceptionMessage: ' + ITelegaTransport.ExceptionMessage);
  show('------------------------------------------------------------');
  // Delete Telegram Message
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
```

