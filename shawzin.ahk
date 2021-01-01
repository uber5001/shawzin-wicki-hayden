#NoEnv
#Warn
#MaxHotkeysPerInterval 9999
SendMode Event
SetKeyDelay, -1, -1

Suspend

STRING_BLOCK_TIME := -32
STRING_WAIT_TIME := -1

Scales := [[60,63,65,67,70,72,75,77,79,82,84,87]   ;/*Pentatonic Minor*/
          ,[60,62,64,67,69,72,74,76,79,81,84,86]  ;/*Pentatonic Major*/
          ,[60,61,62,63,64,65,66,67,68,69,70,71]  ;/*Chromatic*/
          ,[60,63,65,66,67,70,72,75,77,78,79,82]  ;/*Hexatonic*/
          ,[60,62,64,65,67,69,71,72,74,76,77,79]  ;/*Major*/
          ,[60,62,63,65,67,68,70,72,74,75,77,79]  ;/*Minor*/
          ,[60,61,65,66,70,72,73,77,78,81,84,85]  ;/*Hirajoshi*/
          ,[60,61,64,65,67,68,70,72,73,76,77,79]  ;/*Phrygian Dominant*/
          ,[61,63,66,68,70,73,75,78,80,82,85,87]] ;/*Yo*/

ScaleCount = 9

Scale = 1

; shawzin can't pluck same string (1,2,3) twice in one frame.
nq := []
nqLen := 0
blocked1 := false
blocked2 := false
blocked3 := false

TryNoteQueue()

return

#IfWinActive Warframe

HandleKey(row, col) {
    global
    ; this is the jammer layout. modify this function if you want a different layout:
    ; offset of 53 makes midi 83 (the missing note) line up at the nonexistant F4.5 key
    ; offset of 48 gives a good use of the F5 - F8 row, and lines up F8.5 at midi 88 (the note 1 above the highest playable note)
    ;   48 is probably the best one, using "H" as tonic for major, and "Backspace" for 2 octaves up.
    ;   best for having both major and minor scales, anyways
    ; offset of 50 was the original layout. was pretty decent. the "0" key got annoying
    note := 48 + row * 5 + col * 2
    QueueNote(note)
}

QueueNote(n) {
    global
    if (!NoteExists(n)) {
        return
    }
    nq.Insert(1, n)
    nqLen++
}

TryNoteQueue() {
    global

    while (nqLen > 0) {
        local note := nq[nqLen]

        local strBlock := TrySendShawzinNote(note)

        if (strBlock == 0) {
            ; not played. Wait a bit for all strings to unblock, and try again
            break
        } else {
            ; played. block the strings that were played, and unblock them later
            nqLen--
            nq.Remove()
            if (strBlock == 1) {
                blocked1 := true
                SetTimer, Unblock1, %STRING_BLOCK_TIME%
            }
            if (strBlock == 2) {
                blocked2 := true
                SetTimer, Unblock2, %STRING_BLOCK_TIME%
            }
            if (strBlock == 3) {
                blocked3 := true
                SetTimer, Unblock3, %STRING_BLOCK_TIME%
            }
        }
    }

    setTimer, TryNoteQueue, -1
}

Unblock1:
blocked1 := false
return

Unblock2:
blocked2 := false
return

Unblock3:
blocked3 := false
return

NoteExists(midiVal) {
    global
    for i, scaX in Scales {
        for j, noteX in scaX {
            if (noteX == midiVal) {
                return true
            }
        }
    }
    return false
}

; return 0 if failed
; returns blocked string number on success
TrySendShawzinNote(midiVal) {
    global
    local tabsNeeded := 0
    local sc := []
    local scI := 0
    local blockedString := 0
    
    ;MsgBox, %midiVal%

    while (tabsNeeded < ScaleCount) {
        local j := Mod((Scale - 1) + tabsNeeded, ScaleCount) + 1
        sc := Scales[j]
        scI := ArrayFindVal(sc, midiVal)
        ; MsgBox, %Scales%
        ; MsgBox, %sc%
        
        if (scI > 0) {
            if (Mod(scI, 3) == 1)
                if (!blocked1)
                    blockedString := 1
            if (Mod(scI, 3) == 2)
                if (!blocked2)
                    blockedString := 2
            if (Mod(scI, 3) == 0)
                if (!blocked3)
                    blockedString := 3
        }

        if (blockedString > 0) {
            break
        }
            
        tabsNeeded++
    }

    if (blockedString > 0) {
        i := 0
        while i < tabsNeeded {
            send {tab}
            i++
        }
        Scale := Mod((Scale - 1) + tabsNeeded, ScaleCount) + 1
        SendShawzinScalePluck(scI)
    }
    return blockedString
}

ArrayFindVal(array, val) {
    for index, value in array
        if (value == val)
            return index
    return 0
}

; 0 for tab, 1-12 for pluck w/fret
SendShawzinScalePluck(n) {
    send {left up}{down up}{right up}
    If (n == 1)
        send 1
    If (n == 2)
        send 2
    If (n == 3)
        send 3
    If (n == 4)
        send {left down}1
    If (n == 5)
        send {left down}2
    If (n == 6)
        send {left down}3
    If (n == 7)
        send {down down}1
    If (n == 8)
        send {down down}2
    If (n == 9)
        send {down down}3
    If (n == 10)
        send {right down}1
    If (n == 11)
        send {right down}2
    If (n == 12)
        send {right down}3
}

MidiBeep(n, m) {
    x := 440 * (2 ** ((n-69)/12))
    SoundBeep x, m
}

z::HandleKey(0, 0)
x::HandleKey(0, 1)
c::HandleKey(0, 2)
v::HandleKey(0, 3)
b::HandleKey(0, 4)
n::HandleKey(0, 5)
m::HandleKey(0, 6)
,::HandleKey(0, 7)
.::HandleKey(0, 8)
/::HandleKey(0, 9)
a::HandleKey(1, 0)
s::HandleKey(1, 1)
d::HandleKey(1, 2)
f::HandleKey(1, 3)
g::HandleKey(1, 4)
h::HandleKey(1, 5)
j::HandleKey(1, 6)
k::HandleKey(1, 7)
l::HandleKey(1, 8)
SC027::HandleKey(1, 9)
'::HandleKey(1,10)
q::HandleKey(2, 0)
w::HandleKey(2, 1)
e::HandleKey(2, 2)
r::HandleKey(2, 3)
t::HandleKey(2, 4)
y::HandleKey(2, 5)
u::HandleKey(2, 6)
i::HandleKey(2, 7)
o::HandleKey(2, 8)
p::HandleKey(2, 9)
[::HandleKey(2,10)
]::HandleKey(2,11)
1::HandleKey(3, 0)
2::HandleKey(3, 1)
3::HandleKey(3, 2)
4::HandleKey(3, 3)
5::HandleKey(3, 4)
6::HandleKey(3, 5)
7::HandleKey(3, 6)
8::HandleKey(3, 7)
9::HandleKey(3, 8)
0::HandleKey(3, 9)
-::HandleKey(3,10)
=::HandleKey(3,11)
Backspace::HandleKey(3,12)
F1::HandleKey(4, 1)
F2::HandleKey(4, 2)
F3::HandleKey(4, 3)
F4::HandleKey(4, 4)
F5::HandleKey(4, 6)
F6::HandleKey(4, 7)
F7::HandleKey(4, 8)
F8::HandleKey(4, 9)

~Esc::
    send {left up}{down up}{right up}
    MidiBeep(72, 50)
    MidiBeep(60, 50)
    Suspend, 1
return

~Insert::
    Suspend
    Scale := 1
    MidiBeep(60, 50)
    MidiBeep(72, 50)
    Suspend, 0
return