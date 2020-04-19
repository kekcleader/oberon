*English text below*

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

# Oberon Programming Language Compiler

* A project to create an Oberon compiler and write a book about it
* Project website: [freeoberon.su](https://freeoberon.su/en)
* Repository of the book: [https://github.com/kekcleader/OberonBook] [read PDF](https://github.com/kekcleader/OberonBook/blob/master/oberon.pdf)

The source files are in the [Mod](Mod) directory.

Those wishing to dive into the topic of building compilers are advised to familiarize themselves with the source code of this project on an increasing basis, starting with the very first commits (for a more detailed description of the changes, see the [HISTORY](HISTORY) file), as well as read books by Niklaus Wirth, S. Z. Sverdlov and other authors on this topic, as well as familiarize with the compiler code of the [Project Oberon](http://projectoberon.com) and with the [Free Oberon](https://freeoberon.su/en) website (see this website for the contact information).

In order to compile the compiler, you need the VOC compiler included with
[Free Oberon](https://freeoberon.su/en). The VOC compiler is located in the
`data/bin/voc/bin` (the file name on Linux is `voc`, and `voc.exe` on Windows).
For Linux, [the original VOC compiler](https://github.com/vishaps/voc) is also
suitable. You can also use
[Ofront](https://github.com/jtempl/ofront) and
[Ofront+](https://github.com/Oleg-N-Cher/OfrontPlus) compilers.

When changing the compiler for another one, please edit the [Makefile](Makefile)
(namely, the VOCPATH variable at the top, and possibly others).

In the future, the compiler will compile itself.

Go to the directory with the source code of the compiler (you can go into any of `oberon` or `oberon/Mod`) and run:
```
make
```

Then run the file `Compiler`, or type `make run` to test it.

You will also need `make` and `gcc` packages for compilation:
```
sudo apt-get install -y make gcc
```
