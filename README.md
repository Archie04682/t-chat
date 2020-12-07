# t-Chat 

[![Build Status](https://travis-ci.org/Archie04682/t-chat.svg?branch=feature%2Fhomework-13)](https://travis-ci.org/Archie04682/t-chat)

[Fastlane README](fastlane/README.md)

## Prerequisites

* Установить bundler

```sh
    gem install bundler
```

* Установить `libsodium` - библиотека необходима для оповещений в Discord

```sh
    brew install libsodium
```

* Положить файлы `Private.debug.xcconfig` и `Private.release.xcconfig` с ключами от Firebase и Pixabay в папки `t-chat/Configuration/Debug` и `t-chat/Configuration/Release` соответственно.

* Открыть терминал в папке с проектом и запустить

```sh
    bundle install
```

## 1. Сборка

Следующая команда установит зависимости и соберет проект

```sh
    bundle exec fastlane build_for_testing
```

## 2. Запуск тестов

**Замечание.** Запустить тесты через `fastlane` возможно только после выполения первого шага.

Чтобы запустить тесты в проекте, нужно открыть проект в консоли и выполнить команду

```sh
    bundle exec fastlane run_application_tests
```

## 3. Putting it all together

Проект можно собрать и протестировать одной командой, выполненной в консоли проекта

```sh
    bundle exec fastlane build_and_test
```

Для оповещений в Discord о результатах билда, перед вышеуказанной командой необходимо указать переменную `DISCORD_URL='<webhook>'`

```sh 
    DISCORD_URL='<webhook>' bundle exec fastlane build_and_test
```