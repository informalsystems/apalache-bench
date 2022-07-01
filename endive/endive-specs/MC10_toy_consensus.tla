------------------ MODULE MC10_toy_consensus -----------------------------
Node == { "1_OF_N", "2_OF_N", "3_OF_N", "4_OF_N", "5_OF_N", "6_OF_N", "7_OF_N", "8_OF_N", "9_OF_N", "10_OF_N" }

Value == { "1_OF_V", "2_OF_V", "3_OF_V", "4_OF_V", "5_OF_V", "6_OF_V", "7_OF_V", "8_OF_V", "9_OF_V" }

Nil == "Nil_OF_V"

VARIABLES
    \* @type: N -> V;
    vote,
    \* @type: Set(V);
    decision

INSTANCE toy_consensus
===============================================================================
