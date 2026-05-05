# iBooks EPUB Converter

Клиентское Flutter Web-приложение для восстановления EPUB после Apple Books/iBooks.

Apple Books иногда отдаёт книгу как распакованный package-контейнер `.epub/`, а не как один ZIP-файл `.epub`. Такой контейнер не открывается во многих читалках. Приложение переупаковывает его обратно в валидный EPUB:

- `mimetype` первым файлом и без сжатия;
- остальные файлы внутри ZIP;
- всё выполняется локально в браузере, без загрузки на сервер.

## Web deploy

GitHub Actions собирает:

```bash
flutter build web --base-href /projects/epubconverter/
```

и выкладывает `build/web/` в:

```text
$TIMEWEB_REMOTE_PATH/projects/epubconverter/
```