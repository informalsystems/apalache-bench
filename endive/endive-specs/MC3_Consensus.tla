----------------------------- MODULE MC3_Consensus -----------------------------
Value == { "1_OF_V", "2_OF_V", "3_OF_V" }

VARIABLE
    \* @type: Set(V);
    chosen

INSTANCE Consensus    
================================================================================
