# NovuPark-MT5-Bot

The bot trades on the original closed strategy based on a combination of technical indicators

* Coding by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* Strategy by [Mr. Igor](https://t.me/Yudintut)
* Version: 1.00

![Layout](img/UM001.%20Layout.png)

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

##### 1. INDICATORS (I*)
- [x] `I_UT_KEY`: UT Bot: Key Value (sensitivity)
- [x] `I_UT_ATR`: UT Bot: ATR Period
- [x] `I_STC_SCH_PER`: STC: Schaff period
- [x] `I_STC_FEMA`: STC: Fast EMA period
- [x] `I_STC_SEMA`: STC: Slow EMA period
- [x] `I_STC_SMT_PER`: STC: Smoothing period
- [x] `I_STC_PRC`: STC: Price

##### 2. FILTER (F)
- [x] `F_STC_BUY_MIN`: BUY allowed Min STC value
- [x] `F_STC_BUY_MAX`: BUY allowed Max STC value
- [x] `F_STC_SELL_MIN`: SELL allowed Min STC value
- [x] `F_STC_SELL_MAX`: SELL allowed Max STC value

##### 3. TRADE (TRD)
- [x] `TRD_DIR_MOD`: Режим торговли
- [x] `TRD_MM_MOD`: Money Management Type
- [x] `TRD_MM_VAL`: Money Management Value
- [x] `TRD_TP_RR`: TP RR
- [x] `TRD_REV_ENB`: Close pos on opposite signal

##### 4. GRAPHIC (GUI)
- [x] `GUI_ENB`: Draw pos

##### 9. MISC (MS)
- [x] `MS_MGC`: Expert Adviser ID - Magic
- [x] `MS_EGP`: Expert Adviser Global Prefix
- [x] `MS_LOG_LL`: Log Level
- [x] `MS_LOG_FI`: Log Filter IN String (use `;` as sep)
- [x] `MS_LOG_FO`: Log Filter OUT String (use `;` as sep)
- [x] `MS_COM_EN`: Comment Enable (turn off for fast testing)
- [x] `MS_COM_IS`: Comment Interval, ms
- [x] `MS_COM_CW`: Comment Custom Window
- [x] `MS_HIN_EN`: On Chart Hints Enabled
- [x] `MS_HIN_CH`: On Chart Default Char
- [x] `MS_HIN_CL`: On Chart Default Color
- [x] `MS_OTR_MOD`: On Tester Result calculation Mode
- [x] `MS_OTR_TF`: On Tester Result calculation Timeframe
- [x] `MS_TIM_MS`: Timer Interval, ms