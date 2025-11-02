;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Functions to look up the addressing mode, opcode length and mnemonic for
; a given opcode.
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------

; opcode_str
;
; Returns the mnemonic ASCII letters of an opcode.
; Example:
;   Opcode in A: $A9 -> A: 'L', X: 'D', Y: 'A'
;
; In:   A: Opcode
; Out:  A: First letter of ASCII mnemonic
; Out:  X: Second letter of ASCII mnemonic
; Out:  Y: Third letter of ASCII mnemonic
; Mod:  A, X, Y, flags
.export opcode_str

; opcode_addr_mode
;
; Returns the addressing mode of the given opcode:
;       imm = 0     LDA #$12
;       zp  = 1     LDA $12
;       zpx = 2     LDA $12,X
;       zpy = 3     LDA $12,Y
;       izx = 4     LDA ($12,X)
;       izy = 5     LDA ($12),Y
;       abl = 6     LDA $1234
;       abx = 7     LDA $1234,X
;       aby = 8     LDA $1234,Y
;       ind = 9     JMP ($1234)
;       rel = 10    BNE $1234
;       non = 11    NOP
;
; In:   A: Opcode
; Out:  A: Addressing mode
; Mod:  A, X, flags
.export opcode_addr_mode

; opcode_len
;
; Returns the length of a given opcode.
;
; In:   A: Opcode
; Out:  A: Length of the given opcode
; Mod:  A, X, flags
.export opcode_len

;-----------------------------------------------------------------------------
; Local implementation
;-----------------------------------------------------------------------------
.segment "DATA"
offset:     .res 1

;-----------------------------------------------------------------------------
; Note:
;   In order to save memory the tables below do not contain the columns that
;   only have illegal opcode, i.e. columns x3, x7, xB, xF.
;
;   This results in a table of 16 rows with 12 columns each.
;
;   Also, this will only work for the original 6502 opcode set. Opcodes of
;   newer 6502 variants will be decoded as illegal opcodes as they do not exist
;   in this table.
;
; ---+-----------------------------------------------------------------------------
;    | 00      01           02       03      04         05         06         07
; ---+-----------------------------------------------------------------------------
; 00 | BRK i   ORA (zp,x)                               ORA zp     ASL zp
; 10 | BPL r   ORA (zp),y                               ORA zp,x   ASL zp,x
; 20 | JSR a   AND (zp,x)                    BIT zp     AND zp     ROL zp
; 30 | BMI r   AND (zp),y                               AND zp,x   ROL zp,x
; 40 | RTI i   EOR (zp,x)                               EOR zp     LSR zp
; 50 | BVC r   EOR (zp),y                               EOR zp,x   LSR zp,x
; 60 | RTS i   ADC (zp,x)                               ADC zp     ROR zp
; 70 | BVS r   ADC (zp),y                               ADC zp,x   ROR zp,x
; 80 |         STA (zp,x)                    STY zp     STA zp     STX zp
; 90 | BCC r   STA (zp),y                    STY zp,x   STA zp,x   STX zp,y
; A0 | LDY #   LDA (zp,x)   LDX #            LDY zp     LDA zp     LDX zp
; B0 | BCS r   LDA (zp),y                    LDY zp,x   LDA zp,x   LDX zp,y
; C0 | CPY #   CMP (zp,x)                    CPY zp     CMP zp     DEC zp
; D0 | BNE r   CMP (zp),y                               CMP zp,x   DEC zp,x
; E0 | CPX #   SBC (zp,x)                    CPX zp     SBC zp     INC zp
; F0 | BEQ r   SBC (zp),y                               SBC zp,x   INC zp,x
; ---+-----------------------------------------------------------------------------
;    | 08      09           0A       0B      0C         0D         0E         0F
; ---+-----------------------------------------------------------------------------
; 00 | PHP i   ORA #        ASL A                       ORA a      ASL a
; 10 | CLC i   ORA a,y                                  ORA a,x    ASL a,x
; 20 | PLP i   AND #        ROL A            BIT a      AND a      ROL a
; 30 | SEC i   AND a,y                                  AND a,x    ROL a,x
; 40 | PHA i   EOR #        LSR A            JMP a      EOR a      LSR a
; 50 | CLI i   EOR a,y                                  EOR a,x    LSR a,x
; 60 | PLA i   ADC #        ROR A            JMP (a)    ADC a      ROR a
; 70 | SEI i   ADC a,y                                  ADC a,x    ROR a,x
; 80 | DEY i   BIT #        TXA i            STY a      STA a      STX a
; 90 | TYA i   STA a,y      TXS i                       STA a,x
; A0 | TAY i   LDA #        TAX i            LDY a      LDA a      LDX a
; B0 | CLV i   LDA a,y      TSX i            LDY a,x    LDA a,x    LDX a,y
; C0 | INY i   CMP #        DEX i            CPY a      CMP a      DEC a
; D0 | CLD i   CMP a,y                                  CMP a,x    DEC a,x
; E0 | INX i   SBC #        NOP i            CPX a      SBC a      INC a
; F0 | SED i   SBC a,y                                  SBC a,x    INC a,x
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Opcode lookup tables and helper functions
;-----------------------------------------------------------------------------
.segment "CODE"

opcode_len:
        jsr opcode_addr_mode
        tax
        lda opcode_len_table,x
        rts

opcode_addr_mode:
        jsr opcode_table_index
        lsr a
        tax
        lda opcode_addr_mode_table,x
        bcs noshift     ; Result is in low nibble
        lsr a           ; Result is in high nibble
        lsr a
        lsr a
        lsr a
noshift:
        and #$0f
        rts

opcode_str:
        jsr opcode_table_index
        tax
        lda opcode_str_offs,x
        tax
        lda opcode_txt_table + 2,x
        tay
        lda opcode_txt_table,x
        pha
        lda opcode_txt_table + 1,x
        tax
        pla
        rts
        
; opcode_table_index
;
; Returns the index into the opcode lookup tables for a given opcode.
;
; In:   A: Opcode
; Out:  A: Table index for opcode
; Mod:  A, X, flags

opcode_table_index:
        tax
        and #%00000011  ; All opcodes with bits 0 and 1
        cmp #%00000011  ; set are illegal

        ; If A == 3 here then we have an illegal opcode. By definition, entry 3
        ; in the table is an illegal opcode. Therefore, we can just return with
        ; A (index) == 3.
        beq exit

        ; Tables are 16 rows at 12 columns
        ; index = (opc & 0xfc) * 3 + (opc & 0x03)
        txa
        lsr a
        lsr a
        sta offset
        asl a
        adc offset
        sta offset         ; (opc & 0xfc) * 3

        txa
        and #%00000011
        adc offset         ; + (opc & 0x03)
exit:
        rts

;-----------------------------------------------------------------------------
.segment "ROM"

imm = 0
zp  = 1
zpx = 2
zpy = 3
izx = 4
izy = 5
abl = 6
abx = 7
aby = 8
ind = 9
rel = 10
non = 11

; To save space we pack the addressing mode indices into 4 bits.
.macro opcode_mode o1, o2, o3, o4, o5, o6
    .byte (o1 << 4 | (o2))
    .byte (o3 << 4 | (o4))
    .byte (o5 << 4 | (o6))
.endmacro

;-----------------------------------------------------------------------------
opcode_len_table: .byte 2,2,2,2,2,2,3,3,3,3,2,1

opcode_addr_mode_table:
        ; 00
        opcode_mode non, izx, non, non,  zp,  zp
        opcode_mode non, imm, non, non, abl, abl
        ; 10
        opcode_mode rel, izy, non, non, zpx, zpx
        opcode_mode non, aby, non, non, abx, abx
        ; 20
        opcode_mode abl, izx, non,  zp,  zp,  zp
        opcode_mode non, imm, non, abl, abl, abl
        ; 30
        opcode_mode rel, izy, non, non, zpx, zpx
        opcode_mode non, aby, non, non, abx, abx
        ; 40
        opcode_mode non, izx, non, non,  zp,  zp
        opcode_mode non, imm, non, abl, abl, abl
        ; 50
        opcode_mode rel, izy, non, non, zpx, zpx
        opcode_mode non, aby, non, non, abx, abx
        ; 60
        opcode_mode non, izx, non, non,  zp,  zp
        opcode_mode non, imm, non, ind, abl, abl
        ; 70
        opcode_mode rel, izy, non, non, zpx, zpx
        opcode_mode non, aby, non, non, abx, abx
        ; 80
        opcode_mode non, izx, non,  zp,  zp,  zp
        opcode_mode non, non, non, abl, abl, abl
        ; 90
        opcode_mode rel, izy, non, zpx, zpx, zpy
        opcode_mode non, aby, non, non, abx, non
        ; A0
        opcode_mode imm, izx, imm,  zp,  zp,  zp
        opcode_mode non, imm, non, abl, abl, abl
        ; B0
        opcode_mode rel, izy, non, zpx, zpx, zpy
        opcode_mode non, aby, non, abx, abx, aby
        ; C0
        opcode_mode imm, izx, non,  zp,  zp,  zp
        opcode_mode non, imm, non, abl, abl, abl
        ; D0
        opcode_mode rel, izy, non, non, zpx, zpx
        opcode_mode non, aby, non, non, abx, abx
        ; E0
        opcode_mode imm, izx, non,  zp,  zp,  zp
        opcode_mode non, imm, non, abl, abl, abl
        ; F0
        opcode_mode rel, izy, non, non, zpx, zpx
        opcode_mode non, aby, non, non, abx, abx

;-----------------------------------------------------------------------------
opcode_txt_table:
mBNE = * - opcode_txt_table
        .byte "BN"
mEOR = * - opcode_txt_table
        .byte "E"
mORA = * - opcode_txt_table
        .byte "ORA"

mJSR = * - opcode_txt_table
        .byte "JS"
mROR = * - opcode_txt_table
        .byte "RO"
mROL = * - opcode_txt_table
        .byte "RO"
mLDA = * - opcode_txt_table
        .byte "LD"
mADC = * - opcode_txt_table
        .byte "AD"
mCLC = * - opcode_txt_table
        .byte "CL"
mCLI = * - opcode_txt_table
        .byte "CL"
mINX = * - opcode_txt_table
        .byte "INX"

mBCS = * - opcode_txt_table
        .byte "BC"
mSEI = * - opcode_txt_table
        .byte "SE"
mINC = * - opcode_txt_table
        .byte "IN"
mCLD = * - opcode_txt_table
        .byte "CL"
mDEX = * - opcode_txt_table
        .byte "DEX"

mLSR = * - opcode_txt_table
        .byte "LS"
mRTS = * - opcode_txt_table
        .byte "RT"
mSED = * - opcode_txt_table
        .byte "SE"
mDEC = * - opcode_txt_table
        .byte "DE"
mCLV = * - opcode_txt_table
        .byte "CLV"

mJMP = * - opcode_txt_table
        .byte "JM"
mPHA = * - opcode_txt_table
        .byte "PH"
mAND = * - opcode_txt_table
        .byte "AN"
mDEY = * - opcode_txt_table
        .byte "DEY"

mNOP = * - opcode_txt_table
        .byte "NO"
mPHP = * - opcode_txt_table
        .byte "PH"
mPLP = * - opcode_txt_table
        .byte "PL"
mPLA = * - opcode_txt_table
        .byte "PL"
mASL = * - opcode_txt_table
        .byte "AS"
mLDX = * - opcode_txt_table
        .byte "LDX"

mBVS = * - opcode_txt_table
        .byte "BV"
mSBC = * - opcode_txt_table
        .byte "SB"
mCMP = * - opcode_txt_table
        .byte "CMP"

mRTI = * - opcode_txt_table
        .byte "RT"
mINY = * - opcode_txt_table
        .byte "INY"

mBIT = * - opcode_txt_table
        .byte "BI"
mTXS = * - opcode_txt_table
        .byte "TX"
mSEC = * - opcode_txt_table
        .byte "SE"
mCPX = * - opcode_txt_table
        .byte "CPX"

mBCC = * - opcode_txt_table
        .byte "BC"
mCPY = * - opcode_txt_table
        .byte "CPY"

mBPL = * - opcode_txt_table
        .byte "BP"
mLDY = * - opcode_txt_table
        .byte "LDY"

mSTA = * - opcode_txt_table
        .byte "S"
mTAY = * - opcode_txt_table
        .byte "TAY"

mSTX = * - opcode_txt_table
        .byte "S"
mTXA = * - opcode_txt_table
        .byte "TXA"

mSTY = * - opcode_txt_table
        .byte "S"
mTYA = * - opcode_txt_table
        .byte "TYA"

; Can't seem to be able to merge those... :-(
mBEQ = * - opcode_txt_table
        .byte "BEQ"
mBMI = * - opcode_txt_table
        .byte "BMI"
mBRK = * - opcode_txt_table
        .byte "BRK"
mBVC = * - opcode_txt_table
        .byte "BVC"
mTAX = * - opcode_txt_table
        .byte "TAX"
mTSX = * - opcode_txt_table
        .byte "TSX"

m___ = * - opcode_txt_table
        .byte "???"

opcode_str_offs:
    .byte mBRK, mORA, m___, m___, mORA, mASL, mPHP, mORA, mASL, m___, mORA, mASL
    .byte mBPL, mORA, m___, m___, mORA, mASL, mCLC, mORA, m___, m___, mORA, mASL
    .byte mJSR, mAND, m___, mBIT, mAND, mROL, mPLP, mAND, mROL, mBIT, mAND, mROL
    .byte mBMI, mAND, m___, m___, mAND, mROL, mSEC, mAND, m___, m___, mAND, mROL
    .byte mRTI, mEOR, m___, m___, mEOR, mLSR, mPHA, mEOR, mLSR, mJMP, mEOR, mLSR
    .byte mBVC, mEOR, m___, m___, mEOR, mLSR, mCLI, mEOR, m___, m___, mEOR, mLSR
    .byte mRTS, mADC, m___, m___, mADC, mROR, mPLA, mADC, mROR, mJMP, mADC, mROR
    .byte mBVS, mADC, m___, m___, mADC, mROR, mSEI, mADC, m___, m___, mADC, mROR
    .byte m___, mSTA, m___, mSTY, mSTA, mSTX, mDEY, m___, mTXA, mSTY, mSTA, mSTX
    .byte mBCC, mSTA, m___, mSTY, mSTA, mSTX, mTYA, mSTA, mTXS, m___, mSTA, m___
    .byte mLDY, mLDA, mLDX, mLDY, mLDA, mLDX, mTAY, mLDA, mTAX, mLDY, mLDA, mLDX
    .byte mBCS, mLDA, m___, mLDY, mLDA, mLDX, mCLV, mLDA, mTSX, mLDY, mLDA, mLDX
    .byte mCPY, mCMP, m___, mCPY, mCMP, mDEC, mINY, mCMP, mDEX, mCPY, mCMP, mDEC
    .byte mBNE, mCMP, m___, m___, mCMP, mDEC, mCLD, mCMP, m___, m___, mCMP, mDEC
    .byte mCPX, mSBC, m___, mCPX, mSBC, mINC, mINX, mSBC, mNOP, mCPX, mSBC, mINC
    .byte mBEQ, mSBC, m___, m___, mSBC, mINC, mSED, mSBC, m___, m___, mSBC, mINC
