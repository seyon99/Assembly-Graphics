from typing import List

str1 = "1796  1800                               1816   1820            1828  1832  1840  1844  1852  1856  1860  1872  1884 1888  1896  1900  1904"
str2 = "1924  1928             1936            1944                     1956  1960            1968                                1984                      1996            2004            2012                                2028"
str3 = "2052                                          2072                      2084                                2100                     2112                       2124  2128  2132            2140                                2156"
str4 = "2180                                          2200                      2212   2216           2224   2228                     2240                      2252             2260           2268                                 2284"


lst1 = str1.split()
map_object = map(int, lst1)

lst2 = str2.split()
map_object = map(int, lst2)

lst3 = str3.split()
map_object = map(int, lst3)

lst4 = str4.split()
map_object = map(int, lst4)

lst = lst1 + lst2 + lst3 + lst4

#for move down

for adrs in lst:
    print("sw $t5, " + str(adrs) + "($gp)")