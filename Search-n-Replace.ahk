#Persistent

; Pfade für die INI-Datei und die Ordner definieren
configFolder := "config"
dataFolder := "data"
iniFile := configFolder "\settings.ini"

; Sicherstellen, dass die Ordner "config" und "data" existieren
IfNotExist, %configFolder%
{
    FileCreateDir, %configFolder%
}
IfNotExist, %dataFolder%
{
    FileCreateDir, %dataFolder%
}

; Standardwerte für die Slots
global activeSlot := "Slot 1"
slots := ["Slot 1", "Slot 2", "Slot 3", "Slot 4"]

; GUI Variablen
global searchText := ""
global replaceText := ""

; Slot-Änderungsfunktion
SlotChange()
{
    global iniFile, searchText, replaceText, activeSlot

    GuiControlGet, activeSlot,, activeSlot

    ; Lade die Werte des ausgewählten Slots
    IniRead, searchText, %iniFile%, %activeSlot%, SearchText, ERROR
    IniRead, replaceText, %iniFile%, %activeSlot%, ReplaceText, ERROR

    ; Falls die Werte "ERROR" sind, setze sie auf leer
    if (searchText = "ERROR")
        searchText := ""
    if (replaceText = "ERROR")
        replaceText := ""

    ; Aktualisiere die GUI mit den geladenen Werten
    GuiControl,, searchText, %searchText%
    GuiControl,, replaceText, %replaceText%
}

; Speichern der Slot-Einstellungen
SaveSlotSettings()
{
    global iniFile, searchText, replaceText, activeSlot

    GuiControlGet, searchText,, searchText
    GuiControlGet, replaceText,, replaceText
    IniWrite, %searchText%, %iniFile%, %activeSlot%, SearchText
    IniWrite, %replaceText%, %iniFile%, %activeSlot%, ReplaceText
    
    ; Zeige den grünen "Slot saved!" Text an
    GuiControl, Show, SlotSavedText
    Sleep, 1100 ; Warte 1,5 Sekunden
    GuiControl, Hide, SlotSavedText ; Verstecke den Text wieder
}

; Funktion zur Ausführung des jeweiligen Slots
ExecuteSlot(slotNumber)
{
    global iniFile, dataFolder

    ; Lade den Such- und Ersetzungstext aus der INI-Datei für den angegebenen Slot
    slotName := "Slot " slotNumber
    IniRead, searchText, %iniFile%, %slotName%, SearchText, ERROR
    IniRead, replaceText, %iniFile%, %slotName%, ReplaceText, ERROR

    ; Wenn die Werte "ERROR" sind, bedeutet das, dass der Eintrag fehlt
    if (searchText = "ERROR" or replaceText = "ERROR") {
        MsgBox, Error: Could not load settings for %slotName%.
        return
    }

    ; Strg + A senden, um den gesamten Text auszuwählen
    Send, ^a
    Sleep, 100 ; Warte eine kurze Zeit, um sicherzustellen, dass der Text ausgewählt ist

    ; Strg + C senden, um den ausgewählten Text zu kopieren
    Send, ^c
    Sleep, 100 ; Warte eine kurze Zeit, um sicherzustellen, dass der Text kopiert ist

    ; Text aus der Zwischenablage in eine Variable einfügen
    clipboardText := Clipboard

    ; Den Originaltext in einer Datei im "data"-Unterordner speichern (altes überschreiben)
    originalFile := dataFolder "\original_text_" slotName ".txt"
    FileDelete, %originalFile%
    FileAppend, %clipboardText%, %originalFile%

    ; Ersetzung durchführen
    modifiedText := StrReplace(clipboardText, searchText, replaceText)

    ; Den modifizierten Text in einer anderen Datei im "data"-Unterordner speichern (altes überschreiben)
    modifiedFile := dataFolder "\modified_text_" slotName ".txt"
    FileDelete, %modifiedFile%
    FileAppend, %modifiedText%, %modifiedFile%

    ; Modifizierten Text in die Zwischenablage legen
    Clipboard := modifiedText
    Sleep, 100 ; Warte eine kurze Zeit, um sicherzustellen, dass der Text in der Zwischenablage ist

    ; Strg + V senden, um den modifizierten Text einzufügen
    Send, ^v
}

; GUI-Definition
ShowCustomGUI()
{
    global slots, activeSlot, SlotSavedText

    Gui, +AlwaysOnTop
    Gui, Add, Text,, Select Slot:
    Gui, Add, DropDownList, vactiveSlot gSlotChange, % "Slot 1||Slot 2|Slot 3|Slot 4"
    Gui, Add, Text,, Search Text:
    Gui, Add, Edit, vsearchText w300
    Gui, Add, Text,, Replace Text:
    Gui, Add, Edit, vreplaceText w300
    Gui, Add, Button, gSaveSlotSettings, Save Slot
    Gui, Add, Text, xp+60 yp+3 vSlotSavedText cGreen Hidden, SLOT SAVED! ; Der Text wird initial versteckt
    Gui, Show,, Slot Configuration
    SlotChange() ; Initialisiere die GUI mit den Werten des ausgewählten Slots
}

; Tray-Doppelklick anpassen
Menu, Tray, Add, Show GUI, ShowCustomGUI
Menu, Tray, Default, Show GUI  ; Setze die Standardaktion (Doppelklick) auf die benutzerdefinierte GUI

; Hotkeys für die Ausführung der Slots definieren
F1::ExecuteSlot(1)
F2::ExecuteSlot(2)
F3::ExecuteSlot(3)
F4::ExecuteSlot(4)
