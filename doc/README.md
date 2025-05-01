# Projekt FLP 2022 - BKG-2-CNF
Lukas Wagner \<xwagne10>


## Spousteni aplikace
Apikaci lze sestavit spustenim prikazu `make` a nasledne spustit jako `./flp21-fun` (doufam, ze nemam stare zadani). Aplikace akceptuje 3 argumenty podle specifikace ze zadani:

`./flp21-fun [[-i] [-1] [-2] filepath] [-i] [-1] [-2]`
- `-i` - vytiskne gramatiku nezmenenou na vystup
- `-1` - vytiskne ekvivalentni gramatiku bez jednoduchych pravidel
- `-2` - vytiskne gramatiku v Chomskeho normalni forme

Vysledek bude vytisknut v poradi specifikovanem poradim parametru, parametry lze opakovat. Lze take spustit aplikaci nad vice soubory, s parametry vzdy pred souborem. Koncove parametry bez cesty k souboru budou vykonany nad gramatikou nactenou ze standardniho vstupu.

## Format gramatiky
Vstupni format je jednoznacne definovan zadanim:
```
S,A,B       Neterminaly
a,b,c       Terminaly
S           Pocatecni neterminal
S->aAb      Pravidlo
A->B        Pravidlo
...
```
Vystupni oznaceni neterminalu v zadani jasne specifikovano neni. Zadani se odkazuje na oporu, ktera pouziva docasne substituce a tim padem asi 2 typy oznaceni nekterych neterminalu, proto uvadim specifikaci zde.

- `N->tN` => `N->t'N`, kde `t'->t` je nove pravidlo s neterminalem `t'`
- `N->ABt` => `N->A<Bt>`, kde `<Bt>->Bt'` je nove pravidlo s neterminalem `<Bt>`

### Princip pojmenovani
Z terminalu v pravidlech s vice symboly je vytvoren neterminal pripsanim cary, __ovsem__ pismeno neni nahrazeno velkym pismenenm.

Z pravidel s vice symboly nez dvema je vytvoreno pravidlo o prvnim symbolu a novem neterminalu vzniklem uzavorkovanim zbylych symbolu do spicatych zavorek, __ovsem__ v nazvu tohoto neterminalu **nejsou** prejmenovany terminaly dle minuleho pravidla. Pokud je prvni symbol terminal **je** nahrazen dle predchoziho pravidla.

### Priklad spusteni
```
$ make
$ ./flp21-fun -2 test/grammar1.in

S,A,B,<Ab>,b',a',<Bd>,d',c'
a,b,c,d
S
S->AB
a'->a
A->a'<Ab>
<Ab>->Ab'
b'->b
A->a'b'
c'->c
B->c'<Bd>
<Bd>->Bd'
d'->d
B->c'd'
```

## Vyznamna rozsireni
- vice souboru
- vice parametru i s opakovanim
- kontrola vstupu a ukonceni s errorem v pripade chybneho vstupu
    - Neexistujici terminaly/neterminaly v pravidlech a v pocatecnim neterminalu
    - Chybejici prava strana pravidla
    - malo radku na vstupu