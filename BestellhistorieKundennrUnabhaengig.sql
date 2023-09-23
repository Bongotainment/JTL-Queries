---------------------------------------------------------------------------------------
 --   This program is free software: you can redistribute it and/or modify
 --   it under the terms of the GNU General Public License as published by
 --   the Free Software Foundation, either version 3 of the License, or
 --   (at your option) any later version.

 --   This program is distributed in the hope that it will be useful,
 --   but WITHOUT ANY WARRANTY; without even the implied warranty of
 --   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 --   GNU General Public License for more details.

 --   You should have received a copy of the GNU General Public License
 --   along with this program.  If not, see <http://www.gnu.org/licenses/>.

 --   Dieses Programm ist Freie Software: Sie können es unter den Bedingungen
 --   der GNU General Public License, wie von der Free Software Foundation,
 --   Version 3 der Lizenz oder (nach Ihrer Wahl) jeder neueren
 --   veröffentlichten Version, weiter verteilen und/oder modifizieren.

 --   Dieses Programm wird in der Hoffnung bereitgestellt, dass es nützlich sein wird, jedoch
 --   OHNE JEDE GEWÄHR,; sogar ohne die implizite
 --   Gewähr der MARKTFÄHIGKEIT oder EIGNUNG FÜR EINEN BESTIMMTEN ZWECK.
 --   Siehe die GNU General Public License für weitere Einzelheiten.

 --   Sie sollten eine Kopie der GNU General Public License zusammen mit diesem
 --   Programm erhalten haben. Wenn nicht, siehe <https://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------------
-- Erstellt von: Julian Lederer
-- Herkunft dieses Scripts: https://github.com/Bongotainment/JTL-Queries

-- Testkey
-- DECLARE @key as int = 20



DECLARE @kKunde as INT
SELECT @kKunde=kKunde FROM Verkauf.tAuftrag 
WHERE kAuftrag = @key

DECLARE @lieferadresse as INT = 0
;WITH Kunden AS(
SELECT  TRIM(lower(cVorname)) as Vorname, 
		TRIM(lower(cName)) as Nachname, 
		TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(cStrasse),'straße','str')
		,'strasse','str'),'str..','str'),'strase','str'),'str.','str')) as Straße, 
		TRIM(lower(cPLZ)) AS PLZ, 
		tk.kKunde
		FROM tkunde tk
INNER JOIN tAdresse ta 
	ON ta.kKunde = tk.kKunde AND ta.nTyp = @lieferadresse
),
KundenNullBereinigt AS (
SELECT  ISNULL(Vorname,'') AS Vorname, 
		ISNULL(Nachname,'') AS Nachname, 
		ISNULL(Straße,'') AS Straße, 
		ISNULL(PLZ,'') AS PLZ, 
		kKunde
		FROM Kunden
),
KundenAbgleichstabelle AS(
	SELECT REPLACE(Vorname+Nachname+Straße+PLZ, ' ','') AS CustomerKey, kKunde 
	FROM KundenNullBereinigt
),
GleicheKundenFuerAuftrag AS (
	SELECT kat2.kKunde FROM KundenAbgleichstabelle kat
	INNER JOIN KundenAbgleichstabelle kat2 
		ON kat.CustomerKey = kat2.CustomerKey
	WHERE kat.kKunde = @kKunde
)
SELECT CAST(ta.dErstellt AS smalldatetime) AS Erstellt, 
		ta.cAuftragsNr AS Auftragsnummer, 
		ta.cKundenNr AS Kundennummer, 
		tp.cName AS Plattform,
		tad.cAnrede AS Anrede,
		tad.cVorname AS Vorname,
		tad.cName AS Nachname, 
		tad.cStrasse AS Straße, 
		tad.cPLZ AS PLZ, 
		tad.cOrt AS Ort, 
		tad.cLand AS Land
FROM Verkauf.tAuftrag ta
INNER JOIN GleicheKundenFuerAuftrag gk
	ON gk.kKunde = ta.kKunde
LEFT JOIN tPlattform tp 
	ON tp.nPlattform = ta.kPlattform
INNER JOIN Verkauf.tAuftragAdresse tad 
	ON tad.kAuftrag = ta.kAuftrag AND tad.nTyp = @lieferadresse
GROUP BY CAST(ta.dErstellt AS smalldatetime), 
		ta.cAuftragsNr, 
		ta.cKundenNr, 
		tp.cName,
		tad.cAnrede,
		tad.cVorname,
		tad.cName, 
		tad.cStrasse,
		tad.cPLZ,
		tad.cOrt,
		tad.cLand 