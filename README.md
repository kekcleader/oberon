# Компилятор языка программирования Оберон

* Проект по созданию компилятора Оберона и написанию соответствующей книги
* Сайт проекта: [freeoberon.su](https://freeoberon.su)
* Репозиторий с книгой: [https://github.com/kekcleader/OberonBook] [читать PDF](https://github.com/kekcleader/OberonBook/blob/master/oberon.pdf)

С данным исходным кодом рекомендуется ознакамливаться по нарастающей,
начиная с первых коммитов.

Для того, чтобы скомпилировать компилятор, необходим компилятор VOC,
входящий в комплект [Free Oberon](https://freeoberon.su). Компилятор VOC
находится в подкаталоге `data/bin/voc/bin` (файл `voc` на Линуксе или
`voc.exe` на ОС Windows). Для Линукса также подойдёт
[оригинальный компилятор VOC](https://github.com/vishaps/voc).
Можно использовать также компиляторы
[Ofront](https://github.com/jtempl/ofront) и
[Ofront+](https://github.com/Oleg-N-Cher/OfrontPlus).

В будущем данный компилятор будет компилировать сам себя.

Зайдите в каталог с исходным кодом компилятора и выполните:
```
make
```
