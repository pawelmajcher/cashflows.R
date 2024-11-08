# cashflows.R

Simple functions for visualizing and discounting cash flows (DCF) in R

## Czym jest cashflows.R?

cashflows.R to niewielki skrypt w R, który ułatwia pracę nad przepływami pieniężnymi (cash flows). Umożliwia między innymi łączenie różnych przepływów, zapisywanie w formie przepływu rent i obligacji, a także obliczanie wartości przepływu w danym czasie według podanego oprocentowania prostego lub złożonego.

## Rozpoczynanie pracy

Można dołączyć cashflows.R do swojego skryptu dopisując na początku
komendę

``` r
source("https://github.com/pawelmajcher/cashflows.R/blob/main/cashflows.R?raw=true")
```

która dodaje wszystkie funkcje do twojej przestrzeni roboczej.

## Dostępne funkcje

### cashflow(payments, periods)

Funkcja `cashflow` przyjmuje wektor z wartościami poszczególnych transakcji oraz wektor z czasem ich wykonania, i porządkuje je tak, aby transakcje były zapisane w odpowiedniej kolejności i zwraca listę w R, która przez inne funkcje jest rozumiana jako przepływ pieniężny.

#### Argumenty

| Nazwa      | Opis                                                      | Przyjmowana wartość                                  | Wymagany                          |
|:-----|:-------------------------|:-----------------------|:---------------|
| `payments` | wektor z wartościami poszczególnych transakcji            | wektor liczbowy o dowolnej długości                  | Tak                               |
| `periods`  | wektor z czasem przeprowadzenia poszczególnych transakcji | wektor liczbowy o takiej samej długości jak payments | Nie, domyślnie 1:length(payments) |

#### Przykłady

``` r
cashflow_example_1 = cashflow(payments = c(10,30,40,10))
cashflow_example_1
```

    ## $payments
    ## [1] 10 30 40 10
    ## 
    ## $periods
    ## [1] 1 2 3 4

``` r
cashflow_example_2 = cashflow(payments = c(10,20,30), periods = c(0,2,5))
cashflow_example_2
```

    ## $payments
    ## [1] 10 20 30
    ## 
    ## $periods
    ## [1] 0 2 5

### cfmerge(…)

Funkcja `cfmerge` przyjmuje i łączy (scala) dowolną liczbę przepływów
pieniężnych w jeden.

#### Przykłady

``` r
cashflow_example_3 = cfmerge(cashflow_example_1, cashflow_example_2, cashflow(-100, periods=5))
cashflow_example_3
```

    ## $payments
    ## [1]  10  10  50  40  10 -70
    ## 
    ## $periods
    ## [1] 0 1 2 3 4 5

### cfmatrix(cf, vertical)

Funkcja `cfmatrix` zwraca dany przepływ pieniężny jako macierz. Jest
przydatna, gdy chcemy wyświetlić przepływ i ręcznie go przeanalizować.

#### Argumenty

| Nazwa      | Opis                                                                                                   | Przyjmowana wartość                                | Wymagany                                            |
|:----|:--------------------------------|:----------------|:-----------------|
| `cf`       | przepływ, który chcemy zapisać jako macierz                                                            | przepływ pieniężny wygenerowany przez inną funkcję | Tak                                                 |
| `vertical` | opcja zapisu kolejnych transakcji pod sobą zamiast obok siebie (warto wybrać dla dłuższych przepływów) | wartość logiczna                                   | Nie, domyślnie `FALSE` (kolejne transakcje poziomo) |

#### Przykłady

``` r
cfmatrix(cashflow_example_2)
```

    ##        Payment 1 Payment 2 Payment 3
    ## Period         0         2         5
    ## Amount        10        20        30

``` r
cfmatrix(cashflow_example_3, vertical=TRUE)
```

    ##           Period Amount
    ## Payment 1      0     10
    ## Payment 2      1     10
    ## Payment 3      2     50
    ## Payment 4      3     40
    ## Payment 5      4     10
    ## Payment 6      5    -70

### annuity(period, amount, due)

Funkcja `annuity` przyjmuje parametry danej renty i zwraca odpowiadający
jej przepływ pieniężny.

#### Argumenty

| Nazwa    | Opis                                   | Przyjmowana wartość                                                           | Wymagany                                 |
|:----|:----------------|:--------------------------------|:-----------------|
| `period` | liczba okresów (długość) trwania renty | liczba naturalna lub `Inf` (przybliżenie renty wieczystej jako 10000 okresów) | Tak                                      |
| `amount` | wysokość renty                         | liczba                                                                        | Nie, domyślnie `1`                       |
| `due`    | płatność renty z góry                  | wartość logiczna                                                              | Nie, domyślnie `FALSE` (płatność z dołu) |

#### Przykłady

``` r
cashflow_example_4 = annuity(period = 6, amount = 150, due = TRUE)
cfmatrix(cashflow_example_4)
```

    ##        Payment 1 Payment 2 Payment 3 Payment 4 Payment 5 Payment 6
    ## Period         0         1         2         3         4         5
    ## Amount       150       150       150       150       150       150

### bond(principal, maturity, couponRate, boughtFor)

Funkcja `bond` przyjmuje parametry danej obligacji i zwraca
odpowiadający jej przepływ pieniężny.

#### Argumenty

| Nazwa        | Opis                                       | Przyjmowana wartość                   | Wymagany                                                         |
|:------|:-------------------|:-----------------|:----------------------------|
| `principal`  | wartość nominalna obligacji                | liczba                                | Tak                                                              |
| `maturity`   | termin zapadalności obligacji              | liczba naturalna                      | Tak                                                              |
| `couponRate` | stała lub zmienna stopa kuponowa obligacji | liczba lub wektor długości `maturity` | Nie, domyślnie 0 (obligacja zerokuponowa)                        |
| `boughtFor`  | cena, za jaką obligacja została zakupiona  | liczba                                | Nie, domyślnie 0 (transakcja zakupu obligacji nie jest dopisana) |

#### Przykłady

``` r
cashflow_example_5 = bond(principal = 5000, maturity = 5, couponRate = 0.03)
cfmatrix(cashflow_example_5)
```

    ##        Payment 1 Payment 2 Payment 3 Payment 4 Payment 5
    ## Period         1         2         3         4         5
    ## Amount       150       150       150       150      5150

``` r
cashflow_example_6 = bond(principal = 20, maturity = 10, boughtFor = 10)
cfmatrix(cashflow_example_6)
```

    ##        Payment 1 Payment 2
    ## Period         0        10
    ## Amount       -10        20

### timevalue(cf, v, i, t, as.cashflow)

Funkcja `timevalue` oblicza wartość przepływu pieniężnego w danej chwili
przy konkretnych rynkowych stopach procentowych i oprocentowaniu
złożonym.

#### Argumenty

| Nazwa         | Opis                                                               | Przyjmowana wartość                                  | Wymagany                                       |
|:------|:-------------------------|:--------------------|:------------------|
| `cf`          | przepływ, którego wartość chcemy obliczyć                          | przepływ pieniężny wygenerowany przez inną funkcję   | Tak                                            |
| `v`           | wartość/wartości czynnika dyskontującego                           | liczba lub wektor długości równej liczbie transakcji | Tak, o ile nie zdefiniowano `i`                |
| `i`           | wartość/wartości stopy procentowej                                 | liczba lub wektor długości równej liczbie transakcji | Tak, o ile nie zdefiniowano `v`                |
| `t`           | czas, dla którego liczymy wartość                                  | liczba                                               | Nie, domyślnie 0 (wartość obecna)              |
| `as.cashflow` | zwrócenie przepływu zdyskontowanego do danej chwili zamiast liczby | wartość logiczna                                     | Nie, domyślnie `FALSE` (funkcja zwraca liczbę) |

**UWAGA:** Jeśli wprowadzasz `v` lub `i` jako wektor, upewnij się, że
nie wpisujesz wartości dla kolejnych okresów zamiast kolejnych
transakcji.  
**UWAGA 2:** Wprowadź jedną z wartości `v` lub `i`, ale nie obie
jednocześnie.

#### Przykłady

``` r
# Ile warte są kolejne wypłaty renty z przykładu 4? (załóżmy od 1 roku malejącą stopę procentową z 5% do 1% w kolejnych wypłatach) (stopa w roku 0 nie ma znaczenia, więc przyjęliśmy 6% dla ułatwienia)
cashflow_example_4_rates = seq(0.06, 0.01, by=-0.01)
cashflow_example_4_present_values = timevalue(cashflow_example_4, i = cashflow_example_4_rates, as.cashflow = TRUE)
cfmatrix(cashflow_example_4_present_values)
```

    ##        Payment 1 Payment 2 Payment 3 Payment 4 Payment 5 Payment 6
    ## Period         0    1.0000    2.0000    3.0000    4.0000    5.0000
    ## Amount       150  142.8571  138.6834  137.2712  138.5768  142.7199

``` r
# Ile będzie warta obligacja z przykładu 5 w chwili jej zapadalności? (załóżmy stały czynnik dyskontujący 0.98)
cashflow_example_5_maturity_value = timevalue(cashflow_example_5, v = 0.98, t = 5)
cashflow_example_5_maturity_value
```

    ## [1] 5781.243

``` r
# Ile zarobiliśmy na obligacji z przykładu 6? (załóżmy stałą stopę procentową 5%)
cashflow_example_6_present_value = timevalue(cashflow_example_6, i = 0.05)
cashflow_example_6_present_value
```

    ## [1] 2.278265

**UWAGA:** Istnieje też druga funkcja do obliczania obecnej wartości
przepływu przy oprocentowaniu złożonym, `presentvalue`. Występuje ona ze
względu na zgodność z poprzednimi wersjami skryptu i nie ma potrzeby jej
stosowania (domyślnie `timevalue` i tak oblicza wartość bieżącą).

### simpletimevalue(cf, i, method, t, as.cashflow)

Funkcja `simpletimevalue` oblicza wartość przepływu pieniężnego w danej
chwili przy konkretnych rynkowych stopach procentowych i oprocentowaniu
prostym.

#### Argumenty

| Nazwa         | Opis                                                                                                                         | Przyjmowana wartość                                  | Wymagany                                       |
|:----|:------------------------------------|:---------------|:--------------|
| `cf`          | przepływ, którego wartość chcemy obliczyć                                                                                    | przepływ pieniężny wygenerowany przez inną funkcję   | Tak                                            |
| `i`           | wartość/wartości stopy procentowej                                                                                           | liczba lub wektor długości równej liczbie transakcji | Tak                                            |
| `t`           | czas, dla którego liczymy wartość                                                                                            | liczba                                               | Nie, domyślnie 0 (wartość obecna)              |
| `method`      | metoda obliczania wartości przepływu pieniężnego (przepływy równoważne/ekwiwalentne lub metoda retrospektywnie-prospektywna) | `e` lub `rp`                                         | Tak, chyba że `t == 0`                         |
| `as.cashflow` | zwrócenie przepływu zdyskontowanego do danej chwili zamiast liczby                                                           | wartość logiczna                                     | Nie, domyślnie `FALSE` (funkcja zwraca liczbę) |

#### Przykłady

``` r
# Ile będzie warta obligacja z przykładu 5 w chwili jej zapadalności? (załóżmy stałą stopę procentową 7% i oprocentowanie proste)
cashflow_example_5_maturity_value_si_rp = simpletimevalue(cashflow_example_5, i = 0.07, t = 5, method = "rp")
cashflow_example_5_maturity_value_si_e = simpletimevalue(cashflow_example_5, i = 0.07, t = 5, method = "e")

# kolejno wynik metodą retrospektywnie-prospektywn i przepływów równoważnych:
c(cashflow_example_5_maturity_value_si_rp, cashflow_example_5_maturity_value_si_e)
```

    ## [1] 5855.000 5842.442

``` r
# Ile zarobiliśmy na obligacji z przykładu 6? (załóżmy stałą stopę procentową 5% i oprocentowanie proste)
cashflow_example_6_present_value_si = simpletimevalue(cashflow_example_6, i = 0.05)
cashflow_example_6_present_value_si
```

    ## [1] 3.333333

## Więcej przykładów

### Zadanie 1

Wyznacz wartość obecną przepływu nieskończonego, który dla parzystych
chwil n wypłaca wartość *1/n*, a dla nieparzystych wypłaca *1/n^2* dla
*i = 0.02*.

**Rozwiązanie:**

``` r
cashflow_task_1_1 = cashflow(periods = 2*(1:10000), payments = 1/(2*(1:10000)))

cashflow_task_1_2 = cashflow(periods = 2*(1:10000) - 1, payments = (1/(2*(1:10000)) - 1)^2)

cashflow_task_1 = cfmerge(cashflow_task_1_1, cashflow_task_1_2)

timevalue(cashflow_task_1, i=0.02)
```

    ## [1] 23.93494

### Zadanie 2

Podaj różnicę między wartością renty dziesięcioletniej płatnej z góry o
wysokości 400 zł w chwili ostatniej wypłaty a teraz. Załóż
oprocentowanie proste w wysokości i=0.10 i metodę przepływów
równoważnych.

**Rozwiązanie:**

``` r
cashflow_task_2 = annuity(period = 10, amount = 400, due = TRUE)
cfmatrix(cashflow_task_2)
```

    ##        Payment 1 Payment 2 Payment 3 Payment 4 Payment 5 Payment 6 Payment 7
    ## Period         0         1         2         3         4         5         6
    ## Amount       400       400       400       400       400       400       400
    ##        Payment 8 Payment 9 Payment 10
    ## Period         7         8          9
    ## Amount       400       400        400

``` r
simpletimevalue(cashflow_task_2, i = 0.1, t = 9, method="e") - simpletimevalue(cashflow_task_2, i = 0.1, method="e") 
```

    ## [1] 2587.577

### Zadanie 3

Dla jakiej stopy przy oprocentowaniu prostym dziesięcioletnia obligacja
zerokuponowa jest równoważna tej obligacji przy stopie 5% i
oprocentowaniu złożonym?

**Rozwiązanie:**

``` r
# bierzemy dowolny dodatni nominał obligacji
cashflow_task_3 = bond(principal = 1, maturity = 10)
for (i in (1:1000)/1000) {
  if (simpletimevalue(cashflow_task_3, i=i) < timevalue(cashflow_task_3, i=0.05)) {
    print(i)
    break()
  }
}
```

    ## [1] 0.063
