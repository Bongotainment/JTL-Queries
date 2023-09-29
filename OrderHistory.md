# Bestellhistorie Kundennummerunabhängig
Queries zum Einfügen als eigene Übersicht im Bereich Aufträge der JTL Wawi

## Hinweis
Dieses Query benötigt bei größeren Kundenstämmen mehr als eine Sekunde. Es wird daher empfohlen, dieses Query nicht an Position eins
der eigenen Übersichten zu platzieren. Siehe hierzu [Queries mit langen Ladezeiten](Loadtimes.md)

## Varianten

Die Bestellhistorie kommt in zwei unterschiedlichen Varianten

1. [Ohne Namen](BestellhistorieKundennrUnabhaengigOhneNamen.sql)
2. [Mit Namen](BestellhistorieKundennrUnabhaengig.sql)

Während die erste Variante alle Aufträge und Kundennummern auflistet, werden
bei der zweiten Variante auch alle Liefer-, Rechnungs- und Kundenadressen mit ausgegeben. Dies führt dazu,
dass zu einer Auftragsnummer mehrere Adressen gefunden werden. Sollten Sie diese Adressdaten nicht benötigen,
wird die erste Variante empfohlen.



