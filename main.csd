<CsoundSynthesizer>

<CsOptions>
;============================================================
;Realtime Convolution for multiplatform export
;Giuseppe Ernandez Constp 2024
;============================================================
-odac -iadc
</CsOptions>

<CsInstruments>
;============================================================
;PARAMETRI DI CONTROLLO
;============================================================
sr = 48000
ksmps = 32
nchnls = 2
0dbfs  = 1

;============================================================
;Partitioned Convolution
;============================================================
instr Main

      ; dry wet
      kmix = port(chnget:k("drywet"),0.01,-1)
      kgain = port(chnget:k("gain"),0.01,-1)
      ;volume generico
      kvol  = 0.5 * kmix

      ; opzionale, controllo valori fuori scala
      kmix = (kmix < 0 || kmix > 1 ? .5 : kmix)
      kvol  = (kvol < 0 ? 0 : .5*kvol*kmix)

      ; Dimensione delle partizioni per la convoluzione
      ipartitionsize = 512

      ; Calcolo latenza, copiato dal sorgente
      idel = (ksmps < ipartitionsize ? ipartitionsize + ksmps : ipartitionsize)/sr
      prints "Convolving with a latency of %f seconds%n", idel

      ; Input
      al, ar ins
      ;########################################################################################
      ; DEBUG RMS
      kInputRMS rms al
      ;########################################################################################

      ; IR44 file impulso stereo
      awetl, awetr pconvolve kvol*(al+ar), "Impulse.wav", ipartitionsize
      
      ; Delay del segnale per compensare con tempi di calcolo
      ; convoluzione e mettere "a tempo" il riv.
      adryl delay (1-kmix)*al, idel
      adryr delay (1-kmix)*al, idel
      
      ;########################################################################################
      ; DEBUG RMS
      kOutRMS rms (adryl+awetl)*kgain
      printks "RMS input = %3.2f\\tRMS output = %3.2f\\n", 1, dbamp(kInputRMS), dbamp(kOutRMS)
      ;########################################################################################

      outs (adryl+awetl)*kgain, (adryr+awetr)*kgain
endin

; Prima chiamata, punto di inizio del programma
schedule("Main", 0, -1 )    
</CsInstruments>

<CsScore>

</CsScore>

</CsoundSynthesizer>
