# Компилятор языка программирования Оберон

* Проект по созданию компилятора Оберона и написанию соответствующей книги
* Сайт проекта: [freeoberon.su](https://freeoberon.su)
* Репозиторий с книгой: [https://github.com/kekcleader/OberonBook] [читать PDF](https://github.com/kekcleader/OberonBook/blob/master/oberon.pdf)

Исходные файлы находятся в каталоге [Mod](Mod).

Желающим погрузиться в тему построения компиляторов рекомендуется ознакамливаться с исходным кодом данного проекта по нарастающей, начиная с самых первых коммитов (для более развёрнутого описания изменений см. файл [HISTORY](HISTORY)), а также с книгами Николая Вальтеровича Вирта, Сергея Залмановича Свердлова и других авторов на данную тему, с кодом компилятора в [Project Oberon](http://projectoberon.com), с сайтом [Free Oberon](https://freeoberon.su) (на этом сайте есть контактная информация).

Для того, чтобы скомпилировать компилятор, необходим компилятор VOC,
входящий в комплект [Free Oberon](https://freeoberon.su). Компилятор VOC
находится в подкаталоге `data/bin/voc/bin` (файл `voc` на Линуксе или
`voc.exe` на ОС Windows). Для Линукса также подойдёт
[оригинальный компилятор VOC](https://github.com/vishaps/voc).
Также можно использовать компиляторы
[Ofront](https://github.com/jtempl/ofront) и
[Ofront+](https://github.com/Oleg-N-Cher/OfrontPlus).

При смене компилятора, пожалуйста, отредактируйте файл [Makefile](Makefile)
(а именно, переменную `VOCPATH` наверху, и, возможно, другие).

В будущем компилятор будет компилировать себя сам.

Зайдите в каталог с исходным кодом компилятора (можно зайти как в `oberon`, так и в `oberon/Mod`) и выполните:
```
make
```

Затем запустите файл `Compiler`, или воспользуйтесь командой `make run` для теста.

Для компиляции также понадобятся пакеты `make` и `gcc`:
```
sudo apt-get install -y make gcc
```

![Oberon compiler screenshot](https://github.com/kekcleader/oberon/raw/master/etc/docs/schemes/03_Import.png)
