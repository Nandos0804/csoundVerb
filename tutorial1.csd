<CsoundSynthesizer>

<CsOptions>
;============================================================
;Realtime Convolution for multiplatform export
;Giuseppe Ernandez Constp 2024
;NO STOP
;USCITA FORZATA UNICA CONDIZIONE DI CHIUSURA DEL PROGRAMMA
;USARE CUFFIE! NESSUNA PROTIZIONE DA FEEDBACK
;============================================================
-odac -iadc
</CsOptions>

<CsInstruments>
;============================================================
;PARAMETRI DI CONTROLLO
;============================================================
sr = 44100
ksmps = 32
nchnls = 2
0dbfs  = 1

;============================================================
;Partitioned Convolution
;============================================================
instr Main
        ; dry wet
        kmix = .5

        ;volume generico
        kvol  = .05*kmix
                             			
        ; opzionale, controllo valori fuori scala
        kmix = (kmix < 0 || kmix > 1 ? .5 : kmix)
        kvol  = (kvol < 0 ? 0 : .5*kvol*kmix)
        
        ; Dimensione delle partizioni per la convoluzione
        ipartitionsize = 256
        
        ; Calcolo latenza, copiato dal sorgente
        idel = (ksmps < ipartitionsize ? ipartitionsize + ksmps : ipartitionsize)/sr
        prints "Convolving with a latency of %f seconds%n", idel
        
        ; Input
        al, ar ins

        ; IR44 file impulso stereo
        awetl, awetr pconvolve kvol*(al+ar), "IR44.wav", ipartitionsize

        ; Delay del segnale per compensare con tempi di calcolo
        ; convoluzione e mettere "a tempo" il riv.
        adryl delay (1-kmix)*al, idel
        adryr delay (1-kmix)*al, idel
              outs adryl+awetl, adryr+awetr
endin

; Prima chiamata, punto di inizio del programma
schedule("Main", 0, 60*60*24*7 )    
</CsInstruments>

<CsScore>

</CsScore>

</CsoundSynthesizer>
