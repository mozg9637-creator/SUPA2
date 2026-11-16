# SUNAPSEZERO — iOS 7 / iPhone 4

UIWebView-обёртка над чатом SUNAPSEZERO.  
**Unsigned IPA** — подпись не нужна, работает через AppSync Unified + Filza.

---

## Требования на iPhone 4

| Что | Где взять |
|---|---|
| Джейлбрейк iOS 7.x | [evasi0n7](http://evasi0n.com) (7.0–7.0.4) или [p0sixspwn](http://p0sixspwn.com) (7.0.x–7.1.2) |
| AppSync Unified | Cydia → добавь репо `https://cydia.akemi.ai` → ставь AppSync Unified |
| Filza File Manager | BigBoss repo в Cydia |

AppSync патчит `installd` — он пропускает IPA без подписи.

---

## Сборка через GitHub Actions

### 1. Залей проект в GitHub

```
git init
git add .
git commit -m "init"
git remote add origin https://github.com/ТВОЙ_НИК/sunapsezero-ios.git
git push -u origin main
```

### 2. Actions запустится автоматически

`Actions → Build IPA — AppSync/Filza → Artifacts → SUNAPSEZERO-armv7-unsigned`

Секреты **не нужны** — сборка без подписи.

### 3. Скачай IPA на iPhone

Вариант A — через Safari прямо с GitHub Actions  
Вариант B — по AirDrop / через компьютер в Filza

---

## Установка через Filza

1. Скачай `SUNAPSEZERO.ipa` на iPhone 4
2. Открой **Filza** → перейди в папку где лежит IPA
3. Зажми файл → выбери **Installer**
4. Подтверди установку

Если Installer не появляется — убедись что AppSync Unified установлен и активен.

---

## Смена URL приложения

В `SUNAPSEZERO/ViewController.m`:

```objc
static NSString * const kAppURL = @"https://tiny-moon-f4a4.eeop117.workers.dev";
```

Поменяй на свой адрес и запушь — Actions пересоберёт IPA.

---

## Как создать Release с IPA

```bash
git tag v1.0
git push origin v1.0
```

Actions автоматически создаст GitHub Release с прикреплённым IPA файлом.
