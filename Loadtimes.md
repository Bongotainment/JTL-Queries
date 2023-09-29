# Lange Leidezeiten 

## Die optimale Platzierung von benutzerdefinierten Übersichten in JTL

In JTL-Wawi kann die Integration eigener Übersichten eine nützliche Funktion sein, um Daten und Informationen 
schnell abzurufen. Bei der Einrichtung von eigenen Übersichten ist es jedoch wichtig, die Reihenfolge, in der sie in 
der Liste der eigenen Übersichten platziert werden, sorgfältig zu berücksichtigen.

Insbesondere sollte vermieden werden, eine eigene Übersicht an die erste Position in der Liste der eigenen Übersichten 
zu setzen, wenn diese Übersicht längere Ladezeiten erfordert. Dies hat einen wichtigen Grund: Die erste Übersicht in 
der Liste wird standardmäßig ausgewählt und bei jedem Wechsel der Position in der entsprechenden Tabelle geladen.

Angenommen, Sie integrieren eine individuelle Übersicht im Bereich "Aufträge" und setzen sie an die Spitze der Liste. 
Dies hätte zur Folge, dass JTL jedes Mal, wenn Sie zwischen verschiedenen Aufträgen wechseln, den zugehörigen 
Datenabfrageprozess für Ihre benutzerdefinierte Übersicht ausführen würde. Dies kann zu einer spürbaren Verlangsamung 
der Benutzeroberfläche führen und die Effizienz Ihrer Arbeit beeinträchtigen.

Wenn Sie bereits eine eigene Übersicht mit geringer Ladezeit an Position haben, können Sie dieses Problem ignorieren. 
Sollte Ihre Ansicht an Position eins lange laden, können Sie einfach eine neue Ansicht mit folgendem SQL-Code an die
erste Position setzen. Kopieren Sie dazu den Code der bisher an Position eins stehenden Abfrage und speichern 
Sie ihn nun in einer neuen eigenen Übersicht. Anstelle des lange ladenden Queries an Position eins können Sie nun 
folgende Abfrage einfügen:

`SELECT ''`
