# NovuPark-MT5-Bot

The bot trades on the original closed strategy based on a combination of technical indicators

* Coding by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* Strategy by [Mr. Igor](https://t.me/Yudintut)
* Version: 1.00


## Что нового?
```
1.00-DEV: First version
```

## Стратегия

1. Бот проверяет сигнал на открытии свечи таймфрейма, на котором он запущен.
2. Бот покупает по рынку, если на прошлой свече индикатор UT Bot дает сигнал BUY и линия индикатора STC находится в диапазоне [0; 25]. 
3. Бот продает по рынку, если на прошлой свече индикатор UT Bot дает сигнал SELL и линия индикатора STC находится в диапазоне [75; 100].
4. Бот устанавливает SL за прошлый фрактал обратного направления.
5. Бот устанавливает TP на расстоянии `SL*TRD_TP_RR`.
6. Если включен параметр `TRD_REV_ENB` включен, то бот закроет текущую позицию при получении обратного сигнала - позиция будет перевернута.  

## Installation | Установка

1. Установите индикатор `UTBot-MT5-Ind`.
2. Установите индикатор `Schaff Trend Cycle`.
3. Установите бот. 

**RU:** Пошаговую инструкцию по установке торговых советников и индикаторов читай [README_INSTALL.md](README_INSTALL.md)
**EN:** For step-by-step instructions on installing Expert Advisors and indicators read [README_INSTALL.md](README_INSTALL.md).

## Использование


## Bot's Input

