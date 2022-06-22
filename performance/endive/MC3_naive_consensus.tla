-------------------- MODULE MC3_naive_consensus -----------------------------
Node == { "1_OF_N", "2_OF_N", "3_OF_N" }

Quorum == {
    {"1_OF_N", "2_OF_N"},
    {"1_OF_N", "3_OF_N"},
    {"2_OF_N", "3_OF_N"}
}

Value == { "1_OF_V", "2_OF_V" }

VARIABLES
    \* @type: Set(<<N, V>>);
    vote,
    \* @type: Set(<<Set(N), V>>);
    decide,
    \* @type: Set(V);
    decision

INSTANCE naive_consensus
===============================================================================
