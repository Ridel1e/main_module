# Diff Main Machine

### Описание

__Diff Main Machine__ - сервер, который работает на веб сокетах.

### Возможности:
- Подключение и регистрация модулей различных типов (подробнее о типа см. ниже)
- Обработка diff
- Хранение diff для повторного использования
- Хранение исходников библиотек

### Документация:

#### setModuleType

Перед началом работы каждый модуль должен зарегистрироваться. Для этого после откртия канала через web socket необходимо прислать серверу команду __setModuleType__ с типом подключенного модуля.

Возможные типы:
- __interface__ - интерфейс
- __documentation__ - модуль нахождения diff по документации
- __code__ - модуль нахождения diff по коду
- __fat model code__ - модуль, строящий model по коду
- __source migrate__ - модуль, для миграции с одной версии библиотеки на другую
- __diff machine__ - модуль, нахождения diff по fat model

Команда отправляется с помощью JSON.

Пример команды:

``` js
    {
     "cmd" : "setModuleType"
     "data" : "interface"
    }
```

После отправки клиенту придет сообщения вида:
``` js
    {
      status: "success"
      type: "setType"
      data: "now module type is interface"
    }
```
При успешном запросе
``` js
    {
      status: "error"
      message: "module type is undefined"
    }
```
После ошибки


#### getDirs
Получить все библиотеки, хранящиеся на сервере

Пример:

``` js
    {
      "cmd" : "getDirs"
    }
```

После отправки клиенту придет сообщения вида:
``` js
    {
      status: "success"
      type: "dirs"
      data: ['dirs', 'array']
    }
```
При успешном запросе
``` js
    {
      status: "error"
      message: "can't read libs dirs"
    }
```
После ошибки

#### getDir
 Получить директорию по указанному пути

 Пример:

 ``` js
    {
      "cmd" : "getDir"
      "data" : "path\to\dir"
    }
```

После отправки клиенту придет сообщения вида:
``` js
    {
      status: "success"
      type: "dir"
      data: ['dirs', 'and', 'files', 'array']
    }
```
При успешном запросе
``` js
    {
      status: "error"
      message: "can't read libs dir"
    }
```
После ошибки

#### getFile
 Получить файл по указанному пути

 Пример:

 ``` js
    {
      "cmd" : "getFile"
      "data" : "path\to\file"
    }
```

После отправки клиенту придет сообщения вида:
``` js
    {
      status: "success"
      type: "file"
      data: 'file content'
    }
```
При успешном запросе
``` js
    {
      status: "error"
      message: "can't read file"
    }
```
После ошибки

#### getDiffs
 Получить __diff__ для указанных файлов

 Пример:

 ``` js
    {
      "cmd" : "getDiff"
      "data" : {
        "libV1Path" : "path\to\file"
        "libV2Path" : "path\to\file"
      }
    }
```
После обработки и  отправки клиенту придет сообщения вида:
``` js
    {
      status: "success"
      type: "getDiffs"
      data: {[{
        your: "your"
        difs: "difs"
      },{
        your: "your"
        difs: "difs"
      }]}
    }
```
При успешном запросе

### Обрабатывающие модули
    Модуль должен начать обработку __diff__ после получения сообщения вида:

``` js
    {
      "type" : "request"
      "data" : {
        "key" : key
        "libV1PathDoc" : "path\to\lib1\doc"
        "libV2PathDoc" : "path\to\lib2\doc"
        "libV1PathSrc" : "path\to\lib1\src"
        "libV2PathSrc" : "path\to\lib2\src"
      }
    }
```
Для отправки обработанных __diff__ используются следующие команды:

#### pushDiff
 команда используется при отправлении на сервер списка найденных __diff__

 Пример:

 ``` js
    {
      "cmd" : "pushDiff"
      "data" : {
        "key" : key
        "diffList" : diffList
      }
    }
```
__diffList__ - список найденных __diff__, а __key__ - id запроса

#### pushModel
 команда используется при отправлении на сервер __xml__ модели кода

 Пример:

 ``` js
    {
      "cmd" : "pushModel"
      "data" : {
        "key": key
        "xmlModel": xmlModel
      }
    }
```
__xmlModel__ - __xml__ модель по коду, а __key__ - id запроса

