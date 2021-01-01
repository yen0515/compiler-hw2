# hw2 report

|||
|----|-----|
|Name|黃彥慈|
|ID|0716088|

## How much time did you spend on this project

10 hours. 

## Project overview

首先是scanner.l的改動，我將每個辨識的rule後方接加上一return值，而return的值為何則是根據在parser.y中這些rule分別對應到的terminal為何來決定，如scanner讀到string這個keyword時，便會做出原先scanner就會做的處理後return STRING_TER，而這個STRING_TER便是string在parser.y中所對應到的terminal。
再來是parser.y的延續，首先先定義start symbol為program_name後，除了加減乘除四個運算符號定義為%left之外，其餘所有的terminal皆定義為%token，再來便是根據規則去寫出context-free grammer，以下的編序對應到程式碼中第幾個context-free grammer。
 1) program_name根據規則便可以derive出如程式上所寫的grammer，而會插入一個';'是因為在定義完program的名字後需要一個分號來表示宣告名稱結束。
 2) 為了方便閱讀與debug，我將空字串另外定義為empty這個nonterminal，之後便已empty來代指空字串。
 3) 將func定義為由func_decdef與本身所組成，由於可以derive出自身因此可以產生多個func結構，而func也可能為empty，允許沒有func部分的情形也讓derive最終有個結果
 4) 延續上點，func_decdef又可能有4種情形，分別為function declare與function definition，第一種情形代表著最典型的function declare，第二種情形則為function declare中的特例也就是procedure，第三點則是有宣告return type的function definition，最後則是沒有return type的function   definition。
 5) arg為負責處理function中的變數宣告，也就是在括號中的identifier_list: type，而由於一function可以沒有任何argument，因此也可以是empty。
 6) id_list則負責構成5)中的identifier_list，為了避免left recursion而不直接derive成自身，而多宣告了一id_list2。
 7) id_list2則負責處理當有多個identifier同時被宣告的狀況，也是為了避免left recursion而設定而成的nonterminal。
 8) scalar_type則負責構成5)中的type部分，可以為boolean(BOOL_TER)、integer(INT_TER)、string(STR_TER)、real(REAL_TER)四種type。
 9) const的宣告則是為了下面的grammer而提前宣告，由整數常數(CONSTINT)與非整數常數(CONSTNOTINT)所組成。
 10) nega_const則是為了避免減號的-與負號的-搞混而額外宣告的nonterminal，而會derive出-與一const。
 11) operator則包含了除了negative與logical中的NOT以外的所有運算符號，包括加減乘除，而除又包括/與MOD，而relational與logical符號也都在其中。
 12) booleanvalue則由TRUE_TER與FALSE_TER所組成，代表boolean值。
 13) vari負責控制的是program與function中的變數宣告，分為6種情形，第一種是宣告變數為甚麼type，第二種則是宣告該變數為array，第三種是將variable賦予其const的值，第四種則是賦予variable一string作為其值，第五種則為賦予variable一boolean值，最猴則由於一program中可以不宣告任何global variable或是local variable，因此可以是空字串。
 14) 負責進行array declare，為了避免left recursion而不直接derive成自身，而多宣告了一array_declare2。
 15) array_declare2則負責處理當被宣告的array為多維度的狀況，也是為了避免left recursion而設定而成的nonterminal。
 16) compound為program中的一部分，其組成與其定義相同，而由於一program可以沒有comppound，因此可以為空字串。
 17) compound_stmt組成與compound相同，但是不可為空字串，單獨宣告這個nonterminal是因為compound亦屬於statement的一類，但是statement又為compound的一部分，若一起宣告則會早乘conflicts，因此特別將屬於statement的compound多設立一nonterminal。
 18) stmt則有為8種可能，分別為7種類型的statement與空字串，因為一program可以沒有compound因此可以為空字串，而7種類席的stmt後面又接著stmt本身，以符合有多項statement的情形。
 19) simple_stmt有三種可能，第一種為assign expression給var_ref的情形，第二種則包刮了定義中的print var_ref與print expression，第三種則為read的情形。
 20) var_ref如定義所示，可以為identifier本身或是identifier為名的array，為了避免left recursion而不直接derive成自身，而多宣告了一array_declare2，因此由ID_TER與arr_ref所組成。
 21) arr_ref則為涵蓋array所定義的nonterminal，是為了避免left recursion而設定而成的nonterminal。
 22) cond_stmt則如定義有2種可能，分別為有else的情形與沒有else的情形。
 23) while_stmt則如定義所示。
 24) return_stmt則如定義所示。
 25) pro_call則代表著procedure call，identifier後方括號的部分分開定義為pro_call以方便後面要處理包含括號的情形。
 26) pro_call包含了兩種情形，分別為括號中有expression與沒有expression的兩種狀況。
 27) expression包含了6種情形，分別為由const、var_ref、pro_call、STRING_TER、nega_const與pro_call2，比較特別的是pro_call2，宣告其是為了讓包含括號的情形能正常運作，若單獨宣告則會造成conflict。
 28) expression2則是為了包含26)中有多個expression同時在括號中的情形，是為了避免left recursion而設定而成的nonterminal。
 29) expression3是為了符合多個const、var_ref、pro_call、STRING_TER、nega_const與pro_call透過operator連接而成的情形。
 
## What is the hardest you think in this project

最一開始宣告return值的時候，執行時發現scanner.c中有error，但又找不到問題所在而苦惱了不少時間，後來才發現是return的值不可以是keyword本身，不然會發生錯誤，因此我在所有terminal後方皆加上後綴_TER以避免這種情形發生。

## Feedback to T.A.s

思考context-free grammer較上次的RE好想，但是便要多處理一個conflicts的問題，一樣有趣而能將理論實際化。
