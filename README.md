# StatusBar16Padding

Твик под **Dopamine (iOS 15.0 – 16.6.1, Rootless, arm64/arm64e)** для переноса эстетики статус-бара iPhone 15 / 16 Pro Max на iPhone с чёлкой (iPhone X / XS / 11 Pro / 12 / 13 / 14).

## Что делает
- Отодвигает время слева от острого угла экрана вправо (`leading offset`).
- Отодвигает блок батареи, Wi-Fi и сети справа от скругления влево (`trailing offset`).
- Выравнивает элементы по оптическому центру ушей дисплея (`vertical offset`), избавляя от эффекта налипания на углы.
- Применяется глобально: и в SpringBoard (экран блокировки / рабочий стол), и во всех приложениях (Telegram, Safari и т.д.).

## Автосборка через GitHub Actions
При каждом пуше в репозиторий автоматически запускается GitHub Actions runner на macOS, компилирует arm64/arm64e deb-пакет и прикрепляет его в артефакты сборки (**Actions** -> крайний запуск -> **StatusBar16Padding-rootless-deb**).

## Установка через Filza
1. Скачай собранный `.deb` из вкладки **Actions** (или Releases).
2. Открой файл в **Filza**.
3. Нажми на пакет -> **Установить** (Install).
4. Сделай **Respring** в приложении Dopamine.

## Ручная сборка (если есть Theos)
```bash
make clean
make package THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1
```
Готовый deb будет лежать в `./packages/`.
