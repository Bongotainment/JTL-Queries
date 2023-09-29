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

-- Sollte die Strasse nicht mit beachtet werden hier 0 eintragen.
DECLARE @MatchStreet AS BIT = 1

DECLARE @kKunde as INT
SELECT @kKunde=kKunde FROM Verkauf.tAuftrag 
WHERE kAuftrag = @key

;
WITH AlleAdressen AS (
SELECT [kKunde]
      ,[cVorname]
      ,[cName]
      ,[cStrasse]
      ,[cPLZ]
      ,[cOrt]
      ,[cLand]
FROM [eazybusiness].[Verkauf].[tAuftragAdresse]
UNION
SELECT [kKunde]
      ,[cVorname]
      ,[cName]
      ,[cStrasse]
      ,[cPLZ]
      ,[cOrt]
      ,[cLand]
  FROM [eazybusiness].[dbo].[tAdresse]
  WHERE nStandard = 1 --Ignoriere alle nicht Standardadressen, da sie bereits in den Auftragsadressen vorkommen
 ),
AdressenGruppiert AS (
	SELECT 
	LOWER(cVorname) as Vorname, 
		LOWER(cName) as Nachname, 
		CASE WHEN @MatchStreet = 1 THEN
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(cStrasse),'straße','str')
		,'strasse','str'),'str..','str'),'strase','str'),'str.','str')
		ELSE '' END AS Straße, 
		LOWER(cPLZ) AS PLZ,
		kKunde
	FROM AlleAdressen
	GROUP BY [kKunde]
      ,[cVorname]
      ,[cName]
      ,[cStrasse]
      ,[cPLZ]
      ,[cOrt]
      ,[cLand]
),
KundenNullBereinigt AS (
SELECT  ISNULL(Vorname,'') AS Vorname, 
		ISNULL(Nachname,'') AS Nachname, 
		ISNULL(Straße,'') AS Straße, 
		ISNULL(PLZ,'') AS PLZ, 
		kKunde
		FROM AdressenGruppiert
),
KundenEmptyBereinigt AS(
	SELECT REPLACE(Vorname+Nachname+Straße+PLZ, ' ','') AS CustomerKey, kKunde 
	FROM KundenNullBereinigt
),
KundenAbgleichstabelle AS(
	SELECT *
	FROM KundenEmptyBereinigt
	GROUP BY CustomerKey, kKunde
),
GleicheKundenFuerAuftrag AS (
	SELECT kat2.kKunde FROM KundenAbgleichstabelle kat
	INNER JOIN KundenAbgleichstabelle kat2 
		ON kat.CustomerKey = kat2.CustomerKey AND kat2.CustomerKey <> ''
	WHERE kat.kKunde = @kKunde
	GROUP BY kat2.kKunde
)
SELECT 
	--Start Spalte Erstellt 
		CAST(ta.dErstellt AS smalldatetime) AS Erstellt
	--Ende Spalte Erstellt 

	--Start Spalte Auftragsnummer 
		,ta.cAuftragsnummer AS Auftragsnummer
	--Ende Spalte Auftragsnummer 

	--Start Spalte Kundennummer 
		,ta.cKundeNr AS Kundennummer 
	--Ende Spalte Kundennummer 

	--Start Spalte Plattform 
		,tp.cName AS Plattform
	--Ende Spalte Plattform 

	--Start Spalte [Brutto Gesamt] 
		,CAST(ta.fAuftragswertBrutto as DECIMAL(10,2)) as [Brutto Gesamt]
	--Ende Spalte [Brutto Gesamt] 

	--Start Spalte [Gutgeschriebener Wert] 
		,CAST(ta.fGutgeschriebenerWert  as DECIMAL(10,2)) AS [Gutgeschriebener Wert]
	--Ende Spalte [Gutgeschriebener Wert] 

	--Start Spalte Retoure 
		,CASE ISNULL(tr.cRetoureNr,'') WHEN '' THEN 'Nein' ELSE tr.cRetoureNr END AS Retoure
	--Ende Spalte Retoure

	--Start Spalte nLieferstatus 
		,CASE ta.nLieferstatus
			WHEN 0 THEN 'Storniert'
			WHEN 7 THEN 'Ohne Versand abgeschlossen'
			WHEN 6 THEN 'Gutgeschrieben'
			WHEN 5 THEN 'Verpackt und Versendet'
			WHEN 4 THEN 'Teilversendet'
			WHEN 3 THEN 'Lieferschein erstellt'
			WHEN 2 THEN 'Teilgeliefert'
			WHEN 1 THEN 'Ausstehend'
		END as Lieferstatus
	--Ende Spalte nLieferstatus 

FROM [Verkauf].[lvAuftragsverwaltung] ta
INNER JOIN GleicheKundenFuerAuftrag gk
	ON gk.kKunde = ta.kKunde
LEFT JOIN tPlattform tp 
	ON tp.nPlattform = ta.kPlattform
INNER JOIN AdressenGruppiert tad 
	ON tad.kKunde = gk.kKunde
LEFT JOIn tRMRetoure tr 
	ON tr.kBestellung = ta.kAuftrag
GROUP BY CAST(ta.dErstellt AS smalldatetime), 
		ta.cAuftragsnummer,
		ta.cKundeNr,
		tp.cName,
		ta.fAuftragswertBrutto,
		ta.fGutgeschriebenerWert,
		tr.cRetoureNr,
		ta.nLieferstatus
ORDER BY CAST(ta.dErstellt AS smalldatetime) DESC --Hier ASC eingeben um aufsteigend zu sortieren und DESC eingeben um absteigend zu sortieren